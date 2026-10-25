import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Light pink palette with rose-gold accents.
class AppColors {
  static const background = Color(0xFFFDF2F4); // blush white
  static const foreground = Color(0xFF5B3A45); // deep rose-brown ink
  static const gold = Color(0xFFC9A17A); // rose gold
  static const mauve = Color(0xFFA0697A); // muted mauve labels / rules
  static const rose = Color(0xFFEBB8C3); // light pink envelope / accents
  static const roseDark = Color(0xFFCF8C9E);
  static const goldLight = Color(0xFFF0D9C0); // rose-gold highlight
  static const parchment = Color(0xFFF7E1E6);

  // Kept for the painted fallbacks.
  static const olive = Color(0xFF7D8350);
  static const cypress = Color(0xFF2F3A24);

  static Color ink([double alpha = 1]) => foreground.withValues(alpha: alpha);
}

class AppText {
  /// Script headings (Pinyon Script).
  static TextStyle script(double size, {Color color = AppColors.foreground}) =>
      GoogleFonts.pinyonScript(fontSize: size, color: color, height: 1.15);

  /// Body copy (EB Garamond).
  static TextStyle body(double size,
          {Color color = AppColors.foreground, FontStyle? style, FontWeight weight = FontWeight.w400, double height = 1.7}) =>
      GoogleFonts.ebGaramond(fontSize: size, color: color, height: height, fontStyle: style, fontWeight: weight);

  /// Small tracked uppercase labels (EB Garamond).
  static TextStyle label(double size, {Color color = AppColors.mauve, double spacing = 3.5, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.ebGaramond(fontSize: size, color: color, letterSpacing: spacing, fontWeight: weight, height: 1.6);

  /// Display numerals / venue names (Cormorant Garamond).
  static TextStyle display(double size, {Color color = AppColors.foreground, FontWeight weight = FontWeight.w300}) =>
      GoogleFonts.cormorantGaramond(fontSize: size, color: color, fontWeight: weight, height: 1.1);
}

ThemeData buildTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.rose, surface: AppColors.background),
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(2),
    borderSide: BorderSide(color: AppColors.ink(0.2)),
  );
  return base.copyWith(
    textTheme: GoogleFonts.ebGaramondTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.foreground, displayColor: AppColors.foreground),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.5),
      labelStyle: AppText.body(16, color: AppColors.ink(0.6)),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.gold, width: 1.2)),
    ),
  );
}
