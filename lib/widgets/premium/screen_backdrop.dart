import 'package:flutter/material.dart';

import '../../theme/el_emegi_colors.dart';

/// Kayıt alanı arka planı (header dışında).
class ScreenBackdrop extends StatelessWidget {
  const ScreenBackdrop({super.key});

  static const _asset = 'assets/images/bg_02.webp';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _asset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const ColoredBox(color: ElEmegiColors.darkNavy),
        ),
        ColoredBox(color: ElEmegiColors.darkNavy.withValues(alpha: 0.82)),
      ],
    );
  }
}
