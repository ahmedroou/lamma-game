import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/app_theme.dart';
import 'package:lamma/domain/abilities/ability_system.dart';
import 'package:lamma/domain/models/hint_access.dart';
import 'package:lamma/domain/models/question.dart';
import 'package:lamma/domain/models/session_config.dart';
import 'package:lamma/domain/models/session_save.dart';
import 'package:lamma/domain/models/team.dart';
import 'package:lamma/data/repositories/question_repository.dart';
import 'package:lamma/features/session/session_screen.dart';
import 'package:lamma/features/session/session_view_model.dart';
import '../app_test.dart' show snapshot;
import '../fixtures/questions.dart';
import 'session_management_test.dart' show managementConfig;

final hintQuestion = Question(
  id: 'hint-test',
  categoryId: 'myths',
  text: 'سؤال اختبار التلميح',
  answer: 'جواب الاختبار',
  hint: 'تلميح محفوظ لا يُكشف مجاناً',
  difficulty: QuestionDifficulty.medium,
);
final hintQuestions = [hintQuestion, ...seedQuestions.skip(1)];

class _HintEffect implements AbilityEffect {
  @override
  String? validate(AbilityContext context) => null;
  @override
  AbilityImpact apply(AbilityContext context) =>
      AbilityImpact(grantsHint: true);
}

SessionViewModel hintModel({
  bool surprise = false,
  bool withAbility = false,
  String owner = 'a',
  void Function()? onSurprise,
}) {
  final config = managementConfig();
  return SessionViewModel(
    config: SessionConfig(
      teams: config.teams.map(
        (team) => team.id != owner || !withAbility
            ? team
            : team.copyWith(
                inventory: [
                  OwnedAbility(
                    id: 'hint-card-instance',
                    definitionId: 'hint-fixture',
                    ownerTeamId: owner,
                    acquiredTurn: 0,
                    remainingUses: 1,
                  ),
                ],
              ),
      ),
      categoryIds: config.categoryIds,
    ),
    questions: LocalQuestionRepository(questions: hintQuestions),
    abilities: AbilityRegistry(
      definitions: withAbility
          ? [
              AbilityDefinition(
                id: 'hint-fixture',
                title: 'بطاقة اختبار',
                description: 'مخصصة للاختبارات',
                effectKey: 'hint-effect',
                windows: {AbilityWindow.duringQuestion},
                target: AbilityTarget.self,
                usesPerCard: 1,
              ),
            ]
          : [],
      effects: withAbility ? {'hint-effect': _HintEffect()} : {},
    ),
    surpriseResolver: surprise
        ? (q, team, turn) {
            onSurprise?.call();
            return SurpriseCard(
              id: 'hint-surprise-fixture',
              text: 'بطاقة اختبار تمنح فريقكم تلميحاً',
              grantsHint: true,
            );
          }
        : null,
  );
}

void revealHintQuestion(SessionViewModel vm) {
  vm.selectCategory('myths');
  for (var i = 0; i < 3; i++) {
    vm.revealCard(i);
  }
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
  test('No free hint is available without a card', () {
    final vm = hintModel();
    addTearDown(vm.dispose);
    revealHintQuestion(vm);
    expect(vm.canRevealHint, false);
    expect(vm.revealHint(), false);
    expect(vm.state.hintRevealed, false);
    vm.showAnswer();
    expect(vm.revealHint(), false);
  });
  test(
    'Surprise permission starts on opening-card reveal, is saved and clears next question',
    () {
      var draws = 0;
      final vm = hintModel(surprise: true, onSurprise: () => draws++);
      addTearDown(vm.dispose);
      vm.selectCategory('myths');
      expect(vm.state.hintAccess, isNull);
      vm.revealCard(0);
      expect(vm.state.hintAccess!.source, HintSource.surprise);
      expect(vm.revealHint(), false);
      vm.revealCard(1);
      vm.revealCard(2);
      expect(vm.canRevealHint, true);
      vm.pause();
      expect(vm.revealHint(), false);
      vm.resume();
      expect(vm.revealHint(), true);
      expect(vm.revealHint(), false);
      final restored = SessionViewModel.restore(
        SessionSave.fromJson(
          jsonDecode(jsonEncode(vm.snapshot().toJson()))
              as Map<String, dynamic>,
        ),
      );
      addTearDown(restored.dispose);
      expect(restored.state.hintRevealed, true);
      expect(restored.state.hintAccess!.cardId, 'hint-surprise-fixture');
      expect(draws, 1);
      vm.showAnswer();
      vm.awardAnswer('a');
      vm.selectCategory('spacetoon');
      expect(vm.state.hintAccess, isNull);
      expect(vm.state.hintRevealed, false);
    },
  );
  test(
    'Owned ability grants a question-bound hint and is consumed exactly once',
    () {
      final vm = hintModel(withAbility: true);
      addTearDown(vm.dispose);
      revealHintQuestion(vm);
      expect(vm.canRevealHint, false);
      expect(
        () => vm.useAbility(ownerTeamId: 'b', cardId: 'hint-card-instance'),
        throwsStateError,
      );
      vm.useAbility(ownerTeamId: 'a', cardId: 'hint-card-instance');
      expect(vm.state.teams.first.inventory, isEmpty);
      expect(vm.state.hintAccess!.source, HintSource.ability);
      expect(vm.state.hintAccess!.questionId, hintQuestion.id);
      final restored = SessionViewModel.restore(
        SessionSave.fromJson(vm.snapshot().toJson()),
      );
      addTearDown(restored.dispose);
      restored.resume();
      expect(restored.revealHint(), true);
      expect(restored.state.teams.first.inventory, isEmpty);
      expect(vm.revealHint(), true);
      expect(vm.state.availablePoints, 200);
      expect(
        () => vm.useAbility(ownerTeamId: 'a', cardId: 'hint-card-instance'),
        throwsStateError,
      );
    },
  );
  test('A card for an inactive team cannot unlock the active team hint', () {
    final vm = hintModel(withAbility: true, owner: 'b');
    addTearDown(vm.dispose);
    revealHintQuestion(vm);
    vm.useAbility(ownerTeamId: 'b', cardId: 'hint-card-instance');
    expect(vm.state.hintAccess!.teamId, 'b');
    expect(vm.revealHint(), false);
  });
  test(
    'Old free hint state and stale permissions cannot bypass the new rule',
    () {
      final vm = hintModel();
      addTearDown(vm.dispose);
      revealHintQuestion(vm);
      final json =
          jsonDecode(jsonEncode(vm.snapshot().toJson()))
              as Map<String, dynamic>;
      final round =
          (json['state'] as Map<String, dynamic>)['roundData']
              as Map<String, dynamic>;
      round['hintRevealed'] = true;
      final restored = SessionViewModel.restore(SessionSave.fromJson(json));
      addTearDown(restored.dispose);
      expect(restored.state.hintRevealed, false);
      round['hintAccess'] = HintAccess(
        questionId: 'another-question',
        teamId: 'a',
        source: HintSource.ability,
        cardId: 'old-card',
      ).toJson();
      expect(() => SessionSave.fromJson(json), throwsFormatException);
    },
  );
  testWidgets(
    'An unused opening hint does not transfer to the selected opponent or unlock at timeout',
    (tester) async {
      final vm = hintModel(surprise: true);
      addTearDown(vm.dispose);
      revealHintQuestion(vm);
      expect(vm.canRevealHint, true);
      vm.startOpponentOpportunity();
      expect(vm.canRevealHint, false);
      expect(vm.revealHint(), false);
      await tester.pump(const Duration(seconds: 7));
      expect(vm.revealHint(), false);
    },
  );
  testWidgets(
    'Hint button and text remain absent even when the answer is shown without permission',
    (tester) async {
      final vm = hintModel();
      addTearDown(vm.dispose);
      revealHintQuestion(vm);
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: RepaintBoundary(
              key: key,
              child: SessionScreen(config: vm.config, model: vm),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 650));
      expect(find.text('عرض تلميح مساعد'), findsNothing);
      expect(find.text('تلميح مساعد: ${hintQuestion.hint}'), findsNothing);
      await snapshot(tester, key, 'hint-locked');
      vm.showAnswer();
      await tester.pump();
      expect(find.text('تلميح مساعد: ${hintQuestion.hint}'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
