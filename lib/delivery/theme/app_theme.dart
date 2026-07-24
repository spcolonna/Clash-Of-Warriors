import 'package:flutter/material.dart';

import '../../domain/entities/hero_entity.dart';

// ── Colores de facción (FUENTE ÚNICA) ────────────────────────────────────────
// Toda la app debe usar estas dos funciones. No redefinir colores de facción
// en pantallas: la identidad visual de cada facción es la misma en todos lados.

Color factionColor(Faction faction) => switch (faction) {
      Faction.shaolin => const Color(0xFFE5A93C), // dorado templo
      Faction.ninja => const Color(0xFF7B68EE), // violeta sombra
      Faction.judoka => const Color(0xFF4FC3F7), // celeste tatami
      Faction.boxer => const Color(0xFFEF5350), // rojo barrio
      Faction.capoeira => const Color(0xFF66BB6A), // verde ginga
    };

/// Variante por factionId (String de las cartas). null = neutral.
Color? factionColorFromId(String? factionId) {
  final f = factionFromId(factionId);
  return f == null ? null : factionColor(f);
}

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
  // Antes coincidía por error con `card` (0xFF0F3460): el texto quedaba
  // literalmente del mismo color que su fondo (invisible en MiniChip, etc).
  static const textSecondary = Color(0xFF8A8A9A);
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
