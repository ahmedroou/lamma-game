import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/features/updates/app_update_screen.dart';
import 'package:lamma/features/updates/app_update_view_model.dart';
import 'app_update_test.dart' show FakePlatform, FakeStore, release;

void main() {
  for (final size in [
    const Size(390, 844),
    const Size(844, 390),
    const Size(320, 640),
  ]) {
    testWidgets('Update check download and permission flow fits $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final platform = FakePlatform()..permission = false;
      final vm = AppUpdateViewModel(
        platform: platform,
        store: FakeStore(),
        fetchRelease: () async => release(),
      );
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: AppUpdateScreen(model: vm),
        ),
      );
      await tester.pump();
      await tester.ensureVisible(find.text('فحص التحديثات'));
      await tester.tap(find.text('فحص التحديثات'));
      await tester.pump();
      expect(find.text('تنزيل التحديث'), findsOneWidget);
      await tester.ensureVisible(find.text('تنزيل التحديث'));
      await tester.tap(find.text('تنزيل التحديث'));
      await tester.pump();
      await tester.ensureVisible(find.text('تثبيت التحديث'));
      await tester.tap(find.text('تثبيت التحديث'));
      await tester.pump();
      expect(find.text('السماح بتثبيت التحديث'), findsOneWidget);
      expect(platform.installations, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
