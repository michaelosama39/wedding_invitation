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
  /// Set by the app whenever the language changes (see main.dart).
  ///
  /// The Latin fonts have no Arabic glyphs, so in Arabic an Arabic font is
  /// added as a fallback: Latin text (monogram, digits) keeps its typeface and
  /// Arabic text uses the fallback. Letter-spacing and italics are dropped in
  /// Arabic because they break the joined letters.
  static bool arabic = false;

  static List<String>? _fallback(TextStyle Function() font) {
    if (!arabic) return null;
    final family = font().fontFamily;
    return family == null ? null : [family];
  }

  static FontStyle? _style(FontStyle? style) => arabic ? null : style;
  static double _spacing(double spacing) => arabic ? 0 : spacing;

  /// Script headings (Pinyon Script / Aref Ruqaa).
  static TextStyle script(double size, {Color color = AppColors.foreground}) =>
      GoogleFonts.pinyonScript(
        fontSize: size,
        color: color,
        height: arabic ? 1.5 : 1.15,
      ).copyWith(fontFamilyFallback: _fallback(GoogleFonts.arefRuqaa));

  /// Body copy (EB Garamond / Amiri).
  static TextStyle body(
    double size, {
    Color color = AppColors.foreground,
    FontStyle? style,
    FontWeight weight = FontWeight.w400,
    double height = 1.7,
  }) => GoogleFonts.ebGaramond(
    fontSize: size,
    color: color,
    height: height,
    fontStyle: _style(style),
    fontWeight: weight,
  ).copyWith(fontFamilyFallback: _fallback(GoogleFonts.amiri));

  /// Small tracked uppercase labels (EB Garamond / Amiri).
  static TextStyle label(
    double size, {
    Color color = AppColors.mauve,
    double spacing = 3.5,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.ebGaramond(
    fontSize: size,
    color: color,
    letterSpacing: _spacing(spacing),
    fontWeight: weight,
    height: 1.6,
  ).copyWith(fontFamilyFallback: _fallback(GoogleFonts.amiri));

  /// Display numerals / venue names (Cormorant Garamond / Amiri).
  static TextStyle display(
    double size, {
    Color color = AppColors.foreground,
    FontWeight weight = FontWeight.w300,
  }) => GoogleFonts.cormorantGaramond(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: 1.1,
  ).copyWith(fontFamilyFallback: _fallback(GoogleFonts.amiri));
}

ThemeData buildTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.rose,
      surface: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(2),
    borderSide: BorderSide(color: AppColors.ink(0.2)),
  );
  return base.copyWith(
    textTheme: GoogleFonts.ebGaramondTextTheme(base.textTheme).apply(
      bodyColor: AppColors.foreground,
      displayColor: AppColors.foreground,
      fontFamilyFallback: AppText._fallback(GoogleFonts.amiri),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.5),
      labelStyle: AppText.body(16, color: AppColors.ink(0.6)),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.gold, width: 1.2),
      ),
    ),
  );
}
