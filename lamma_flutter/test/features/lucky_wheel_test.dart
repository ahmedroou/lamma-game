import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/abilities/surprise_catalog.dart';
import 'package:lamma/domain/models/hint_access.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/question_usage.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/features/session/lucky_wheel_dialog.dart';
import 'package:lamma/features/session/session_view_model.dart';

void main() {
  const cats = [
    'general_knowledge',
    'history',
    'science',
    'geography',
    'sports',
    'riddles',
  ];

  List<Question> bank() => [
    for (final c in cats)
      for (var i = 0; i < 16; i++)
        Question(
          id: '$c-$i',
          categoryId: c,
          difficulty: QuestionDifficulty.values[i % 4],
          text: 'سؤال $c $i',
          answer: 'إجابة $c $i',
          options: const [],
        ),
  ];

  SessionViewModel createModel({SurpriseCard? forcedSurprise}) {
    final config = SessionConfig(
      categoryIds: cats,
      teams: [
        TeamState(id: 'team-1', name: 'الفريق الأول', score: 500),
        TeamState(id: 'team-2', name: 'الفريق الثاني', score: 300),
      ],
      abilitiesEnabled: false,
    );

    final planned = planMatchQuestions(
      questions: bank(),
      categoryIds: cats.toSet(),
      usage: QuestionUsage(),
      includeAbilities: false,
      random: Random(42),
    );

    final vm = SessionViewModel(
      config: config,
      questions: LocalQuestionRepository(questions: planned),
      openingCardsEnabled: true,
      surpriseResolver: forcedSurprise != null
          ? (_, _, _) => forcedSurprise
          : null,
    );
    addTearDown(vm.dispose);
    return vm;
  }

  final wheelCard = SurpriseCatalog.cards.firstWhere(
    (c) => c.effect == SurpriseEffect.wheelOfFortune,
  );

  test('lucky_wheel surprise card exists in catalog and is eligible', () {
    expect(wheelCard.id, 'lucky_wheel');
    expect(wheelCard.text, 'عجلة الحظ');
    expect(wheelCard.effect, SurpriseEffect.wheelOfFortune);

    final q = bank().first;
    final eligible = SurpriseCatalog.eligibleFor(q);
    expect(eligible.any((c) => c.id == 'lucky_wheel'), isTrue);
  });

  test('Wheel blocks subsequent card reveals until decision is made', () {
    final model = createModel(forcedSurprise: wheelCard);
    model.selectCategory(cats.first);

    expect(model.state.surpriseCard?.effect, SurpriseEffect.wheelOfFortune);
    expect(model.state.revealedCards, 0);

    // Reveal card 0 (the surprise card)
    expect(model.revealCard(0), isTrue);
    expect(model.state.revealedCards, 1);
    expect(model.wheelStatus, 'pending');
    expect(model.canSpinWheel, isTrue);
    expect(model.canSkipWheel, isTrue);

    // Card 1 must be blocked while wheelStatus is pending
    expect(model.revealCard(1), isFalse);
    expect(model.state.revealedCards, 1);
  });

  test('Skipping the wheel unlocks subsequent card reveals', () {
    final model = createModel(forcedSurprise: wheelCard);
    model.selectCategory(cats.first);
    model.revealCard(0);

    expect(model.wheelStatus, 'pending');
    expect(model.skipWheel(), isTrue);
    expect(model.wheelStatus, 'skipped');
    expect(model.canSpinWheel, isFalse);

    // Now card 1 can be revealed
    expect(model.revealCard(1), isTrue);
    expect(model.state.revealedCards, 2);
  });

  test('Positive point outcomes (+100, +200, +400, +600) add points immediately', () {
    for (final outcome in [
      WheelOutcome.plus100,
      WheelOutcome.plus200,
      WheelOutcome.plus400,
      WheelOutcome.plus600,
    ]) {
      final model = createModel(forcedSurprise: wheelCard);
      model.selectCategory(cats.first);
      model.revealCard(0);

      final initialScore = model.state.activeTeam.score;
      expect(model.applyWheelOutcome(outcome), isTrue);

      expect(
        model.state.activeTeam.score,
        initialScore + outcome.pointsDelta,
      );
      expect(model.wheelStatus, 'completed');
      expect(model.wheelOutcome, outcome);

      // Card 1 can now be revealed
      expect(model.revealCard(1), isTrue);
    }
  });

  test('-500 point outcome deducts points immediately', () {
    final model = createModel(forcedSurprise: wheelCard);
    model.selectCategory(cats.first);
    model.revealCard(0);

    final initialScore = model.state.activeTeam.score; // 500
    expect(model.applyWheelOutcome(WheelOutcome.minus500), isTrue);

    expect(model.state.activeTeam.score, initialScore - 500); // 0
    expect(model.wheelStatus, 'completed');
    expect(model.wheelOutcome, WheelOutcome.minus500);
  });

  test('Bankruptcy outcome resets active team score to 0', () {
    final model = createModel(forcedSurprise: wheelCard);
    model.selectCategory(cats.first);
    model.revealCard(0);

    expect(model.state.activeTeam.score, 500);
    expect(model.applyWheelOutcome(WheelOutcome.bankruptcy), isTrue);

    expect(model.state.activeTeam.score, 0);
    expect(model.wheelStatus, 'completed');
    expect(model.wheelOutcome, WheelOutcome.bankruptcy);
  });

  test('Pass turn outcome transfers answering right to the opposing team', () {
    final model = createModel(forcedSurprise: wheelCard);
    model.selectCategory(cats.first);
    model.revealCard(0);

    expect(model.state.activeTeam.id, 'team-1');
    expect(model.applyWheelOutcome(WheelOutcome.passTurn), isTrue);

    expect(model.wheelStatus, 'completed');
    expect(model.state.roundData['wheelTurnPassed'], isTrue);
    expect(model.state.opponentTeamId, 'team-2');
    expect(model.state.answeringTeam.id, 'team-2');

    // Cards 1 and 2 can be revealed
    model.revealCard(1);
    model.revealCard(2);

    // Opponent team can answer and receive the question points
    expect(model.showAnswer(), isTrue);
    final opponentScoreBefore = model.state.teams
        .firstWhere((t) => t.id == 'team-2')
        .score;
    expect(model.awardAnswer('team-2'), isTrue);

    final opponentScoreAfter = model.state.teams
        .firstWhere((t) => t.id == 'team-2')
        .score;
    expect(opponentScoreAfter, greaterThan(opponentScoreBefore));
  });

  testWidgets('LuckyWheelDialog renders correctly and displays wheel canvas', (tester) async {
    final model = createModel(forcedSurprise: wheelCard);
    model.selectCategory(cats.first);
    model.revealCard(0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LuckyWheelDialog(
            model: model,
            initialOutcome: WheelOutcome.plus400,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('عجلة الحظ'), findsOneWidget);
    expect(find.text('لف!'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    // Tap spin
    await tester.tap(find.text('لف!'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Check outcome announcement appears
    expect(find.text('+400 نقطة'), findsOneWidget);
    expect(find.text('اعتماد النتيجة ومتابعة التحدي'), findsOneWidget);

    // Tap confirm button
    await tester.ensureVisible(find.text('اعتماد النتيجة ومتابعة التحدي'));
    await tester.tap(find.text('اعتماد النتيجة ومتابعة التحدي'));
    await tester.pumpAndSettle();

    expect(model.state.activeTeam.score, 500 + 400);
    expect(model.wheelStatus, 'completed');
  });
}
