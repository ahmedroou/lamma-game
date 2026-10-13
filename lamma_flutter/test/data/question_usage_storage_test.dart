import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast_io.dart';
import 'package:lamma/data/repositories/local_game_repository.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:crypto/crypto.dart';
import '../features/numeric_usage_fallback_test.dart' show signed;
import 'package:lamma/domain/models/session_save.dart';
import 'package:lamma/features/session/session_view_model.dart';
import '../fixtures/questions.dart';
import '../features/session_management_test.dart' show managementModel;

final usageStore = stringMapStoreFactory.store('question_usage_v1');

void main() {
  late Directory directory;
  late String databasePath;
  late SembastGameRepository repository;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('lamma-usage-test-');
    databasePath = path.join(directory.path, 'device.db');
    repository = SembastGameRepository(
      await databaseFactoryIo.openDatabase(databasePath),
    );
  });
  tearDown(() async {
    await repository.close();
    final resolved = path.normalize(path.absolute(directory.path));
    if (!path.isWithin(
      path.normalize(path.absolute(Directory.systemTemp.path)),
      resolved,
    )) {
      throw StateError('Unsafe test cleanup path.');
    }
    await directory.delete(recursive: true);
  });
  Future<SessionViewModel> checkpoint() async {
    await repository.prepareUsage(seedQuestions);
    final vm = managementModel();
    addTearDown(vm.dispose);
    vm.selectCategory('myths');
    vm.revealCard(0);
    vm.revealCard(1);
    await repository.saveSession(vm.snapshot());
    return vm;
  }

  test(
    'Use bit and visible question checkpoint survive a real database reopen',
    () async {
      final vm = await checkpoint();
      vm.revealCard(2);
      await repository.commitQuestion(vm.snapshot(), vm.state.question!);
      await repository.close();
      repository = SembastGameRepository(
        await databaseFactoryIo.openDatabase(databasePath),
      );
      final usage = await repository.prepareUsage(seedQuestions);
      expect(usage.contains(seedQuestions.first), true);
      expect(usage.contains(seedQuestions[1]), false);
      final saved = (await repository.load()).session!;
      expect(saved.state.revealedCards, 3);
      final resumed = SessionViewModel.restore(
        saved,
        usage: usage,
        commitReveal: repository.commitQuestion,
      );
      addTearDown(resumed.dispose);
      expect(resumed.state.isPaused, true);
      resumed.resume();
      expect(resumed.showAnswer(), true);
      expect(resumed.awardAnswer(null), true);
      expect(resumed.selectCategory('myths'), false);
    },
  );
  test(
    'Older session writes cannot roll back device use; duplicate commits are refused',
    () async {
      final vm = await checkpoint();
      final before = vm.snapshot();
      vm.revealCard(2);
      await repository.commitQuestion(vm.snapshot(), vm.state.question!);
      await expectLater(
        repository.commitQuestion(vm.snapshot(), vm.state.question!),
        throwsStateError,
      );
      final oldReplacement = SessionSave(
        id: 'another-session',
        config: before.config,
        state: before.state,
        questions: before.questions,
        createdAt: before.createdAt,
        updatedAt: before.updatedAt,
        revision: 0,
      );
      await repository.saveSession(oldReplacement);
      final usage = await repository.prepareUsage(seedQuestions);
      expect(usage.contains(seedQuestions.first), true);
    },
  );
  test(
    'Transaction refusal leaves both the use bit and checkpoint unchanged',
    () async {
      final vm = await checkpoint();
      vm.revealCard(2);
      final proposed = vm.snapshot();
      final newer = SessionSave(
        id: proposed.id,
        config: proposed.config,
        state: proposed.state.copyWith(revealedCards: 2, seenQuestionIds: {}),
        questions: proposed.questions,
        createdAt: proposed.createdAt,
        updatedAt: proposed.updatedAt,
        revision: proposed.revision + 10,
      );
      await repository.saveSession(newer);
      await expectLater(
        repository.commitQuestion(proposed, vm.state.question!),
        throwsStateError,
      );
      final usage = await repository.prepareUsage(seedQuestions);
      expect(usage.contains(seedQuestions.first), false);
      expect((await repository.load()).session!.revision, newer.revision);
    },
  );
  test(
    'Legacy revealed questions migrate from both latest and previous checkpoints',
    () async {
      final vm = managementModel();
      addTearDown(vm.dispose);
      vm.selectCategory('myths');
      for (var i = 0; i < 3; i++) {
        vm.revealCard(i);
      }
      await repository.saveSession(vm.snapshot());
      final other = managementModel();
      addTearDown(other.dispose);
      await repository.saveSession(other.snapshot());
      final usage = await repository.prepareUsage(seedQuestions);
      expect(usage.contains(seedQuestions.first), true);
    },
  );
  test(
    'Text is not a device usage identity; editing an existing ID retains its history',
    () async {
      final vm = await checkpoint();
      vm.revealCard(2);
      await repository.commitQuestion(vm.snapshot(), vm.state.question!);
      final original = seedQuestions.first;
      final renamed = Question(
        id: 'new-edition',
        categoryId: 'maps',
        text: '  ${original.text}  ',
        answer: original.answer,
        difficulty: original.difficulty,
      );
      final usage = await repository.prepareUsage([...seedQuestions, renamed]);
      expect(usage.contains(renamed), false);
      final changed = Question(
        id: original.id,
        categoryId: original.categoryId,
        text: 'صياغة جديدة للسؤال نفسه',
        answer: original.answer,
        difficulty: original.difficulty,
      );
      expect(
        (await repository.prepareUsage([changed])).contains(changed),
        true,
      );
    },
  );
  test('Timer and judgment saves never rewrite bitmap pages', () async {
    final vm = await checkpoint();
    vm.revealCard(2);
    await repository.commitQuestion(vm.snapshot(), vm.state.question!);
    final pageBefore = await usageStore
        .record('page.0')
        .get(repository.database);
    vm.pause();
    await repository.saveSession(vm.snapshot());
    vm.resume();
    vm.showAnswer();
    vm.awardAnswer('a');
    await repository.saveSession(vm.snapshot());
    expect(
      await usageStore.record('page.0').get(repository.database),
      pageBefore,
    );
  });
  test(
    'Page corruption blocks play instead of clearing used questions',
    () async {
      await repository.prepareUsage(seedQuestions);
      final raw = await usageStore.record('page.0').get(repository.database);
      final damaged = jsonDecode(jsonEncode(raw)) as Map<String, Object?>;
      damaged['bits'] = base64Encode(List.filled(512, 0));
      damaged['_checksum'] = 'broken';
      await usageStore.record('page.0').put(repository.database, damaged);
      await expectLater(
        repository.prepareUsage(seedQuestions),
        throwsFormatException,
      );
      expect(
        await usageStore.record('page.0').get(repository.database),
        damaged,
      );
    },
  );
  test('Missing identity records or an entire ledger fail closed', () async {
    await repository.prepareUsage(seedQuestions);
    final rows = await usageStore.find(repository.database);
    final alias = rows.firstWhere((row) => row.key.startsWith('id.'));
    await usageStore.record(alias.key).delete(repository.database);
    await expectLater(
      repository.prepareUsage(seedQuestions),
      throwsFormatException,
    );
    await usageStore.delete(repository.database);
    await expectLater(
      repository.prepareUsage(seedQuestions),
      throwsFormatException,
    );
  });
  test(
    'Backup before a committed reveal skips the used question rather than reselecting it',
    () async {
      final vm = await checkpoint();
      vm.revealCard(2);
      await repository.commitQuestion(vm.snapshot(), vm.state.question!);
      final raw = await SembastGameRepository.store
          .record(SembastGameRepository.currentKey)
          .get(repository.database);
      final damaged = jsonDecode(jsonEncode(raw)) as Map<String, Object?>;
      damaged['_checksum'] = 'broken';
      await SembastGameRepository.store
          .record(SembastGameRepository.currentKey)
          .put(repository.database, damaged);
      final usage = await repository.prepareUsage(seedQuestions);
      final restored = SessionViewModel.restore(
        (await repository.load()).session!,
        usage: usage,
        commitReveal: repository.commitQuestion,
      );
      addTearDown(restored.dispose);
      expect(restored.state.phase, SessionPhase.categories);
      expect(restored.state.question, isNull);
      restored.resume();
      expect(restored.selectCategory('myths'), false);
    },
  );
  test(
    'Selected opponent survives a real database reopen without another draw',
    () async {
      final vm = await checkpoint();
      vm.revealCard(2);
      await repository.commitQuestion(vm.snapshot(), vm.state.question!);
      vm.startOpponentOpportunity();
      final selected = vm.state.opponentTeamId;
      vm.pause();
      await repository.saveSession(vm.snapshot());
      await repository.close();
      repository = SembastGameRepository(
        await databaseFactoryIo.openDatabase(databasePath),
      );
      final usage = await repository.prepareUsage(seedQuestions);
      final restored = SessionViewModel.restore(
        (await repository.load()).session!,
        usage: usage,
        commitReveal: repository.commitQuestion,
      );
      addTearDown(restored.dispose);
      expect(restored.state.opponentTeamId, selected);
      expect(restored.state.secondsRemaining, 7);
      expect(restored.state.opponentSelectedByLot, true);
      expect(restored.resume(), true);
      expect(restored.startOpponentOpportunity(), false);
      expect(restored.showAnswer(), false);
    },
  );
  test(
    'Category renewal persists, preserves other bits, and is not undone by old snapshots',
    () async {
      final vm = await checkpoint();
      vm.revealCard(2);
      await repository.commitQuestion(vm.snapshot(), vm.state.question!);
      vm.showAnswer();
      vm.awardAnswer('a');
      vm.selectCategory('spacetoon');
      vm.revealCard(0);
      vm.revealCard(1);
      await repository.saveSession(vm.snapshot());
      vm.revealCard(2);
      await repository.commitQuestion(vm.snapshot(), vm.state.question!);
      final question = vm.state.question!;
      final renewed = await repository.resetCategory('myths', seedQuestions);
      expect(renewed.contains(seedQuestions.first), false);
      expect(renewed.contains(question), true);
      await expectLater(
        repository.resetCategory('myths', seedQuestions),
        throwsStateError,
      );
      await repository.close();
      repository = SembastGameRepository(
        await databaseFactoryIo.openDatabase(databasePath),
      );
      final usage = await repository.prepareUsage(seedQuestions);
      expect(usage.contains(seedQuestions.first), false);
      expect(usage.contains(question), true);
      final resumed = SessionViewModel.restore(
        (await repository.load()).session!,
        usage: usage,
      );
      addTearDown(resumed.dispose);
      expect(resumed.state.teams.first.score, 200);
      expect(resumed.remainingForCategory('myths'), 0);
      expect(usage.contains(seedQuestions.first), false);
      final raw = await usageStore.record('meta').get(repository.database);
      expect((raw!['cycles'] as Map)['myths'], 1);
    },
  );
  test(
    'Renewal refuses incomplete exhaustion and corrupt history without modifying bits',
    () async {
      await repository.prepareUsage(seedQuestions);
      final before = await usageStore.record('page.0').get(repository.database);
      await expectLater(
        repository.resetCategory('myths', seedQuestions),
        throwsStateError,
      );
      expect(
        await usageStore.record('page.0').get(repository.database),
        before,
      );
      final raw = jsonDecode(jsonEncode(before)) as Map<String, Object?>;
      raw['_checksum'] = 'broken';
      await usageStore.record('page.0').put(repository.database, raw);
      await expectLater(
        repository.resetCategory('myths', seedQuestions),
        throwsFormatException,
      );
      expect(await usageStore.record('page.0').get(repository.database), raw);
    },
  );
  test(
    'Old text-sharing ledger migrates to independent numeric slots and survives a real reopen',
    () async {
      final numbered = [
        for (var i = 0; i < seedQuestions.length; i++)
          Question.fromJson({
            ...seedQuestions[i].toJson(),
            'usageId': '${80000 + i}',
          }),
      ];
      final page = List.filled(512, 0)..[0] = 1;
      for (var i = 0; i < seedQuestions.length; i++) {
        final index = i == 1 ? 0 : i;
        final idKey = 'id.${sha256.convert(utf8.encode(seedQuestions[i].id))}';
        await usageStore
            .record(idKey)
            .put(repository.database, signed({'index': index}));
        await usageStore
            .record('content.old-$i')
            .put(repository.database, signed({'index': index}));
      }
      await usageStore
          .record('page.0')
          .put(repository.database, signed({'bits': base64Encode(page)}));
      await usageStore
          .record('meta')
          .put(
            repository.database,
            signed({
              'version': 1,
              'next': seedQuestions.length,
              'aliases': seedQuestions.length * 2,
            }),
          );
      final usage = await repository.prepareUsage(numbered);
      expect(usage.contains(numbered[0]), true);
      expect(usage.contains(numbered[1]), true);
      final first = await usageStore
          .record('number.${numbered[0].usageId}')
          .get(repository.database);
      final second = await usageStore
          .record('number.${numbered[1].usageId}')
          .get(repository.database);
      expect(first!['index'], isNot(second!['index']));
      await repository.resetCategory('myths', numbered);
      await repository.close();
      repository = SembastGameRepository(
        await databaseFactoryIo.openDatabase(databasePath),
      );
      final reopened = await repository.prepareUsage(numbered);
      expect(reopened.contains(numbered[0]), false);
      expect(reopened.contains(numbered[1]), true);
      final edited = Question.fromJson({
        ...numbered[1].toJson(),
        'text': 'نص مختلف تماماً',
        'answer': 'جواب محرر',
      });
      expect(
        (await repository.prepareUsage([
          ...numbered.where((q) => q.id != edited.id),
          edited,
        ])).contains(edited),
        true,
      );
      final changedNumber = Question.fromJson({
        ...edited.toJson(),
        'usageId': '99999',
      });
      await expectLater(
        repository.prepareUsage([changedNumber]),
        throwsStateError,
      );
    },
  );
  test(
    'Dense use bitmap crosses pages without allocating one byte per question',
    () async {
      final large = List.generate(
        4100,
        (i) => Question(
          id: 'large-$i',
          categoryId: 'myths',
          text: 'حالة حجم $i',
          answer: 'إجابة',
          difficulty: QuestionDifficulty.easy,
        ),
      );
      await repository.prepareUsage(large);
      final rows = await usageStore.find(repository.database);
      final pages = rows.where((row) => row.key.startsWith('page.')).toList();
      expect(pages.length, 2);
      expect(
        pages.every(
          (row) => base64Decode(row.value['bits'] as String).length == 512,
        ),
        true,
      );
    },
  );
}
