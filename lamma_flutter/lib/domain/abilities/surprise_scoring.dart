import '../models/hint_access.dart';
import '../models/question.dart';

abstract final class SurpriseScoring {
  static int points({
    required Question question,
    required int clues,
    required String teamId,
    required String actingTeamId,
    required Map<String, Object?> roundData,
  }) {
    var value = question.pointsForClues(clues);
    if (roundData['surpriseApplied'] != true) {
      return value;
    }
    final encoded = roundData['surpriseCard'];
    if (encoded is! Map) return value;
    final card = SurpriseCard.fromJson(Map<String, Object?>.from(encoded));
    if (teamId != actingTeamId) {
      return card.effect == SurpriseEffect.opponentBonus
          ? value + card.amount
          : value;
    }
    if ({
      SurpriseEffect.doublePoints,
      SurpriseEffect.doubleOrLose,
    }.contains(card.effect)) {
      value *= 2;
    }
    if (card.effect == SurpriseEffect.options &&
        roundData['surpriseActionUsed'] == true) {
      value ~/= card.pointsDivisor;
    }
    return value;
  }

  static int penalty(
    Map<String, Object?> roundData,
    String? winner,
    String actingTeamId, {
    Question? question,
    int clues = 1,
  }) {
    if (winner == actingTeamId || roundData['surpriseApplied'] != true) {
      return 0;
    }
    final encoded = roundData['surpriseCard'];
    if (encoded is! Map) return 0;
    final card = SurpriseCard.fromJson(Map<String, Object?>.from(encoded));
    if (card.effect == SurpriseEffect.doubleOrLose) {
      return question!.pointsForClues(clues);
    }
    return card.effect == SurpriseEffect.failurePenalty ? card.amount : 0;
  }

  static Map<String, int> fixedDeltas(Map<String, Object?> roundData) =>
      Map<String, int>.from(
        roundData['surpriseFixedDeltas'] as Map? ?? const {},
      );

  static int failureDebit({
    required Map<String, Object?> roundData,
    required String? winner,
    required String actingTeamId,
    required int currentScore,
    required Question question,
    required int clues,
  }) {
    final amount = penalty(
      roundData,
      winner,
      actingTeamId,
      question: question,
      clues: clues,
    );
    if (amount == 0) return 0;
    // User rule: penalties may make scores negative; purchases may not.
    return amount;
  }
}
