import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/abilities/surprise_catalog.dart';
import 'package:lamma/domain/models/hint_access.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/session_save.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/features/session/session_view_model.dart';
import '../fixtures/questions.dart';

final specialQuestion = Question(
  id: 'myths-surprise-test',
  categoryId: 'myths',
  text: 'سؤال اختبار تأثير الورقة',
  answer: 'الصحيح',
  hint: 'تلميح متوسط القوة',
  difficulty: QuestionDifficulty.legendary,
  options: [
    for (var i = 0; i < 6; i++)
      QuestionOption(
        id: String.fromCharCode(65 + i),
        text: i == 0 ? 'الصحيح' : 'مشتت $i',
      ),
  ],
  correctOptionId: 'A',
);
SurpriseCard card(String id) =>
    SurpriseCatalog.cards.singleWhere((card) => card.id == id);
SessionViewModel model(String id, {int score = 300, int seed = 8}) {
  final questions = [specialQuestion, ...seedQuestions.skip(1).take(5)];
  return SessionViewModel(
    config: SessionConfig(
      teams: [
        TeamState(id: 'a', name: 'أ', score: score),
        TeamState(id: 'b', name: 'ب'),
      ],
      categoryIds: questions.map((q) => q.categoryId),
    ),
    questions: LocalQuestionRepository(questions: questions),
    random: Random(seed),
    surpriseResolver: (_, _, _) => card(id),
  );
}

void openQuestion(SessionViewModel model) {
  expect(model.selectCategory('myths'), true);
  for (var i = 0; i < 3; i++) {
    expect(model.revealCard(i), true);
  }
}

SessionViewModel restored(SessionViewModel old, {int? seconds}) {
  final save = old.snapshot();
  final encoded = SessionSave(
    id: save.id,
    config: save.config,
    state: save.state.copyWith(secondsRemaining: seconds),
    questions: save.questions,
    createdAt: save.createdAt,
    updatedAt: save.updatedAt,
    revision: save.revision,
  );
  old.dispose();
  final copy = SessionSave.fromJson(
    jsonDecode(jsonEncode(encoded.toJson())) as Map<String, dynamic>,
  );
  return SessionViewModel(
    config: copy.config,
    questions: LocalQuestionRepository(questions: copy.questions),
    restored: copy,
  );
}

void main() {
  testWidgets(
    'Plank continues beyond 30 seconds, pauses, restores and ends into one opponent window',
    (tester) async {
      var game = model('plank_time');
      expect(game.selectCategory('myths'), true);
      game.revealCard(0);
      expect(game.revealCard(1), false);
      expect(game.acceptPlank(), true);
      game.revealCard(1);
      game.revealCard(2);
      expect(game.state.plankRunning, true);
      await tester.pump(const Duration(seconds: 37));
      expect(game.state.plankSeconds, 37);
      expect(game.state.isOpponentWindow, false);
      game.pause();
      await tester.pump(const Duration(seconds: 9));
      expect(game.state.plankSeconds, 37);
      game = restored(game);
      addTearDown(game.dispose);
      expect(game.state.plankSeconds, 37);
      expect(game.state.isPaused, true);
      game.resume();
      await tester.pump(const Duration(seconds: 3));
      expect(game.state.plankSeconds, 40);
      expect(game.finishPlank(), true);
      expect(game.finishPlank(), false);
      expect(game.state.isOpponentWindow, true);
      expect(game.state.secondsRemaining, 7);
      expect(game.state.opponentTeamId, 'b');
      await tester.pump(const Duration(seconds: 7));
      expect(game.state.secondsRemaining, 0);
    },
  );
  testWidgets(
    'Refusing plank deducts once even at insufficient balance and restores normal timer',
    (tester) async {
      var game = model('plank_time', score: 20);
      game.selectCategory('myths');
      game.revealCard(0);
      expect(game.refusePlank(), true);
      expect(game.refusePlank(), false);
      expect(game.state.activeTeam.score, -80);
      expect(game.state.secondsRemaining, 30);
      game = restored(game);
      addTearDown(game.dispose);
      game.resume();
      game.revealCard(1);
      game.revealCard(2);
      expect(game.state.plankRunning, false);
      expect(game.state.activeTeam.score, -80);
      await tester.pump(const Duration(seconds: 3));
      expect(game.state.secondsRemaining, 27);
      game.pause();
    },
  );
  test('Automatic extra time and bonus apply once and survive restoration', () {
    final time = model('extra_time_30');
    addTearDown(time.dispose);
    time.selectCategory('myths');
    time.revealCard(0);
    expect(time.state.secondsRemaining, 60);
    expect(time.revealCard(0), false);
    expect(time.state.secondsRemaining, 60);
    var bonus = model('bonus_20');
    bonus.selectCategory('myths');
    bonus.revealCard(0);
    expect(bonus.state.activeTeam.score, 500);
    bonus = restored(bonus);
    addTearDown(bonus.dispose);
    bonus.resume();
    bonus.revealCard(1);
    bonus.revealCard(2);
    expect(bonus.state.activeTeam.score, 500);
    bonus.showAnswer();
    bonus.awardAnswer('a');
    expect(bonus.state.teams.first.score, 900);
    expect(bonus.state.history.single.scoreDeltas['a'], 600);
    expect(bonus.correctDecision(bonus.state.history.single.id, null), true);
    expect(bonus.state.teams.first.score, 500);
    expect(bonus.undoLastDecision(), true);
    expect(bonus.state.teams.first.score, 500);
  });
  test(
    'Paid hint is explicit, charged once and preserved when correcting judgment',
    () {
      final game = model('hint_50');
      addTearDown(game.dispose);
      openQuestion(game);
      expect(game.state.hintRevealed, false);
      expect(game.state.activeTeam.score, 300);
      expect(game.activateSurprise(), true);
      expect(game.state.activeTeam.score, 250);
      expect(game.state.hintRevealed, true);
      expect(game.activateSurprise(), false);
      game.showAnswer();
      game.awardAnswer('a');
      expect(game.state.teams.first.score, 650);
      expect(game.correctDecision(game.state.history.single.id, null), true);
      expect(game.state.teams.first.score, 250);
      game.undoLastDecision();
      expect(game.state.teams.first.score, 250);
      expect(game.state.hintRevealed, true);
    },
  );
  test(
    'Paid reveal is refused when balance is insufficient, without any debit',
    () {
      final blocked = model('hint_100', score: 20);
      addTearDown(blocked.dispose);
      openQuestion(blocked);
      expect(blocked.canActivateSurprise, false);
      expect(blocked.activateSurprise(), false);
      expect(blocked.state.activeTeam.score, 20);
      final sufficient = model('hint_100', score: 100);
      addTearDown(sufficient.dispose);
      openQuestion(sufficient);
      expect(sufficient.activateSurprise(), true);
      expect(sufficient.state.activeTeam.score, 0);
    },
  );
  test(
    'Double points belong to acting team; opponent receives original amount',
    () {
      final acting = model('double_points');
      addTearDown(acting.dispose);
      openQuestion(acting);
      expect(acting.state.availablePoints, 800);
      acting.showAnswer();
      acting.awardAnswer('a');
      expect(acting.state.teams.first.score, 1100);
      var other = model('double_points');
      openQuestion(other);
      other.startOpponentOpportunity();
      expect(other.state.availablePoints, 400);
      other = restored(other, seconds: 0);
      addTearDown(other.dispose);
      other.resume();
      other.showAnswer();
      other.awardAnswer('b');
      expect(other.state.teams.last.score, 400);
      expect(other.state.history.single.awardedPoints, 400);
    },
  );
  test(
    'Host can award points to any team after answer reveal in active team turn with surprise card',
    () {
      final game = model('double_points');
      addTearDown(game.dispose);
      openQuestion(game);
      expect(game.state.opponentTeamId, isNull);
      game.showAnswer();
      expect(game.awardAnswer('b'), isTrue);
      expect(game.state.teams.last.score, 400);
      expect(game.state.teams.first.score, 300);
    },
  );
  for (final amount in [50, 100, 200]) {
    test(
      'Failure penalty $amount affects only acting team and corrects cleanly',
      () {
        final game = model('failure_$amount');
        addTearDown(game.dispose);
        openQuestion(game);
        game.showAnswer();
        game.awardAnswer(null);
        expect(game.state.teams.first.score, 300 - amount);
        expect(game.state.teams.last.score, 0);
        game.correctDecision(game.state.history.single.id, 'a');
        expect(game.state.teams.first.score, 700);
        game.correctDecision(game.state.history.single.id, null);
        expect(game.state.teams.first.score, 300 - amount);
        game.undoLastDecision();
        expect(game.state.teams.first.score, 300);
      },
    );
  }
  test('Failure penalties may make the balance negative', () {
    final game = model('failure_200', score: 30);
    addTearDown(game.dispose);
    openQuestion(game);
    game.showAnswer();
    game.awardAnswer(null);
    expect(game.state.teams.first.score, -170);
    game.correctDecision(game.state.history.single.id, 'a');
    expect(game.state.teams.first.score, 430);
    game.correctDecision(game.state.history.single.id, null);
    expect(game.state.teams.first.score, -170);
  });
  test(
    'Quarter points require accepting options; opponents keep full value',
    () {
      final game = model('options_quarter');
      addTearDown(game.dispose);
      openQuestion(game);
      expect(game.state.availablePoints, 400);
      expect(game.state.visibleOptions, isEmpty);
      expect(game.activateSurprise(), true);
      expect(game.state.visibleOptions, hasLength(6));
      expect(game.state.availablePoints, 100);
      game.startOpponentOpportunity();
      expect(game.state.availablePoints, 400);
      expect(game.state.visibleOptions, isEmpty);
    },
  );
  test(
    'Guaranteed four include correct answer; random four can exclude it',
    () {
      var excluded = false;
      for (var seed = 0; seed < 30; seed++) {
        final sure = model('options_four_correct', seed: seed);
        openQuestion(sure);
        sure.activateSurprise();
        expect(sure.state.visibleOptions, hasLength(4));
        expect(sure.state.visibleOptions.any((o) => o.id == 'A'), true);
        sure.dispose();
        var random = model('options_four_random', seed: seed);
        openQuestion(random);
        random.activateSurprise();
        final ids = random.state.visibleOptions.map((o) => o.id).toList();
        expect(ids.toSet(), hasLength(4));
        excluded |= !ids.contains('A');
        random = restored(random);
        random.resume();
        expect(random.state.visibleOptions.map((o) => o.id).toList(), ids);
        expect(random.activateSurprise(), false);
        random.dispose();
      }
      expect(excluded, true);
    },
  );
  test(
    '100-point options draw is available for all question point values',
    () {
      expect(
        SurpriseCatalog.eligibleFor(
          specialQuestion,
        ).any((c) => c.id == 'options_100'),
        true,
        reason: 'options_100 is now available across all question point tiers.',
      );
      expect(
        SurpriseCatalog.eligibleFor(
          seedQuestions.first,
        ).any((c) => c.id == 'options_100'),
        false,
        reason: 'Options still require six authored choices.',
      );
      final easy = Question.fromJson({
        ...specialQuestion.toJson(),
        'difficulty': 'medium',
      });
      expect(
        SurpriseCatalog.eligibleFor(easy).any((c) => c.id == 'options_100'),
        true,
      );
      expect(
        SurpriseCatalog.draw(specialQuestion, {'options_100': 1}, Random(1)),
        isNotNull,
      );
    },
  );
}
