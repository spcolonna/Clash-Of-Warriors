import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta visual de una locación del cómic: convierte los pocos fondos
/// genéricos existentes en escenarios distintos vía tinte duotono.
class ComicPalette {
  /// Color de sombra (tonos oscuros del duotono).
  final Color shadow;
  /// Color de luz (tonos claros del duotono).
  final Color light;
  /// Color de la trama de medios tonos superpuesta.
  final Color halftone;
  /// Asset de fondo a teñir.
  final String bgAsset;

  const ComicPalette({
    required this.shadow,
    required this.light,
    required this.halftone,
    required this.bgAsset,
  });

  /// Matriz de duotono: mapea la luminancia del fondo al gradiente
  /// shadow→light de la paleta.
  ColorFilter get duotoneFilter {
    final sr = shadow.r, sg = shadow.g, sb = shadow.b;
    final lr = light.r, lg = light.g, lb = light.b;
    // luminancia = 0.299R + 0.587G + 0.114B; out = shadow + lum*(light-shadow)
    return ColorFilter.matrix([
      0.299 * (lr - sr), 0.587 * (lr - sr), 0.114 * (lr - sr), 0, sr * 255,
      0.299 * (lg - sg), 0.587 * (lg - sg), 0.114 * (lg - sg), 0, sg * 255,
      0.299 * (lb - sb), 0.587 * (lb - sb), 0.114 * (lb - sb), 0, sb * 255,
      0, 0, 0, 1, 0,
    ]);
  }
}

/// Tema del sistema de cómic: paletas por locación + tipografía.
class ComicTheme {
  ComicTheme._();

  static const Color paper = Color(0xFFF2EAD8);
  static const Color ink = Color(0xFF14100C);
  static const Color narratorBg = Color(0xFFF5E6B8);

  // ── Paletas por locationId ────────────────────────────────────────────
  static const _fallback = ComicPalette(
    shadow: Color(0xFF1A1A2E),
    light: Color(0xFFB8B2D8),
    halftone: Color(0xFF3D3A5C),
    bgAsset: 'assets/images/bg_1.jpeg',
  );

  static const Map<String, ComicPalette> palettes = {
    // Templo / montaña — azul frío amanecer
    'montana_sagrada': ComicPalette(
      shadow: Color(0xFF16233D),
      light: Color(0xFFA9C7E8),
      halftone: Color(0xFF2E4A72),
      bgAsset: 'assets/images/bg_landscape.png',
    ),
    // Calles de La Ciudadela — ámbar sucio
    'ciudadela_calles': ComicPalette(
      shadow: Color(0xFF33200E),
      light: Color(0xFFE8C48A),
      halftone: Color(0xFF7A5426),
      bgAsset: 'assets/images/bg_1.jpeg',
    ),
    // La Arena / el torneo — rojo dramático
    'arena': ComicPalette(
      shadow: Color(0xFF3A0D12),
      light: Color(0xFFF0A48E),
      halftone: Color(0xFF8C2F2F),
      bgAsset: 'assets/images/pre_battle_bg.png',
    ),
    // El Puerto — verde-teal nocturno
    'puerto': ComicPalette(
      shadow: Color(0xFF0D2B2B),
      light: Color(0xFF9AD4C8),
      halftone: Color(0xFF2E6659),
      bgAsset: 'assets/images/bg_portrait.png',
    ),
    // Catacumbas / guarida del Consejo — violeta conspirativo
    'catacumbas': ComicPalette(
      shadow: Color(0xFF1E0F33),
      light: Color(0xFFB79ADB),
      halftone: Color(0xFF553080),
      bgAsset: 'assets/images/battle_bg_night.png',
    ),
    // Dojo / tatami — madera cálida
    'dojo': ComicPalette(
      shadow: Color(0xFF2E1D10),
      light: Color(0xFFE3C9A5),
      halftone: Color(0xFF6E4E2E),
      bgAsset: 'assets/images/battle_bg_day.png',
    ),
    // Barrio Sur / gimnasio — gris cemento con rojo
    'barrio_sur': ComicPalette(
      shadow: Color(0xFF22201F),
      light: Color(0xFFCFC4BC),
      halftone: Color(0xFF8C3B33),
      bgAsset: 'assets/images/bg_home.png',
    ),
  };

  /// Alias: mapea slugs derivados de locationName reales a paletas.
  static const Map<String, String> _aliases = {
    'la_montana_sagrada': 'montana_sagrada',
    'el_templo': 'montana_sagrada',
    'templo_shaolin': 'montana_sagrada',
    'la_ciudadela': 'ciudadela_calles',
    'calles_de_la_ciudadela': 'ciudadela_calles',
    'la_arena': 'arena',
    'la_gran_arena': 'arena',
    'el_puerto': 'puerto',
    'el_puerto_de_la_ciudadela': 'puerto',
    'dojo_mushin': 'dojo',
    'el_dojo': 'dojo',
    'el_tatami': 'dojo',
    'el_gimnasio': 'barrio_sur',
    'el_barrio_sur': 'barrio_sur',
    'gimnasio_del_barrio_sur': 'barrio_sur',
  };

  static ComicPalette paletteFor(String locationId) =>
      palettes[locationId] ?? palettes[_aliases[locationId]] ?? _fallback;

  // ── Tipografía ────────────────────────────────────────────────────────
  /// Títulos, onomatopeyas, nombres — display estilo cómic.
  static TextStyle display({
    double size = 32,
    Color color = ink,
    double letterSpacing = 1.5,
  }) =>
      GoogleFonts.bangers(
        fontSize: size,
        color: color,
        letterSpacing: letterSpacing,
        height: 1.0,
      );

  /// Texto de diálogo dentro de globos.
  static TextStyle speech({double size = 13.5, Color color = ink}) =>
      GoogleFonts.comicNeue(
        fontSize: size,
        color: color,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  /// Cajas de narrador.
  static TextStyle caption({double size = 12.5}) => GoogleFonts.comicNeue(
        fontSize: size,
        color: ink,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        height: 1.3,
      );
}
