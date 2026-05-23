import 'package:flutter/material.dart';

/// Fabrika 360 ailesi + El Emeği sıcak / premium metalik motifler.
abstract final class ElEmegiColors {
  static const deepNavy = Color(0xFF1A1F36);
  static const darkNavy = Color(0xFF0F1425);
  static const headerEnd = Color(0xFF2A3152);
  static const teal = Color(0xFF00C2A8);
  static const tealLight = Color(0xFF33D4BE);
  static const amber = Color(0xFFF5A623);
  static const kilimRed = Color(0xFFD7263D);
  static const threadCream = Color(0xFFF7F2E8);
  static const olive = Color(0xFF8A9A5B);
  static const softBlueGray = Color(0xFF7FA6B8);
  static const cardDark = Color(0xFF1E2540);

  /// Premium altın / gümüş (new_design + premium UI engineering)
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF5D78E);
  static const goldDeep = Color(0xFFB8860B);
  static const silver = Color(0xFFC0C8D4);
  static const silverLight = Color(0xFFE8ECF2);
  static const silverDeep = Color(0xFF8A95A8);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepNavy, headerEnd],
  );

  static const goldMetallicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldDeep, goldLight, gold, goldDeep],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  static const silverMetallicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [silverDeep, silverLight, silver, silverDeep],
    stops: [0.0, 0.4, 0.6, 1.0],
  );

  static const ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [teal, tealLight],
  );

  /// Kenar dolaşan parıltı — dar parlak bant + koyu zemin (daha belirgin).
  static List<Color> borderSweepColors({bool goldPrimary = true}) {
    if (goldPrimary) {
      return [
        gold.withValues(alpha: 0.18),
        gold.withValues(alpha: 0.22),
        goldLight.withValues(alpha: 0.95),
        Colors.white.withValues(alpha: 0.75),
        goldLight.withValues(alpha: 0.9),
        gold.withValues(alpha: 0.25),
        gold.withValues(alpha: 0.18),
      ];
    }
    return [
      silver.withValues(alpha: 0.15),
      silver.withValues(alpha: 0.2),
      silverLight.withValues(alpha: 0.9),
      Colors.white.withValues(alpha: 0.65),
      silverLight.withValues(alpha: 0.85),
      silver.withValues(alpha: 0.22),
      silver.withValues(alpha: 0.15),
    ];
  }

  static List<double> borderSweepStops() =>
      const [0.0, 0.58, 0.72, 0.78, 0.84, 0.92, 1.0];
}
