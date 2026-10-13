part of 'local_game_repository.dart';

final _usageStore = stringMapStoreFactory.store('question_usage_v1');
const _pageBits = 4096;
const _pageBytes = _pageBits ~/ 8;
String _idAlias(String id) => 'id.${sha256.convert(utf8.encode(id))}';
String _contentAlias(Question q) => 'content.${questionFingerprint(q)}';

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
      (meta['next'] as int) < 0) {
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
  // Import all readable old checkpoints before any replacement can erase history.
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
        /* Retain unreadable documents. */
      }
    }
  }
  if (ledger.next == 0 && hasLegacy && legacy.isEmpty) {
    throw const FormatException(
      'Cannot migrate unreadable question-use history.',
    );
  }
  final catalog = [...questions, for (final save in legacy) ...save.questions];
  for (final q in catalog) {
    final idKey = _idAlias(q.id), contentKey = _contentAlias(q);
    final oldId = ledger.aliases[idKey],
        oldContent = ledger.aliases[contentKey];
    final index = oldId ?? oldContent ?? ledger.next++;
    final page = index ~/ _pageBits;
    if (!ledger.pages.containsKey(page)) {
      ledger.pages[page] = List.filled(_pageBytes, 0);
      ledger.dirty.add(page);
    }
    if (oldContent != null && ledger.used(oldContent)) ledger.mark(index);
    for (final key in [idKey, contentKey]) {
      if (!ledger.aliases.containsKey(key)) {
        ledger.aliases[key] = index;
        await _usageStore
            .record(key)
            .put(txn, SembastGameRepository._signed({'index': index}));
      }
    }
  }
  for (final save in legacy) {
    for (final q in save.questions.where(
      (q) =>
          !ledger.cycles.containsKey(q.categoryId) &&
          save.state.seenQuestionIds.contains(q.id),
    )) {
      ledger.mark(ledger.aliases[_idAlias(q.id)]!);
      ledger.mark(ledger.aliases[_contentAlias(q)]!);
    }
  }
  await _writePages(txn, ledger);
  await _usageStore
      .record('meta')
      .put(txn, SembastGameRepository._signed(ledger.metadata()));
  await SembastGameRepository.store
      .record('usage.required')
      .put(txn, SembastGameRepository._signed({'version': 1}));
  return QuestionUsage(
    ids: catalog
        .where(
          (q) =>
              ledger.used(ledger.aliases[_idAlias(q.id)]!) ||
              ledger.used(ledger.aliases[_contentAlias(q)]!),
        )
        .map((q) => q.id)
        .toSet(),
    fingerprints: catalog
        .where(
          (q) =>
              ledger.used(ledger.aliases[_idAlias(q.id)]!) ||
              ledger.used(ledger.aliases[_contentAlias(q)]!),
        )
        .map(questionFingerprint)
        .toSet(),
  );
});

/// A deliberate new cycle clears only this section's bits, atomically.
Future<QuestionUsage> _resetCategory(
  SembastGameRepository repository,
  String categoryId,
  Iterable<Question> catalog,
) => repository.database.transaction((txn) async {
  final ledger = await _readUsage(txn);
  final questions = catalog.where((q) => q.categoryId == categoryId).toList();
  if (questions.isEmpty) throw StateError('Empty category cannot be renewed.');
  final indices = <int>{};
  for (final question in questions) {
    final idIndex = ledger.aliases[_idAlias(question.id)],
        contentIndex = ledger.aliases[_contentAlias(question)];
    if (idIndex == null ||
        contentIndex == null ||
        (!ledger.used(idIndex) && !ledger.used(contentIndex))) {
      throw StateError('Only exhausted categories can be renewed.');
    }
    indices
      ..add(idIndex)
      ..add(contentIndex);
  }
  for (final index in indices) {
    ledger.clear(index);
  }
  ledger.cycles.update(categoryId, (cycle) => cycle + 1, ifAbsent: () => 1);
  await _writePages(txn, ledger);
  await _usageStore
      .record('meta')
      .put(txn, SembastGameRepository._signed(ledger.metadata()));
  return QuestionUsage(
    ids: catalog
        .where(
          (q) =>
              ledger.used(ledger.aliases[_idAlias(q.id)]!) ||
              ledger.used(ledger.aliases[_contentAlias(q)]!),
        )
        .map((q) => q.id)
        .toSet(),
    fingerprints: catalog
        .where(
          (q) =>
              ledger.used(ledger.aliases[_idAlias(q.id)]!) ||
              ledger.used(ledger.aliases[_contentAlias(q)]!),
        )
        .map(questionFingerprint)
        .toSet(),
  );
});

Future<void> _commitQuestion(
  SembastGameRepository repository,
  SessionSave session,
  Question question,
) => repository.database.transaction((txn) async {
  _validateReveal(session, question);
  // Read only the two identities and their pages on the reveal path.
  final indices = <int>{};
  for (final key in [_idAlias(question.id), _contentAlias(question)]) {
    final raw = await _usageStore.record(key).get(txn);
    if (raw == null) throw const FormatException('Unregistered question.');
    indices.add(SembastGameRepository._verify(raw)['index'] as int);
  }
  final pages = <int, List<int>>{};
  for (final index in indices) {
    final page = index ~/ _pageBits;
    final raw = await _usageStore.record('page.$page').get(txn);
    if (raw == null) throw const FormatException('Missing question-use page.');
    final bytes = pages.putIfAbsent(
      page,
      () => base64Decode(
        SembastGameRepository._verify(raw)['bits'] as String,
      ).toList(),
    );
    if (bytes.length != _pageBytes ||
        (bytes[index % _pageBits ~/ 8] & (1 << (index % 8))) != 0) {
      throw StateError('Question already shown or ledger damaged.');
    }
    bytes[index % _pageBits ~/ 8] |= 1 << (index % 8);
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
  for (final entry in pages.entries) {
    await _usageStore
        .record('page.${entry.key}')
        .put(
          txn,
          SembastGameRepository._signed({'bits': base64Encode(entry.value)}),
        );
  }
  await SembastGameRepository.store
      .record(SembastGameRepository.currentKey)
      .put(txn, SembastGameRepository._signed(session.toJson()));
});
