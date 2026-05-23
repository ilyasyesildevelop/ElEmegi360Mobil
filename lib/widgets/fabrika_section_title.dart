import 'package:flutter/material.dart';

import '../theme/el_emegi_colors.dart';

class FabrikaSectionTitle extends StatelessWidget {
  const FabrikaSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isDark
                  ? ElEmegiColors.softBlueGray
                  : ElEmegiColors.deepNavy.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
