import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'el_emegi_colors.dart';

abstract final class ElEmegiTheme {
  static ThemeData light() => _base(Brightness.light).copyWith(
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        dividerColor: ElEmegiColors.deepNavy.withValues(alpha: 0.08),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  static ThemeData dark() => _base(Brightness.dark).copyWith(
        scaffoldBackgroundColor: ElEmegiColors.darkNavy,
        dividerColor: Colors.white.withValues(alpha: 0.08),
      );

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ElEmegiColors.teal,
        brightness: brightness,
        primary: ElEmegiColors.teal,
        secondary: ElEmegiColors.amber,
        surface: isDark ? ElEmegiColors.cardDark : Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(),
    );

    final labelColor = isDark
        ? ElEmegiColors.threadCream.withValues(alpha: 0.7)
        : ElEmegiColors.deepNavy.withValues(alpha: 0.65);

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: ElEmegiColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 2,
        shadowColor: ElEmegiColors.deepNavy.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? ElEmegiColors.cardDark : Colors.white,
        margin: EdgeInsets.zero,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: isDark ? Colors.white : ElEmegiColors.deepNavy,
        displayColor: isDark ? Colors.white : ElEmegiColors.deepNavy,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? ElEmegiColors.deepNavy.withValues(alpha: 0.4)
            : ElEmegiColors.threadCream.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: labelColor),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: ElEmegiColors.deepNavy,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
