import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/hint_access.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/session_save.dart';
import 'package:lamma/features/session/session_view_model.dart';
import 'package:lamma/features/session/session_screen.dart';
import 'package:lamma/features/session/identity_question_panel.dart';
import '../app_test.dart' show snapshot;
import '../fixtures/questions.dart';
import 'session_management_test.dart' show managementConfig;

SessionViewModel identityModel(QuestionDifficulty difficulty) {
  final identity = Question(
    id: 'identity',
    categoryId: 'who_am_i',
    text: 'من أنا؟',
    answer: 'الشمس',
    difficulty: difficulty,
    hint: 'مصدر ضوء',
    options: const [
      QuestionOption(id: 'A', text: 'القمر'),
      QuestionOption(id: 'B', text: 'الشمس'),
      QuestionOption(id: 'C', text: 'المشتري'),
      QuestionOption(id: 'D', text: 'الشعرى'),
      QuestionOption(id: 'E', text: 'سهيل'),
      QuestionOption(id: 'F', text: 'الزهرة'),
    ],
    correctOptionId: 'B',
    clues: const [
      'تصل طاقتي إلى الأرض.',
      'أنا نجم.',
      'تدور حولي كواكب النظام الشمسي.',
    ],
  );
  return SessionViewModel(
    config: SessionConfig(
      teams: managementConfig().teams,
      categoryIds: [
        ...seedQuestions.take(5).map((q) => q.categoryId),
        'who_am_i',
      ],
    ),
    questions: LocalQuestionRepository(
      questions: [...seedQuestions.take(5), identity],
    ),
  );
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
  for (final level in QuestionDifficulty.values) {
    for (var count = 1; count <= 3; count++) {
      test(
        'Identity ${level.name}: $count clues survive save, correction and reopening',
        () {
          final vm = identityModel(level);
          addTearDown(vm.dispose);
          vm.selectCategory('who_am_i');
          expect(vm.revealNextClue(), false);
          for (var i = 0; i < 3; i++) {
            vm.revealCard(i);
          }
          for (var i = 1; i < count; i++) {
            expect(vm.revealNextClue(), true);
          }
          final expected = level.points ~/ (1 << (count - 1));
          expect(vm.state.availablePoints, expected);
          vm.pause();
          expect(vm.revealNextClue(), false);
          final save = SessionSave.fromJson(
            jsonDecode(jsonEncode(vm.snapshot().toJson()))
                as Map<String, dynamic>,
          );
          final restored = SessionViewModel.restore(save);
          addTearDown(restored.dispose);
          expect(restored.state.identityCluesRevealed, count);
          expect(restored.state.question!.options.length, 6);
          expect(restored.state.question!.correctOptionId, 'B');
          restored.resume();
          restored.showAnswer();
          expect(restored.revealNextClue(), false);
          restored.awardAnswer('a');
          expect(restored.state.teams.first.score, expected);
          final record = restored.state.history.single;
          expect(record.awardedPoints, expected);
          expect(restored.correctDecision(record.id, 'b'), true);
          expect(restored.state.teams[0].score, 0);
          expect(restored.state.teams[1].score, expected);
          expect(restored.correctDecision(record.id, null), true);
          expect(restored.correctDecision(record.id, 'a'), true);
          expect(restored.state.teams[0].score, expected);
          expect(restored.undoLastDecision(), true);
          expect(restored.state.availablePoints, expected);
          restored.resume();
          restored.awardAnswer('b');
          expect(restored.state.teams[1].score, expected);
        },
      );
    }
  }

  testWidgets(
    'Only revealed identity clues appear; points and answer actions update',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final vm = identityModel(QuestionDifficulty.hard);
      addTearDown(vm.dispose);
      vm.selectCategory('who_am_i');
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: SessionScreen(config: vm.config, model: vm),
          ),
        ),
      );
      Future<void> tap(String text) async {
        await tester.ensureVisible(find.text(text));
        await tester.tap(find.text(text));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      expect(find.text('تصل طاقتي إلى الأرض.'), findsNothing);
      await tap('المفاجأة');
      await tap('الوقت');
      await tap('اكشف التلميح الأول · 300 نقطة');
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('question-points')),
          matching: find.text('300 نقطة'),
        ),
        findsOneWidget,
      );
      expect(find.text('تصل طاقتي إلى الأرض.'), findsOneWidget);
      expect(find.text('أنا نجم.'), findsNothing);
      await tap('التلميح التالي · 150 نقطة');
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('question-points')),
          matching: find.text('150 نقطة'),
        ),
        findsOneWidget,
      );
      expect(find.text('أنا نجم.'), findsOneWidget);
      await tap('التلميح التالي · 75 نقطة');
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('question-points')),
          matching: find.text('75 نقطة'),
        ),
        findsOneWidget,
      );
      expect(find.text('تدور حولي كواكب النظام الشمسي.'), findsOneWidget);
      expect(vm.revealNextClue(), false);
      await tap('كشف الإجابة');
      expect(find.text('الصقور +75'), findsOneWidget);
      for (final option in vm.state.question!.options.where(
        (option) => option.id != 'B',
      )) {
        expect(find.text(option.text), findsNothing);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final size in [
    const Size(390, 844),
    const Size(844, 390),
    const Size(320, 568),
  ]) {
    testWidgets('Identity layout supports $size and large text', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final vm = identityModel(QuestionDifficulty.hard);
      addTearDown(vm.dispose);
      vm.selectCategory('who_am_i');
      for (var i = 0; i < 3; i++) {
        vm.revealCard(i);
      }
      vm.revealNextClue();
      vm.pause();
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            home: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(size.width == 320 ? 1.8 : 1),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: IdentityQuestionPanel(
                      state: vm.state,
                      onStart: () {},
                      onNext: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (size.width == 390) {
        await snapshot(tester, boundary, 'identity-question-portrait');
      }
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'A surprise-gated hint is saved while six choices remain hidden',
    (tester) async {
      final repository = await tester.runAsync(
        () => LocalQuestionRepository.load(),
      );
      final vm = SessionViewModel(
        config: managementConfig(),
        questions: repository!,
        surpriseResolver: (q, team, turn) => SurpriseCard(
          id: 'test-hint-surprise',
          text: 'اختبار: بطاقة تمنح التلميح',
          grantsHint: true,
        ),
      );
      addTearDown(vm.dispose);
      vm.selectCategory('myths');
      for (var i = 0; i < 3; i++) {
        vm.revealCard(i);
      }
      final question = vm.state.question!;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: SessionScreen(config: vm.config, model: vm),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final option in question.options) {
        expect(find.text(option.text), findsNothing);
      }
      await tester.ensureVisible(find.text('عرض تلميح مساعد'));
      await tester.tap(find.text('عرض تلميح مساعد'));
      await tester.pumpAndSettle();
      expect(find.text('تلميح مساعد: ${question.hint}'), findsOneWidget);
      expect(vm.state.availablePoints, question.points);
      final restored = SessionViewModel.restore(
        SessionSave.fromJson(
          jsonDecode(jsonEncode(vm.snapshot().toJson()))
              as Map<String, dynamic>,
        ),
      );
      addTearDown(restored.dispose);
      expect(restored.state.hintRevealed, true);
      expect(restored.state.question!.options.length, 6);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
