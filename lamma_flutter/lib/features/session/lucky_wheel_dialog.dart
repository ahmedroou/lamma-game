import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import '../../shared/components.dart';
import 'session_view_model.dart';

/// Interactive animated Wheel of Fortune (عجلة الحظ) dialog.
class LuckyWheelDialog extends StatefulWidget {
  const LuckyWheelDialog({
    super.key,
    required this.model,
    this.initialOutcome,
  });

  final SessionViewModel model;
  final WheelOutcome? initialOutcome;

  static Future<WheelOutcome?> show(
    BuildContext context, {
    required SessionViewModel model,
  }) {
    return showDialog<WheelOutcome>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LuckyWheelDialog(model: model),
    );
  }

  @override
  State<LuckyWheelDialog> createState() => _LuckyWheelDialogState();
}

class _LuckyWheelDialogState extends State<LuckyWheelDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _spinAnimation;

  double _currentAngle = 0.0;
  double _targetAngle = 0.0;
  bool _isSpinning = false;
  WheelOutcome? _selectedOutcome;
  bool _applied = false;

  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    );

    _controller.addListener(() {
      setState(() {
        _currentAngle = _spinAnimation.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isSpinning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning || _selectedOutcome != null) return;

    HapticFeedback.mediumImpact();

    // Pick a random outcome or use the predetermined one
    final outcome = widget.initialOutcome ??
        WheelOutcome.values[_random.nextInt(WheelOutcome.values.length)];

    final segments = WheelOutcome.segmentOrder;
    final targetIndex = segments.indexOf(outcome);
    final segmentAngle = (2 * math.pi) / segments.length;

    // Center of the target segment
    final segmentCenterAngle = (targetIndex + 0.5) * segmentAngle;

    // Slight natural jitter within the slice (±25% of slice width)
    final jitter = (_random.nextDouble() - 0.5) * 0.5 * segmentAngle;

    // Pointer is at 12 o'clock (-pi/2)
    // We want: (segmentCenterAngle + jitter + targetAngle) % 2pi == -pi/2 % 2pi
    // => targetAngle = -pi/2 - segmentCenterAngle - jitter
    final desiredFinalMod =
        (-math.pi / 2 - segmentCenterAngle - jitter) % (2 * math.pi);
    final normalizedFinal = (desiredFinalMod + 2 * math.pi) % (2 * math.pi);

    // Number of full revolutions (6 to 8 full spins)
    final fullSpins = 6 + _random.nextInt(3);
    final currentMod = _currentAngle % (2 * math.pi);
    var delta = normalizedFinal - currentMod;
    if (delta <= 0) delta += 2 * math.pi;

    _targetAngle = _currentAngle + (fullSpins * 2 * math.pi) + delta;

    setState(() {
      _isSpinning = true;
      _selectedOutcome = outcome;
    });

    _spinAnimation = Tween<double>(
      begin: _currentAngle,
      end: _targetAngle,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward(from: 0.0);
  }

  void _applyAndClose() {
    if (_applied || _selectedOutcome == null) return;
    _applied = true;
    widget.model.applyWheelOutcome(_selectedOutcome!);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(_selectedOutcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTeam = widget.model.state.activeTeam;
    final outcome = _selectedOutcome;
    final isDone = !_isSpinning && outcome != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: const Color(0xFF16141D),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDone ? outcome.color : AppColors.gold.withValues(alpha: 0.45),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDone ? outcome.color : AppColors.gold).withValues(alpha: 0.22),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.casino_rounded,
                        color: AppColors.gold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'عجلة الحظ',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'دور: ${activeTeam.name}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Wheel Widget
                SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Spinning Wheel Canvas
                      CustomPaint(
                        size: const Size(270, 270),
                        painter: LuckyWheelPainter(
                          angle: _currentAngle,
                          isSpinning: _isSpinning,
                        ),
                      ),

                      // Center SPIN button / Hub
                      GestureDetector(
                        onTap: _isSpinning || isDone ? null : _spin,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: _isSpinning
                                  ? [const Color(0xFF4A4458), const Color(0xFF1E1B24)]
                                  : isDone
                                  ? [outcome.color, outcome.color.withValues(alpha: 0.7)]
                                  : [AppColors.gold, const Color(0xFFB8860B)],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isSpinning
                                        ? Colors.black54
                                        : isDone
                                        ? outcome.color
                                        : AppColors.gold)
                                    .withValues(alpha: 0.45),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isSpinning
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : isDone
                                ? Icon(
                                    outcome.icon,
                                    color: outcome.textColor,
                                    size: 28,
                                  )
                                : const Text(
                                    'لف!',
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: AppColors.ink,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // Top Ticker / Pointer
                      Positioned(
                        top: 0,
                        child: CustomPaint(
                          size: const Size(26, 32),
                          painter: _WheelPointerPainter(
                            wobble: _isSpinning
                                ? math.sin(_currentAngle * 7) * 0.22
                                : 0.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Outcome Banner or Prompt
                if (isDone) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: outcome.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: outcome.color, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(outcome.icon, color: outcome.color, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              outcome.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: outcome.color,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          outcome.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.white,
                            fontFamily: 'Tajawal',
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  LammaButton(
                    label: 'اعتماد النتيجة ومتابعة التحدي',
                    icon: Icons.check_circle_rounded,
                    onPressed: _applyAndClose,
                  ),
                ] else if (_isSpinning) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'العجلة تدور… ترقبوا النتيجة! ⏳',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'فرصة ذهبية أو مخاطرة كبرى! اضغط للَفّ العجلة أو تخطّها.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                      fontFamily: 'Tajawal',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LammaButton(
                    label: 'لف عجلة الحظ الآن 🎡',
                    icon: Icons.play_arrow_rounded,
                    onPressed: _spin,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'إلغاء والعودة للخيارات',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter that renders the Wheel of Fortune with 7 vibrant segments,
/// gold metallic rim, glowing LED bulbs, and clean typography.
class LuckyWheelPainter extends CustomPainter {
  const LuckyWheelPainter({
    required this.angle,
    required this.isSpinning,
  });

  final double angle;
  final bool isSpinning;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segments = WheelOutcome.segmentOrder;
    final segmentCount = segments.length;
    final sweepAngle = (2 * math.pi) / segmentCount;

    // Draw outer golden metallic rim
    final rimPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0xFFB8860B),
          Color(0xFFFFD700),
          Color(0xFFB8860B),
          Color(0xFF5A4500),
        ],
        stops: const [0.88, 0.93, 0.97, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, rimPaint);

    // Save before rotating the wheel
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final innerRadius = radius * 0.91;

    // Draw each slice
    for (var i = 0; i < segmentCount; i++) {
      final outcome = segments[i];
      final startAngle = i * sweepAngle;

      final slicePath = Path()
        ..moveTo(0, 0)
        ..arcTo(
          Rect.fromCircle(center: Offset.zero, radius: innerRadius),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();

      // Slice background paint with radial depth
      final slicePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            outcome.color.withValues(alpha: 0.88),
            outcome.color,
          ],
          stops: const [0.2, 1.0],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: innerRadius));

      canvas.drawPath(slicePath, slicePaint);

      // Slice divider line
      final dividerPaint = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: 0.6)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset.zero,
        Offset(
          innerRadius * math.cos(startAngle),
          innerRadius * math.sin(startAngle),
        ),
        dividerPaint,
      );

      // Draw label and icon inside slice
      _drawSliceLabel(
        canvas: canvas,
        outcome: outcome,
        angle: startAngle + sweepAngle / 2,
        radius: innerRadius,
      );
    }

    // Outer peg / stud dots on the rim
    final pegPaint = Paint()..color = const Color(0xFFFFF8E1);
    final pegShadow = Paint()..color = Colors.black45;
    for (var i = 0; i < segmentCount * 2; i++) {
      final pegAngle = i * (math.pi / segmentCount);
      final pegDist = radius * 0.955;
      final pegCenter = Offset(
        pegDist * math.cos(pegAngle),
        pegDist * math.sin(pegAngle),
      );
      canvas.drawCircle(pegCenter + const Offset(0, 1), 2.5, pegShadow);
      canvas.drawCircle(pegCenter, 2.5, pegPaint);
    }

    canvas.restore();
  }

  void _drawSliceLabel({
    required Canvas canvas,
    required WheelOutcome outcome,
    required double angle,
    required double radius,
  }) {
    canvas.save();
    canvas.rotate(angle);

    // Distance from center for label
    final labelDist = radius * 0.66;
    canvas.translate(labelDist, 0);
    canvas.rotate(math.pi / 2); // Rotate text to read across wedge

    // Text label
    final textPainter = TextPainter(
      text: TextSpan(
        text: outcome.label,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.w900,
          fontSize: outcome.label.length > 5 ? 12 : 15,
          color: outcome.textColor,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LuckyWheelPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.isSpinning != isSpinning;
  }
}

/// Dynamic ticker pointer at the top of the wheel with subtle bounce physics.
class _WheelPointerPainter extends CustomPainter {
  const _WheelPointerPainter({required this.wobble});

  final double wobble;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    canvas.save();
    canvas.translate(cx, 4);
    canvas.rotate(wobble);

    // Drop shadow
    final shadowPath = Path()
      ..moveTo(-10, 0)
      ..lineTo(10, 0)
      ..lineTo(0, 22)
      ..close();
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Gold pointer body
    final path = Path()
      ..moveTo(-9, 0)
      ..lineTo(9, 0)
      ..lineTo(0, 20)
      ..close();

    final pointerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFE65100)],
      ).createShader(Rect.fromLTWH(-9, 0, 18, 20));

    canvas.drawPath(path, pointerPaint);

    // Shiny border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);

    // Pin mount circle
    canvas.drawCircle(
      Offset.zero,
      5,
      Paint()..color = const Color(0xFFD4AF37),
    );
    canvas.drawCircle(
      Offset.zero,
      3,
      Paint()..color = Colors.white,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WheelPointerPainter oldDelegate) {
    return oldDelegate.wobble != wobble;
  }
}
