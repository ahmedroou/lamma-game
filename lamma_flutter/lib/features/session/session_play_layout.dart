part of 'session_screen.dart';

extension _SessionPlayLayout on _SessionScreenState {
  Widget _playCanvas() => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, box) {
            final wide =
                box.maxWidth >= 480 && box.maxWidth > box.maxHeight * 1.35;
            return Padding(
              padding: EdgeInsets.all(wide ? 4 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_app != null) _saveIndicator(),
                  if (_model.state.phase == SessionPhase.categories) ...[
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 42),
                      child: SizedBox(height: wide ? 32 : 44, child: _scores()),
                    ),
                    SizedBox(height: wide ? 3 : 6),
                  ],
                  Expanded(
                    child: _model.state.isPaused
                        ? _compactPause()
                        : _model.state.phase == SessionPhase.categories
                        ? _board()
                        : _round(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );

  Widget _scores() => Row(
    key: const ValueKey('team-scoreboard'),
    children: [
      for (var i = 0; i < _model.state.teams.length; i++) ...[
        if (i > 0) const SizedBox(width: 5),
        Expanded(child: _team(_model.state.teams[i], i)),
      ],
    ],
  );

  Widget _team(TeamState team, int index) {
    final color = [AppColors.lime, AppColors.purple, AppColors.blue][index];
    final active = team.id == _model.state.answeringTeam.id;
    return Material(
      color: active ? color.withValues(alpha: .12) : AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _model.abilitiesEnabled || team.inventory.isNotEmpty
            ? () => _inventory(team.id)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? color : AppColors.border,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FitText(
                        team.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: active ? color : AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_model.abilitiesEnabled ||
                        team.inventory.isNotEmpty) ...[
                      const SizedBox(width: 3),
                      Icon(Icons.style_outlined, color: color, size: 11),
                      const SizedBox(width: 2),
                      FitText(
                        '${team.inventory.length}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    _scoreButton(
                      icon: Icons.remove_rounded,
                      color: AppColors.peach,
                      key: ValueKey('team-score-minus-${team.id}'),
                      tooltip: 'خصم 50 نقطة من ${team.name}',
                      onTap: () => _adjustScore(team.id, -50),
                    ),
                    Expanded(
                      child: FitText(
                        '${team.score}',
                        style: TextStyle(
                          fontSize: 16,
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _scoreButton(
                      icon: Icons.add_rounded,
                      color: AppColors.lime,
                      key: ValueKey('team-score-plus-${team.id}'),
                      tooltip: 'إضافة 50 نقطة لـ ${team.name}',
                      onTap: () => _adjustScore(team.id, 50),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreButton({
    required IconData icon,
    required Color color,
    required Key key,
    required String tooltip,
    required VoidCallback onTap,
  }) => Semantics(
    button: true,
    label: tooltip,
    child: SizedBox(
      width: 20,
      height: 20,
      child: IconButton(
        key: key,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        iconSize: 13,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          backgroundColor: color.withValues(alpha: .14),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(color: color.withValues(alpha: .35), width: 1),
          ),
        ),
        icon: Icon(icon),
        onPressed: onTap,
      ),
    ),
  );

  Widget _surface(
    Widget child, {
    Color color = AppColors.blue,
    double padding = 8,
  }) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: .25)),
    ),
    child: child,
  );

  Widget _compactPause() => _surface(
    Column(
      children: [
        Expanded(
          child: Column(
            children: [
              const Expanded(
                child: Icon(
                  Icons.pause_circle_outline_rounded,
                  size: 48,
                  color: AppColors.blue,
                ),
              ),
              Expanded(
                child: FitText(
                  _model.state.pauseReason == PauseReason.restored
                      ? 'جلسة محفوظة… نكمل؟'
                      : 'الجلسة متوقفة',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: FitText(
                  _model.canResume
                      ? 'المؤقت واللعب متوقفان. تابع من نفس الجولة والوقت.'
                      : 'هذه الجولة تحتاج تعريفات القدرات السابقة؛ احتفظنا بنقاطك وأوراقك.',
                  style: const TextStyle(fontSize: 15, color: AppColors.muted),
                ),
              ),
              if (_model.state.question != null)
                Expanded(
                  child: FitText(
                    '${_model.state.secondsRemaining} ثانية متبقية',
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: PlayButton(
            label: 'متابعة اللعب',
            onPressed: _model.canResume ? _model.resume : null,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: PlayButton(
            label: 'حفظ والعودة للرئيسية',
            secondary: true,
            onPressed: () => _requestExit(returnHome: true),
          ),
        ),
      ],
    ),
  );

  Widget _board() {
    final state = _model.state;
    final categories = gameCategories
        .where((c) => widget.config.categoryIds.contains(c.id))
        .toList();
    final messages = _effectMessages();
    if (_model.forcedCategoryId case final String id) {
      messages.add(
        'قسم هذه الجولة محدد بواسطة ورقة الخصم: ${gameCategories.firstWhere((c) => c.id == id).title}',
      );
    }
    if (state.history.isNotEmpty &&
        state.history.last.isAbilityRound &&
        state.history.last.awardedTeamId == state.history.last.actingTeamId &&
        state.history.last.roundData['rewardDefinitionId'] != null) {
      messages.add(
        'بطاقة جديدة: ${_model.abilities.definitions[state.history.last.roundData['rewardDefinitionId']]?.title ?? 'قدرة'}',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 34,
          child: Row(
            children: [
              const Expanded(
                flex: 2,
                child: FitText(
                  'اختار ساحة التحدّي',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              Expanded(
                child: FitText(
                  'الدور: ${state.activeTeam.name}',
                  style: const TextStyle(fontSize: 13, color: AppColors.lime),
                ),
              ),
              if (_app != null)
                IconButton(
                  tooltip: 'إعادة الأقسام المكتملة',
                  iconSize: 20,
                  onPressed: () => _showDetails(
                    CategoryReplayOptions(
                      categoryIds: widget.config.categoryIds,
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                ),
            ],
          ),
        ),
        if (messages.isNotEmpty)
          SizedBox(
            height: 30,
            child: FitText(
              messages.join(' · '),
              style: const TextStyle(fontSize: 12, color: AppColors.gold),
            ),
          ),
        const SizedBox(height: 6),
        Expanded(
          child: Column(
            children: [
              for (var row = 0; row < 2; row++) ...[
                if (row > 0) const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      for (var column = 0; column < 3; column++) ...[
                        if (column > 0) const SizedBox(width: 8),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final c = categories[row * 3 + column];
                              final remaining = _model.remainingForCategory(
                                c.id,
                              );
                              return SizedBox.expand(
                                child: CategoryCard(
                                  key: ValueKey('play-category-${c.id}'),
                                  category: c,
                                  dense: true,
                                  remaining: remaining,
                                  onTap:
                                      remaining > 0 &&
                                          (_model.forcedCategoryId == null ||
                                              _model.forcedCategoryId == c.id)
                                      ? () => _model.selectCategory(c.id)
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_model.abilitiesEnabled) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: Material(
              color: AppColors.gold.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap:
                    _model.remainingForCategory(GameRules.abilitiesCategoryId) >
                            0 &&
                        _model.abilityChoicesLeft(state.activeTeam.id) > 0
                    ? () {
                        if (!_model.selectCategory(
                          GameRules.abilitiesCategoryId,
                        )) {
                          _riskInfo();
                        }
                      }
                    : _riskInfo,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.style_outlined,
                        color: AppColors.gold,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: FitText(
                          '07 / قسم القدرات',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FitText(
                          '${_model.remainingForCategory(GameRules.abilitiesCategoryId)}/6 أسئلة · لفريقك ${_model.abilityChoicesLeft(state.activeTeam.id)} اختيارات',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<String> _effectMessages() {
    final state = _model.state;
    return [
      if (state.roundData['doubleAbilityTeamId'] != null)
        'بطاقة الدبل مفعّلة لصاحبها',
      if (state.roundData['blockOpponentTeamId'] != null)
        'لا فرصة إجابة لأي خصم بعد الفريق الأساسي في هذا السؤال.',
      for (final ban
          in (state.roundData['abilityPlayerBans'] as List? ?? const []))
        'منع لاعب من ${state.teams.firstWhere((t) => t.id == (ban as Map)['target']).name} لهذا السؤال؛ يحدد المضيف واللاعبون الشخص ويلتزمون بالمنع.',
      if (state.roundData['googleTeamId'] != null &&
          state.phase == SessionPhase.cards)
        _model.googleSecondsLeft > 0
            ? 'وقت البحث: ${_model.googleSecondsLeft} ثانية · مؤقت السؤال مستمر'
            : 'انتهت مهلة البحث؛ أغلقوا قوقل وأكملوا وفق وقت السؤال.',
      if (state.roundData['diceTeamId'] == state.answeringTeam.id &&
          state.revealedCards == 3)
        '🎲 نتيجة النرد: ${state.roundData['diceResult']} · الصحيح بين الخيارات',
      for (final ban in SurpriseSessionEffects.activeBans(
        state.sessionEffects,
        state.turn,
      ))
        'مستبعد من الإجابة والنقاش: ${ban['player']} · ${state.teams.firstWhere((t) => t.id == ban['target']).name}',
    ];
  }

  Future<void> _showDetails(Widget child) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );

  Widget _round({bool fitViewport = false}) {
    if (!fitViewport) {
      return LayoutBuilder(
        builder: (context, box) {
          final wide =
              box.maxWidth >= 480 && box.maxWidth > box.maxHeight * 1.25;
          if (wide) return _round(fitViewport: true);
          final q = _model.state.question!;
          final scale = MediaQuery.textScalerOf(
            context,
          ).scale(1).clamp(1.0, 1.5);
          final minimum =
              (610 +
                  (q.presentation != null ? 120 : 0) +
                  (q.imageAsset != null ? 140 : 0)) *
              scale;
          return SingleChildScrollView(
            key: const ValueKey('portrait-card-table'),
            child: SizedBox(
              height: box.maxHeight > minimum ? box.maxHeight : minimum,
              child: _round(fitViewport: true),
            ),
          );
        },
      );
    }
    final state = _model.state;
    final q = state.question!;
    final opened = state.revealedCards == 3;
    final answer = state.phase == SessionPhase.answer;
    final messages = _effectMessages();
    final paper = state.surpriseCard;
    final structured =
        opened &&
        q.presentation != null &&
        !(q.presentation!.type.name == 'symbols' &&
            q.imageAsset != null &&
            q.presentation!.elements.every((e) => e.text == 'الرسم المرفق'));
    final actions = <Widget>[];
    if (!opened) {
      if (_model.revealError != null) {
        actions.add(
          PlayButton(
            label: 'إعادة محاولة كشف السؤال',
            onPressed: _model.revealQuestion,
          ),
        );
      }
    } else if (answer) {
      for (final team in state.teams) {
        actions.add(
          PlayButton(
            label: '${team.name} +${_model.pointsForTeam(team.id)}',
            secondary: team.id != state.answeringTeam.id,
            onPressed:
                (state.opponentTeamId != null
                    ? state.answeringTeam.id == team.id
                    : (!_model.opponentsBlocked ||
                          team.id == state.activeTeam.id))
                ? () => _model.awardAnswer(team.id)
                : null,
          ),
        );
      }
      actions.add(
        PlayButton(
          label: 'لا أحد · نكمل',
          secondary: true,
          onPressed: () => _model.awardAnswer(null),
        ),
      );
    } else {
      if (q.isIdentity &&
          state.identityCluesRevealed < 3 &&
          state.secondsRemaining > 0) {
        actions.add(
          PlayButton(
            label:
                'التلميح التالي · ${q.pointsForClues(state.identityCluesRevealed + 1)} نقطة',
            onPressed: _model.revealNextClue,
            secondary: true,
          ),
        );
      }
      if (state.plankRunning) {
        actions.add(
          PlayButton(
            label: 'انتهى البلانك · إنهاء وقت الفريق',
            onPressed: _model.finishPlank,
          ),
        );
      }
      if (!state.isOpponentWindow &&
          {
            SurpriseEffect.hint,
            SurpriseEffect.options,
          }.contains(paper?.effect) &&
          state.roundData['surpriseActionUsed'] != true &&
          !(paper?.effect == SurpriseEffect.options &&
              state.visibleOptions.length == 6) &&
          !state.hintRevealed) {
        actions.add(
          PlayButton(
            label: paper!.price > 0
                ? 'ادفع ${paper.price} نقطة واكشف ${paper.effect == SurpriseEffect.hint ? 'التلميح' : 'الخيارات'}'
                : paper.pointsDivisor == 4
                ? 'أقبل ربع النقاط وأكشف الخيارات'
                : paper.effect == SurpriseEffect.hint
                ? 'كشف التلميح مجانًا'
                : 'كشف الخيارات',
            onPressed: _model.canActivateSurprise
                ? _model.activateSurprise
                : null,
            secondary: true,
          ),
        );
      }
      if (!q.isIdentity &&
          q.hint.isNotEmpty &&
          !state.hintRevealed &&
          _model.canRevealHint &&
          paper?.effect != SurpriseEffect.hint) {
        actions.add(
          PlayButton(
            label: 'عرض تلميح مساعد',
            onPressed: _model.revealHint,
            secondary: true,
          ),
        );
      }
      actions.add(
        PlayButton(
          label: 'كشف الإجابة',
          onPressed: _model.canShowAnswer ? _model.showAnswer : null,
        ),
      );
      if (state.opponentTeamId == null && !_model.opponentsBlocked) {
        actions.add(
          PlayButton(
            label: 'إجابة خاطئة أو تمرير · فرصة للخصم',
            onPressed: _model.startOpponentOpportunity,
            secondary: true,
          ),
        );
      }
    }
    if (_model.canChoosePlank && state.revealedCards >= 1) {
      actions.addAll([
        PlayButton(
          label: 'أقبل التحدي · يبدأ مع السؤال',
          onPressed: _model.acceptPlank,
        ),
        PlayButton(
          label: 'رفض التحدي · خصم 100 نقطة',
          onPressed: _model.refusePlank,
          secondary: true,
        ),
      ]);
    }
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth > box.maxHeight * 1.35;
        Widget questionArea() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (q.categoryId == 'reverse_question')
              const SizedBox(
                height: 26,
                child: FitText(
                  'الجواب أمامك: ما السؤال الذي يُطرح لتكون هذه إجابته؟',
                  style: TextStyle(fontSize: 12, color: AppColors.peach),
                ),
              ),
            Expanded(
              flex: opened && (q.imageAsset != null || answer) ? 2 : 3,
              child: q.isIdentity && opened
                  ? Column(
                      children: [
                        for (var i = 0; i < state.identityCluesRevealed; i++)
                          Expanded(
                            child: _surface(
                              FitText(
                                q.clues[i],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              color: AppColors.purple,
                              padding: 5,
                            ),
                          ),
                      ],
                    )
                  : FitText(
                      opened
                          ? q.text
                          : q.isIdentity
                          ? 'من أنا؟'
                          : 'ثلاث بطاقات… والتحدّي يبدأ',
                      style: TextStyle(
                        fontSize: wide ? 25 : 30,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
            ),
            if (opened && q.imageAsset != null)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    q.imageAsset!,
                    fit: BoxFit.contain,
                    semanticLabel: q.imageDescription,
                    errorBuilder: (_, _, _) =>
                        const FitText('تعذّر عرض صورة السؤال.'),
                  ),
                ),
              ),
            if (opened &&
                state.hintRevealed &&
                !q.isIdentity &&
                q.hint.isNotEmpty)
              Expanded(
                child: FitText(
                  'تلميح مساعد: ${q.hint}',
                  style: const TextStyle(fontSize: 16, color: AppColors.gold),
                ),
              ),
            if (answer)
              Expanded(
                flex: 3,
                child: _surface(
                  Column(
                    children: [
                      const Expanded(
                        child: FitText(
                          'الإجابة الصحيحة',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: FitText(
                          q.answer,
                          style: const TextStyle(
                            fontSize: 26,
                            color: AppColors.lime,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (q.explanation.isNotEmpty)
                        Expanded(
                          child: FitText(
                            q.explanation,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                    ],
                  ),
                  color: AppColors.lime,
                  padding: 5,
                ),
              ),
          ],
        );

        Widget premises() => Column(
          children: [
            if (structured)
              Expanded(
                flex: 3,
                child: StructuredQuestionPanel(
                  key: ValueKey('${q.id}-${state.answeringTeam.id}'),
                  presentation: q.presentation!,
                  draft: state.questionDraft,
                  enabled: _model.canEditQuestionDraft,
                  onChanged: _model.updateQuestionDraft,
                  compact: true,
                  comparisonInteraction: q.subtype == 'number_nearest'
                      ? ComparisonInteraction.nearest
                      : q.categoryId == 'first_last'
                      ? ComparisonInteraction.endpoints
                      : ComparisonInteraction.order,
                ),
              ),
            if (state.visibleOptions.isNotEmpty) ...[
              if (structured) const SizedBox(height: 6),
              Expanded(
                flex: 2,
                child: _fixedGrid(
                  state.visibleOptions
                      .map(
                        (o) => _surface(
                          FitText(
                            '${o.id} · ${o.text}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          padding: 6,
                        ),
                      )
                      .toList(),
                  2,
                ),
              ),
            ],
          ],
        );
        final hasPremises = structured || state.visibleOptions.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 32,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 42),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: state.isOpponentWindow
                          ? Column(
                              key: const ValueKey('opponent-opportunity'),
                              children: [
                                Expanded(
                                  child: FitText(
                                    'فرصة ${state.answeringTeam.name} وحده',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.purple,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FitText(
                                    state.opponentSelectedByLot
                                        ? 'اختير بالقرعة'
                                        : state.teams.length == 3
                                        ? 'الخصم الأقل نقاطاً'
                                        : 'فرصة الفريق الآخر',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: FitText(
                                    gameCategories
                                        .firstWhere((c) => c.id == q.categoryId)
                                        .title,
                                    style: const TextStyle(
                                      color: AppColors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FitText(
                                    'الدور: ${state.answeringTeam.name}',
                                    style: const TextStyle(
                                      color: AppColors.lime,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    Expanded(
                      flex: 2,
                      child: FitText(
                        '${state.availablePoints} نقطة',
                        key: const ValueKey('question-points'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (opened)
                      Expanded(
                        flex: 2,
                        child: FitText(
                          '${state.clockSeconds} ${state.plankAccepted ? 'ثانية بلانك' : 'ثانية'}',
                          style: TextStyle(
                            color: state.clockSeconds <= 7
                                ? AppColors.peach
                                : AppColors.lime,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (messages.isNotEmpty)
              SizedBox(
                height: 32,
                child: FitText(
                  messages.join(' · '),
                  style: const TextStyle(fontSize: 12, color: AppColors.gold),
                ),
              ),
            if (_model.revealing || _model.revealError != null)
              SizedBox(
                height: 28,
                child: FitText(
                  _model.revealing
                      ? 'نحفظ السؤال قبل كشفه…'
                      : _model.revealError!,
                  style: const TextStyle(fontSize: 12, color: AppColors.peach),
                ),
              ),
            const SizedBox(height: 4),
            Expanded(
              child: CinematicRoundDeck(
                key: ValueKey('cinematic-${state.turn}-${q.id}'),
                sideBySide: wide,
                revealedCards: state.revealedCards,
                animate: _app?.settings.motion ?? true,
                questionTitle: q.categoryId == 'reverse_question'
                    ? 'الجواب'
                    : 'السؤال',
                revealLabels: [
                  q.isIdentity && paper != null
                      ? 'اكشف ورقة المفاجأة أولًا'
                      : 'اضغط للكشف',
                  'اضغط للكشف',
                  q.isIdentity
                      ? 'اكشف التلميح الأول · ${q.points} نقطة'
                      : 'اضغط للكشف',
                ],
                canReveal: [
                  for (var i = 0; i < 3; i++)
                    state.revealedCards == i &&
                        !_model.revealing &&
                        !(i == 2 &&
                            (state.roundData['plankDecision'] == 'pending' ||
                                state.roundData['wheelStatus'] == 'pending')),
                ],
                onReveal: (i) {
                  if (_app?.settings.haptics ?? false) {
                    HapticFeedback.lightImpact();
                  }
                  _model.revealCard(i);
                },
                faces: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: FitText(
                          paper?.text ?? 'جولة بلا مفاجأة',
                          style: const TextStyle(
                            fontSize: 23,
                            color: AppColors.lime,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: FitText(
                          paper?.note ?? 'جاوبوا عن السؤال ضمن الوقت المحدد.',
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),
                      if (paper != null)
                        OpeningCardControls(
                          key: ValueKey(
                            'opening-${state.turn}-${q.id}-${state.answeringTeam.id}',
                          ),
                          model: _model,
                          compact: true,
                        ),
                    ],
                  ),
                  Column(
                    children: [
                      const Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Icon(
                            Icons.timer_outlined,
                            size: 36,
                            color: AppColors.purple,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: FitText(
                          '${state.clockSeconds}',
                          style: TextStyle(
                            fontSize: 66,
                            color: state.clockSeconds <= 7 && opened
                                ? AppColors.peach
                                : AppColors.purple,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FitText(
                          state.plankAccepted ? 'ثانية بلانك' : 'ثانية',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FitText(
                          !opened
                              ? 'المؤقت يبدأ بكشف السؤال'
                              : state.isOpponentWindow
                              ? 'فرصة الخصم'
                              : state.secondsRemaining > 0
                              ? 'الوقت يجري…'
                              : 'انتهى الوقت',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  wide && hasPremises
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 4, child: questionArea()),
                            const SizedBox(width: 8),
                            Expanded(flex: 5, child: premises()),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(flex: 4, child: questionArea()),
                            if (hasPremises) ...[
                              const SizedBox(height: 8),
                              Expanded(flex: 5, child: premises()),
                            ],
                          ],
                        ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height:
                  ((actions.length.clamp(1, 12) / (wide ? 4 : 2)).ceil() * 44 -
                          2)
                      .toDouble(),
              child: actions.isEmpty
                  ? const FitText(
                      'اكشف المفاجأة، ثم الوقت، ثم السؤال',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    )
                  : _fixedGrid(
                      actions,
                      wide
                          ? actions.length.clamp(1, 4)
                          : actions.length.clamp(1, 2),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _fixedGrid(List<Widget> children, int columns) {
    final rows = (children.length / columns).ceil();
    return Column(
      children: [
        for (var row = 0; row < rows; row++) ...[
          if (row > 0) const SizedBox(height: 4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < columns; col++) ...[
                  if (col > 0) const SizedBox(width: 4),
                  Expanded(
                    child: row * columns + col < children.length
                        ? children[row * columns + col]
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
