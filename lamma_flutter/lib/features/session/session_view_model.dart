import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/repositories/question_repository.dart';
import '../../domain/abilities/ability_system.dart';
import '../../domain/abilities/team_ability_catalog.dart';
import '../../domain/abilities/risk_engine.dart';
import '../../domain/models/question.dart';
import '../../domain/models/question_presentation.dart';
import '../../domain/models/question_usage.dart';
import '../../domain/models/session_config.dart';
import '../../domain/models/session_save.dart';
import '../../domain/models/session_state.dart';
import '../../domain/models/team.dart';
import '../../domain/models/host_score_adjustment.dart';
import '../../domain/models/hint_access.dart';
import '../../domain/abilities/surprise_scoring.dart';
import '../../domain/abilities/surprise_catalog.dart';
import '../../domain/abilities/surprise_session_effects.dart';
import '../../domain/models/wheel_outcome.dart';
import '../../core/online_sync_service.dart';
export '../../domain/models/session_state.dart';
export '../../domain/models/wheel_outcome.dart';

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
    this.openingCardsEnabled = false,
    this.randomizeQuestionSeconds = false,
    this.questionSecondsResolver,
    Iterable<String> replayQuestionIds = const [],
    Iterable<String> blockedQuestionIds = const [],
  }) : _questions = questions,
       _now = now ?? DateTime.now {
    _usage = usage ?? QuestionUsage();
    _blockedQuestionIds = Set.unmodifiable(blockedQuestionIds);
    _replayQuestionIds = Set.unmodifiable(
      restored?.replayQuestionIds ?? replayQuestionIds,
    );
    _random = random ?? Random();
    this.abilities = abilities ?? TeamAbilityCatalog.registry(_random);
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
    _abilityQuestionIds = Set.unmodifiable(
      restored?.abilityQuestionIds ??
          (config.abilitiesEnabled
              ? _pool
                    .skip(
                      GameRules.selectedCategoryCount *
                          GameRules.questionsPerCategory,
                    )
                    .map((q) => q.id)
              : const <String>[]),
    );
    for (final q in _pool.where((q) => state.seenQuestionIds.contains(q.id))) {
      if (usage == null) _usage.mark(q);
    }
    if (restored != null &&
        state.question != null &&
        (state.question!.categoryId == 'character_voice' &&
                !state.question!.hasApprovedVoice ||
            state.revealedCards < 3 &&
                (_blockedQuestionIds.contains(state.question!.id) ||
                    _usage.claimedInSession(id, state.question!) ||
                    _usage.contains(state.question!) &&
                        !_replayQuestionIds.contains(state.question!.id)))) {
      // Do not resume an unsafe voice snapshot, even if its cards were already
      // opened. Preserve scores/use history and return to category selection.
      // Other backups may precede an already committed reveal.
      _state = state.copyWith(
        phase: SessionPhase.categories,
        seenQuestionIds: {...state.seenQuestionIds, state.question!.id},
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
    if (restored != null &&
        state.revealedCards >= 1 &&
        state.phase == SessionPhase.cards) {
      _applyOpeningSurprise();
    }
    if (config.abilitiesEnabled &&
        state.phase == SessionPhase.categories &&
        config.categoryIds.every(
          (category) => remainingForCategory(category) == 0,
        )) {
      final eligible = state.teams
          .where((team) => abilityChoicesLeft(team.id) > 0)
          .toList();
      if (eligible.isEmpty ||
          remainingForCategory(GameRules.abilitiesCategoryId) == 0) {
        _state = state.copyWith(
          phase: SessionPhase.results,
          pauseReason: PauseReason.none,
        );
      } else if (abilityChoicesLeft(state.activeTeam.id) == 0) {
        final index = state.teams.indexWhere(
          (team) => team.id == state.activeTeam.id,
        );
        final next = [
          for (var step = 1; step <= state.teams.length; step++)
            state.teams[(index + step) % state.teams.length],
        ].firstWhere((team) => abilityChoicesLeft(team.id) > 0);
        _state = state.copyWith(selectionTeamId: next.id);
      }
    }
    if (restored != null && state.roundData['googlePendingCard'] != null) {
      _state = state.copyWith(
        roundData: {...state.roundData}..remove('googlePendingCard'),
      );
    }
    if (restored != null && searchClockRunning) {
      _state = state.copyWith(pauseReason: PauseReason.none);
      syncSearchClock();
      _state = state.copyWith(
        pauseReason: PauseReason.restored,
        roundData: {
          ...state.roundData,
          'searchPausedAt': _now().toUtc().toIso8601String(),
        },
      );
      _timer?.cancel();
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
    bool openingCardsEnabled = false,
    bool randomizeQuestionSeconds = false,
    int Function(Question, Random)? questionSecondsResolver,
    Iterable<String> blockedQuestionIds = const [],
  }) => SessionViewModel(
    config: save.config,
    questions: LocalQuestionRepository(questions: save.questions),
    restored: save,
    abilities: abilities,
    riskResolver: riskResolver,
    usage: usage,
    commitReveal: commitReveal,
    surpriseResolver: surpriseResolver,
    openingCardsEnabled: openingCardsEnabled,
    randomizeQuestionSeconds: randomizeQuestionSeconds,
    questionSecondsResolver: questionSecondsResolver,
    blockedQuestionIds: blockedQuestionIds,
  );
  static int _nextId = 0;
  late String id;
  late DateTime createdAt;
  late DateTime _updatedAt;
  late int _revision;
  final DateTime Function() _now;
  final SessionConfig config;
  final QuestionRepository _questions;
  late List<Question> _pool;
  late Set<String> _abilityQuestionIds;
  late Set<String> _replayQuestionIds;
  late final Set<String> _blockedQuestionIds;
  late final QuestionUsage _usage;
  late final Random _random;
  final Future<void> Function(SessionSave, Question)? commitReveal;
  final SurpriseCard? Function(Question, TeamState, int)? surpriseResolver;
  final bool openingCardsEnabled;
  final bool randomizeQuestionSeconds;
  final int Function(Question, Random)? questionSecondsResolver;
  bool revealing = false;
  String? revealError;
  List<Question> _sectionQuestions(String id) {
    if (config.abilitiesEnabled) {
      return _pool
          .where(
            (q) => id == GameRules.abilitiesCategoryId
                ? _abilityQuestionIds.contains(q.id)
                : q.categoryId == id && !_abilityQuestionIds.contains(q.id),
          )
          .take(
            id == GameRules.abilitiesCategoryId
                ? GameRules.abilityQuestions
                : GameRules.questionsPerCategory,
          )
          .toList();
    }
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
      !_blockedQuestionIds.contains(q.id) &&
      !q.isQuarantined &&
      (!_usage.contains(q) || _replayQuestionIds.contains(q.id)) &&
      !state.seenQuestionIds.contains(q.id) &&
      !_usage.claimedInSession(id, q);
  late final AbilityRegistry abilities;
  final RiskRoundResolver? riskResolver;
  late SessionState _state;
  SessionState get state => _state;
  Timer? _timer;
  DateTime? _clockDeadline;
  bool _foreground = true, _disposed = false;
  bool get abilitiesEnabled =>
      config.abilitiesEnabled ||
      riskResolver != null && abilities.definitions.keys.any(abilities.isReady);
  int abilityChoicesLeft(String teamId) => max(
    0,
    config.abilityChoicesPerTeam - (state.abilitySelections[teamId] ?? 0),
  );
  bool get opponentsBlocked =>
      state.surpriseCard?.effect == SurpriseEffect.noOpponent ||
      state.roundData['blockOpponentTeamId'] == state.activeTeam.id &&
          state.roundData['blockOpponentQuestionId'] == state.question?.id;
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
    replayQuestionIds: _replayQuestionIds,
    abilityQuestionIds: _abilityQuestionIds,
  );

  bool selectCategory(String id) {
    if (state.phase != SessionPhase.categories || state.isPaused) return false;
    final abilityRound = id == GameRules.abilitiesCategoryId;
    if (abilityRound &&
            (!abilitiesEnabled ||
                config.abilitiesEnabled &&
                    abilityChoicesLeft(state.activeTeam.id) == 0) ||
        forcedCategoryId != null && id != forcedCategoryId ||
        !abilityRound && !config.categoryIds.contains(id)) {
      return false;
    }
    final candidates = _sectionQuestions(id).where(_available).toList();
    if (candidates.isEmpty) return false;
    final surprise = abilityRound
        ? null
        : surpriseResolver != null
        ? surpriseResolver!.call(candidates.first, state.activeTeam, state.turn)
        : openingCardsEnabled
        ? SurpriseCatalog.draw(
            candidates.first,
            SurpriseCatalog.equalWeights,
            _random,
            isAllowed: (card) => _openingCardAllowed(card, candidates.first),
          )
        : null;
    final initialSeconds = questionSecondsResolver != null
        ? questionSecondsResolver!(candidates.first, _random)
        : randomizeQuestionSeconds
        ? GameRules.secondsForCategory(candidates.first.categoryId, _random)
        : GameRules.secondsForCategory(candidates.first.categoryId);
    _set(
      state.copyWith(
        phase: SessionPhase.cards,
        question: candidates.first,
        revealedCards: 0,
        secondsRemaining: initialSeconds,
        isAbilityRound: abilityRound,
        abilitySelections: {
          ...state.abilitySelections,
          if (abilityRound && config.abilitiesEnabled)
            state.activeTeam.id:
                (state.abilitySelections[state.activeTeam.id] ?? 0) + 1,
        },
        roundData: {
          'baseQuestionSeconds': initialSeconds,
          'initialQuestionSeconds': initialSeconds,
          if (surprise != null) 'surpriseCard': surprise.toJson(),
        },
      ),
    );
    return true;
  }

  bool revealCard(int index) {
    if (index > 0 &&
        state.surpriseCard?.effect == SurpriseEffect.plank &&
        state.roundData['plankDecision'] == 'pending') {
      return false;
    }
    if (index > 0 &&
        state.surpriseCard?.effect == SurpriseEffect.wheelOfFortune &&
        state.roundData['wheelStatus'] == 'pending') {
      return false;
    }
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
      if (_usage.claimedInSession(id, state.question!) ||
          _usage.contains(state.question!) &&
              !_replayQuestionIds.contains(state.question!.id)) {
        return false;
      }
      _usage.mark(state.question!);
      if (_replayQuestionIds.contains(state.question!.id)) {
        _usage.claim(id, state.question!);
      }
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
    if (index == 0) _applyOpeningSurprise();
    if (index == 2) {
      _set(_preparePlankQuestion(state));
      _startTimer();
    }
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
    final proposed = _preparePlankQuestion(
      state.copyWith(
        revealedCards: 3,
        seenQuestionIds: {...state.seenQuestionIds, question.id},
      ),
    );
    revealing = true;
    revealError = null;
    notifyListeners();
    try {
      final checkpoint = SessionSave(
        id: id,
        config: config,
        state: proposed,
        questions: _pool,
        createdAt: createdAt,
        updatedAt: _now(),
        revision: _revision + 1,
        replayQuestionIds: _replayQuestionIds,
        abilityQuestionIds: _abilityQuestionIds,
      );
      await commitReveal!(checkpoint, question);
      _usage.mark(question);
      if (_replayQuestionIds.contains(question.id)) _usage.claim(id, question);
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
      state.roundData['googlePendingCard'] == null &&
      !revealing &&
      state.phase == SessionPhase.cards &&
      state.revealedCards == 3 &&
      (state.surpriseCard?.effect != SurpriseEffect.silence ||
          state.secondsRemaining == 0 ||
          (state.roundData['firstAnswers'] as Map? ?? const {}).containsKey(
            state.answeringTeam.id,
          )) &&
      (!state.isOpponentWindow || state.secondsRemaining == 0);

  bool startOpponentOpportunity() {
    if (opponentsBlocked) return false;
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
          if (searchClockRunning) 'searchClockMode': 'countdown',
          if (searchClockRunning)
            'searchWindowDeadline': _opponentSearchDeadline()
                .toUtc()
                .toIso8601String(),
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
    if ((!_foreground && !searchClockRunning) || state.isPaused) return;
    if (searchClockRunning) {
      syncSearchClock();
      _timer?.cancel();
      if (state.secondsRemaining > 0 || state.plankRunning) {
        _timer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => syncSearchClock(),
        );
      }
      return;
    }
    if (state.surpriseCard?.effect == SurpriseEffect.silence &&
        (state.roundData['firstAnswers'] as Map? ?? const {}).containsKey(
          state.answeringTeam.id,
        )) {
      return;
    }
    if (state.plankRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_disposed || state.isPaused || !state.plankRunning) {
          timer.cancel();
          return;
        }
        _set(
          state.copyWith(
            roundData: {
              ...state.roundData,
              'plankElapsedSeconds': state.plankSeconds + 1,
            },
          ),
        );
      });
      return;
    }
    if (state.secondsRemaining <= 0) {
      if (!state.isOpponentWindow &&
          state.phase == SessionPhase.cards &&
          state.revealedCards == 3) {
        startOpponentOpportunity();
      }
      return;
    }
    _clockDeadline = _now().add(Duration(seconds: state.secondsRemaining));
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
        _set(state.copyWith(secondsRemaining: 0));
        startOpponentOpportunity();
        return;
      }
      _set(
        state.copyWith(
          secondsRemaining: state.secondsRemaining - 1,
          roundData: {
            ...state.roundData,
            'questionElapsedSeconds':
                (state.roundData['questionElapsedSeconds'] as int? ?? 0) + 1,
          },
        ),
      );
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
    _set(
      state.copyWith(
        pauseReason: reason,
        roundData: {
          ...state.roundData,
          if (searchClockRunning)
            'searchPausedAt': _now().toUtc().toIso8601String(),
        },
      ),
    );
  }

  bool resume() {
    if (_disposed ||
        !_foreground ||
        !canResume ||
        !state.isPaused ||
        state.phase == SessionPhase.results) {
      return false;
    }
    final data = {...state.roundData};
    if (searchClockRunning && data['searchPausedAt'] is String) {
      final at = data['searchPausedAt'] as String;
      final shift = _now().difference(DateTime.parse(at));
      for (final key in [
        'searchWindowDeadline',
        'googleEndsAt',
        'searchPlankStartedAt',
      ]) {
        if (data[key] case String value) {
          data[key] = DateTime.parse(
            value,
          ).add(shift).toUtc().toIso8601String();
        }
      }
      data.remove('searchPausedAt');
    }
    _set(state.copyWith(pauseReason: PauseReason.none, roundData: data));
    if (state.phase == SessionPhase.cards && state.revealedCards == 3) {
      _startTimer();
    }
    return true;
  }

  void setForeground(bool foreground) {
    _foreground = foreground;
    if (searchClockRunning) {
      syncSearchClock();
      if (!state.isPaused) _startTimer();
      return;
    }
    if (!foreground) pause(PauseReason.background);
  }

  bool showAnswer() {
    if (!canShowAnswer) {
      return false;
    }
    _timer?.cancel();
    _set(
      state.copyWith(
        phase: SessionPhase.answer,
        roundData: {
          ...state.roundData,
          if (state.plankRunning) 'plankRunning': false,
        },
      ),
    );
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

  void _applyOpeningSurprise() {
    final card = state.surpriseCard;
    if (card == null ||
        state.roundData['surpriseApplied'] == true ||
        state.isAbilityRound) {
      return;
    }
    final data = <String, Object?>{
      ...state.roundData,
      'surpriseApplied': true,
      'roundStartingScores': {
        for (final team in state.teams) team.id: team.score,
      },
    };
    var seconds = state.secondsRemaining;
    var teams = state.teams;
    if (card.effect == SurpriseEffect.extraTime) seconds += card.amount;
    if (card.effect == SurpriseEffect.halfTime) seconds = max(1, seconds ~/ 2);
    if (card.effect == SurpriseEffect.bonusPoints) {
      teams = teams
          .map(
            (team) => team.id == state.activeTeam.id
                ? team.copyWith(score: team.score + card.amount)
                : team,
          )
          .toList();
      data['surpriseFixedDeltas'] = {state.activeTeam.id: card.amount};
    }
    data['initialQuestionSeconds'] = seconds;
    if (card.effect == SurpriseEffect.plank) data['plankDecision'] = 'pending';
    if (card.effect == SurpriseEffect.wheelOfFortune) {
      data['wheelStatus'] = 'pending';
    }
    _set(
      state.copyWith(
        teams: teams,
        secondsRemaining: seconds,
        roundData: data,
        abilityRevision:
            state.abilityRevision +
            (card.effect == SurpriseEffect.bonusPoints ? 1 : 0),
      ),
    );
  }

  bool get canActivateSurprise {
    final card = state.surpriseCard;
    if (card == null ||
        state.roundData['surpriseApplied'] != true ||
        state.roundData['surpriseActionUsed'] == true ||
        !{SurpriseEffect.hint, SurpriseEffect.options}.contains(card.effect) ||
        state.isPaused ||
        revealing ||
        state.phase != SessionPhase.cards ||
        state.revealedCards != 3 ||
        state.isOpponentWindow ||
        state.secondsRemaining <= 0) {
      return false;
    }
    if (card.maximumQuestionPoints != null &&
        state.question!.points > card.maximumQuestionPoints!) {
      return false;
    }
    if (card.effect == SurpriseEffect.options &&
        state.visibleOptions.length == 6) {
      return false;
    }
    return card.price == 0 || state.activeTeam.score >= card.price;
  }

  bool activateSurprise() {
    if (!canActivateSurprise) return false;
    final card = state.surpriseCard!, question = state.question!;
    final data = <String, Object?>{
      ...state.roundData,
      'surpriseActionUsed': true,
    };
    final fixed = SurpriseScoring.fixedDeltas(data);
    fixed[state.activeTeam.id] = (fixed[state.activeTeam.id] ?? 0) - card.price;
    data['surpriseFixedDeltas'] = fixed;
    final teams = state.teams.map(
      (team) => team.id == state.activeTeam.id
          ? team.copyWith(score: team.score - card.price)
          : team,
    );
    if (card.effect == SurpriseEffect.hint) {
      if (question.isIdentity || question.hint.isEmpty) return false;
      data['hintAccess'] = HintAccess(
        questionId: question.id,
        teamId: state.activeTeam.id,
        source: HintSource.surprise,
        cardId: card.id,
      ).toJson();
      data['hintRevealed'] = true;
    } else {
      if (question.options.length != 6) return false;
      final choices = [...question.options]..shuffle(_random);
      var selected = choices.take(card.optionCount).toList();
      if (card.optionCount == 4 && card.includeCorrect) {
        final correct = question.options.singleWhere(
          (option) => option.id == question.correctOptionId,
        );
        selected = [
          correct,
          ...choices.where((option) => option.id != correct.id).take(3),
        ]..shuffle(_random);
      }
      data.addAll({
        'optionsQuestionId': question.id,
        'optionsTeamId': state.activeTeam.id,
        'visibleOptionIds': selected.map((option) => option.id).toList(),
      });
    }
    _set(
      state.copyWith(
        teams: teams,
        roundData: data,
        abilityRevision: state.abilityRevision + (card.price > 0 ? 1 : 0),
      ),
    );
    return true;
  }

  int nextTurnFor(String teamId) {
    final index = state.teams.indexWhere((team) => team.id == teamId);
    if (index < 0) throw ArgumentError('Unknown team.');
    var offset =
        (index - state.turn % state.teams.length + state.teams.length) %
        state.teams.length;
    if (offset == 0) offset = state.teams.length;
    return state.turn + offset;
  }

  int get wagerBalance => max(
    0,
    state.activeTeam.score -
        SurpriseSessionEffects.reserved(
          state.sessionEffects,
          state.activeTeam.id,
        ),
  );
  String? get forcedCategoryId {
    final assignments =
        SurpriseSessionEffects.entries(state.sessionEffects, 'categories')
            .where(
              (entry) =>
                  entry['target'] == state.activeTeam.id &&
                  entry['dueTurn'] == state.turn,
            )
            .toList();
    if (assignments.isEmpty) return null;
    final category = assignments.last['category'] as String;
    return remainingForCategory(category) > 0 ? category : null;
  }

  bool get isAnswererCard => {
    SurpriseEffect.designatedPlayer,
    SurpriseEffect.selfDesignates,
    SurpriseEffect.opponentDesignates,
  }.contains(state.surpriseCard?.effect);
  bool get requiresAnswerer => false;
  bool get canPrepareSurprise =>
      !revealing &&
      !state.isPaused &&
      state.phase == SessionPhase.cards &&
      state.revealedCards >= 1 &&
      state.revealedCards < 3 &&
      state.roundData['surpriseActionUsed'] != true;
  bool _validOpponent(String id) => state.teams.any(
    (team) => team.id == id && team.id != state.activeTeam.id,
  );
  bool _hasFutureTurn(String target) {
    final available = remainingQuestions
        .where((q) => q.id != state.question?.id)
        .length;
    return nextTurnFor(target) - state.turn <= available;
  }

  bool _openingCardAllowed(SurpriseCard card, Question question) {
    final available = remainingQuestions
        .where((q) => q.id != question.id)
        .length;
    bool future(String target) => nextTurnFor(target) - state.turn <= available;
    final opponentFuture = state.teams.any(
      (team) => team.id != state.activeTeam.id && future(team.id),
    );
    return switch (card.effect) {
      SurpriseEffect.selfWager =>
        wagerBalance > 0 && future(state.activeTeam.id),
      SurpriseEffect.opponentWager => wagerBalance > 0 && opponentFuture,
      SurpriseEffect.chooseOpponentCategory ||
      SurpriseEffect.banPlayer => opponentFuture,
      SurpriseEffect.changeQuestion => available > 0,
      _ => true,
    };
  }

  bool commitWager(int amount, {String? targetTeamId}) {
    final effect = state.surpriseCard?.effect;
    if (!canPrepareSurprise ||
        !{
          SurpriseEffect.selfWager,
          SurpriseEffect.opponentWager,
        }.contains(effect) ||
        amount <= 0 ||
        amount > wagerBalance) {
      return false;
    }
    final target = effect == SurpriseEffect.selfWager
        ? state.activeTeam.id
        : targetTeamId;
    if (target == null ||
        effect == SurpriseEffect.opponentWager && !_validOpponent(target) ||
        !_hasFutureTurn(target)) {
      return false;
    }
    final entry = <String, Object?>{
      'id': '$id-wager-${state.turn}',
      'owner': state.activeTeam.id,
      'target': target,
      'amount': amount,
      'dueTurn': nextTurnFor(target),
      'onCorrect': effect == SurpriseEffect.selfWager,
    };
    _set(
      state.copyWith(
        sessionEffects: SurpriseSessionEffects.append(
          state.sessionEffects,
          'wagers',
          entry,
        ),
        abilityRevision: state.abilityRevision + 1,
        roundData: {
          ...state.roundData,
          'surpriseActionUsed': true,
          'registeredWager': entry,
        },
      ),
    );
    return true;
  }

  bool chooseAnswerer(String name, {String? choosingTeamId}) {
    name = name.trim();
    if (!canPrepareSurprise ||
        !isAnswererCard ||
        name.isEmpty ||
        name.length > 80 ||
        SurpriseSessionEffects.banned(
          state.sessionEffects,
          state.activeTeam.id,
          name,
          state.turn,
        ) ||
        state.surpriseCard?.effect == SurpriseEffect.opponentDesignates &&
            (choosingTeamId == null || !_validOpponent(choosingTeamId))) {
      return false;
    }
    _set(
      state.copyWith(
        roundData: {
          ...state.roundData,
          'designatedPlayer': name,
          'surpriseActionUsed': true,
          'answererChosenBy': ?choosingTeamId,
        },
      ),
    );
    return true;
  }

  bool assignOpponentCategory(String target, String category) {
    if (!canPrepareSurprise ||
        state.surpriseCard?.effect != SurpriseEffect.chooseOpponentCategory ||
        !_validOpponent(target) ||
        !config.categoryIds.contains(category) ||
        remainingForCategory(category) == 0 ||
        !_hasFutureTurn(target)) {
      return false;
    }
    final assignments =
        SurpriseSessionEffects.entries(state.sessionEffects, 'categories')
          ..removeWhere(
            (entry) =>
                entry['target'] == target &&
                entry['dueTurn'] == nextTurnFor(target),
          );
    final entry = <String, Object?>{
      'id': '$id-category-${state.turn}',
      'owner': state.activeTeam.id,
      'target': target,
      'category': category,
      'dueTurn': nextTurnFor(target),
    };
    _set(
      state.copyWith(
        sessionEffects: {
          ...state.sessionEffects,
          'categories': [...assignments, entry],
        },
        abilityRevision: state.abilityRevision + 1,
        roundData: {
          ...state.roundData,
          'surpriseActionUsed': true,
          'assignedCategory': entry,
        },
      ),
    );
    return true;
  }

  bool banOpponentPlayer(String target, String name) {
    name = name.trim();
    if (!canPrepareSurprise ||
        state.surpriseCard?.effect != SurpriseEffect.banPlayer ||
        !_validOpponent(target) ||
        name.isEmpty ||
        name.length > 80 ||
        !_hasFutureTurn(target)) {
      return false;
    }
    final entry = <String, Object?>{
      'id': '$id-ban-${state.turn}',
      'owner': state.activeTeam.id,
      'target': target,
      'player': name,
      'startsTurn': state.turn + 1,
      'expiresTurn': nextTurnFor(target) + state.teams.length,
    };
    _set(
      state.copyWith(
        sessionEffects: SurpriseSessionEffects.append(
          state.sessionEffects,
          'bans',
          entry,
        ),
        abilityRevision: state.abilityRevision + 1,
        roundData: {
          ...state.roundData,
          'surpriseActionUsed': true,
          'registeredBan': entry,
        },
      ),
    );
    return true;
  }

  bool recordFirstAnswer(String answer) {
    answer = answer.trim();
    if (state.surpriseCard?.effect != SurpriseEffect.silence ||
        state.isPaused ||
        revealing ||
        state.phase != SessionPhase.cards ||
        state.revealedCards != 3 ||
        state.secondsRemaining <= 0 ||
        answer.isEmpty ||
        answer.length > 200) {
      return false;
    }
    final answers = Map<String, Object?>.from(
      state.roundData['firstAnswers'] as Map? ?? const {},
    );
    if (answers.containsKey(state.answeringTeam.id)) return false;
    answers[state.answeringTeam.id] = answer;
    final seconds = Map<String, Object?>.from(
      state.roundData['firstAnswerSeconds'] as Map? ?? const {},
    );
    seconds[state.answeringTeam.id] = state.secondsRemaining;
    _timer?.cancel();
    _set(
      state.copyWith(
        secondsRemaining: 0,
        roundData: {
          ...state.roundData,
          'firstAnswers': answers,
          'searchClockActive': false,
          'firstAnswerSeconds': seconds,
        },
      ),
    );
    return true;
  }

  bool get canChangeQuestion =>
      !state.isPaused &&
      !revealing &&
      state.phase == SessionPhase.cards &&
      state.revealedCards == 3 &&
      !state.isOpponentWindow &&
      state.surpriseCard?.effect == SurpriseEffect.changeQuestion &&
      state.roundData['surpriseActionUsed'] != true &&
      (state.roundData['questionElapsedSeconds'] as int? ?? 0) < 10 &&
      remainingQuestions.isNotEmpty;
  Future<bool> changeQuestion() async {
    if (!canChangeQuestion) return false;
    var data = <String, Object?>{...state.roundData};
    Question? replacement;
    final pendingId = data['replacementQuestionId'];
    if (pendingId is String) {
      for (final candidate in remainingQuestions) {
        if (candidate.id == pendingId) replacement = candidate;
      }
    }
    if (replacement == null) {
      final sections = config.categoryIds
          .where((category) => remainingForCategory(category) > 0)
          .toList();
      if (sections.isEmpty) return false;
      final category = sections[_random.nextInt(sections.length)];
      final candidates = _sectionQuestions(category).where(_available).toList();
      replacement = candidates[_random.nextInt(candidates.length)];
      data['replacementQuestionId'] = replacement.id;
      _set(state.copyWith(roundData: data));
    }
    final proposed = state.copyWith(
      question: replacement,
      seenQuestionIds: {...state.seenQuestionIds, replacement.id},
      roundData: {
        ...data,
        'surpriseActionUsed': true,
        'identityCluesRevealed': 1,
        'questionElapsedSeconds': 0,
        'questionDrafts': <String, Object?>{},
      },
    );
    revealing = true;
    revealError = null;
    notifyListeners();
    _timer?.cancel();
    try {
      if (commitReveal != null) {
        await commitReveal!(
          SessionSave(
            id: id,
            config: config,
            state: proposed,
            questions: _pool,
            createdAt: createdAt,
            updatedAt: _now(),
            revision: _revision + 1,
            replayQuestionIds: _replayQuestionIds,
            abilityQuestionIds: _abilityQuestionIds,
          ),
          replacement,
        );
      }
      if (_disposed) return false;
      _usage.mark(replacement);
      if (_replayQuestionIds.contains(replacement.id)) {
        _usage.claim(id, replacement);
      }
      _set(proposed.copyWith(pauseReason: state.pauseReason));
      _startTimer();
      return true;
    } on Object {
      if (!_disposed) {
        revealError =
            'تعذّر حفظ تغيير السؤال. بقي السؤال الحالي؛ أعد المحاولة.';
      }
      return false;
    } finally {
      revealing = false;
      if (!_disposed) {
        _startTimer();
        notifyListeners();
      }
    }
  }

  SessionState _preparePlankQuestion(SessionState proposed) =>
      proposed.plankAccepted
      ? proposed.copyWith(
          secondsRemaining: 1,
          roundData: {
            ...proposed.roundData,
            'plankRunning': true,
            'plankElapsedSeconds': 0,
          },
        )
      : proposed;

  bool get canChoosePlank =>
      !state.isPaused &&
      !revealing &&
      state.phase == SessionPhase.cards &&
      state.revealedCards >= 1 &&
      state.revealedCards < 3 &&
      state.surpriseCard?.effect == SurpriseEffect.plank &&
      state.roundData['plankDecision'] == 'pending';
  bool acceptPlank() {
    if (!canChoosePlank) return false;
    _set(
      state.copyWith(
        roundData: {
          ...state.roundData,
          'plankDecision': 'accepted',
          'plankElapsedSeconds': 0,
        },
      ),
    );
    return true;
  }

  bool refusePlank() {
    if (!canChoosePlank) return false;
    final amount = state.surpriseCard!.price;
    final fixed = SurpriseScoring.fixedDeltas(state.roundData);
    fixed[state.activeTeam.id] = (fixed[state.activeTeam.id] ?? 0) - amount;
    final baseSeconds =
        (state.roundData['baseQuestionSeconds'] as int?) ??
        GameRules.secondsForCategory(state.question?.categoryId);
    _set(
      state.copyWith(
        teams: state.teams.map(
          (team) => team.id == state.activeTeam.id
              ? team.copyWith(score: team.score - amount)
              : team,
        ),
        secondsRemaining: baseSeconds,
        abilityRevision: state.abilityRevision + 1,
        roundData: {
          ...state.roundData,
          'plankDecision': 'refused',
          'surpriseFixedDeltas': fixed,
          'initialQuestionSeconds': baseSeconds,
        },
      ),
    );
    return true;
  }

  bool finishPlank() {
    if (state.isPaused || revealing || !state.plankRunning) return false;
    _timer?.cancel();
    _set(
      state.copyWith(
        secondsRemaining: 0,
        roundData: {
          ...state.roundData,
          'plankRunning': false,
          'plankFinished': true,
        },
      ),
    );
    return startOpponentOpportunity();
  }

  bool get canSpinWheel =>
      !state.isPaused &&
      !revealing &&
      state.phase == SessionPhase.cards &&
      state.revealedCards >= 1 &&
      state.surpriseCard?.effect == SurpriseEffect.wheelOfFortune &&
      state.roundData['wheelStatus'] == 'pending';

  bool get canSkipWheel => canSpinWheel;

  String? get wheelStatus => state.roundData['wheelStatus'] as String?;

  WheelOutcome? get wheelOutcome {
    final name = state.roundData['wheelOutcome'] as String?;
    return name == null ? null : WheelOutcome.values.byName(name);
  }

  bool skipWheel() {
    if (!canSkipWheel) return false;
    _set(
      state.copyWith(
        roundData: {
          ...state.roundData,
          'wheelStatus': 'skipped',
          'surpriseActionUsed': true,
        },
        abilityRevision: state.abilityRevision + 1,
      ),
    );
    return true;
  }

  bool applyWheelOutcome(WheelOutcome outcome) {
    if (!canSpinWheel) return false;

    final activeId = state.activeTeam.id;
    var teams = state.teams;
    final currentScore = state.activeTeam.score;
    final delta = outcome.pointsDelta;
    String? passOpponentId;

    if (outcome == WheelOutcome.passTurn) {
      final opponents = state.teams.where((t) => t.id != activeId).toList();
      if (opponents.isNotEmpty) {
        final lowest = opponents.map((t) => t.score).reduce(min);
        final eligible = opponents.where((t) => t.score == lowest).toList();
        final chosen = eligible.length == 1
            ? eligible.single
            : eligible[_random.nextInt(eligible.length)];
        passOpponentId = chosen.id;
      }
    } else if (outcome == WheelOutcome.bankruptcy) {
      // Active team loses all points (score becomes 0)
      teams = teams.map((team) {
        return team.id == activeId ? team.copyWith(score: 0) : team;
      }).toList();
    } else if (delta != 0) {
      // +100, +200, +400, +600, or -500
      teams = teams.map((team) {
        return team.id == activeId
            ? team.copyWith(score: team.score + delta)
            : team;
      }).toList();
    }

    final fixed = SurpriseScoring.fixedDeltas(state.roundData);
    final recordedDelta = outcome == WheelOutcome.bankruptcy
        ? -currentScore
        : delta;
    if (recordedDelta != 0) {
      fixed[activeId] = (fixed[activeId] ?? 0) + recordedDelta;
    }

    final updatedRoundData = <String, Object?>{
      ...state.roundData,
      'wheelStatus': 'completed',
      'wheelOutcome': outcome.name,
      'surpriseActionUsed': true,
      'surpriseFixedDeltas': fixed,
      if (passOpponentId != null) ...{
        'wheelTurnPassed': true,
        'opponentTeamId': passOpponentId,
        'opponentReason': 'wheel_pass',
      },
    };

    _set(
      state.copyWith(
        teams: teams,
        roundData: updatedRoundData,
        abilityRevision: state.abilityRevision + 1,
      ),
    );
    return true;
  }

  bool get canEditQuestionDraft =>
      !revealing &&
      !state.isPaused &&
      state.phase == SessionPhase.cards &&
      state.revealedCards == 3 &&
      state.secondsRemaining > 0 &&
      state.question?.presentation != null;

  bool updateQuestionDraft(Map<String, String> draft) {
    if (!canEditQuestionDraft ||
        draft.length > 24 ||
        draft.values.any((v) => v.length > 200)) {
      return false;
    }
    final content = state.question!.presentation!;
    final ids = content.elements.map((item) => item.id).toSet();
    for (final entry in draft.entries) {
      final key = entry.key, value = entry.value;
      if (key.startsWith('missing:')) {
        if (!content.elements.any(
          (item) => item.id == key.substring(8) && item.missing,
        )) {
          return false;
        }
      } else if (key.startsWith('group:')) {
        if (content.type != QuestionPresentationType.grouping ||
            !ids.contains(key.substring(6)) ||
            !{'1', '2'}.contains(value)) {
          return false;
        }
      } else if (key.startsWith('pair:')) {
        if (content.type != QuestionPresentationType.matching ||
            !content.sections.first.items.any(
              (item) => item.id == key.substring(5),
            ) ||
            !content.sections.last.items.any((item) => item.id == value)) {
          return false;
        }
      } else if (key == 'selected') {
        if (!(content.type == QuestionPresentationType.statements ||
                state.question?.subtype == 'number_nearest') ||
            !ids.contains(value)) {
          return false;
        }
      } else if (key == 'first' || key == 'last') {
        if (state.question?.categoryId != 'first_last' ||
            !ids.contains(value)) {
          return false;
        }
      } else if (key == 'order') {
        if (content.type != QuestionPresentationType.comparison) return false;
        try {
          final order = (jsonDecode(value) as List).cast<String>();
          if (order.length != ids.length ||
              order.toSet().length != ids.length ||
              !order.toSet().containsAll(ids)) {
            return false;
          }
        } catch (_) {
          return false;
        }
      } else {
        return false;
      }
    }
    final pairValues = draft.entries
        .where((entry) => entry.key.startsWith('pair:'))
        .map((entry) => entry.value)
        .toList();
    if (pairValues.toSet().length != pairValues.length) return false;
    if (draft['first'] != null && draft['first'] == draft['last']) return false;
    final drafts = Map<String, Object?>.from(
      state.roundData['questionDrafts'] as Map? ?? const {},
    );
    drafts[state.answeringTeam.id] = Map<String, String>.from(draft);
    _set(
      state.copyWith(roundData: {...state.roundData, 'questionDrafts': drafts}),
    );
    return true;
  }

  bool awardAnswer(String? teamId) {
    if (teamId != null && opponentsBlocked && teamId != state.activeTeam.id) {
      return false;
    }
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
    final rewardDefinition = state.isAbilityRound && config.abilitiesEnabled
        ? state.roundData['rewardDefinitionId'] as String? ??
              TeamAbilityCatalog
                  .definitions[_random.nextInt(
                    TeamAbilityCatalog.definitions.length,
                  )]
                  .id
        : null;
    final rewardId = '$id-ability-${state.turn}-${question.id}';
    if (state.isAbilityRound && !config.abilitiesEnabled) {
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
                ? team.copyWith(
                    score:
                        team.score +
                        SurpriseScoring.points(
                          question: question,
                          clues: state.identityCluesRevealed,
                          teamId: team.id,
                          actingTeamId: state.activeTeam.id,
                          roundData: state.roundData,
                        ),
                  )
                : team,
          )
          .toList();
    }
    if (rewardDefinition != null && teamId == state.activeTeam.id) {
      teams = _withReward(
        teams,
        rewardId,
        rewardDefinition,
        teamId,
        state.turn,
      );
    }
    if (!state.isAbilityRound) {
      teams = teams
          .map(
            (team) => team.id == state.activeTeam.id
                ? team.copyWith(
                    score:
                        team.score -
                        SurpriseScoring.failureDebit(
                          roundData: state.roundData,
                          winner: teamId,
                          actingTeamId: state.activeTeam.id,
                          currentScore: team.score,
                          question: question,
                          clues: state.identityCluesRevealed,
                        ),
                  )
                : team,
          )
          .toList();
    }
    final settledWagers = SurpriseSessionEffects.dueWagers(
      state.sessionEffects,
      state.turn,
    ).where((entry) => entry['target'] == state.activeTeam.id).toList();
    final wagerDeltas = SurpriseSessionEffects.wagerDeltas(
      settledWagers,
      teamId,
    );
    teams = teams
        .map(
          (team) =>
              team.copyWith(score: team.score + (wagerDeltas[team.id] ?? 0)),
        )
        .toList();
    final record = RoundRecord(
      id: '$id-round-${state.turn}',
      turn: state.turn,
      question: question,
      actingTeamId: state.activeTeam.id,
      awardedTeamId: teamId,
      scoreDeltas: {
        for (var i = 0; i < teams.length; i++)
          teams[i].id:
              teams[i].score -
              before[i].score +
              (SurpriseScoring.fixedDeltas(state.roundData)[teams[i].id] ?? 0),
      },
      secondsAtAnswer: state.secondsRemaining,
      abilityRevision: state.abilityRevision,
      isAbilityRound: state.isAbilityRound,
      completedAt: _now(),
      identityCluesRevealed: state.identityCluesRevealed,
      answerTeamId: state.opponentTeamId,
      roundData: {
        ...state.roundData,
        'rewardDefinitionId': ?rewardDefinition,
        if (rewardDefinition != null) 'rewardId': rewardId,
        if (settledWagers.isNotEmpty) 'settledWagers': settledWagers,
      },
      effectsBefore: state.sessionEffects,
    );
    final normalDone = config.categoryIds.every(
      (id) => remainingForCategory(id) == 0,
    );
    final abilityDone =
        !abilitiesEnabled ||
        remainingForCategory(GameRules.abilitiesCategoryId) == 0 ||
        config.abilitiesEnabled &&
            state.teams.every((team) => abilityChoicesLeft(team.id) == 0);
    final currentIndex = state.teams.indexWhere(
      (team) => team.id == state.activeTeam.id,
    );
    final nextCandidates = [
      for (var step = 1; step <= state.teams.length; step++)
        state.teams[(currentIndex + step) % state.teams.length],
    ];
    final nextTeam = nextCandidates.firstWhere(
      (team) => !normalDone || abilityDone || abilityChoicesLeft(team.id) > 0,
    );
    _set(
      state.copyWith(
        phase: normalDone && abilityDone
            ? SessionPhase.results
            : SessionPhase.categories,
        selectionTeamId: nextTeam.id,
        teams: teams,
        history: [...state.history, record],
        turn: state.turn + 1,
        clearQuestion: true,
        revealedCards: 0,
        isAbilityRound: false,
        roundData: {},
        sessionEffects: SurpriseSessionEffects.completeTurn(
          state.sessionEffects,
          state.turn,
        ),
      ),
    );
    return true;
  }

  List<TeamState> _withReward(
    Iterable<TeamState> teams,
    String cardId,
    String definitionId,
    String? winner,
    int turn,
  ) => teams
      .map(
        (team) => team.copyWith(
          inventory: [
            ...team.inventory.where((card) => card.id != cardId),
            if (team.id == winner)
              OwnedAbility(
                id: cardId,
                definitionId: definitionId,
                ownerTeamId: team.id,
                acquiredTurn: turn,
                remainingUses: abilities.definitions[definitionId]!.usesPerCard,
              ),
          ],
        ),
      )
      .toList();
  bool adjustTeamScore(String teamId, int delta, {String reason = ''}) {
    if (!state.teams.any((t) => t.id == teamId)) return false;
    final scores = {
      for (final t in state.teams)
        t.id: t.id == teamId ? t.score + delta : t.score,
    };
    return setTeamScores(
      scores,
      expectedScores: {for (final t in state.teams) t.id: t.score},
      reason: reason.isNotEmpty
          ? reason
          : (delta >= 0 ? 'تعديل سريع (+$delta)' : 'تعديل سريع ($delta)'),
    );
  }

  bool setTeamScores(
    Map<String, int> scores, {
    required Map<String, int> expectedScores,
    String reason = '',
  }) {
    if (_disposed ||
        revealing ||
        reason.trim().length > 120 ||
        scores.length != state.teams.length ||
        expectedScores.length != state.teams.length ||
        state.teams.any(
          (team) =>
              !scores.containsKey(team.id) ||
              expectedScores[team.id] != team.score ||
              scores[team.id]!.abs() > 999999999,
        )) {
      return false;
    }
    final changes = [
      for (final team in state.teams)
        if (scores[team.id] != team.score)
          HostScoreAdjustment(
            id: '$id-score-${_revision + 1}-${team.id}',
            teamId: team.id,
            before: team.score,
            after: scores[team.id]!,
            at: _now(),
            reason: reason.trim(),
          ),
    ];
    if (changes.isEmpty) return true;
    final data = Map<String, Object?>.from(state.roundData);
    if (data['roundStartingScores'] case final Map<Object?, Object?> raw) {
      final starting = Map<String, int>.from(raw);
      for (final change in changes) {
        starting[change.teamId] = (starting[change.teamId] ?? 0) + change.delta;
      }
      data['roundStartingScores'] = starting;
    }
    _set(
      state.copyWith(
        teams: state.teams.map((team) => team.copyWith(score: scores[team.id])),
        roundData: data,
        scoreAdjustments: [...state.scoreAdjustments, ...changes],
      ),
    );
    return true;
  }

  bool canCorrect(RoundRecord record) =>
      (!record.isAbilityRound ||
          record.roundData['rewardDefinitionId'] != null) &&
      record.abilityRevision == state.abilityRevision;
  int pointsForTeam(String teamId) => state.question == null
      ? 0
      : SurpriseScoring.points(
          question: state.question!,
          clues: state.identityCluesRevealed,
          teamId: teamId,
          actingTeamId: state.activeTeam.id,
          roundData: state.roundData,
        );
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
    if (teamId != null &&
        record.roundData['blockOpponentTeamId'] == record.actingTeamId &&
        teamId != record.actingTeamId) {
      return false;
    }
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
        team.id:
            (record.fixedScoreDeltas[team.id] ?? 0) +
            (team.id == teamId ? record.pointsForTeam(team.id) : 0),
    };
    final initial = Map<String, int>.from(
      record.roundData['roundStartingScores'] as Map? ?? const {},
    );
    final actingScore =
        (initial[record.actingTeamId] ?? 0) + newDeltas[record.actingTeamId]!;
    newDeltas[record.actingTeamId] =
        newDeltas[record.actingTeamId]! -
        SurpriseScoring.failureDebit(
          roundData: record.roundData,
          winner: teamId,
          actingTeamId: record.actingTeamId,
          currentScore: actingScore,
          question: record.question,
          clues: record.identityCluesRevealed,
        );
    final wagerDeltas = SurpriseSessionEffects.wagerDeltas(
      SurpriseSessionEffects.entries(record.roundData, 'settledWagers'),
      teamId,
    );
    for (final entry in wagerDeltas.entries) {
      newDeltas[entry.key] = newDeltas[entry.key]! + entry.value;
    }
    var teams = state.teams
        .map(
          (team) => team.copyWith(
            score:
                team.score -
                (record.scoreDeltas[team.id] ?? 0) +
                newDeltas[team.id]!,
          ),
        )
        .toList();
    if (record.roundData['rewardDefinitionId'] case String definitionId) {
      teams = _withReward(
        teams,
        record.roundData['rewardId'] as String,
        definitionId,
        teamId == record.actingTeamId ? teamId : null,
        record.turn,
      );
    }
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
    var teams = state.teams
        .map(
          (team) => team.copyWith(
            score:
                team.score -
                (record.scoreDeltas[team.id] ?? 0) +
                (record.fixedScoreDeltas[team.id] ?? 0),
          ),
        )
        .toList();
    if (record.roundData['rewardDefinitionId'] case String definitionId) {
      teams = _withReward(
        teams,
        record.roundData['rewardId'] as String,
        definitionId,
        null,
        record.turn,
      );
    }
    _set(
      state.copyWith(
        phase: SessionPhase.answer,
        teams: teams,
        history: state.history.take(state.history.length - 1),
        sessionEffects: record.effectsBefore,
        question: record.question,
        turn: record.turn,
        selectionTeamId: record.actingTeamId,
        revealedCards: 3,
        secondsRemaining: record.secondsAtAnswer,
        pauseReason: PauseReason.manual,
        isAbilityRound: record.isAbilityRound,
        roundData: {
          ...record.roundData,
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
    if (state.roundData['googlePendingCard'] != null) {
      throw StateError('جارٍ فتح البحث؛ انتظر اكتمال العملية.');
    }
    if (TeamAbilityCatalog.contains(
          state.teams
              .firstWhere((t) => t.id == ownerTeamId)
              .inventory
              .firstWhere((c) => c.id == cardId)
              .definitionId,
        ) &&
        !config.abilitiesEnabled) {
      throw StateError('اللعب بالقدرات غير مفعّل لهذه المباراة.');
    }
    final originalCard = state.teams
        .firstWhere((t) => t.id == ownerTeamId)
        .inventory
        .firstWhere((c) => c.id == cardId);
    final result = AbilityService(abilities).use(
      teams: state.teams,
      ownerTeamId: ownerTeamId,
      cardId: cardId,
      window: abilityWindow,
      targetTeamId: targetTeamId,
      question: state.question,
      roundData: _abilityContextData(),
    );
    final data = Map<String, Object?>.from(result.roundData)
      ..removeWhere((key, _) => key.startsWith('_'));
    data['lastAbilityTitle'] =
        abilities.definitions[originalCard.definitionId]!.title;
    data['lastAbilityTeamId'] = ownerTeamId;
    data['abilityUseLog'] = [
      ...?state.roundData['abilityUseLog'] as List?,
      {
        'cardId': originalCard.id,
        'definitionId': originalCard.definitionId,
        'ownerTeamId': ownerTeamId,
        'targetTeamId': targetTeamId ?? ownerTeamId,
        'at': _now().toUtc().toIso8601String(),
        if (originalCard.definitionId == TeamAbilityCatalog.dice)
          'diceResult': data['diceResult'],
      },
    ];
    if (originalCard.definitionId == TeamAbilityCatalog.google) {
      final now = _now();
      final naturalDeadline = searchClockRunning && !state.plankRunning
          ? DateTime.parse(state.roundData['searchWindowDeadline'] as String)
          : _clockDeadline ??
                now.add(Duration(seconds: state.secondsRemaining));
      final searchEnd = now.add(const Duration(seconds: 20));
      data['googleEndsAt'] =
          (state.plankRunning || searchEnd.isBefore(naturalDeadline)
                  ? searchEnd
                  : naturalDeadline)
              .toUtc()
              .toIso8601String();
      data['searchWindowDeadline'] =
          (searchClockRunning && !state.plankRunning
                  ? DateTime.parse(
                      state.roundData['searchWindowDeadline'] as String,
                    )
                  : naturalDeadline)
              .toUtc()
              .toIso8601String();
      data['searchClockActive'] = true;
      data['searchClockMode'] = state.plankRunning ? 'plank' : 'countdown';
      if (state.plankRunning) {
        data['searchPlankStartedAt'] = now.toUtc().toIso8601String();
        data['searchPlankBaseSeconds'] = state.plankSeconds;
      }
      data['googlePendingCard'] = originalCard.toJson();
    }
    _set(
      state.copyWith(
        teams: result.teams,
        roundData: data,
        abilityRevision: state.abilityRevision + 1,
      ),
    );
    if (originalCard.definitionId == TeamAbilityCatalog.google) _startTimer();
  }

  Map<String, Object?> _abilityContextData() => {
    ...state.roundData,
    '_activeTeam': state.activeTeam.id,
    '_answeringTeam': state.answeringTeam.id,
    '_opponentWindow': state.isOpponentWindow,
    '_seconds': state.secondsRemaining,
    '_elapsed': state.plankAccepted
        ? state.plankSeconds
        : state.roundData['questionElapsedSeconds'] as int? ?? 0,
    '_plank': state.plankAccepted,
    '_googleRemaining': googleSecondsLeft,
    '_firstAnswerRecorded': (state.roundData['firstAnswers'] as Map? ?? {})
        .containsKey(state.answeringTeam.id),
    '_surpriseBlocks': state.surpriseCard?.effect == SurpriseEffect.noOpponent,
  };

  String? abilityUnavailableReason(
    String ownerId,
    OwnedAbility card, {
    String? targetId,
  }) {
    if (state.roundData['googlePendingCard'] != null) return 'جارٍ فتح البحث…';
    if (state.isPaused || revealing) return 'استأنف المباراة أولًا.';
    if (state.phase == SessionPhase.results) return 'انتهت المباراة.';
    final definition = abilities.definitions[card.definitionId];
    if (definition == null || !abilities.isReady(card.definitionId)) {
      return 'تعريف البطاقة غير متاح.';
    }
    if (TeamAbilityCatalog.contains(card.definitionId) &&
        !config.abilitiesEnabled) {
      return 'القدرات غير مفعّلة.';
    }
    if (!definition.windows.contains(AbilityWindow.anyTime) &&
        !definition.windows.contains(abilityWindow)) {
      return card.definitionId == TeamAbilityCatalog.doublePoints
          ? 'اختر سؤال فريقك واستخدمها قبل كشفه.'
          : 'غير متاحة في هذه المرحلة.';
    }
    return abilities.effects[definition.effectKey]!.validate(
      AbilityContext(
        teams: state.teams,
        ownerTeamId: ownerId,
        targetTeamId:
            targetId ??
            (definition.target == AbilityTarget.opponent
                ? state.teams.firstWhere((t) => t.id != ownerId).id
                : ownerId),
        window: abilityWindow,
        question: state.question,
        roundData: _abilityContextData(),
      ),
    );
  }

  bool get searchClockRunning =>
      state.phase == SessionPhase.cards &&
      state.roundData['searchClockActive'] == true;
  DateTime _opponentSearchDeadline() {
    if (state.roundData['searchClockMode'] == 'plank') {
      return _now().add(const Duration(seconds: 7));
    }
    final deadline = DateTime.parse(
      state.roundData['searchWindowDeadline'] as String,
    );
    return (_now().isBefore(deadline) ? _now() : deadline).add(
      const Duration(seconds: 7),
    );
  }

  int get googleSecondsLeft {
    final raw = state.roundData['googleEndsAt'];
    if (raw is! String ||
        state.phase != SessionPhase.cards ||
        state.secondsRemaining <= 0 && !state.plankRunning ||
        state.roundData['googleTeamId'] != state.answeringTeam.id) {
      return 0;
    }
    final now = state.isPaused && state.roundData['searchPausedAt'] is String
        ? DateTime.parse(state.roundData['searchPausedAt'] as String)
        : _now();
    final left = max(
      0,
      (DateTime.parse(raw).difference(now).inMilliseconds / 1000).ceil(),
    );
    return state.plankRunning ? left : min(left, state.secondsRemaining);
  }

  void syncSearchClock() {
    if (!searchClockRunning || state.isPaused) return;
    if (state.roundData['searchClockMode'] == 'plank') {
      if (state.plankRunning) {
        final elapsed = max(
          0,
          _now()
              .difference(
                DateTime.parse(
                  state.roundData['searchPlankStartedAt'] as String,
                ),
              )
              .inSeconds,
        );
        _set(
          state.copyWith(
            roundData: {
              ...state.roundData,
              'plankElapsedSeconds':
                  (state.roundData['searchPlankBaseSeconds'] as int) + elapsed,
            },
          ),
        );
      }
      return;
    }
    final deadline = DateTime.parse(
      state.roundData['searchWindowDeadline'] as String,
    );
    final left = max(
      0,
      (deadline.difference(_now()).inMilliseconds / 1000).ceil(),
    );
    final elapsed =
        (state.roundData['questionElapsedSeconds'] as int? ?? 0) +
        max(0, state.secondsRemaining - left);
    _set(
      state.copyWith(
        secondsRemaining: left,
        roundData: {...state.roundData, 'questionElapsedSeconds': elapsed},
      ),
    );
    if (left == 0 && !state.isOpponentWindow) startOpponentOpportunity();
    if (state.secondsRemaining == 0) _timer?.cancel();
  }

  /// A failed external launch refunds exactly its pending card, once.
  void finishGoogleLaunch(bool success) {
    final raw = state.roundData['googlePendingCard'];
    if (raw is! Map) return;
    if (!success) syncSearchClock();
    final card = OwnedAbility.fromJson(Map<String, dynamic>.from(raw));
    final data = {...state.roundData}..remove('googlePendingCard');
    if (!success) {
      data.remove('googleTeamId');
      data.remove('googleEndsAt');
      data['searchClockActive'] = false;
      _set(
        state.copyWith(
          teams: state.teams.map(
            (team) => team.id == card.ownerTeamId
                ? team.copyWith(
                    inventory: [
                      ...team.inventory.where((c) => c.id != card.id),
                      card,
                    ],
                  )
                : team,
          ),
          roundData: data,
          abilityRevision: state.abilityRevision - 1,
        ),
      );
      if (!_foreground) {
        pause(PauseReason.background);
      } else {
        _startTimer();
      }
    } else {
      _set(state.copyWith(roundData: data));
    }
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
    _abilityQuestionIds = Set.unmodifiable(
      config.abilitiesEnabled
          ? fresh.skip(30).map((q) => q.id)
          : const <String>[],
    );
    _replayQuestionIds = Set.unmodifiable(
      fresh.where(_usage.contains).map((q) => q.id),
    );
    id = 'session-${_now().microsecondsSinceEpoch}-${_nextId++}';
    createdAt = _now();
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
    OnlineSyncService().syncState(state);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    OnlineSyncService().stopBroadcasting();
    super.dispose();
  }
}
