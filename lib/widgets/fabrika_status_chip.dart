import 'package:flutter/material.dart';

import '../models/record_status.dart';

class FabrikaStatusChip extends StatelessWidget {
  const FabrikaStatusChip({super.key, required this.status});

  final RecordStatus status;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor(brightness),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.foregroundColor(),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
