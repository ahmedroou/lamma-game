import 'question.dart';
import 'team.dart';
import 'hint_access.dart';
import 'session_config.dart';
import '../abilities/surprise_scoring.dart';

enum SessionPhase { categories, cards, answer, results }

enum PauseReason { none, manual, background, restored, dialog }

final class RoundRecord {
  RoundRecord({
    required this.id,
    required this.turn,
    required this.question,
    required this.actingTeamId,
    required this.awardedTeamId,
    required Map<String, int> scoreDeltas,
    required this.secondsAtAnswer,
    required this.abilityRevision,
    required this.isAbilityRound,
    required this.completedAt,
    this.correctionCount = 0,
    this.identityCluesRevealed = 1,
    this.answerTeamId,
    this.roundData = const {},
    this.effectsBefore = const {},
  }) : scoreDeltas = Map.unmodifiable(scoreDeltas);
  final String id, actingTeamId;
  final String? awardedTeamId;
  final String? answerTeamId;
  final Question question;
  final int turn, secondsAtAnswer, abilityRevision, correctionCount;
  final int identityCluesRevealed;
  int get awardedPoints => pointsForTeam(awardedTeamId ?? actingTeamId);
  int pointsForTeam(String teamId) => SurpriseScoring.points(
    question: question,
    clues: identityCluesRevealed,
    teamId: teamId,
    actingTeamId: actingTeamId,
    roundData: roundData,
  );
  Map<String, int> get fixedScoreDeltas =>
      SurpriseScoring.fixedDeltas(roundData);
  final Map<String, Object?> roundData;
  final Map<String, Object?> effectsBefore;
  final bool isAbilityRound;
  final Map<String, int> scoreDeltas;
  final DateTime completedAt;
  RoundRecord corrected(String? teamId, Map<String, int> deltas) => RoundRecord(
    id: id,
    turn: turn,
    question: question,
    actingTeamId: actingTeamId,
    awardedTeamId: teamId,
    scoreDeltas: deltas,
    secondsAtAnswer: secondsAtAnswer,
    abilityRevision: abilityRevision,
    isAbilityRound: isAbilityRound,
    completedAt: completedAt,
    correctionCount: correctionCount + 1,
    identityCluesRevealed: identityCluesRevealed,
    answerTeamId: answerTeamId,
    roundData: roundData,
    effectsBefore: effectsBefore,
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'turn': turn,
    'question': question.toJson(),
    'actingTeamId': actingTeamId,
    'awardedTeamId': awardedTeamId,
    'scoreDeltas': scoreDeltas,
    'secondsAtAnswer': secondsAtAnswer,
    'abilityRevision': abilityRevision,
    'correctionCount': correctionCount,
    'identityCluesRevealed': identityCluesRevealed,
    'answerTeamId': answerTeamId,
    'isAbilityRound': isAbilityRound,
    if (roundData.isNotEmpty) 'roundData': roundData,
    if (effectsBefore.isNotEmpty) 'effectsBefore': effectsBefore,
    'completedAt': completedAt.toUtc().toIso8601String(),
  };
  factory RoundRecord.fromJson(Map<String, dynamic> json) => RoundRecord(
    id: json['id'] as String,
    turn: json['turn'] as int,
    question: Question.fromJson(json['question'] as Map<String, dynamic>),
    actingTeamId: json['actingTeamId'] as String,
    awardedTeamId: json['awardedTeamId'] as String?,
    scoreDeltas: (json['scoreDeltas'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, value as int),
    ),
    secondsAtAnswer: json['secondsAtAnswer'] as int,
    abilityRevision: json['abilityRevision'] as int,
    correctionCount: json['correctionCount'] as int,
    identityCluesRevealed: json['identityCluesRevealed'] as int? ?? 1,
    answerTeamId: json['answerTeamId'] as String?,
    roundData: Map<String, Object?>.from(json['roundData'] as Map? ?? const {}),
    effectsBefore: Map<String, Object?>.from(
      json['effectsBefore'] as Map? ?? const {},
    ),
    isAbilityRound: json['isAbilityRound'] as bool,
    completedAt: DateTime.parse(json['completedAt'] as String),
  );
}

final class JudgmentChange {
  const JudgmentChange({
    required this.roundId,
    required this.previousTeamId,
    required this.nextTeamId,
    required this.at,
    required this.reopened,
  });
  final String roundId;
  final String? previousTeamId, nextTeamId;
  final DateTime at;
  final bool reopened;
  Map<String, Object?> toJson() => {
    'roundId': roundId,
    'previousTeamId': previousTeamId,
    'nextTeamId': nextTeamId,
    'at': at.toUtc().toIso8601String(),
    'reopened': reopened,
  };
  factory JudgmentChange.fromJson(Map<String, dynamic> json) => JudgmentChange(
    roundId: json['roundId'] as String,
    previousTeamId: json['previousTeamId'] as String?,
    nextTeamId: json['nextTeamId'] as String?,
    at: DateTime.parse(json['at'] as String),
    reopened: json['reopened'] as bool,
  );
}

final class SessionState {
  SessionState({
    required this.phase,
    required Iterable<TeamState> teams,
    required Iterable<String> seenQuestionIds,
    this.question,
    this.turn = 0,
    this.revealedCards = 0,
    this.secondsRemaining = 30,
    this.isAbilityRound = false,
    this.pauseReason = PauseReason.none,
    this.endedEarly = false,
    this.abilityRevision = 0,
    Iterable<RoundRecord> history = const [],
    Iterable<JudgmentChange> corrections = const [],
    Map<String, Object?> roundData = const {},
    Map<String, Object?> sessionEffects = const {},
    Map<String, int> abilitySelections = const {},
    this.selectionTeamId,
  }) : teams = List.unmodifiable(teams),
       seenQuestionIds = Set.unmodifiable(seenQuestionIds),
       history = List.unmodifiable(history),
       corrections = List.unmodifiable(corrections),
       roundData = Map.unmodifiable(roundData),
       sessionEffects = Map.unmodifiable(sessionEffects),
       abilitySelections = Map.unmodifiable(abilitySelections);
  final SessionPhase phase;
  final List<TeamState> teams;
  final Set<String> seenQuestionIds;
  final Question? question;
  final int turn, revealedCards, secondsRemaining, abilityRevision;
  final bool isAbilityRound, endedEarly;
  final PauseReason pauseReason;
  final List<RoundRecord> history;
  final List<JudgmentChange> corrections;
  final Map<String, Object?> roundData;
  final Map<String, Object?> sessionEffects;
  final Map<String, int> abilitySelections;
  final String? selectionTeamId;
  bool get isPaused =>
      pauseReason != PauseReason.none && phase != SessionPhase.results;
  TeamState get activeTeam => selectionTeamId == null
      ? teams[turn % teams.length]
      : teams.firstWhere((team) => team.id == selectionTeamId);
  String? get opponentTeamId => roundData['opponentTeamId'] as String?;
  bool get isOpponentWindow => roundData['answerWindow'] == 'opponent';
  bool get opponentSelectedByLot => roundData['opponentReason'] == 'tie';
  bool get plankAccepted =>
      surpriseCard?.effect == SurpriseEffect.plank &&
      roundData['plankDecision'] == 'accepted' &&
      !isOpponentWindow;
  bool get plankRunning =>
      plankAccepted &&
      roundData['plankRunning'] == true &&
      phase == SessionPhase.cards;
  int get plankSeconds => roundData['plankElapsedSeconds'] as int? ?? 0;
  int get clockSeconds => plankAccepted ? plankSeconds : secondsRemaining;
  int get initialQuestionSeconds =>
      roundData['initialQuestionSeconds'] as int? ??
      (question?.categoryId == 'reverse_question'
          ? GameRules.reverseQuestionSeconds
          : GameRules.primaryQuestionSeconds);
  int get baseQuestionSeconds =>
      roundData['baseQuestionSeconds'] as int? ??
      (question?.categoryId == 'reverse_question'
          ? GameRules.reverseQuestionSeconds
          : GameRules.primaryQuestionSeconds);
  TeamState get answeringTeam => opponentTeamId == null
      ? activeTeam
      : teams.firstWhere((team) => team.id == opponentTeamId);
  int get identityCluesRevealed =>
      roundData['identityCluesRevealed'] as int? ?? 1;
  HintAccess? get hintAccess => roundData['hintAccess'] == null
      ? null
      : HintAccess.fromJson(
          Map<String, Object?>.from(roundData['hintAccess'] as Map),
        );
  SurpriseCard? get surpriseCard => roundData['surpriseCard'] == null
      ? null
      : SurpriseCard.fromJson(
          Map<String, Object?>.from(roundData['surpriseCard'] as Map),
        );
  bool get hintRevealed =>
      roundData['hintRevealed'] == true &&
      hintAccess != null &&
      hintAccess?.questionId == question?.id;
  int get availablePoints => question == null
      ? 0
      : SurpriseScoring.points(
          question: question!,
          clues: identityCluesRevealed,
          teamId: answeringTeam.id,
          actingTeamId: activeTeam.id,
          roundData: roundData,
        );
  List<QuestionOption> get visibleOptions {
    if (roundData['optionsQuestionId'] != question?.id ||
        roundData['optionsTeamId'] != answeringTeam.id ||
        revealedCards != 3) {
      return const [];
    }
    final ids = (roundData['visibleOptionIds'] as List? ?? const [])
        .cast<String>();
    return List.unmodifiable(
      ids.map(
        (id) => question!.options.singleWhere((option) => option.id == id),
      ),
    );
  }

  Map<String, String> get questionDraft {
    final drafts = roundData['questionDrafts'];
    if (drafts is! Map) return const {};
    final current = drafts[answeringTeam.id];
    if (current is! Map) return const {};
    return Map.unmodifiable(
      current.map((key, value) => MapEntry(key as String, value as String)),
    );
  }

  SessionState copyWith({
    SessionPhase? phase,
    Iterable<TeamState>? teams,
    Iterable<String>? seenQuestionIds,
    Question? question,
    bool clearQuestion = false,
    int? turn,
    int? revealedCards,
    int? secondsRemaining,
    bool? isAbilityRound,
    bool? endedEarly,
    int? abilityRevision,
    PauseReason? pauseReason,
    Iterable<RoundRecord>? history,
    Iterable<JudgmentChange>? corrections,
    Map<String, Object?>? roundData,
    Map<String, Object?>? sessionEffects,
    Map<String, int>? abilitySelections,
    String? selectionTeamId,
  }) => SessionState(
    phase: phase ?? this.phase,
    teams: teams ?? this.teams,
    seenQuestionIds: seenQuestionIds ?? this.seenQuestionIds,
    question: clearQuestion ? null : question ?? this.question,
    turn: turn ?? this.turn,
    revealedCards: revealedCards ?? this.revealedCards,
    secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    isAbilityRound: isAbilityRound ?? this.isAbilityRound,
    pauseReason: pauseReason ?? this.pauseReason,
    endedEarly: endedEarly ?? this.endedEarly,
    abilityRevision: abilityRevision ?? this.abilityRevision,
    history: history ?? this.history,
    corrections: corrections ?? this.corrections,
    roundData: roundData ?? this.roundData,
    sessionEffects: sessionEffects ?? this.sessionEffects,
    abilitySelections: abilitySelections ?? this.abilitySelections,
    selectionTeamId: selectionTeamId ?? this.selectionTeamId,
  );

  Map<String, Object?> toJson() => {
    'phase': phase.name,
    'teams': teams.map((team) => team.toJson()).toList(),
    'seenQuestionIds': seenQuestionIds.toList(),
    'question': question?.toJson(),
    'turn': turn,
    'revealedCards': revealedCards,
    'secondsRemaining': secondsRemaining,
    'isAbilityRound': isAbilityRound,
    'pauseReason': pauseReason.name,
    'endedEarly': endedEarly,
    'abilityRevision': abilityRevision,
    'history': history.map((round) => round.toJson()).toList(),
    'corrections': corrections.map((change) => change.toJson()).toList(),
    'roundData': roundData,
    'abilitySelections': abilitySelections,
    'selectionTeamId': selectionTeamId,
    if (sessionEffects.isNotEmpty) 'sessionEffects': sessionEffects,
  };
  factory SessionState.fromJson(Map<String, dynamic> json) => SessionState(
    phase: SessionPhase.values.byName(json['phase'] as String),
    teams: (json['teams'] as List<dynamic>).map(
      (raw) => TeamState.fromJson(raw as Map<String, dynamic>),
    ),
    seenQuestionIds: (json['seenQuestionIds'] as List<dynamic>).cast<String>(),
    question: json['question'] == null
        ? null
        : Question.fromJson(json['question'] as Map<String, dynamic>),
    turn: json['turn'] as int,
    abilitySelections: Map<String, int>.from(
      json['abilitySelections'] as Map? ?? const {},
    ),
    selectionTeamId: json['selectionTeamId'] as String?,
    revealedCards: json['revealedCards'] as int,
    secondsRemaining: json['secondsRemaining'] as int,
    isAbilityRound: json['isAbilityRound'] as bool,
    pauseReason: PauseReason.values.byName(json['pauseReason'] as String),
    endedEarly: json['endedEarly'] as bool,
    abilityRevision: json['abilityRevision'] as int,
    history: (json['history'] as List<dynamic>).map(
      (raw) => RoundRecord.fromJson(raw as Map<String, dynamic>),
    ),
    corrections: (json['corrections'] as List<dynamic>).map(
      (raw) => JudgmentChange.fromJson(raw as Map<String, dynamic>),
    ),
    roundData: Map<String, Object?>.from(
      json['roundData'] as Map<String, dynamic>,
    ),
    sessionEffects: Map<String, Object?>.from(
      json['sessionEffects'] as Map? ?? const {},
    ),
  );
}
