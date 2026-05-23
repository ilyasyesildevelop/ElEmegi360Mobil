import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'el_emegi_colors.dart';

/// new_design mockup tipografi: Playfair (marka) + Inter (UI).
abstract final class ElEmegiTypography {
  static TextStyle brandGold(double size) => GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: ElEmegiColors.goldLight,
        height: 1.1,
      );

  /// "360" — parlak teal yerine yumuşak gümüş/krem (marka ile uyumlu).
  static TextStyle brandAccent(double size) => GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: ElEmegiColors.silverLight.withValues(alpha: 0.92),
        height: 1.1,
        letterSpacing: 0.5,
      );

  static TextStyle tagline(BuildContext context) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: ElEmegiColors.threadCream.withValues(alpha: 0.72),
        letterSpacing: 0.2,
      );

  static TextStyle screenTitle(BuildContext context) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : ElEmegiColors.deepNavy,
      );

  static TextStyle sectionInCard(BuildContext context) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : ElEmegiColors.deepNavy,
      );

  static TextStyle formLabel(BuildContext context) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: ElEmegiColors.softBlueGray,
      );

  static TextStyle formValue(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : ElEmegiColors.deepNavy,
      );
}
