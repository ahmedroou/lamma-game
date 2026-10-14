import 'package:lamma/data/repositories/question_repository.dart';
import '../fixtures/questions.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/main.dart';
import 'package:lamma/core/app_controller.dart';
import 'package:lamma/data/repositories/local_game_repository.dart';
import 'package:lamma/features/session/session_view_model.dart';
import 'session_management_test.dart' show managementModel, completeRound;

Future<void> tapLabel(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pump();
  await tester.tap(find.text(label));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 450));
}

Future<void> renderSnapshot(
  WidgetTester tester,
  GlobalKey boundary,
  String name,
) async {
  await tester.runAsync(() async {
    final image =
        await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('screenshots').create(recursive: true);
    await File(
      'screenshots/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<AppController> restoredController(
  MemoryGameRepository repository,
) async {
  final seed = managementModel();
  completeRound(seed, 'myths', 'a');
  await repository.saveSession(seed.snapshot());
  seed.dispose();
  final app = AppController(
    repository,
    questions: LocalQuestionRepository(questions: seedQuestions),
    openingCardsEnabled: false,
  );
  await app.initialize();
  return app;
}

void main() {
  setUpAll(() async {
    final arabic = FontLoader('Tajawal')
      ..addFont(rootBundle.load('assets/fonts/Tajawal-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Tajawal-Bold.ttf'));
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await Future.wait([arabic.load(), icons.load()]);
  });
  testWidgets(
    'Saved session, pause, back cancellation and saved exit keep progress',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = MemoryGameRepository();
      final app = await restoredController(repository);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: LammaApp(controller: app),
        ),
      );
      await tester.pump();
      expect(find.text('لمّتكم محفوظة'), findsOneWidget);
      await tapLabel(tester, 'استئناف الجلسة');
      expect(find.text('جلسة محفوظة… نكمل؟'), findsOneWidget);
      await renderSnapshot(tester, boundary, 'session-restored-portrait');
      await tapLabel(tester, 'متابعة اللعب');
      await tapLabel(tester, 'سبيستون');
      for (final title in ['المفاجأة', 'الوقت', 'السؤال']) {
        await tapLabel(tester, title);
      }
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byTooltip('خيارات اللعبة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إيقاف الجلسة'));
      await tester.pump();
      final remaining = app.session!.state.secondsRemaining;
      await tester.pump(const Duration(seconds: 10));
      expect(app.session!.state.secondsRemaining, remaining);
      expect(find.text('الجلسة متوقفة'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('نحفظ اللمّة ونرجع؟'), findsOneWidget);
      await tapLabel(tester, 'البقاء');
      expect(app.session!.state.isPaused, true);
      await tapLabel(tester, 'متابعة اللعب');
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tapLabel(tester, 'حفظ وخروج');
      expect(find.text('لمّتكم محفوظة'), findsOneWidget);
      await app.flush();
      expect(repository.session!.state.teams.first.score, 200);
      expect(repository.session!.state.question!.id, 'spacetoon-1');
      expect(repository.session!.state.isPaused, true);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      app.dispose();
    },
  );
  testWidgets(
    'History correction is persisted and last judgment can be reopened safely',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = MemoryGameRepository();
      final app = await restoredController(repository);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: LammaApp(controller: app),
        ),
      );
      await tester.pump();
      await tapLabel(tester, 'استئناف الجلسة');
      await tapLabel(tester, 'متابعة اللعب');
      await tester.tap(find.byTooltip('خيارات اللعبة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('سجل الجولات'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tapLabel(tester, 'تصحيح التحكيم');
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('الأبطال').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tapLabel(tester, 'حفظ التصحيح');
      expect(app.session!.state.teams.map((team) => team.score), [0, 200, 0]);
      await app.flush();
      expect(repository.session!.state.corrections.length, 1);
      await renderSnapshot(tester, boundary, 'session-history-portrait');
      await tapLabel(tester, 'إعادة فتح آخر تحكيم');
      await tapLabel(tester, 'إعادة التحكيم');
      expect(app.session!.state.phase, SessionPhase.answer);
      expect(app.session!.state.isPaused, true);
      expect(app.session!.state.teams.every((team) => team.score == 0), true);
      await tapLabel(tester, 'متابعة اللعب');
      await tapLabel(tester, 'العواصف +200');
      expect(app.session!.state.teams.last.score, 200);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      app.dispose();
    },
  );
  testWidgets('Changed settings reload into another app instance', (
    tester,
  ) async {
    final repository = MemoryGameRepository();
    final first = AppController(
      repository,
      questions: LocalQuestionRepository(questions: seedQuestions),
      openingCardsEnabled: false,
    );
    await first.initialize();
    await tester.pumpWidget(LammaApp(controller: first));
    await tester.pump();
    await tester.tap(find.byTooltip('الإعدادات'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.widgetWithText(SwitchListTile, 'حركة الكروت'));
    await tester.pump();
    await first.flush();
    expect(repository.settings.motion, false);
    await tester.pumpWidget(const SizedBox());
    first.dispose();
    final second = AppController(
      repository,
      questions: LocalQuestionRepository(questions: seedQuestions),
      openingCardsEnabled: false,
    );
    await second.initialize();
    await tester.pumpWidget(LammaApp(controller: second));
    await tester.pump();
    expect(second.settings.motion, false);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    second.dispose();
  });
  testWidgets('Paused restoration fits short landscape with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final repository = MemoryGameRepository();
    final app = await restoredController(repository);
    await tester.pumpWidget(LammaApp(controller: app));
    await tester.pump();
    await tapLabel(tester, 'استئناف الجلسة');
    expect(find.text('جلسة محفوظة… نكمل؟'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    app.dispose();
  });
}
