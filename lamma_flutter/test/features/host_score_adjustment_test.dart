import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/domain/models/session_save.dart';
import 'package:lamma/features/session/session_view_model.dart';
import 'session_management_test.dart' show managementModel, completeRound;
import 'surprise_rules_test.dart' as surprise;

Map<String, int> scores(SessionViewModel vm) => {
  for (final team in vm.state.teams) team.id: team.score,
};
void main() {
  test('Host edits keep a surprise bonus separate from judgment points', () {
    final vm = surprise.model('bonus_20');
    addTearDown(vm.dispose);
    surprise.openQuestion(vm);
    expect(vm.state.teams.first.score, 320);
    expect(
      vm.setTeamScores({'a': 750, 'b': -50}, expectedScores: scores(vm)),
      true,
    );
    expect(vm.state.roundData['roundStartingScores'], {'a': 730, 'b': -50});
    vm.showAnswer();
    vm.awardAnswer('a');
    expect(scores(vm), {'a': 1150, 'b': -50});
    expect(vm.correctDecision(vm.state.history.last.id, null), true);
    expect(scores(vm), {'a': 750, 'b': -50});
    expect(vm.undoLastDecision(), true);
    expect(scores(vm), {'a': 750, 'b': -50});
  });
  test(
    'Host changes all totals atomically and adjustments survive correction and restoration',
    () {
      final vm = managementModel();
      addTearDown(vm.dispose);
      completeRound(vm, 'myths', 'a');
      final prior = scores(vm);
      expect(
        vm.setTeamScores(
          {'a': 750, 'b': -50, 'c': 100},
          expectedScores: prior,
          reason: 'تصحيح المضيف',
        ),
        true,
      );
      expect(vm.state.scoreAdjustments.length, 3);
      expect(vm.state.scoreAdjustments.first.before, 200);
      expect(vm.correctDecision(vm.state.history.first.id, 'b'), true);
      expect(scores(vm), {'a': 550, 'b': 150, 'c': 100});
      final saved = SessionSave.fromJson(
        jsonDecode(jsonEncode(vm.snapshot().toJson())) as Map<String, dynamic>,
      );
      final restored = SessionViewModel.restore(saved);
      addTearDown(restored.dispose);
      expect(scores(restored), scores(vm));
      expect(restored.state.scoreAdjustments.length, 3);
      expect(restored.state.scoreAdjustments.first.reason, 'تصحيح المضيف');
      expect(restored.undoLastDecision(), true);
      expect(scores(restored), {'a': 550, 'b': -50, 'c': 100});
      expect(restored.state.scoreAdjustments.length, 3);
    },
  );
  test(
    'Stale, incomplete, unknown and out-of-range requests never partially change totals',
    () {
      final vm = managementModel();
      addTearDown(vm.dispose);
      final before = scores(vm);
      for (final invalid in [
        <String, int>{'a': 100},
        {'a': 100, 'b': 0, 'x': 0},
        {'a': 1000000000, 'b': 0, 'c': 0},
      ]) {
        expect(vm.setTeamScores(invalid, expectedScores: before), false);
        expect(scores(vm), before);
      }
      expect(
        vm.setTeamScores(
          {'a': 200, 'b': 0, 'c': 0},
          expectedScores: {'a': 50, 'b': 0, 'c': 0},
        ),
        false,
      );
      expect(vm.setTeamScores(before, expectedScores: before), true);
      expect(vm.state.scoreAdjustments, isEmpty);
    },
  );
  test(
    'Host changes preserve question, time and an already selected opponent',
    () {
      final vm = managementModel();
      addTearDown(vm.dispose);
      vm.selectCategory('myths');
      for (var i = 0; i < 3; i++) {
        vm.revealCard(i);
      }
      vm.startOpponentOpportunity();
      vm.pause();
      final opponent = vm.state.opponentTeamId,
          question = vm.state.question!.id,
          time = vm.state.secondsRemaining;
      expect(
        vm.setTeamScores({
          'a': 900,
          'b': 500,
          'c': -200,
        }, expectedScores: scores(vm)),
        true,
      );
      expect(vm.state.opponentTeamId, opponent);
      expect(vm.state.question!.id, question);
      expect(vm.state.secondsRemaining, time);
      expect(vm.state.isPaused, true);
    },
  );
  test(
    'Version five saves without the optional audit list remain readable',
    () {
      final vm = managementModel();
      addTearDown(vm.dispose);
      final json =
          jsonDecode(jsonEncode(vm.snapshot().toJson()))
              as Map<String, dynamic>;
      json['version'] = 5;
      (json['state'] as Map).remove('scoreAdjustments');
      expect(SessionSave.fromJson(json).state.scoreAdjustments, isEmpty);
    },
  );
}
