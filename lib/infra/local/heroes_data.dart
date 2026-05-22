import '../../domain/entities/game_card.dart';
import '../../domain/entities/hero_entity.dart';

/// Pasivas de los 5 héroes Common (fuera del mazo, siempre disponibles)
class _Passives {
  static const puoLiu = GameCard(
    id: 'passive_puo_liu',
    name: 'Técnica Antigua',
    lore: 'PUÑO · 22 daño. Se activa al bajar al 40% de HP. Jugala en el slot correcto y el rival no tiene respuesta.',
    category: CardCategory.punch,
    rarity: CardRarity.common,
    staminaCost: 3,
    baseDamage: 22,
    heroId: 'puo_liu',
    factionId: 'shaolin',
  );

  static const kage = GameCard(
    id: 'passive_kage',
    name: 'Golpe en la Sombra',
    lore: 'ESQUIVE · Si gana el slot, inflige 8 de daño al rival durante 2 rounds. Se activa al bajar al 40% de HP.',
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
    lore: 'AGARRE · 36 daño base (el más alto del mazo). Se activa al bajar al 40% de HP. Un solo golpe puede cambiar el round.',
    category: CardCategory.grapple,
    rarity: CardRarity.common,
    staminaCost: 4,
    baseDamage: 36, // daño base alto — el doble del agarre más fuerte
    heroId: 'ryoto',
    factionId: 'judoka',
  );

  static const kai = GameCard(
    id: 'passive_kai',
    name: 'Uppercut Devastador',
    lore: 'PUÑO · 34 daño base. Se activa al bajar al 40% de HP. El golpe más poderoso de Kai, reservado para el momento crítico.',
    category: CardCategory.punch,
    rarity: CardRarity.common,
    staminaCost: 4,
    baseDamage: 34,
    heroId: 'kai',
    factionId: 'boxer',
  );

  static const mila = GameCard(
    id: 'passive_mila',
    name: 'Rasteira del Destino',
    lore: 'PATADA · Si gana el slot, bloquea el slot 0 del rival el próximo round. Se activa al bajar al 40% de HP.',
    category: CardCategory.kick,
    rarity: CardRarity.common,
    staminaCost: 4,
    baseDamage: 22,
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
    baseDamage: 22,
    factionId: 'shaolin',
  );

  static const ninjaCard = GameCard(
    id: 'ninja_shadow_kick',
    name: 'Patada Sombra',
    lore: 'La sombra siempre llega antes que el que la proyecta. Esta patada es la sombra del Ninja.',
    category: CardCategory.kick,
    rarity: CardRarity.common,
    staminaCost: 2,
    baseDamage: 22,
    factionId: 'ninja',
  );

  static const judokaCard = GameCard(
    id: 'judoka_basic_projection',
    name: 'Proyección Básica',
    lore: 'Usa el impulso del oponente en su contra. Si empuja, jalás. Si jala, empujás.',
    category: CardCategory.grapple,
    rarity: CardRarity.common,
    staminaCost: 2,
    baseDamage: 20,
    factionId: 'judoka',
  );

  static const boxerCard = GameCard(
    id: 'boxer_barrio_cross',
    name: 'Cruzado de Barrio',
    lore: 'Sin guardia, sin ritual. Solo el brazo derecho, toda la cadera, y que duela.',
    category: CardCategory.punch,
    rarity: CardRarity.common,
    staminaCost: 2,
    baseDamage: 22,
    factionId: 'boxer',
  );

  static const capoeiraCard = GameCard(
    id: 'capoeira_meia_lua',
    name: 'Meia Lua',
    lore: 'Media luna. El pie traza un arco de un extremo al otro. Si te llega, te lleva.',
    category: CardCategory.kick,
    rarity: CardRarity.common,
    staminaCost: 2,
    baseDamage: 22,
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

  static GameCard? findById(String id) => switch (id) {
    'shaolin_five_beasts'     => shaolinCard,
    'ninja_shadow_kick'       => ninjaCard,
    'judoka_basic_projection' => judokaCard,
    'boxer_barrio_cross'      => boxerCard,
    'capoeira_meia_lua'       => capoeiraCard,
    _ => null,
  };
}

// ── Pasivas de raridades superiores ──────────────────────────────────────────
// Misma mecánica que las common pero con daño escalado.
class _RarityPassives {
  // Rare (+15% dmg sobre common)
  static const puoLiuRare  = GameCard(id: 'passive_puo_liu_rare',  name: 'Técnica Antigua II',      lore: 'PUÑO · 25 daño. Velocidad mejorada tras el descenso de la montaña.',  category: CardCategory.punch,  rarity: CardRarity.rare,      staminaCost: 3, baseDamage: 25, heroId: 'puo_liu_rare',  factionId: 'shaolin');
  static const kageRare    = GameCard(id: 'passive_kage_rare',    name: 'Sombra Doble',            lore: 'ESQUIVE · Inflige 10 dmg al rival durante 2 rounds al bajar al 40% HP.', category: CardCategory.dodge,  rarity: CardRarity.rare,      staminaCost: 3, staminaBonus: 0, heroId: 'kage_rare',    factionId: 'ninja');
  static const ryotoRare   = GameCard(id: 'passive_ryoto_rare',   name: 'Ippon Perfecto',          lore: 'AGARRE · 41 daño base. La técnica se refina con cada año de tatami.',   category: CardCategory.grapple, rarity: CardRarity.rare,     staminaCost: 4, baseDamage: 41, heroId: 'ryoto_rare',   factionId: 'judoka');
  static const kaiRare     = GameCard(id: 'passive_kai_rare',     name: 'Uppercut de Barrio',      lore: 'PUÑO · 39 daño base. Forjado en las peleas de garaje del Barrio Sur.',  category: CardCategory.punch,  rarity: CardRarity.rare,      staminaCost: 4, baseDamage: 39, heroId: 'kai_rare',     factionId: 'boxer');
  static const milaRare    = GameCard(id: 'passive_mila_rare',    name: 'Rasteira Perfecta',       lore: 'PATADA · 25 dmg y bloquea slot 0 rival el próximo round al 40% HP.',    category: CardCategory.kick,   rarity: CardRarity.rare,      staminaCost: 4, baseDamage: 25, heroId: 'mila_rare',    factionId: 'capoeira');

  // Epic (+30% dmg sobre common)
  static const puoLiuEpic  = GameCard(id: 'passive_puo_liu_epic',  name: 'Técnica Antigua III',     lore: 'PUÑO · 29 daño. Maestría que pocos logran en la Montaña Sagrada.',      category: CardCategory.punch,  rarity: CardRarity.epic,      staminaCost: 3, baseDamage: 29, heroId: 'puo_liu_epic',  factionId: 'shaolin');
  static const kageEpic    = GameCard(id: 'passive_kage_epic',    name: 'Sombra sin Forma',        lore: 'ESQUIVE · Inflige 13 dmg al rival durante 2 rounds al bajar al 40% HP.', category: CardCategory.dodge,  rarity: CardRarity.epic,      staminaCost: 3, staminaBonus: 0, heroId: 'kage_epic',    factionId: 'ninja');
  static const ryotoEpic   = GameCard(id: 'passive_ryoto_epic',   name: 'Gran Ippon',              lore: 'AGARRE · 47 daño base. La culminación de doce años en el tatami.',      category: CardCategory.grapple, rarity: CardRarity.epic,     staminaCost: 4, baseDamage: 47, heroId: 'ryoto_epic',   factionId: 'judoka');
  static const kaiEpic     = GameCard(id: 'passive_kai_epic',     name: 'Golpe del Campeón',       lore: 'PUÑO · 44 daño base. El golpe que calló a todos los que dudaron de él.', category: CardCategory.punch,  rarity: CardRarity.epic,      staminaCost: 4, baseDamage: 44, heroId: 'kai_epic',     factionId: 'boxer');
  static const milaEpic    = GameCard(id: 'passive_mila_epic',    name: 'Danza del Caos',          lore: 'PATADA · 29 dmg y bloquea slot 0 rival el próximo round al 40% HP.',    category: CardCategory.kick,   rarity: CardRarity.epic,      staminaCost: 4, baseDamage: 29, heroId: 'mila_epic',    factionId: 'capoeira');

  // Legendary (+50% dmg sobre common)
  static const puoLiuLeg   = GameCard(id: 'passive_puo_liu_leg',  name: 'Técnica del Dragón',      lore: 'PUÑO · 33 daño. La técnica que el Maestro Lin esperaba ver en vida.',    category: CardCategory.punch,  rarity: CardRarity.legendary, staminaCost: 3, baseDamage: 33, heroId: 'puo_liu_legendary', factionId: 'shaolin');
  static const kageLeg     = GameCard(id: 'passive_kage_leg',     name: 'Vacío',                   lore: 'ESQUIVE · Inflige 15 dmg al rival durante 2 rounds al bajar al 40% HP.', category: CardCategory.dodge,  rarity: CardRarity.legendary, staminaCost: 3, staminaBonus: 0, heroId: 'kage_legendary', factionId: 'ninja');
  static const ryotoLeg    = GameCard(id: 'passive_ryoto_leg',    name: 'Ippon Legendario',        lore: 'AGARRE · 54 daño base. La técnica que restauró el honor del Dojo Mushin.', category: CardCategory.grapple, rarity: CardRarity.legendary, staminaCost: 4, baseDamage: 54, heroId: 'ryoto_legendary', factionId: 'judoka');
  static const kaiLeg      = GameCard(id: 'passive_kai_leg',      name: 'El Golpe del Barrio Sur', lore: 'PUÑO · 51 daño base. El golpe que salvó al gimnasio y cambió La Ciudadela.', category: CardCategory.punch, rarity: CardRarity.legendary, staminaCost: 4, baseDamage: 51, heroId: 'kai_legendary',  factionId: 'boxer');
  static const milaLeg     = GameCard(id: 'passive_mila_leg',     name: 'La Danza Sin Fin',        lore: 'PATADA · 33 dmg y bloquea slot 0 rival el próximo round al 40% HP.',    category: CardCategory.kick,   rarity: CardRarity.legendary, staminaCost: 4, baseDamage: 33, heroId: 'mila_legendary', factionId: 'capoeira');
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

  // ── Héroes de raridades superiores (recompensa del modo historia) ──────────
  // imagePath reutiliza las imágenes common como placeholder hasta que existan
  // los assets de rareza superior. Estadísticas: +10% rare, +21% epic, +33% legendary
  // (floor, cap 10 por stat). HP y Stamina sin cap.
  static final List<HeroEntity> rarityHeroes = [
    // ── Puo Liu ──────────────────────────────────────────────────────────────
    HeroEntity(id: 'puo_liu_rare',      name: 'Puo Liu', title: 'El Discípulo',       faction: Faction.shaolin,  rarity: 'rare',      stats: const HeroStats(punch: 7, kick: 6, grapple: 4, defense: 7, dodge: 6),  maxHp: 88,  maxStamina: 11, passive: _RarityPassives.puoLiuRare, lore: 'Ya no tiemblan sus manos. El descenso de la montaña le enseñó más que doce años de entrenamiento.',          imagePath: 'assets/images/heros/shaolin_common.png'),
    HeroEntity(id: 'puo_liu_epic',      name: 'Puo Liu', title: 'El Guardián',        faction: Faction.shaolin,  rarity: 'epic',      stats: const HeroStats(punch: 8, kick: 7, grapple: 5, defense: 8, dodge: 7),  maxHp: 97,  maxStamina: 12, passive: _RarityPassives.puoLiuEpic, lore: 'Expuso al Consejo Sombra ante toda La Ciudadela. Ahora es el guardián del legado Shaolin.',                  imagePath: 'assets/images/heros/shaolin_common.png'),
    HeroEntity(id: 'puo_liu_legendary', name: 'Puo Liu', title: 'Maestro del Dragón', faction: Faction.shaolin,  rarity: 'legendary', stats: const HeroStats(punch: 9, kick: 8, grapple: 5, defense: 9, dodge: 8),  maxHp: 106, maxStamina: 13, passive: _RarityPassives.puoLiuLeg,  lore: 'El Maestro Lin dijo que llegaría este día. Puo Liu lo corrigió: ese día ya pasó.',                          imagePath: 'assets/images/heros/shaolin_common.png'),
    // ── Kage ─────────────────────────────────────────────────────────────────
    HeroEntity(id: 'kage_rare',         name: 'Kage',    title: 'El Desertor',        faction: Faction.ninja,    rarity: 'rare',      stats: const HeroStats(punch: 5, kick: 7, grapple: 2, defense: 6, dodge: 10), maxHp: 79,  maxStamina: 13, passive: _RarityPassives.kageRare,   lore: 'Abandonó el Clan. Sobrevivió. Eso es suficiente para saber que tomó la decisión correcta.',               imagePath: 'assets/images/heros/ninja_common.png'),
    HeroEntity(id: 'kage_epic',         name: 'Kage',    title: 'La Sombra Libre',    faction: Faction.ninja,    rarity: 'epic',      stats: const HeroStats(punch: 6, kick: 8, grapple: 2, defense: 7, dodge: 10), maxHp: 87,  maxStamina: 14, passive: _RarityPassives.kageEpic,   lore: 'Ya no tiene clan. Tiene algo mejor: una razón propia.',                                                     imagePath: 'assets/images/heros/ninja_common.png'),
    HeroEntity(id: 'kage_legendary',    name: 'Kage',    title: 'La Sombra',          faction: Faction.ninja,    rarity: 'legendary', stats: const HeroStats(punch: 6, kick: 9, grapple: 3, defense: 8, dodge: 10), maxHp: 95,  maxStamina: 16, passive: _RarityPassives.kageLeg,    lore: 'Kage. Solo un nombre. Pero ahora toda La Ciudadela lo conoce.',                                             imagePath: 'assets/images/heros/ninja_common.png'),
    // ── Ryoto ────────────────────────────────────────────────────────────────
    HeroEntity(id: 'ryoto_rare',        name: 'Ryoto',   title: 'El Reivindicado',    faction: Faction.judoka,   rarity: 'rare',      stats: const HeroStats(punch: 3, kick: 5, grapple: 9, defense: 9, dodge: 4),  maxHp: 93,  maxStamina:  9, passive: _RarityPassives.ryotoRare,  lore: 'El expediente del Sensei Hiroshi fue restablecido. El dojo tiene su nombre de vuelta.',                    imagePath: 'assets/images/heros/judo_common.png'),
    HeroEntity(id: 'ryoto_epic',        name: 'Ryoto',   title: 'El Incorruptible',   faction: Faction.judoka,   rarity: 'epic',      stats: const HeroStats(punch: 4, kick: 6, grapple: 10, defense: 10, dodge: 5), maxHp: 102, maxStamina: 10, passive: _RarityPassives.ryotoEpic,  lore: 'Doce años en el tatami. No ha perdido desde entonces. No va a empezar ahora.',                              imagePath: 'assets/images/heros/judo_common.png'),
    HeroEntity(id: 'ryoto_legendary',   name: 'Ryoto',   title: 'Sensei',             faction: Faction.judoka,   rarity: 'legendary', stats: const HeroStats(punch: 4, kick: 7, grapple: 10, defense: 10, dodge: 5), maxHp: 113, maxStamina: 12, passive: _RarityPassives.ryotoLeg,   lore: 'El sensei que nunca debió dejar de serlo. Ahora enseña lo que aprendió al precio más alto.',                imagePath: 'assets/images/heros/judo_common.png'),
    // ── Kai ──────────────────────────────────────────────────────────────────
    HeroEntity(id: 'kai_rare',          name: 'Kai',     title: 'El Peleador',        faction: Faction.boxer,    rarity: 'rare',      stats: const HeroStats(punch: 8, kick: 3, grapple: 4, defense: 8, dodge: 7),  maxHp: 88,  maxStamina: 11, passive: _RarityPassives.kaiRare,    lore: 'El gimnasio sigue en pie. El barrio lo sabe. Y los que dudaron también.',                                   imagePath: 'assets/images/heros/boxer_common.png'),
    HeroEntity(id: 'kai_epic',          name: 'Kai',     title: 'El Campeón',         faction: Faction.boxer,    rarity: 'epic',      stats: const HeroStats(punch: 9, kick: 4, grapple: 5, defense: 9, dodge: 8),  maxHp: 96,  maxStamina: 12, passive: _RarityPassives.kaiEpic,    lore: 'Ganó el torneo. Sin trampas, sin sobornos. Como siempre debió haber sido.',                                 imagePath: 'assets/images/heros/boxer_common.png'),
    HeroEntity(id: 'kai_legendary',     name: 'Kai',     title: 'La Leyenda del Sur', faction: Faction.boxer,    rarity: 'legendary', stats: const HeroStats(punch: 10, kick: 4, grapple: 5, defense: 10, dodge: 9), maxHp: 106, maxStamina: 13, passive: _RarityPassives.kaiLeg,     lore: 'En el Barrio Sur dicen que Kai nunca existió. Que fue un sueño. Un sueño que ganó el torneo.',              imagePath: 'assets/images/heros/boxer_common.png'),
    // ── Mila ─────────────────────────────────────────────────────────────────
    HeroEntity(id: 'mila_rare',         name: 'Mila',    title: 'La Buscadora',       faction: Faction.capoeira, rarity: 'rare',      stats: const HeroStats(punch: 5, kick: 9, grapple: 2, defense: 5, dodge: 9),  maxHp: 82,  maxStamina: 12, passive: _RarityPassives.milaRare,   lore: 'Encontró a Lucas. La deuda fue cancelada. Ahora La Ciudadela entera es su tatami.',                        imagePath: 'assets/images/heros/capoeira_common.png'),
    HeroEntity(id: 'mila_epic',         name: 'Mila',    title: 'La Danzante Libre',  faction: Faction.capoeira, rarity: 'epic',      stats: const HeroStats(punch: 6, kick: 10, grapple: 2, defense: 6, dodge: 10), maxHp: 90,  maxStamina: 13, passive: _RarityPassives.milaEpic,   lore: 'La gente que la ve danzar ya sabe que están en combate. Y lo disfrutan igual.',                             imagePath: 'assets/images/heros/capoeira_common.png'),
    HeroEntity(id: 'mila_legendary',    name: 'Mila',    title: 'La Libre',           faction: Faction.capoeira, rarity: 'legendary', stats: const HeroStats(punch: 6, kick: 10, grapple: 3, defense: 7, dodge: 10), maxHp: 99,  maxStamina: 16, passive: _RarityPassives.milaLeg,    lore: 'En la Capoeira no hay derrota. Solo pausas. Mila nunca hace pausas.',                                       imagePath: 'assets/images/heros/capoeira_common.png'),
  ];

  static List<HeroEntity> get allHeroes => [...starterHeroes, ...rarityHeroes];

  /// Busca en starter + rarity. Lanza si no encuentra.
  static HeroEntity findById(String id) =>
      allHeroes.firstWhere((h) => h.id == id,
          orElse: () => throw ArgumentError('Hero not found: $id'));

  /// Versión null-safe para código de historia donde el id puede ser inválido.
  static HeroEntity? findByIdSafe(String id) =>
      allHeroes.where((h) => h.id == id).firstOrNull;

  /// Aplica las stats de Firestore sobre los héroes hardcodeados.
  /// Llamado al cargar gameConfigProvider en startup.
  /// Solo toca starterHeroes — las raridades superiores no tienen overrides en Firestore.
  static void applyOverrides(List<Map<String, dynamic>> firestoreHeroes) {
    for (int i = 0; i < starterHeroes.length; i++) {
      final data = firestoreHeroes.where((h) => h['id'] == starterHeroes[i].id).firstOrNull;
      if (data == null) continue;

      final rawStats = data['stats'] as Map<String, dynamic>?;
      final newStats = rawStats != null
          ? HeroStats(
              punch:   rawStats['punch']   as int? ?? starterHeroes[i].stats.punch,
              kick:    rawStats['kick']    as int? ?? starterHeroes[i].stats.kick,
              grapple: rawStats['grapple'] as int? ?? starterHeroes[i].stats.grapple,
              defense: rawStats['defense'] as int? ?? starterHeroes[i].stats.defense,
              dodge:   rawStats['dodge']   as int? ?? starterHeroes[i].stats.dodge,
            )
          : null;

      starterHeroes[i] = starterHeroes[i].copyWith(
        maxHp:      data['maxHp']      as int?,
        maxStamina: data['maxStamina'] as int?,
        stats:      newStats,
      );
    }
  }

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
      print('[HeroesData] tutorialBotFor: factionId desconocido → "$factionId"');
      return starterHeroes.first;
    }

    return findById(rivalId);
  }
}
