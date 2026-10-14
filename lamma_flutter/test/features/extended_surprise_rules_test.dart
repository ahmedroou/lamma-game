import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/game_catalog.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/session_save.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/domain/abilities/surprise_session_effects.dart';
import 'package:lamma/features/session/session_view_model.dart';
import '../fixtures/questions.dart';
import 'surprise_rules_test.dart'
    show card, model, openQuestion, restored, specialQuestion;

void settle(SessionViewModel game, String? team) {
  expect(game.showAnswer(), true);
  expect(game.awardAnswer(team), true);
}

void nextQuestion(SessionViewModel game, String category) {
  expect(game.selectCategory(category), true);
  for (var i = 0; i < 3; i++) {
    expect(game.revealCard(i), true);
  }
}

void main() {
  test('Current catalog has 28 categories and configured new bank targets', () {
    expect(gameCategories, hasLength(28));
  });
  testWidgets(
    'No-opponent card finishes the primary window without choosing an opponent',
    (tester) async {
      final game = model('no_opponent');
      addTearDown(game.dispose);
      openQuestion(game);
      expect(game.startOpponentOpportunity(), false);
      await tester.pump(const Duration(seconds: 30));
      expect(game.state.secondsRemaining, 0);
      expect(game.state.opponentTeamId, isNull);
      expect(game.showAnswer(), true);
      expect(game.awardAnswer('b'), false);
      expect(game.awardAnswer(null), true);
    },
  );
  test(
    'Half time and double-or-lose settle correctly and may debit below zero',
    () {
      final half = model('half_time');
      addTearDown(half.dispose);
      openQuestion(half);
      expect(half.state.secondsRemaining, 15);
      final risk = model('double_or_lose', score: 20);
      addTearDown(risk.dispose);
      openQuestion(risk);
      expect(risk.state.availablePoints, 800);
      settle(risk, null);
      expect(risk.state.teams.first.score, -380);
      risk.correctDecision(risk.state.history.single.id, 'a');
      expect(risk.state.teams.first.score, 820);
    },
  );
  test('Opponent bonus is awarded only to a correct other team', () {
    var game = model('opponent_bonus_100');
    openQuestion(game);
    game.startOpponentOpportunity();
    expect(game.state.availablePoints, 500);
    game = restored(game, seconds: 0);
    addTearDown(game.dispose);
    game.resume();
    settle(game, 'b');
    expect(game.state.teams.first.score, 300);
    expect(game.state.teams.last.score, 500);
  });
  for (final name in [
    'answerer_youngest',
    'answerer_tallest',
    'answerer_shortest',
    'answerer_oldest',
    'answerer_middle_age',
    'pick_one_answerer',
    'opponent_picks_answerer',
  ]) {
    test(
      '$name does not block question revealing and nomination is handled in person',
      () {
        final game = model(name);
        addTearDown(game.dispose);
        game.selectCategory('myths');
        game.revealCard(0);
        expect(game.revealCard(1), true);
        expect(game.revealCard(2), true);
      },
    );
  }
  testWidgets(
    'First spoken answer is immutable and freezes the clock through pause/restore',
    (tester) async {
      var game = model('total_silence');
      openQuestion(game);
      await tester.pump(const Duration(seconds: 4));
      expect(game.canShowAnswer, false);
      expect(game.recordFirstAnswer('إجابة أولى'), true);
      expect(game.recordFirstAnswer('إجابة بديلة'), false);
      await tester.pump(const Duration(seconds: 50));
      expect(game.state.opponentTeamId, isNull);
      expect(game.state.secondsRemaining, 0);
      game = restored(game);
      addTearDown(game.dispose);
      game.resume();
      await tester.pump(const Duration(seconds: 20));
      expect(game.state.opponentTeamId, isNull);
      expect(game.canShowAnswer, true);
      settle(game, 'a');
    },
  );
  testWidgets(
    'Question change is limited to ten active seconds, consumes both shown IDs and keeps remaining time',
    (tester) async {
      final game = model('change_question');
      addTearDown(game.dispose);
      openQuestion(game);
      final original = game.state.question!;
      await tester.pump(const Duration(seconds: 9));
      expect(game.canChangeQuestion, true);
      expect(await game.changeQuestion(), true);
      expect(game.state.question!.id, isNot(original.id));
      expect(game.state.secondsRemaining, 21);
      expect(game.state.seenQuestionIds, contains(original.id));
      expect(game.state.seenQuestionIds, contains(game.state.question!.id));
      expect(game.canChangeQuestion, false);
      game.pause();
      final late = model('change_question');
      addTearDown(late.dispose);
      openQuestion(late);
      await tester.pump(const Duration(seconds: 10));
      expect(late.canChangeQuestion, false);
      expect(await late.changeQuestion(), false);
      late.pause();
    },
  );
  test(
    'Own wager resolves on next own turn, survives restoration, corrects and reopens without duplicate payouts',
    () {
      var game = model('wager_self', score: 100);
      game.selectCategory('myths');
      game.revealCard(0);
      expect(game.commitWager(101), false);
      expect(game.commitWager(50), true);
      expect(game.commitWager(50), false);
      game.revealCard(1);
      game.revealCard(2);
      settle(game, 'a');
      expect(game.state.teams.first.score, 500);
      nextQuestion(game, 'spacetoon');
      settle(game, 'b');
      expect(game.state.teams.first.score, 500);
      game = restored(game);
      addTearDown(game.dispose);
      game.resume();
      nextQuestion(game, 'breaking_news');
      settle(game, 'a');
      expect(game.state.teams.first.score, 750);
      expect(
        SurpriseSessionEffects.entries(game.state.sessionEffects, 'wagers'),
        isEmpty,
      );
      final round = game.state.history.last;
      game.correctDecision(round.id, null);
      expect(game.state.teams.first.score, 450);
      game.undoLastDecision();
      expect(game.state.teams.first.score, 500);
      expect(
        SurpriseSessionEffects.entries(game.state.sessionEffects, 'wagers'),
        hasLength(1),
      );
      game.resume();
      game.awardAnswer('a');
      expect(game.state.teams.first.score, 750);
      expect(game.awardAnswer('a'), false);
    },
  );
  test(
    'Opponent wager ignores current opportunity and settles on target next primary round',
    () {
      final game = model('wager_opponent', score: 100);
      addTearDown(game.dispose);
      game.selectCategory('myths');
      game.revealCard(0);
      expect(game.commitWager(75, targetTeamId: 'a'), false);
      expect(game.commitWager(75, targetTeamId: 'b'), true);
      game.revealCard(1);
      game.revealCard(2);
      settle(game, null);
      expect(game.state.teams.first.score, 100);
      nextQuestion(game, 'spacetoon');
      settle(game, null);
      expect(game.state.teams.first.score, 175);
      game.correctDecision(game.state.history.last.id, 'b');
      expect(game.state.teams.first.score, 25);
      expect(game.state.teams.last.score, 100);
    },
  );
  test(
    'Forced category applies only to target next turn and disappears after settlement',
    () {
      final game = model('choose_opponent_category');
      addTearDown(game.dispose);
      game.selectCategory('myths');
      game.revealCard(0);
      expect(game.assignOpponentCategory('b', 'spacetoon'), true);
      game.revealCard(1);
      game.revealCard(2);
      settle(game, 'a');
      expect(game.forcedCategoryId, 'spacetoon');
      expect(game.selectCategory('how_it_works'), false);
      nextQuestion(game, 'spacetoon');
      settle(game, 'b');
      expect(game.forcedCategoryId, isNull);
    },
  );
  test(
    'Player ban lasts two target turns, affects later nomination, and ends after the second',
    () {
      final pool = [specialQuestion, ...seedQuestions.skip(1).take(5)];
      final game = SessionViewModel(
        config: SessionConfig(
          teams: [
            TeamState(id: 'a', name: 'أ'),
            TeamState(id: 'b', name: 'ب'),
          ],
          categoryIds: pool.map((q) => q.categoryId),
        ),
        questions: LocalQuestionRepository(questions: pool),
        surpriseResolver: (_, _, turn) =>
            card(turn == 0 ? 'ban_player_two_turns' : 'pick_one_answerer'),
      );
      addTearDown(game.dispose);
      game.selectCategory('myths');
      game.revealCard(0);
      expect(game.banOpponentPlayer('b', 'مستبعد'), true);
      game.revealCard(1);
      game.revealCard(2);
      settle(game, 'a');
      for (final category in ['spacetoon', 'breaking_news', 'complete_verse']) {
        game.selectCategory(category);
        game.revealCard(0);
        if (game.state.activeTeam.id == 'b') {
          expect(game.chooseAnswerer('مستبعد'), false);
        }
        expect(game.chooseAnswerer('مجيب متاح'), true);
        game.revealCard(1);
        game.revealCard(2);
        settle(game, game.state.activeTeam.id);
      }
      expect(
        SurpriseSessionEffects.activeBans(
          game.state.sessionEffects,
          game.state.turn,
        ),
        isEmpty,
      );
    },
  );
  test(
    'Paid hint is valid in persisted save and previous save versions remain readable',
    () {
      var game = model('hint_100');
      openQuestion(game);
      expect(game.activateSurprise(), true);
      final raw = game.snapshot().toJson();
      expect(raw['version'], 5);
      for (final version in [1, 2, 3, 4, 5]) {
        expect(
          SessionSave.fromJson(
            jsonDecode(jsonEncode({...raw, 'version': version}))
                as Map<String, dynamic>,
          ).state.hintRevealed,
          true,
        );
      }
      game = restored(game);
      addTearDown(game.dispose);
      game.resume();
      expect(game.state.activeTeam.score, 200);
      expect(game.activateSurprise(), false);
    },
  );
}
