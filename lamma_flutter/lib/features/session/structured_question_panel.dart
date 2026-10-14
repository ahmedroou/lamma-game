import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../core/app_theme.dart';
import '../../domain/models/question_presentation.dart';
import '../../shared/fit_text.dart';
part 'structured_question_compact.dart';

/// The question's visible premises. Hidden answer options are never read here.
enum ComparisonInteraction { order, nearest, endpoints }

class StructuredQuestionPanel extends StatefulWidget {
  const StructuredQuestionPanel({
    super.key,
    required this.presentation,
    required this.draft,
    required this.enabled,
    required this.onChanged,
    this.comparisonInteraction = ComparisonInteraction.order,
    this.compact = false,
  });
  final QuestionPresentation presentation;
  final Map<String, String> draft;
  final bool enabled;
  final ValueChanged<Map<String, String>> onChanged;
  final ComparisonInteraction comparisonInteraction;
  final bool compact;
  @override
  State<StructuredQuestionPanel> createState() =>
      _StructuredQuestionPanelState();
}

class _StructuredQuestionPanelState extends State<StructuredQuestionPanel> {
  String? _left;
  void _selectLeft(String? id) => setState(() => _left = id);
  void _change(String key, String? value) {
    if (!widget.enabled) return;
    final next = Map<String, String>.from(widget.draft);
    if (value == null || value.isEmpty) {
      next.remove(key);
    } else {
      next[key] = value;
    }
    widget.onChanged(next);
  }

  Widget _label(QuestionElement item) => item.missing
      ? _MissingElement(
          key: ValueKey('missing-${item.id}'),
          enabled: widget.enabled,
          value: widget.draft['missing:${item.id}'] ?? '',
          onChanged: (value) => _change('missing:${item.id}', value),
        )
      : Text(
          item.text,
          textAlign: TextAlign.center,
          textDirection: RegExp('[ء-ي]').hasMatch(item.text)
              ? TextDirection.rtl
              : TextDirection.ltr,
          style: TextStyle(
            fontSize:
                widget.presentation.type == QuestionPresentationType.symbols
                ? 34
                : 17,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        );
  Widget _tile(
    QuestionElement item, {
    bool selected = false,
    VoidCallback? onTap,
    Widget? footer,
  }) => Semantics(
    selected: selected,
    child: AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 160),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.blue.withValues(alpha: .17)
            : AppColors.surface,
        border: Border.all(color: selected ? AppColors.blue : AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('element-${item.id}'),
          borderRadius: BorderRadius.circular(18),
          onTap: widget.enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _label(item),
                if (footer != null) ...[const SizedBox(height: 8), footer],
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _matching() {
    final left = widget.presentation.sections.first,
        right = widget.presentation.sections.last;
    void select(QuestionElement item, bool isLeft) {
      if (!widget.enabled) return;
      if (isLeft) {
        setState(() => _left = item.id);
        return;
      }
      final selectedLeft = _left;
      if (selectedLeft == null) return;
      final next = Map<String, String>.from(widget.draft)
        ..removeWhere(
          (key, value) => key.startsWith('pair:') && value == item.id,
        );
      next['pair:$selectedLeft'] = item.id;
      widget.onChanged(next);
      setState(() => _left = null);
    }

    Widget side(QuestionSection section, bool isLeft) => Column(
      children: [
        if (section.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              section.title,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        for (final item in section.items)
          _tile(
            item,
            selected: isLeft
                ? _left == item.id
                : widget.draft.entries.any(
                    (e) => e.key.startsWith('pair:') && e.value == item.id,
                  ),
            onTap: () => select(item, isLeft),
            footer: Column(
              children: [
                if (isLeft && widget.draft.containsKey('pair:${item.id}'))
                  Text(
                    'متصل بالطرف ${right.items.indexWhere((r) => r.id == widget.draft['pair:${item.id}']) + 1}',
                    style: const TextStyle(color: AppColors.blue, fontSize: 13),
                  ),
                if (!isLeft)
                  Text(
                    'الطرف ${right.items.indexOf(item) + 1}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                TextButton.icon(
                  key: ValueKey('link-${item.id}'),
                  onPressed: widget.enabled && (isLeft || _left != null)
                      ? () => select(item, isLeft)
                      : null,
                  icon: Icon(
                    isLeft ? Icons.touch_app_outlined : Icons.link_rounded,
                    size: 18,
                  ),
                  label: Text(isLeft ? 'اختر هذا الطرف' : 'صِل بالمحدد'),
                ),
              ],
            ),
          ),
      ],
    );
    return Column(
      children: [
        const Text(
          'اختر عنصرًا من الطرف الأول، ثم العنصر الذي تربطه به. استنتج الخانات الناقصة.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, height: 1.6),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, box) {
            if (box.maxWidth < 330 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.5) {
              return Column(
                children: [
                  side(left, true),
                  const SizedBox(height: 12),
                  side(right, false),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: side(left, true)),
                const SizedBox(width: 14),
                Expanded(child: side(right, false)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _grouping() => Column(
    children: [
      const Text(
        'وزّع العناصر بين المجموعتين واكتشف الرابط لكل مجموعة.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.muted),
      ),
      const SizedBox(height: 14),
      LayoutBuilder(
        builder: (context, box) {
          final columns = box.maxWidth >= 580
              ? 3
              : box.maxWidth >= 340 &&
                    MediaQuery.textScalerOf(context).scale(1) <= 1.5
              ? 2
              : 1;
          return Wrap(
            spacing: 10,
            children: [
              for (final item in widget.presentation.elements)
                SizedBox(
                  width: (box.maxWidth - (columns - 1) * 10) / columns,
                  child: _tile(
                    item,
                    selected: widget.draft.containsKey('group:${item.id}'),
                    footer: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      children: [
                        for (final group in ['1', '2'])
                          ChoiceChip(
                            label: Text('مجموعة $group'),
                            selected: widget.draft['group:${item.id}'] == group,
                            onSelected: widget.enabled
                                ? (selected) => _change(
                                    'group:${item.id}',
                                    selected ? group : null,
                                  )
                                : null,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      Text(
        'المجموعة 1: ${widget.draft.entries.where((e) => e.key.startsWith('group:') && e.value == '1').length}  ·  '
        'المجموعة 2: ${widget.draft.entries.where((e) => e.key.startsWith('group:') && e.value == '2').length}',
        style: const TextStyle(color: AppColors.muted),
      ),
    ],
  );

  Widget _comparison() {
    final original = widget.presentation.elements;
    if (widget.comparisonInteraction != ComparisonInteraction.order) {
      return Column(
        children: [
          Text(
            widget.comparisonInteraction == ComparisonInteraction.nearest
                ? 'اختر أقرب قيمة إلى المطلوب.'
                : 'حدد العنصر الأول والعنصر الأخير وفق قاعدة السؤال.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          for (final item in original)
            _tile(
              item,
              selected:
                  widget.draft['selected'] == item.id ||
                  widget.draft['first'] == item.id ||
                  widget.draft['last'] == item.id,
              onTap:
                  widget.comparisonInteraction == ComparisonInteraction.nearest
                  ? () => _change('selected', item.id)
                  : null,
              footer:
                  widget.comparisonInteraction ==
                      ComparisonInteraction.endpoints
                  ? Wrap(
                      spacing: 8,
                      children: [
                        for (final choice in [
                          ('first', 'الأول'),
                          ('last', 'الأخير'),
                        ])
                          ChoiceChip(
                            label: Text(choice.$2),
                            selected: widget.draft[choice.$1] == item.id,
                            onSelected: !widget.enabled
                                ? null
                                : (selected) {
                                    final next = Map<String, String>.from(
                                      widget.draft,
                                    );
                                    if (!selected) {
                                      next.remove(choice.$1);
                                    } else {
                                      next.removeWhere(
                                        (key, value) =>
                                            {'first', 'last'}.contains(key) &&
                                            value == item.id,
                                      );
                                      next[choice.$1] = item.id;
                                    }
                                    widget.onChanged(next);
                                  },
                          ),
                      ],
                    )
                  : null,
            ),
        ],
      );
    }
    var order = original.map((item) => item.id).toList();
    try {
      final saved = (jsonDecode(widget.draft['order'] ?? 'null') as List)
          .cast<String>();
      if (saved.length == order.length && saved.toSet().containsAll(order)) {
        order = saved;
      }
    } catch (_) {
      /* An absent draft uses the authored display order. */
    }
    void move(int index, int offset) {
      final next = [...order];
      final item = next.removeAt(index);
      next.insert(index + offset, item);
      _change('order', jsonEncode(next));
    }

    return Column(
      children: [
        const Text(
          'رتّب العناصر بحسب المطلوب في السؤال.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < order.length; i++)
          _tile(
            original.firstWhere((item) => item.id == order[i]),
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'إلى الأعلى',
                  onPressed: widget.enabled && i > 0 ? () => move(i, -1) : null,
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
                Text('${i + 1}'),
                IconButton(
                  tooltip: 'إلى الأسفل',
                  onPressed: widget.enabled && i < order.length - 1
                      ? () => move(i, 1)
                      : null,
                  icon: const Icon(Icons.arrow_downward_rounded),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => widget.compact
      ? _compactPanel()
      : Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              switch (widget.presentation.type) {
                QuestionPresentationType.matching => _matching(),
                QuestionPresentationType.grouping => _grouping(),
                QuestionPresentationType.comparison => _comparison(),
                _ => Column(
                  children: [
                    for (final section in widget.presentation.sections) ...[
                      if (section.title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(section.title),
                        ),
                      for (var i = 0; i < section.items.length; i++)
                        _tile(
                          section.items[i],
                          selected:
                              widget.draft['selected'] == section.items[i].id,
                          onTap:
                              widget.presentation.type ==
                                  QuestionPresentationType.statements
                              ? () => _change('selected', section.items[i].id)
                              : null,
                          footer:
                              widget.presentation.type ==
                                  QuestionPresentationType.sequence
                              ? Text(
                                  'الموضع ${i + 1}',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                  ),
                                )
                              : null,
                        ),
                    ],
                  ],
                ),
              },
              if (widget.enabled && widget.draft.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() => _left = null);
                    widget.onChanged(const {});
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('مسح ترتيبك'),
                ),
            ],
          ),
        );
}

class _MissingElement extends StatefulWidget {
  const _MissingElement({
    super.key,
    required this.enabled,
    required this.value,
    required this.onChanged,
  });
  final bool enabled;
  final String value;
  final ValueChanged<String> onChanged;
  @override
  State<_MissingElement> createState() => _MissingElementState();
}

@Preview(
  name: 'توصيل الأطراف · جوال',
  group: 'السؤال متعدد العناصر',
  size: Size(390, 800),
)
@Preview(
  name: 'توصيل الأطراف · واسع',
  group: 'السؤال متعدد العناصر',
  size: Size(800, 700),
)
Widget matchingQuestionPreview() {
  var draft = <String, String>{};
  final presentation = QuestionPresentation.fromJson({
    'type': 'matching',
    'sections': [
      {
        'id': 'left',
        'title': 'الأطراف الأولى',
        'items': [
          {'id': 'l1', 'text': 'عنصر أول'},
          {'id': 'l2', 'text': 'عنصر ثانٍ'},
        ],
      },
      {
        'id': 'right',
        'title': 'الأطراف المقابلة',
        'items': [
          {'id': 'r1', 'text': 'طرف معروض'},
          {'id': 'r2', 'text': '؟', 'missing': true},
        ],
      },
    ],
  });
  return MaterialApp(
    theme: AppTheme.dark,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setState) => StructuredQuestionPanel(
              presentation: presentation,
              draft: draft,
              enabled: true,
              onChanged: (value) => setState(() => draft = value),
            ),
          ),
        ),
      ),
    ),
  );
}

class _MissingElementState extends State<_MissingElement> {
  late final _controller = TextEditingController(text: widget.value);
  @override
  void didUpdateWidget(covariant _MissingElement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    enabled: widget.enabled,
    textAlign: TextAlign.center,
    maxLength: 80,
    decoration: const InputDecoration(
      labelText: 'الطرف الناقص',
      hintText: '؟',
      counterText: '',
    ),
    onChanged: widget.onChanged,
  );
}
