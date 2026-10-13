import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/repositories/local_game_repository.dart';
import '../data/repositories/question_repository.dart';
import '../domain/models/app_settings.dart';
import '../domain/models/session_config.dart';
import '../domain/models/session_save.dart';
import '../domain/models/question_usage.dart';
import '../domain/models/question.dart';
import '../features/session/session_view_model.dart';
import 'game_catalog.dart';

enum LocalSaveStatus { idle, saving, saved, error }

class AppController extends ChangeNotifier {
  AppController(
    this.repository, {
    QuestionRepository? questions,
    this.openingCardsEnabled = true,
  }) : _questions = questions;
  final bool openingCardsEnabled;
  QuestionRepository? _questions;
  late QuestionUsage _usage;
  Map<String, int> _availableCounts = const {};
  Map<String, int> _totalCounts = const {};
  bool _renewingCategory = false;
  int availableQuestionsForCategory(String id) => _availableCounts[id] ?? 0;
  int totalQuestionsForCategory(String id) => _totalCounts[id] ?? 0;
  bool isCategoryExhausted(String id) =>
      totalQuestionsForCategory(id) > 0 &&
      availableQuestionsForCategory(id) == 0;
  bool canPlayCategory(String id) =>
      totalQuestionsForCategory(id) >= GameRules.questionsPerCategory &&
      availableQuestionsForCategory(id) > 0;
  void _refreshAvailability() {
    final counts = <String, int>{};
    final totals = <String, int>{};
    for (final q in _questions!.forCategories(
      gameCategories.map((c) => c.id).toSet(),
    )) {
      totals.update(q.categoryId, (n) => n + 1, ifAbsent: () => 1);
      if (!_usage.contains(q)) {
        counts.update(q.categoryId, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    _availableCounts = Map.unmodifiable(counts);
    _totalCounts = Map.unmodifiable(totals);
  }

  Future<void> resetCategory(String id) async {
    if (!ready ||
        _renewingCategory ||
        session?.revealing == true ||
        !isCategoryExhausted(id) ||
        !gameCategories.any((c) => c.id == id)) {
      throw StateError('Category renewal is unavailable.');
    }
    _renewingCategory = true;
    try {
      await flush();
      final catalog = _questions!.forCategories(
        gameCategories.map((c) => c.id).toSet(),
      );
      final refreshed = await repository.resetCategory(id, catalog);
      _usage.replaceWith(refreshed);
      _refreshAvailability();
      _notify();
    } finally {
      _renewingCategory = false;
    }
  }

  final LocalGameRepository repository;
  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;
  SessionViewModel? _session;
  SessionViewModel? get session => _session;
  bool ready = false, unreadableSession = false;
  String? notice;
  LocalSaveStatus saveStatus = LocalSaveStatus.idle;
  DateTime? lastSavedAt;
  SessionSave? _pendingSession;
  bool _settingsDirty = false, _disposed = false, _snapshotError = false;
  Future<void>? _writing;
  bool get hasActiveSession =>
      session != null && session!.state.phase != SessionPhase.results;

  Future<void> initialize() async {
    final restored = await repository.load();
    _questions ??= await LocalQuestionRepository.load();
    _usage = await repository.prepareUsage([
      ..._questions!.forCategories(gameCategories.map((c) => c.id).toSet()),
      ...?restored.session?.questions,
    ]);
    if (_disposed) return;
    _settings = restored.settings;
    notice = restored.notice;
    unreadableSession = restored.unreadableSession;
    final retired =
        restored.session?.config.categoryIds.any(
          (id) => !gameCategories.any((category) => category.id == id),
        ) ??
        false;
    if (retired) {
      notice =
          'تغيّرت أقسام اللعبة. ابدأ جلسة جديدة بالأقسام المعتمدة؛ الحفظ القديم لم يُحذف.';
    } else if (restored.session != null) {
      final currentIds = _questions!
          .forCategories(restored.session!.config.categoryIds)
          .map((q) => q.id)
          .toSet();
      final blocked = restored.session!.questions
          .where((q) => q.isQuarantined || !currentIds.contains(q.id))
          .map((q) => q.id)
          .toSet();
      if (blocked.isNotEmpty) {
        notice =
            'تحتوي المباراة المحفوظة على أسئلة قديمة تحتاج إصلاحًا. ابدأ مباراة جديدة لاستخدام البنك المنقّح؛ لم تُحذف النقاط أو سجل المشاهدة.';
      }
      _attach(
        SessionViewModel.restore(
          restored.session!,
          usage: _usage,
          commitReveal: _commitReveal,
          blockedQuestionIds: blocked,
          openingCardsEnabled: openingCardsEnabled,
        ),
      );
      lastSavedAt = restored.session!.updatedAt;
      saveStatus = LocalSaveStatus.saved;
      // Save reconciled external-search time and any chosen opponent before
      // making restoration available to the UI. A new launch cannot reroll it.
      _onSessionChanged();
      await retrySave();
    }
    ready = true;
    _refreshAvailability();
    _notify();
  }

  Future<SessionViewModel> startSession(SessionConfig config) async {
    if (_renewingCategory) {
      throw StateError('Wait for category renewal to finish.');
    }
    await flush();
    if (config.categoryIds.any(
      (id) => !gameCategories.any((category) => category.id == id),
    )) {
      throw ArgumentError('Select approved categories.');
    }
    _questions ??= await LocalQuestionRepository.load();
    final planned = planMatchQuestions(
      questions: _questions!.forCategories(config.categoryIds),
      categoryIds: config.categoryIds,
      usage: _usage,
      includeAbilities: config.abilitiesEnabled,
    );
    final next = SessionViewModel(
      config: config,
      questions: LocalQuestionRepository(questions: planned),
      usage: _usage,
      commitReveal: _commitReveal,
      replayQuestionIds: planned.where(_usage.contains).map((q) => q.id),
      openingCardsEnabled: openingCardsEnabled,
    );
    try {
      await repository.saveSession(next.snapshot());
    } on Object {
      next.dispose();
      saveStatus = LocalSaveStatus.error;
      _notify();
      rethrow;
    }
    final previous = _session;
    previous?.removeListener(_onSessionChanged);
    _attach(next);
    previous?.dispose();
    unreadableSession = false;
    notice = null;
    lastSavedAt = DateTime.now();
    saveStatus = LocalSaveStatus.saved;
    _notify();
    return next;
  }

  void _attach(SessionViewModel model) {
    _session = model;
    model.addListener(_onSessionChanged);
  }

  Future<void> _commitReveal(SessionSave checkpoint, Question question) async {
    await flush();
    await repository.commitQuestion(checkpoint, question);
    _usage.mark(question);
    if (question.usageId == null) {
      for (final current
          in _questions!
              .forCategories({question.categoryId})
              .where((q) => q.id == question.id)) {
        _usage.mark(current);
      }
    }
    _refreshAvailability();
    lastSavedAt = DateTime.now();
  }

  void _onSessionChanged() {
    if (_disposed) return;
    try {
      _pendingSession = _session!.snapshot();
      _snapshotError = false;
    } on Object {
      _snapshotError = true;
      saveStatus = LocalSaveStatus.error;
      _notify();
      return;
    }
    _beginWrite();
  }

  void updateSettings(AppSettings settings) {
    if (_disposed) return;
    _settings = settings;
    _settingsDirty = true;
    _beginWrite();
  }

  void dismissNotice() {
    notice = null;
    _notify();
  }

  void _beginWrite() {
    if (_writing != null) return;
    final completion = Completer<void>();
    _writing = completion.future;
    saveStatus = LocalSaveStatus.saving;
    _notify();
    unawaited(_drain(completion));
  }

  Future<void> _drain(Completer<void> completion) async {
    var success = true;
    try {
      while (_pendingSession != null || _settingsDirty) {
        if (_settingsDirty) {
          final settings = _settings;
          await repository.saveSettings(settings);
          if (identical(settings, _settings)) _settingsDirty = false;
        }
        final pending = _pendingSession;
        if (pending != null) {
          await repository.saveSession(pending);
          if (identical(pending, _pendingSession)) _pendingSession = null;
          lastSavedAt = DateTime.now();
        }
      }
    } on Object {
      success = false;
    }
    saveStatus = success && !_snapshotError
        ? LocalSaveStatus.saved
        : LocalSaveStatus.error;
    _writing = null;
    _notify();
    completion.complete();
  }

  Future<void> flush() async {
    if (_snapshotError) {
      try {
        _pendingSession = _session!.snapshot();
        _snapshotError = false;
      } on Object {
        throw StateError('The current session could not be serialized.');
      }
    }
    while (_writing != null || _pendingSession != null || _settingsDirty) {
      if (_writing == null) _beginWrite();
      await _writing;
      if (saveStatus == LocalSaveStatus.error) {
        throw StateError('Local save did not complete.');
      }
    }
  }

  Future<bool> retrySave() async {
    try {
      await flush();
      return true;
    } on Object {
      return false;
    }
  }

  void background() {
    _session?.setForeground(false);
    unawaited(retrySave());
  }

  void foreground() => _session?.setForeground(true);
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _session?.removeListener(_onSessionChanged);
    if (_session != null) {
      try {
        _pendingSession = _session!.snapshot();
      } on Object {
        _snapshotError = true;
      }
    }
    _session?.dispose();
    _disposed = true;
    unawaited(_close());
    super.dispose();
  }

  Future<void> _close() async {
    try {
      await flush();
    } on Object {
      /* Preserve the last successful disk snapshot. */
    }
    try {
      await repository.close();
    } on Object {
      /* App disposal cannot recover a platform close failure. */
    }
  }
}
