import 'package:flutter/material.dart';

import '../../theme/el_emegi_colors.dart';

/// Scaffold arkasında yumuşak bloom / ambient ışık (derinlik katmanı).
class PremiumAmbientBackground extends StatelessWidget {
  const PremiumAmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return child;

    return Stack(
      fit: StackFit.expand,
      children: [
        const _AmbientOrbs(),
        child,
      ],
    );
  }
}

class _AmbientOrbs extends StatelessWidget {
  const _AmbientOrbs();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _orb(220, ElEmegiColors.teal.withValues(alpha: 0.12)),
          ),
          Positioned(
            top: 120,
            left: -60,
            child: _orb(180, ElEmegiColors.gold.withValues(alpha: 0.07)),
          ),
          Positioned(
            bottom: 120,
            right: -20,
            child: _orb(160, ElEmegiColors.silver.withValues(alpha: 0.06)),
          ),
        ],
      ),
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 80, spreadRadius: 20),
        ],
      ),
    );
  }
}
