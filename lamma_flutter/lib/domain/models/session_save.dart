import 'dart:convert';
import 'question.dart';
import 'session_config.dart';
import 'session_state.dart';
import 'hint_access.dart';

class UnsupportedSaveVersion extends FormatException {
  const UnsupportedSaveVersion() : super('Unsupported saved-session version.');
}

final class SessionSave {
  SessionSave({
    required this.id,
    required this.config,
    required this.state,
    required Iterable<Question> questions,
    required this.createdAt,
    required this.updatedAt,
    required this.revision,
  }) : questions = List.unmodifiable(questions) {
    _validate();
  }
  static const version = 2;
  final String id;
  final SessionConfig config;
  final SessionState state;
  final List<Question> questions;
  final DateTime createdAt, updatedAt;
  final int revision;

  void _validate() {
    final teamIds = config.teams.map((team) => team.id).toSet();
    final ids = questions.map((question) => question.id).toSet();
    if (id.isEmpty ||
        revision < 0 ||
        state.turn < 0 ||
        state.turn != state.history.length ||
        state.revealedCards < 0 ||
        state.revealedCards > 3 ||
        state.secondsRemaining < 0 ||
        state.secondsRemaining > 86400 ||
        state.abilityRevision < 0 ||
        state.identityCluesRevealed < 1 ||
        state.identityCluesRevealed > 3 ||
        questions.isEmpty ||
        ids.length != questions.length) {
      throw const FormatException('Invalid session progress.');
    }
    if (state.teams.length != teamIds.length ||
        state.teams.map((team) => team.id).toSet().length != teamIds.length ||
        state.teams.any((team) => !teamIds.contains(team.id))) {
      throw const FormatException('Invalid saved teams.');
    }
    if (questions.any(
          (question) =>
              !config.categoryIds.contains(question.categoryId) ||
              question.isIdentity &&
                  (question.clues.length != 3 ||
                      question.clues.any((clue) => clue.trim().isEmpty)),
        ) ||
        config.categoryIds.any(
          (id) => !questions.any((question) => question.categoryId == id),
        ) ||
        !ids.containsAll(state.seenQuestionIds)) {
      throw const FormatException('Invalid saved question pool.');
    }
    if ((state.phase == SessionPhase.cards ||
            state.phase == SessionPhase.answer) &&
        (state.question == null || !ids.contains(state.question!.id))) {
      throw const FormatException('Missing current question.');
    }
    if ((state.phase == SessionPhase.categories ||
            state.phase == SessionPhase.results) &&
        state.question != null) {
      throw const FormatException('Unexpected current question.');
    }
    if (state.phase == SessionPhase.answer && state.revealedCards != 3) {
      throw const FormatException('Invalid answer phase.');
    }
    if (state.opponentTeamId != null &&
        (!teamIds.contains(state.opponentTeamId) ||
            state.opponentTeamId == state.activeTeam.id ||
            state.revealedCards != 3 ||
            state.secondsRemaining > 7 ||
            (state.phase != SessionPhase.cards &&
                state.phase != SessionPhase.answer))) {
      throw const FormatException('Invalid opponent opportunity.');
    }
    if (state.isOpponentWindow &&
        (state.opponentTeamId == null ||
            ![
              'only',
              'lowest',
              'tie',
            ].contains(state.roundData['opponentReason']))) {
      throw const FormatException('Missing opponent selection.');
    }
    if (state.revealedCards == 3 &&
        state.question != null &&
        !state.seenQuestionIds.contains(state.question!.id)) {
      throw const FormatException('Current question was not recorded.');
    }
    final access = state.hintAccess;
    final surprise = state.surpriseCard;
    if (access != null &&
        (access.questionId != state.question?.id ||
            !teamIds.contains(access.teamId) ||
            state.question?.isIdentity == true ||
            state.question?.hint.isNotEmpty != true ||
            access.source == HintSource.surprise &&
                (state.revealedCards < 1 ||
                    access.teamId != state.activeTeam.id ||
                    surprise?.id != access.cardId ||
                    surprise?.grantsHint != true))) {
      throw const FormatException('Invalid hint permission.');
    }
    for (var i = 0; i < state.history.length; i++) {
      final round = state.history[i];
      if (round.turn != i ||
          !ids.contains(round.question.id) ||
          !state.seenQuestionIds.contains(round.question.id) ||
          !teamIds.contains(round.actingTeamId) ||
          round.answerTeamId != null &&
              (!teamIds.contains(round.answerTeamId) ||
                  round.answerTeamId == round.actingTeamId) ||
          round.awardedTeamId != null &&
              !teamIds.contains(round.awardedTeamId) ||
          round.scoreDeltas.keys.any((id) => !teamIds.contains(id)) ||
          round.secondsAtAnswer < 0 ||
          round.identityCluesRevealed < 1 ||
          round.identityCluesRevealed > 3 ||
          round.correctionCount < 0) {
        throw const FormatException('Invalid round ledger.');
      }
    }
    if (state.history.map((round) => round.id).toSet().length !=
            state.history.length ||
        state.history.map((round) => round.question.id).toSet().length !=
            state.history.length) {
      throw const FormatException('Duplicate saved rounds.');
    }
    for (final change in state.corrections) {
      if (change.previousTeamId != null &&
              !teamIds.contains(change.previousTeamId) ||
          change.nextTeamId != null && !teamIds.contains(change.nextTeamId)) {
        throw const FormatException('Invalid correction ledger.');
      }
    }
    // Fail before a write if a future ability adds non-serializable data.
    jsonEncode(state.roundData);
  }

  Map<String, Object?> toJson() => {
    'version': version,
    'id': id,
    'config': config.toJson(),
    'state': state.toJson(),
    'questions': questions.map((question) => question.toJson()).toList(),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'revision': revision,
  };
  factory SessionSave.fromJson(Map<String, dynamic> json) {
    if (json['version'] != version && json['version'] != 1) {
      throw const UnsupportedSaveVersion();
    }
    try {
      return SessionSave(
        id: json['id'] as String,
        config: SessionConfig.fromJson(json['config'] as Map<String, dynamic>),
        state: SessionState.fromJson(json['state'] as Map<String, dynamic>),
        questions: (json['questions'] as List<dynamic>).map(
          (raw) => Question.fromJson(raw as Map<String, dynamic>),
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        revision: json['revision'] as int,
      );
    } on Object {
      throw const FormatException('Saved session is incomplete or damaged.');
    }
  }
}
