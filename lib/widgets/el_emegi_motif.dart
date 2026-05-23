import 'package:flutter/material.dart';

import '../theme/el_emegi_colors.dart';

/// Dekoratif halı köşesi / saçak vurgusu — arayüzü kalabalıklaştırmaz.
class ElEmegiMotif extends StatelessWidget {
  const ElEmegiMotif({super.key, this.size = 48, this.alignment = Alignment.topRight});

  final double size;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Opacity(
        opacity: 0.2,
        child: CustomPaint(
          size: Size(size, size),
          painter: _CornerMotifPainter(
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
    );
  }
}

class _CornerMotifPainter extends CustomPainter {
  _CornerMotifPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rug = Paint()
      ..color = isDark ? ElEmegiColors.kilimRed : ElEmegiColors.kilimRed.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    final fringe = Paint()
      ..color = ElEmegiColors.threadCream.withValues(alpha: isDark ? 0.5 : 0.85)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.65, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, rug);

    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.55 + i * 0.08);
      canvas.drawLine(
        Offset(size.width * 0.15, y),
        Offset(size.width * 0.9, y + 4),
        fringe,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CornerMotifPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
