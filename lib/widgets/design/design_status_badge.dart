import 'package:flutter/material.dart';

import '../../models/record_status.dart';
import '../../theme/el_emegi_colors.dart';

/// Mockup 02/03: kenarlıklı durum rozeti + ikon.
class DesignStatusBadge extends StatelessWidget {
  const DesignStatusBadge({super.key, required this.status});

  final RecordStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      RecordStatus.onaylandi => (const Color(0xFF4ADE80), Icons.check_circle_outline),
      RecordStatus.beklemede => (ElEmegiColors.amber, Icons.schedule_rounded),
      RecordStatus.odendi => (ElEmegiColors.tealLight, Icons.check_circle_outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.65), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
