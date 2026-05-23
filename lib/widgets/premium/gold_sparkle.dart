import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/el_emegi_colors.dart';

/// Altın yıldız parıltı çizimi.
class GoldSparkleIcon extends StatelessWidget {
  const GoldSparkleIcon({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(),
    );
  }
}

/// Logo / thumbnail üzerinde altın parıltı (new_design).
class GoldSparkle extends StatelessWidget {
  const GoldSparkle({
    super.key,
    this.size = 28,
    this.top = -6,
    this.right,
    this.left,
  });

  final double size;
  final double top;
  final double? right;
  final double? left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      left: left,
      child: IgnorePointer(child: GoldSparkleIcon(size: size)),
    );
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final glow = Paint()
      ..color = ElEmegiColors.goldLight.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center, size.width * 0.42, glow);

    final star = Paint()..color = ElEmegiColors.goldLight;
    _drawStar(canvas, center, size.width * 0.26, star);
    _drawStar(
      canvas,
      center + Offset(size.width * 0.28, size.height * 0.12),
      size.width * 0.1,
      star..color = ElEmegiColors.gold.withValues(alpha: 0.9),
    );
    _drawStar(
      canvas,
      center + Offset(-size.width * 0.2, size.height * 0.18),
      size.width * 0.08,
      star..color = ElEmegiColors.silverLight.withValues(alpha: 0.85),
    );
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    const points = 4;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? r : r * 0.38;
      final angle = (i * math.pi / points) - math.pi / 2;
      final p = Offset(
        c.dx + radius * math.cos(angle),
        c.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
