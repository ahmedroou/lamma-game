import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class CardScene extends StatefulWidget {
  const CardScene({super.key, required this.animate});
  final bool animate;
  @override
  State<CardScene> createState() => _CardSceneState();
}

class _CardSceneState extends State<CardScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(CardScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMotion();
  }

  void _syncMotion() {
    if (widget.animate && !MediaQuery.disableAnimationsOf(context)) {
      if (!_float.isAnimating) _float.repeat();
    } else {
      _float.stop();
      _float.value = 0;
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final scale = math.min(
          constraints.maxWidth / 370,
          constraints.maxHeight / 270,
        );
        return Center(
          child: SizedBox(
            width: 370 * scale,
            height: 270 * scale,
            child: FittedBox(
              child: SizedBox(
                width: 370,
                height: 270,
                child: AnimatedBuilder(
                  animation: _float,
                  builder: (context, _) {
                    final phase = _float.value * math.pi * 2;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 25,
                          top: 12,
                          child: Container(
                            width: 325,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.purple.withValues(alpha: .18),
                                  AppColors.purple.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(painter: _OrbitPainter()),
                        ),
                        Positioned(
                          left: 65,
                          top: 35 + math.sin(phase + 1) * 5,
                          child: Transform.rotate(
                            angle: -.24,
                            child: const _GameCard(
                              AppColors.purple,
                              'وقت',
                              '02',
                              Icons.timer_outlined,
                              'ثانية تغيّر كل شيء',
                              '30',
                            ),
                          ),
                        ),
                        Positioned(
                          left: 180,
                          top: 31 + math.sin(phase + 2) * 6,
                          child: Transform.rotate(
                            angle: .23,
                            child: const _GameCard(
                              AppColors.blue,
                              'سؤال',
                              '01',
                              Icons.psychology_alt_outlined,
                              'ورّنا اللي عندك',
                              '؟',
                            ),
                          ),
                        ),
                        Positioned(
                          left: 123,
                          top: 57 + math.sin(phase) * 7,
                          child: Transform.rotate(
                            angle: -.045,
                            child: const _GameCard(
                              AppColors.lime,
                              'مفاجأة',
                              '03',
                              Icons.bolt_rounded,
                              'اقلب موازين اللعبة',
                              null,
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 27,
                          top: 39,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 21,
                            color: AppColors.lime,
                          ),
                        ),
                        const Positioned(
                          right: 20,
                          bottom: 43,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: AppColors.purple,
                          ),
                        ),
                        Positioned(
                          left: 30,
                          bottom: 26,
                          child: Transform.rotate(
                            angle: -.08,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'GAME ON',
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          top: 4 + math.sin(phase + 2) * 4,
                          child: Transform.rotate(
                            angle: .1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF332D23),
                                border: Border.all(
                                  color: AppColors.gold.withValues(alpha: .6),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: .1),
                                    blurRadius: 22,
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.style_outlined,
                                    size: 17,
                                    color: AppColors.gold,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'ABILITY +',
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _GameCard extends StatelessWidget {
  const _GameCard(
    this.color,
    this.label,
    this.number,
    this.icon,
    this.foot,
    this.bigText,
  );
  final Color color;
  final String label, number, foot;
  final IconData icon;
  final String? bigText;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 137,
    height: 187,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.white, .18)!],
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: Colors.white.withValues(alpha: .45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .35),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: MediaQuery.withNoTextScaling(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    number,
                    style: TextStyle(
                      color: AppColors.ink.withValues(alpha: .6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: bigText == null
                      ? Transform.rotate(
                          angle: -.12,
                          child: Icon(icon, color: AppColors.ink, size: 86),
                        )
                      : Text(
                          bigText!,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                ),
              ),
              Divider(color: AppColors.ink.withValues(alpha: .2)),
              Text(
                foot,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: .075)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawOval(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: 355,
        height: 220,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: 305,
        height: 170,
      ),
      paint,
    );
    paint
      ..style = PaintingStyle.fill
      ..color = AppColors.white.withValues(alpha: .09);
    for (double x = 20; x < size.width; x += 18) {
      for (double y = 12; y < size.height; y += 18) {
        canvas.drawCircle(Offset(x, y), .8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) => false;
}
