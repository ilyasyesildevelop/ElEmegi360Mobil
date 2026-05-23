import 'package:flutter/material.dart';

import 'premium_glow_card.dart';

/// Standart form kartı — premium cam, animasyonsuz kenar.
class FabrikaFormCard extends StatelessWidget {
  const FabrikaFormCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return PremiumGlowCard(
      padding: padding,
      child: child,
    );
  }
}
