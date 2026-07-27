import 'package:flutter/material.dart';

enum AppThemeType { classic, hightech }

/// Palette constants exactly as specified in the design brief.
class AppColors {
  // --- High-Tech Neon HUD ---
  static const htBackground = Color(0xFF0D0F12);
  static const htBackgroundPureBlack = Color(0xFF000000);
  static const htElectricCyan = Color(0xFF00F0FF);
  static const htNeonViolet = Color(0xFF7B2CBF);
  static const htNeonGreen = Color(0xFF39FF14); // active-task highlight
  static const htCyberRed = Color(0xFFFF0055); // distraction warning

  // --- Classic / Minimalist ---
  static const classicBackground = Color(0xFFF8F9FA);
  static const classicNavy = Color(0xFF1E293B);
  static const classicOlive = Color(0xFF15803D);
}

class AppTheme {
  static ThemeData of(AppThemeType type) {
    return type == AppThemeType.hightech ? hightech : classic;
  }

  static final ThemeData classic = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.classicBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.classicNavy,
      secondary: AppColors.classicOlive,
      surface: Colors.white,
      onPrimary: Colors.white,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.classicBackground,
      foregroundColor: AppColors.classicNavy,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.classicNavy,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.classicOlive,
    ),
  );

  static final ThemeData hightech = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.htBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.htElectricCyan,
      secondary: AppColors.htNeonViolet,
      surface: Color(0xFF14171C),
      error: AppColors.htCyberRed,
      onPrimary: Colors.black,
    ),
    fontFamily: 'RobotoMono',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.htBackground,
      foregroundColor: AppColors.htElectricCyan,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF14171C),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF23272E)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.htElectricCyan,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.htElectricCyan,
    ),
  );

  /// Neon glow shadow used on High-Tech HUD widgets (buttons, active-task
  /// highlights, gamified progress visuals).
  static List<BoxShadow> neonGlow(Color color, {double intensity = 0.6}) => [
        BoxShadow(
          color: color.withOpacity(intensity),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];
}
