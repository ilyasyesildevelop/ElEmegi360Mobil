import 'package:flutter/material.dart';

import '../theme/el_emegi_colors.dart';

/// Vardiya `FabrikaInfoField` ile aynı rol: etiket + değer satırı.
class FabrikaInfoField extends StatelessWidget {
  const FabrikaInfoField({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.trailing,
    this.leading,
    this.highlight = false,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? leading;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = highlight
        ? ElEmegiColors.teal
        : (isDark ? Colors.white : ElEmegiColors.deepNavy);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDark
                    ? ElEmegiColors.softBlueGray
                    : ElEmegiColors.deepNavy.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: valueColor,
                      fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ],
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: content,
        ),
      ),
    );
  }
}
