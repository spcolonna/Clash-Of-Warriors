import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFC62828);
  static const secondary = Color(0xFF6A1B9A);
  static const accent = Color(0xFFE65100);
  static const gold = Color(0xFFFFD700);
  static const bg = Color(0xFF1A1A2E);
  static const bgLight = Color(0xFF16213E);
  static const card = Color(0xFF0F3460);
  static const surface = Color(0xFF222244);
  static const textPrimary = Color(0xFFB0B0B0);
  static const textSecondary = Color(0xFF0F3460);
  static const hp100 = Color(0xFF2E7D32);
  static const hp50 = Color(0xFFE65100);
  static const hp25 = Color(0xFFC62828);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      bodyMedium: TextStyle(fontSize: 13, color: AppColors.textSecondary),
    ),
  );
}

Color hpColor(int hp, int maxHp) {
  final pct = hp / maxHp;
  if (pct > 0.5) return AppColors.hp100;
  if (pct > 0.25) return AppColors.hp50;
  return AppColors.hp25;
}
