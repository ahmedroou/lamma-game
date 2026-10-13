part of 'session_screen.dart';

extension _SessionManagement on _SessionScreenState {
  Widget _saveIndicator() => ListenableBuilder(
    listenable: _app!,
    builder: (context, _) {
      final app = _app!;
      final error = app.saveStatus == LocalSaveStatus.error;
      return Row(
        children: [
          Icon(
            error
                ? Icons.warning_amber_rounded
                : app.saveStatus == LocalSaveStatus.saving
                ? Icons.sync_rounded
                : Icons.check_circle_outline,
            size: 16,
            color: error ? AppColors.peach : AppColors.muted,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              error
                  ? 'تعذّر الحفظ على الجهاز'
                  : app.saveStatus == LocalSaveStatus.saving
                  ? 'جاري حفظ الجلسة…'
                  : 'الجلسة محفوظة على الجهاز',
              style: TextStyle(
                fontSize: 12,
                color: error ? AppColors.peach : AppColors.muted,
              ),
            ),
          ),
          if (error)
            TextButton(
              onPressed: _retrySave,
              child: const Text('إعادة المحاولة'),
            ),
        ],
      );
    },
  );
  Future<void> _retrySave() async {
    final saved = await _app?.retrySave() ?? true;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'تم الحفظ على الجهاز.'
              : 'لم يكتمل الحفظ. ابقَ في التطبيق وأعد المحاولة.',
        ),
      ),
    );
  }

  Widget _pausedPanel() => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.blue.withValues(alpha: .3)),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.pause_circle_outline_rounded,
          size: 64,
          color: AppColors.blue,
        ),
        const SizedBox(height: 20),
        Text(
          _model.state.pauseReason == PauseReason.restored
              ? 'جلسة محفوظة… نكمل؟'
              : 'الجلسة متوقفة',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        Text(
          _model.canResume
              ? 'المؤقت واللعب متوقفان. تابع من نفس الجولة والوقت.'
              : 'هذه الجولة تحتاج تعريفات القدرات السابقة؛ احتفظنا بنقاطك وأوراقك.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 18),
        if (_model.state.question != null)
          Tag(
            '${_model.state.secondsRemaining} ثانية متبقية',
            color: AppColors.purple,
          ),
        const SizedBox(height: 22),
        LammaButton(
          label: 'متابعة اللعب',
          onPressed: _model.canResume ? _model.resume : null,
          icon: Icons.play_arrow_rounded,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _requestExit(returnHome: true),
          child: const Text('حفظ والعودة للرئيسية'),
        ),
      ],
    ),
  );

  Future<bool> _flushBeforeLeaving() async {
    try {
      await _app?.flush();
      return true;
    } on Object {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('الحفظ لم يكتمل'),
            content: const Text(
              'الجلسة ما زالت في التطبيق. لن نخرج قبل حفظها حتى لا تفقد التقدم.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('البقاء في الجلسة'),
              ),
            ],
          ),
        );
      }
      return false;
    }
  }

  Future<void> _requestExit({bool returnHome = false}) async {
    if (_exitDialogOpen || !mounted) return;
    _exitDialogOpen = true;
    final wasPaused = _model.state.isPaused;
    final finished = _model.state.phase == SessionPhase.results;
    _model.pause(PauseReason.dialog);
    try {
      final exit =
          finished ||
          await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('نحفظ اللمّة ونرجع؟'),
                  content: const Text(
                    'المؤقت متوقف الآن. يمكنك حفظ الجلسة ومتابعتها لاحقاً من الرئيسية.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('البقاء'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('حفظ وخروج'),
                    ),
                  ],
                ),
              ) ==
              true;
      if (!exit) {
        if (!wasPaused) _model.resume();
        return;
      }
      if (!await _flushBeforeLeaving() || !mounted) return;
      _permitPop();
      if (returnHome) {
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        Navigator.of(context).pop();
      }
    } finally {
      _exitDialogOpen = false;
    }
  }

  Future<void> _confirmEnd() async {
    final wasPaused = _model.state.isPaused;
    _model.pause(PauseReason.dialog);
    final end = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنهاء الجلسة الآن؟'),
        content: const Text(
          'ستُحفظ النتيجة الحالية وتنتهي هذه المباراة. يمكنك بدء مباراة جديدة بعد ذلك.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إنهاء وحفظ النتيجة'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (end == true) {
      _model.endSession();
      await _flushBeforeLeaving();
    } else if (!wasPaused) {
      _model.resume();
    }
  }

  Future<void> _restart() async {
    final wasPaused = _model.state.isPaused;
    _model.pause(PauseReason.dialog);
    final restart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('بدء المباراة من جديد؟'),
        content: const Text(
          'ستبدأ مباراة بنفس الفرق والأقسام وبخمسة أسئلة جديدة لكل قسم. سجل الأسئلة المعروضة على الجهاز يبقى محفوظاً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ابدأ مباراة جديدة'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (restart == true) {
      try {
        final app = _app;
        if (app == null) {
          if (!_model.restart()) throw StateError('No unused questions.');
        } else {
          final next = await app.startSession(
            SessionConfig(
              teams: widget.config.teams.map(
                (team) => TeamState(id: team.id, name: team.name),
              ),
              categoryIds: widget.config.categoryIds,
            ),
          );
          if (!mounted) return;
          _permitPop();
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => SessionScreen(config: next.config, model: next),
            ),
          );
        }
      } on Object {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'لا يمكن بدء مباراة جديدة الآن. نحتاج خمسة أسئلة غير معروضة لكل قسم وحفظاً ناجحاً؛ المباراة الحالية محفوظة.',
              ),
            ),
          );
        }
        if (!wasPaused) _model.resume();
      }
    } else if (!wasPaused) {
      _model.resume();
    }
  }

  String _teamName(String? id) => id == null
      ? 'لا أحد'
      : _model.state.teams.firstWhere((team) => team.id == id).name;
  Future<void> _showHistory() async {
    final wasPaused = _model.state.isPaused;
    _model.pause(PauseReason.dialog);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .8,
          child: ListenableBuilder(
            listenable: _model,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'سجل الجولات',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_model.state.history.length} جولات · ${_model.state.corrections.length} تعديلات على التحكيم',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: _model.state.history.isEmpty
                        ? const Center(child: Text('ما خلّصنا أي جولة للحين.'))
                        : ListView.builder(
                            itemCount: _model.state.history.length,
                            itemBuilder: (context, index) {
                              final record = _model.state.history[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(17),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        Tag(
                                          'الجولة ${record.turn + 1}',
                                          color: AppColors.blue,
                                        ),
                                        Tag(
                                          '${record.question.difficulty.label} · ${record.awardedPoints}',
                                          color: AppColors.gold,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 11),
                                    Text(record.question.text),
                                    const SizedBox(height: 8),
                                    Text(
                                      'التحكيم: ${_teamName(record.awardedTeamId)}',
                                      style: const TextStyle(
                                        color: AppColors.lime,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (record.correctionCount > 0)
                                      Text(
                                        'عُدّل القرار ${record.correctionCount} مرة',
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    TextButton(
                                      onPressed: _model.canCorrect(record)
                                          ? () => _correctJudgment(record)
                                          : null,
                                      child: Text(
                                        _model.canCorrect(record)
                                            ? 'تصحيح التحكيم'
                                            : 'تعديل هذه الجولة مرتبط بالقدرات',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                  LammaButton(
                    label: 'إعادة فتح آخر تحكيم',
                    secondary: true,
                    icon: Icons.undo_rounded,
                    onPressed: _model.canUndoLastDecision
                        ? () async {
                            final confirm = await showDialog<bool>(
                              context: sheetContext,
                              builder: (context) => AlertDialog(
                                title: const Text('إعادة تحكيم آخر جولة؟'),
                                content: const Text(
                                  'سنلغي نقاط قرار الجولة الأخيرة ونعود لإجابتها، مع إبقاء الجلسة متوقفة حتى تختار المتابعة.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('إلغاء'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('إعادة التحكيم'),
                                  ),
                                ],
                              ),
                            );
                            if (!mounted || confirm != true) return;
                            if (_model.undoLastDecision()) {
                              await _flushBeforeLeaving();
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                            }
                          }
                        : null,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('إغلاق السجل'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (mounted &&
        !wasPaused &&
        _model.state.pauseReason == PauseReason.dialog) {
      _model.resume();
    }
  }

  Future<void> _correctJudgment(RoundRecord record) async {
    const nobody = '__no_answer__';
    var selected = record.awardedTeamId ?? nobody;
    final winner = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text('تصحيح الجولة ${record.turn + 1}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'تنقل نقاط السؤال فقط؛ لن نعيد السؤال أو نسحب قدرة جديدة.',
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  initialValue: selected,
                  isExpanded: true,
                  items: [
                    for (final team in _model.state.teams)
                      if (record.answerTeamId == null ||
                          record.answerTeamId == team.id)
                        DropdownMenuItem(
                          value: team.id,
                          child: Text(team.name),
                        ),
                    const DropdownMenuItem(
                      value: nobody,
                      child: Text('لا أحد'),
                    ),
                  ],
                  onChanged: (value) => update(() => selected = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: selected == (record.awardedTeamId ?? nobody)
                  ? null
                  : () => Navigator.pop(context, selected),
              child: const Text('حفظ التصحيح'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || winner == null) return;
    final changed = _model.correctDecision(
      record.id,
      winner == nobody ? null : winner,
      expectedCorrectionCount: record.correctionCount,
    );
    if (changed) {
      await _flushBeforeLeaving();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم يُغيّر القرار؛ أعد فتح السجل إذا تغيرت الجولة.'),
        ),
      );
    }
  }
}
