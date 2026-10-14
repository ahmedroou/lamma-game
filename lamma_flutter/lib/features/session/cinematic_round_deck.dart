import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../shared/fit_text.dart';

/// The three persistent cards on the table, revealed in the authored order.
class CinematicRoundDeck extends StatefulWidget {
  const CinematicRoundDeck({
    super.key,
    required this.revealedCards,
    required this.sideBySide,
    required this.faces,
    required this.onReveal,
    required this.canReveal,
    this.questionTitle = 'السؤال',
    this.revealLabels,
    this.animate = true,
  });
  final int revealedCards;
  final bool sideBySide, animate;
  final List<Widget> faces;
  final List<bool> canReveal;
  final List<String>? revealLabels;
  final ValueChanged<int> onReveal;
  final String questionTitle;
  @override
  State<CinematicRoundDeck> createState() => _CinematicRoundDeckState();
}

class _CinematicRoundDeckState extends State<CinematicRoundDeck>
    with SingleTickerProviderStateMixin {
  late final _deal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 780),
  );
  bool get _motion =>
      widget.animate && !MediaQuery.disableAnimationsOf(context);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_motion || widget.revealedCards > 0) {
      _deal.value = 1;
    } else if (_deal.value == 0 && !_deal.isAnimating) {
      _deal.forward();
    }
  }

  @override
  void didUpdateWidget(CinematicRoundDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_motion) _deal.value = 1;
  }

  @override
  void dispose() {
    _deal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card(int index) => AnimatedBuilder(
      animation: _deal,
      child: _CinematicCard(
        key: ValueKey('round-card-$index'),
        index: index,
        title: ['المفاجأة', 'الوقت', widget.questionTitle][index],
        open: widget.revealedCards > index,
        available: widget.canReveal[index],
        revealLabel: widget.revealLabels?[index] ?? 'اضغط للكشف',
        animate: _motion,
        onReveal: () => widget.onReveal(index),
        face: widget.faces[index],
      ),
      builder: (context, child) {
        final t = Interval(
          index * .12,
          .7 + index * .12,
          curve: Curves.easeOutCubic,
        ).transform(_deal.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - t)),
            child: Transform.rotate(
              angle: (index - 1) * .035 * (1 - t),
              child: child,
            ),
          ),
        );
      },
    );
    if (widget.sideBySide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: card(0)),
          const SizedBox(width: 10),
          Expanded(flex: 4, child: card(1)),
          const SizedBox(width: 10),
          Expanded(flex: 11, child: card(2)),
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: card(0)),
              const SizedBox(width: 10),
              Expanded(child: card(1)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(flex: 7, child: card(2)),
      ],
    );
  }
}

class _CinematicCard extends StatefulWidget {
  const _CinematicCard({
    super.key,
    required this.index,
    required this.title,
    required this.open,
    required this.available,
    required this.revealLabel,
    required this.animate,
    required this.onReveal,
    required this.face,
  });
  final int index;
  final String title, revealLabel;
  final bool open, available, animate;
  final VoidCallback onReveal;
  final Widget face;
  @override
  State<_CinematicCard> createState() => _CinematicCardState();
}

class _CinematicCardState extends State<_CinematicCard>
    with SingleTickerProviderStateMixin {
  late final _flip = AnimationController(
    vsync: this,
    value: widget.open ? 1 : 0,
    duration: const Duration(milliseconds: 760),
  );
  static const _colors = [AppColors.lime, AppColors.purple, AppColors.blue];
  static const _icons = [
    Icons.auto_awesome_rounded,
    Icons.hourglass_bottom_rounded,
    Icons.help_outline_rounded,
  ];
  @override
  void didUpdateWidget(_CinematicCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.animate) {
      _flip.value = widget.open ? 1 : 0;
    } else if (oldWidget.open != widget.open) {
      widget.open ? _flip.forward() : _flip.reverse();
    }
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _flip,
    builder: (context, _) {
      final t = Curves.easeInOutCubic.transform(_flip.value);
      final front = widget.open && t >= .5;
      final color = _colors[widget.index];
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, .0014)
        ..rotateY(math.pi * t);
      Widget shell(Widget child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              color.withValues(alpha: front ? .19 : .11),
              const Color(0xff181c26),
              const Color(0xff12161e),
            ],
          ),
          border: Border.all(
            color: color.withValues(
              alpha: widget.available || front ? .65 : .22,
            ),
            width: widget.available ? 1.6 : 1,
          ),
          boxShadow: [
            if (widget.available || _flip.isAnimating)
              BoxShadow(color: color.withValues(alpha: .14), blurRadius: 18),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: !widget.open && widget.available ? widget.onReveal : null,
            child: Padding(padding: const EdgeInsets.all(8), child: child),
          ),
        ),
      );
      return Semantics(
        button: !widget.open,
        enabled: widget.available || widget.open,
        label: front ? '${widget.title} مكشوفة' : 'كشف كرت ${widget.title}',
        child: Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(front ? math.pi : 0),
            child: shell(
              front
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 22,
                          child: Row(
                            children: [
                              Icon(
                                _icons[widget.index],
                                size: 16,
                                color: color,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: FitText(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ),
                              Text(
                                '0${widget.index + 1}',
                                style: TextStyle(
                                  color: color.withValues(alpha: .7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(child: widget.face),
                      ],
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 20,
                          child: Row(
                            children: [
                              Text(
                                '0${widget.index + 1}',
                                style: TextStyle(color: color, fontSize: 12),
                              ),
                              const Spacer(),
                              Icon(
                                widget.available
                                    ? Icons.touch_app_outlined
                                    : Icons.lock_outline_rounded,
                                size: 16,
                                color: color.withValues(alpha: .7),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color.withValues(alpha: .28),
                                ),
                                gradient: RadialGradient(
                                  colors: [
                                    color.withValues(alpha: .2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Icon(
                                _icons[widget.index],
                                color: color,
                                size: 44,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: FitText(
                            widget.title,
                            style: TextStyle(
                              color: color,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Expanded(
                          child: FitText(
                            widget.available
                                ? widget.revealLabel
                                : 'اكشف البطاقة السابقة أولًا',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.available
                                  ? AppColors.white
                                  : AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    },
  );
}
