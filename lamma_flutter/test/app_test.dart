import 'fixtures/questions.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/main.dart';
import 'package:lamma/core/app_controller.dart';
import 'package:lamma/data/repositories/local_game_repository.dart';
import 'package:lamma/features/session/session_view_model.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/core/game_catalog.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/features/session/session_screen.dart';
import 'package:lamma/features/session/question_card_deck.dart';

Future<void> snapshot(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('screenshots').create(recursive: true);
    await File(
      'screenshots/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> tapText(WidgetTester tester, String text) async {
  final chip = find.ancestor(
    of: find.text(text),
    matching: find.byType(FilterChip),
  );
  final target = chip.evaluate().isEmpty ? find.text(text) : chip;
  await tester.ensureVisible(target);
  await tester.pump();
  await tester.tap(target);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

SessionConfig fixtureConfig() => SessionConfig(
  teams: [
    for (var i = 0; i < 3; i++)
      TeamState(id: 'team-$i', name: ['الصقور', 'الأبطال', 'العواصف'][i]),
  ],
  categoryIds: seedQuestions.take(6).map((question) => question.categoryId),
);

Widget sessionHarness() => MaterialApp(
  theme: AppTheme.dark,
  debugShowCheckedModeBanner: false,
  locale: const Locale('ar'),
  supportedLocales: const [Locale('ar')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: SessionScreen(config: fixtureConfig(), model: fixtureModel()),
);

SessionViewModel fixtureModel() {
  final model = SessionViewModel(
    config: fixtureConfig(),
    questions: LocalQuestionRepository(questions: seedQuestions),
  );
  addTearDown(model.dispose);
  return model;
}

Widget testApp() {
  final controller = AppController(
    MemoryGameRepository(),
    questions: LocalQuestionRepository(questions: completeQuestions),
    openingCardsEnabled: false,
  );
  addTearDown(controller.dispose);
  return LammaApp(controller: controller);
}

void main() {
  setUpAll(() async {
    WidgetController.hitTestWarningShouldBeFatal = true;
    final arabic = FontLoader('Tajawal')
      ..addFont(rootBundle.load('assets/fonts/Tajawal-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Tajawal-Bold.ttf'));
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await Future.wait([arabic.load(), icons.load()]);
  });
  for (final size in [
    const Size(390, 844),
    const Size(844, 390),
    const Size(320, 568),
    const Size(1024, 768),
  ]) {
    testWidgets('Question cards reveal without shifting at $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var revealed = 0;
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            theme: AppTheme.dark,
            debugShowCheckedModeBanner: false,
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: StatefulBuilder(
                    builder: (context, update) => QuestionCardDeck(
                      question: seedQuestions.first.text,
                      points: seedQuestions.first.points,
                      revealedCards: revealed,
                      secondsRemaining: 30,
                      onReveal: (index) => update(() => revealed = index + 1),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final initialSizes = [
        for (var i = 0; i < 3; i++)
          tester.getSize(find.byKey(ValueKey('round-card-$i'))),
      ];
      expect(initialSizes[0], initialSizes[1]);
      if (size.width >= 700) expect(initialSizes[1], initialSizes[2]);
      await snapshot(
        tester,
        key,
        'question-cards-closed-${size.width.toInt()}',
      );
      for (final title in ['المفاجأة', 'الوقت', 'السؤال']) {
        await tapText(tester, title);
        expect(tester.takeException(), isNull);
      }
      expect(find.text(seedQuestions.first.text), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('round-card-2')),
          matching: find.text('${seedQuestions.first.points} نقطة'),
        ),
        findsOneWidget,
      );
      for (var i = 0; i < 3; i++) {
        expect(
          tester.getSize(find.byKey(ValueKey('round-card-$i'))),
          initialSizes[i],
        );
      }
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 1500),
      );
      await tester.pumpAndSettle();
      await snapshot(tester, key, 'question-cards-open-${size.width.toInt()}');
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('Question cards support large text and reduced motion', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var revealed = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
            textScaler: TextScaler.linear(2),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: StatefulBuilder(
                  builder: (context, update) => QuestionCardDeck(
                    points: 400,
                    question:
                        'هذا سؤال طويل لاختبار قراءة النص العربي كاملًا عند تكبير الخط دون اقتطاع الكلمات أو تداخل البطاقات مع بعضها.',
                    revealedCards: revealed,
                    secondsRemaining: 0,
                    onReveal: (index) => update(() => revealed = index + 1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.bySemanticsLabel('كشف كرت المفاجأة')),
      matchesSemantics(
        label: 'كشف كرت المفاجأة',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    for (final title in ['المفاجأة', 'الوقت', 'السؤال']) {
      await tester.ensureVisible(find.text(title));
      await tester.tap(find.text(title));
      await tester.pump();
      final cardAnimations = tester
          .widgetList<AnimatedBuilder>(
            find.descendant(
              of: find.byType(QuestionCardDeck),
              matching: find.byType(AnimatedBuilder),
            ),
          )
          .map((builder) => builder.animation)
          .whereType<AnimationController>();
      expect(
        cardAnimations.every((animation) => !animation.isAnimating),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    }
    expect(find.text('انتهى الوقت'), findsOneWidget);
    semantics.dispose();
    await tester.pumpWidget(const SizedBox());
  });
  for (final size in [
    const Size(390, 844),
    const Size(844, 390),
    const Size(1024, 768),
    const Size(320, 568),
  ]) {
    testWidgets('Responsive home $size has no layout errors', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(key: key, child: testApp()));
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.text('كل جمعة،'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('كل جمعة،'))),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
      if (size.width == 844) {
        expect(
          tester.getRect(find.text('ابدأ اللمّة')).bottom,
          lessThan(size.height - 70),
          reason:
              'The primary action must fit in the short landscape viewport.',
        );
      }
      if (size.width == 390 || size.width == 844) {
        await snapshot(
          tester,
          key,
          'home-${size.width == 390 ? 'portrait' : 'landscape'}',
        );
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('Large text keeps home, library and guide usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(testApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    await tapText(tester, 'الفئات');
    expect(find.text('وش جوّك اليوم؟'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tapText(tester, 'كيف نلعب؟');
    expect(find.text('3 كروت.\nوجلسة غير.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Setup supports third team and requires exactly six categories', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(testApp());
    await tester.pump(const Duration(milliseconds: 300));
    await tapText(tester, 'ابدأ اللمّة');
    expect(find.text('مين يتحدّى مين؟'), findsOneWidget);
    await tapText(tester, '3');
    expect(find.byKey(const ValueKey('team-name-2')), findsOneWidget);
    await tapText(tester, 'سبيستون');
    expect(find.text('باقي 1 أقسام'), findsOneWidget);
    await tapText(tester, 'جغرافيا');
    await tapText(tester, 'ابدأ التحدّي');
    expect(find.text('اختار ساحة التحدّي'), findsOneWidget);
    expect(find.text('العواصف'), findsOneWidget);
    expect(find.text('07 / قسم القدرات'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  for (final size in [const Size(390, 844), const Size(844, 390)]) {
    testWidgets('Three-team board and ability inventory adapt at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(key: key, child: sessionHarness()),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      await snapshot(
        tester,
        key,
        'board-${size.width == 390 ? 'portrait' : 'landscape'}',
      );
      await tapText(tester, '07 / قسم القدرات');
      expect(find.text('قدرات تغيّر اللعب'), findsOneWidget);
      await tapText(tester, 'نكمل التحدّي');
      await tapText(tester, 'الصقور');
      expect(find.text('أوراق الصقور'), findsOneWidget);
      expect(find.text('ما عندكم أوراق قدرات… للحين!'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets(
    'Legacy sample match completes but cannot recycle questions on restart',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(sessionHarness());
      await tester.pump();
      for (final category in gameCategories.take(6)) {
        await tapText(tester, category.title);
        if (category.id == 'myths') {
          await tapText(tester, 'السؤال');
          expect(find.text(seedQuestions.first.text), findsNothing);
        }
        for (final title in ['المفاجأة', 'الوقت', 'السؤال']) {
          await tapText(tester, title);
        }
        await tapText(tester, 'كشف الإجابة');
        if (category.id == 'myths') {
          await tapText(tester, 'الصقور +200');
        } else {
          await tapText(tester, 'لا أحد · نكمل');
        }
      }
      expect(find.text('الصقور أبطال اللمّة!'), findsOneWidget);
      await tapText(tester, 'نلعب من جديد');
      await tapText(tester, 'ابدأ مباراة جديدة');
      expect(find.text('الصقور أبطال اللمّة!'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
