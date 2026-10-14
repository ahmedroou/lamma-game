import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_controller.dart';
import 'package:lamma/core/app_scope.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/data/repositories/local_game_repository.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/app_release.dart';
import 'package:lamma/features/home/home_screen.dart';
import 'package:lamma/features/updates/app_update_view_model.dart';
import '../fixtures/questions.dart';
import '../app_test.dart' show snapshot;
import 'app_update_test.dart' show FakePlatform, FakeStore, release;

Future<AppController> controller() async {
  final app = AppController(
    MemoryGameRepository(),
    questions: LocalQuestionRepository(questions: seedQuestions),
  );
  await app.initialize();
  app.updateSettings(app.settings.copyWith(motion: false));
  return app;
}

Widget harness(
  AppController app,
  AppUpdateViewModel updates,
  GlobalKey boundary,
) => AppScope(
  controller: app,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: RepaintBoundary(
        key: boundary,
        child: HomeScreen(updateModel: updates),
      ),
    ),
  ),
);

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
  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    testWidgets(
      'Home automatically checks and opens the notified update at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final app = await controller();
        addTearDown(app.dispose);
        final gate = Completer<AppRelease?>();
        var requests = 0;
        final updates = AppUpdateViewModel(
          platform: FakePlatform(),
          store: FakeStore(),
          fetchRelease: () {
            requests++;
            return gate.future;
          },
        );
        addTearDown(updates.dispose);
        final key = GlobalKey();
        await tester.pumpWidget(harness(app, updates, key));
        await tester.pump();
        expect(requests, 1);
        expect(find.byKey(const ValueKey('home-update-badge')), findsNothing);
        gate.complete(release());
        await tester.pump();
        await tester.pump();
        final button = find.byKey(const ValueKey('home-update-button'));
        expect(find.byKey(const ValueKey('home-update-badge')), findsOneWidget);
        final rect = tester.getRect(button);
        expect(rect.top, lessThan(80));
        expect(rect.right, lessThanOrEqualTo(size.width));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.width, lessThanOrEqualTo(48));
        if (size.width == 390) {
          await snapshot(tester, key, 'home-update-notification');
        }
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.text('تنزيل التحديث'), findsOneWidget);
        expect(requests, 1);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('home-update-badge')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets(
    'A failed automatic check leaves home playable without a false notification',
    (tester) async {
      final app = await controller();
      addTearDown(app.dispose);
      var requests = 0;
      final updates = AppUpdateViewModel(
        platform: FakePlatform(),
        store: FakeStore(),
        fetchRelease: () async {
          requests++;
          throw StateError('offline');
        },
      );
      addTearDown(updates.dispose);
      await tester.pumpWidget(harness(app, updates, GlobalKey()));
      await tester.pump();
      expect(requests, 1);
      expect(find.byKey(const ValueKey('home-update-badge')), findsNothing);
      expect(find.text('ابدأ اللمّة'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('home-update-button')));
      await tester.pumpAndSettle();
      expect(find.text('فتح رابط التحميل المباشر'), findsOneWidget);
      expect(requests, 2);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
