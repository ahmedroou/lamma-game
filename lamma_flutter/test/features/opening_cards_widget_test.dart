import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/features/session/session_screen.dart';
import 'package:lamma/features/session/question_card_deck.dart';
import 'package:lamma/features/session/session_view_model.dart';
import '../app_test.dart' show snapshot;
import '../fixtures/questions.dart';
import 'surprise_rules_test.dart'
    show model, card, specialQuestion, openQuestion;

Widget screen(SessionViewModel game) => MaterialApp(
  theme: AppTheme.dark,
  home: Directionality(
    textDirection: TextDirection.rtl,
    child: SessionScreen(config: game.config, model: game),
  ),
);
Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
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
  for (final width in [320.0, 390.0]) {
    for (final id in [
      'options_quarter',
      'plank_time',
      'ban_player_two_turns',
    ]) {
      testWidgets('$id note fits $width with enlarged Arabic text', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final paper = card(id), boundary = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: RepaintBoundary(
                      key: boundary,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: QuestionCardDeck(
                          question: specialQuestion.text,
                          points: 400,
                          revealedCards: 1,
                          secondsRemaining: 30,
                          onReveal: (_) {},
                          surpriseText: paper.text,
                          surpriseNote: paper.note,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(paper.note), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (width == 390 && id == 'plank_time') {
          await snapshot(tester, boundary, 'plank-paper-accessible');
        }
      });
    }
  }
  testWidgets(
    'Paid options stay hidden until purchase, cost once and disappear for opponent',
    (tester) async {
      final game = model('options_200', score: 300);
      addTearDown(game.dispose);
      openQuestion(game);
      await tester.pumpWidget(screen(game));
      await tester.pumpAndSettle();
      expect(find.text('A · الصحيح'), findsNothing);
      await tapText(tester, 'ادفع 200 نقطة واكشف الخيارات');
      expect(game.state.teams.first.score, 100);
      expect(find.text('A · الصحيح'), findsOneWidget);
      expect(game.activateSurprise(), false);
      expect(game.startOpponentOpportunity(), true);
      await tester.pump();
      expect(find.text('A · الصحيح'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Identity question shows opening rule before first clue and keeps modified time',
    (tester) async {
      final identity = Question.fromJson({
        ...specialQuestion.toJson(),
        'id': 'who_am_i-surprise',
        'categoryId': 'who_am_i',
        'text': 'من أنا؟',
        'clues': [
          'تلميح الهوية الأول',
          'تلميح الهوية الثاني',
          'تلميح الهوية الثالث',
        ],
      });
      final pool = [identity, ...seedQuestions.skip(1).take(5)];
      final game = SessionViewModel(
        config: SessionConfig(
          teams: [
            TeamState(id: 'a', name: 'أ'),
            TeamState(id: 'b', name: 'ب'),
          ],
          categoryIds: pool.map((q) => q.categoryId),
        ),
        questions: LocalQuestionRepository(questions: pool),
        surpriseResolver: (_, _, _) => card('half_time'),
      );
      addTearDown(game.dispose);
      game.selectCategory('who_am_i');
      await tester.pumpWidget(screen(game));
      await tester.pumpAndSettle();
      expect(find.text('تلميح الهوية الأول'), findsNothing);
      await tapText(tester, 'اكشف ورقة المفاجأة أولًا');
      expect(find.text(card('half_time').note), findsOneWidget);
      expect(game.state.revealedCards, 1);
      expect(find.text('تلميح الهوية الأول'), findsNothing);
      expect(game.revealCard(1), true);
      expect(game.revealCard(2), true);
      await tester.pumpAndSettle();
      expect(game.state.secondsRemaining, 15);
      expect(find.text('تلميح الهوية الأول'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
