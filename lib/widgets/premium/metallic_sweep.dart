import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/el_emegi_colors.dart';

/// Kenar boyunca tek parıltı — saat yönünde düzenli tur.
class BorderGlowController extends AnimationController {
  BorderGlowController({required super.vsync})
      : super(duration: const Duration(seconds: 12)) {
    repeat();
  }
}

/// Yuvarlatılmış dikdörtgen çevresinde hareket eden altın parıltı noktası.
class _BorderSweepPainter extends CustomPainter {
  _BorderSweepPainter({
    required this.progress,
    required this.borderRadius,
    required this.borderWidth,
  });

  final double progress;
  final double borderRadius;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = borderWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - borderWidth,
      size.height - borderWidth,
    );
    final r = math.max(0.0, borderRadius - inset);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));
    final path = Path()..addRRect(rrect);

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = ElEmegiColors.gold.withValues(alpha: 0.2);
    canvas.drawPath(path, basePaint);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final total = metric.length;
    if (total <= 0) return;

    final center = (progress % 1.0) * total;
    _drawSparkle(canvas, metric, total, center);
  }

  /// Kısa, yumuşak parıltı — geniş çubuk değil; merkezde parlak nokta + kuyruk.
  void _drawSparkle(Canvas canvas, PathMetric metric, double total, double center) {
    const layers = <({double spread, double alpha, double blur, double widthMul, Color color})>[
      (spread: 0.045, alpha: 0.10, blur: 7, widthMul: 1.4, color: ElEmegiColors.goldLight),
      (spread: 0.022, alpha: 0.22, blur: 3.5, widthMul: 0.9, color: ElEmegiColors.goldLight),
      (spread: 0.009, alpha: 0.50, blur: 1.2, widthMul: 0.55, color: Colors.white),
      (spread: 0.003, alpha: 0.88, blur: 0, widthMul: 0.35, color: Colors.white),
    ];

    for (final layer in layers) {
      final band = total * layer.spread;
      final segment = _extractWrapped(metric, center - band / 2, band);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth * layer.widthMul
        ..strokeCap = StrokeCap.round
        ..color = layer.color.withValues(alpha: layer.alpha);
      if (layer.blur > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, layer.blur);
      }
      canvas.drawPath(segment, paint);
    }

    final tangent = metric.getTangentForOffset(center);
    if (tangent == null) return;

    final pos = tangent.position;
    canvas.drawCircle(
      pos,
      5,
      Paint()
        ..color = ElEmegiColors.goldLight.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      pos,
      2.2,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      pos,
      0.9,
      Paint()..color = Colors.white.withValues(alpha: 0.98),
    );
  }

  Path _extractWrapped(PathMetric metric, double start, double length) {
    final total = metric.length;
    var s = start % total;
    if (s < 0) s += total;
    final out = Path();
    var remaining = length;
    var pos = s;

    while (remaining > 0) {
      final segment = math.min(remaining, total - pos);
      out.addPath(metric.extractPath(pos, pos + segment), Offset.zero);
      remaining -= segment;
      pos = 0;
    }
    return out;
  }

  @override
  bool shouldRepaint(covariant _BorderSweepPainter old) =>
      old.progress != progress ||
      old.borderRadius != borderRadius ||
      old.borderWidth != borderWidth;
}

/// Cam kart — BackdropFilter yok (bazı Android cihazlarda içerik kayboluyordu).
class GlassMetallicPanel extends StatefulWidget {
  const GlassMetallicPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.borderGlow = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final bool borderGlow;

  @override
  State<GlassMetallicPanel> createState() => _GlassMetallicPanelState();
}

class _GlassMetallicPanelState extends State<GlassMetallicPanel>
    with SingleTickerProviderStateMixin {
  BorderGlowController? _border;

  @override
  void initState() {
    super.initState();
    if (widget.borderGlow) {
      _border = BorderGlowController(vsync: this);
    }
  }

  @override
  void dispose() {
    _border?.dispose();
    super.dispose();
  }

  double get _cornerRadius => widget.borderRadius.topLeft.x;

  @override
  Widget build(BuildContext context) {
    final inner = ElEmegiColors.cardDark.withValues(alpha: 0.94);

    if (_border != null) {
      return RepaintBoundary(
        child: AnimatedBuilder(
          animation: _border!,
          builder: (context, child) =>
              _buildGlowingPanel(inner, _border!.value, child: child),
          child: widget.child,
        ),
      );
    }
    return _buildPanel(inner);
  }

  Widget _buildGlowingPanel(Color inner, double borderT, {Widget? child}) {
    const borderWidth = 2.0;
    final innerRadius = BorderRadius.circular(_cornerRadius - 1);

    return CustomPaint(
      painter: _BorderSweepPainter(
        progress: borderT,
        borderRadius: _cornerRadius,
        borderWidth: borderWidth,
      ),
      child: Padding(
        padding: const EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: innerRadius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: inner,
              borderRadius: innerRadius,
              boxShadow: [
                BoxShadow(
                  color: ElEmegiColors.gold.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: widget.padding,
              child: child ?? widget.child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(Color inner) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        boxShadow: [
          BoxShadow(
            color: ElEmegiColors.gold.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            ElEmegiColors.gold.withValues(alpha: 0.35),
            ElEmegiColors.silver.withValues(alpha: 0.22),
            ElEmegiColors.gold.withValues(alpha: 0.3),
          ],
        ),
      ),
      padding: const EdgeInsets.all(1.1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cornerRadius - 1),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: inner,
            borderRadius: BorderRadius.circular(_cornerRadius - 1),
          ),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
