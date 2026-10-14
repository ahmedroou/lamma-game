import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/game_catalog.dart';
import '../../domain/models/hint_access.dart';
import '../../shared/components.dart';
import 'lucky_wheel_dialog.dart';
import 'session_view_model.dart';

class OpeningCardControls extends StatefulWidget {
  const OpeningCardControls({super.key, required this.model});
  final SessionViewModel model;
  @override
  State<OpeningCardControls> createState() => _OpeningCardControlsState();
}

class _OpeningCardControlsState extends State<OpeningCardControls> {
  final _value = TextEditingController(),
      _name = TextEditingController(),
      _firstAnswer = TextEditingController();
  String? _target, _category, _error;
  @override
  void dispose() {
    _value.dispose();
    _name.dispose();
    _firstAnswer.dispose();
    super.dispose();
  }

  void _result(bool result, String message) {
    setState(() => _error = result ? null : message);
  }

  int? _number(String value) {
    value = value.replaceAllMapped(RegExp('[٠-٩۰-۹]'), (match) {
      final code = match[0]!.codeUnitAt(0);
      return '${code >= 0x06F0 ? code - 0x06F0 : code - 0x0660}';
    });
    return int.tryParse(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model, state = model.state, card = state.surpriseCard;
    if (card == null || state.revealedCards < 1) return const SizedBox.shrink();
    final opponents = state.teams
        .where((team) => team.id != state.activeTeam.id)
        .toList();
    _target ??= opponents.first.id;
    final categories = gameCategories
        .where(
          (category) =>
              model.config.categoryIds.contains(category.id) &&
              model.remainingForCategory(category.id) > 0,
        )
        .toList();
    if (!categories.any((category) => category.id == _category)) {
      _category = categories.isEmpty ? null : categories.first.id;
    }
    Widget targetPicker() => DropdownButtonFormField<String>(
      initialValue: _target,
      decoration: const InputDecoration(labelText: 'الفريق المنافس'),
      items: [
        for (final team in opponents)
          DropdownMenuItem(value: team.id, child: Text(team.name)),
      ],
      onChanged: model.canPrepareSurprise
          ? (value) => setState(() => _target = value)
          : null,
    );
    final children = <Widget>[];
    if (state.roundData['designatedPlayer'] case final String player) {
      children.add(
        Text(
          'مجيب الفريق الأساسي وحده: $player · بقية فريقه لا تشارك في النقاش.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    if ({
          SurpriseEffect.selfWager,
          SurpriseEffect.opponentWager,
        }.contains(card.effect) &&
        model.canPrepareSurprise) {
      if (card.effect == SurpriseEffect.opponentWager) {
        children.add(targetPicker());
      }
      children.addAll([
        Text(
          'رصيدك المتاح للرهان: ${model.wagerBalance} نقطة',
          textAlign: TextAlign.center,
        ),
        TextField(
          controller: _value,
          keyboardType: TextInputType.number,
          maxLength: 9,
          decoration: const InputDecoration(labelText: 'مقدار الرهان بالنقاط'),
        ),
        LammaButton(
          label: 'تسجيل الرهان للجولة القادمة',
          onPressed: () => _result(
            model.commitWager(_number(_value.text) ?? 0, targetTeamId: _target),
            'يلزم مقدار موجب ضمن الرصيد المتاح، وجولة قادمة للفريق المستهدف.',
          ),
        ),
        const Text(
          'إذا انتهت المباراة قبل الجولة المستهدفة يُلغى الرهان بلا ربح أو خصم.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ]);
    }
    if (model.canPrepareSurprise &&
        card.effect == SurpriseEffect.chooseOpponentCategory) {
      children.addAll([
        targetPicker(),
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'قسم جولته القادمة'),
          items: [
            for (final category in categories)
              DropdownMenuItem(value: category.id, child: Text(category.title)),
          ],
          onChanged: (value) => setState(() => _category = value),
        ),
        LammaButton(
          label: 'اعتماد قسم الخصم',
          onPressed: _category == null
              ? null
              : () => _result(
                  model.assignOpponentCategory(_target!, _category!),
                  'لا يمكن تحديد قسم نافد، أو فريق لا يملك جولة قادمة.',
                ),
        ),
      ]);
    }
    if (model.canPrepareSurprise && card.effect == SurpriseEffect.banPlayer) {
      children.addAll([
        targetPicker(),
        TextField(
          controller: _name,
          maxLength: 80,
          decoration: const InputDecoration(
            labelText: 'اسم اللاعب المستبعد من الفريق المنافس',
          ),
        ),
        LammaButton(
          label: 'استبعاد اللاعب لجولتي فريقه القادمتين',
          onPressed: () => _result(
            model.banOpponentPlayer(_target!, _name.text),
            'اكتب اسم اللاعب وحدد خصمًا لديه جولة قادمة.',
          ),
        ),
      ]);
    }
    if (state.roundData['registeredWager']
        case final Map<dynamic, dynamic> wager) {
      children.add(
        Text(
          'تم تسجيل رهان ${wager['amount']} نقطة للجولة القادمة للفريق المستهدف.',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (state.roundData['assignedCategory']
        case final Map<dynamic, dynamic> assignment) {
      children.add(
        Text(
          'تم تحديد ${gameCategories.firstWhere((category) => category.id == assignment['category']).title} لجولة الخصم القادمة.',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (state.roundData['registeredBan'] case final Map<dynamic, dynamic> ban) {
      children.add(
        Text(
          'استبعاد ${ban['player']} مسجل لجولتي فريقه القادمتين.',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (card.effect == SurpriseEffect.changeQuestion &&
        state.revealedCards == 3 &&
        state.phase == SessionPhase.cards) {
      children.add(
        LammaButton(
          label: state.roundData['surpriseActionUsed'] == true
              ? 'تم تغيير السؤال'
              : 'تغيير السؤال خلال أول 10 ثوانٍ',
          onPressed: model.canChangeQuestion
              ? () async {
                  await model.changeQuestion();
                }
              : null,
          icon: Icons.shuffle_rounded,
        ),
      );
    }
    if (card.effect == SurpriseEffect.silence && state.revealedCards == 3) {
      final answers = state.roundData['firstAnswers'] as Map? ?? const {};
      final first = answers[state.answeringTeam.id];
      if (first != null) {
        children.add(
          Text(
            'الإجابة الأولى المعتمدة: $first',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.gold),
          ),
        );
      } else if (state.phase == SessionPhase.cards) {
        children.addAll([
          TextField(
            controller: _firstAnswer,
            maxLength: 200,
            enabled: !state.isPaused && state.secondsRemaining > 0,
            decoration: InputDecoration(
              labelText: 'المراقب: أول إجابة قالها ${state.answeringTeam.name}',
            ),
          ),
          LammaButton(
            label: 'اعتماد أول إجابة فقط',
            onPressed: state.isPaused || state.secondsRemaining <= 0
                ? null
                : () => _result(
                    model.recordFirstAnswer(_firstAnswer.text),
                    'اكتب الإجابة الأولى قبل انتهاء الوقت؛ لا يمكن استبدال إجابة مسجلة.',
                  ),
          ),
        ]);
      }
    }
    if (card.effect == SurpriseEffect.wheelOfFortune) {
      final status = model.wheelStatus ?? 'pending';
      final outcome = model.wheelOutcome;
      if (status == 'pending') {
        children.add(
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.casino_rounded, color: AppColors.gold, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'ورقة المفاجأة: عجلة الحظ 🎡',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'لصاحب الدور حرية الاختيار: لف العجلة لفرصة كسب حتى 600 نقطة، أو المجازفة بخسارة 500 نقطة أو الإفلاس أو تحويل الدور، أو التخطي.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.white, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: LammaButton(
                        label: 'لف عجلة الحظ 🎡',
                        onPressed: model.canSpinWheel
                            ? () => LuckyWheelDialog.show(context, model: model)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 56),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: model.canSkipWheel ? model.skipWheel : null,
                        child: const Text(
                          'تخطي العجلة',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      } else if (status == 'completed' && outcome != null) {
        children.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: outcome.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: outcome.color.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(outcome.icon, color: outcome.color, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نتيجة عجلة الحظ: ${outcome.title}',
                        style: TextStyle(
                          color: outcome.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        outcome.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (status == 'skipped') {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'تم تخطي عجلة الحظ لهذه الجولة والمتابعة بدون لف.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
        );
      }
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in children) ...[child, const SizedBox(height: 12)],
          if (_error != null)
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.peach),
            ),
        ],
      ),
    );
  }
}
