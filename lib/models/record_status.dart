import 'package:flutter/material.dart';

import '../theme/el_emegi_colors.dart';

/// Firestore `durum` ↔ UI etiketi
enum RecordStatus {
  beklemede('BEKLEMEDE', 'Ödeme bekliyor'),
  onaylandi('ONAYLANDI', 'Onaylandı'),
  odendi('ODENDI', 'Ödendi');

  const RecordStatus(this.firestoreValue, this.label);

  final String firestoreValue;
  final String label;

  static RecordStatus fromFirestore(String? value) {
    return RecordStatus.values.firstWhere(
      (s) => s.firestoreValue == value,
      orElse: () => RecordStatus.beklemede,
    );
  }

  Color backgroundColor(Brightness brightness) => switch (this) {
        RecordStatus.onaylandi => ElEmegiColors.teal.withValues(
            alpha: brightness == Brightness.dark ? 0.22 : 0.12,
          ),
        RecordStatus.beklemede => ElEmegiColors.amber.withValues(
            alpha: brightness == Brightness.dark ? 0.25 : 0.15,
          ),
        RecordStatus.odendi => ElEmegiColors.softBlueGray.withValues(
            alpha: brightness == Brightness.dark ? 0.28 : 0.18,
          ),
      };

  Color foregroundColor() => switch (this) {
        RecordStatus.onaylandi => ElEmegiColors.teal,
        RecordStatus.beklemede => ElEmegiColors.amber,
        RecordStatus.odendi => ElEmegiColors.softBlueGray,
      };
}
