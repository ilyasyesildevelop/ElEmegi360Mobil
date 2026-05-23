import 'package:flutter/material.dart';

import '../../theme/el_emegi_colors.dart';

/// Uygulama geneli arka plan (assets/images/bg_02.webp).
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  static const _asset = 'assets/images/bg_02.webp';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            _asset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: ElEmegiColors.darkNavy),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ElEmegiColors.darkNavy.withValues(alpha: 0.72),
                  ElEmegiColors.darkNavy.withValues(alpha: 0.88),
                  ElEmegiColors.darkNavy.withValues(alpha: 0.94),
                ],
              ),
            ),
          ),
        ),
        // Column + Expanded için sınırlı yükseklik şart; aksi halde içerik çizilmez.
        Positioned.fill(child: child),
      ],
    );
  }
}
