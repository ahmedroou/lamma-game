import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/online_sync_service.dart';
import '../../domain/abilities/team_ability_catalog.dart';
import '../../core/app_theme.dart';
import '../../core/app_controller.dart';
import '../../core/app_scope.dart';
import '../../core/game_catalog.dart';
import '../../domain/abilities/ability_system.dart';
import '../../domain/models/session_config.dart';
import '../../domain/models/team.dart';
import '../../domain/models/hint_access.dart';
import '../../shared/components.dart';
import '../../shared/category_card.dart';
import 'session_view_model.dart';
import 'category_replay_options.dart';
import 'structured_question_panel.dart';
import 'opening_card_controls.dart';
import 'cinematic_round_deck.dart';
import 'character_voice_player.dart';
import '../../domain/abilities/surprise_session_effects.dart';
import '../../shared/fit_text.dart';
part 'session_management.dart';
part 'session_play_layout.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, required this.config, required this.model});
  final SessionConfig config;
  final SessionViewModel model;
  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with WidgetsBindingObserver {
  late final SessionViewModel _model = widget.model;
  AppController? get _app => AppScope.maybeRead(context);
  bool _allowPop = false, _exitDialogOpen = false;
  void _permitPop() => setState(() => _allowPop = true);
  void refreshView() => setState(() {});
  void _adjustScore(String teamId, int delta) {
    final changed = _model.adjustTeamScore(teamId, delta);
    if (changed) {
      unawaited(_app?.flush());
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.pause(PauseReason.manual);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _model.setForeground(state == AppLifecycleState.resumed);

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _model,
    builder: (context, _) => PopScope<Object?>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_requestExit());
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _model.state.phase != SessionPhase.results
                ? _playCanvas()
                : SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_app != null) _saveIndicator(),
                              if (!_model.state.isPaused &&
                                  (_model.state.phase ==
                                          SessionPhase.categories ||
                                      _model.state.phase ==
                                          SessionPhase.results))
                                CategoryReplayOptions(
                                  categoryIds: widget.config.categoryIds,
                                ),
                              if (_model.state.isPaused)
                                _pausedPanel()
                              else if (_model.state.phase ==
                                  SessionPhase.results)
                                _result()
                              else if (_model.state.phase ==
                                  SessionPhase.categories)
                                _board()
                              else
                                _round(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            PositionedDirectional(
              top: MediaQuery.paddingOf(context).top + 4,
              end:
                  8 +
                  (Directionality.of(context) == TextDirection.rtl
                      ? MediaQuery.paddingOf(context).left
                      : MediaQuery.paddingOf(context).right),
              child: _sessionMenu(),
            ),
          ],
        ),
      ),
    ),
  );

  void _riskInfo() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.style_outlined, size: 50, color: AppColors.gold),
              const SizedBox(height: 18),
              Text(
                'قدرات تغيّر اللعب',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'ستة أسئلة صعبة أو خارقة من أقسام جلستك. لكل فريق ثلاثة اختيارات عند وجود فريقين، واختياران عند وجود ثلاثة. صاحب الدور يحصل على نقاط السؤال وبطاقة عشوائية إذا أجاب صحيحًا؛ الخصم يحصل على النقاط فقط. لا خصم عند الإخفاق.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              LammaButton(
                label: 'نكمل التحدّي',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  void _inventory(String teamId) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final team = _model.state.teams.firstWhere((team) => team.id == teamId);
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'أوراق ${team.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 18),
                  if (team.inventory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.style_outlined,
                            size: 48,
                            color: AppColors.gold,
                          ),
                          SizedBox(height: 14),
                          Text(
                            'ما عندكم أوراق قدرات… للحين!',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'أجب صحيحًا في قسم القدرات لتكسب بطاقة. المضيف يفعّلها بطلب فريقك.',
                            style: TextStyle(color: AppColors.muted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  for (final card in team.inventory) _ownedCard(team, card),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _ownedCard(TeamState team, OwnedAbility card) {
    final definition = _model.abilities.definitions[card.definitionId];
    final reason = _model.abilityUnavailableReason(team.id, card);
    final enabled = definition != null && reason == null;
    final icon = switch (card.definitionId) {
      TeamAbilityCatalog.banPlayer => Icons.person_off_outlined,
      TeamAbilityCatalog.options => Icons.view_list_rounded,
      TeamAbilityCatalog.dice => Icons.casino_outlined,
      TeamAbilityCatalog.noOpponent => Icons.shield_outlined,
      TeamAbilityCatalog.google => Icons.travel_explore_rounded,
      TeamAbilityCatalog.doublePoints => Icons.bolt_rounded,
      _ => Icons.style_outlined,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: enabled
            ? AppColors.gold.withValues(alpha: .08)
            : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: enabled
                ? AppColors.gold.withValues(alpha: .5)
                : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.gold, size: 30),
                  const Spacer(),
                  Tag(
                    '${card.remainingUses} من ${definition?.usesPerCard ?? card.remainingUses}',
                    color: AppColors.gold,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                definition?.title ?? 'ورقة قدرة',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(definition?.description ?? ''),
              Text(
                'الاستخدامات المتبقية: ${card.remainingUses}',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                children: [
                  for (
                    var i = 0;
                    i < (definition?.usesPerCard ?? card.remainingUses);
                    i++
                  )
                    Icon(
                      Icons.bolt_rounded,
                      size: 19,
                      color: i < card.remainingUses
                          ? AppColors.gold
                          : AppColors.border,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (reason != null)
                Text(reason, style: const TextStyle(color: AppColors.muted)),
              FilledButton(
                onPressed: enabled
                    ? () async {
                        String? target = team.id;
                        if (definition.target != AbilityTarget.self) {
                          target = await showDialog<String>(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: const Text('اختار الفريق المستهدف'),
                              children: _model.state.teams
                                  .where(
                                    (target) =>
                                        definition.target !=
                                            AbilityTarget.opponent ||
                                        target.id != team.id,
                                  )
                                  .map(
                                    (target) => SimpleDialogOption(
                                      onPressed: () =>
                                          Navigator.pop(context, target.id),
                                      child: Text(target.name),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                        }
                        if (!mounted || target == null) return;
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('تفعيل ${definition.title}؟'),
                            content: Text(
                              'بطلب من ${team.name}. سيُستهلك استخدام واحد من البطاقة. ${definition.description}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('إلغاء'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('تفعيل البطاقة'),
                              ),
                            ],
                          ),
                        );
                        if (!mounted || confirmed != true) return;
                        try {
                          final q = _model.state.question;
                          final query = q?.isIdentity == true
                              ? q!.clues
                                    .take(_model.state.identityCluesRevealed)
                                    .join(' ')
                              : q?.text ?? '';
                          _model.useAbility(
                            ownerTeamId: team.id,
                            cardId: card.id,
                            targetTeamId: target,
                          );
                          await _app?.flush();
                          if (card.definitionId == TeamAbilityCatalog.google) {
                            var launched = false;
                            try {
                              if (_model.googleSecondsLeft > 0) {
                                launched = await launchUrl(
                                  Uri.https('www.google.com', '/search', {
                                    'q': query,
                                  }),
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            } on Object {
                              launched = false;
                            }
                            _model.finishGoogleLaunch(launched);
                            await _app?.flush();
                            if (!launched && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'تعذّر فتح قوقل؛ أُعيد استخدام البطاقة، ومؤقت السؤال استمر.',
                                  ),
                                ),
                              );
                            }
                          }
                          if (mounted) Navigator.of(context).pop();
                        } on StateError catch (error) {
                          if (card.definitionId == TeamAbilityCatalog.google) {
                            _model.finishGoogleLaunch(false);
                          }
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.message.toString())),
                          );
                        } on Object {
                          if (card.definitionId == TeamAbilityCatalog.google) {
                            _model.finishGoogleLaunch(false);
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تعذّر حفظ الاستخدام. أعد محاولة الحفظ قبل المتابعة.',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    : null,
                child: Text(enabled ? 'تفعيل بطلب الفريق' : 'غير متاحة الآن'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _result() {
    final teams = _model.state.teams;
    final maxScore = teams
        .map((team) => team.score)
        .reduce((a, b) => a > b ? a : b);
    final winners = teams.where((team) => team.score == maxScore).toList();
    final sortedTeams = List<TeamState>.from(teams)
      ..sort((a, b) => b.score.compareTo(a.score));
    return Column(
      children: [
        const Icon(
          Icons.emoji_events_outlined,
          size: 80,
          color: AppColors.gold,
        ),
        if (_model.state.endedEarly) ...[
          const SizedBox(height: 12),
          const Tag('أُنهيت الجلسة مبكراً', color: AppColors.peach),
        ],
        const SizedBox(height: 20),
        Text(
          winners.length > 1
              ? 'تعادل… التحدّي مستمر!'
              : '${winners.single.name} أبطال اللمّة!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (winners.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              winners.map((team) => team.name).join(' • '),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.lime,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(height: 12),
        const Text(
          'أحلى فوز؟ إنكم اجتمعتوا.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'الترتيب النهائي للفرق',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < sortedTeams.length; i++) ...[
                Builder(
                  builder: (context) {
                    final team = sortedTeams[i];
                    final isWinner = team.score == maxScore;
                    final medal = i == 0
                        ? (winners.length > 1 ? '🤝' : '🥇')
                        : i == 1
                        ? '🥈'
                        : '🥉';
                    final teamColor = [
                      AppColors.lime,
                      AppColors.purple,
                      AppColors.blue,
                    ][teams.indexOf(team).clamp(0, 2)];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isWinner
                            ? teamColor.withValues(alpha: .12)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isWinner ? teamColor : AppColors.border,
                          width: isWinner ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(medal, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              team.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isWinner ? teamColor : AppColors.white,
                              ),
                            ),
                          ),
                          Text(
                            '${team.score} نقطة',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: teamColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 26),
        LammaButton(
          label: 'العودة للرئيسية',
          onPressed: () => _requestExit(returnHome: true),
        ),
        const SizedBox(height: 12),
        LammaButton(
          label: 'نلعب من جديد',
          secondary: true,
          onPressed: _restart,
        ),
      ],
    );
  }
}
