import '../../domain/entities/game_card.dart';
import '../../domain/entities/hero_entity.dart';

/// Pasivas de los 5 héroes Common (fuera del mazo, siempre disponibles)
class _Passives {
  static const puoLiu = GameCard(
    id: 'passive_puo_liu',
    name: 'Técnica Antigua',
    lore: 'No hay defensa contra una técnica que tiene mil años de perfección.',
    category: CardCategory.punch,
    rarity: CardRarity.common,
    staminaCost: 3,
    baseDamage: 14,
    heroId: 'puo_liu',
    factionId: 'shaolin',
  );

  static const kage = GameCard(
    id: 'passive_kage',
    name: 'Golpe en la Sombra',
    lore: 'La sombra no recibe el golpe. Lo devuelve.',
    category: CardCategory.dodge,
    rarity: CardRarity.common,
    staminaCost: 3,
    staminaBonus: 0,
    heroId: 'kage',
    factionId: 'ninja',
  );

  static const ryoto = GameCard(
    id: 'passive_ryoto',
    name: 'Ippon',
    lore: 'Un punto. El combate termina. No hay réplica, no hay segunda oportunidad.',
    category: CardCategory.grapple,
    rarity: CardRarity.common,
    staminaCost: 4,
    baseDamage: 24, // daño base × 2 — el doble del agarre más fuerte
    heroId: 'ryoto',
    factionId: 'judoka',
  );

  static const kai = GameCard(
    id: 'passive_kai',
    name: 'Uppercut Devastador',
    lore: 'Kai no inventó el uppercut. Pero lo hace como si lo hubiera hecho.',
    category: CardCategory.punch,
    rarity: CardRarity.common,
    staminaCost: 4,
    baseDamage: 22,
    heroId: 'kai',
    factionId: 'boxer',
  );

  static const mila = GameCard(
    id: 'passive_mila',
    name: 'Rasteira del Destino',
    lore: 'No solo cae. Además, no puede levantarse a tiempo para el siguiente golpe.',
    category: CardCategory.kick,
    rarity: CardRarity.common,
    staminaCost: 4,
    baseDamage: 14,
    heroId: 'mila',
    factionId: 'capoeira',
  );
}

/// Primera carta de facción que se desbloquea en la home obligatoria
class FactionStarterCards {
  static const shaolinCard = GameCard(
    id: 'shaolin_five_beasts',
    name: 'Golpe de las Cinco Bestias',
    lore: 'El estilo Shaolin imita a cinco animales. Este golpe los invoca todos en un único movimiento.',
    category: CardCategory.punch,
    rarity: CardRarity.common,
    staminaCost: 2,
    baseDamage: 14,
    factionId: 'shaolin',
  );

  static const ninjaCard = GameCard(
    id: 'ninja_shadow_kick',
    name: 'Patada Sombra',
    lore: 'La sombra siempre llega antes que el que la proyecta. Esta patada es la sombra del Ninja.',
    category: CardCategory.kick,
    rarity: CardRarity.common,
    staminaCost: 2,
    baseDamage: 14,
    factionId: 'ninja',
  );

  static const judokaCard = GameCard(
    id: 'judoka_basic_projection',
    name: 'Proyección Básica',
    lore: 'Usa el impulso del oponente en su contra. Si empuja, jalás. Si jala, empujás.',
    category: CardCategory.grapple,
    rarity: CardRarity.common,
    staminaCost: 2,
    baseDamage: 12,
    factionId: 'judoka',
  );

  static const boxerCard = GameCard(
    id: 'boxer_barrio_cross',
    name: 'Cruzado de Barrio',
    lore: 'Sin guardia, sin ritual. Solo el brazo derecho, toda la cadera, y que duela.',
    category: CardCategory.punch,
    rarity: CardRarity.common,
    staminaCost: 2,
    baseDamage: 14,
    factionId: 'boxer',
  );

  static const capoeiraCard = GameCard(
    id: 'capoeira_meia_lua',
    name: 'Meia Lua',
    lore: 'Media luna. El pie traza un arco de un extremo al otro. Si te llega, te lleva.',
    category: CardCategory.kick,
    rarity: CardRarity.common,
    staminaCost: 2,
    baseDamage: 14,
    factionId: 'capoeira',
  );

  static GameCard forFaction(String factionId) => switch (factionId) {
    'shaolin'  => shaolinCard,
    'ninja'    => ninjaCard,
    'judoka'   => judokaCard,
    'boxer'    => boxerCard,
    'capoeira' => capoeiraCard,
    _          => throw ArgumentError('Unknown factionId: $factionId'),
  };

  static int costFor(String factionId) => 80; // todas cuestan 80 soft coins
}

/// Los 5 héroes Common del lanzamiento
class HeroesData {
  static final List<HeroEntity> starterHeroes = [
    HeroEntity(
      id: 'puo_liu',
      name: 'Puo Liu',
      title: 'El Estudiante',
      faction: Faction.shaolin,
      rarity: 'common',
      stats: const HeroStats(punch: 7, kick: 6, grapple: 4, defense: 7, dodge: 6),
      maxHp: 80,
      maxStamina: 10,
      passive: _Passives.puoLiu,
      lore: 'El más joven en bajar de la Montaña Sagrada. Aún le tiemblan las manos antes de cada batalla. Pero los maestros dicen que ese temblor desaparecerá pronto.',
      imagePath: 'assets/images/heros/shaolin_common.png'
    ),
    HeroEntity(
      id: 'kage',
      name: 'Kage',
      title: 'El Iniciado',
      faction: Faction.ninja,
      rarity: 'common',
      stats: const HeroStats(punch: 5, kick: 7, grapple: 2, defense: 6, dodge: 10),
      maxHp: 72,
      maxStamina: 12,
      passive: _Passives.kage,
      lore: 'Nadie sabe su nombre real. Kage significa "sombra" en el idioma del Clan. Es todo lo que necesitás saber.',
      imagePath: 'assets/images/heros/ninja_common.png'
    ),
    HeroEntity(
      id: 'ryoto',
      name: 'Ryoto',
      title: 'El Estudiante del Tatami',
      faction: Faction.judoka,
      rarity: 'common',
      stats: const HeroStats(punch: 3, kick: 5, grapple: 9, defense: 9, dodge: 4),
      maxHp: 85,
      maxStamina: 9,
      passive: _Passives.ryoto,
      lore: 'Lleva doce años en el tatami. Perdió los primeros tres. No ha perdido desde entonces.',
      imagePath: 'assets/images/heros/judo_common.png'
    ),
    HeroEntity(
      id: 'kai',
      name: 'Kai',
      title: 'El Novato del Cemento',
      faction: Faction.boxer,
      rarity: 'common',
      stats: const HeroStats(punch: 8, kick: 3, grapple: 4, defense: 8, dodge: 7),
      maxHp: 80,
      maxStamina: 10,
      passive: _Passives.kai,
      lore: 'Kai aprendió a pelear antes de aprender a leer. En los garajes donde creció, la teoría era un lujo que nadie tenía.',
      imagePath: 'assets/images/heros/boxer_common.png'
    ),
    HeroEntity(
      id: 'mila',
      name: 'Mila',
      title: 'La Libre',
      faction: Faction.capoeira,
      rarity: 'common',
      stats: const HeroStats(punch: 5, kick: 9, grapple: 2, defense: 5, dodge: 9),
      maxHp: 75,
      maxStamina: 11,
      passive: _Passives.mila,
      lore: 'Mila danza. La gente que la ve danzar no entiende que ya están en combate.',
      imagePath: 'assets/images/heros/capoeira_common.png'
    ),
  ];

  static HeroEntity findById(String id) =>
      starterHeroes.firstWhere((h) => h.id == id);

  static HeroEntity findByFaction(Faction faction) =>
      starterHeroes.firstWhere((h) => h.faction == faction);

  /// El bot tutorial es el rival histórico — siempre vencible
  static HeroEntity tutorialBotFor(String factionId) {
    final rivalMap = {
      'shaolin':  'kage',
      'ninja':    'puo_liu',
      'judoka':   'kai',
      'boxer':    'ryoto',
      'capoeira': 'puo_liu',
    };

    final normalized = factionId.toLowerCase().trim();
    final rivalId = rivalMap[normalized];

    if (rivalId == null) {
      // Fallback seguro + log para saber qué llegó
      print('[HeroesData] tutorialBotFor: factionId desconocido → "$factionId"');
      return starterHeroes.first;
    }

    return findById(rivalId);
  }
}
