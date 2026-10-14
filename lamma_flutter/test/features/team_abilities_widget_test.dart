import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/domain/abilities/team_ability_catalog.dart';
import 'package:lamma/features/session/session_screen.dart';
import 'package:lamma/features/session/session_setup.dart';
import 'team_abilities_test.dart' show abilityModel, owned;

Widget harness(Widget child, {double scale = 1}) => MaterialApp(
  theme: AppTheme.dark,
  debugShowCheckedModeBanner: false,
  locale: const Locale('ar'),
  supportedLocales: const [Locale('ar')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: child,
);
Future<void> capture(
  WidgetTester tester,
  GlobalKey boundary,
  String name,
) async {
  await tester.runAsync(() async {
    final frame =
        await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
    final bytes = await frame.toByteData(format: ui.ImageByteFormat.png);
    await Directory('screenshots').create(recursive: true);
    await File(
      'screenshots/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    frame.dispose();
  });
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 450));
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    await (FontLoader('Tajawal')
          ..addFont(rootBundle.load('assets/fonts/Tajawal-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Tajawal-Bold.ttf')))
        .load();
  });
  testWidgets(
    'Setup ability switch changes information for two and three teams',
    (tester) async {
      await tester.pumpWidget(harness(const SessionSetup()));
      await tester.ensureVisible(find.byType(Switch));
      await tester.pump();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(find.textContaining('لكل فريق 3 اختيارات'), findsOneWidget);
      await tap(tester, find.byType(Switch));
      expect(find.text('اللعب بستة أقسام دون محفظة قدرات'), findsOneWidget);
      await tap(tester, find.byType(Switch));
      await tap(tester, find.text('3'));
      expect(find.textContaining('لكل فريق 2 اختيارات'), findsOneWidget);
    },
  );
  for (final size in [
    const Size(390, 844),
    const Size(844, 390),
    const Size(320, 640),
  ]) {
    testWidgets('Ability board wallet and host activation fit $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final vm = abilityModel(count: 3, stock: true);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: harness(
            SessionScreen(config: vm.config, model: vm),
            scale: size.width == 320 ? 1.3 : 1,
          ),
        ),
      );
      expect(find.text('07 / قسم القدرات'), findsOneWidget);
      expect(find.textContaining('لفريقك 2 اختيارات'), findsOneWidget);
      vm.selectCategory('myths');
      await tester.pump();
      await tap(tester, find.byTooltip('خيارات اللعبة'));
      await tap(tester, find.text('محافظ القدرات'));
      await tap(tester, find.text('فريق 0'));
      expect(find.text('أوراق فريق 0'), findsOneWidget);
      expect(find.text('الاستخدامات المتبقية: 3'), findsOneWidget);
      expect(find.text('اختر سؤال فريقك واستخدمها قبل كشفه.'), findsNothing);
      expect(tester.takeException(), isNull);
      final card = find.ancestor(
        of: find.text('دبل النقاط'),
        matching: find.byType(Card),
      );
      final button = find.descendant(
        of: card,
        matching: find.byType(FilledButton),
      );
      await tap(tester, button);
      expect(find.text('تفعيل دبل النقاط؟'), findsOneWidget);
      await tap(tester, find.text('تفعيل البطاقة'));
      expect(vm.state.roundData['doubleAbilityTeamId'], '0');
      expect(owned(vm, '0', TeamAbilityCatalog.doublePoints).remainingUses, 1);
      await tap(tester, find.byTooltip('خيارات اللعبة'));
      await tap(tester, find.text('محافظ القدرات'));
      await tap(tester, find.text('فريق 0'));
      await tester.ensureVisible(find.text('دبل النقاط'));
      await tester.pump();
      expect(find.text('الاستخدامات المتبقية: 1'), findsNWidgets(2));
      expect(find.text('الدبل مُفعّل بالفعل.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await capture(tester, boundary, 'abilities-wallet-${size.width.toInt()}');
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('Disabled mode hides seventh category', (tester) async {
    final vm = abilityModel(enabled: false);
    await tester.pumpWidget(
      harness(SessionScreen(config: vm.config, model: vm)),
    );
    expect(find.text('07 / قسم القدرات'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
