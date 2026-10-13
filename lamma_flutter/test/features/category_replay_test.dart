import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_controller.dart';
import 'package:lamma/core/app_scope.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/data/repositories/local_game_repository.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/question_usage.dart';
import 'package:lamma/features/session/session_setup.dart';
import '../app_test.dart' show snapshot;
import '../fixtures/questions.dart';
import 'session_management_test.dart' show managementConfig;

final replayCatalog = [
  for (final id in managementConfig().categoryIds)
    ...completeQuestions.where((q) => q.categoryId == id).take(5),
];

class _RenewFailure extends MemoryGameRepository {
  @override
  Future<QuestionUsage> resetCategory(
    String id,
    Iterable<Question> catalog,
  ) async => throw StateError('disk full');
}

Future<AppController> replayApp(MemoryGameRepository repository) async {
  final app = AppController(
    repository,
    questions: LocalQuestionRepository(questions: replayCatalog),
    openingCardsEnabled: false,
  );
  await app.initialize();
  return app;
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
    'Renewal stays unavailable before bank exhaustion, including after five of twelve',
    () async {
      final repo = MemoryGameRepository();
      for (final q
          in completeQuestions.where((q) => q.categoryId == 'myths').take(5)) {
        repo.usage.mark(q);
      }
      final app = AppController(
        repo,
        questions: LocalQuestionRepository(questions: completeQuestions),
        openingCardsEnabled: false,
      );
      await app.initialize();
      expect(app.isCategoryExhausted('myths'), false);
      await expectLater(app.resetCategory('myths'), throwsStateError);
      expect(app.availableQuestionsForCategory('myths'), 7);
      await expectLater(app.resetCategory('missing'), throwsStateError);
      app.dispose();
    },
  );
  test(
    'Renewal opens a new cycle while scores, other categories and current-match exclusions survive',
    () async {
      final repo = MemoryGameRepository();
      final app = await replayApp(repo);
      final vm = await app.startSession(managementConfig());
      for (var i = 0; i < 5; i++) {
        expect(vm.selectCategory('myths'), true);
        vm.revealCard(0);
        vm.revealCard(1);
        expect(await vm.revealQuestion(), true);
        vm.showAnswer();
        vm.awardAnswer('a');
      }
      await app.flush();
      expect(app.isCategoryExhausted('myths'), true);
      final score = vm.state.teams.first.score;
      final history = vm.state.history;
      expect(score, 1000);
      await app.resetCategory('myths');
      expect(app.availableQuestionsForCategory('myths'), 5);
      expect(app.availableQuestionsForCategory('spacetoon'), 5);
      expect(vm.state.teams.first.score, score);
      expect(vm.state.history, history);
      expect(vm.remainingForCategory('myths'), 0);
      expect(vm.selectCategory('myths'), false);
      final reopened = await replayApp(repo);
      expect(reopened.availableQuestionsForCategory('myths'), 5);
      expect(reopened.session!.state.teams.first.score, score);
      expect(reopened.session!.remainingForCategory('myths'), 0);
      final fresh = await reopened.startSession(managementConfig());
      expect(fresh.remainingForCategory('myths'), 5);
      reopened.dispose();
      app.dispose();
    },
  );
  test(
    'A failed renewal leaves the used history unchanged and the option available',
    () async {
      final repo = _RenewFailure();
      for (final q in replayCatalog.where((q) => q.categoryId == 'myths')) {
        repo.usage.mark(q);
      }
      final app = await replayApp(repo);
      await expectLater(app.resetCategory('myths'), throwsStateError);
      expect(app.isCategoryExhausted('myths'), true);
      expect(repo.usage.contains(replayCatalog.first), true);
      app.dispose();
    },
  );
  test(
    'New cycles draw shuffled five-question quotas, without an imposed bank order',
    () {
      final first = planMatchQuestions(
        questions: replayCatalog,
        categoryIds: managementConfig().categoryIds,
        usage: QuestionUsage(),
        random: Random(17),
      );
      final second = planMatchQuestions(
        questions: replayCatalog,
        categoryIds: managementConfig().categoryIds,
        usage: QuestionUsage(),
        random: Random(29),
      );
      expect(first.map((q) => q.id).toSet(), second.map((q) => q.id).toSet());
      expect(
        first.map((q) => q.id).toList(),
        isNot(second.map((q) => q.id).toList()),
      );
      expect(first.map((q) => q.id).toSet().length, 30);
    },
  );
  testWidgets(
    'Setup offers only fully exhausted sections and refreshes shortage state after renewal',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = MemoryGameRepository();
      for (final q in replayCatalog.where((q) => q.categoryId == 'myths')) {
        repo.usage.mark(q);
      }
      final app = await replayApp(repo);
      final key = GlobalKey();
      await tester.pumpWidget(
        AppScope(
          controller: app,
          child: MaterialApp(
            theme: AppTheme.dark,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: RepaintBoundary(key: key, child: const SessionSetup()),
          ),
        ),
      );
      await tester.pump();
      final button = find.byKey(const ValueKey('renew-category-myths'));
      expect(button, findsOneWidget);
      expect(
        find.byKey(const ValueKey('renew-category-spacetoon')),
        findsNothing,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('category-replay-options')),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await snapshot(tester, key, 'category-renewal-portrait');
      await tester.tap(button);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(button, findsNothing);
      expect(find.byKey(const ValueKey('insufficient-content')), findsNothing);
      expect(app.availableQuestionsForCategory('myths'), 5);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      app.dispose();
    },
  );
}
