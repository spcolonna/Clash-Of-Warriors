// lib/infra/local/story/story_npcs.dart
//
// Catálogo de personajes narrativos del modo historia (los que NO son héroes
// jugables). Antes vivía como un mapa privado dentro de `comic_portrait.dart`,
// o sea que un dato de contenido estaba enterrado en la capa de presentación y
// nadie podía validarlo: por eso "El Falsario" se dibujaba con cuerpo shaolin
// mientras la batalla siguiente era contra un ninja.
//
// REGLA: si el NPC es el jefe de la batalla que sigue a su diálogo (su
// `speakerName` coincide con el `bossName` de ese `battle()`), su [faction]
// tiene que ser la misma que la del `botHeroId` contra el que se pelea.
// `test/story_npc_consistency_test.dart` lo verifica sobre los 20 arcos.

import 'package:flutter/material.dart' show Color;
import '../../../domain/entities/hero_entity.dart' show Faction;

class StoryNpc {
  /// Id usado como `speakerId` en las líneas de diálogo.
  final String id;

  /// Facción cuyo cuerpo se usa como base de la silueta.
  final Faction faction;

  /// Color de la silueta (cada villano tiene su tinte).
  final Color tint;

  const StoryNpc({
    required this.id,
    required this.faction,
    required this.tint,
  });
}

class StoryNpcs {
  StoryNpcs._();

  static const _shadow = Color(0xFF2E3440);

  static const all = <StoryNpc>[
    // ── Aliados y secundarios ──────────────────────────────────────────────
    StoryNpc(id: 'maestro_lin', faction: Faction.shaolin, tint: _shadow),
    StoryNpc(id: 'sensei_hiroshi', faction: Faction.judoka, tint: _shadow),
    StoryNpc(id: 'lucas', faction: Faction.capoeira, tint: Color(0xFF25303A)),
    StoryNpc(id: 'oficial', faction: Faction.judoka, tint: Color(0xFF2A2A33)),
    StoryNpc(id: 'entrenador', faction: Faction.boxer, tint: Color(0xFF2E2A26)),

    // ── El Arquitecto ──────────────────────────────────────────────────────
    // Discípulo renegado del Maestro Lin ("Veinte años esperé esta clase
    // final", "el viejo verá cuál de los dos fue su verdadero fracaso"): es
    // shaolin, el espejo oscuro de Puo Liu, y lo es en las 5 sagas.
    StoryNpc(id: 'arquitecto', faction: Faction.shaolin, tint: Color(0xFF3A1458)),
    StoryNpc(id: 'el_arquitecto', faction: Faction.shaolin, tint: Color(0xFF3A1458)),

    // ── Villanos de los actos II-IV ────────────────────────────────────────
    // Maestro del clan ninja de Kage ("Te di un nombre... te di un arte").
    StoryNpc(id: 'maestro_clan', faction: Faction.ninja, tint: Color(0xFF1A1023)),
    StoryNpc(id: 'lugarteniente', faction: Faction.ninja, tint: Color(0xFF241430)),
    StoryNpc(id: 'cobrador', faction: Faction.ninja, tint: Color(0xFF1E2A22)),
    StoryNpc(id: 'tesorero', faction: Faction.boxer, tint: Color(0xFF2A2418)),
    StoryNpc(id: 'verdugo', faction: Faction.judoka, tint: Color(0xFF301518)),
    StoryNpc(id: 'dama_contratos', faction: Faction.capoeira, tint: Color(0xFF2C1830)),
    StoryNpc(id: 'campeon_cristal', faction: Faction.boxer, tint: Color(0xFF203040)),
    // Kuro pelea "a la manera antigua": cinturón negro, tercer dan.
    StoryNpc(id: 'inspectora_kuro', faction: Faction.judoka, tint: Color(0xFF302030)),
    // Vespa: "Boxeador antes que buitre" (briefing de su combate final).
    StoryNpc(id: 'promotor', faction: Faction.boxer, tint: Color(0xFF33231A)),
    StoryNpc(id: 'promotor_vespa', faction: Faction.boxer, tint: Color(0xFF33231A)),
    // El Falsario no es un artista marcial de escuela: pelea como lo que es,
    // una sombra que arma trampas en su propio taller (rival `kage_epic`).
    StoryNpc(id: 'falsario', faction: Faction.ninja, tint: Color(0xFF32261A)),
  ];

  static final Map<String, StoryNpc> _byId = {for (final n in all) n.id: n};

  static StoryNpc? byId(String id) => _byId[id];

  /// Facción del cuerpo base, o null si el id no es un NPC conocido.
  static Faction? factionFor(String id) => _byId[id]?.faction;
}
