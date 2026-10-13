import '../fixtures/questions.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/session_save.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/features/session/session_view_model.dart';

SessionConfig managementConfig({bool withCard = false}) => SessionConfig(
  teams: [
    TeamState(
      id: 'a',
      name: 'الصقور',
      inventory: withCard
          ? [
              OwnedAbility(
                id: 'owned-1',
                definitionId: 'future-definition',
                ownerTeamId: 'a',
                acquiredTurn: 0,
                remainingUses: 2,
              ),
            ]
          : [],
    ),
    TeamState(id: 'b', name: 'الأبطال'),
    TeamState(id: 'c', name: 'العواصف'),
  ],
  categoryIds: seedQuestions.take(6).map((question) => question.categoryId),
);
SessionViewModel managementModel({bool withCard = false}) => SessionViewModel(
  config: managementConfig(withCard: withCard),
  questions: LocalQuestionRepository(questions: seedQuestions),
);
void completeRound(SessionViewModel vm, String category, String? winner) {
  expect(vm.selectCategory(category), true);
  for (var i = 0; i < 3; i++) {
    expect(vm.revealCard(i), true);
  }
  expect(vm.showAnswer(), true);
  expect(vm.awardAnswer(winner), true);
}

void main() {
  testWidgets(
    'Manual pause blocks all gameplay and resume keeps remaining time',
    (tester) async {
      final vm = managementModel();
      addTearDown(vm.dispose);
      vm.selectCategory('myths');
      for (var i = 0; i < 3; i++) {
        vm.revealCard(i);
      }
      await tester.pump(const Duration(seconds: 4));
      expect(vm.state.secondsRemaining, 26);
      vm.pause();
      await tester.pump(const Duration(seconds: 40));
      expect(vm.state.secondsRemaining, 26);
      expect(vm.showAnswer(), false);
      expect(vm.awardAnswer('a'), false);
      expect(vm.selectCategory('spacetoon'), false);
      expect(vm.resume(), true);
      await tester.pump(const Duration(seconds: 1));
      expect(vm.state.secondsRemaining, 25);
      vm.pause();
      vm.setForeground(false);
      vm.setForeground(true);
      expect(vm.state.pauseReason, PauseReason.manual);
    },
  );
  testWidgets(
    'Cold restoration is paused with exact question, cards, teams and inventory',
    (tester) async {
      final vm = managementModel(withCard: true);
      addTearDown(vm.dispose);
      completeRound(vm, 'myths', 'a');
      vm.selectCategory('spacetoon');
      for (var i = 0; i < 3; i++) {
        vm.revealCard(i);
      }
      await tester.pump(const Duration(seconds: 6));
      final document =
          jsonDecode(jsonEncode(vm.snapshot().toJson()))
              as Map<String, dynamic>;
      final restored = SessionViewModel.restore(SessionSave.fromJson(document));
      addTearDown(restored.dispose);
      expect(restored.state.isPaused, true);
      expect(restored.state.pauseReason, PauseReason.restored);
      expect(restored.state.secondsRemaining, 24);
      expect(restored.state.question!.id, 'spacetoon-1');
      expect(restored.state.revealedCards, 3);
      expect(restored.state.teams.first.score, 200);
      expect(restored.state.activeTeam.id, 'b');
      expect(restored.state.history.length, 1);
      expect(restored.state.teams.first.inventory.single.remainingUses, 2);
      await tester.pump(const Duration(seconds: 8));
      expect(restored.state.secondsRemaining, 24);
      restored.resume();
      await tester.pump(const Duration(seconds: 1));
      expect(restored.state.secondsRemaining, 23);
      restored.pause();
      vm.pause();
    },
  );
  test(
    'Restore before question reveal does not mark it seen or start a timer',
    () {
      final vm = managementModel();
      addTearDown(vm.dispose);
      vm.selectCategory('myths');
      vm.revealCard(0);
      final restored = SessionViewModel.restore(
        SessionSave.fromJson(vm.snapshot().toJson()),
      );
      addTearDown(restored.dispose);
      expect(restored.state.revealedCards, 1);
      expect(restored.state.seenQuestionIds, isEmpty);
      expect(restored.state.secondsRemaining, 30);
    },
  );
  test(
    'Correction transfers only that question score and keeps turn, inventory and other rounds',
    () {
      final vm = managementModel(withCard: true);
      addTearDown(vm.dispose);
      completeRound(vm, 'myths', 'a');
      completeRound(vm, 'spacetoon', 'a');
      final first = vm.state.history.first;
      expect(
        vm.correctDecision(first.id, 'b', expectedCorrectionCount: 0),
        true,
      );
      expect(vm.state.teams.map((team) => team.score), [100, 200, 0]);
      expect(vm.state.turn, 2);
      expect(vm.state.seenQuestionIds.length, 2);
      expect(vm.state.teams.first.inventory.single.id, 'owned-1');
      expect(
        vm.correctDecision(first.id, 'c', expectedCorrectionCount: 0),
        false,
      );
      expect(vm.correctDecision(first.id, null), true);
      expect(vm.state.teams.map((team) => team.score), [100, 0, 0]);
      expect(vm.correctDecision(first.id, null), false);
      expect(vm.state.corrections.length, 2);
      final restored = SessionViewModel.restore(
        SessionSave.fromJson(
          jsonDecode(jsonEncode(vm.snapshot().toJson()))
              as Map<String, dynamic>,
        ),
      );
      addTearDown(restored.dispose);
      expect(restored.state.history.first.correctionCount, 2);
      expect(restored.state.corrections.length, 2);
    },
  );
  test(
    'Undo last judgment keeps an earlier correction and can be awarded once again',
    () {
      final vm = managementModel();
      addTearDown(vm.dispose);
      completeRound(vm, 'myths', 'a');
      completeRound(vm, 'spacetoon', 'a');
      vm.correctDecision(vm.state.history.first.id, 'b');
      expect(vm.undoLastDecision(), true);
      expect(vm.state.teams.map((team) => team.score), [0, 200, 0]);
      expect(vm.state.phase, SessionPhase.answer);
      expect(vm.state.isPaused, true);
      expect(vm.state.history.length, 1);
      expect(vm.state.question!.id, 'spacetoon-1');
      expect(vm.state.activeTeam.id, 'b');
      vm.resume();
      expect(vm.awardAnswer('c'), true);
      expect(vm.awardAnswer('c'), false);
      expect(vm.state.teams.map((team) => team.score), [0, 200, 100]);
      SessionSave.fromJson(vm.snapshot().toJson());
    },
  );
  test('Undo refuses to discard a question already in progress', () {
    final vm = managementModel();
    addTearDown(vm.dispose);
    completeRound(vm, 'myths', 'a');
    vm.selectCategory('spacetoon');
    expect(vm.canUndoLastDecision, false);
    expect(vm.undoLastDecision(), false);
    expect(vm.state.question!.id, 'spacetoon-1');
  });
  test(
    'Early end stores results and exhausted restart preserves progress and cards',
    () {
      final vm = managementModel(withCard: true);
      addTearDown(vm.dispose);
      completeRound(vm, 'myths', 'a');
      vm.selectCategory('spacetoon');
      vm.endSession();
      final restored = SessionViewModel.restore(
        SessionSave.fromJson(vm.snapshot().toJson()),
      );
      addTearDown(restored.dispose);
      expect(restored.state.phase, SessionPhase.results);
      expect(restored.state.endedEarly, true);
      expect(restored.state.isPaused, false);
      expect(restored.state.teams.first.score, 200);
      expect(restored.restart(), false);
      expect(
        restored.state.teams.every(
          (team) =>
              team.id != 'a' || team.score == 200 && team.inventory.isNotEmpty,
        ),
        true,
      );
      expect(restored.state.history.length, 1);
    },
  );
  test(
    'Invalid and future schemas fail clearly instead of partially restoring',
    () {
      final vm = managementModel();
      addTearDown(vm.dispose);
      expect(
        () => SessionSave.fromJson({...vm.snapshot().toJson(), 'version': 999}),
        throwsA(isA<UnsupportedSaveVersion>()),
      );
      final invalid =
          jsonDecode(jsonEncode(vm.snapshot().toJson()))
              as Map<String, dynamic>;
      (invalid['state'] as Map<String, dynamic>)['secondsRemaining'] = -1;
      expect(() => SessionSave.fromJson(invalid), throwsFormatException);
      (invalid['state'] as Map<String, dynamic>)['secondsRemaining'] = 30;
      (invalid['state'] as Map<String, dynamic>)['turn'] = 5;
      expect(() => SessionSave.fromJson(invalid), throwsFormatException);
    },
  );
}
