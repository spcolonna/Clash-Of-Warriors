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

  const TokenPack({
    required this.id,
    required this.storeProductId,
    required this.name,
    required this.tokenAmount,
    required this.bonusTokens,
    required this.priceUsd,
    required this.icon,
    this.badgeText,
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
  // ── BUNDLES LEGENDARIOS ──────────────────────────────────────────────────
  // Cada bundle incluye un héroe legendario + cartas para el mazo + tokens.
  // Ordenados por precio ascendente; isHighlighted = true para el destacado.
  static const List<PremiumBundle> bundles = [
    PremiumBundle(
      id: 'bundle_ninja_elite',
      storeProductId: 'com.clashofwarriors.bundle.ninja_elite',
      name: 'Pack Élite Ninja',
      description: 'El asesino de las sombras, listo para dominar el mazo',
      heroId: 'ninja',
      heroName: 'Ninja',
      cardIds: ['ninja_kick_01', 'ninja_palm_01', 'ninja_dodge_01'],
      cardCount: 3,
      tokenAmount: 600,
      priceUsd: 4.99,
      isHighlighted: true,
      badgeText: 'MÁS POPULAR',
      heroGradientStart: 0xFF1A1A2E,
      heroGradientEnd: 0xFF0D0D0D,
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
  // Ordenados por rareza descendente (legendarios primero), luego por precio.
  static const List<HeroOffer> heroOffers = [
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
    ),
  ];
}
