import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:lamma/core/app_controller.dart';
import 'package:lamma/data/repositories/local_game_repository.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/question_usage.dart';
import 'package:lamma/features/session/session_view_model.dart';
import '../fixtures/questions.dart';
import 'session_management_test.dart' show managementConfig, managementModel;

final numericQuestions = [
  for (var i = 0; i < completeQuestions.length; i++)
    Question.fromJson({
      ...completeQuestions[i].toJson(),
      'usageId': '${100000 + i}',
    }),
];
Map<String, Object?> signed(Map<String, Object?> raw) {
  Object? canonical(Object? value) {
    if (value is Map) {
      final keys = value.keys.cast<String>().toList()..sort();
      return {for (final key in keys) key: canonical(value[key])};
    }
    if (value is List) return value.map(canonical).toList();
    return value;
  }

  return {
    ...raw,
    '_checksum': sha256
        .convert(utf8.encode(jsonEncode(canonical(raw))))
        .toString(),
  };
}

void main() {
  test(
    'Numeric usage identity survives edits and ignores identical text on another number',
    () {
      final first = numericQuestions.first;
      final edited = Question.fromJson({
        ...first.toJson(),
        'text': 'صياغة معدلة',
        'imageAsset': 'assets/question_media/new.webp',
      });
      final different = Question.fromJson({
        ...first.toJson(),
        'id': 'another',
        'usageId': '900000',
      });
      final usage = QuestionUsage()..mark(first);
      expect(usage.contains(edited), true);
      expect(usage.contains(different), false);
      expect(questionUsageKey(first), '100000');
      expect(
        () => Question.fromJson({...first.toJson(), 'usageId': 100000}),
        throwsFormatException,
      );
    },
  );
  for (var remaining = 1; remaining < 5; remaining++) {
    test(
      '$remaining new questions lead the quota; old questions fill five without duplicates',
      () {
        final group = numericQuestions
            .where((q) => q.categoryId == 'myths')
            .toList();
        final usage = QuestionUsage();
        for (final q in group.take(group.length - remaining)) {
          usage.mark(q);
        }
        final plan = planMatchQuestions(
          questions: numericQuestions,
          categoryIds: managementConfig().categoryIds,
          usage: usage,
        );
        final selected = plan.where((q) => q.categoryId == 'myths').toList();
        expect(selected.length, 5);
        expect(selected.map(questionUsageKey).toSet().length, 5);
        expect(selected.take(remaining).every((q) => !usage.contains(q)), true);
        expect(selected.skip(remaining).every(usage.contains), true);
      },
    );
  }
  test(
    'Zero unused questions require explicit renewal; a bank smaller than five is not fabricated',
    () {
      final usage = QuestionUsage();
      for (final q in numericQuestions.where((q) => q.categoryId == 'myths')) {
        usage.mark(q);
      }
      expect(
        () => planMatchQuestions(
          questions: numericQuestions,
          categoryIds: managementConfig().categoryIds,
          usage: usage,
        ),
        throwsA(isA<InsufficientQuestions>()),
      );
      expect(
        () => planMatchQuestions(
          questions: seedQuestions,
          categoryIds: managementConfig().categoryIds,
          usage: QuestionUsage(),
        ),
        throwsA(isA<InsufficientQuestions>()),
      );
    },
  );
  test(
    'Controller permits four remaining questions and saves one replay allowance through restoration',
    () async {
      final repo = MemoryGameRepository();
      for (final q
          in numericQuestions.where((q) => q.categoryId == 'myths').take(8)) {
        repo.usage.mark(q);
      }
      final app = AppController(
        repo,
        questions: LocalQuestionRepository(questions: numericQuestions),
        openingCardsEnabled: false,
      );
      await app.initialize();
      expect(app.availableQuestionsForCategory('myths'), 4);
      expect(app.canPlayCategory('myths'), true);
      final vm = await app.startSession(managementConfig());
      expect(vm.snapshot().replayQuestionIds.length, 1);
      for (var i = 0; i < 5; i++) {
        expect(vm.selectCategory('myths'), true);
        vm.revealCard(0);
        vm.revealCard(1);
        expect(await vm.revealQuestion(), true);
        vm.showAnswer();
        expect(vm.awardAnswer(vm.state.activeTeam.id), true);
      }
      await app.flush();
      expect(vm.remainingForCategory('myths'), 0);
      expect(vm.state.seenQuestionIds.length, 5);
      expect(
        vm.state.teams.fold<int>(0, (sum, team) => sum + team.score),
        1000,
      );
      expect(app.isCategoryExhausted('myths'), true);
      final reopened = AppController(
        repo,
        questions: LocalQuestionRepository(questions: numericQuestions),
        openingCardsEnabled: false,
      );
      await reopened.initialize();
      expect(reopened.session!.snapshot().replayQuestionIds.length, 1);
      expect(
        reopened.session!.state.history
            .map((r) => r.question.id)
            .toSet()
            .length,
        5,
      );
      reopened.dispose();
      app.dispose();
    },
  );
  test(
    'Native replay resumes unshown, commits only once and cannot repeat after older-backup recovery',
    () async {
      final database = await databaseFactoryMemory.openDatabase(
        'numeric-replay-native',
      );
      final repo = SembastGameRepository(database);
      addTearDown(repo.close);
      await repo.prepareUsage(numericQuestions);
      final store = stringMapStoreFactory.store('question_usage_v1');
      final page = base64Decode(
        (await store.record('page.0').get(database))!['bits'] as String,
      ).toList();
      for (final q
          in numericQuestions.where((q) => q.categoryId == 'myths').take(8)) {
        final index =
            (await store.record('number.${q.usageId}').get(database))!['index']
                as int;
        page[index ~/ 8] |= 1 << (index % 8);
      }
      await store
          .record('page.0')
          .put(database, signed({'bits': base64Encode(page)}));
      final usage = await repo.prepareUsage(numericQuestions);
      final plan = planMatchQuestions(
        questions: numericQuestions,
        categoryIds: managementConfig().categoryIds,
        usage: usage,
      );
      final vm = SessionViewModel(
        config: managementConfig(),
        questions: LocalQuestionRepository(questions: plan),
        usage: usage,
        commitReveal: repo.commitQuestion,
        replayQuestionIds: plan.where(usage.contains).map((q) => q.id),
      );
      addTearDown(vm.dispose);
      await repo.saveSession(vm.snapshot());
      for (var i = 0; i < 4; i++) {
        vm.selectCategory('myths');
        vm.revealCard(0);
        vm.revealCard(1);
        expect(await vm.revealQuestion(), true);
        vm.showAnswer();
        vm.awardAnswer(null);
      }
      vm.selectCategory('myths');
      vm.revealCard(0);
      vm.revealCard(1);
      final before = vm.snapshot();
      await repo.saveSession(before);
      final restored = SessionViewModel.restore(
        (await repo.load()).session!,
        usage: await repo.prepareUsage(numericQuestions),
        commitReveal: repo.commitQuestion,
      );
      addTearDown(restored.dispose);
      expect(restored.state.question!.id, before.state.question!.id);
      restored.resume();
      expect(await restored.revealQuestion(), true);
      await expectLater(
        repo.commitQuestion(restored.snapshot(), restored.state.question!),
        throwsStateError,
      );
      await SembastGameRepository.store
          .record(SembastGameRepository.backupKey)
          .put(database, signed(before.toJson()));
      final damaged = Map<String, Object?>.from(
        (await SembastGameRepository.store
            .record(SembastGameRepository.currentKey)
            .get(database))!,
      );
      damaged['_checksum'] = 'broken';
      await SembastGameRepository.store
          .record(SembastGameRepository.currentKey)
          .put(database, damaged);
      final recovery = SessionViewModel.restore(
        (await repo.load()).session!,
        usage: await repo.prepareUsage(numericQuestions),
        commitReveal: repo.commitQuestion,
      );
      addTearDown(recovery.dispose);
      expect(recovery.state.question, isNull);
      expect(recovery.remainingForCategory('myths'), 0);
    },
  );
  test(
    'Playing a legacy saved question marks its current numeric identity before starting another match',
    () async {
      final repo = MemoryGameRepository();
      final old = managementModel();
      addTearDown(old.dispose);
      old.selectCategory('myths');
      old.revealCard(0);
      old.revealCard(1);
      await repo.saveSession(old.snapshot());
      final app = AppController(
        repo,
        questions: LocalQuestionRepository(questions: numericQuestions),
        openingCardsEnabled: false,
      );
      await app.initialize();
      app.session!.resume();
      expect(await app.session!.revealQuestion(), true);
      app.session!.showAnswer();
      app.session!.awardAnswer(null);
      await app.flush();
      final next = await app.startSession(managementConfig());
      expect(
        next.snapshot().questions.any((q) => q.id == numericQuestions.first.id),
        false,
      );
      app.dispose();
    },
  );
}
