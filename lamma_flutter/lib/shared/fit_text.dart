import 'package:flutter/material.dart';

/// Keeps the complete text inside a bounded game region, without truncation.
class FitText extends StatelessWidget {
  const FitText(
    this.text, {
    super.key,
    this.style,
    this.align = TextAlign.center,
    this.direction,
  });
  final String text;
  final TextStyle? style;
  final TextAlign align;
  final TextDirection? direction;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final base = DefaultTextStyle.of(context).style.merge(style);
      final direction = this.direction ?? Directionality.of(context);
      final scaler = MediaQuery.textScalerOf(context);
      var low = 1.0;
      var high = base.fontSize ?? 16;
      bool fits(double size) {
        final painter = TextPainter(
          text: TextSpan(
            text: text,
            style: base.copyWith(fontSize: size),
          ),
          textDirection: direction,
          textAlign: align,
          textScaler: scaler,
        )..layout(maxWidth: box.maxWidth);
        final fits =
            painter.height <= box.maxHeight && painter.width <= box.maxWidth;
        painter.dispose();
        return fits;
      }

      if (!fits(high)) {
        for (var i = 0; i < 12; i++) {
          final mid = (low + high) / 2;
          if (fits(mid)) {
            low = mid;
          } else {
            high = mid;
          }
        }
        high = low;
      }
      return Center(
        child: Text(
          text,
          textAlign: align,
          textDirection: direction,
          style: base.copyWith(fontSize: high),
        ),
      );
    },
  );
}

/// A bounded button whose full label remains visible on a compact play screen.
class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      minimumSize: const Size(0, 40),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: secondary ? Theme.of(context).colorScheme.surface : null,
      foregroundColor: secondary
          ? Theme.of(context).colorScheme.onSurface
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: FitText(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
  );
}
