import 'package:flutter/material.dart';

/// App color palette and theme styling for casual mobile game look.
class AppTheme {
  // Vibrant Casual Colors
  static const Color primary = Color(0xFF6C5CE7); // Indigo Violet
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color secondary = Color(0xFF00CEC9); // Bright Teal
  static const Color accent = Color(0xFFFF7675); // Coral Red
  static const Color goldStar = Color(0xFFFDCB6E); // Gold Yellow
  static const Color cardBg = Color(0xFF2D3436);
  static const Color bgDark = Color(0xFF0F172A); // Slate Dark
  static const Color bgLight = Color(0xFF1E293B);

  // Board colors
  static const Color tileBg = Color(0xFF334155);
  static const Color tileBorder = Color(0xFF475569);
  static const Color arrowDefault = Color(0xFF38BDF8); // Sky Blue
  static const Color arrowBlocked = Color(0xFFF43F5E); // Bright Red
  static const Color arrowExit = Color(0xFF4ADE80); // Bright Green

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: bgLight,
      ),
      cardTheme: CardTheme(
        color: bgLight,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
