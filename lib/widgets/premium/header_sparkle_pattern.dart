import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/el_emegi_colors.dart';

/// Rozet etrafında premium aura — dönen metalik yansıma + yumuşak mikro parıltılar.
class HeaderSparklePattern extends StatefulWidget {
  const HeaderSparklePattern({
    super.key,
    this.ringSize = 56,
  });

  final double ringSize;

  @override
  State<HeaderSparklePattern> createState() => _HeaderSparklePatternState();
}

class _HeaderSparklePatternState extends State<HeaderSparklePattern>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7200),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _spin,
        builder: (context, _) {
          return CustomPaint(
            size: Size.square(widget.ringSize),
            painter: _BadgeAuraPainter(
              progress: _spin.value,
              ringSize: widget.ringSize,
            ),
          );
        },
      ),
    );
  }
}

class _BadgeAuraPainter extends CustomPainter {
  _BadgeAuraPainter({
    required this.progress,
    required this.ringSize,
  });

  final double progress;
  final double ringSize;

  static const _glints = <({double speed, double phase, double orbit, double size})>[
    (speed: 1.0, phase: 0.0, orbit: 0.54, size: 3.2),
    (speed: -0.72, phase: 2.1, orbit: 0.48, size: 2.4),
    (speed: 1.35, phase: 4.4, orbit: 0.58, size: 2.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final t = progress * 2 * math.pi;
    final breathe = 0.55 + 0.45 * math.sin(t * 0.65);

    _drawHalo(canvas, center, radius, breathe);
    _drawSpecularSweep(canvas, center, radius - 1.5, t);
    _drawCounterSweep(canvas, center, radius - 0.5, t);
    _drawGlints(canvas, center, radius, t, breathe);
  }

  void _drawHalo(Canvas canvas, Offset center, double radius, double breathe) {
    final halo = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius * 1.05,
        [
          ElEmegiColors.goldLight.withValues(alpha: 0.22 * breathe),
          ElEmegiColors.gold.withValues(alpha: 0.10 * breathe),
          Colors.transparent,
        ],
        [0.72, 0.88, 1.0],
      );
    canvas.drawCircle(center, radius * 1.02, halo);
  }

  void _drawSpecularSweep(Canvas canvas, Offset center, double radius, double t) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final start = t - math.pi / 2;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + 2 * math.pi,
        colors: [
          Colors.transparent,
          Colors.transparent,
          ElEmegiColors.gold.withValues(alpha: 0.05),
          ElEmegiColors.goldLight.withValues(alpha: 0.55),
          Colors.white.withValues(alpha: 0.85),
          ElEmegiColors.goldLight.withValues(alpha: 0.45),
          ElEmegiColors.gold.withValues(alpha: 0.08),
          Colors.transparent,
          Colors.transparent,
        ],
        stops: const [0.0, 0.38, 0.44, 0.47, 0.50, 0.53, 0.58, 0.62, 1.0],
        transform: GradientRotation(start),
      ).createShader(rect);

    canvas.drawArc(rect, start, math.pi * 0.55, false, arc);

    final soft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..color = ElEmegiColors.goldLight.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawArc(rect, start + 0.08, math.pi * 0.42, false, soft);
  }

  void _drawCounterSweep(Canvas canvas, Offset center, double radius, double t) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final start = -t * 0.55 - math.pi / 2;

    final faint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + 2 * math.pi,
        colors: [
          Colors.transparent,
          ElEmegiColors.silverLight.withValues(alpha: 0.08),
          ElEmegiColors.silverLight.withValues(alpha: 0.35),
          ElEmegiColors.silverLight.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.46, 0.5, 0.54, 1.0],
        transform: GradientRotation(start),
      ).createShader(rect);

    canvas.drawArc(rect, start + 0.2, math.pi * 0.22, false, faint);
  }

  void _drawGlints(
    Canvas canvas,
    Offset center,
    double radius,
    double t,
    double breathe,
  ) {
    for (final g in _glints) {
      final angle = t * g.speed + g.phase;
      final twinkle = math.pow(
        (math.sin(t * 1.8 + g.phase) + 1) / 2,
        2.2,
      ).toDouble();
      final alpha = (0.15 + 0.85 * twinkle) * breathe;
      final r = radius * g.orbit;
      final pos = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );

      canvas.drawCircle(
        pos,
        g.size * 2.2,
        Paint()
          ..color = ElEmegiColors.goldLight.withValues(alpha: alpha * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(
        pos,
        g.size,
        Paint()..color = Colors.white.withValues(alpha: alpha * 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BadgeAuraPainter old) =>
      old.progress != progress || old.ringSize != ringSize;
}

typedef IconBadgeSparkleRing = HeaderSparklePattern;
