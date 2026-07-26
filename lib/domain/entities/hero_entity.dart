// lib/domain/entities/hero_entity.dart

import 'game_card.dart';

enum Faction {
  shaolin,
  ninja,
  judoka,
  boxer,
  capoeira,
}

/// Convierte el `factionId` (String? guardado en las cartas / Firestore) al
/// enum `Faction`. Retorna null para neutrales o ids desconocidos.
Faction? factionFromId(String? id) => switch (id) {
      'shaolin' => Faction.shaolin,
      'ninja' => Faction.ninja,
      'judoka' => Faction.judoka,
      'boxer' => Faction.boxer,
      'capoeira' => Faction.capoeira,
      _ => null,
    };

/// Rivalidades entre facciones según el lore (La Ciudadela).
/// - Shaolin ↔ Clan ninja (secuestran al Maestro Lin).
/// - Judoka ↔ Boxer (Federación corrupta vs promotores como Vespa).
/// - Capoeira → Clan ninja (Mila busca a Lucas, endeudado con el Clan).
const Map<Faction, Set<Faction>> factionEnemies = {
  Faction.shaolin: {Faction.ninja},
  Faction.ninja: {Faction.shaolin, Faction.capoeira},
  Faction.judoka: {Faction.boxer},
  Faction.boxer: {Faction.judoka},
  Faction.capoeira: {Faction.ninja},
};

/// Relación de una carta con la facción del héroe que la juega.
enum FactionAffinity { none, affinity, rival }

/// Determina si una carta es afín (misma facción del héroe), rival (facción
/// enemiga según el lore) o neutral. Usado tanto por el motor de combate
/// (para el multiplicador de daño) como por la UI (badges y look de la carta).
FactionAffinity factionAffinityFor(Faction heroFaction, String? cardFactionId) {
  final cf = factionFromId(cardFactionId);
  if (cf == null) return FactionAffinity.none;
  if (cf == heroFaction) return FactionAffinity.affinity;
  if (factionEnemies[heroFaction]?.contains(cf) ?? false) {
    return FactionAffinity.rival;
  }
  return FactionAffinity.none;
}

class HeroStats {
  final int punch;   // P
  final int kick;    // K
  final int grapple; // G
  final int defense; // D
  final int dodge;   // E

  const HeroStats({
    required this.punch,
    required this.kick,
    required this.grapple,
    required this.defense,
    required this.dodge,
  });

  int statFor(CardCategory category) => switch (category) {
    CardCategory.punch   => punch,
    CardCategory.kick    => kick,
    CardCategory.grapple => grapple,
    CardCategory.defense => defense,
    CardCategory.dodge   => dodge,
  };

  int get total => punch + kick + grapple + defense + dodge;
}

class HeroEntity {
  final String id;
  final String name;
  final String title;
  final Faction faction;
  final String rarity; // 'common' | 'rare' | 'epic' | 'legendary'
  final HeroStats stats;
  final int maxHp;
  final int maxStamina;
  final GameCard passive;
  final String lore;
  final int stars; // upgrade level 1–5
  final String imagePath; // <--- Nueva propiedad para la ruta de la imagen

  const HeroEntity({
    required this.id,
    required this.name,
    required this.title,
    required this.faction,
    required this.rarity,
    required this.stats,
    required this.maxHp,
    required this.maxStamina,
    required this.passive,
    required this.lore,
    required this.imagePath, // <--- Requerida en el constructor
    this.stars = 1,
  });

  // +1 a cada stat por cada estrella adicional sobre la primera
  static const int _statBonusPerStar = 1;

  int _boostedStat(int base) =>
      base + (stars - 1) * _statBonusPerStar;

  /// Stats ya escaladas por la ascensión (las mismas que usa el combate).
  /// Toda UI que muestre stats debe usar esto y NO `stats` crudo, o va a
  /// mostrar valores de 1★ para un héroe ascendido.
  HeroStats get boostedStats => HeroStats(
        punch: _boostedStat(stats.punch),
        kick: _boostedStat(stats.kick),
        grapple: _boostedStat(stats.grapple),
        defense: _boostedStat(stats.defense),
        dodge: _boostedStat(stats.dodge),
      );

  /// Daño efectivo de una carta para este héroe.
  /// Cada estrella adicional suma +1 al stat relevante.
  double effectiveDamage(GameCard card) {
    if (card.baseDamage == null) return 0;
    final statValue = _boostedStat(stats.statFor(card.category));
    final multiplier = statValue / 10.0;
    // Cartas del propio héroe tienen +10% sinergia
    final synergyBonus = card.heroId == id ? 1.1 : 1.0;
    return card.baseDamage! * multiplier * synergyBonus;
  }

  /// Stamina recuperada por un esquive para este héroe.
  double effectiveDodgeRecovery(GameCard card) {
    assert(card.category == CardCategory.dodge);
    final staminaBonus = card.staminaBonus ?? 0;
    return staminaBonus * (_boostedStat(stats.dodge) / 10.0);
  }

  HeroEntity copyWith({
    int? stars,
    int? maxHp,
    int? maxStamina,
    HeroStats? stats,
    String? imagePath,
  }) =>
      HeroEntity(
        id: id,
        name: name,
        title: title,
        faction: faction,
        rarity: rarity,
        stats: stats ?? this.stats,
        maxHp: maxHp ?? this.maxHp,
        maxStamina: maxStamina ?? this.maxStamina,
        passive: passive,
        lore: lore,
        imagePath: imagePath ?? this.imagePath,
        stars: stars ?? this.stars,
      );
}
