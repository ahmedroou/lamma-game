import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/app_controller.dart';
import '../../core/app_scope.dart';
import '../../core/game_catalog.dart';
import '../../domain/abilities/ability_system.dart';
import '../../domain/models/session_config.dart';
import '../../domain/models/team.dart';
import '../../shared/components.dart';
import '../../shared/category_card.dart';
import 'session_view_model.dart';
import 'question_card_deck.dart';
import 'question_points_badge.dart';
import 'identity_question_panel.dart';
import 'category_replay_options.dart';
part 'session_management.dart';

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
        appBar: AppBar(
          leading: BackButton(onPressed: () => _requestExit()),
          title: Text(
            _model.state.phase == SessionPhase.results
                ? 'نتائج اللمّة'
                : 'الجولة ${_model.state.turn + 1}',
          ),
          actions: [
            if (_model.state.phase != SessionPhase.results)
              IconButton(
                tooltip: _model.state.isPaused
                    ? 'استئناف اللعب'
                    : 'إيقاف الجلسة',
                onPressed: _model.state.isPaused ? _model.resume : _model.pause,
                icon: Icon(
                  _model.state.isPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                ),
              ),
            IconButton(
              tooltip: 'سجل الجولات',
              onPressed: _showHistory,
              icon: const Icon(Icons.history_rounded),
            ),
            PopupMenuButton<String>(
              tooltip: 'إدارة الجلسة',
              onSelected: (value) {
                if (value == 'save') {
                  _requestExit(returnHome: true);
                } else if (value == 'end') {
                  _confirmEnd();
                } else {
                  _restart();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'save',
                  child: Text('حفظ والعودة للرئيسية'),
                ),
                if (_model.state.phase != SessionPhase.results)
                  const PopupMenuItem(
                    value: 'end',
                    child: Text('إنهاء الجلسة'),
                  ),
                const PopupMenuItem(
                  value: 'restart',
                  child: Text('بدء المباراة من جديد'),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_app != null) ...[
                      _saveIndicator(),
                      const SizedBox(height: 12),
                    ],
                    _scores(),
                    const SizedBox(height: 24),
                    if (!_model.state.isPaused &&
                        (_model.state.phase == SessionPhase.categories ||
                            _model.state.phase == SessionPhase.results))
                      CategoryReplayOptions(
                        categoryIds: widget.config.categoryIds,
                      ),
                    if (_model.state.isPaused)
                      _pausedPanel()
                    else if (_model.state.phase == SessionPhase.results)
                      _result()
                    else if (_model.state.phase == SessionPhase.categories)
                      _board()
                    else
                      _round(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _scores() => LayoutBuilder(
    builder: (context, constraints) {
      final teams = _model.state.teams;
      final columns =
          constraints.maxWidth < 330 && teams.length == 3 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.5
          ? 1
          : teams.length;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < teams.length; i++)
            SizedBox(
              width: (constraints.maxWidth - 10 * (columns - 1)) / columns,
              child: _team(teams[i], i),
            ),
        ],
      );
    },
  );

  Widget _team(TeamState team, int index) {
    final color = [AppColors.lime, AppColors.purple, AppColors.blue][index];
    final active =
        _model.state.phase != SessionPhase.results &&
        team.id == _model.state.answeringTeam.id;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _inventory(team.id),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: active ? color : AppColors.border),
          ),
          child: Column(
            children: [
              Text(
                team.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: active ? color : AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '${team.score}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_outlined, size: 13, color: color),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '${team.inventory.length} قدرات',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _board() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Tag('الدور: ${_model.state.activeTeam.name}', icon: Icons.bolt_rounded),
      const SizedBox(height: 18),
      Text(
        'اختار ساحة التحدّي',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 8),
      const Text(
        'ستة أقسام… وفي السابع مخاطرة تغيّر اللعبة.',
        style: TextStyle(color: AppColors.muted),
      ),
      const SizedBox(height: 22),
      CategoryGrid(
        categories: gameCategories
            .where(
              (category) => widget.config.categoryIds.contains(category.id),
            )
            .toList(),
        maxColumns: 3,
        itemBuilder: (category) {
          final remaining = _model.remainingForCategory(category.id);
          return CategoryCard(
            key: ValueKey('play-category-${category.id}'),
            category: category,
            remaining: remaining,
            onTap: remaining > 0
                ? () => _model.selectCategory(category.id)
                : null,
          );
        },
      ),
      const SizedBox(height: 16),
      Material(
        color: const Color(0xFF28241B),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () {
            if (!_model.selectCategory(GameRules.abilitiesCategoryId)) {
              _riskInfo();
            }
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.gold.withValues(alpha: .4)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.style_outlined,
                  size: 42,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '07 / قسم القدرات',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'نقاط السؤال + ورقة قدرة… أو خسارة 50 / 100 / 150',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      const SizedBox(height: 9),
                      Tag(
                        _model.abilitiesEnabled ? 'جرّب حظك' : 'قريباً',
                        color: AppColors.gold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _round() {
    final state = _model.state;
    final question = state.question!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Tag(
              gameCategories
                  .firstWhere((category) => category.id == question.categoryId)
                  .title,
              color: AppColors.blue,
            ),
            Tag(
              '${question.difficulty.label} · ${state.availablePoints} نقطة',
              color: AppColors.gold,
            ),
            Tag(
              '${state.opponentTeamId == null ? 'الدور' : 'فرصة الخصم'}: ${state.answeringTeam.name}',
              color: state.opponentTeamId == null
                  ? AppColors.muted
                  : AppColors.purple,
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_model.revealing || _model.revealError != null) ...[
          Text(
            _model.revealing ? 'نحفظ السؤال قبل كشفه…' : _model.revealError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.gold),
          ),
          if (_model.revealError != null)
            TextButton(
              onPressed: _model.revealQuestion,
              child: const Text('إعادة محاولة كشف السؤال'),
            ),
          const SizedBox(height: 14),
        ],
        if (state.isOpponentWindow) ...[
          Container(
            key: const ValueKey('opponent-opportunity'),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: .14),
              border: Border.all(color: AppColors.purple),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'فرصة ${state.answeringTeam.name} وحده',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${state.secondsRemaining} ثوانٍ',
                  style: const TextStyle(fontSize: 32, color: AppColors.gold),
                ),
                Text(
                  state.opponentSelectedByLot
                      ? 'اختير بالقرعة لتساوي نقاط الخصمين'
                      : state.teams.length == 3
                      ? 'الخصم الأقل نقاطاً'
                      : 'فرصة الفريق الآخر',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value:
                        state.secondsRemaining /
                        GameRules.opponentAnswerSeconds,
                    minHeight: 4,
                    color: AppColors.purple,
                    backgroundColor: AppColors.purple.withValues(alpha: .15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        if (question.isIdentity)
          IdentityQuestionPanel(
            state: state,
            onStart: () {
              for (var i = 0; i < 3; i++) {
                _model.revealCard(i);
              }
            },
            onNext: _model.revealNextClue,
          )
        else if (state.isOpponentWindow)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: .12),
              border: Border.all(color: AppColors.blue.withValues(alpha: .35)),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                QuestionPointsBadge(
                  key: const ValueKey('question-points'),
                  points: state.availablePoints,
                ),
                const SizedBox(height: 16),
                Text(
                  question.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else
          QuestionCardDeck(
            key: ValueKey('${state.turn}-${question.id}'),
            question: question.text,
            points: state.availablePoints,
            surpriseText: state.surpriseCard?.text,
            revealedCards: state.revealedCards,
            secondsRemaining: state.secondsRemaining,
            onReveal: _model.revealCard,
          ),
        const SizedBox(height: 20),
        if (state.revealedCards == 3 && question.imageAsset != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              question.imageAsset!,
              height: 240,
              fit: BoxFit.contain,
              semanticLabel: question.imageDescription,
              errorBuilder: (context, error, stack) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('تعذّر عرض صورة السؤال.'),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (state.revealedCards == 3 &&
            !question.isIdentity &&
            question.hint.isNotEmpty &&
            (state.hintRevealed || _model.canRevealHint)) ...[
          if (state.hintRevealed)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'تلميح مساعد: ${question.hint}',
                style: const TextStyle(color: AppColors.gold),
              ),
            )
          else
            TextButton.icon(
              onPressed: _model.revealHint,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('عرض تلميح مساعد'),
            ),
          const SizedBox(height: 16),
        ],
        if (state.revealedCards == 3 && state.phase == SessionPhase.cards) ...[
          Text(
            state.isOpponentWindow && state.secondsRemaining > 0
                ? 'الجواب مخفي حتى تنتهي فرصة ${state.answeringTeam.name}.'
                : state.secondsRemaining > 0
                ? 'الوقت بدأ… فكّروا بسرعة!'
                : 'انتهى الوقت. اكشفوا الإجابة واحسموا الجولة.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 15),
          LammaButton(
            label: 'كشف الإجابة',
            onPressed: _model.canShowAnswer ? _model.showAnswer : null,
            icon: Icons.visibility_outlined,
          ),
          if (state.opponentTeamId == null)
            TextButton(
              onPressed: _model.startOpponentOpportunity,
              child: const Text('إجابة خاطئة أو تمرير · فرصة للخصم'),
            ),
          if (state.opponentTeamId == null)
            const Text(
              'الكشف المبكر ينهي فرصة الإجابة لهذا السؤال. مرّر للخصم قبل كشف الجواب إذا كانت الإجابة خاطئة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
        ],
        if (state.phase == SessionPhase.answer) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'الإجابة الصحيحة',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 10),
                Text(
                  question.answer,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (question.explanation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    question.explanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
                if (question.acceptedAnswers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'يُقبل أيضًا: ${question.acceptedAnswers.join('، ')}',
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 12),
                const Text(
                  'مين جاوب صح والتزم بالشرط؟',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          for (var i = 0; i < state.teams.length; i++) ...[
            LammaButton(
              label: '${state.teams[i].name} +${state.availablePoints}',
              onPressed:
                  state.opponentTeamId == null ||
                      state.opponentTeamId == state.teams[i].id
                  ? () => _model.awardAnswer(state.teams[i].id)
                  : null,
              secondary: i > 0,
            ),
            const SizedBox(height: 10),
          ],
          TextButton(
            onPressed: () => _model.awardAnswer(null),
            child: const Text('لا أحد · نكمل'),
          ),
        ],
      ],
    );
  }

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
                'هنا تختبر حظك بسؤال من أقسام جلستك. تكسب نقاطه وورقة قدرة، أو تخسر 50 أو 100 أو 150 نقطة. قريباً تنكشف أوراق القدرات!',
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
                            'لكل فريق مخزونه الخاص. القدرات الجديدة قريباً.',
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
    final enabled =
        definition != null &&
        _model.abilities.isReady(card.definitionId) &&
        (definition.windows.contains(AbilityWindow.anyTime) ||
            definition.windows.contains(_model.abilityWindow)) &&
        _model.state.phase != SessionPhase.results &&
        !_model.state.isPaused;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        try {
                          _model.useAbility(
                            ownerTeamId: team.id,
                            cardId: card.id,
                            targetTeamId: target,
                          );
                        } on StateError {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'هذه القدرة غير متاحة في هذه اللحظة.',
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                child: Text(enabled ? 'استخدم القدرة' : 'غير متاحة الآن'),
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
          Text(
            winners.map((team) => team.name).join(' • '),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.lime),
          ),
        const SizedBox(height: 12),
        const Text(
          'أحلى فوز؟ إنكم اجتمعتوا.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 30),
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
