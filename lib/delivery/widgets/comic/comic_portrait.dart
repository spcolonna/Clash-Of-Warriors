import 'package:flutter/material.dart';
import '../../../domain/entities/hero_entity.dart';
import '../../../infra/local/heroes_data.dart';
import '../../../infra/local/story/story_npcs.dart';

/// Retrato de personaje estilo cómic.
///
/// - Héroes conocidos → PNG de `withoutBG/` con tratamiento "entintado"
///   (outline barato: duplicado del PNG teñido negro y escalado detrás).
/// - NPCs (Maestro Lin, El Arquitecto, Vespa...) → **modo silueta**: el PNG
///   de una facción afín teñido de negro/violeta. Estética misteriosa
///   deliberada + hook natural para arte real futuro vía [imagePath].
class ComicPortrait extends StatelessWidget {
  final String speakerId;
  final double height;
  final bool mirrored;
  /// Hook: ilustración real (ignora el render procedural).
  final String? imagePath;
  /// Emoción declarada en la línea ('angry', 'shocked', 'sad'...).
  final String? emotion;
  /// Atenuado (speaker inactivo del panel).
  final bool dimmed;

  /// Fuerza modo silueta con este tinte aunque el speaker sea un héroe
  /// conocido (jefes narrativos: "El Arquitecto" usando un bot-héroe).
  final Color? silhouetteTint;

  const ComicPortrait({
    super.key,
    required this.speakerId,
    this.height = 150,
    this.mirrored = false,
    this.imagePath,
    this.emotion,
    this.dimmed = false,
    this.silhouetteTint,
  });

  static const _factionAsset = {
    Faction.shaolin: 'assets/images/heros/withoutBG/shaolin_common.png',
    Faction.ninja: 'assets/images/heros/withoutBG/ninja_common.png',
    Faction.judoka: 'assets/images/heros/withoutBG/judo_common.png',
    Faction.boxer: 'assets/images/heros/withoutBG/boxer_common.png',
    Faction.capoeira: 'assets/images/heros/withoutBG/capoeira_common.png',
  };

  @override
  Widget build(BuildContext context) {
    Widget result;

    if (imagePath != null) {
      // Arte real provisto por contenido
      result = Image.asset(
        imagePath!,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => SizedBox(height: height),
      );
    } else if (silhouetteTint != null) {
      final hero = HeroesData.findByIdSafe(speakerId);
      final asset = hero != null
          ? _factionAsset[hero.faction]!
          : _factionAsset[Faction.ninja]!;
      result = _silhouette(asset, silhouetteTint!);
    } else {
      final hero = HeroesData.findByIdSafe(speakerId);
      if (hero != null) {
        result = _inkedHero(_factionAsset[hero.faction]!);
      } else {
        final npc = StoryNpcs.byId(speakerId);
        if (npc != null) {
          result = _silhouette(_factionAsset[npc.faction]!, npc.tint);
        } else {
          // NPC desconocido: silueta gris genérica
          result = _silhouette(
              _factionAsset[Faction.ninja]!, const Color(0xFF2B2B33));
        }
      }
    }

    if (mirrored) {
      result = Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(-1, 1, 1),
        child: result,
      );
    }

    // Emoción (hasta tener arte por emoción): tratamiento sutil
    if (emotion == 'sad') {
      result = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.5, 0.4, 0.1, 0, 10,
          0.4, 0.5, 0.1, 0, 10,
          0.3, 0.4, 0.3, 0, 20,
          0, 0, 0, 1, 0,
        ]),
        child: result,
      );
    }

    if (dimmed) {
      result = Opacity(opacity: 0.45, child: result);
    }

    return SizedBox(height: height, child: result);
  }

  /// Héroe "entintado": outline negro barato (duplicado escalado) + PNG con
  /// contraste/saturación de tinta.
  Widget _inkedHero(String asset) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Outline: la misma imagen teñida negra, apenas más grande
        Transform.scale(
          scale: 1.045,
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
                Color(0xFF14100C), BlendMode.srcATop),
            child: Image.asset(
              asset,
              height: height,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => SizedBox(height: height),
            ),
          ),
        ),
        // Imagen con contraste alto (look entintado)
        ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            1.25, 0, 0, 0, -18,
            0, 1.25, 0, 0, -18,
            0, 0, 1.25, 0, -18,
            0, 0, 0, 1, 0,
          ]),
          child: Image.asset(
            asset,
            height: height,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => SizedBox(height: height),
          ),
        ),
      ],
    );
  }

  Widget _silhouette(String asset, Color tint) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(tint, BlendMode.srcATop),
      child: Image.asset(
        asset,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => SizedBox(height: height),
      ),
    );
  }
}
