import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/game_catalog.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/abilities/surprise_catalog.dart';
import 'package:lamma/domain/models/hint_access.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/question_bank_config.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/features/session/session_view_model.dart';
import '../fixtures/questions.dart';

SurpriseCard findCard(String id) =>
    SurpriseCatalog.cards.singleWhere((c) => c.id == id);

final reverseTestQuestion = Question(
  id: 'reverse_question-easy-9999',
  categoryId: 'reverse_question',
  text: 'الجواب: «الرياض»',
  answer: 'ما هي عاصمة المملكة العربية السعودية؟',
  hint: 'عاصمة عربية في نجد',
  difficulty: QuestionDifficulty.easy,
  options: [
    QuestionOption(id: 'A', text: 'ما هي عاصمة جمهورية مصر العربية؟'),
    QuestionOption(id: 'B', text: 'ما هي عاصمة المملكة العربية السعودية؟'),
    QuestionOption(id: 'C', text: 'ما هي عاصمة الإمارات العربية المتحدة؟'),
    QuestionOption(id: 'D', text: 'ما هي عاصمة المملكة الأردنية الهاشمية؟'),
    QuestionOption(id: 'E', text: 'ما هي عاصمة دولة الكويت؟'),
    QuestionOption(id: 'F', text: 'ما هي عاصمة مملكة البحرين؟'),
  ],
  correctOptionId: 'B',
  qualityStatus: QuestionQualityStatus.reviewed,
);

SessionViewModel createModel({SurpriseCard? surprise}) {
  final questions = [
    reverseTestQuestion,
    ...seedQuestions.where((q) => q.categoryId != 'reverse_question').take(5),
  ];
  return SessionViewModel(
    config: SessionConfig(
      teams: [
        TeamState(id: 'a', name: 'الفريق الأول', score: 300),
        TeamState(id: 'b', name: 'الفريق الثاني', score: 300),
      ],
      categoryIds: questions.map((q) => q.categoryId),
    ),
    questions: LocalQuestionRepository(questions: questions),
    random: Random(42),
    surpriseResolver: surprise != null ? (_, _, _) => surprise : null,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reverse Question Category Catalog & Config', () {
    test('Category is registered in gameCategories with expected metadata', () {
      final category = gameCategories.firstWhere(
        (c) => c.id == 'reverse_question',
      );
      expect(category.title, 'سؤال عكسي');
      expect(category.subtitle, 'ما السؤال الذي يُطرح لتكون هذه إجابته؟');
      expect(category.usesVectorArt, isTrue);
    });

    test('QuestionBankConfig includes reverse_question in newCategoryIds', () {
      expect(
        QuestionBankConfig.newCategoryIds.contains('reverse_question'),
        isTrue,
      );
    });

    test('GameRules.secondsForCategory returns 20 for reverse_question and 30 for others', () {
      expect(GameRules.secondsForCategory('reverse_question'), 20);
      expect(GameRules.secondsForCategory('myths'), 30);
      expect(GameRules.secondsForCategory('geography'), 30);
      expect(GameRules.secondsForCategory(null), 30);
    });
  });

  group('Reverse Question Round Timer Logic', () {
    test('Default round timer for reverse_question is exactly 20 seconds', () {
      final vm = createModel();
      addTearDown(vm.dispose);

      expect(vm.selectCategory('reverse_question'), isTrue);
      expect(vm.state.secondsRemaining, 20);
      expect(vm.state.roundData['initialQuestionSeconds'], 20);
    });

    test('Surprise extra time adds to the 20-second base for reverse_question', () {
      final extraTime30 = findCard('extra_time_30');
      final vm = createModel(surprise: extraTime30);
      addTearDown(vm.dispose);

      expect(vm.selectCategory('reverse_question'), isTrue);
      expect(vm.state.secondsRemaining, 20);

      // Reveal opening card (surprise card)
      expect(vm.revealCard(0), isTrue);

      // 20s base + 30s extra = 50s
      expect(vm.state.secondsRemaining, 50);
      expect(vm.state.roundData['initialQuestionSeconds'], 50);
    });

    test('Surprise half time reduces the 20-second base to 10 seconds', () {
      final halfTime = findCard('half_time');
      final vm = createModel(surprise: halfTime);
      addTearDown(vm.dispose);

      expect(vm.selectCategory('reverse_question'), isTrue);
      expect(vm.state.secondsRemaining, 20);

      // Reveal opening card
      expect(vm.revealCard(0), isTrue);

      // 20s base ~/ 2 = 10s
      expect(vm.state.secondsRemaining, 10);
      expect(vm.state.roundData['initialQuestionSeconds'], 10);
    });

    test('Refusing plank resets secondsRemaining to 20 for reverse_question', () {
      final plankCard = findCard('plank_time');
      final vm = createModel(surprise: plankCard);
      addTearDown(vm.dispose);

      expect(vm.selectCategory('reverse_question'), isTrue);
      expect(vm.revealCard(0), isTrue);

      expect(vm.canChoosePlank, isTrue);
      expect(vm.refusePlank(), isTrue);

      expect(vm.state.secondsRemaining, 20);
      expect(vm.state.roundData['initialQuestionSeconds'], 20);
    });
  });

  group('Reverse Question Asset Integrity', () {
    test('reverse_question.json loads and parses into valid questions', () async {
      final raw = await rootBundle.loadString('assets/questions/reverse_question.json');
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      expect(parsed['categoryId'], 'reverse_question');

      final questions = (parsed['questions'] as List<dynamic>)
          .map((item) => Question.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(questions.length, 700);

      for (final q in questions) {
        expect(q.categoryId, 'reverse_question');
        expect(q.text.isNotEmpty, isTrue);
        expect(
          q.text.contains('ما السؤال'),
          isFalse,
          reason: 'Redundant phrasing should be on the category, not on questions: ${q.id}',
        );
        expect(q.options.length, 6);
        expect(q.hint, isNotEmpty);
        expect(q.explanation, isNotEmpty);
        expect(q.sources, isNotEmpty);
        expect(q.qualityStatus, QuestionQualityStatus.reviewed);
        expect(
          q.options.singleWhere((o) => o.id == q.correctOptionId).text,
          q.answer,
        );
      }

      // Check representation across all 4 difficulty levels
      for (final diff in QuestionDifficulty.values) {
        expect(
          questions.where((q) => q.difficulty == diff).length,
          greaterThanOrEqualTo(5),
          reason: 'At least 5 questions for ${diff.name}',
        );
      }
    });
  });
}
