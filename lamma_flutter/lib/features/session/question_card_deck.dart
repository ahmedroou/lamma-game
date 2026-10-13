import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/app_theme.dart';
import 'question_points_badge.dart';

class QuestionCardDeck extends StatefulWidget {
  const QuestionCardDeck({
    super.key,
    required this.question,
    required this.points,
    required this.revealedCards,
    required this.secondsRemaining,
    required this.onReveal,
    this.surpriseText,
  });

  final String question;
  final int points;
  final String? surpriseText;
  final int revealedCards, secondsRemaining;
  final ValueChanged<int> onReveal;

  @override
  State<QuestionCardDeck> createState() => _QuestionCardDeckState();
}

class _QuestionCardDeckState extends State<QuestionCardDeck>
    with SingleTickerProviderStateMixin {
  late final _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else if (!_entrance.isAnimating && _entrance.value == 0) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context);
      final wide = constraints.maxWidth >= 700 && scale.scale(1) <= 1.3;
      final stacked = constraints.maxWidth < 300 || scale.scale(1) > 1.5;
      final compact = !wide && !stacked;
      final smallWidth = wide
          ? (constraints.maxWidth - 28) / 3
          : compact
          ? (constraints.maxWidth - 14) / 2
          : constraints.maxWidth;
      final questionWidth = wide ? smallWidth : constraints.maxWidth;
      final content = [
        widget.surpriseText ?? 'جاوبوا بدون مساعدة من الجمهور.',
        '${widget.secondsRemaining} ثانية',
        widget.question,
      ];
      final heights = [
        for (var i = 0; i < 3; i++)
          _heightFor(
                context,
                content[i],
                i == 2 ? questionWidth : smallWidth,
                i == 2
                    ? 24
                    : compact
                    ? 16
                    : 20,
                wide
                    ? 320
                    : i == 2
                    ? 248
                    : 226,
              ) +
              (i == 2 ? scale.scale(40) : 0),
      ];
      final smallHeight = math.max(heights[0], heights[1]);
      final wideHeight = heights.reduce(math.max);

      Widget card(int index) => AnimatedBuilder(
        animation: _entrance,
        child: SizedBox(
          key: ValueKey('round-card-$index'),
          height: wide
              ? wideHeight
              : index == 2
              ? heights[2]
              : smallHeight,
          child: _RevealCard(
            index: index,
            points: widget.points,
            content: content[index],
            open: widget.revealedCards > index,
            available: widget.revealedCards == index,
            compact: compact && index != 2,
            secondsRemaining: widget.secondsRemaining,
            timerRunning: widget.revealedCards == 3,
            onTap: () => widget.onReveal(index),
          ),
        ),
        builder: (context, child) {
          final progress = Interval(
            index * .14,
            .72 + index * .14,
            curve: Curves.easeOutCubic,
          ).transform(_entrance.value);
          return Opacity(
            opacity: progress,
            child: Transform.translate(
              offset: Offset(0, 26 * (1 - progress)),
              child: Transform.rotate(
                angle: (index - 1) * .045 * (1 - progress),
                child: child,
              ),
            ),
          );
        },
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.revealedCards == 3
                      ? 'التحدّي بين أيديكم'
                      : 'ثلاث بطاقات… والتحدّي يبدأ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                label: 'تم كشف ${widget.revealedCards} من 3 بطاقات',
                child: ExcludeSemantics(
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Container(
                          width: 16,
                          height: 4,
                          margin: const EdgeInsetsDirectional.only(start: 4),
                          decoration: BoxDecoration(
                            color: widget.revealedCards > i
                                ? _RevealCard.colors[i]
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  Expanded(child: card(i)),
                  if (i < 2) const SizedBox(width: 14),
                ],
              ],
            )
          else ...[
            if (compact)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: card(0)),
                  const SizedBox(width: 14),
                  Expanded(child: card(1)),
                ],
              )
            else ...[
              card(0),
              const SizedBox(height: 14),
              card(1),
            ],
            const SizedBox(height: 14),
            card(2),
          ],
        ],
      );
    },
  );

  // Reserve the revealed content's space before flipping, including large text.
  double _heightFor(
    BuildContext context,
    String text,
    double width,
    double fontSize,
    double minimum,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: fontSize,
          height: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: math.max(1, width - 36));
    final height = math.max(
      minimum,
      // Allow for card chrome and font ascent/descent when surprise text wraps.
      painter.height + 200 * MediaQuery.textScalerOf(context).scale(1),
    );
    painter.dispose();
    return height;
  }
}

class _RevealCard extends StatefulWidget {
  const _RevealCard({
    required this.index,
    required this.points,
    required this.content,
    required this.open,
    required this.available,
    required this.compact,
    required this.secondsRemaining,
    required this.timerRunning,
    required this.onTap,
  });

  static const colors = [AppColors.lime, AppColors.purple, AppColors.blue];
  static const titles = ['المفاجأة', 'الوقت', 'السؤال'];
  static const icons = [
    Icons.bolt_rounded,
    Icons.timer_outlined,
    Icons.psychology_alt_outlined,
  ];
  final int index, secondsRemaining, points;
  final String content;
  final bool open, available, compact, timerRunning;
  final VoidCallback onTap;

  @override
  State<_RevealCard> createState() => _RevealCardState();
}

class _RevealCardState extends State<_RevealCard>
    with SingleTickerProviderStateMixin {
  late final _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: widget.open ? 1 : 0,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _flip.value = widget.open ? 1 : 0;
    }
  }

  @override
  void didUpdateWidget(_RevealCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != oldWidget.open) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _flip.value = widget.open ? 1 : 0;
      } else {
        _flip.animateTo(widget.open ? 1 : 0);
      }
    }
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _RevealCard.colors[widget.index];
    final title = _RevealCard.titles[widget.index];
    return Semantics(
      button: !widget.open,
      enabled: widget.open || widget.available,
      label: widget.open
          ? '$title: ${widget.content}${widget.index == 2 ? '، قيمة السؤال: ${widget.points} نقطة' : ''}'
          : 'كشف كرت $title',
      hint: !widget.open && !widget.available
          ? 'اكشف الكرت السابق أولاً'
          : null,
      onTap: widget.available ? widget.onTap : null,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _flip,
        builder: (context, _) {
          final progress = Curves.easeInOutCubic.transform(_flip.value);
          final front = progress >= .5;
          final angle = (front ? progress - 1 : progress) * math.pi;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, .0012)
              ..rotateY(angle),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (front || widget.available ? color : Colors.black)
                        .withValues(
                          alpha: front || widget.available ? .1 : .16,
                        ),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: front
                          ? [color, Color.lerp(color, Colors.white, .2)!]
                          : [
                              Color.lerp(
                                AppColors.surface,
                                color,
                                widget.available ? .12 : .035,
                              )!,
                              AppColors.surface,
                            ],
                    ),
                    border: Border.all(
                      color: front
                          ? color
                          : widget.available
                          ? color.withValues(alpha: .65)
                          : AppColors.border,
                    ),
                  ),
                  child: InkWell(
                    onTap: widget.available ? widget.onTap : null,
                    child: Stack(
                      children: [
                        PositionedDirectional(
                          end: -24,
                          top: -24,
                          child: IgnorePointer(
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: (front ? AppColors.ink : color)
                                      .withValues(alpha: .07),
                                  width: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: front ? AppColors.ink : color,
                                    ),
                                  ),
                                  if (widget.index == 2)
                                    QuestionPointsBadge(
                                      key: const ValueKey('question-points'),
                                      points: widget.points,
                                      onLight: front,
                                    )
                                  else
                                    Text(
                                      '0${widget.index + 1}',
                                      style: TextStyle(
                                        color: (front ? AppColors.ink : color)
                                            .withValues(alpha: .55),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!(front && widget.index == 1)) ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (front ? AppColors.ink : color)
                                              .withValues(alpha: .08),
                                        ),
                                        child: Icon(
                                          _RevealCard.icons[widget.index],
                                          size: widget.compact ? 28 : 36,
                                          color: front ? AppColors.ink : color,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    if (front && widget.index == 1)
                                      Text(
                                        '${widget.secondsRemaining}',
                                        style: const TextStyle(
                                          fontSize: 52,
                                          height: 1.1,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                          fontFeatures: [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    Text(
                                      front
                                          ? widget.index == 1
                                                ? 'ثانية'
                                                : widget.content
                                          : widget.available
                                          ? 'اضغط للكشف'
                                          : 'بانتظار الكشف',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: front
                                            ? AppColors.ink
                                            : widget.available
                                            ? AppColors.white
                                            : AppColors.muted,
                                        fontSize: front
                                            ? widget.index == 2
                                                  ? 24
                                                  : widget.compact
                                                  ? 16
                                                  : 20
                                            : 14,
                                        height: 1.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (front && widget.index == 1)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: (widget.secondsRemaining / 30).clamp(
                                      0,
                                      1,
                                    ),
                                    minHeight: 4,
                                    color: AppColors.ink.withValues(alpha: .7),
                                    backgroundColor: AppColors.ink.withValues(
                                      alpha: .12,
                                    ),
                                  ),
                                )
                              else
                                Divider(
                                  height: 4,
                                  color: (front ? AppColors.ink : color)
                                      .withValues(alpha: .18),
                                ),
                              const SizedBox(height: 10),
                              Text(
                                front
                                    ? [
                                        'شرط التحدّي',
                                        widget.secondsRemaining == 0
                                            ? 'انتهى الوقت'
                                            : widget.timerRunning
                                            ? 'العدّ التنازلي'
                                            : 'يبدأ مع السؤال',
                                        'فكّروا… الجواب عندكم',
                                      ][widget.index]
                                    : widget.available
                                    ? 'جاهزة للكشف'
                                    : 'اكشف الكرت السابق أولاً',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      (front ? AppColors.ink : AppColors.muted)
                                          .withValues(alpha: .8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

@Preview(name: 'بطاقات السؤال · جوال', group: 'الجولة', size: Size(390, 700))
@Preview(
  name: 'بطاقات السؤال · شاشة واسعة',
  group: 'الجولة',
  size: Size(1000, 520),
)
Widget questionCardsPreview() => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.dark,
  home: Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: _DeckPreview(),
      ),
    ),
  ),
);

class _DeckPreview extends StatefulWidget {
  @override
  State<_DeckPreview> createState() => _DeckPreviewState();
}

class _DeckPreviewState extends State<_DeckPreview> {
  int revealed = 0;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      QuestionCardDeck(
        question: 'ما هو أكبر محيط في العالم؟',
        points: 200,
        revealedCards: revealed,
        secondsRemaining: 30,
        onReveal: (index) => setState(() => revealed = index + 1),
      ),
      TextButton(
        onPressed: () => setState(() => revealed = 0),
        child: const Text('إعادة الكشف'),
      ),
    ],
  );
}
