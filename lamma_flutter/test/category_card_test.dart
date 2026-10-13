import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/core/game_catalog.dart';
import 'package:lamma/shared/category_card.dart';
import 'app_test.dart' show snapshot, testApp, tapText;

void main() {
  setUpAll(() async {
    final font = FontLoader('Tajawal')
      ..addFont(rootBundle.load('assets/fonts/Tajawal-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Tajawal-Bold.ttf'));
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await Future.wait([font.load(), icons.load()]);
  });

  for (final size in [
    const Size(390, 844),
    const Size(1024, 1000),
    const Size(320, 568),
  ]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets('Illustrated grid fits $size at text scale $textScale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final boundary = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              theme: AppTheme.dark,
              debugShowCheckedModeBanner: false,
              home: MediaQuery(
                data: MediaQueryData(
                  size: size,
                  textScaler: TextScaler.linear(textScale),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Scaffold(
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'اختاروا ساحة التحدّي',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '6 أقسام · اختياراتكم تصنع جوّ الجلسة',
                            style: TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 24),
                          CategoryGrid(
                            categories: gameCategories,
                            itemBuilder: (category) => CategoryCard(
                              category: category,
                              selected: gameCategories.indexOf(category) < 6,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final context = tester.element(find.byType(CategoryGrid));
        await tester.runAsync(() async {
          await Future.wait([
            for (final category in gameCategories)
              if (!category.usesVectorArt)
                precacheImage(
                  ResizeImage(AssetImage(category.imageAsset), width: 300),
                  context,
                ),
          ]);
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final sizes = tester
            .widgetList<CategoryCard>(find.byType(CategoryCard))
            .map((card) => tester.getSize(find.byWidget(card)))
            .toSet();
        expect(sizes, hasLength(1));
        if (textScale == 1 && size.width != 320) {
          await snapshot(
            tester,
            boundary,
            'illustrated-categories-${size.width.toInt()}',
          );
        }
        await tester.scrollUntilVisible(find.text('من أنا؟'), 250);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Image card responds to pointer, keyboard and reduced motion', (
    tester,
  ) async {
    var taps = 0;
    Future<void> render({bool reduce = false, bool enabled = true}) =>
        tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduce),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 180,
                    child: CategoryCard(
                      category: gameCategories.first,
                      selected: true,
                      onTap: enabled ? () => taps++ : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
    await render();
    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byType(CategoryCard)),
      matchesSemantics(
        label: 'الأساطير والخرافات',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(CategoryCard)));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      greaterThan(1),
    );
    await tester.tap(find.byType(CategoryCard));
    expect(taps, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(taps, 2);
    await render(reduce: true);
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    expect(
      tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
      0,
    );
    await render(enabled: false);
    await tester.tap(find.byType(CategoryCard));
    expect(taps, 2);
    await mouse.removePointer();
    semantics.dispose();
  });

  testWidgets('Setup image selection still requires exactly six categories', (
    tester,
  ) async {
    await tester.pumpWidget(testApp());
    await tester.pump(const Duration(milliseconds: 400));
    await tapText(tester, 'ابدأ اللمّة');
    await tester.pumpAndSettle();
    final geography = find.byKey(const ValueKey('select-category-geography'));
    await tester.ensureVisible(geography);
    await tester.tap(geography);
    await tester.pumpAndSettle();
    expect(tester.widget<CategoryCard>(geography).selected, false);
    final myths = find.byKey(const ValueKey('select-category-myths'));
    await tester.ensureVisible(myths);
    await tester.tap(myths);
    await tester.pumpAndSettle();
    await tester.ensureVisible(geography);
    await tester.tap(geography);
    await tester.pumpAndSettle();
    expect(tester.widget<CategoryCard>(geography).selected, true);
    expect(
      tester
          .widgetList<CategoryCard>(find.byType(CategoryCard))
          .where((card) => card.selected == true),
      hasLength(6),
    );
  });
}
