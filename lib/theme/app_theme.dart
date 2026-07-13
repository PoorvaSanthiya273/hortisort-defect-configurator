import 'package:flutter/material.dart';

class AppTheme {
  // New industrial dark palette
  static const Color bg = Color(0xFF0F1115);
  static const Color cardPrimary = Color(0xFF1A2433);
  static const Color cardSecondary = Color(0xFF202B3D);
  static const Color hortisortGreen = Color(0xFFA6CE39);
  static const Color infoBlue = Color(0xFF4DA3FF);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFF9A825);
  static const Color danger = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB5BDC8);
  static const Color textMuted = Color(0xFF6B7A8F);
  static Color get border => Colors.white.withValues(alpha: 0.08);

  // Keep legacy aliases for backward compat
  static const Color headerBg = cardSecondary;
  static const Color mainBg = bg;
  static const Color panelBg = cardPrimary;
  static const Color darkGrey = cardSecondary;
  static const Color primaryText = textPrimary;
  static const Color secondaryText = textSecondary;
  static const Color greenHighlight = hortisortGreen;
  static const Color orangeBar = warning;
  static const Color stopRed = danger;
  static const Color outletGreen = Color(0xFFD4EE7B);
  static const Color outletRed = Color(0xFFFF6B6B);
  static const Color outletOrange = Color(0xFFFFD54F);
  static const Color goodFill = Color(0xFF3D7A4E);
  static const Color mixedFill = Color(0xFF9E4A4A);
  static const Color badFill = Color(0xFF6B2C2C);

  // Shadow / glow / hover utilities
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2)),
      ];

  static List<BoxShadow> get greenGlow => [
        BoxShadow(
            color: hortisortGreen.withValues(alpha: 0.2),
            blurRadius: 14,
            spreadRadius: 2),
      ];

  static BoxBorder get selectedBorder =>
      Border.all(color: hortisortGreen.withValues(alpha: 0.7), width: 1.5);

  static BoxBorder get defaultBorder =>
      Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1);

  static const TextStyle headingXLarge = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle subtitleText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle labelText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle smallText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textMuted,
  );

  static const TextStyle accentText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: hortisortGreen,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: bg,
      primaryColor: hortisortGreen,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: hortisortGreen,
        surface: cardPrimary,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardSecondary,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        titleLarge: cardTitle,
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: bodyText,
        bodySmall: smallText,
        labelMedium: labelText,
        labelSmall: smallText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: hortisortGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(fontSize: 14, color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: hortisortGreen,
          foregroundColor: const Color(0xFF0F1115),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
