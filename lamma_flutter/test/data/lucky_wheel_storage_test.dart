import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_controller.dart';
import 'package:lamma/data/repositories/local_game_repository.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/domain/abilities/surprise_catalog.dart';
import 'package:lamma/domain/models/hint_access.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/session_save.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/features/session/session_view_model.dart';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

import '../fixtures/questions.dart';

final _questions = seedQuestions.take(6).toList();
final _wheel = SurpriseCatalog.cards.singleWhere(
  (card) => card.effect == SurpriseEffect.wheelOfFortune,
);

SessionViewModel _game(SembastGameRepository repository, int teamCount) =>
    SessionViewModel(
      config: SessionConfig(
        categoryIds: _questions.map((q) => q.categoryId),
        teams: [
          TeamState(id: 'a', name: 'الأول', score: 500),
          TeamState(id: 'b', name: 'الثاني', score: 300),
          if (teamCount == 3) TeamState(id: 'c', name: 'الثالث', score: 100),
        ],
      ),
      questions: LocalQuestionRepository(questions: _questions),
      commitReveal: repository.commitQuestion,
      openingCardsEnabled: true,
      surpriseResolver: (_, _, _) => _wheel,
    );

Map<String, dynamic> _json(SessionSave save) =>
    jsonDecode(jsonEncode(save.toJson())) as Map<String, dynamic>;

void main() {
  for (final teams in [2, 3]) {
    for (final outcome in WheelOutcome.values) {
      test(
        '$teams teams: ${outcome.name} saves, restores and reveals',
        () async {
          final repo = SembastGameRepository(
            await databaseFactoryMemory.openDatabase(
              'wheel-$teams-${outcome.name}',
            ),
          );
          addTearDown(repo.close);
          await repo.prepareUsage(_questions);
          final game = _game(repo, teams);
          addTearDown(game.dispose);
          expect(game.selectCategory(_questions.first.categoryId), isTrue);
          expect(game.revealCard(0), isTrue);
          expect(game.applyWheelOutcome(outcome), isTrue);
          final scores = game.state.teams.map((team) => team.score).toList();
          final recipient = game.state.answeringTeam.id;
          if (outcome == WheelOutcome.passTurn) {
            expect(recipient, teams == 3 ? 'c' : 'b');
            expect(game.state.isOpponentWindow, isFalse);
            expect(game.state.secondsRemaining, 30);
          }

          // This checkpoint failed before the second/third card could open.
          await repo.saveSession(game.snapshot());
          final restored = SessionViewModel.restore(
            (await repo.load()).session!,
            usage: await repo.prepareUsage(_questions),
            commitReveal: repo.commitQuestion,
          );
          addTearDown(restored.dispose);
          expect(restored.state.isPaused, isTrue);
          expect(restored.wheelOutcome, outcome);
          expect(restored.state.answeringTeam.id, recipient);
          expect(restored.state.teams.map((team) => team.score), scores);
          expect(restored.resume(), isTrue);
          expect(restored.applyWheelOutcome(outcome), isFalse);
          expect(restored.revealCard(1), isTrue);
          expect(await restored.revealQuestion(), isTrue);
          expect(restored.state.revealedCards, 3);
          expect(
            (await repo.prepareUsage(_questions)).contains(_questions.first),
            isTrue,
          );
          expect(restored.showAnswer(), isTrue);
          expect(restored.awardAnswer(recipient), isTrue);
          await repo.saveSession(restored.snapshot());
          expect(restored.state.teams.map((team) => team.score), [
            for (var i = 0; i < scores.length; i++)
              scores[i] +
                  (restored.state.teams[i].id == recipient
                      ? _questions.first.points
                      : 0),
          ]);
          expect(restored.undoLastDecision(), isTrue);
          await repo.saveSession(restored.snapshot());
          expect(
            (await repo.load()).session!.state.answeringTeam.id,
            recipient,
          );
        },
      );
    }
  }

  test('Pass-turn checkpoint survives file reopen and app autosave', () async {
    final directory = await Directory.systemTemp.createTemp('lamma-wheel-');
    addTearDown(() async {
      final target = path.normalize(path.absolute(directory.path));
      if (!path.isWithin(
        path.normalize(path.absolute(Directory.systemTemp.path)),
        target,
      )) {
        throw StateError('Unsafe test cleanup path.');
      }
      await directory.delete(recursive: true);
    });
    final databasePath = path.join(directory.path, 'game.db');
    final repo = SembastGameRepository(
      await databaseFactoryIo.openDatabase(databasePath),
    );
    await repo.prepareUsage(_questions);
    final game = _game(repo, 3);
    addTearDown(game.dispose);
    game.selectCategory(_questions.first.categoryId);
    game.revealCard(0);
    game.applyWheelOutcome(WheelOutcome.passTurn);
    game.revealCard(1);
    await repo.saveSession(game.snapshot());
    await repo.close();

    final reopened = SembastGameRepository(
      await databaseFactoryIo.openDatabase(databasePath),
    );
    final app = AppController(
      reopened,
      questions: LocalQuestionRepository(questions: _questions),
    );
    addTearDown(() async {
      await app.flush();
      app.dispose();
      await reopened.close();
    });
    await app.initialize();
    expect(app.saveStatus, LocalSaveStatus.saved);
    final restored = app.session!;
    expect(restored.wheelOutcome, WheelOutcome.passTurn);
    expect(restored.state.answeringTeam.id, 'c');
    expect(restored.resume(), isTrue);
    expect(await restored.revealQuestion(), isTrue);
    await app.flush();
    expect(app.saveStatus, LocalSaveStatus.saved);
    expect((await reopened.load()).session!.state.revealedCards, 3);
  });

  test('Wheel exception rejects unrelated or damaged opponent data', () async {
    final repo = SembastGameRepository(
      await databaseFactoryMemory.openDatabase('wheel-invalid'),
    );
    addTearDown(repo.close);
    final game = _game(repo, 2);
    addTearDown(game.dispose);
    game.selectCategory(_questions.first.categoryId);
    game.revealCard(0);
    game.applyWheelOutcome(WheelOutcome.passTurn);
    final valid = game.snapshot();
    for (final changes in <Map<String, Object?>>[
      {'wheelOutcome': 'plus100'},
      {'wheelStatus': 'pending'},
      {'wheelTurnPassed': false},
      {'surpriseApplied': false},
      {'opponentTeamId': 'a'},
      {'opponentTeamId': 'unknown'},
      {'opponentTeamId': null},
      {'opponentReason': 'tie'},
      {'answerWindow': 'opponent'},
    ]) {
      final json = _json(valid);
      (json['state']['roundData'] as Map).addAll(changes);
      expect(
        () => SessionSave.fromJson(json),
        throwsFormatException,
        reason: '$changes',
      );
    }
    final hidden = _json(valid);
    hidden['state']['revealedCards'] = 0;
    expect(() => SessionSave.fromJson(hidden), throwsFormatException);
  });

  test(
    'Normal opponent opportunity still requires a revealed question and at most seven seconds',
    () async {
      final repo = SembastGameRepository(
        await databaseFactoryMemory.openDatabase('wheel-normal-window'),
      );
      addTearDown(repo.close);
      await repo.prepareUsage(_questions);
      final game = _game(repo, 3);
      addTearDown(game.dispose);
      game.selectCategory(_questions.first.categoryId);
      game.revealCard(0);
      game.skipWheel();
      game.revealCard(1);
      expect(await game.revealQuestion(), isTrue);
      expect(game.startOpponentOpportunity(), isTrue);
      final valid = game.snapshot();
      expect(valid.state.secondsRemaining, 7);
      final tooLong = _json(valid);
      tooLong['state']['secondsRemaining'] = 8;
      expect(() => SessionSave.fromJson(tooLong), throwsFormatException);
      final hidden = _json(valid);
      hidden['state']['revealedCards'] = 2;
      expect(() => SessionSave.fromJson(hidden), throwsFormatException);
    },
  );
}
