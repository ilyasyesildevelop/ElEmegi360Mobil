import 'package:flutter/material.dart';

import '../../theme/el_emegi_colors.dart';

/// Mockup 03: alt navigasyon üstü halı şeridi.
class CarpetNavStrip extends StatelessWidget {
  const CarpetNavStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      width: double.infinity,
      child: CustomPaint(painter: _CarpetStripPainter()),
    );
  }
}

class _CarpetStripPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      ElEmegiColors.kilimRed,
      ElEmegiColors.gold,
      ElEmegiColors.teal,
      ElEmegiColors.olive,
      ElEmegiColors.kilimRed,
      ElEmegiColors.amber,
    ];
    final w = size.width / colors.length;
    for (var i = 0; i < colors.length; i++) {
      final paint = Paint()..color = colors[i].withValues(alpha: 0.85);
      canvas.drawRect(Rect.fromLTWH(i * w, 0, w + 1, size.height), paint);
    }
    final line = Paint()
      ..color = ElEmegiColors.goldLight.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
