import 'package:flutter/material.dart';

/// CapCut-style modern Dark Theme Design System
class AppTheme {
  // Palet Warna Utama (True CapCut Dark)
  static const Color background = Color(0xFF121212); // Pure deep dark
  static const Color surface = Color(0xFF1E1E1E);    // Bar & Panel surface
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color cardColor = Color(0xFF242424);
  
  // CapCut Accent Colors
  static const Color primary = Color(0xFF00E5FF);    // Vibrant Cyan / Aqua
  static const Color accentCyan = Color(0xFF00D1FF); // Ekspor button cyan
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color diamondPurple = Color(0xFF9D4EDD);

  // Status & Trim Colors
  static const Color playhead = Color(0xFFFFFFFF);   // Putih garis playhead
  static const Color timelineBg = Color(0xFF181818);
  static const Color trackBg = Color(0xFF222222);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF616161);

  // Border & Divider
  static const Color border = Color(0xFF2C2C2C);
  static const Color divider = Color(0xFF222222);

  // Border Radius
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 14.0;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accentCyan,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
    );
  }
}
