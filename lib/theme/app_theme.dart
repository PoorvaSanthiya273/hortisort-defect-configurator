import 'package:flutter/material.dart';

class AppTheme {
  static const Color headerBg = Color(0xFF4A4A4A);
  static const Color mainBg = Color(0xFF000000);
  static const Color panelBg = Color(0xFF26384F);
  static const Color darkGrey = Color(0xFF4A4A4A);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFD8D8D8);
  static const Color greenHighlight = Color(0xFF8DAA00);
  static const Color orangeBar = Color(0xFFF5A000);
  static const Color stopRed = Color(0xFF6B1605);

  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: mainBg,
      primaryColor: greenHighlight,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: greenHighlight,
        surface: panelBg,
        error: stopRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: headerBg,
        foregroundColor: primaryText,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: primaryText),
        headlineMedium: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, color: primaryText),
        titleLarge: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: primaryText),
        titleMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: primaryText),
        bodyLarge: TextStyle(fontSize: 16, color: primaryText),
        bodyMedium: TextStyle(fontSize: 14, color: primaryText),
        bodySmall: TextStyle(fontSize: 14, color: secondaryText),
        labelMedium: TextStyle(fontSize: 14, color: secondaryText),
        labelSmall: TextStyle(fontSize: 12, color: secondaryText),
      ),
    );
  }
}
