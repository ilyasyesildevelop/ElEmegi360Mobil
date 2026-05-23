import 'package:flutter/material.dart';

import 'premium/metallic_sweep.dart';

/// Cam kart; [borderGlow] yalnızca Kayıt ekranı çalışan/ürün kartlarında true.
class PremiumGlowCard extends StatelessWidget {
  const PremiumGlowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    bool borderGlow = false,
    @Deprecated('borderGlow kullanın') bool animate = false,
  }) : borderGlow = borderGlow || animate;

  final Widget child;
  final EdgeInsets padding;
  final bool borderGlow;

  @override
  Widget build(BuildContext context) {
    return GlassMetallicPanel(
      padding: padding,
      borderGlow: borderGlow,
      child: child,
    );
  }
}
