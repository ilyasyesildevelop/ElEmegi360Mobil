import 'package:flutter/material.dart';

import '../../theme/el_emegi_colors.dart';
import '../../theme/el_emegi_typography.dart';

/// Mockup 01: sol etiket, sağ koyu kutu + altın ok.
class DesignFormRow extends StatelessWidget {
  const DesignFormRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.showChevron = true,
    this.child,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool showChevron;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final field = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? ElEmegiColors.darkNavy.withValues(alpha: 0.85)
            : ElEmegiColors.deepNavy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? ElEmegiColors.gold.withValues(alpha: 0.12)
              : ElEmegiColors.deepNavy.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: child ??
                Text(
                  value,
                  style: ElEmegiTypography.formValue(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
          ),
          if (showChevron && onTap != null)
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: ElEmegiColors.gold,
              size: 22,
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: ElEmegiTypography.formLabel(context).copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: onTap == null
                ? field
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(10),
                      child: field,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
