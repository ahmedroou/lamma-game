import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_controller.dart';
import 'package:lamma/core/game_catalog.dart';
import 'package:lamma/data/repositories/local_game_repository.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/question_bank_config.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/session_save.dart';
import 'package:lamma/domain/models/session_state.dart';
import 'package:lamma/domain/models/team.dart';
import '../fixtures/questions.dart';

class _BankBundle extends CachingAssetBundle {
  _BankBundle(this.documents);
  final Map<String, String> documents;
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(documents[key]!)));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Live catalog excludes every quarantine but preserves reviewed replacement',
    () async {
      final documents = <String, String>{
        for (final c in gameCategories)
          c.id: await rootBundle.loadString('assets/questions/${c.id}.json'),
      };
      final raw = parseQuestionBank(documents);
      final playable = (await LocalQuestionRepository.load()).forCategories(
        gameCategories.map((c) => c.id).toSet(),
      );
      expect(
        raw.length,
        documents.values.fold<int>(
          0,
          (sum, document) =>
              sum +
              ((jsonDecode(document) as Map<String, dynamic>)['questions']
                      as List)
                  .length,
        ),
      );
      // Editorial removal is allowed; targets are authoring caps, not a
      // requirement to reintroduce deleted or defective questions.
      expect(
        raw.length,
        lessThanOrEqualTo(
          QuestionBankConfig.totalFor(gameCategories.map((c) => c.id)),
        ),
      );
      expect(playable.where((q) => q.isQuarantined), isEmpty);
      expect(
        raw
            .where((q) => q.isQuarantined)
            .every((q) => q.qualityReasons.isNotEmpty),
        true,
      );
      expect(
        playable.map((q) => q.id).toSet(),
        raw.where((q) => !q.isQuarantined).map((q) => q.id).toSet(),
      );
      final replacement = playable.singleWhere(
        (q) => q.id == 'how_it_works-legendary-0074',
      );
      expect(replacement.text, contains('LIGO'));
      expect(replacement.options.length, 6);
      expect(replacement.hasKnownPlaceholderContent, isFalse);
    },
  );

  test(
    'Explicit quarantine and untagged legacy placeholder both stay out of new games',
    () async {
      final documents = <String, String>{};
      for (final c in gameCategories) {
        final document =
            jsonDecode(
                  await rootBundle.loadString('assets/questions/${c.id}.json'),
                )
                as Map<String, dynamic>;
        final q =
            (document['questions'] as List<dynamic>).first
                as Map<String, dynamic>;
        if (c.id == 'myths') {
          q['qualityStatus'] = 'quarantined';
          q['qualityReasons'] = [
            'Confirmed factual error, awaiting replacement',
          ];
        }
        if (c.id == 'how_it_works') {
          q.remove('qualityStatus');
          q.remove('qualityReasons');
          q['answer'] = 'الآلية الدقيقة المفسرة للعملية التخصصية 999';
          final correct = (q['options'] as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .singleWhere((o) => o['id'] == q['correctOptionId']);
          correct['text'] = q['answer'];
        }
        documents['assets/questions/${c.id}.json'] = jsonEncode(document);
      }
      final repo = await LocalQuestionRepository.load(
        bundle: _BankBundle(documents),
      );
      expect(
        repo.forCategories({'myths'}).any((q) => q.id == 'myths-easy-0001'),
        isFalse,
      );
      expect(
        repo
            .forCategories({'how_it_works'})
            .any((q) => q.id == 'how_it_works-easy-0001'),
        isFalse,
      );
    },
  );

  test(
    'Old snapshots keep scores and history and receive a quality notice',
    () async {
      final old = Question.fromJson({
        ...seedQuestions.first.toJson(),
        'answer': 'المبدأ الكمي/الترموديناميكي المعقد الحاكم للمنظومة 74',
      });
      final teams = [
        TeamState(id: 'a', name: 'أ', score: 300),
        TeamState(id: 'b', name: 'ب'),
      ];
      final config = SessionConfig(
        teams: teams,
        categoryIds: seedQuestions.take(6).map((q) => q.categoryId),
      );
      final stamp = DateTime(2026, 10, 13);
      final save = SessionSave(
        id: 'old-quality-save',
        config: config,
        state: SessionState(
          phase: SessionPhase.categories,
          teams: teams,
          seenQuestionIds: {old.id},
        ),
        questions: [old, ...seedQuestions.skip(1).take(5)],
        createdAt: stamp,
        updatedAt: stamp,
        revision: 0,
      );
      final storage = MemoryGameRepository();
      await storage.saveSession(save);
      final app = AppController(
        storage,
        questions: LocalQuestionRepository(questions: completeQuestions),
        openingCardsEnabled: false,
      );
      addTearDown(app.dispose);
      await app.initialize();
      expect(app.notice, contains('أسئلة قديمة'));
      expect(app.session!.state.teams.first.score, 300);
      expect(app.session!.state.seenQuestionIds, contains(old.id));
      expect(
        (await storage.load()).session!.questions.first.answer,
        old.answer,
      );
      expect(app.session!.snapshot().questions.first.id, old.id);
    },
  );

  test(
    'Saved untagged questions excluded by the current catalog are blocked from new draws',
    () async {
      final repo = MemoryGameRepository();
      final config = SessionConfig(
        teams: [
          TeamState(id: 'a', name: 'a'),
          TeamState(id: 'b', name: 'b'),
        ],
        categoryIds: seedQuestions.take(6).map((q) => q.categoryId),
      );
      final save = SessionSave(
        id: 'before-review',
        config: config,
        state: SessionState(
          phase: SessionPhase.categories,
          teams: config.teams,
          seenQuestionIds: const {},
        ),
        questions: seedQuestions.take(6),
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        revision: 0,
      );
      await repo.saveSession(save);
      final active = [
        ...seedQuestions.skip(1),
        Question(
          id: 'myths-replacement',
          categoryId: 'myths',
          text: 'بديل صالح',
          answer: 'جواب',
          difficulty: QuestionDifficulty.easy,
        ),
      ];
      final app = AppController(
        repo,
        questions: LocalQuestionRepository(questions: active),
        openingCardsEnabled: false,
      );
      await app.initialize();
      expect(app.notice, contains('إصلاح'));
      app.session!.resume();
      expect(app.session!.selectCategory('myths'), false);
      expect(app.session!.selectCategory('spacetoon'), true);
      app.dispose();
    },
  );
  test('Quality metadata round-trips and unknown statuses fail closed', () {
    final json = {
      ...seedQuestions.first.toJson(),
      'qualityStatus': 'quarantined',
      'qualityReasons': ['bad premise'],
    };
    final q = Question.fromJson(json);
    expect(q.isQuarantined, isTrue);
    expect(Question.fromJson(q.toJson()).qualityReasons, ['bad premise']);
    expect(
      () => Question.fromJson({...json, 'qualityStatus': 'looks-fine'}),
      throwsFormatException,
    );
    expect(
      Question.fromJson(seedQuestions.first.toJson()).qualityStatus,
      QuestionQualityStatus.unreviewed,
    );
  });
}
