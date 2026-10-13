import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class QuestionPointsBadge extends StatelessWidget {
  const QuestionPointsBadge({
    super.key,
    required this.points,
    this.onLight = false,
  });

  final int points;
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final color = onLight ? AppColors.ink : AppColors.gold;
    return Semantics(
      label: 'قيمة السؤال: $points نقطة',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: .2)),
        ),
        child: Text(
          '$points نقطة',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 16,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
