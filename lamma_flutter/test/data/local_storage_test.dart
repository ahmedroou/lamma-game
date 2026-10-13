import 'package:lamma/data/repositories/question_repository.dart';
import '../fixtures/questions.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:lamma/core/app_controller.dart';
import 'package:lamma/data/repositories/local_game_repository.dart';
import 'package:lamma/domain/models/app_settings.dart';
import 'package:lamma/domain/models/session_save.dart';
import 'package:lamma/features/session/session_view_model.dart';
import '../features/session_management_test.dart'
    show managementConfig, managementModel, completeRound;

int _databaseId = 0;
Future<SembastGameRepository> memoryDatabase() async => SembastGameRepository(
  await databaseFactoryMemory.openDatabase('test-${_databaseId++}'),
);

Future<void> completeStoredRound(
  SessionViewModel vm,
  String category,
  String? winner,
) async {
  expect(vm.selectCategory(category), true);
  vm.revealCard(0);
  vm.revealCard(1);
  expect(await vm.revealQuestion(), true);
  expect(vm.showAnswer(), true);
  expect(vm.awardAnswer(winner), true);
}

class _FailingRepository extends MemoryGameRepository {
  bool fail = false;
  @override
  Future<void> saveSession(SessionSave value) async {
    if (fail) throw StateError('Injected disk failure');
    await super.saveSession(value);
  }

  @override
  Future<void> saveSettings(AppSettings value) async {
    if (fail) throw StateError('Injected disk failure');
    await super.saveSettings(value);
  }
}

class _SlowRepository extends MemoryGameRepository {
  Completer<void>? gate;
  @override
  Future<void> saveSession(SessionSave value) async {
    await gate?.future;
    await super.saveSession(value);
  }
}

void main() {
  test(
    'Checksum catches well-formed score corruption and settings use a backup',
    () async {
      final repo = await memoryDatabase();
      addTearDown(repo.close);
      final vm = managementModel();
      addTearDown(vm.dispose);
      await repo.saveSettings(const AppSettings(haptics: false));
      await repo.saveSettings(const AppSettings(motion: false, haptics: false));
      await repo.saveSession(vm.snapshot());
      completeRound(vm, 'myths', 'a');
      await repo.saveSession(vm.snapshot());
      final raw =
          jsonDecode(
                jsonEncode(
                  await SembastGameRepository.store
                      .record(SembastGameRepository.currentKey)
                      .get(repo.database),
                ),
              )
              as Map<String, Object?>;
      final state = raw['state'] as Map<String, Object?>;
      final firstTeam =
          (state['teams'] as List<Object?>).first as Map<String, Object?>;
      firstTeam['score'] = 99999;
      await SembastGameRepository.store
          .record(SembastGameRepository.currentKey)
          .put(repo.database, raw);
      final settings =
          jsonDecode(
                jsonEncode(
                  await SembastGameRepository.store
                      .record(SembastGameRepository.settingsKey)
                      .get(repo.database),
                ),
              )
              as Map<String, Object?>;
      settings['haptics'] = true;
      await SembastGameRepository.store
          .record(SembastGameRepository.settingsKey)
          .put(repo.database, settings);
      final recovered = await repo.load();
      expect(recovered.session!.state.teams.first.score, 0);
      expect(recovered.settings.haptics, false);
      expect(recovered.settings.motion, true);
    },
  );
  test(
    'Real file store survives close and reopen without network or UI plugins',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'lamma-storage-test-',
      );
      final file = path.join(directory.path, 'state.db');
      final vm = managementModel(withCard: true);
      completeRound(vm, 'myths', 'a');
      vm.pause();
      var repo = SembastGameRepository(
        await databaseFactoryIo.openDatabase(file),
      );
      await repo.saveSettings(const AppSettings(motion: false, haptics: false));
      await repo.saveSession(vm.snapshot());
      await repo.close();
      repo = SembastGameRepository(await databaseFactoryIo.openDatabase(file));
      final load = await repo.load();
      expect(load.settings.motion, false);
      expect(load.settings.haptics, false);
      expect(load.session!.state.teams.first.score, 200);
      expect(load.session!.state.teams.first.inventory.length, 1);
      expect(load.session!.state.history.length, 1);
      await repo.close();
      vm.dispose();
      expect(path.isWithin(Directory.systemTemp.path, directory.path), true);
      await directory.delete(recursive: true);
    },
  );
  test(
    'Corrupt latest snapshot recovers prior valid snapshot without dropping settings',
    () async {
      final repo = await memoryDatabase();
      addTearDown(repo.close);
      final vm = managementModel();
      addTearDown(vm.dispose);
      await repo.saveSettings(const AppSettings(motion: false));
      await repo.saveSession(vm.snapshot());
      completeRound(vm, 'myths', 'a');
      await repo.saveSession(vm.snapshot());
      await SembastGameRepository.store
          .record(SembastGameRepository.currentKey)
          .put(repo.database, {'version': 1, 'id': 'damaged'});
      final load = await repo.load();
      expect(load.session, isNotNull);
      expect(load.session!.state.turn, 0);
      expect(load.settings.motion, false);
      expect(load.notice, contains('نسخة الحفظ السابقة'));
      final restored = SessionViewModel.restore(load.session!);
      restored.resume();
      await repo.saveSession(restored.snapshot());
      restored.dispose();
      expect((await repo.load()).unreadableSession, false);
    },
  );
  test(
    'Unrecoverable records and future schema are kept without silently overwriting',
    () async {
      final repo = await memoryDatabase();
      addTearDown(repo.close);
      await SembastGameRepository.store
          .record(SembastGameRepository.currentKey)
          .put(repo.database, {'version': 1, 'bad': true});
      expect((await repo.load()).unreadableSession, true);
      expect(
        await SembastGameRepository.store
            .record(SembastGameRepository.currentKey)
            .get(repo.database),
        isNotNull,
      );
      final vm = managementModel();
      addTearDown(vm.dispose);
      await repo.saveSession(vm.snapshot());
      vm.pause();
      await repo.saveSession(vm.snapshot());
      await SembastGameRepository.store
          .record(SembastGameRepository.currentKey)
          .put(repo.database, {'version': 999});
      final load = await repo.load();
      expect(load.session, isNull);
      expect(load.unreadableSession, true);
      expect(load.notice, contains('إصدار مختلف'));
    },
  );
  test('Older snapshots cannot overwrite newer progress', () async {
    final repo = await memoryDatabase();
    addTearDown(repo.close);
    final vm = managementModel();
    addTearDown(vm.dispose);
    final before = vm.snapshot();
    completeRound(vm, 'myths', 'a');
    await repo.saveSession(vm.snapshot());
    await expectLater(repo.saveSession(before), throwsStateError);
    expect((await repo.load()).session!.state.teams.first.score, 200);
  });
  test(
    'Settings and saved match initialize a new controller correctly',
    () async {
      final repository = MemoryGameRepository();
      final first = AppController(
        repository,
        questions: LocalQuestionRepository(questions: completeQuestions),
      );
      await first.initialize();
      first.updateSettings(const AppSettings(motion: false, haptics: false));
      await first.startSession(managementConfig());
      await completeStoredRound(first.session!, 'myths', 'b');
      await first.flush();
      final second = AppController(
        repository,
        questions: LocalQuestionRepository(questions: completeQuestions),
      );
      await second.initialize();
      expect(second.settings.motion, false);
      expect(second.session!.state.isPaused, true);
      expect(second.session!.state.teams[1].score, 200);
      second.dispose();
      first.dispose();
    },
  );
  test(
    'Failed autosave exposes error, retains dirty state, and retry saves it',
    () async {
      final repository = _FailingRepository();
      final app = AppController(
        repository,
        questions: LocalQuestionRepository(questions: completeQuestions),
      );
      await app.initialize();
      await app.startSession(managementConfig());
      final vm = app.session!;
      vm.selectCategory('myths');
      vm.revealCard(0);
      vm.revealCard(1);
      expect(await vm.revealQuestion(), true);
      vm.showAnswer();
      await app.flush();
      repository.fail = true;
      expect(vm.awardAnswer('a'), true);
      await expectLater(app.flush(), throwsStateError);
      expect(app.saveStatus, LocalSaveStatus.error);
      expect(app.session!.state.teams.first.score, 200);
      repository.fail = false;
      expect(await app.retrySave(), true);
      expect(repository.session!.state.teams.first.score, 200);
      expect(app.saveStatus, LocalSaveStatus.saved);
      app.dispose();
    },
  );
  test(
    'Failed new session leaves the previously saved session available',
    () async {
      final repository = _FailingRepository();
      final app = AppController(
        repository,
        questions: LocalQuestionRepository(questions: completeQuestions),
      );
      await app.initialize();
      await app.startSession(managementConfig());
      final previousId = app.session!.id;
      repository.fail = true;
      await expectLater(app.startSession(managementConfig()), throwsStateError);
      expect(app.session!.id, previousId);
      expect(repository.session!.id, previousId);
      repository.fail = false;
      await app.startSession(managementConfig());
      expect(app.session!.id, isNot(previousId));
      app.dispose();
    },
  );
  test(
    'Concurrent updates are serialized and flush includes the newest snapshot',
    () async {
      final repository = _SlowRepository();
      final app = AppController(
        repository,
        questions: LocalQuestionRepository(questions: completeQuestions),
      );
      await app.initialize();
      await app.startSession(managementConfig());
      await completeStoredRound(app.session!, 'myths', 'a');
      await completeStoredRound(app.session!, 'spacetoon', null);
      await app.flush();
      repository.gate = Completer<void>();
      app.session!.correctDecision(app.session!.state.history.last.id, 'a');
      app.session!.correctDecision(app.session!.state.history.last.id, 'b');
      app.updateSettings(const AppSettings(haptics: false));
      repository.gate!.complete();
      await app.flush();
      expect(repository.session!.state.history.length, 2);
      expect(repository.session!.state.teams.map((team) => team.score), [
        200,
        100,
        0,
      ]);
      expect(repository.settings.haptics, false);
      app.dispose();
    },
  );
}
