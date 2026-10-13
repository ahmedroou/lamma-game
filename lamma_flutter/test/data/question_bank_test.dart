import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/game_catalog.dart';
import 'package:lamma/core/app_controller.dart';
import 'package:lamma/data/repositories/local_game_repository.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/question_bank_config.dart';

Future<List<Question>> verifyQuestionBank({bool complete = false}) async {
  final files = Directory('assets/questions')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .toList();
  expect(files.length, gameCategories.length);
  final documents = <String, String>{
    for (final category in gameCategories)
      category.id: await rootBundle.loadString(
        'assets/questions/${category.id}.json',
      ),
  };
  // Validate ALL authoring rows, including quarantined ones. Gameplay filters
  // them separately; excluding them here would conceal structural defects.
  final repository = LocalQuestionRepository(
    questions: parseQuestionBank(documents),
  );
  final all = repository.forCategories(gameCategories.map((c) => c.id).toSet());
  for (final category in gameCategories) {
    final questions = repository.forCategories({category.id});
    expect(questions, isNotEmpty, reason: category.id);
    for (final level in QuestionDifficulty.values) {
      final count = questions.where((q) => q.difficulty == level).length;
      expect(
        count,
        complete
            ? QuestionBankConfig.perDifficultyFor(category.id)
            : lessThanOrEqualTo(
                QuestionBankConfig.perDifficultyFor(category.id),
              ),
        reason: '${category.id}/${level.name}',
      );
    }
    if (complete) {
      expect(
        questions.length,
        QuestionBankConfig.countFor(category.id),
        reason: category.id,
      );
      final json =
          jsonDecode(
                await rootBundle.loadString(
                  'assets/questions/${category.id}.json',
                ),
              )
              as Map<String, dynamic>;
      expect(json['status'], 'complete', reason: category.id);
    }
    for (final q in questions) {
      expect(q.id, matches('^${category.id}-${q.difficulty.name}-[0-9]{4}\$'));
      expect(q.hint, isNotEmpty);
      expect(q.options.length, 6);
      expect(
        q.options.singleWhere((option) => option.id == q.correctOptionId).text,
        isIn([q.answer, ...q.acceptedAnswers]),
      );
      if (complete) {
        expect(q.sources, isNotEmpty, reason: 'Sources: ${q.id}');
        expect(
          q.qualityStatus,
          QuestionQualityStatus.reviewed,
          reason: 'Editorial review required: ${q.id}',
        );
        expect(q.isQuarantined, isFalse, reason: 'Quarantined: ${q.id}');
      }
      expect(
        Question.fromJson(
          jsonDecode(jsonEncode(q.toJson())) as Map<String, dynamic>,
        ).toJson(),
        q.toJson(),
      );
      if (q.imageAsset != null) {
        expect(
          (await rootBundle.load(q.imageAsset!)).lengthInBytes,
          greaterThan(0),
        );
      }
    }
  }
  return all;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Approved local bank loads, round-trips and validates all media',
    () async {
      final questions = await verifyQuestionBank();
      expect(gameCategories.length, 24);
      expect(questions.map((q) => q.categoryId).toSet().length, 24);
      expect(
        gameCategories.any(
          (c) => [
            'general',
            'sports',
            'cinema',
            'science',
            'language',
            'history',
            'technology',
          ].contains(c.id),
        ),
        false,
      );
    },
  );
  test(
    'A changed map image cannot introduce a second playable copy of one prompt',
    () async {
      final document =
          jsonDecode(await rootBundle.loadString('assets/questions/maps.json'))
              as Map<String, dynamic>;
      final originals = (document['questions'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final first = Map<String, dynamic>.from(
        originals.singleWhere((q) => q['id'] == 'maps-hard-0134'),
      );
      final second = Map<String, dynamic>.from(
        originals.singleWhere((q) => q['id'] == 'maps-hard-0138'),
      );
      second['text'] = first['text'];
      first.remove('qualityStatus');
      first.remove('qualityReasons');
      second.remove('qualityStatus');
      second.remove('qualityReasons');
      expect(first['imageAsset'], isNot(second['imageAsset']));
      document['questions'] = [first, second];
      Map<String, String> encoded() => {'maps': jsonEncode(document)};
      expect(() => parseQuestionBank(encoded()), throwsFormatException);
      second['qualityStatus'] = 'quarantined';
      second['qualityReasons'] = ['duplicate_question_in_category'];
      expect(parseQuestionBank(encoded()), hasLength(2));
      second.remove('qualityStatus');
      second.remove('qualityReasons');
      second['imageAsset'] = first['imageAsset'];
      expect(() => parseQuestionBank(encoded()), throwsFormatException);
      first.remove('imageAsset');
      first.remove('imageDescription');
      second.remove('imageAsset');
      second.remove('imageDescription');
      expect(() => parseQuestionBank(encoded()), throwsFormatException);
    },
  );
  test('Malformed banks fail before a game starts', () async {
    final original =
        jsonDecode(
              await rootBundle.loadString('assets/questions/who_am_i.json'),
            )
            as Map<String, dynamic>;
    for (final mutate in <void Function(Map<String, dynamic>)>[
      (q) => q.remove('usageId'),
      (q) => q['usageId'] = 12345,
      (q) => q.remove('hint'),
      (q) => q['clues'] = ['واحد', 'اثنان'],
      (q) => q['clues'] = ['واحد', 'واحد', 'ثلاثة'],
      (q) => q['categoryId'] = 'general',
      (q) => q['imageAsset'] = 'https://example.com/image.png',
      (q) => q.remove('options'),
      (q) => q['correctOptionId'] = 'Z',
      (q) => (q['options'] as List<dynamic>).removeLast(),
      (q) => (q['options'] as List<dynamic>)[1] =
          (q['options'] as List<dynamic>)[0],
      (q) =>
          (q['options'] as List<dynamic>)[2] = {'id': 'C', 'text': q['answer']},
    ]) {
      final document = jsonDecode(jsonEncode(original)) as Map<String, dynamic>;
      mutate(
        (document['questions'] as List<dynamic>).first as Map<String, dynamic>,
      );
      expect(
        () => parseQuestionBank({'who_am_i': jsonEncode(document)}),
        throwsFormatException,
      );
    }
    final document = jsonDecode(jsonEncode(original)) as Map<String, dynamic>;
    (document['questions'] as List<dynamic>).add(
      (document['questions'] as List<dynamic>).first,
    );
    expect(
      () => parseQuestionBank({'who_am_i': jsonEncode(document)}),
      throwsFormatException,
    );
  });

  test(
    'Production start loads JSON assets and preserves hidden options in saves',
    () async {
      final app = AppController(MemoryGameRepository());
      await app.initialize();
      final vm = await app.startSession(
        SessionConfig(
          teams: [
            TeamState(id: 'a', name: 'أ'),
            TeamState(id: 'b', name: 'ب'),
          ],
          categoryIds: gameCategories.take(6).map((category) => category.id),
        ),
      );
      expect(vm.selectCategory('myths'), true);
      expect(vm.state.surpriseCard, isNotNull);
      expect(vm.state.question!.options.length, 6);
      await app.flush();
      final saved = await app.repository.load();
      expect(saved.session!.state.question!.options.length, 6);
      expect(
        saved.session!.state.question!.correctOptionId,
        vm.state.question!.correctOptionId,
      );
      app.dispose();
    },
  );
}
