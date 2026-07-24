// lib/infra/local/neutral_cards_data.dart

import '../../domain/entities/game_card.dart';

// Composición fija del mazo starter: cardId → cantidad de copias
const Map<String, int> _deckComposition = {
  'neutral_punch_basic':   2,
  'neutral_punch_strong':  2,
  'neutral_kick_basic':    2,
  'neutral_kick_strong':   2,
  'neutral_grapple_basic': 2,
  'neutral_grapple_lock':  1,
  'neutral_defense_basic': 3,
  'neutral_defense_solid': 2,
  'neutral_dodge_step':    2,
  'neutral_dodge_full':    2,
};

class NeutralCardsData {

  // ── Cartas base ──────────────────────────────────────────────────────────

  static final GameCard golpeBasico = GameCard(
    id: 'neutral_punch_basic',
    name: 'Golpe Básico',
    lore: 'El primer golpe que cualquier luchador aprende. Sin técnica, sin arte. Solo intención.',
    category: CardCategory.punch,
    rarity: CardRarity.neutral,
    staminaCost: 1,
    baseDamage: 14,
  );

  static final GameCard golpeFuerte = GameCard(
    id: 'neutral_punch_strong',
    name: 'Golpe Fuerte',
    lore: 'Más peso, más cadera. Lo básico, ejecutado con toda la fuerza disponible.',
    category: CardCategory.punch,
    rarity: CardRarity.neutral,
    staminaCost: 2,
    baseDamage: 22,
  );

  static final GameCard patadaBasica = GameCard(
    id: 'neutral_kick_basic',
    name: 'Patada Básica',
    lore: 'Corta, directa. Para poner distancia o probar las defensas del oponente.',
    category: CardCategory.kick,
    rarity: CardRarity.neutral,
    staminaCost: 1,
    baseDamage: 12,
  );

  static final GameCard patadaFuerte = GameCard(
    id: 'neutral_kick_strong',
    name: 'Patada Fuerte',
    lore: 'Una patada con todo el cuerpo detrás. Sin estilo, pero con consecuencias.',
    category: CardCategory.kick,
    rarity: CardRarity.neutral,
    staminaCost: 2,
    baseDamage: 22,
  );

  static final GameCard agarreBasico = GameCard(
    id: 'neutral_grapple_basic',
    name: 'Agarre Básico',
    lore: 'Tomar al otro. Sin técnica de proyección — solo control. A veces es suficiente.',
    category: CardCategory.grapple,
    rarity: CardRarity.neutral,
    staminaCost: 2,
    baseDamage: 17,
  );

  static final GameCard llaveBasica = GameCard(
    id: 'neutral_grapple_lock',
    name: 'Llave Básica',
    lore: 'Una presión sobre la articulación correcta. No importa el arte — duele igual.',
    category: CardCategory.grapple,
    rarity: CardRarity.neutral,
    staminaCost: 2,
    baseDamage: 20,
  );

  static final GameCard guardiaBasica = GameCard(
    id: 'neutral_defense_basic',
    name: 'Guardia Básica',
    lore: 'Brazos arriba. Lo primero que enseñan. Y lo que más vidas salva.',
    category: CardCategory.defense,
    rarity: CardRarity.neutral,
    staminaCost: 1,
    baseDamage: 10,
  );

  static final GameCard bloqueoBasico = GameCard(
    id: 'neutral_defense_solid',
    name: 'Bloqueo Básico',
    lore: 'Un bloqueo con intención. No solo los brazos — el cuerpo entero.',
    category: CardCategory.defense,
    rarity: CardRarity.neutral,
    staminaCost: 2,
    baseDamage: 16,
  );

  static final GameCard pasoBasico = GameCard(
    id: 'neutral_dodge_step',
    name: 'Paso Básico',
    lore: 'Un paso lateral. Simple. El golpe pasa al lado y vos seguís en pie.',
    category: CardCategory.dodge,
    rarity: CardRarity.neutral,
    staminaCost: 1,
    baseDamage: 10,
  );

  static final GameCard esquiveBasico = GameCard(
    id: 'neutral_dodge_full',
    name: 'Esquive Básico',
    lore: 'Un movimiento completo de evasión. Más amplio, más deliberado, más efectivo.',
    category: CardCategory.dodge,
    rarity: CardRarity.neutral,
    staminaCost: 2,
    baseDamage: 16,
  );

  static final List<GameCard> allUniqueCards = [
    golpeBasico, golpeFuerte, patadaBasica, patadaFuerte,
    agarreBasico, llaveBasica, guardiaBasica, bloqueoBasico,
    pasoBasico, esquiveBasico,
  ];

  static GameCard? findById(String id) {
    for (final c in allUniqueCards) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ── Mazo starter: 20 cartas ──────────────────────────────────────────────
  //
  // Composición:
  //   Golpe Básico    × 2
  //   Golpe Fuerte    × 2
  //   Patada Básica   × 2
  //   Patada Fuerte   × 2
  //   Agarre Básico   × 2
  //   Llave Básica    × 1
  //   Guardia Básica  × 3
  //   Bloqueo Básico  × 2
  //   Paso Básico     × 2
  //   Esquive Básico  × 2
  //                   = 20

  static List<GameCard> buildStarterDeck() => [
    golpeBasico,
    golpeBasico,
    golpeFuerte,
    golpeFuerte,
    patadaBasica,
    patadaBasica,
    patadaFuerte,
    patadaFuerte,
    agarreBasico,
    agarreBasico,
    llaveBasica,
    guardiaBasica,
    guardiaBasica,
    guardiaBasica,
    bloqueoBasico,
    bloqueoBasico,
    pasoBasico,
    pasoBasico,
    esquiveBasico,
    esquiveBasico,
  ];

  /// Retorna los 20 IDs (con repeticiones) del mazo starter.
  /// Se usa en PlayerNotifier.selectFaction para asignar el mazo inicial.
  static List<String> starterDeckCardIds() {
    return buildStarterDeck().map((c) => c.id).toList();
  }

  /// Construye el mazo usando datos de Firestore (stats actualizados desde admin).
  /// Las cartas deshabilitadas (isEnabled == false) se excluyen silenciosamente.
  static List<GameCard> buildStarterDeckFromConfig(
      List<Map<String, dynamic>> firestoreCards) {
    final cardMap = {for (final c in firestoreCards) c['id'] as String: c};
    final result = <GameCard>[];
    for (final entry in _deckComposition.entries) {
      final data = cardMap[entry.key];
      if (data == null) continue; // deshabilitada o no existe
      final card = mapToGameCard(data);
      for (int i = 0; i < entry.value; i++) { result.add(card); }
    }
    return result.isEmpty ? buildStarterDeck() : result;
  }

  /// Convierte un doc de Firestore (gameData/cards/items) en un GameCard.
  /// Público: es el único deserializador de cartas, reutilizado por CardCatalog.
  static GameCard mapToGameCard(Map<String, dynamic> d) {
    final categoryStr = d['category'] as String? ?? 'punch';
    final rarityStr   = d['rarity']   as String? ?? 'neutral';
    return GameCard(
      id:          d['id']          as String,
      name:        d['name']        as String? ?? '',
      // El admin viejo guardaba el texto en 'description'; el nuevo en 'lore'.
      lore:        (d['lore'] ?? d['description']) as String? ?? '',
      category:    _parseCategory(categoryStr),
      rarity:      _parseRarity(rarityStr),
      staminaCost: d['staminaCost'] as int? ?? 1,
      baseDamage:  d['baseDamage']  as int?,
      staminaBonus: d['staminaBonus'] as int?,
      conditionalBonus: _parseConditionalBonus(d['conditionalBonus'] as String?),
      heroId:      d['heroId']      as String?,
      factionId:   d['factionId']   as String?,
      imageFolder: d['imageFolder'] as String?,
      imageName:   d['imageName']   as String?,
      imageUrl:    d['imageUrl']    as String?,
      effect:      _parseEffect(d['effect'] as String?),
      effectValue: d['effectValue'] as int?,
    );
  }

  static CardEffect? _parseEffect(String? s) => switch (s) {
    'drainStamina' => CardEffect.drainStamina,
    'heal'         => CardEffect.heal,
    'staminaBoost' => CardEffect.staminaBoost,
    'denyDefense'  => CardEffect.denyDefense,
    'weaken'       => CardEffect.weaken,
    'pierce'       => CardEffect.pierce,
    _              => null,
  };

  static CardCategory _parseCategory(String s) => switch (s) {
    'kick'    => CardCategory.kick,
    'grapple' => CardCategory.grapple,
    'defense' => CardCategory.defense,
    'dodge'   => CardCategory.dodge,
    _         => CardCategory.punch,
  };

  static CardRarity _parseRarity(String s) => switch (s) {
    'common'    => CardRarity.common,
    'uncommon'  => CardRarity.common, // el juego no distingue uncommon
    'rare'      => CardRarity.rare,
    'epic'      => CardRarity.epic,
    'legendary' => CardRarity.legendary,
    _           => CardRarity.neutral,
  };

  static ConditionalBonus? _parseConditionalBonus(String? s) => switch (s) {
    'wonPreviousSlot' => ConditionalBonus.wonPreviousSlot,
    'opponentRested'  => ConditionalBonus.opponentRested,
    'playerAhead'     => ConditionalBonus.playerAhead,
    'lowHp'           => ConditionalBonus.lowHp,
    _                 => null,
  };
}