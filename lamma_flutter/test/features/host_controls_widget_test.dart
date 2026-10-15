import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_controller.dart';
import 'package:lamma/core/app_scope.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/data/repositories/local_game_repository.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/features/session/session_screen.dart';
import '../fixtures/questions.dart';
import '../app_test.dart' show snapshot;
import 'session_management_test.dart' show managementConfig;

Future<void> tap(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
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
  for (final size in [const Size(390, 844), const Size(844, 390)]) {
    testWidgets(
      'One compact menu replaces the header; totals only appear on selection at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = MemoryGameRepository();
        final app = AppController(
          repository,
          questions: LocalQuestionRepository(questions: completeQuestions),
          openingCardsEnabled: false,
        );
        addTearDown(app.dispose);
        await app.initialize();
        final vm = await app.startSession(managementConfig());
        final boundary = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: AppScope(
              controller: app,
              child: MaterialApp(
                theme: AppTheme.dark,
                debugShowCheckedModeBanner: false,
                builder: (context, child) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                ),
                home: SessionScreen(config: vm.config, model: vm),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AppBar), findsNothing);
        expect(find.byKey(const ValueKey('team-scoreboard')), findsOneWidget);
        expect(find.text('الجلسة محفوظة على الجهاز'), findsNothing);
        expect(find.byKey(const ValueKey('team-score-plus-a')), findsOneWidget);
        expect(find.byKey(const ValueKey('team-score-minus-b')), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('team-score-plus-a')));
        await tester.pumpAndSettle();
        expect(vm.state.teams[0].score, 50);

        await tester.tap(find.byKey(const ValueKey('team-score-minus-b')));
        await tester.pumpAndSettle();
        expect(vm.state.teams[1].score, -50);
        expect(repository.session!.state.scoreAdjustments.length, 2);

        vm.selectCategory('myths');
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('team-scoreboard')), findsNothing);
        for (var i = 0; i < 3; i++) {
          vm.revealCard(i);
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('team-scoreboard')), findsNothing);
        }
        await tester.tap(find.byTooltip('خيارات اللعبة'));
        await tester.pumpAndSettle();
        await snapshot(tester, boundary, 'host-dropdown-${size.width.toInt()}');
        expect(find.text('تعديل نقاط الفرق'), findsNothing);
        Navigator.of(
          tester.element(find.byType(PopupMenuButton<String>).first),
        ).pop();
        await tester.pumpAndSettle();
        vm.showAnswer();
        await tester.pumpAndSettle();
        await tap(tester, 'لا أحد · نكمل');
        expect(find.byKey(const ValueKey('team-scoreboard')), findsOneWidget);
        expect(find.text('50'), findsOneWidget);
        expect(find.text('-50'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
