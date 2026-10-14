import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/core/game_catalog.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/hint_access.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/question_presentation.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/features/session/session_screen.dart';
import 'package:lamma/features/session/session_setup.dart';
import 'package:lamma/features/session/session_view_model.dart';
import 'package:lamma/shared/fit_text.dart';
import '../fixtures/questions.dart';
import '../app_test.dart' show snapshot;
import 'surprise_rules_test.dart' show card;

Widget harness(Widget child, {double scale = 1}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.dark,
  home: Directionality(textDirection: TextDirection.rtl, child: child),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      padding: const EdgeInsets.only(top: 24, bottom: 20),
      textScaler: TextScaler.linear(scale),
    ),
    child: child!,
  ),
);

SessionViewModel game(String variant, DateTime Function() now) {
  final presentation = variant == 'matching' || variant == 'grouping'
      ? QuestionPresentation.fromJson({
          'type': variant,
          'sections': [
            for (var side = 0; side < (variant == 'matching' ? 2 : 1); side++)
              {
                'id': side == 0 ? 'left' : 'right',
                'title': variant == 'matching' ? 'الطرف ${side + 1}' : '',
                'items': [
                  for (var n = 0; n < (variant == 'matching' ? 4 : 8); n++)
                    {'id': 'e$side$n', 'text': 'العنصر العربي رقم ${n + 1}'},
                ],
              },
          ],
        })
      : null;
  final q = Question(
    id: 'myths-layout',
    categoryId: 'myths',
    difficulty: QuestionDifficulty.hard,
    text:
        'اقرأ العناصر المعروضة وحدد الإجابة المطلوبة وفق المعلومات التي تظهر أمامك في هذا السؤال.',
    answer: 'الإجابة الصحيحة الكاملة',
    explanation: 'شرح مختصر يوضح طريقة الوصول إلى الإجابة الصحيحة.',
    imageAsset: variant == 'image' ? 'assets/category_art/myths.webp' : null,
    presentation: presentation,
    options: [
      for (var i = 0; i < 6; i++)
        QuestionOption(id: '$i', text: 'خيار عربي كامل رقم ${i + 1}'),
    ],
    correctOptionId: '0',
  );
  final pool = [q, ...seedQuestions.skip(1).take(5)];
  return SessionViewModel(
    now: now,
    config: SessionConfig(
      teams: [
        for (var i = 0; i < 3; i++)
          TeamState(id: '$i', name: 'الفريق ${i + 1}', score: 300),
      ],
      categoryIds: pool.map((q) => q.categoryId),
    ),
    questions: LocalQuestionRepository(questions: pool),
    surpriseResolver: (_, _, _) => variant == 'options'
        ? card('options_200')
        : SurpriseCard(
            id: 'layout-none',
            text: 'سؤال عادي',
            note: 'أجب عن السؤال ضمن الوقت المحدد.',
          ),
  );
}

void fitsScreen(WidgetTester tester, Size size) {
  expect(find.byType(Scrollable), findsNothing);
  expect(tester.takeException(), isNull);
  for (final element in find.byType(PlayButton).evaluate()) {
    final rect = tester.getRect(find.byWidget(element.widget));
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(size.width));
    expect(rect.top, greaterThanOrEqualTo(24));
    expect(rect.bottom, lessThanOrEqualTo(size.height - 20));
    expect(rect.height, greaterThanOrEqualTo(24));
  }
  for (final element in find.byType(Text).evaluate()) {
    final rect = tester.getRect(find.byWidget(element.widget));
    expect(rect.bottom, lessThanOrEqualTo(size.height - 20 + 1));
    expect(rect.top, greaterThanOrEqualTo(24 - 1));
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
  for (final width in [320.0, 390.0]) {
    testWidgets('Setup always has three compact category cards at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(harness(const SessionSetup()));
      final tiles = [
        for (final c in gameCategories.take(4))
          find.byKey(ValueKey('select-category-${c.id}')),
      ];
      await tester.ensureVisible(tiles.first);
      await tester.pump();
      final rects = tiles.map(tester.getRect).toList();
      expect(rects[0].top, rects[1].top);
      expect(rects[1].top, rects[2].top);
      expect(rects[3].top, greaterThan(rects[0].bottom));
      expect(rects[0].height, lessThan(140));
      expect(tester.takeException(), isNull);
      if (width == 390) {
        // Setup is intentionally scrollable; play has a separate bounded canvas.
        final boundary = GlobalKey();
        await tester.pumpWidget(
          harness(RepaintBoundary(key: boundary, child: const SessionSetup())),
        );
        await tester.ensureVisible(
          find.byKey(ValueKey('select-category-${gameCategories.first.id}')),
        );
        await tester.pumpAndSettle();
        await snapshot(tester, boundary, 'compact-category-selection');
      }
    });
  }
  for (final size in [
    const Size(320, 568),
    const Size(568, 320),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    for (final variant in ['options', 'image', 'matching', 'grouping']) {
      testWidgets(
        '$variant game fits $size through board, question, opponent, answer and pause',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var now = DateTime.utc(2026, 10, 14);
          final vm = game(variant, () => now);
          addTearDown(vm.dispose);
          final boundary = GlobalKey();
          await tester.pumpWidget(
            harness(
              RepaintBoundary(
                key: boundary,
                child: SessionScreen(config: vm.config, model: vm),
              ),
              scale: 1.5,
            ),
          );
          await tester.pumpAndSettle();
          fitsScreen(tester, size);
          await tester.tap(find.byKey(const ValueKey('play-category-myths')));
          await tester.pump();
          fitsScreen(tester, size);
          for (var i = 0; i < 3; i++) {
            vm.revealCard(i);
          }
          if (variant == 'options') {
            vm.activateSurprise();
          }
          await tester.pumpAndSettle();
          fitsScreen(tester, size);
          expect(find.text(vm.state.question!.text), findsOneWidget);
          if (variant == 'options') {
            for (var i = 0; i < 6; i++) {
              expect(
                find.text('$i · خيار عربي كامل رقم ${i + 1}'),
                findsOneWidget,
              );
            }
          }
          if (variant == 'matching') {
            await tester.tap(find.byKey(const ValueKey('element-e00')));
            await tester.pump();
            await tester.tap(find.byKey(const ValueKey('element-e10')));
            await tester.pump();
            expect(vm.state.questionDraft['pair:e00'], 'e10');
            fitsScreen(tester, size);
          }
          if (variant == 'grouping') {
            await tester.tap(find.byKey(const ValueKey('element-e00')));
            await tester.pump();
            expect(vm.state.questionDraft.values, contains('1'));
            fitsScreen(tester, size);
          }
          if (size == const Size(390, 844) || size == const Size(844, 390)) {
            await snapshot(
              tester,
              boundary,
              'compact-$variant-${size.width.toInt()}',
            );
          }
          vm.pause();
          await tester.pump();
          fitsScreen(tester, size);
          await tester.tap(find.text('متابعة اللعب'));
          await tester.pump();
          vm.startOpponentOpportunity();
          await tester.pump();
          fitsScreen(tester, size);
          now = now.add(const Duration(seconds: 7));
          await tester.pump(const Duration(seconds: 7));
          vm.showAnswer();
          await tester.pump();
          fitsScreen(tester, size);
          expect(find.text('الإجابة الصحيحة الكاملة'), findsOneWidget);
          await tester.tap(find.text('لا أحد · نكمل'));
          await tester.pump();
          fitsScreen(tester, size);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
