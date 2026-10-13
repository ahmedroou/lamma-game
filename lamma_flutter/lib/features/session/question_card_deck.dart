import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.surpriseNote,
    this.totalSeconds = 30,
    this.countUpTimer = false,
  });

  final String question;
  final int points;
  final String? surpriseText;
  final String? surpriseNote;
  final int totalSeconds;
  final bool countUpTimer;
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
      final compact = !wide;
      final smallWidth = wide
          ? (constraints.maxWidth - 28) / 3
          : stacked
          ? constraints.maxWidth
          : (constraints.maxWidth - 14) / 2;
      final questionWidth = wide ? smallWidth : constraints.maxWidth;
      final content = [
        widget.surpriseText ?? 'لا توجد ورقة مفاجأة لهذه الجولة.',
        '${widget.secondsRemaining} ثانية',
        widget.question,
      ];
      final heights = [
        for (var i = 0; i < 3; i++)
          _heightFor(
                context,
                i == 0 && widget.surpriseNote?.isNotEmpty == true
                    ? '${content[i]}\n${widget.surpriseNote}'
                    : content[i],
                i == 2 ? questionWidth : smallWidth,
                i == 2
                    ? (compact ? 20 : 24)
                    : compact
                    ? 15
                    : 20,
                wide
                    ? 320
                    : i == 2
                    ? (compact ? 190 : 248)
                    : (compact ? 172 : 226),
                compact: compact,
                isQuestion: i == 2,
              ) +
              (i == 2 ? scale.scale(compact ? 24 : 40) : 0),
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
            note: index == 0 ? widget.surpriseNote : null,
            totalSeconds: widget.totalSeconds,
            countUpTimer: widget.countUpTimer,
            open: widget.revealedCards > index,
            available: widget.revealedCards == index,
            compact: compact,
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
            if (!stacked)
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
    double minimum, {
    bool compact = false,
    bool isQuestion = false,
  }) {
    final scale = MediaQuery.textScalerOf(context);
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: fontSize,
          height: 1.4,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: Directionality.of(context),
      textScaler: scale,
    )..layout(maxWidth: math.max(1, width - (compact ? 28 : 36)));
    final chrome =
        (compact
            ? (isQuestion ? 144.0 : 130.0)
            : (isQuestion ? 165.0 : 150.0)) *
        scale.scale(1);
    final height = math.max(
      minimum,
      // Allow for card chrome and font ascent/descent when surprise text wraps.
      painter.height + chrome,
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
    this.note,
    this.totalSeconds = 30,
    this.countUpTimer = false,
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
  final String? note;
  final int totalSeconds;
  final bool countUpTimer;
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
                    boxShadow: [
                      if (widget.available)
                        BoxShadow(
                          color: color.withValues(alpha: .18),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: InkWell(
                    onTap: widget.available
                        ? () {
                            HapticFeedback.lightImpact();
                            widget.onTap();
                          }
                        : null,
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
                          padding: EdgeInsets.all(widget.compact ? 12 : 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: widget.compact ? 14 : 17,
                                        fontWeight: FontWeight.w700,
                                        color: front ? AppColors.ink : color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
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
                                        fontSize: widget.compact ? 11 : 12,
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
                                        padding: EdgeInsets.all(
                                          widget.compact ? 8 : 12,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (front ? AppColors.ink : color)
                                              .withValues(alpha: .08),
                                        ),
                                        child: Icon(
                                          _RevealCard.icons[widget.index],
                                          size: widget.compact ? 22 : 36,
                                          color: front ? AppColors.ink : color,
                                        ),
                                      ),
                                      SizedBox(height: widget.compact ? 6 : 12),
                                    ],
                                    if (front && widget.index == 1)
                                      Builder(
                                        builder: (context) {
                                          final isUrgent =
                                              widget.timerRunning &&
                                              !widget.countUpTimer &&
                                              widget.secondsRemaining <= 5 &&
                                              widget.secondsRemaining > 0;
                                          final isFinished =
                                              widget.timerRunning &&
                                              !widget.countUpTimer &&
                                              widget.secondsRemaining == 0;
                                          final timerColor = isUrgent
                                              ? AppColors.peach
                                              : isFinished
                                              ? const Color(0xFFE57373)
                                              : AppColors.ink;
                                          return AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            style: TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: widget.compact
                                                  ? (isUrgent ? 40 : 38)
                                                  : (isUrgent ? 54 : 52),
                                              height: 1.1,
                                              fontWeight: FontWeight.w700,
                                              color: timerColor,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                            child: Text(
                                              '${widget.secondsRemaining}',
                                            ),
                                          );
                                        },
                                      ),
                                    Text(
                                      front
                                          ? widget.index == 1
                                                ? (widget.countUpTimer
                                                      ? 'ثانية بلانك'
                                                      : 'ثانية')
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
                                                  ? (widget.compact ? 20 : 24)
                                                  : widget.compact
                                                  ? 15
                                                  : 20
                                            : (widget.compact ? 13 : 14),
                                        height: 1.4,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: widget.compact ? 6 : 10),
                              if (front &&
                                  widget.index == 1 &&
                                  !widget.countUpTimer)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value:
                                        (widget.secondsRemaining /
                                                math.max(
                                                  1,
                                                  widget.totalSeconds,
                                                ))
                                            .clamp(0, 1),
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
                              SizedBox(height: widget.compact ? 6 : 10),
                              Text(
                                front
                                    ? (widget.note?.isNotEmpty == true
                                          ? widget.note!
                                          : [
                                              'شرط التحدّي',
                                              widget.secondsRemaining == 0
                                                  ? 'انتهى الوقت'
                                                  : widget.timerRunning
                                                  ? (widget.countUpTimer
                                                        ? 'العدّ التصاعدي أثناء البلانك'
                                                        : 'العدّ التنازلي')
                                                  : 'يبدأ مع السؤال',
                                              'فكّروا… الجواب عندكم',
                                            ][widget.index])
                                    : widget.available
                                    ? 'جاهزة للكشف'
                                    : 'اكشف الكرت السابق أولاً',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: widget.compact
                                      ? 10.5
                                      : (widget.note?.isNotEmpty == true
                                            ? 12
                                            : 11),
                                  height: 1.5,
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
