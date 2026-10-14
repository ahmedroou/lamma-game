part of 'structured_question_panel.dart';

extension _CompactPremises on _StructuredQuestionPanelState {
  Widget _compactPanel() {
    final p = widget.presentation;
    return LayoutBuilder(
      builder: (context, box) {
        if (widget.draft.isNotEmpty && box.maxHeight < 110) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: p.type == QuestionPresentationType.matching
                    ? _compactMatching()
                    : _compactElements(),
              ),
              SizedBox(
                width: 28,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: IconButton(
                    tooltip: 'مسح ترتيبك',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    onPressed: widget.enabled
                        ? () {
                            _selectLeft(null);
                            widget.onChanged(const {});
                          }
                        : null,
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            if (widget.draft.isNotEmpty)
              SizedBox(
                height: 24,
                child: Row(
                  children: [
                    const Expanded(
                      child: FitText(
                        'ترتيب الفريق',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: PlayButton(
                        label: 'مسح ترتيبك',
                        secondary: true,
                        onPressed: widget.enabled
                            ? () {
                                _selectLeft(null);
                                widget.onChanged(const {});
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: p.type == QuestionPresentationType.matching
                  ? _compactMatching()
                  : _compactElements(),
            ),
          ],
        );
      },
    );
  }

  Widget _compactMatching() => LayoutBuilder(
    builder: (context, box) {
      final p = widget.presentation;
      return Row(
        children: [
          for (var side = 0; side < 2; side++) ...[
            if (side > 0) const SizedBox(width: 6),
            Expanded(
              child: Column(
                children: [
                  if (p.sections[side].title.isNotEmpty)
                    SizedBox(
                      height: 20,
                      child: FitText(
                        p.sections[side].title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  Expanded(
                    child: _premiseGrid([
                      for (final e in p.sections[side].items)
                        _compactTile(
                          e,
                          selected: side == 0
                              ? _left == e.id ||
                                    widget.draft.containsKey('pair:${e.id}')
                              : widget.draft.entries.any(
                                  (v) =>
                                      v.key.startsWith('pair:') &&
                                      v.value == e.id,
                                ),
                          onTap: () => _compactLink(e, side == 0),
                          footer: SizedBox(
                            height: 16,
                            child: FitText(
                              side == 0
                                  ? widget.draft.containsKey('pair:${e.id}')
                                        ? '← الطرف ${p.sections.last.items.indexWhere((r) => r.id == widget.draft['pair:${e.id}']) + 1}'
                                        : 'اختر ثم صِل'
                                  : 'الطرف ${p.sections[side].items.indexOf(e) + 1}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.blue,
                              ),
                            ),
                          ),
                        ),
                    ], box.maxHeight / p.sections[side].items.length < 60 ? 2 : 1),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    },
  );

  Widget _premiseGrid(List<Widget> items, int columns) => Column(
    children: [
      for (var row = 0; row < (items.length / columns).ceil(); row++) ...[
        if (row > 0) const SizedBox(height: 4),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var col = 0; col < columns; col++) ...[
                if (col > 0) const SizedBox(width: 4),
                Expanded(
                  child: row * columns + col < items.length
                      ? items[row * columns + col]
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      ],
    ],
  );

  void _compactLink(QuestionElement e, bool left) {
    if (!widget.enabled) return;
    if (left) {
      _selectLeft(e.id);
      return;
    }
    if (_left == null) return;
    final next = Map<String, String>.from(widget.draft)
      ..removeWhere((key, value) => key.startsWith('pair:') && value == e.id);
    next['pair:$_left'] = e.id;
    widget.onChanged(next);
    _selectLeft(null);
  }

  Widget _compactTile(
    QuestionElement e, {
    bool selected = false,
    VoidCallback? onTap,
    Widget? footer,
  }) => Material(
    color: selected ? AppColors.blue.withValues(alpha: .18) : AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: selected ? AppColors.blue : AppColors.border),
    ),
    child: InkWell(
      key: ValueKey('element-${e.id}'),
      borderRadius: BorderRadius.circular(10),
      onTap: !widget.enabled
          ? null
          : e.missing
          ? () => _editMissing(e)
          : onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Expanded(
              child: FitText(
                direction: RegExp('[ء-ي]').hasMatch(e.text)
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                e.missing
                    ? widget.draft['missing:${e.id}'] ?? '؟ · أدخل القيمة'
                    : e.text,
                style: TextStyle(
                  fontSize:
                      widget.presentation.type ==
                          QuestionPresentationType.symbols
                      ? 32
                      : 17,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
            if (footer != null) Flexible(child: footer),
          ],
        ),
      ),
    ),
  );

  Future<void> _editMissing(QuestionElement e) async {
    final controller = TextEditingController(
      text: widget.draft['missing:${e.id}'],
    );
    try {
      final value = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('القيمة الناقصة'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 120,
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('اعتماد'),
            ),
          ],
        ),
      );
      if (mounted && value != null) _change('missing:${e.id}', value);
    } finally {
      controller.dispose();
    }
  }

  Widget _compactElements() => LayoutBuilder(
    builder: (context, box) {
      final p = widget.presentation;
      var elements = p.elements;
      final isOrder =
          p.type == QuestionPresentationType.comparison &&
          widget.comparisonInteraction == ComparisonInteraction.order;
      if (isOrder) {
        try {
          final order = (jsonDecode(widget.draft['order'] ?? 'null') as List)
              .cast<String>();
          if (order.length == elements.length &&
              order.toSet().containsAll(elements.map((e) => e.id))) {
            elements = order
                .map((id) => p.elements.firstWhere((e) => e.id == id))
                .toList();
          }
        } catch (_) {
          /* No saved order yet. */
        }
      }
      final columns = p.type == QuestionPresentationType.symbols
          ? 3
          : box.maxHeight / (elements.length / 2).ceil() < 65
          ? 4
          : 2;
      final rows = (elements.length / columns).ceil();
      void move(int index, int offset) {
        final order = elements.map((e) => e.id).toList();
        final id = order.removeAt(index);
        order.insert(index + offset, id);
        _change('order', jsonEncode(order));
      }

      Widget smallAction(String label, VoidCallback? callback, bool active) =>
          Expanded(
            child: PlayButton(
              label: label,
              secondary: !active,
              onPressed: widget.enabled ? callback : null,
            ),
          );
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
                      child: Builder(
                        builder: (context) {
                          final index = row * columns + col;
                          if (index >= elements.length) {
                            return const SizedBox.shrink();
                          }
                          final e = elements[index];
                          final nearest =
                              p.type == QuestionPresentationType.comparison &&
                              widget.comparisonInteraction ==
                                  ComparisonInteraction.nearest;
                          Widget? footer;
                          if (p.type == QuestionPresentationType.grouping) {
                            footer = SizedBox(
                              height: 16,
                              child: FitText(
                                widget.draft['group:${e.id}'] == null
                                    ? 'اضغط لتحديد المجموعة'
                                    : 'مجموعة ${widget.draft['group:${e.id}']} · اضغط للتغيير',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.blue,
                                ),
                              ),
                            );
                          } else if (isOrder) {
                            footer = SizedBox(
                              height: 24,
                              child: Row(
                                children: [
                                  smallAction(
                                    '↑',
                                    index > 0 ? () => move(index, -1) : null,
                                    false,
                                  ),
                                  Expanded(
                                    child: FitText(
                                      '${index + 1}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  smallAction(
                                    '↓',
                                    index < elements.length - 1
                                        ? () => move(index, 1)
                                        : null,
                                    false,
                                  ),
                                ],
                              ),
                            );
                          } else if (p.type ==
                                  QuestionPresentationType.comparison &&
                              widget.comparisonInteraction ==
                                  ComparisonInteraction.endpoints) {
                            footer = SizedBox(
                              height: 24,
                              child: Row(
                                children: [
                                  for (final choice in [
                                    ('first', 'الأول'),
                                    ('last', 'الأخير'),
                                  ])
                                    smallAction(choice.$2, () {
                                      final next = Map<String, String>.from(
                                        widget.draft,
                                      );
                                      if (next[choice.$1] == e.id) {
                                        next.remove(choice.$1);
                                      } else {
                                        next.removeWhere(
                                          (key, value) =>
                                              {'first', 'last'}.contains(key) &&
                                              value == e.id,
                                        );
                                        next[choice.$1] = e.id;
                                      }
                                      widget.onChanged(next);
                                    }, widget.draft[choice.$1] == e.id),
                                ],
                              ),
                            );
                          } else if (p.type ==
                              QuestionPresentationType.sequence) {
                            footer = SizedBox(
                              height: 16,
                              child: FitText(
                                'الموضع ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              ),
                            );
                          }
                          return _compactTile(
                            e,
                            footer: footer,
                            selected:
                                widget.draft['selected'] == e.id ||
                                widget.draft.containsKey('group:${e.id}') ||
                                widget.draft['first'] == e.id ||
                                widget.draft['last'] == e.id,
                            onTap: p.type == QuestionPresentationType.grouping
                                ? () {
                                    final current =
                                        widget.draft['group:${e.id}'];
                                    _change(
                                      'group:${e.id}',
                                      current == null
                                          ? '1'
                                          : current == '1'
                                          ? '2'
                                          : null,
                                    );
                                  }
                                : nearest ||
                                      p.type ==
                                          QuestionPresentationType.statements
                                ? () => _change('selected', e.id)
                                : null,
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
      );
    },
  );
}
