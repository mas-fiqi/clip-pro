import 'package:flutter/material.dart';

/// QUICKCLIP PRO - Premium Creative Video Editor Design System Tokens
class AppDesignTokens {
  // Surface Layers
  static const Color bgMidnight = Color(0xFF0D0E15);      // Deepest background
  static const Color surfacePrimary = Color(0xFF141622);   // Main panels & bottom sheets
  static const Color surfaceSecondary = Color(0xFF1C1F30); // Cards & inputs
  static const Color surfaceElevated = Color(0xFF262B40);  // Floating cards & active chips
  static const Color surfaceGlass = Color(0x331C1F30);     // Glassmorphism overlay

  // Accent Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF0077FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentPurpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF181B2B), Color(0xFF121422)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x3300E5FF), Color(0x00141622)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Accent Solids
  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color blueAccent = Color(0xFF3B82F6);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color redAccent = Color(0xFFEF4444);
  static const Color greenAccent = Color(0xFF10B981);

  // Border & Hairlines
  static const Color borderSubtle = Color(0x26FFFFFF); // 15% white
  static const Color borderGlow = Color(0x6600E5FF);   // 40% cyan
  static const Color borderGlass = Color(0x1FFFFFFF);  // 12% white

  // Typography Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B7C3);
  static const Color textMuted = Color(0xFF6B7280);

  // Radius Tokens
  static const double radiusS = 8.0;
  static const double radiusM = 14.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 28.0;

  // Box Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.25),
      blurRadius: 14,
      spreadRadius: 1,
      offset: const Offset(0, 4),
    ),
  ];
}

