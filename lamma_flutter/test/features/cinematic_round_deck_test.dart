import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/features/session/cinematic_round_deck.dart';
import 'package:lamma/features/session/session_screen.dart';
import 'package:lamma/features/session/session_view_model.dart';
import 'package:lamma/shared/fit_text.dart';
import '../app_test.dart' show snapshot;
import 'question_rules_test.dart' show timedModel;

Widget deckHarness(
  ValueNotifier<int> count,
  GlobalKey key, {
  required bool wide,
  bool reduceMotion = false,
}) => MaterialApp(
  theme: AppTheme.dark,
  debugShowCheckedModeBanner: false,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: RepaintBoundary(
            key: key,
            child: ListenableBuilder(
              listenable: count,
              builder: (context, _) => CinematicRoundDeck(
                revealedCards: count.value,
                sideBySide: wide,
                canReveal: [for (var i = 0; i < 3; i++) count.value == i],
                onReveal: (i) => count.value = i + 1,
                faces: const [
                  FitText('قاعدة مفاجأة ظاهرة بعد الكشف'),
                  FitText('30 ثانية'),
                  FitText('نص السؤال المخفي حتى البطاقة الثالثة'),
                ],
              ),
            ),
          ),
        ),
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
    const Size(568, 320),
    const Size(844, 390),
    const Size(1024, 600),
    const Size(390, 844),
  ]) {
    testWidgets(
      'Three persistent cards reveal in order with a cinematic flip at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final count = ValueNotifier(0), boundary = GlobalKey();
        addTearDown(count.dispose);
        final wide = size.width > size.height;
        await tester.pumpWidget(deckHarness(count, boundary, wide: wide));
        await tester.pumpAndSettle();
        List<Rect> cards() => [
          for (var i = 0; i < 3; i++)
            tester.getRect(find.byKey(ValueKey('round-card-$i'))),
        ];
        final initial = cards();
        if (wide) {
          expect(initial[0].top, initial[1].top);
          expect(initial[1].top, initial[2].top);
          expect(initial[0].bottom, initial[2].bottom);
          expect(initial[0].left, greaterThan(initial[1].right));
          expect(initial[1].left, greaterThan(initial[2].right));
        }
        expect(find.byType(Scrollable), findsNothing);
        await tester.tap(find.text('السؤال'));
        await tester.pump();
        expect(count.value, 0);
        expect(find.text('نص السؤال المخفي حتى البطاقة الثالثة'), findsNothing);
        await tester.tap(find.text('المفاجأة'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 180));
        expect(find.text('قاعدة مفاجأة ظاهرة بعد الكشف'), findsNothing);
        expect(tester.binding.transientCallbackCount, greaterThan(0));
        await tester.pumpAndSettle();
        expect(find.text('قاعدة مفاجأة ظاهرة بعد الكشف'), findsOneWidget);
        await tester.tap(find.text('الوقت'));
        await tester.pumpAndSettle();
        expect(find.text('30 ثانية'), findsOneWidget);
        await tester.tap(find.text('السؤال'));
        await tester.pumpAndSettle();
        expect(
          find.text('نص السؤال المخفي حتى البطاقة الثالثة'),
          findsOneWidget,
        );
        expect(count.value, 3);
        expect(cards(), initial);
        expect(tester.takeException(), isNull);
        if (size.width == 844 || size.width == 390) {
          await snapshot(
            tester,
            boundary,
            'cinematic-table-${size.width.toInt()}',
          );
        }
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets(
    'Reduced motion reveals immediately and restores opened cards without a replay',
    (tester) async {
      final count = ValueNotifier(0);
      addTearDown(count.dispose);
      await tester.pumpWidget(
        deckHarness(count, GlobalKey(), wide: true, reduceMotion: true),
      );
      await tester.tap(find.text('المفاجأة'));
      await tester.pump();
      expect(find.text('قاعدة مفاجأة ظاهرة بعد الكشف'), findsOneWidget);
      count.value = 3;
      await tester.pump();
      expect(find.text('نص السؤال المخفي حتى البطاقة الثالثة'), findsOneWidget);
      await tester.pumpWidget(deckHarness(count, GlobalKey(), wide: false));
      await tester.pump();
      expect(find.text('نص السؤال المخفي حتى البطاقة الثالثة'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Real match keeps the timer stopped until the third card and retains the table on rotation',
    (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final model = timedModel();
      addTearDown(model.dispose);
      model.selectCategory('myths');
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          debugShowCheckedModeBanner: false,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: RepaintBoundary(
              key: boundary,
              child: SessionScreen(config: model.config, model: model),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('المفاجأة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('الوقت'));
      await tester.pumpAndSettle();
      expect(model.state.revealedCards, 2);
      expect(model.state.phase, SessionPhase.cards);
      expect(find.text(model.state.question!.text), findsNothing);
      final seconds = model.state.secondsRemaining;
      await tester.pump(const Duration(seconds: 3));
      expect(model.state.secondsRemaining, seconds);
      await tester.tap(find.text('السؤال'));
      await tester.pumpAndSettle();
      expect(model.state.revealedCards, 3);
      expect(find.text(model.state.question!.text), findsOneWidget);
      await snapshot(tester, boundary, 'cinematic-match-landscape');
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(model.state.revealedCards, 3);
      expect(find.byKey(const ValueKey('portrait-card-table')), findsOneWidget);
      for (var i = 0; i < 3; i++) {
        expect(find.byKey(ValueKey('round-card-$i')), findsOneWidget);
      }
      await snapshot(tester, boundary, 'cinematic-match-portrait');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
