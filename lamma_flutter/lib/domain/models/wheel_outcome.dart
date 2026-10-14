import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

/// Outcomes available on the Wheel of Fortune (عجلة الحظ).
enum WheelOutcome {
  plus100,
  plus200,
  plus400,
  plus600,
  minus500,
  passTurn,
  bankruptcy;

  String get label => switch (this) {
    WheelOutcome.plus100 => '+100',
    WheelOutcome.plus200 => '+200',
    WheelOutcome.plus400 => '+400',
    WheelOutcome.plus600 => '+600',
    WheelOutcome.minus500 => '-500',
    WheelOutcome.passTurn => 'تحويل\nالدور',
    WheelOutcome.bankruptcy => 'إفلاس',
  };

  String get title => switch (this) {
    WheelOutcome.plus100 => '+100 نقطة',
    WheelOutcome.plus200 => '+200 نقطة',
    WheelOutcome.plus400 => '+400 نقطة',
    WheelOutcome.plus600 => 'الجائزة الكبرى: +600 نقطة!',
    WheelOutcome.minus500 => 'خصم 500 نقطة!',
    WheelOutcome.passTurn => 'ما يحق لك تجاوب هذا الدور!',
    WheelOutcome.bankruptcy => 'إفلاس! خسارة كل النقاط',
  };

  String get description => switch (this) {
    WheelOutcome.plus100 => 'تُضاف 100 نقطة مباشرة إلى رصيد فريقك.',
    WheelOutcome.plus200 => 'تُضاف 200 نقطة مباشرة إلى رصيد فريقك.',
    WheelOutcome.plus400 => 'تُضاف 400 نقطة مباشرة إلى رصيد فريقك.',
    WheelOutcome.plus600 => 'مبروك! تُضاف 600 نقطة مباشرة إلى رصيد فريقك.',
    WheelOutcome.minus500 => 'تُخصم 500 نقطة مباشرة من رصيد فريقك.',
    WheelOutcome.passTurn =>
      'فقدت حق الإجابة لهذا الدور! يتحول الدور للفريق المنافس.',
    WheelOutcome.bankruptcy => 'خسرت كل نقاطك وأصبح رصيد فريقك 0.',
  };

  IconData get icon => switch (this) {
    WheelOutcome.plus100 => Icons.add_circle_outline_rounded,
    WheelOutcome.plus200 => Icons.add_circle_outline_rounded,
    WheelOutcome.plus400 => Icons.stars_rounded,
    WheelOutcome.plus600 => Icons.military_tech_rounded,
    WheelOutcome.minus500 => Icons.remove_circle_outline_rounded,
    WheelOutcome.passTurn => Icons.sync_problem_rounded,
    WheelOutcome.bankruptcy => Icons.dangerous_rounded,
  };

  Color get color => switch (this) {
    WheelOutcome.plus100 => AppColors.lime,
    WheelOutcome.plus200 => AppColors.blue,
    WheelOutcome.plus400 => AppColors.purple,
    WheelOutcome.plus600 => AppColors.gold,
    WheelOutcome.minus500 => const Color(0xFFFF6B4A),
    WheelOutcome.passTurn => const Color(0xFF6C5CE7),
    WheelOutcome.bankruptcy => const Color(0xFFFF2A55),
  };

  Color get textColor => switch (this) {
    WheelOutcome.plus100 => AppColors.ink,
    WheelOutcome.plus600 => AppColors.ink,
    _ => Colors.white,
  };

  int get pointsDelta => switch (this) {
    WheelOutcome.plus100 => 100,
    WheelOutcome.plus200 => 200,
    WheelOutcome.plus400 => 400,
    WheelOutcome.plus600 => 600,
    WheelOutcome.minus500 => -500,
    WheelOutcome.passTurn => 0,
    WheelOutcome.bankruptcy => 0,
  };

  /// Segment order on the wheel designed for maximum suspense and visual balance.
  static const List<WheelOutcome> segmentOrder = [
    WheelOutcome.plus600,
    WheelOutcome.bankruptcy,
    WheelOutcome.plus200,
    WheelOutcome.minus500,
    WheelOutcome.plus400,
    WheelOutcome.passTurn,
    WheelOutcome.plus100,
  ];
}
