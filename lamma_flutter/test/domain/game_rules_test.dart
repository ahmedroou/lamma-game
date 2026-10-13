import '../fixtures/questions.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/domain/abilities/ability_system.dart';
import 'package:lamma/domain/abilities/risk_engine.dart';

final scope = seedQuestions
    .take(6)
    .map((question) => question.categoryId)
    .toSet();
TeamState team(
  String id, {
  int score = 0,
  List<OwnedAbility> inventory = const [],
}) => TeamState(id: id, name: id, score: score, inventory: inventory);
AbilityRegistry testRegistry({AbilityEffect? effect, int uses = 1}) =>
    AbilityRegistry(
      definitions: [
        AbilityDefinition(
          id: 'test-only',
          title: 'Test fixture',
          description: 'Not a product ability',
          effectKey: 'test-effect',
          windows: {AbilityWindow.beforeScoring},
          target: AbilityTarget.opponent,
          usesPerCard: uses,
        ),
      ],
      effects: {'test-effect': effect ?? _Effect()},
    );

class _Effect implements AbilityEffect {
  @override
  String? validate(AbilityContext context) => null;
  @override
  AbilityImpact apply(AbilityContext context) => AbilityImpact(
    scoreDeltas: {context.ownerTeamId: 10},
    roundChanges: {'testApplied': true},
  );
}

class _RejectingEffect extends _Effect {
  @override
  String? validate(AbilityContext context) => 'Test rejection';
}

void main() {
  group('Questions and configuration', () {
    test('All four difficulty scores are derived from the saved level', () {
      expect(QuestionDifficulty.values.map((level) => level.points), [
        100,
        200,
        300,
        400,
      ]);
      for (final level in QuestionDifficulty.values) {
        final question = Question(
          id: 'q',
          categoryId: 'myths',
          text: 'سؤال',
          answer: 'جواب',
          difficulty: level,
        );
        final restored = Question.fromJson(
          jsonDecode(jsonEncode(question.toJson())) as Map<String, dynamic>,
        );
        expect(restored.difficulty, level);
        expect(restored.points, level.points);
      }
    });
    test('Missing or invalid difficulty fails instead of guessing', () {
      final json = seedQuestions.first.toJson()..remove('difficulty');
      expect(() => Question.fromJson(json), throwsFormatException);
      json['difficulty'] = 'super_easy';
      expect(() => Question.fromJson(json), throwsFormatException);
    });
    test('Two or three teams and exactly six normal categories', () {
      for (final count in [2, 3]) {
        final config = SessionConfig(
          teams: List.generate(count, (i) => team('$i')),
          categoryIds: scope,
        );
        expect(config.boardCategoryIds.length, 7);
        expect(config.boardCategoryIds.last, GameRules.abilitiesCategoryId);
        final restored = SessionConfig.fromJson(config.toJson());
        expect(restored.teams.length, count);
        expect(restored.categoryIds, scope);
      }
      for (final count in [1, 4]) {
        expect(
          () => SessionConfig(
            teams: List.generate(count, (i) => team('$i')),
            categoryIds: scope,
          ),
          throwsArgumentError,
        );
      }
      expect(
        () => SessionConfig(
          teams: [team('a'), team('b')],
          categoryIds: scope.take(5),
        ),
        throwsArgumentError,
      );
      expect(
        () => SessionConfig(
          teams: [team('a'), team('b')],
          categoryIds: {...scope, 'geography'},
        ),
        throwsArgumentError,
      );
      expect(
        () => SessionConfig(
          teams: [team('a'), team('b')],
          categoryIds: {...scope.take(5), GameRules.abilitiesCategoryId},
        ),
        throwsArgumentError,
      );
      expect(
        () => SessionConfig(
          teams: [team('same'), team('same')],
          categoryIds: scope,
        ),
        throwsArgumentError,
      );
    });
    test(
      'Team inventory round trips and prevents duplicate or foreign cards',
      () {
        final card = OwnedAbility(
          id: 'card',
          definitionId: 'test-only',
          ownerTeamId: 'a',
          acquiredTurn: 2,
          remainingUses: 1,
        );
        final original = team('a', score: 400, inventory: [card]);
        final restored = TeamState.fromJson(
          jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
        );
        expect(restored.inventory.single.ownerTeamId, 'a');
        expect(restored.score, 400);
        expect(() => original.inventory.clear(), throwsUnsupportedError);
        expect(() => team('b', inventory: [card]), throwsArgumentError);
        expect(() => team('a', inventory: [card, card]), throwsArgumentError);
      },
    );
  });

  group('Ability ownership and usage', () {
    final card = OwnedAbility(
      id: 'owned',
      definitionId: 'test-only',
      ownerTeamId: 'a',
      acquiredTurn: 0,
      remainingUses: 1,
    );
    test(
      'Definition serializes timing, targeting and uses without hardcoding a type',
      () {
        final definition = testRegistry().definitions.values.single;
        final restored = AbilityDefinition.fromJson(definition.toJson());
        expect(restored.windows, {AbilityWindow.beforeScoring});
        expect(restored.target, AbilityTarget.opponent);
        expect(restored.usesPerCard, 1);
        expect(AbilityRegistry().definitions, isEmpty);
      },
    );
    test(
      'Successful use affects the right team and consumes the owned card once',
      () {
        final service = AbilityService(testRegistry());
        final original = [
          team('a', inventory: [card]),
          team('b'),
        ];
        final result = service.use(
          teams: original,
          ownerTeamId: 'a',
          cardId: 'owned',
          targetTeamId: 'b',
          window: AbilityWindow.beforeScoring,
        );
        expect(result.teams.first.score, 10);
        expect(result.teams.first.inventory, isEmpty);
        expect(result.teams.last.score, 0);
        expect(result.roundData['testApplied'], true);
        expect(original.first.inventory.length, 1);
        expect(
          () => service.use(
            teams: result.teams,
            ownerTeamId: 'a',
            cardId: 'owned',
            targetTeamId: 'b',
            window: AbilityWindow.beforeScoring,
          ),
          throwsStateError,
        );
      },
    );
    test(
      'Invalid owner, timing, target, and effect rejection preserve inventory',
      () {
        final original = [
          team('a', inventory: [card]),
          team('b'),
        ];
        final service = AbilityService(testRegistry());
        expect(
          () => service.use(
            teams: original,
            ownerTeamId: 'b',
            cardId: 'owned',
            window: AbilityWindow.beforeScoring,
          ),
          throwsStateError,
        );
        expect(
          () => service.use(
            teams: original,
            ownerTeamId: 'a',
            cardId: 'owned',
            targetTeamId: 'b',
            window: AbilityWindow.duringQuestion,
          ),
          throwsStateError,
        );
        expect(
          () => service.use(
            teams: original,
            ownerTeamId: 'a',
            cardId: 'owned',
            targetTeamId: 'a',
            window: AbilityWindow.beforeScoring,
          ),
          throwsStateError,
        );
        expect(
          () => service.use(
            teams: original,
            ownerTeamId: 'a',
            cardId: 'owned',
            targetTeamId: 'missing',
            window: AbilityWindow.beforeScoring,
          ),
          throwsStateError,
        );
        expect(
          () => AbilityService(testRegistry(effect: _RejectingEffect())).use(
            teams: original,
            ownerTeamId: 'a',
            cardId: 'owned',
            targetTeamId: 'b',
            window: AbilityWindow.beforeScoring,
          ),
          throwsStateError,
        );
        expect(original.first.inventory.single.id, 'owned');
        expect(original.first.score, 0);
      },
    );
    test('Explicit multiple-use definition reduces remaining uses', () {
      final multiple = OwnedAbility(
        id: 'owned',
        definitionId: 'test-only',
        ownerTeamId: 'a',
        acquiredTurn: 0,
        remainingUses: 2,
      );
      final result = AbilityService(testRegistry(uses: 2)).use(
        teams: [
          team('a', inventory: [multiple]),
          team('b'),
        ],
        ownerTeamId: 'a',
        cardId: 'owned',
        targetTeamId: 'b',
        window: AbilityWindow.beforeScoring,
      );
      expect(result.teams.first.inventory.single.remainingUses, 1);
    });
  });

  group(
    'Configurable ability risk — fixture odds only, no product defaults',
    () {
      test(
        'A win gives the difficulty score and an owned ability together',
        () {
          final engine = RiskEngine(
            policy: RiskPolicy(
              options: [WeightedRiskOption(const AbilityWon('test-only'), 1)],
              scoreFloor: ScoreFloorPolicy.allowNegative,
            ),
            registry: testRegistry(),
            draw: (_) => 0,
          );
          final result = engine.resolve(
            question: seedQuestions.first,
            selectedCategoryIds: scope,
            team: team('a', score: 100),
            cardInstanceId: 'won-card',
            turn: 1,
          );
          expect(result.questionPointsAwarded, 200);
          expect(result.team.score, 300);
          expect(result.team.inventory.single.ownerTeamId, 'a');
          expect(
            () => engine.resolve(
              question: seedQuestions.last,
              selectedCategoryIds: scope,
              team: team('a'),
              cardInstanceId: 'out-of-scope',
              turn: 1,
            ),
            throwsArgumentError,
          );
        },
      );
      for (final penalty in [50, 100, 150]) {
        test('Loss applies exactly $penalty with no question reward', () {
          final engine = RiskEngine(
            policy: RiskPolicy(
              options: [WeightedRiskOption(PointsLost(penalty), 1)],
              scoreFloor: ScoreFloorPolicy.allowNegative,
            ),
            registry: AbilityRegistry(),
            draw: (_) => 0,
          );
          final result = engine.resolve(
            question: seedQuestions.first,
            selectedCategoryIds: scope,
            team: team('a', score: 200),
            cardInstanceId: 'unused',
            turn: 1,
          );
          expect(result.team.score, 200 - penalty);
          expect(result.questionPointsAwarded, 0);
          expect(result.team.inventory, isEmpty);
        });
      }
      test('Score floor is an explicit injected decision', () {
        for (final floor in ScoreFloorPolicy.values) {
          final engine = RiskEngine(
            policy: RiskPolicy(
              options: [WeightedRiskOption(PointsLost(150), 1)],
              scoreFloor: floor,
            ),
            registry: AbilityRegistry(),
            draw: (_) => 0,
          );
          final result = engine.resolve(
            question: seedQuestions.first,
            selectedCategoryIds: scope,
            team: team('a', score: 50),
            cardInstanceId: 'unused',
            turn: 0,
          );
          expect(
            result.team.score,
            floor == ScoreFloorPolicy.clampAtZero ? 0 : -100,
          );
        }
      });
      test(
        'Weighted boundaries are deterministic under an injected source',
        () {
          for (var draw = 0; draw < 5; draw++) {
            final engine = RiskEngine(
              policy: RiskPolicy(
                options: [
                  WeightedRiskOption(PointsLost(50), 2),
                  WeightedRiskOption(PointsLost(150), 3),
                ],
                scoreFloor: ScoreFloorPolicy.allowNegative,
              ),
              registry: AbilityRegistry(),
              draw: (bound) {
                expect(bound, 5);
                return draw;
              },
            );
            final result = engine.resolve(
              question: seedQuestions.first,
              selectedCategoryIds: scope,
              team: team('a', score: 200),
              cardInstanceId: 'unused',
              turn: 0,
            );
            expect((result.outcome as PointsLost).amount, draw < 2 ? 50 : 150);
          }
        },
      );
      test(
        'Invalid penalties, weights, empty policies and unknown rewards fail',
        () {
          expect(() => PointsLost(200), throwsArgumentError);
          expect(
            () => WeightedRiskOption(PointsLost(50), 0),
            throwsArgumentError,
          );
          expect(
            () => RiskPolicy(
              options: [],
              scoreFloor: ScoreFloorPolicy.allowNegative,
            ),
            throwsArgumentError,
          );
          expect(
            () => RiskEngine(
              policy: RiskPolicy(
                options: [WeightedRiskOption(const AbilityWon('unknown'), 1)],
                scoreFloor: ScoreFloorPolicy.allowNegative,
              ),
              registry: AbilityRegistry(),
            ),
            throwsArgumentError,
          );
        },
      );
    },
  );
}
