import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_controller.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/data/repositories/local_game_repository.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/question_usage.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/session_save.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/features/session/session_screen.dart';
import 'package:lamma/features/session/session_view_model.dart';
import '../app_test.dart' show snapshot;
import '../fixtures/questions.dart';
import 'session_management_test.dart' show managementConfig, completeRound;

class _FirstRandom implements Random {
  int calls = 0;
  @override
  int nextInt(int max) {
    calls++;
    return 0;
  }

  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

SessionViewModel timedModel({
  List<int> scores = const [200, 100, 0],
  Random? random,
}) => SessionViewModel(
  config: SessionConfig(
    teams: [
      for (var i = 0; i < scores.length; i++)
        TeamState(id: 't$i', name: 'فريق $i', score: scores[i]),
    ],
    categoryIds: managementConfig().categoryIds,
  ),
  questions: LocalQuestionRepository(questions: completeQuestions),
  random: random,
);

void startQuestion(SessionViewModel vm) {
  expect(vm.selectCategory('myths'), true);
  for (var i = 0; i < 3; i++) {
    expect(vm.revealCard(i), true);
  }
}

void main() {
  setUpAll(() async {
    await (FontLoader('Tajawal')
          ..addFont(rootBundle.load('assets/fonts/Tajawal-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Tajawal-Bold.ttf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  test(
    'Planner reserves exactly five per category and five disjoint ability questions',
    () {
      final usage = QuestionUsage();
      final plan = planMatchQuestions(
        questions: completeQuestions,
        categoryIds: managementConfig().categoryIds,
        usage: usage,
        includeAbilities: true,
      );
      expect(plan.length, 35);
      expect(plan.map((q) => q.id).toSet().length, 35);
      for (final id in managementConfig().categoryIds) {
        expect(plan.take(30).where((q) => q.categoryId == id).length, 5);
      }
      expect(
        plan
            .skip(30)
            .every(
              (q) => managementConfig().categoryIds.contains(q.categoryId),
            ),
        true,
      );
    },
  );
  test(
    'Viewed content stays excluded even under a different ID or category',
    () {
      final usage = QuestionUsage()..mark(seedQuestions.first);
      final moved = Question(
        id: 'renamed',
        categoryId: 'maps',
        text: seedQuestions.first.text,
        answer: seedQuestions.first.answer,
        difficulty: QuestionDifficulty.easy,
      );
      expect(usage.contains(moved), true);
      expect(
        () => planMatchQuestions(
          questions: seedQuestions,
          categoryIds: managementConfig().categoryIds,
          usage: usage,
        ),
        throwsA(isA<InsufficientQuestions>()),
      );
    },
  );
  test('Five-question sections finish at 30, without consuming extras', () {
    final vm = timedModel();
    addTearDown(vm.dispose);
    for (final id in vm.config.categoryIds) {
      expect(vm.remainingForCategory(id), 5);
      for (var i = 0; i < 5; i++) {
        completeRound(vm, id, null);
        expect(vm.remainingForCategory(id), 4 - i);
      }
      expect(vm.selectCategory(id), false);
    }
    expect(vm.state.history.length, 30);
    expect(vm.state.phase, SessionPhase.results);
    final used = vm.state.seenQuestionIds;
    expect(vm.restart(), true);
    startQuestion(vm);
    expect(used.contains(vm.state.question!.id), false);
  });
  testWidgets(
    'Three teams: lower-scoring opponent gets seven seconds, then adjudication',
    (tester) async {
      final random = _FirstRandom();
      final vm = timedModel(random: random);
      addTearDown(vm.dispose);
      startQuestion(vm);
      await tester.pump(const Duration(seconds: 30));
      expect(vm.state.activeTeam.id, 't0');
      expect(vm.state.answeringTeam.id, 't2');
      expect(vm.state.secondsRemaining, 7);
      expect(vm.state.isOpponentWindow, true);
      expect(random.calls, 0);
      expect(vm.showAnswer(), false);
      expect(vm.startOpponentOpportunity(), false);
      await tester.pump(const Duration(seconds: 7));
      expect(vm.state.secondsRemaining, 0);
      expect(vm.showAnswer(), true);
      expect(vm.awardAnswer('t0'), false);
      expect(vm.awardAnswer('t1'), false);
      expect(vm.awardAnswer('t2'), true);
      expect(vm.state.teams.last.score, 200);
      final record = vm.state.history.single;
      expect(vm.correctDecision(record.id, 't1'), false);
      expect(vm.undoLastDecision(), true);
      vm.resume();
      expect(vm.awardAnswer('t0'), false);
      expect(vm.awardAnswer(null), true);
    },
  );
  testWidgets(
    'Tie is drawn once and the selected opponent and time survive restoration',
    (tester) async {
      final random = _FirstRandom();
      final vm = timedModel(scores: [900, 100, 100], random: random);
      addTearDown(vm.dispose);
      startQuestion(vm);
      await tester.pump(const Duration(seconds: 32));
      expect(random.calls, 1);
      expect(vm.state.opponentTeamId, 't1');
      expect(vm.state.opponentSelectedByLot, true);
      expect(vm.state.secondsRemaining, 5);
      vm.pause();
      await tester.pump(const Duration(seconds: 20));
      expect(vm.state.secondsRemaining, 5);
      vm.resume();
      expect(random.calls, 1);
      final restored = SessionViewModel.restore(
        SessionSave.fromJson(
          jsonDecode(jsonEncode(vm.snapshot().toJson()))
              as Map<String, dynamic>,
        ),
      );
      addTearDown(restored.dispose);
      vm.pause();
      expect(restored.state.isPaused, true);
      expect(restored.state.opponentTeamId, 't1');
      expect(restored.state.secondsRemaining, 5);
      restored.resume();
      await tester.pump(const Duration(seconds: 5));
      expect(restored.state.opponentTeamId, 't1');
      expect(restored.state.secondsRemaining, 0);
      expect(restored.showAnswer(), true);
    },
  );
  testWidgets(
    'Two teams: explicit wrong answer gives the other team one window',
    (tester) async {
      final vm = timedModel(scores: [0, 500]);
      addTearDown(vm.dispose);
      startQuestion(vm);
      expect(vm.startOpponentOpportunity(), true);
      expect(vm.state.answeringTeam.id, 't1');
      expect(vm.showAnswer(), false);
      await tester.pump(const Duration(seconds: 7));
      expect(vm.showAnswer(), true);
      expect(vm.awardAnswer(null), true);
      expect(vm.state.teams.map((t) => t.score), [0, 500]);
      expect(vm.state.activeTeam.id, 't1');
    },
  );
  test(
    'Failed reveal remains hidden and unconsumed; repeated clicks cannot bypass the write',
    () async {
      final gate = Completer<void>();
      var fail = true;
      final usage = QuestionUsage();
      final vm = SessionViewModel(
        config: managementConfig(),
        questions: LocalQuestionRepository(questions: completeQuestions),
        usage: usage,
        commitReveal: (_, q) async {
          if (fail) {
            await gate.future;
            throw StateError('disk full');
          }
        },
      );
      addTearDown(vm.dispose);
      vm.selectCategory('myths');
      vm.revealCard(0);
      vm.revealCard(1);
      final pending = vm.revealQuestion();
      expect(vm.state.revealedCards, 2);
      expect(vm.revealCard(2), false);
      expect(vm.showAnswer(), false);
      expect(await vm.revealQuestion(), false);
      vm.pause();
      gate.complete();
      expect(await pending, false);
      expect(usage.contains(vm.state.question!), false);
      expect(vm.state.seenQuestionIds, isEmpty);
      expect(vm.revealError, isNotNull);
      vm.resume();
      fail = false;
      expect(await vm.revealQuestion(), true);
      expect(usage.contains(vm.state.question!), true);
    },
  );
  test(
    'Controller retains device history when a new match replaces the previous one',
    () async {
      final repo = MemoryGameRepository();
      final app = AppController(
        repo,
        questions: LocalQuestionRepository(questions: completeQuestions),
      );
      await app.initialize();
      final first = await app.startSession(managementConfig());
      first.selectCategory('myths');
      first.revealCard(0);
      first.revealCard(1);
      final usedId = first.state.question!.id;
      expect(await first.revealQuestion(), true);
      await app.flush();
      final second = await app.startSession(managementConfig());
      expect(second.snapshot().questions.any((q) => q.id == usedId), false);
      expect(
        repo.usage.contains(
          first.snapshot().questions.firstWhere((q) => q.id == usedId),
        ),
        true,
      );
      app.dispose();
    },
  );
  for (final size in [const Size(390, 844), const Size(844, 390)]) {
    testWidgets('Opponent window has no visible answer and fits $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final vm = timedModel();
      addTearDown(vm.dispose);
      startQuestion(vm);
      vm.startOpponentOpportunity();
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: RepaintBoundary(
              key: key,
              child: SessionScreen(config: vm.config, model: vm),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.text(seedQuestions.first.answer), findsNothing);
      expect(find.text('فرصة فريق 2 وحده'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('question-points')),
          matching: find.text('${vm.state.availablePoints} نقطة'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await snapshot(
        tester,
        key,
        'opponent-${size.width == 390 ? 'portrait' : 'landscape'}',
      );
      await tester.pumpWidget(const SizedBox());
    });
  }
}
