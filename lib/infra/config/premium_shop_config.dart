// lib/infra/config/premium_shop_config.dart
//
// Configuración de la Tienda Premium (compras con dinero real en USD).
// Fuente única de verdad para bundles, packs de tokens y héroes.
//
// ── MIGRACIÓN A FIREBASE ────────────────────────────────────────────────────
// Para llevar esto a Firebase, seguir estos pasos:
//   1. Crear colecciones en Firestore:
//      • premium_shop/bundles        (lista de PremiumBundle)
//      • premium_shop/token_packs    (lista de TokenPack)
//      • premium_shop/hero_offers    (lista de HeroOffer)
//   2. Serializar con los métodos toMap() ya implementados para subir los datos.
//   3. Leer con fromMap() en el repositorio remoto.
//   4. Reemplazar PremiumShopConfig.bundles / .tokenPacks / .heroOffers
//      por llamadas asíncronas al repositorio de Firestore.
//   5. Los productos IAP del store (App Store / Play Store) deben tener IDs
//      que coincidan con el campo `storeProductId` de cada item.
// ────────────────────────────────────────────────────────────────────────────

/// Un bundle legendario: incluye un héroe, cartas y tokens.
class PremiumBundle {
  final String id;
  final String storeProductId; // ID del producto en App Store / Play Store
  final String name;
  final String description;
  final String heroId;          // ID del GameHero incluido
  final String heroName;        // Nombre visible del héroe
  final List<String> cardIds;   // IDs de cartas incluidas
  final int cardCount;          // Cantidad de cartas (visible al usuario)
  final int tokenAmount;
  final double priceUsd;
  final bool isHighlighted;     // Borde/badge especial de "más popular"
  final String? badgeText;      // e.g. "MÁS POPULAR", "ÉPICO"
  final int heroGradientStart;  // Color hex para gradiente de la card
  final int heroGradientEnd;
  final bool isEnabled;         // Toggle desde el admin (premium_shop/bundles)

  const PremiumBundle({
    required this.id,
    required this.storeProductId,
    required this.name,
    required this.description,
    required this.heroId,
    required this.heroName,
    required this.cardIds,
    required this.cardCount,
    required this.tokenAmount,
    required this.priceUsd,
    this.isHighlighted = false,
    this.badgeText,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'storeProductId': storeProductId,
        'name': name,
        'description': description,
        'heroId': heroId,
        'heroName': heroName,
        'cardIds': cardIds,
        'cardCount': cardCount,
        'tokenAmount': tokenAmount,
        'priceUsd': priceUsd,
        'isHighlighted': isHighlighted,
        'badgeText': badgeText,
        'heroGradientStart': heroGradientStart,
        'heroGradientEnd': heroGradientEnd,
        'isEnabled': isEnabled,
      };

  factory PremiumBundle.fromMap(Map<String, dynamic> map) => PremiumBundle(
        id: map['id'] as String,
        storeProductId: map['storeProductId'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        heroId: map['heroId'] as String,
        heroName: map['heroName'] as String,
        cardIds: List<String>.from(map['cardIds'] as List),
        cardCount: map['cardCount'] as int,
        tokenAmount: map['tokenAmount'] as int,
        priceUsd: (map['priceUsd'] as num).toDouble(),
        isHighlighted: map['isHighlighted'] as bool? ?? false,
        badgeText: map['badgeText'] as String?,
        heroGradientStart: map['heroGradientStart'] as int,
        heroGradientEnd: map['heroGradientEnd'] as int,
        isEnabled: map['isEnabled'] as bool? ?? true,
      );
}

/// Pack de tokens para comprar con dinero real.
class TokenPack {
  final String id;
  final String storeProductId;
  final String name;
  final int tokenAmount;
  final int bonusTokens;   // Tokens extra de bonificación
  final double priceUsd;
  final String icon;       // Emoji del pack
  final String? badgeText; // e.g. "MEJOR VALOR", "POPULAR"
  final bool isEnabled;    // Toggle desde el admin (premium_shop/token_packs)

  const TokenPack({
    required this.id,
    required this.storeProductId,
    required this.name,
    required this.tokenAmount,
    required this.bonusTokens,
    required this.priceUsd,
    required this.icon,
    this.badgeText,
    this.isEnabled = true,
  });

  int get totalTokens => tokenAmount + bonusTokens;

  Map<String, dynamic> toMap() => {
        'id': id,
        'storeProductId': storeProductId,
        'name': name,
        'tokenAmount': tokenAmount,
        'bonusTokens': bonusTokens,
        'priceUsd': priceUsd,
        'icon': icon,
        'badgeText': badgeText,
        'isEnabled': isEnabled,
      };

  factory TokenPack.fromMap(Map<String, dynamic> map) => TokenPack(
        id: map['id'] as String,
        storeProductId: map['storeProductId'] as String,
        name: map['name'] as String,
        tokenAmount: map['tokenAmount'] as int,
        bonusTokens: map['bonusTokens'] as int? ?? 0,
        priceUsd: (map['priceUsd'] as num).toDouble(),
        icon: map['icon'] as String,
        badgeText: map['badgeText'] as String?,
        isEnabled: map['isEnabled'] as bool? ?? true,
      );
}

/// Héroe individual disponible para comprar.
class HeroOffer {
  final String id;
  final String storeProductId;
  final String heroId;
  final String name;
  final String description;
  final HeroRarity rarity;
  final double priceUsd;
  final bool isNew;
  final bool isFeatured;
  final int gradientStart; // Color hex para gradiente de la card
  final int gradientEnd;
  final bool isEnabled;    // Toggle desde el admin (premium_shop/hero_offers)

  const HeroOffer({
    required this.id,
    required this.storeProductId,
    required this.heroId,
    required this.name,
    required this.description,
    required this.rarity,
    required this.priceUsd,
    this.isNew = false,
    this.isFeatured = false,
    required this.gradientStart,
    required this.gradientEnd,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'storeProductId': storeProductId,
        'heroId': heroId,
        'name': name,
        'description': description,
        'rarity': rarity.name,
        'priceUsd': priceUsd,
        'isNew': isNew,
        'isFeatured': isFeatured,
        'gradientStart': gradientStart,
        'gradientEnd': gradientEnd,
        'isEnabled': isEnabled,
      };

  factory HeroOffer.fromMap(Map<String, dynamic> map) => HeroOffer(
        id: map['id'] as String,
        storeProductId: map['storeProductId'] as String,
        heroId: map['heroId'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        rarity: HeroRarity.values.firstWhere(
          (r) => r.name == map['rarity'],
          orElse: () => HeroRarity.rare,
        ),
        priceUsd: (map['priceUsd'] as num).toDouble(),
        isNew: map['isNew'] as bool? ?? false,
        isFeatured: map['isFeatured'] as bool? ?? false,
        gradientStart: map['gradientStart'] as int,
        gradientEnd: map['gradientEnd'] as int,
        isEnabled: map['isEnabled'] as bool? ?? true,
      );
}

enum HeroRarity {
  rare,
  epic,
  legendary;

  String get label => switch (this) {
        HeroRarity.rare => 'RARO',
        HeroRarity.epic => 'ÉPICO',
        HeroRarity.legendary => 'LEGENDARIO',
      };

  int get colorHex => switch (this) {
        HeroRarity.rare => 0xFF1565C0,
        HeroRarity.epic => 0xFF6A1B9A,
        HeroRarity.legendary => 0xFFE65100,
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// DATOS DE LA TIENDA PREMIUM
// Modificar aquí para cambiar ofertas, precios o agregar nuevos items.
// Cuando se migre a Firebase, estos valores irán a Firestore y se leerán
// de forma remota, permitiendo actualizaciones sin publicar nueva versión.
// ═══════════════════════════════════════════════════════════════════════════
class PremiumShopConfig {
  // ── BUNDLES ──────────────────────────────────────────────────────────────
  // Bundles reales: héroe rare de cada facción + cartas de esa facción +
  // tokens. Los bundles de héroes que aún no existen en el juego quedan
  // isEnabled: false hasta que se habiliten desde el admin.
  static const List<PremiumBundle> bundles = [
    PremiumBundle(
      id: 'bundle_shaolin_rare',
      storeProductId: 'com.clashofwarriors.bundle.shaolin_rare',
      name: 'Pack del Discípulo',
      description: 'Puo Liu ascendido + 3 cartas Shaolin + 600 tokens',
      heroId: 'puo_liu_rare',
      heroName: 'Puo Liu · El Discípulo',
      cardIds: ['shaolin_tiger_claw', 'shaolin_meditation', 'shaolin_crane_wing'],
      cardCount: 3,
      tokenAmount: 600,
      priceUsd: 4.99,
      isHighlighted: true,
      badgeText: 'MÁS POPULAR',
      heroGradientStart: 0xFFD4A017,
      heroGradientEnd: 0xFF3E2A00,
    ),
    PremiumBundle(
      id: 'bundle_ninja_rare',
      storeProductId: 'com.clashofwarriors.bundle.ninja_rare',
      name: 'Pack del Desertor',
      description: 'Kage ascendido + 3 cartas Ninja + 600 tokens',
      heroId: 'kage_rare',
      heroName: 'Kage · El Desertor',
      cardIds: ['ninja_shadow_kick', 'ninja_pressure_strike', 'ninja_smoke_step'],
      cardCount: 3,
      tokenAmount: 600,
      priceUsd: 4.99,
      heroGradientStart: 0xFF7B68EE,
      heroGradientEnd: 0xFF1A1A2E,
    ),
    PremiumBundle(
      id: 'bundle_judoka_rare',
      storeProductId: 'com.clashofwarriors.bundle.judoka_rare',
      name: 'Pack del Reivindicado',
      description: 'Ryoto ascendido + 3 cartas + 600 tokens',
      heroId: 'ryoto_rare',
      heroName: 'Ryoto · El Reivindicado',
      cardIds: ['judoka_shoulder_throw', 'judoka_pin_control', 'judoka_immobilize'],
      cardCount: 3,
      tokenAmount: 600,
      priceUsd: 4.99,
      heroGradientStart: 0xFF1A5276,
      heroGradientEnd: 0xFF081826,
    ),
    PremiumBundle(
      id: 'bundle_boxer_rare',
      storeProductId: 'com.clashofwarriors.bundle.boxer_rare',
      name: 'Pack del Peleador',
      description: 'Kai ascendido + 3 cartas + 600 tokens',
      heroId: 'kai_rare',
      heroName: 'Kai · El Peleador',
      cardIds: ['boxer_barrio_cross', 'boxer_second_wind', 'neutral_punch_strong'],
      cardCount: 3,
      tokenAmount: 600,
      priceUsd: 4.99,
      heroGradientStart: 0xFFC0392B,
      heroGradientEnd: 0xFF2A0703,
    ),
    PremiumBundle(
      id: 'bundle_capoeira_rare',
      storeProductId: 'com.clashofwarriors.bundle.capoeira_rare',
      name: 'Pack de la Buscadora',
      description: 'Mila ascendida + 3 cartas + 600 tokens',
      heroId: 'mila_rare',
      heroName: 'Mila · La Buscadora',
      cardIds: ['capoeira_meia_lua', 'capoeira_ginga_flow', 'neutral_dodge_step'],
      cardCount: 3,
      tokenAmount: 600,
      priceUsd: 4.99,
      heroGradientStart: 0xFF27AE60,
      heroGradientEnd: 0xFF062415,
    ),
    PremiumBundle(
      id: 'bundle_spartan_glory',
      storeProductId: 'com.clashofwarriors.bundle.spartan_glory',
      name: 'Pack Gloria Espartana',
      description: 'Disciplina de hierro y escudo inquebrantable',
      heroId: 'spartan',
      heroName: 'Espartano',
      cardIds: [
        'spartan_grapple_01',
        'spartan_block_01',
        'spartan_fist_01',
        'neutral_block_01',
      ],
      cardCount: 4,
      tokenAmount: 800,
      priceUsd: 7.99,
      isHighlighted: false,
      badgeText: null,
      heroGradientStart: 0xFF4A148C,
      heroGradientEnd: 0xFF1A0533,
      isEnabled: false, // héroe aún no existe en el juego
    ),
    PremiumBundle(
      id: 'bundle_viking_wrath',
      storeProductId: 'com.clashofwarriors.bundle.viking_wrath',
      name: 'Pack Furia Vikinga',
      description: 'Desata el caos del norte con tu mazo épico',
      heroId: 'viking',
      heroName: 'Vikingo',
      cardIds: [
        'viking_fist_01',
        'viking_kick_01',
        'viking_grapple_01',
        'neutral_block_01',
        'neutral_dodge_01',
      ],
      cardCount: 5,
      tokenAmount: 1200,
      priceUsd: 12.99,
      isHighlighted: false,
      badgeText: 'ÉPICO',
      heroGradientStart: 0xFF0D47A1,
      heroGradientEnd: 0xFF01031A,
      isEnabled: false, // héroe aún no existe en el juego
    ),
    PremiumBundle(
      id: 'bundle_samurai_honor',
      storeProductId: 'com.clashofwarriors.bundle.samurai_honor',
      name: 'Pack Honor del Samurái',
      description: 'Katana, honor y dominio absoluto del campo de batalla',
      heroId: 'samurai',
      heroName: 'Samurái',
      cardIds: [
        'samurai_palm_01',
        'samurai_fist_01',
        'samurai_kick_01',
        'samurai_block_01',
        'neutral_dodge_01',
        'neutral_block_01',
      ],
      cardCount: 6,
      tokenAmount: 2000,
      priceUsd: 19.99,
      isHighlighted: false,
      badgeText: 'PREMIUM',
      heroGradientStart: 0xFF880E4F,
      heroGradientEnd: 0xFF1A0010,
      isEnabled: false, // héroe aún no existe en el juego
    ),
  ];

  // ── PACKS DE TOKENS ──────────────────────────────────────────────────────
  // Ordenados por cantidad ascendente.
  // bonusTokens = tokens extra de regalo (0 en el pack básico).
  static const List<TokenPack> tokenPacks = [
    TokenPack(
      id: 'tokens_starter',
      storeProductId: 'com.clashofwarriors.tokens.starter',
      name: 'Bolsa de Tokens',
      tokenAmount: 500,
      bonusTokens: 0,
      priceUsd: 0.99,
      icon: '🪙',
    ),
    TokenPack(
      id: 'tokens_medium',
      storeProductId: 'com.clashofwarriors.tokens.medium',
      name: 'Cesta de Tokens',
      tokenAmount: 1200,
      bonusTokens: 100,
      priceUsd: 1.99,
      icon: '💰',
      badgeText: 'POPULAR',
    ),
    TokenPack(
      id: 'tokens_large',
      storeProductId: 'com.clashofwarriors.tokens.large',
      name: 'Saco de Tokens',
      tokenAmount: 3000,
      bonusTokens: 500,
      priceUsd: 4.99,
      icon: '🏆',
      badgeText: 'MEJOR VALOR',
    ),
    TokenPack(
      id: 'tokens_mega',
      storeProductId: 'com.clashofwarriors.tokens.mega',
      name: 'Cofre de Tokens',
      tokenAmount: 6500,
      bonusTokens: 1500,
      priceUsd: 9.99,
      icon: '👑',
      badgeText: 'OFERTA MÁXIMA',
    ),
  ];

  // ── HÉROES INDIVIDUALES ──────────────────────────────────────────────────
  // Variantes de rareza de los 5 héroes reales (HeroesData.rarityHeroes),
  // ordenadas por rareza descendente. Las ofertas de héroes que aún no
  // existen quedan isEnabled: false (se activan desde el admin).
  static const List<HeroOffer> heroOffers = [
    // ── Legendarios ──
    HeroOffer(id: 'offer_puo_liu_legendary', storeProductId: 'com.clashofwarriors.hero.puo_liu_legendary', heroId: 'puo_liu_legendary', name: 'Puo Liu · Maestro del Dragón', description: 'La técnica que el Maestro Lin esperaba ver en vida', rarity: HeroRarity.legendary, priceUsd: 2.99, isFeatured: true, gradientStart: 0xFFD4A017, gradientEnd: 0xFF3E2A00),
    HeroOffer(id: 'offer_kage_legendary', storeProductId: 'com.clashofwarriors.hero.kage_legendary', heroId: 'kage_legendary', name: 'Kage · La Sombra', description: 'Solo un nombre. Toda La Ciudadela lo conoce', rarity: HeroRarity.legendary, priceUsd: 2.99, gradientStart: 0xFF7B68EE, gradientEnd: 0xFF1A1A2E),
    HeroOffer(id: 'offer_ryoto_legendary', storeProductId: 'com.clashofwarriors.hero.ryoto_legendary', heroId: 'ryoto_legendary', name: 'Ryoto · Sensei', description: 'El sensei que nunca debió dejar de serlo', rarity: HeroRarity.legendary, priceUsd: 2.99, gradientStart: 0xFF1A5276, gradientEnd: 0xFF081826),
    HeroOffer(id: 'offer_kai_legendary', storeProductId: 'com.clashofwarriors.hero.kai_legendary', heroId: 'kai_legendary', name: 'Kai · La Leyenda del Sur', description: 'Un sueño que ganó el torneo', rarity: HeroRarity.legendary, priceUsd: 2.99, gradientStart: 0xFFC0392B, gradientEnd: 0xFF2A0703),
    HeroOffer(id: 'offer_mila_legendary', storeProductId: 'com.clashofwarriors.hero.mila_legendary', heroId: 'mila_legendary', name: 'Mila · La Libre', description: 'En la Capoeira no hay derrota, solo pausas', rarity: HeroRarity.legendary, priceUsd: 2.99, gradientStart: 0xFF27AE60, gradientEnd: 0xFF062415),
    // ── Épicos ──
    HeroOffer(id: 'offer_puo_liu_epic', storeProductId: 'com.clashofwarriors.hero.puo_liu_epic', heroId: 'puo_liu_epic', name: 'Puo Liu · El Guardián', description: 'Guardián del legado Shaolin', rarity: HeroRarity.epic, priceUsd: 1.99, gradientStart: 0xFFD4A017, gradientEnd: 0xFF3E2A00),
    HeroOffer(id: 'offer_kage_epic', storeProductId: 'com.clashofwarriors.hero.kage_epic', heroId: 'kage_epic', name: 'Kage · La Sombra Libre', description: 'Ya no tiene clan: tiene una razón propia', rarity: HeroRarity.epic, priceUsd: 1.99, gradientStart: 0xFF7B68EE, gradientEnd: 0xFF1A1A2E),
    HeroOffer(id: 'offer_ryoto_epic', storeProductId: 'com.clashofwarriors.hero.ryoto_epic', heroId: 'ryoto_epic', name: 'Ryoto · El Incorruptible', description: 'No ha perdido desde entonces. No va a empezar ahora', rarity: HeroRarity.epic, priceUsd: 1.99, gradientStart: 0xFF1A5276, gradientEnd: 0xFF081826),
    HeroOffer(id: 'offer_kai_epic', storeProductId: 'com.clashofwarriors.hero.kai_epic', heroId: 'kai_epic', name: 'Kai · El Campeón', description: 'Ganó el torneo sin trampas ni sobornos', rarity: HeroRarity.epic, priceUsd: 1.99, gradientStart: 0xFFC0392B, gradientEnd: 0xFF2A0703),
    HeroOffer(id: 'offer_mila_epic', storeProductId: 'com.clashofwarriors.hero.mila_epic', heroId: 'mila_epic', name: 'Mila · La Danzante Libre', description: 'Verla danzar ya es estar en combate', rarity: HeroRarity.epic, priceUsd: 1.99, gradientStart: 0xFF27AE60, gradientEnd: 0xFF062415),
    // ── Raros ──
    HeroOffer(id: 'offer_puo_liu_rare', storeProductId: 'com.clashofwarriors.hero.puo_liu_rare', heroId: 'puo_liu_rare', name: 'Puo Liu · El Discípulo', description: 'Ya no tiemblan sus manos', rarity: HeroRarity.rare, priceUsd: 0.99, gradientStart: 0xFFD4A017, gradientEnd: 0xFF3E2A00),
    HeroOffer(id: 'offer_kage_rare', storeProductId: 'com.clashofwarriors.hero.kage_rare', heroId: 'kage_rare', name: 'Kage · El Desertor', description: 'Abandonó el Clan. Sobrevivió', rarity: HeroRarity.rare, priceUsd: 0.99, gradientStart: 0xFF7B68EE, gradientEnd: 0xFF1A1A2E),
    HeroOffer(id: 'offer_ryoto_rare', storeProductId: 'com.clashofwarriors.hero.ryoto_rare', heroId: 'ryoto_rare', name: 'Ryoto · El Reivindicado', description: 'El dojo tiene su nombre de vuelta', rarity: HeroRarity.rare, priceUsd: 0.99, gradientStart: 0xFF1A5276, gradientEnd: 0xFF081826),
    HeroOffer(id: 'offer_kai_rare', storeProductId: 'com.clashofwarriors.hero.kai_rare', heroId: 'kai_rare', name: 'Kai · El Peleador', description: 'El gimnasio sigue en pie', rarity: HeroRarity.rare, priceUsd: 0.99, gradientStart: 0xFFC0392B, gradientEnd: 0xFF2A0703),
    HeroOffer(id: 'offer_mila_rare', storeProductId: 'com.clashofwarriors.hero.mila_rare', heroId: 'mila_rare', name: 'Mila · La Buscadora', description: 'La Ciudadela entera es su tatami', rarity: HeroRarity.rare, priceUsd: 0.99, gradientStart: 0xFF27AE60, gradientEnd: 0xFF062415),
    // ── Héroes futuros (aún no existen en el juego) ──
    HeroOffer(
      id: 'hero_ninja_offer',
      storeProductId: 'com.clashofwarriors.hero.ninja',
      heroId: 'ninja',
      name: 'Ninja',
      description: 'Velocidad sobrenatural, golpe silencioso y mortal',
      rarity: HeroRarity.legendary,
      priceUsd: 2.99,
      isFeatured: true,
      gradientStart: 0xFF1A1A2E,
      gradientEnd: 0xFF0D0D0D,
      isEnabled: false, // héroe aún no existe en el juego
    ),
    HeroOffer(
      id: 'hero_samurai_offer',
      storeProductId: 'com.clashofwarriors.hero.samurai',
      heroId: 'samurai',
      name: 'Samurái',
      description: 'Honor inquebrantable y maestría con la katana',
      rarity: HeroRarity.legendary,
      priceUsd: 2.99,
      isNew: true,
      gradientStart: 0xFF880E4F,
      gradientEnd: 0xFF3E0020,
      isEnabled: false, // héroe aún no existe en el juego
    ),
    HeroOffer(
      id: 'hero_viking_offer',
      storeProductId: 'com.clashofwarriors.hero.viking',
      heroId: 'viking',
      name: 'Vikingo',
      description: 'Berserker del norte, imparable en batalla',
      rarity: HeroRarity.epic,
      priceUsd: 1.99,
      gradientStart: 0xFF0D47A1,
      gradientEnd: 0xFF01031A,
      isEnabled: false, // héroe aún no existe en el juego
    ),
    HeroOffer(
      id: 'hero_spartan_offer',
      storeProductId: 'com.clashofwarriors.hero.spartan',
      heroId: 'spartan',
      name: 'Espartano',
      description: 'Escudo y lanza: defensa y ataque perfectos',
      rarity: HeroRarity.epic,
      priceUsd: 1.99,
      gradientStart: 0xFF4A148C,
      gradientEnd: 0xFF1A0533,
      isEnabled: false, // héroe aún no existe en el juego
    ),
    HeroOffer(
      id: 'hero_gladiator_offer',
      storeProductId: 'com.clashofwarriors.hero.gladiator',
      heroId: 'gladiator',
      name: 'Gladiador',
      description: 'Campeón del coliseo, nunca se rinde',
      rarity: HeroRarity.rare,
      priceUsd: 0.99,
      gradientStart: 0xFFBF360C,
      gradientEnd: 0xFF3E0C00,
      isEnabled: false, // héroe aún no existe en el juego
    ),
    HeroOffer(
      id: 'hero_muaythai_offer',
      storeProductId: 'com.clashofwarriors.hero.muaythai',
      heroId: 'muaythai',
      name: 'Muay Thai',
      description: 'El arte de las ocho extremidades',
      rarity: HeroRarity.rare,
      priceUsd: 0.99,
      gradientStart: 0xFF1B5E20,
      gradientEnd: 0xFF052009,
      isEnabled: false, // héroe aún no existe en el juego
    ),
    HeroOffer(
      id: 'hero_monk_offer',
      storeProductId: 'com.clashofwarriors.hero.monk',
      heroId: 'monk',
      name: 'Monje',
      description: 'Paz interior, palma devastadora',
      rarity: HeroRarity.rare,
      priceUsd: 0.99,
      gradientStart: 0xFFE65100,
      gradientEnd: 0xFF3E1700,
      isEnabled: false, // héroe aún no existe en el juego
    ),
    HeroOffer(
      id: 'hero_templar_offer',
      storeProductId: 'com.clashofwarriors.hero.templar',
      heroId: 'templar',
      name: 'Templario',
      description: 'Fe y acero en una sola voluntad',
      rarity: HeroRarity.epic,
      priceUsd: 1.99,
      gradientStart: 0xFF37474F,
      gradientEnd: 0xFF0D1214,
      isEnabled: false, // héroe aún no existe en el juego
    ),
  ];
}

/// Catálogo completo de la tienda premium, remoto (Firestore) con fallback
/// al hardcodeado de arriba. Cada lista viene YA filtrada por isEnabled.
class PremiumShopData {
  final List<PremiumBundle> bundles;
  final List<TokenPack> tokenPacks;
  final List<HeroOffer> heroOffers;

  const PremiumShopData({
    required this.bundles,
    required this.tokenPacks,
    required this.heroOffers,
  });

  /// Combina lo remoto con el fallback local: si una lista remota viene
  /// vacía (colección sin sembrar), usa la local. Filtra deshabilitados.
  factory PremiumShopData.fromRemote(
      Map<String, List<Map<String, dynamic>>> remote) {
    List<T> pick<T>(
      List<Map<String, dynamic>> raw,
      T Function(Map<String, dynamic>) parse,
      List<T> local,
      bool Function(T) enabled,
    ) {
      final list = raw.isEmpty ? local : raw.map(parse).toList();
      return list.where(enabled).toList();
    }

    return PremiumShopData(
      bundles: pick(remote['bundles'] ?? const [], PremiumBundle.fromMap,
          PremiumShopConfig.bundles, (b) => b.isEnabled),
      tokenPacks: pick(remote['tokenPacks'] ?? const [], TokenPack.fromMap,
          PremiumShopConfig.tokenPacks, (p) => p.isEnabled),
      heroOffers: pick(remote['heroOffers'] ?? const [], HeroOffer.fromMap,
          PremiumShopConfig.heroOffers, (o) => o.isEnabled),
    );
  }

  /// Solo el catálogo local habilitado (sin red).
  factory PremiumShopData.localOnly() => PremiumShopData(
        bundles:
            PremiumShopConfig.bundles.where((b) => b.isEnabled).toList(),
        tokenPacks:
            PremiumShopConfig.tokenPacks.where((p) => p.isEnabled).toList(),
        heroOffers:
            PremiumShopConfig.heroOffers.where((o) => o.isEnabled).toList(),
      );
}
