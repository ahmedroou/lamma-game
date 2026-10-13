import 'dart:math';
import '../models/question.dart';
import '../models/session_config.dart';
import '../models/team.dart';
import 'ability_system.dart';

sealed class RiskOutcome {
  const RiskOutcome();
}

final class AbilityWon extends RiskOutcome {
  const AbilityWon(this.definitionId);
  final String definitionId;
}

final class PointsLost extends RiskOutcome {
  PointsLost(this.amount) {
    if (!const {50, 100, 150}.contains(amount)) {
      throw ArgumentError('Risk penalties are restricted to 50, 100, 150.');
    }
  }
  final int amount;
}

final class WeightedRiskOption {
  WeightedRiskOption(this.outcome, this.weight) {
    if (weight <= 0) throw ArgumentError('Risk weight must be positive.');
  }
  final RiskOutcome outcome;
  final int weight;
}

enum ScoreFloorPolicy { allowNegative, clampAtZero }

final class RiskPolicy {
  RiskPolicy({
    required Iterable<WeightedRiskOption> options,
    required this.scoreFloor,
  }) : options = List.unmodifiable(options) {
    if (this.options.isEmpty) {
      throw ArgumentError('Explicit risk probabilities are required.');
    }
  }
  final List<WeightedRiskOption> options;
  final ScoreFloorPolicy scoreFloor;
}

final class RiskSettlement {
  const RiskSettlement({
    required this.team,
    required this.outcome,
    required this.questionPointsAwarded,
  });
  final TeamState team;
  final RiskOutcome outcome;
  final int questionPointsAwarded;
}

// No default odds or score floor: both are explicit product decisions.
final class RiskEngine {
  RiskEngine({
    required this.policy,
    required this.registry,
    int Function(int)? draw,
  }) : _draw = draw ?? Random().nextInt {
    for (final option in policy.options) {
      if (option.outcome case AbilityWon(:final definitionId)) {
        if (!registry.isReady(definitionId)) {
          throw ArgumentError('Risk reward must be a configured ability.');
        }
      }
    }
  }
  final RiskPolicy policy;
  final AbilityRegistry registry;
  final int Function(int) _draw;

  RiskSettlement resolve({
    required Question question,
    required Set<String> selectedCategoryIds,
    required TeamState team,
    required String cardInstanceId,
    required int turn,
  }) {
    if (selectedCategoryIds.length != GameRules.selectedCategoryCount ||
        selectedCategoryIds.contains(GameRules.abilitiesCategoryId) ||
        !selectedCategoryIds.contains(question.categoryId)) {
      throw ArgumentError(
        'Ability question must belong to the six selected categories.',
      );
    }
    if (turn < 0 || cardInstanceId.isEmpty) {
      throw ArgumentError('Risk turn identity is required.');
    }
    final total = policy.options.fold(
      0,
      (total, option) => total + option.weight,
    );
    var draw = _draw(total);
    if (draw < 0 || draw >= total) {
      throw StateError('Random source returned an invalid value.');
    }
    late RiskOutcome outcome;
    for (final option in policy.options) {
      if (draw < option.weight) {
        outcome = option.outcome;
        break;
      }
      draw -= option.weight;
    }
    switch (outcome) {
      case AbilityWon(:final definitionId):
        final definition = registry.definitions[definitionId]!;
        final card = OwnedAbility(
          id: cardInstanceId,
          definitionId: definitionId,
          ownerTeamId: team.id,
          acquiredTurn: turn,
          remainingUses: definition.usesPerCard,
        );
        return RiskSettlement(
          team: team.copyWith(
            score: team.score + question.points,
            inventory: [...team.inventory, card],
          ),
          outcome: outcome,
          questionPointsAwarded: question.points,
        );
      case PointsLost(:final amount):
        final score = team.score - amount;
        return RiskSettlement(
          team: team.copyWith(
            score: policy.scoreFloor == ScoreFloorPolicy.clampAtZero
                ? max(0, score)
                : score,
          ),
          outcome: outcome,
          questionPointsAwarded: 0,
        );
    }
  }
}
