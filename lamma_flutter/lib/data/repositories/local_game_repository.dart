import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sembast/sembast.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/session_save.dart';
import '../../domain/models/question.dart';
import '../../domain/models/question_usage.dart';
part 'question_usage_storage.dart';

void _validateReveal(SessionSave session, Question question) {
  if (session.state.question?.id != question.id ||
      session.state.revealedCards != 3 ||
      !session.state.seenQuestionIds.contains(question.id) ||
      questionFingerprint(session.state.question!) !=
          questionFingerprint(question)) {
    throw StateError(
      'Use flag requires the matching revealed question checkpoint.',
    );
  }
}

final class LocalLoadResult {
  const LocalLoadResult({
    required this.settings,
    this.session,
    this.notice,
    this.unreadableSession = false,
  });
  final AppSettings settings;
  final SessionSave? session;
  final String? notice;
  final bool unreadableSession;
}

abstract interface class LocalGameRepository {
  Future<QuestionUsage> resetCategory(
    String categoryId,
    Iterable<Question> catalog,
  );
  Future<QuestionUsage> prepareUsage(Iterable<Question> questions);
  Future<void> commitQuestion(SessionSave session, Question question);
  Future<LocalLoadResult> load();
  Future<void> saveSettings(AppSettings settings);
  Future<void> saveSession(SessionSave session);
  Future<void> close();
}

class SembastGameRepository implements LocalGameRepository {
  SembastGameRepository(this.database);
  final Database database;
  @override
  Future<QuestionUsage> resetCategory(
    String categoryId,
    Iterable<Question> catalog,
  ) => _resetCategory(this, categoryId, catalog);
  @override
  Future<QuestionUsage> prepareUsage(Iterable<Question> questions) =>
      _prepareUsage(this, questions);
  @override
  Future<void> commitQuestion(SessionSave session, Question question) =>
      _commitQuestion(this, session, question);
  static final store = stringMapStoreFactory.store('lamma_local');
  static const currentKey = 'session.current',
      backupKey = 'session.backup',
      settingsBackupKey = 'settings.backup',
      settingsKey = 'settings';
  @override
  Future<LocalLoadResult> load() async {
    final documents = await database.transaction(
      (transaction) async => (
        await store.record(settingsKey).get(transaction),
        await store.record(settingsBackupKey).get(transaction),
        await store.record(currentKey).get(transaction),
        await store.record(backupKey).get(transaction),
      ),
    );
    final (rawSettings, backupSettings, current, backup) = documents;
    var settings = const AppSettings();
    String? notice;
    if (rawSettings != null) {
      try {
        settings = AppSettings.fromJson(_verify(rawSettings));
      } on Object {
        try {
          if (backupSettings == null) {
            throw const FormatException('No settings backup.');
          }
          settings = AppSettings.fromJson(_verify(backupSettings));
          notice = 'استعدنا نسخة الإعدادات السابقة.';
        } on Object {
          notice =
              'تعذّر قراءة الإعدادات السابقة؛ استخدمنا الإعدادات الافتراضية.';
        }
      }
    }
    if (current == null && backup == null) {
      return LocalLoadResult(settings: settings, notice: notice);
    }
    if (current != null) {
      try {
        return LocalLoadResult(
          settings: settings,
          session: _readSession(current),
          notice: notice,
        );
      } on UnsupportedSaveVersion {
        return LocalLoadResult(
          settings: settings,
          notice: 'هذه الجلسة محفوظة بإصدار مختلف. احتفظنا ببياناتها.',
          unreadableSession: true,
        );
      } on Object {
        /* Try the last successfully committed snapshot. */
      }
    }
    if (backup != null) {
      try {
        return LocalLoadResult(
          settings: settings,
          session: _readSession(backup),
          notice: 'استعدنا نسخة الحفظ السابقة لأن آخر حفظ تعذّر قراءته.',
        );
      } on Object {
        /* Keep both records for diagnosis, without deleting data. */
      }
    }
    return LocalLoadResult(
      settings: settings,
      notice:
          'تعذّر قراءة الجلسة المحفوظة. احتفظنا ببياناتها حتى تختار بدء جلسة جديدة.',
      unreadableSession: true,
    );
  }

  static Map<String, dynamic> _json(Map<String, Object?> map) =>
      jsonDecode(jsonEncode(map)) as Map<String, dynamic>;
  static Object? _canonical(Object? value) {
    if (value is Map<String, Object?>) {
      final keys = value.keys.toList()..sort();
      return {for (final key in keys) key: _canonical(value[key])};
    }
    if (value is List<Object?>) return value.map(_canonical).toList();
    return value;
  }

  static String _digest(Map<String, Object?> value) =>
      sha256.convert(utf8.encode(jsonEncode(_canonical(value)))).toString();
  static Map<String, Object?> _signed(Map<String, Object?> value) => {
    ...value,
    '_checksum': _digest(value),
  };
  static Map<String, dynamic> _verify(Map<String, Object?> value) {
    final payload = Map<String, Object?>.from(value)..remove('_checksum');
    if (value['_checksum'] is! String ||
        value['_checksum'] != _digest(payload)) {
      throw const FormatException('Local record integrity check failed.');
    }
    return _json(payload);
  }

  static SessionSave _readSession(Map<String, Object?> value) {
    if (value['version'] != SessionSave.version && value['version'] != 1) {
      throw const UnsupportedSaveVersion();
    }
    return SessionSave.fromJson(_verify(value));
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await database.transaction((transaction) async {
      final previous = await store.record(settingsKey).get(transaction);
      if (previous != null) {
        try {
          AppSettings.fromJson(_verify(previous));
          await store.record(settingsBackupKey).put(transaction, previous);
        } on Object {
          /* Preserve an existing healthy backup. */
        }
      }
      await store
          .record(settingsKey)
          .put(transaction, _signed(settings.toJson()));
    });
  }

  @override
  Future<void> saveSession(SessionSave session) async {
    final document = session.toJson();
    SessionSave.fromJson(_json(document));
    await database.transaction((transaction) async {
      final previous = await store.record(currentKey).get(transaction);
      if (previous != null) {
        try {
          final validated = _readSession(previous);
          if (validated.id == session.id &&
              validated.revision > session.revision) {
            throw StateError('A newer snapshot already exists.');
          }
          await store.record(backupKey).put(transaction, previous);
        } on FormatException {
          /* Never replace a healthy backup with damaged data. */
        }
      }
      await store.record(currentKey).put(transaction, _signed(document));
    });
  }

  @override
  Future<void> close() => database.close();
}

class MemoryGameRepository implements LocalGameRepository {
  final Set<String> _resetCategories = {};
  @override
  Future<QuestionUsage> resetCategory(
    String categoryId,
    Iterable<Question> catalog,
  ) async {
    final questions = catalog.where((q) => q.categoryId == categoryId).toList();
    if (questions.isEmpty || questions.any((q) => !usage.contains(q))) {
      throw StateError('Only exhausted categories can be renewed.');
    }
    usage.clearQuestions(questions);
    _resetCategories.add(categoryId);
    return usage;
  }

  final QuestionUsage usage = QuestionUsage();
  @override
  Future<QuestionUsage> prepareUsage(Iterable<Question> questions) async {
    for (final q in session?.questions ?? <Question>[]) {
      if (!_resetCategories.contains(q.categoryId) &&
          session!.state.seenQuestionIds.contains(q.id)) {
        usage.mark(q);
      }
    }
    return usage;
  }

  @override
  Future<void> commitQuestion(SessionSave value, Question question) async {
    _validateReveal(value, question);
    if (usage.contains(question)) throw StateError('Question already shown.');
    await saveSession(value);
    usage.mark(question);
  }

  AppSettings settings = const AppSettings();
  SessionSave? session;
  @override
  Future<LocalLoadResult> load() async =>
      LocalLoadResult(settings: settings, session: session);
  @override
  Future<void> saveSettings(AppSettings value) async {
    settings = value;
  }

  @override
  Future<void> saveSession(SessionSave value) async {
    session = SessionSave.fromJson(
      jsonDecode(jsonEncode(value.toJson())) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> close() async {}
}
