part of 'local_game_repository.dart';

final _usageStore = stringMapStoreFactory.store('question_usage_v1');
const _pageBits = 4096;
const _pageBytes = _pageBits ~/ 8;
String _idAlias(String id) => 'id.${sha256.convert(utf8.encode(id))}';
String _numberAlias(Question q) => 'number.${questionUsageKey(q)}';
String _claimRecordKey(String sessionId, Question q) =>
    'replay.${sha256.convert(utf8.encode(questionClaimKey(sessionId, q)))}';

final class _UsageLedger {
  _UsageLedger(this.next, this.aliases, this.pages, this.cycles);
  int next;
  final Map<String, int> aliases;
  final Map<int, List<int>> pages;
  final Map<String, int> cycles;
  final Set<int> dirty = {};
  bool used(int index) =>
      (pages[index ~/ _pageBits]![index % _pageBits ~/ 8] &
          (1 << (index % 8))) !=
      0;
  void mark(int index) {
    if (used(index)) return;
    final page = index ~/ _pageBits;
    pages[page]![index % _pageBits ~/ 8] |= 1 << (index % 8);
    dirty.add(page);
  }

  void clear(int index) {
    if (!used(index)) return;
    final page = index ~/ _pageBits;
    pages[page]![index % _pageBits ~/ 8] &= ~(1 << (index % 8));
    dirty.add(page);
  }

  Map<String, Object?> metadata() => {
    'version': 1,
    'identityVersion': 2,
    'next': next,
    'aliases': aliases.length,
    'cycles': cycles,
  };
}

Future<_UsageLedger> _readUsage(DatabaseClient client) async {
  final rows = await _usageStore.find(client);
  if (rows.isEmpty) return _UsageLedger(0, {}, {}, {});
  final raw = await _usageStore.record('meta').get(client);
  if (raw == null) throw const FormatException('Missing question-use index.');
  final meta = SembastGameRepository._verify(raw);
  if (meta['version'] != 1 ||
      meta['next'] is! int ||
      (meta['next'] as int) < 0 ||
      ![null, 2].contains(meta['identityVersion'])) {
    throw const FormatException('Invalid question-use index.');
  }
  final next = meta['next'] as int;
  final cycles = (meta['cycles'] as Map<String, dynamic>? ?? {}).map(
    (key, value) => MapEntry(key, value as int),
  );
  if (cycles.values.any((value) => value < 1)) {
    throw const FormatException('Invalid category cycle.');
  }
  final aliases = <String, int>{};
  final pages = <int, List<int>>{};
  for (final row in rows) {
    if (row.key == 'meta') continue;
    final value = SembastGameRepository._verify(row.value);
    if (row.key.startsWith('page.')) {
      final number = int.parse(row.key.substring(5));
      final bytes = base64Decode(value['bits'] as String);
      if (bytes.length != _pageBytes ||
          number < 0 ||
          number >= (next + _pageBits - 1) ~/ _pageBits) {
        throw const FormatException('Invalid question-use page.');
      }
      pages[number] = bytes.toList();
    } else {
      final index = value['index'] as int;
      if (index < 0 || index >= next) {
        throw const FormatException('Invalid question-use alias.');
      }
      aliases[row.key] = index;
    }
  }
  if (aliases.length != meta['aliases'] ||
      pages.length != (next + _pageBits - 1) ~/ _pageBits) {
    throw const FormatException('Incomplete question-use ledger.');
  }
  return _UsageLedger(next, aliases, pages, cycles);
}

Future<void> _writePages(DatabaseClient client, _UsageLedger ledger) async {
  for (final page in ledger.dirty) {
    await _usageStore
        .record('page.$page')
        .put(
          client,
          SembastGameRepository._signed({
            'bits': base64Encode(ledger.pages[page]!),
          }),
        );
  }
}

Future<Set<String>> _readClaims(DatabaseClient client) async {
  final claims = <String>{};
  for (final row in await SembastGameRepository.store.find(client)) {
    if (!row.key.startsWith('replay.')) continue;
    final document = SembastGameRepository._verify(row.value);
    if (document['claim'] is! String) {
      throw const FormatException('Invalid replay claim.');
    }
    claims.add(document['claim'] as String);
  }
  return claims;
}

QuestionUsage _usageSnapshot(
  _UsageLedger ledger,
  Iterable<Question> questions,
  Set<String> claims,
) => QuestionUsage(
  ids: questions
      .where((q) => ledger.used(ledger.aliases[_idAlias(q.id)]!))
      .map((q) => q.id)
      .toSet(),
  keys: questions
      .where((q) => ledger.used(ledger.aliases[_idAlias(q.id)]!))
      .map(questionUsageKey)
      .toSet(),
  claims: claims,
);

Future<QuestionUsage> _prepareUsage(
  SembastGameRepository repository,
  Iterable<Question> questions,
) => repository.database.transaction((txn) async {
  final ledger = await _readUsage(txn);
  final required = await SembastGameRepository.store
      .record('usage.required')
      .get(txn);
  if (ledger.next == 0 && required != null) {
    throw const FormatException(
      'Question-use ledger disappeared; history cannot be reset.',
    );
  }
  final legacy = <SessionSave>[];
  var hasLegacy = false;
  for (final key in [
    SembastGameRepository.currentKey,
    SembastGameRepository.backupKey,
  ]) {
    final raw = await SembastGameRepository.store.record(key).get(txn);
    if (raw != null) {
      hasLegacy = true;
      try {
        legacy.add(SembastGameRepository._readSession(raw));
      } on Object {
        /* Preserve unreadable saves. */
      }
    }
  }
  if (ledger.next == 0 && hasLegacy && legacy.isEmpty) {
    throw const FormatException(
      'Cannot migrate unreadable question-use history.',
    );
  }
  // Prefer the current bank's numeric identity over old question snapshots.
  final byId = <String, Question>{};
  for (final q in [
    ...questions,
    for (final save in legacy) ...save.questions,
  ]) {
    if (!byId.containsKey(q.id) ||
        byId[q.id]!.usageId == null && q.usageId != null) {
      byId[q.id] = q;
    }
  }
  for (final q in byId.values) {
    final idKey = _idAlias(q.id), numberKey = _numberAlias(q);
    final oldId = ledger.aliases[idKey];
    var index = ledger.aliases[numberKey];
    final previousAlias = await _usageStore.record(idKey).get(txn);
    if (previousAlias != null) {
      final previousKey =
          SembastGameRepository._verify(previousAlias)['usageKey'] as String?;
      if (previousKey != null &&
          !previousKey.startsWith('legacy:') &&
          previousKey != questionUsageKey(q)) {
        throw StateError('A published numeric question identity changed.');
      }
    }
    if (index == null) {
      index = ledger.next++;
      final page = index ~/ _pageBits;
      if (!ledger.pages.containsKey(page)) {
        ledger.pages[page] = List.filled(_pageBytes, 0);
        ledger.dirty.add(page);
      }
      // Copy old ID history once. Never consult text hashes for new identities.
      if (oldId != null && ledger.used(oldId)) ledger.mark(index);
      ledger.aliases[numberKey] = index;
      await _usageStore
          .record(numberKey)
          .put(txn, SembastGameRepository._signed({'index': index}));
    }
    if (oldId != index ||
        previousAlias == null ||
        previousAlias['usageKey'] != questionUsageKey(q)) {
      ledger.aliases[idKey] = index;
      await _usageStore
          .record(idKey)
          .put(
            txn,
            SembastGameRepository._signed({
              'index': index,
              'usageKey': questionUsageKey(q),
            }),
          );
    }
  }
  for (final save in legacy) {
    for (final q in save.questions.where(
      (q) =>
          !ledger.cycles.containsKey(q.categoryId) &&
          save.state.seenQuestionIds.contains(q.id),
    )) {
      ledger.mark(ledger.aliases[_idAlias(q.id)]!);
    }
  }
  await _writePages(txn, ledger);
  await _usageStore
      .record('meta')
      .put(txn, SembastGameRepository._signed(ledger.metadata()));
  await SembastGameRepository.store
      .record('usage.required')
      .put(txn, SembastGameRepository._signed({'version': 1}));
  return _usageSnapshot(ledger, byId.values, await _readClaims(txn));
});

Future<QuestionUsage> _resetCategory(
  SembastGameRepository repository,
  String categoryId,
  Iterable<Question> catalog,
) => repository.database.transaction((txn) async {
  final ledger = await _readUsage(txn);
  final questions = catalog.where((q) => q.categoryId == categoryId).toList();
  if (questions.isEmpty) throw StateError('Empty category cannot be renewed.');
  final indices = <int>{};
  for (final q in questions) {
    final index = ledger.aliases[_numberAlias(q)];
    if (index == null || !ledger.used(index)) {
      throw StateError('Only exhausted categories can be renewed.');
    }
    indices.add(index);
  }
  for (final index in indices) {
    ledger.clear(index);
  }
  ledger.cycles.update(categoryId, (cycle) => cycle + 1, ifAbsent: () => 1);
  await _writePages(txn, ledger);
  await _usageStore
      .record('meta')
      .put(txn, SembastGameRepository._signed(ledger.metadata()));
  return _usageSnapshot(ledger, catalog, await _readClaims(txn));
});

Future<void> _commitQuestion(
  SembastGameRepository repository,
  SessionSave session,
  Question question,
) => repository.database.transaction((txn) async {
  _validateReveal(session, question);
  final raw =
      await _usageStore.record(_numberAlias(question)).get(txn) ??
      (question.usageId == null
          ? await _usageStore.record(_idAlias(question.id)).get(txn)
          : null);
  if (raw == null) throw const FormatException('Unregistered question.');
  final index = SembastGameRepository._verify(raw)['index'] as int;
  final page = index ~/ _pageBits;
  final pageRaw = await _usageStore.record('page.$page').get(txn);
  if (pageRaw == null) {
    throw const FormatException('Missing question-use page.');
  }
  final bytes = base64Decode(
    SembastGameRepository._verify(pageRaw)['bits'] as String,
  ).toList();
  if (bytes.length != _pageBytes) {
    throw const FormatException('Invalid question-use page.');
  }
  final used = (bytes[index % _pageBits ~/ 8] & (1 << (index % 8))) != 0;
  final replay = session.replayQuestionIds.contains(question.id);
  final claimKey = _claimRecordKey(session.id, question);
  if (await SembastGameRepository.store.record(claimKey).get(txn) != null ||
      used && !replay) {
    throw StateError('Question already shown or replay already claimed.');
  }
  final old = await SembastGameRepository.store
      .record(SembastGameRepository.currentKey)
      .get(txn);
  if (old != null) {
    final previous = SembastGameRepository._readSession(old);
    if (previous.id != session.id || previous.revision > session.revision) {
      throw StateError('Stale reveal checkpoint.');
    }
    await SembastGameRepository.store
        .record(SembastGameRepository.backupKey)
        .put(txn, old);
  }
  SessionSave.fromJson(SembastGameRepository._json(session.toJson()));
  if (!used) {
    bytes[index % _pageBits ~/ 8] |= 1 << (index % 8);
    await _usageStore
        .record('page.$page')
        .put(txn, SembastGameRepository._signed({'bits': base64Encode(bytes)}));
  }
  if (replay) {
    await SembastGameRepository.store
        .record(claimKey)
        .put(
          txn,
          SembastGameRepository._signed({
            'claim': questionClaimKey(session.id, question),
            'turn': session.state.turn,
          }),
        );
  }
  await SembastGameRepository.store
      .record(SembastGameRepository.currentKey)
      .put(txn, SembastGameRepository._signed(session.toJson()));
});
