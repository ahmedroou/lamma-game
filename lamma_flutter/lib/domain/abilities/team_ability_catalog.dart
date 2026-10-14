import 'dart:math';
import 'ability_system.dart';

/// Stable card identifiers are independent of their translated labels.
abstract final class TeamAbilityCatalog {
  static const banPlayer = 'ban_player';
  static const options = 'show_options';
  static const dice = 'roll_dice';
  static const noOpponent = 'block_opponents';
  static const google = 'google_search';
  static const doublePoints = 'double_points';
  static final definitions = <AbilityDefinition>[
    _card(
      banPlayer,
      'منع لاعب',
      'امنع لاعبًا من خصم تختاره لهذا السؤال فقط. يُنفّذ المنع بين اللاعبين والمضيف خلال أول 15 ثانية من وقت الأساسي.',
      3,
      AbilityTarget.opponent,
      [AbilityWindow.duringQuestion],
    ),
    _card(
      options,
      'أظهر الخيارات',
      'اكشف كل خيارات السؤال في فرصة إجابة فريقك.',
      2,
      AbilityTarget.self,
      [AbilityWindow.duringQuestion],
    ),
    _card(
      dice,
      'رمي النرد',
      'اكشف خيارات بعدد النرد من 1 إلى 6. الصحيح بينها دائمًا.',
      2,
      AbilityTarget.self,
      [AbilityWindow.duringQuestion],
    ),
    _card(
      noOpponent,
      'لا أحد يجيب بعدك',
      'امنع فرصة الإجابة لجميع الخصوم بعد وقت فريقك في هذا السؤال.',
      2,
      AbilityTarget.self,
      [AbilityWindow.beforeQuestion, AbilityWindow.duringQuestion],
    ),
    _card(
      google,
      'البحث على قوقل',
      'حتى 20 ثانية للبحث من وقت السؤال المتبقي. الساعة تستمر دون زيادة أو إيقاف.',
      1,
      AbilityTarget.self,
      [AbilityWindow.duringQuestion],
    ),
    _card(
      doublePoints,
      'دبل النقاط',
      'ضاعف نقاط إجابة فريقك لهذا السؤال. تُستخدم قبل كشف السؤال فقط؛ الخصم يحصل على النقاط العادية.',
      2,
      AbilityTarget.self,
      [AbilityWindow.beforeQuestion],
    ),
  ];
  static AbilityDefinition _card(
    String id,
    String title,
    String description,
    int uses,
    AbilityTarget target,
    List<AbilityWindow> windows,
  ) => AbilityDefinition(
    id: id,
    title: title,
    description: description,
    effectKey: id,
    windows: windows,
    target: target,
    usesPerCard: uses,
  );
  static AbilityRegistry registry(Random random) => AbilityRegistry(
    definitions: definitions,
    effects: {
      for (final card in definitions) card.id: _TeamEffect(card.id, random),
    },
  );
  static bool contains(String id) => definitions.any((card) => card.id == id);
}

final class _TeamEffect implements AbilityEffect {
  _TeamEffect(this.id, this.random);
  final String id;
  final Random random;
  @override
  String? validate(AbilityContext c) {
    if (c.question == null) return 'اختر السؤال أولًا.';
    final data = c.roundData;
    final own = data['_activeTeam'] == c.ownerTeamId;
    final answering = data['_answeringTeam'] == c.ownerTeamId;
    final opponent = data['_opponentWindow'] == true;
    final seconds = data['_seconds'] as int? ?? 0;
    final elapsed = data['_elapsed'] as int? ?? 0;
    if (data['_firstAnswerRecorded'] == true) return 'سُجلت الإجابة بالفعل.';
    if (id == TeamAbilityCatalog.banPlayer) {
      if (opponent || seconds <= 0 || elapsed >= 15) {
        return 'المنع متاح خلال أول 15 ثانية من وقت الفريق الأساسي فقط.';
      }
      return null;
    }
    if (id == TeamAbilityCatalog.doublePoints) {
      if (!own || opponent) return 'الدبل لسؤال فريقك فقط.';
      if (data['doubleAbilityTeamId'] != null) return 'الدبل مُفعّل بالفعل.';
      return null;
    }
    if (id == TeamAbilityCatalog.noOpponent) {
      if (!own ||
          opponent ||
          c.window == AbilityWindow.duringQuestion && seconds <= 0) {
        return 'استخدمها قبل انتهاء وقت فريقك الأساسي.';
      }
      if (data['blockOpponentTeamId'] != null ||
          data['_surpriseBlocks'] == true) {
        return 'منع الخصوم مُفعّل بالفعل.';
      }
      return null;
    }
    if (!answering || seconds <= 0) return 'متاحة أثناء فرصة إجابة فريقك فقط.';
    if (id == TeamAbilityCatalog.google) {
      if (data['googleTeamId'] == c.ownerTeamId &&
          (data['_googleRemaining'] as int? ?? 0) > 0) {
        return 'مهلة البحث الحالية مستمرة؛ احتفظ بالبطاقة الأخرى.';
      }
      return null;
    }
    if (c.question!.options.length != 6 ||
        !c.question!.options.any((o) => o.id == c.question!.correctOptionId)) {
      return 'هذا السؤال لا يحتوي على ستة خيارات معتمدة؛ احتفظنا بالبطاقة.';
    }
    if (data['optionsTeamId'] == c.ownerTeamId &&
        (data['visibleOptionIds'] as List? ?? []).length == 6) {
      return 'جميع الخيارات ظاهرة لفريقك بالفعل.';
    }
    return null;
  }

  @override
  AbilityImpact apply(AbilityContext c) {
    final q = c.question!;
    if (id == TeamAbilityCatalog.banPlayer) {
      return AbilityImpact(
        roundChanges: {
          'abilityPlayerBans': [
            ...?c.roundData['abilityPlayerBans'] as List?,
            {'owner': c.ownerTeamId, 'target': c.targetTeamId},
          ],
        },
      );
    }
    if (id == TeamAbilityCatalog.doublePoints) {
      return AbilityImpact(
        roundChanges: {
          'doubleAbilityTeamId': c.ownerTeamId,
          'doubleAbilityQuestionId': q.id,
        },
      );
    }
    if (id == TeamAbilityCatalog.noOpponent) {
      return AbilityImpact(
        roundChanges: {
          'blockOpponentTeamId': c.ownerTeamId,
          'blockOpponentQuestionId': q.id,
        },
      );
    }
    if (id == TeamAbilityCatalog.google) {
      return AbilityImpact(
        roundChanges: {'googleTeamId': c.ownerTeamId, 'googleQuestionId': q.id},
      );
    }
    final count = id == TeamAbilityCatalog.dice ? random.nextInt(6) + 1 : 6;
    final distractors =
        q.options.where((o) => o.id != q.correctOptionId).toList()
          ..shuffle(random);
    final ids = [
      q.correctOptionId!,
      ...distractors.take(count - 1).map((o) => o.id),
    ]..shuffle(random);
    return AbilityImpact(
      roundChanges: {
        'optionsQuestionId': q.id,
        'optionsTeamId': c.ownerTeamId,
        'visibleOptionIds': ids,
        if (id == TeamAbilityCatalog.dice) 'diceResult': count,
        if (id == TeamAbilityCatalog.dice) 'diceTeamId': c.ownerTeamId,
        if (id == TeamAbilityCatalog.dice)
          'diceTeams': [...?c.roundData['diceTeams'] as List?, c.ownerTeamId],
      },
    );
  }
}
