import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/repositories/question_repository.dart';
import '../../domain/abilities/ability_system.dart';
import '../../domain/abilities/risk_engine.dart';
import '../../domain/models/question.dart';
import '../../domain/models/question_usage.dart';
import '../../domain/models/session_config.dart';
import '../../domain/models/session_save.dart';
import '../../domain/models/session_state.dart';
import '../../domain/models/team.dart';
import '../../domain/models/hint_access.dart';
export '../../domain/models/session_state.dart';

abstract interface class RiskRoundResolver {
  RiskSettlement settle({
    required Question question,
    required Set<String> selectedCategoryIds,
    required TeamState actingTeam,
    required TeamState? correctAnswerTeam,
    required int turn,
    required String cardInstanceId,
  });
}

class SessionViewModel extends ChangeNotifier {
  SessionViewModel({
    required this.config,
    required QuestionRepository questions,
    AbilityRegistry? abilities,
    this.riskResolver,
    SessionSave? restored,
    DateTime Function()? now,
    QuestionUsage? usage,
    this.commitReveal,
    Random? random,
    this.surpriseResolver,
  }) : _questions = questions,
       abilities = abilities ?? AbilityRegistry(),
       _now = now ?? DateTime.now {
    _usage = usage ?? QuestionUsage();
    _random = random ?? Random();
    id =
        restored?.id ?? 'session-${_now().microsecondsSinceEpoch}-${_nextId++}';
    createdAt = restored?.createdAt ?? _now();
    _updatedAt = restored?.updatedAt ?? createdAt;
    _revision = restored?.revision ?? 0;
    _state = restored == null
        ? SessionState(
            phase: SessionPhase.categories,
            teams: config.teams,
            seenQuestionIds: const {},
          )
        : restored.state.copyWith(
            pauseReason: restored.state.phase == SessionPhase.results
                ? PauseReason.none
                : PauseReason.restored,
          );
    _pool = List.unmodifiable(_questions.forCategories(config.categoryIds));
    for (final q in _pool.where((q) => state.seenQuestionIds.contains(q.id))) {
      if (usage == null) _usage.mark(q);
    }
    if (restored != null &&
        state.question != null &&
        state.revealedCards < 3 &&
        _usage.contains(state.question!)) {
      // A backup may precede an already committed reveal. Never draw it again.
      _state = state.copyWith(
        phase: SessionPhase.categories,
        clearQuestion: true,
        revealedCards: 0,
        isAbilityRound: false,
        roundData: {},
      );
      _revision++;
    }
    if (_pool.isEmpty ||
        config.categoryIds.any(
          (id) => !_pool.any((question) => question.categoryId == id),
        )) {
      throw ArgumentError(
        'Each selected category needs at least one question.',
      );
    }
    snapshot();
  }
  factory SessionViewModel.restore(
    SessionSave save, {
    AbilityRegistry? abilities,
    RiskRoundResolver? riskResolver,
    QuestionUsage? usage,
    Future<void> Function(SessionSave, Question)? commitReveal,
    SurpriseCard? Function(Question, TeamState, int)? surpriseResolver,
  }) => SessionViewModel(
    config: save.config,
    questions: LocalQuestionRepository(questions: save.questions),
    restored: save,
    abilities: abilities,
    riskResolver: riskResolver,
    usage: usage,
    commitReveal: commitReveal,
    surpriseResolver: surpriseResolver,
  );
  static int _nextId = 0;
  late final String id;
  late final DateTime createdAt;
  late DateTime _updatedAt;
  late int _revision;
  final DateTime Function() _now;
  final SessionConfig config;
  final QuestionRepository _questions;
  late List<Question> _pool;
  late final QuestionUsage _usage;
  late final Random _random;
  final Future<void> Function(SessionSave, Question)? commitReveal;
  final SurpriseCard? Function(Question, TeamState, int)? surpriseResolver;
  bool revealing = false;
  String? revealError;
  List<Question> _sectionQuestions(String id) {
    if (id == GameRules.abilitiesCategoryId) {
      final normalIds = {
        for (final category in config.categoryIds)
          ..._pool
              .where((q) => q.categoryId == category)
              .take(GameRules.questionsPerCategory)
              .map((q) => q.id),
      };
      return _pool
          .where((q) => !normalIds.contains(q.id))
          .take(GameRules.questionsPerCategory)
          .toList();
    }
    return _pool
        .where((q) => q.categoryId == id)
        .take(GameRules.questionsPerCategory)
        .toList();
  }

  bool _available(Question q) =>
      !_usage.contains(q) && !state.seenQuestionIds.contains(q.id);
  final AbilityRegistry abilities;
  final RiskRoundResolver? riskResolver;
  late SessionState _state;
  SessionState get state => _state;
  Timer? _timer;
  bool _foreground = true, _disposed = false;
  bool get abilitiesEnabled =>
      riskResolver != null && abilities.definitions.keys.any(abilities.isReady);
  bool get canResume => !state.isAbilityRound || abilitiesEnabled;
  List<Question> get remainingQuestions =>
      _pool.where(_available).toList(growable: false);
  int remainingForCategory(String id) =>
      _sectionQuestions(id).where(_available).length;
  SessionSave snapshot() => SessionSave(
    id: id,
    config: config,
    state: state,
    questions: _pool,
    createdAt: createdAt,
    updatedAt: _updatedAt,
    revision: _revision,
  );

  bool selectCategory(String id) {
    if (state.phase != SessionPhase.categories || state.isPaused) return false;
    final abilityRound = id == GameRules.abilitiesCategoryId;
    if (abilityRound && !abilitiesEnabled ||
        !abilityRound && !config.categoryIds.contains(id)) {
      return false;
    }
    final candidates = _sectionQuestions(id).where(_available).toList();
    if (candidates.isEmpty) return false;
    final surprise = surpriseResolver?.call(
      candidates.first,
      state.activeTeam,
      state.turn,
    );
    _set(
      state.copyWith(
        phase: SessionPhase.cards,
        question: candidates.first,
        revealedCards: 0,
        secondsRemaining: GameRules.primaryQuestionSeconds,
        isAbilityRound: abilityRound,
        roundData: {if (surprise != null) 'surpriseCard': surprise.toJson()},
      ),
    );
    return true;
  }

  bool revealCard(int index) {
    if (revealing ||
        state.isPaused ||
        state.phase != SessionPhase.cards ||
        state.revealedCards != index ||
        index < 0 ||
        index > 2) {
      return false;
    }
    if (index == 2 && commitReveal != null) {
      unawaited(revealQuestion());
      return true;
    }
    if (index == 2) {
      if (_usage.contains(state.question!)) return false;
      _usage.mark(state.question!);
    }
    _set(
      state.copyWith(
        revealedCards: index + 1,
        roundData: {
          ...state.roundData,
          if (index == 0 &&
              state.surpriseCard?.grantsHint == true &&
              state.question?.isIdentity == false &&
              state.question!.hint.isNotEmpty)
            'hintAccess': HintAccess(
              questionId: state.question!.id,
              teamId: state.activeTeam.id,
              source: HintSource.surprise,
              cardId: state.surpriseCard!.id,
            ).toJson(),
        },
        seenQuestionIds: index == 2
            ? {...state.seenQuestionIds, state.question!.id}
            : state.seenQuestionIds,
      ),
    );
    if (index == 2) _startTimer();
    return true;
  }

  /// The text stays hidden until both the use flag and checkpoint commit.
  Future<bool> revealQuestion() async {
    if (revealing ||
        state.isPaused ||
        state.phase != SessionPhase.cards ||
        state.revealedCards != 2) {
      return false;
    }
    if (commitReveal == null) return revealCard(2);
    final question = state.question!;
    final proposed = state.copyWith(
      revealedCards: 3,
      seenQuestionIds: {...state.seenQuestionIds, question.id},
    );
    final checkpoint = SessionSave(
      id: id,
      config: config,
      state: proposed,
      questions: _pool,
      createdAt: createdAt,
      updatedAt: _now(),
      revision: _revision + 1,
    );
    revealing = true;
    revealError = null;
    notifyListeners();
    try {
      await commitReveal!(checkpoint, question);
      _usage.mark(question);
      if (_disposed) return false;
      _set(proposed.copyWith(pauseReason: state.pauseReason));
      _startTimer();
      return true;
    } on Object {
      if (!_disposed) {
        revealError = 'تعذّر حفظ مشاهدة السؤال. بقي مخفياً؛ أعد المحاولة.';
      }
      return false;
    } finally {
      revealing = false;
      if (!_disposed) notifyListeners();
    }
  }

  bool get canShowAnswer =>
      !state.isPaused &&
      !revealing &&
      state.phase == SessionPhase.cards &&
      state.revealedCards == 3 &&
      (!state.isOpponentWindow || state.secondsRemaining == 0);

  bool startOpponentOpportunity() {
    if (state.isPaused ||
        revealing ||
        state.phase != SessionPhase.cards ||
        state.revealedCards != 3 ||
        state.opponentTeamId != null) {
      return false;
    }
    final others = state.teams
        .where((team) => team.id != state.activeTeam.id)
        .toList();
    final lowest = others.map((team) => team.score).reduce(min);
    final eligible = others.where((team) => team.score == lowest).toList();
    final chosen = eligible.length == 1
        ? eligible.single
        : eligible[_random.nextInt(eligible.length)];
    _set(
      state.copyWith(
        secondsRemaining: GameRules.opponentAnswerSeconds,
        roundData: {
          ...state.roundData,
          'answerWindow': 'opponent',
          'opponentTeamId': chosen.id,
          'opponentReason': others.length == 1
              ? 'only'
              : eligible.length > 1
              ? 'tie'
              : 'lowest',
        },
      ),
    );
    _startTimer();
    return true;
  }

  void _startTimer() {
    _timer?.cancel();
    if (!_foreground || state.isPaused) return;
    if (state.secondsRemaining <= 0) {
      if (!state.isOpponentWindow &&
          state.phase == SessionPhase.cards &&
          state.revealedCards == 3) {
        startOpponentOpportunity();
      }
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed ||
          state.isPaused ||
          state.secondsRemaining <= 0 ||
          state.phase != SessionPhase.cards) {
        timer.cancel();
        return;
      }
      if (state.secondsRemaining == 1 && !state.isOpponentWindow) {
        timer.cancel();
        startOpponentOpportunity();
        return;
      }
      _set(state.copyWith(secondsRemaining: state.secondsRemaining - 1));
      if (state.secondsRemaining == 0) {
        timer.cancel();
        if (!state.isOpponentWindow) startOpponentOpportunity();
      }
    });
  }

  void pause([PauseReason reason = PauseReason.manual]) {
    if (_disposed || state.phase == SessionPhase.results || state.isPaused) {
      return;
    }
    _timer?.cancel();
    _set(state.copyWith(pauseReason: reason));
  }

  bool resume() {
    if (_disposed ||
        !_foreground ||
        !canResume ||
        !state.isPaused ||
        state.phase == SessionPhase.results) {
      return false;
    }
    _set(state.copyWith(pauseReason: PauseReason.none));
    if (state.phase == SessionPhase.cards && state.revealedCards == 3) {
      _startTimer();
    }
    return true;
  }

  void setForeground(bool foreground) {
    _foreground = foreground;
    if (!foreground) pause(PauseReason.background);
  }

  bool showAnswer() {
    if (!canShowAnswer) {
      return false;
    }
    _timer?.cancel();
    _set(state.copyWith(phase: SessionPhase.answer));
    return true;
  }

  bool revealNextClue() {
    if (revealing ||
        state.isPaused ||
        state.phase != SessionPhase.cards ||
        state.revealedCards != 3 ||
        state.question?.isIdentity != true ||
        state.identityCluesRevealed >= 3 ||
        state.secondsRemaining <= 0) {
      return false;
    }
    _set(
      state.copyWith(
        roundData: {
          ...state.roundData,
          'identityCluesRevealed': state.identityCluesRevealed + 1,
        },
      ),
    );
    return true;
  }

  bool get canRevealHint =>
      !revealing &&
      !state.isPaused &&
      state.phase == SessionPhase.cards &&
      state.revealedCards == 3 &&
      state.secondsRemaining > 0 &&
      !state.hintRevealed &&
      state.question?.hint.isNotEmpty == true &&
      !state.question!.isIdentity &&
      state.hintAccess?.questionId == state.question!.id &&
      state.hintAccess?.teamId == state.answeringTeam.id;
  bool revealHint() {
    if (!canRevealHint) {
      return false;
    }
    _set(state.copyWith(roundData: {...state.roundData, 'hintRevealed': true}));
    return true;
  }

  bool awardAnswer(String? teamId) {
    if (state.isPaused ||
        state.phase != SessionPhase.answer ||
        state.history.any((round) => round.turn == state.turn) ||
        teamId != null && !state.teams.any((team) => team.id == teamId)) {
      return false;
    }
    if (state.opponentTeamId != null &&
        teamId != null &&
        teamId != state.opponentTeamId) {
      return false;
    }
    final question = state.question!;
    final before = state.teams;
    var teams = before;
    if (state.isAbilityRound) {
      if (!abilitiesEnabled) return false;
      final settlement = riskResolver!.settle(
        question: question,
        selectedCategoryIds: config.categoryIds,
        actingTeam: state.activeTeam,
        correctAnswerTeam: teamId == null
            ? null
            : teams.firstWhere((team) => team.id == teamId),
        turn: state.turn,
        cardInstanceId: '$id-ability-${state.turn}-${question.id}',
      );
      if (settlement.team.id != state.activeTeam.id) {
        throw StateError('Risk settlement must apply to the acting team.');
      }
      teams = teams
          .map((team) => team.id == settlement.team.id ? settlement.team : team)
          .toList();
    } else if (teamId != null) {
      teams = teams
          .map(
            (team) => team.id == teamId
                ? team.copyWith(score: team.score + state.availablePoints)
                : team,
          )
          .toList();
    }
    final record = RoundRecord(
      id: '$id-round-${state.turn}',
      turn: state.turn,
      question: question,
      actingTeamId: state.activeTeam.id,
      awardedTeamId: teamId,
      scoreDeltas: {
        for (var i = 0; i < teams.length; i++)
          teams[i].id: teams[i].score - before[i].score,
      },
      secondsAtAnswer: state.secondsRemaining,
      abilityRevision: state.abilityRevision,
      isAbilityRound: state.isAbilityRound,
      completedAt: _now(),
      identityCluesRevealed: state.identityCluesRevealed,
      answerTeamId: state.opponentTeamId,
    );
    _set(
      state.copyWith(
        phase:
            config.categoryIds.every((id) => remainingForCategory(id) == 0) &&
                (!abilitiesEnabled ||
                    remainingForCategory(GameRules.abilitiesCategoryId) == 0)
            ? SessionPhase.results
            : SessionPhase.categories,
        teams: teams,
        history: [...state.history, record],
        turn: state.turn + 1,
        clearQuestion: true,
        revealedCards: 0,
        isAbilityRound: false,
        roundData: {},
      ),
    );
    return true;
  }

  bool canCorrect(RoundRecord record) =>
      !record.isAbilityRound && record.abilityRevision == state.abilityRevision;
  bool correctDecision(
    String roundId,
    String? teamId, {
    int? expectedCorrectionCount,
  }) {
    final index = state.history.indexWhere((round) => round.id == roundId);
    if (index < 0 ||
        teamId != null && !state.teams.any((team) => team.id == teamId)) {
      return false;
    }
    final record = state.history[index];
    if (record.answerTeamId != null &&
        teamId != null &&
        teamId != record.answerTeamId) {
      return false;
    }
    if (!canCorrect(record) ||
        record.awardedTeamId == teamId ||
        expectedCorrectionCount != null &&
            record.correctionCount != expectedCorrectionCount) {
      return false;
    }
    final newDeltas = {
      for (final team in state.teams)
        team.id: team.id == teamId ? record.awardedPoints : 0,
    };
    final teams = state.teams.map(
      (team) => team.copyWith(
        score:
            team.score -
            (record.scoreDeltas[team.id] ?? 0) +
            newDeltas[team.id]!,
      ),
    );
    final history = [...state.history];
    history[index] = record.corrected(teamId, newDeltas);
    _set(
      state.copyWith(
        teams: teams,
        history: history,
        corrections: [
          ...state.corrections,
          JudgmentChange(
            roundId: roundId,
            previousTeamId: record.awardedTeamId,
            nextTeamId: teamId,
            at: _now(),
            reopened: false,
          ),
        ],
      ),
    );
    return true;
  }

  bool get canUndoLastDecision =>
      !state.endedEarly &&
      state.history.isNotEmpty &&
      (state.phase == SessionPhase.categories ||
          state.phase == SessionPhase.results) &&
      canCorrect(state.history.last);
  bool undoLastDecision() {
    if (!canUndoLastDecision) return false;
    _timer?.cancel();
    final record = state.history.last;
    final teams = state.teams.map(
      (team) =>
          team.copyWith(score: team.score - (record.scoreDeltas[team.id] ?? 0)),
    );
    _set(
      state.copyWith(
        phase: SessionPhase.answer,
        teams: teams,
        history: state.history.take(state.history.length - 1),
        question: record.question,
        turn: record.turn,
        revealedCards: 3,
        secondsRemaining: record.secondsAtAnswer,
        pauseReason: PauseReason.manual,
        isAbilityRound: false,
        roundData: {
          'identityCluesRevealed': record.identityCluesRevealed,
          if (record.answerTeamId != null)
            'opponentTeamId': record.answerTeamId,
        },
        corrections: [
          ...state.corrections,
          JudgmentChange(
            roundId: record.id,
            previousTeamId: record.awardedTeamId,
            nextTeamId: null,
            at: _now(),
            reopened: true,
          ),
        ],
      ),
    );
    return true;
  }

  void endSession() {
    if (revealing) return;
    if (state.phase == SessionPhase.results) return;
    _timer?.cancel();
    _set(
      state.copyWith(
        phase: SessionPhase.results,
        endedEarly: true,
        pauseReason: PauseReason.none,
        clearQuestion: true,
        revealedCards: 0,
        isAbilityRound: false,
        roundData: {},
      ),
    );
  }

  AbilityWindow get abilityWindow => switch (state.phase) {
    SessionPhase.categories => AbilityWindow.categorySelection,
    SessionPhase.cards when state.revealedCards < 3 =>
      AbilityWindow.beforeQuestion,
    SessionPhase.cards => AbilityWindow.duringQuestion,
    SessionPhase.answer => AbilityWindow.beforeScoring,
    SessionPhase.results => AbilityWindow.betweenTurns,
  };
  void useAbility({
    required String ownerTeamId,
    required String cardId,
    String? targetTeamId,
  }) {
    if (revealing || state.phase == SessionPhase.results || state.isPaused) {
      throw StateError('Abilities are unavailable while paused or finished.');
    }
    final result = AbilityService(abilities).use(
      teams: state.teams,
      ownerTeamId: ownerTeamId,
      cardId: cardId,
      window: abilityWindow,
      targetTeamId: targetTeamId,
      question: state.question,
      roundData: state.roundData,
    );
    _set(
      state.copyWith(
        teams: result.teams,
        roundData: result.roundData,
        abilityRevision: state.abilityRevision + 1,
      ),
    );
  }

  bool restart() {
    if (revealing) return false;
    final List<Question> fresh;
    try {
      fresh = planMatchQuestions(
        questions: _questions.forCategories(config.categoryIds),
        categoryIds: config.categoryIds,
        usage: _usage,
        includeAbilities: abilitiesEnabled,
      );
    } on InsufficientQuestions {
      return false;
    }
    _timer?.cancel();
    _pool = fresh;
    _set(
      SessionState(
        phase: SessionPhase.categories,
        teams: config.teams.map(
          (team) => TeamState(id: team.id, name: team.name),
        ),
        seenQuestionIds: const {},
      ),
    );
    return true;
  }

  void _set(SessionState state) {
    if (_disposed) return;
    _state = state;
    _revision++;
    _updatedAt = _now();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
