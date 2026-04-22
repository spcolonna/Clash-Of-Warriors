// lib/domain/entities/hero_entity.dart

import 'game_card.dart';

enum Faction {
  shaolin,
  ninja,
  judoka,
  boxer,
  capoeira,
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

  /// Daño efectivo de una carta para este héroe
  double effectiveDamage(GameCard card) {
    if (card.baseDamage == null) return 0;
    final statValue = stats.statFor(card.category);
    final multiplier = statValue / 10.0;
    // Cartas del propio héroe tienen +10% sinergia
    final synergyBonus = card.heroId == id ? 1.1 : 1.0;
    return card.baseDamage! * multiplier * synergyBonus;
  }

  /// Stamina recuperada por un esquive para este héroe
  double effectiveDodgeRecovery(GameCard card) {
    assert(card.category == CardCategory.dodge);
    final staminaBonus = card.staminaBonus ?? 0;
    return staminaBonus * (stats.dodge / 10.0);
  }

  HeroEntity copyWith({
    int? stars,
    int? maxHp,
    String? imagePath,
  }) =>
      HeroEntity(
        id: id,
        name: name,
        title: title,
        faction: faction,
        rarity: rarity,
        stats: stats,
        maxHp: maxHp ?? this.maxHp,
        maxStamina: maxStamina,
        passive: passive,
        lore: lore,
        imagePath: imagePath ?? this.imagePath, // <--- Soporte en copyWith
        stars: stars ?? this.stars,
      );
}
