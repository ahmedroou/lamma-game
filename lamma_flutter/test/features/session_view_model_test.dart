import '../fixtures/questions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/features/session/session_view_model.dart';

SessionViewModel model({int teamCount = 3}) => SessionViewModel(
  config: SessionConfig(
    teams: List.generate(
      teamCount,
      (i) => TeamState(id: 'team-$i', name: 'فريق $i'),
    ),
    categoryIds: seedQuestions.take(6).map((question) => question.categoryId),
  ),
  questions: LocalQuestionRepository(questions: seedQuestions),
);
void reveal(SessionViewModel model) {
  for (var card = 0; card < 3; card++) {
    expect(model.revealCard(card), true);
  }
}

void main() {
  test(
    'Board is six selected categories plus abilities, disabled until configured',
    () {
      final vm = model();
      addTearDown(vm.dispose);
      expect(vm.config.boardCategoryIds.length, 7);
      expect(vm.abilitiesEnabled, false);
      expect(vm.selectCategory(GameRules.abilitiesCategoryId), false);
      expect(vm.selectCategory('geography'), false);
      expect(vm.selectCategory('unknown'), false);
    },
  );
  test('Round award is once only and turns rotate through all three teams', () {
    final vm = model();
    addTearDown(vm.dispose);
    for (var i = 0; i < 3; i++) {
      final question = seedQuestions[i];
      expect(vm.state.activeTeam.id, 'team-$i');
      expect(vm.selectCategory(question.categoryId), true);
      expect(vm.revealCard(2), false);
      reveal(vm);
      vm.showAnswer();
      expect(vm.awardAnswer('missing'), false);
      expect(vm.awardAnswer('team-$i'), true);
      expect(vm.awardAnswer('team-$i'), false);
      expect(vm.state.teams[i].score, question.points);
    }
    expect(vm.state.activeTeam.id, 'team-0');
    expect(vm.state.seenQuestionIds.length, 3);
  });
  test('Legacy sample match cannot restart with recycled questions', () {
    final vm = model();
    addTearDown(vm.dispose);
    for (final question in seedQuestions.take(6)) {
      expect(vm.selectCategory(question.categoryId), true);
      reveal(vm);
      vm.showAnswer();
      vm.awardAnswer(null);
    }
    expect(vm.state.phase, SessionPhase.results);
    expect(vm.remainingQuestions, isEmpty);
    expect(vm.restart(), false);
    expect(vm.state.phase, SessionPhase.results);
    expect(vm.state.turn, 6);
    expect(vm.state.seenQuestionIds.length, 6);
    expect(
      vm.state.teams.every((team) => team.score == 0 && team.inventory.isEmpty),
      true,
    );
  });
  testWidgets(
    'Timer begins at question reveal, pauses in background, stops at answer',
    (tester) async {
      final vm = model();
      addTearDown(vm.dispose);
      vm.selectCategory('myths');
      vm.revealCard(0);
      vm.revealCard(1);
      await tester.pump(const Duration(seconds: 3));
      expect(vm.state.secondsRemaining, 30);
      vm.revealCard(2);
      await tester.pump(const Duration(seconds: 2));
      expect(vm.state.secondsRemaining, 28);
      vm.setForeground(false);
      await tester.pump(const Duration(seconds: 10));
      expect(vm.state.secondsRemaining, 28);
      vm.setForeground(true);
      await tester.pump(const Duration(seconds: 1));
      expect(vm.state.secondsRemaining, 28);
      expect(vm.state.isPaused, true);
      vm.resume();
      await tester.pump(const Duration(seconds: 1));
      expect(vm.state.secondsRemaining, 27);
      vm.showAnswer();
      await tester.pump(const Duration(seconds: 5));
      expect(vm.state.secondsRemaining, 27);
    },
  );
}
