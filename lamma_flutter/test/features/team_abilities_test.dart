import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/abilities/team_ability_catalog.dart';
import 'package:lamma/domain/models/hint_access.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/question_usage.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/session_save.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/features/session/session_view_model.dart';

const cats = [
  'myths',
  'how_it_works',
  'geography',
  'islamic_history',
  'flags',
  'riddles',
];
List<Question> bank() => [
  for (final c in cats)
    for (var i = 0; i < 16; i++)
      Question(
        id: '$c-$i',
        categoryId: c,
        text: 'سؤال $c $i',
        answer: 'صحيح',
        difficulty: QuestionDifficulty.values[i % 4],
        options: [
          for (var n = 1; n <= 6; n++)
            QuestionOption(id: '$n', text: 'خيار $n'),
        ],
        correctOptionId: '1',
      ),
];
SessionViewModel abilityModel({
  int count = 2,
  bool enabled = true,
  bool stock = false,
  Random? random,
  DateTime Function()? now,
  SurpriseCard? surprise,
}) {
  final config = SessionConfig(
    teams: [
      for (var i = 0; i < count; i++)
        TeamState(
          id: '$i',
          name: 'فريق $i',
          inventory: stock
              ? [
                  for (final d in TeamAbilityCatalog.definitions)
                    OwnedAbility(
                      id: '$i-${d.id}',
                      definitionId: d.id,
                      ownerTeamId: '$i',
                      acquiredTurn: 0,
                      remainingUses: d.usesPerCard,
                    ),
                ]
              : [],
        ),
    ],
    categoryIds: cats,
    abilitiesEnabled: enabled,
  );
  final planned = planMatchQuestions(
    questions: bank(),
    categoryIds: cats.toSet(),
    usage: QuestionUsage(),
    includeAbilities: enabled,
    random: Random(2),
  );
  final vm = SessionViewModel(
    config: config,
    questions: LocalQuestionRepository(questions: planned),
    random: random,
    now: now,
    surpriseResolver: surprise == null ? null : (_, _, _) => surprise,
  );
  addTearDown(vm.dispose);
  return vm;
}

void reveal(SessionViewModel vm) {
  for (var i = 0; i < 3; i++) {
    expect(vm.revealCard(i), isTrue);
  }
}

void finish(SessionViewModel vm, {String? winner}) {
  reveal(vm);
  expect(vm.showAnswer(), isTrue);
  expect(vm.awardAnswer(winner), isTrue);
}

OwnedAbility owned(SessionViewModel vm, String owner, String type) => vm
    .state
    .teams
    .firstWhere((t) => t.id == owner)
    .inventory
    .firstWhere((c) => c.definitionId == type);
void use(
  SessionViewModel vm,
  String type, {
  String owner = '0',
  String? target,
}) => vm.useAbility(
  ownerTeamId: owner,
  cardId: owned(vm, owner, type).id,
  targetTeamId: target,
);
SessionSave roundTrip(SessionViewModel vm) => SessionSave.fromJson(
  jsonDecode(jsonEncode(vm.snapshot().toJson())) as Map<String, dynamic>,
);

class FixedDice implements Random {
  FixedDice(this.face);
  final int face;
  @override
  int nextInt(int max) => max == 6 ? face - 1 : 0;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

void main() {
  test(
    'Three manual bans spend three charges even when targeting the same opposing team',
    () {
      final vm = abilityModel(count: 3, stock: true);
      vm.selectCategory('myths');
      reveal(vm);
      for (var i = 0; i < 3; i++) {
        use(vm, TeamAbilityCatalog.banPlayer, target: '1');
      }
      expect(
        vm.state.activeTeam.inventory.any(
          (c) => c.definitionId == TeamAbilityCatalog.banPlayer,
        ),
        isFalse,
      );
      expect(vm.state.roundData['abilityPlayerBans'], hasLength(3));
      expect(vm.state.roundData['abilityUseLog'], hasLength(3));
    },
  );
  test(
    'Older backup of the last committed ability reveal cannot strand the exhausted board',
    () {
      final vm = abilityModel();
      for (var i = 0; i < 3; i++) {
        vm.selectCategory(GameRules.abilitiesCategoryId);
        finish(vm);
        vm.selectCategory(
          cats.firstWhere((c) => vm.remainingForCategory(c) > 0),
        );
        finish(vm);
      }
      while (cats.any((c) => vm.remainingForCategory(c) > 0)) {
        vm.selectCategory(
          cats.firstWhere((c) => vm.remainingForCategory(c) > 0),
        );
        finish(vm);
      }
      for (var i = 0; i < 2; i++) {
        vm.selectCategory(GameRules.abilitiesCategoryId);
        finish(vm);
      }
      vm.selectCategory(GameRules.abilitiesCategoryId);
      final pending = vm.state.question!;
      final save = roundTrip(vm);
      final usage = QuestionUsage();
      for (final q in save.questions.where(
        (q) => save.state.seenQuestionIds.contains(q.id),
      )) {
        usage.mark(q);
      }
      usage.mark(pending);
      final restored = SessionViewModel.restore(save, usage: usage);
      addTearDown(restored.dispose);
      expect(restored.state.phase, SessionPhase.results);
      expect(restored.state.history, hasLength(35));
      expect(restored.state.seenQuestionIds, contains(pending.id));
    },
  );
  test(
    'Activating Google between ticks preserves the original question deadline',
    () {
      var now = DateTime.utc(2026, 10, 13);
      final vm = abilityModel(stock: true, now: () => now);
      vm.selectCategory('myths');
      reveal(vm);
      now = now.add(const Duration(milliseconds: 900));
      use(vm, TeamAbilityCatalog.google);
      vm.finishGoogleLaunch(true);
      expect(
        DateTime.parse(vm.state.roundData['searchWindowDeadline'] as String),
        DateTime.utc(2026, 10, 13).add(const Duration(seconds: 30)),
      );
      now = DateTime.utc(2026, 10, 13).add(const Duration(seconds: 30));
      vm.syncSearchClock();
      use(vm, TeamAbilityCatalog.google, owner: '1');
      expect(vm.googleSecondsLeft, 7);
      vm.finishGoogleLaunch(true);
    },
  );
  test(
    'Paid opening choices cannot charge again after an ability reveals all options',
    () {
      final vm = abilityModel(
        stock: true,
        surprise: SurpriseCard(
          id: 'choices',
          text: 'خيارات',
          effect: SurpriseEffect.options,
          price: 100,
        ),
      );
      vm.selectCategory('myths');
      reveal(vm);
      use(vm, TeamAbilityCatalog.options);
      expect(vm.activateSurprise(), isFalse);
      expect(vm.state.activeTeam.score, 0);
    },
  );
  test(
    'Google allows twenty seconds during plank without stopping the count-up clock',
    () {
      var now = DateTime.utc(2026, 10, 13);
      final vm = abilityModel(
        stock: true,
        now: () => now,
        surprise: SurpriseCard(
          id: 'plank',
          text: 'بلانك',
          effect: SurpriseEffect.plank,
        ),
      );
      vm.selectCategory('myths');
      vm.revealCard(0);
      vm.acceptPlank();
      vm.revealCard(1);
      vm.revealCard(2);
      use(vm, TeamAbilityCatalog.google);
      vm.finishGoogleLaunch(true);
      expect(vm.googleSecondsLeft, 20);
      now = now.add(const Duration(seconds: 12));
      vm.syncSearchClock();
      expect(vm.state.plankSeconds, 12);
      expect(vm.googleSecondsLeft, 8);
      now = now.add(const Duration(seconds: 13));
      vm.syncSearchClock();
      expect(vm.state.plankSeconds, 25);
      expect(vm.googleSecondsLeft, 0);
      expect(vm.finishPlank(), isTrue);
      expect(vm.state.secondsRemaining, 7);
      expect(vm.state.isOpponentWindow, isTrue);
    },
  );
  test(
    'Cold restore consumes an uncertain pending launch without permanently locking controls',
    () {
      var now = DateTime.utc(2026, 10, 13);
      final vm = abilityModel(stock: true, now: () => now);
      vm.selectCategory('myths');
      reveal(vm);
      use(vm, TeamAbilityCatalog.google);
      final save = roundTrip(vm);
      now = now.add(const Duration(seconds: 2));
      final restored = SessionViewModel(
        config: save.config,
        questions: LocalQuestionRepository(questions: save.questions),
        restored: save,
        now: () => now,
      );
      addTearDown(restored.dispose);
      expect(restored.state.roundData['googlePendingCard'], isNull);
      expect(restored.state.secondsRemaining, 28);
      expect(
        restored.state.teams.first.inventory.any(
          (c) => c.definitionId == TeamAbilityCatalog.google,
        ),
        isFalse,
      );
      restored.resume();
      expect(restored.canShowAnswer, isTrue);
    },
  );
  for (final count in [2, 3]) {
    test(
      'Exhausted quota cannot strand the final ability turns with $count teams',
      () {
        final vm = abilityModel(count: count);
        for (var round = 0; round < vm.config.abilityChoicesPerTeam; round++) {
          expect(vm.state.activeTeam.id, '0');
          expect(vm.selectCategory(GameRules.abilitiesCategoryId), isTrue);
          finish(vm);
          for (var t = 1; t < count; t++) {
            vm.selectCategory(
              cats.firstWhere((c) => vm.remainingForCategory(c) > 0),
            );
            finish(vm);
          }
        }
        while (cats.any((c) => vm.remainingForCategory(c) > 0)) {
          vm.selectCategory(
            cats.firstWhere((c) => vm.remainingForCategory(c) > 0),
          );
          finish(vm);
        }
        while (vm.state.phase != SessionPhase.results) {
          expect(vm.state.activeTeam.id, isNot('0'));
          expect(vm.abilityChoicesLeft(vm.state.activeTeam.id), greaterThan(0));
          expect(vm.selectCategory(GameRules.abilitiesCategoryId), isTrue);
          finish(vm);
        }
        expect(vm.state.history, hasLength(36));
        expect(vm.state.abilitySelections.values.reduce((a, b) => a + b), 6);
      },
    );
  }
  test(
    'Optional mode plans thirty or thirty-six disjoint questions, hard ability pool',
    () {
      for (final enabled in [false, true]) {
        final vm = abilityModel(enabled: enabled);
        expect(vm.snapshot().questions.length, enabled ? 36 : 30);
        expect(vm.config.boardCategoryIds.length, enabled ? 7 : 6);
        expect(vm.snapshot().abilityQuestionIds.length, enabled ? 6 : 0);
        for (final c in cats) {
          expect(vm.remainingForCategory(c), 5);
        }
        expect(vm.selectCategory(GameRules.abilitiesCategoryId), enabled);
        if (enabled) {
          expect(vm.state.question!.points, greaterThanOrEqualTo(300));
        }
      }
    },
  );
  test(
    'Reserve rare hard stock before normal allocation and report a hard-stock shortage',
    () {
      final source = [
        for (final c in cats)
          for (var i = 0; i < 6; i++)
            Question(
              id: '$c-$i',
              categoryId: c,
              text: 'q',
              answer: 'a',
              difficulty: i == 5
                  ? QuestionDifficulty.hard
                  : QuestionDifficulty.easy,
            ),
      ];
      final planned = planMatchQuestions(
        questions: source,
        categoryIds: cats.toSet(),
        usage: QuestionUsage(),
        includeAbilities: true,
        random: Random(5),
      );
      expect(planned.skip(30).every((q) => q.points == 300), isTrue);
      expect(planned.take(30).every((q) => q.points == 100), isTrue);
      expect(
        () => planMatchQuestions(
          questions: source.where((q) => q.id != 'myths-5'),
          categoryIds: cats.toSet(),
          usage: QuestionUsage(),
          includeAbilities: true,
        ),
        throwsA(isA<InsufficientQuestions>()),
      );
    },
  );
  for (final count in [2, 3]) {
    test(
      '$count teams enforce individual quotas and persist them without resetting on undo',
      () {
        final vm = abilityModel(count: count);
        for (var i = 0; i < 6; i++) {
          expect(vm.selectCategory(GameRules.abilitiesCategoryId), isTrue);
          finish(vm);
        }
        expect(vm.remainingForCategory(GameRules.abilitiesCategoryId), 0);
        for (final t in vm.state.teams) {
          expect(vm.abilityChoicesLeft(t.id), 0);
        }
        expect(vm.selectCategory(GameRules.abilitiesCategoryId), isFalse);
        final restored = SessionViewModel.restore(roundTrip(vm));
        addTearDown(restored.dispose);
        for (final t in restored.state.teams) {
          expect(restored.abilityChoicesLeft(t.id), 0);
        }
        expect(vm.undoLastDecision(), isTrue);
        vm.resume();
        expect(vm.awardAnswer(null), isTrue);
        expect(vm.state.abilitySelections, restored.state.abilitySelections);
      },
    );
  }
  test(
    'Primary correct earns one random card; correction and undo preserve its draw',
    () {
      final vm = abilityModel();
      vm.selectCategory(GameRules.abilitiesCategoryId);
      finish(vm, winner: '0');
      final card = vm.state.teams.first.inventory.single;
      final record = vm.state.history.single;
      expect(vm.state.teams.first.score, record.question.points);
      expect(vm.awardAnswer('0'), isFalse);
      expect(vm.correctDecision(record.id, null), isTrue);
      expect(vm.state.teams.first.inventory, isEmpty);
      expect(vm.correctDecision(record.id, '0'), isTrue);
      expect(
        vm.state.teams.first.inventory.single.definitionId,
        card.definitionId,
      );
      expect(vm.undoLastDecision(), isTrue);
      expect(vm.state.teams.first.inventory, isEmpty);
      vm.resume();
      expect(vm.awardAnswer('0'), isTrue);
      expect(vm.state.teams.first.inventory.single.id, card.id);
      expect(
        vm.state.teams.first.inventory.single.definitionId,
        card.definitionId,
      );
    },
  );
  testWidgets(
    'Opponent earns normal points only and never the ability reward',
    (tester) async {
      final vm = abilityModel();
      vm.selectCategory(GameRules.abilitiesCategoryId);
      reveal(vm);
      vm.startOpponentOpportunity();
      await tester.pump(const Duration(seconds: 7));
      expect(vm.showAnswer(), isTrue);
      expect(vm.awardAnswer('1'), isTrue);
      expect(
        vm.state.teams.last.score,
        vm.state.history.single.question.points,
      );
      expect(vm.state.teams.every((t) => t.inventory.isEmpty), isTrue);
    },
  );
  test(
    'Double before reveal stacks with opening double, binds to owner and survives correction',
    () {
      final vm = abilityModel(
        stock: true,
        surprise: SurpriseCard(
          id: 'double',
          text: 'دبل',
          effect: SurpriseEffect.doublePoints,
        ),
      );
      vm.selectCategory('myths');
      use(vm, TeamAbilityCatalog.doublePoints);
      reveal(vm);
      expect(vm.pointsForTeam('0'), vm.state.question!.points * 4);
      expect(vm.pointsForTeam('1'), vm.state.question!.points);
      expect(() => use(vm, TeamAbilityCatalog.doublePoints), throwsStateError);
      vm.showAnswer();
      vm.awardAnswer('0');
      final record = vm.state.history.single;
      expect(vm.correctDecision(record.id, null), isTrue);
      expect(vm.state.teams.first.score, 0);
      expect(vm.correctDecision(record.id, '0'), isTrue);
      expect(vm.state.teams.first.score, record.question.points * 4);
      expect(owned(vm, '0', TeamAbilityCatalog.doublePoints).remainingUses, 1);
    },
  );
  testWidgets(
    'Ban works for own/opponent questions only in first fifteen active seconds',
    (tester) async {
      final vm = abilityModel(stock: true);
      vm.selectCategory('myths');
      reveal(vm);
      use(vm, TeamAbilityCatalog.banPlayer, target: '1');
      use(vm, TeamAbilityCatalog.banPlayer, owner: '1', target: '0');
      expect(owned(vm, '0', TeamAbilityCatalog.banPlayer).remainingUses, 2);
      expect(vm.state.roundData['abilityPlayerBans'], hasLength(2));
      await tester.pump(const Duration(seconds: 15));
      expect(
        vm.abilityUnavailableReason(
          '0',
          owned(vm, '0', TeamAbilityCatalog.banPlayer),
        ),
        isNotNull,
      );
      expect(
        () => use(vm, TeamAbilityCatalog.banPlayer, target: '1'),
        throwsStateError,
      );
      expect(owned(vm, '0', TeamAbilityCatalog.banPlayer).remainingUses, 2);
      vm.pause();
    },
  );
  testWidgets(
    'No-opponent card stops all secondary opportunities and normal timeout remains',
    (tester) async {
      final vm = abilityModel(count: 3, stock: true);
      vm.selectCategory('myths');
      use(vm, TeamAbilityCatalog.noOpponent);
      reveal(vm);
      await tester.pump(const Duration(seconds: 30));
      expect(vm.state.secondsRemaining, 0);
      expect(vm.startOpponentOpportunity(), isFalse);
      expect(vm.state.opponentTeamId, isNull);
      expect(vm.showAnswer(), isTrue);
      expect(vm.awardAnswer('1'), isFalse);
    },
  );
  for (var face = 1; face <= 6; face++) {
    test(
      'Dice $face includes correct answer, preserves sample and charges each requested reroll',
      () {
        final vm = abilityModel(stock: true, random: FixedDice(face));
        vm.selectCategory('myths');
        reveal(vm);
        use(vm, TeamAbilityCatalog.dice);
        expect(vm.state.visibleOptions, hasLength(face));
        expect(
          vm.state.visibleOptions.map((o) => o.id),
          contains(vm.state.question!.correctOptionId),
        );
        final ids = vm.state.visibleOptions.map((o) => o.id).toList();
        final restored = SessionViewModel.restore(roundTrip(vm));
        addTearDown(restored.dispose);
        expect(restored.state.visibleOptions.map((o) => o.id), ids);
        if (face == 6) {
          expect(() => use(vm, TeamAbilityCatalog.dice), throwsStateError);
          expect(owned(vm, '0', TeamAbilityCatalog.dice).remainingUses, 1);
        } else {
          use(vm, TeamAbilityCatalog.dice);
          expect(
            vm.state.activeTeam.inventory.any(
              (card) => card.definitionId == TeamAbilityCatalog.dice,
            ),
            isFalse,
          );
          expect(vm.state.roundData['abilityUseLog'], hasLength(2));
          expect(vm.state.visibleOptions, hasLength(face));
        }
      },
    );
  }
  test(
    'Options require recipient turn; full reveal cannot be charged again',
    () {
      final vm = abilityModel(stock: true);
      vm.selectCategory('myths');
      reveal(vm);
      expect(
        () => use(vm, TeamAbilityCatalog.options, owner: '1'),
        throwsStateError,
      );
      use(vm, TeamAbilityCatalog.options);
      expect(vm.state.visibleOptions, hasLength(6));
      expect(() => use(vm, TeamAbilityCatalog.options), throwsStateError);
      expect(owned(vm, '0', TeamAbilityCatalog.options).remainingUses, 1);
      vm.startOpponentOpportunity();
      expect(vm.state.visibleOptions, isEmpty);
      use(vm, TeamAbilityCatalog.options, owner: '1');
      expect(vm.state.visibleOptions, hasLength(6));
    },
  );
  test(
    'Google clock continues in background, gives twenty from existing time and expires opponent too',
    () {
      var now = DateTime.utc(2026, 10, 13);
      final vm = abilityModel(stock: true, now: () => now);
      vm.selectCategory('myths');
      reveal(vm);
      use(vm, TeamAbilityCatalog.google);
      vm.finishGoogleLaunch(true);
      expect(vm.state.secondsRemaining, 30);
      expect(vm.googleSecondsLeft, 20);
      expect(
        vm.state.teams.first.inventory.any(
          (c) => c.definitionId == TeamAbilityCatalog.google,
        ),
        isFalse,
      );
      vm.setForeground(false);
      expect(vm.state.isPaused, isFalse);
      now = now.add(const Duration(seconds: 21));
      vm.syncSearchClock();
      expect(vm.googleSecondsLeft, 0);
      expect(vm.state.secondsRemaining, 9);
      now = now.add(const Duration(seconds: 12));
      vm.syncSearchClock();
      expect(vm.state.isOpponentWindow, isTrue);
      expect(vm.state.secondsRemaining, 4);
      now = now.add(const Duration(seconds: 20));
      vm.syncSearchClock();
      expect(vm.state.secondsRemaining, 0);
      expect(vm.canShowAnswer, isTrue);
    },
  );
  test(
    'Google in seven-second window gets only remaining seven and refunds failed launch once',
    () {
      final vm = abilityModel(stock: true);
      vm.selectCategory('myths');
      reveal(vm);
      vm.startOpponentOpportunity();
      use(vm, TeamAbilityCatalog.google, owner: '1');
      expect(vm.googleSecondsLeft, 7);
      expect(vm.state.secondsRemaining, 7);
      vm.finishGoogleLaunch(false);
      vm.finishGoogleLaunch(false);
      expect(owned(vm, '1', TeamAbilityCatalog.google).remainingUses, 1);
      expect(vm.state.abilityRevision, 0);
    },
  );
  test(
    'Saved Google absolute deadline reconciles time spent while closed before paused restore',
    () {
      var now = DateTime.utc(2026, 10, 13);
      final vm = abilityModel(stock: true, now: () => now);
      vm.selectCategory('myths');
      reveal(vm);
      use(vm, TeamAbilityCatalog.google);
      vm.finishGoogleLaunch(true);
      final save = roundTrip(vm);
      now = now.add(const Duration(seconds: 34));
      final restored = SessionViewModel(
        config: save.config,
        questions: LocalQuestionRepository(questions: save.questions),
        restored: save,
        now: () => now,
      );
      addTearDown(restored.dispose);
      expect(restored.state.isPaused, isTrue);
      expect(restored.state.isOpponentWindow, isTrue);
      expect(restored.state.secondsRemaining, 3);
    },
  );
  test('Consumed card stays consumed through save; last charge removes it', () {
    final vm = abilityModel(stock: true);
    vm.selectCategory('myths');
    use(vm, TeamAbilityCatalog.doublePoints);
    finish(vm, winner: '0');
    vm.selectCategory('how_it_works');
    finish(vm);
    vm.selectCategory('geography');
    use(vm, TeamAbilityCatalog.doublePoints);
    expect(
      vm.state.teams.first.inventory.any(
        (c) => c.definitionId == TeamAbilityCatalog.doublePoints,
      ),
      isFalse,
    );
    final restored = SessionViewModel.restore(roundTrip(vm));
    addTearDown(restored.dispose);
    expect(
      restored.state.teams.first.inventory.any(
        (c) => c.definitionId == TeamAbilityCatalog.doublePoints,
      ),
      isFalse,
    );
  });
}
