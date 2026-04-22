// lib/infra/local/neutral_cards_data.dart

import '../../domain/entities/game_card.dart';

class NeutralCardsData {

  // ── Cartas base ──────────────────────────────────────────────────────────

  static final GameCard golpeBasico = GameCard(
    id: 'neutral_punch_basic',
    name: 'Golpe Básico',
    lore: 'El primer golpe que cualquier luchador aprende. Sin técnica, sin arte. Solo intención.',
    category: CardCategory.punch,
    rarity: CardRarity.neutral,
    staminaCost: 1,
    baseDamage: 8,
  );

  static final GameCard golpeFuerte = GameCard(
    id: 'neutral_punch_strong',
    name: 'Golpe Fuerte',
    lore: 'Más peso, más cadera. Lo básico, ejecutado con toda la fuerza disponible.',
    category: CardCategory.punch,
    rarity: CardRarity.neutral,
    staminaCost: 2,
    baseDamage: 14,
  );

  static final GameCard patadaBasica = GameCard(
    id: 'neutral_kick_basic',
    name: 'Patada Básica',
    lore: 'Corta, directa. Para poner distancia o probar las defensas del oponente.',
    category: CardCategory.kick,
    rarity: CardRarity.neutral,
    staminaCost: 1,
    baseDamage: 7,
  );

  static final GameCard patadaFuerte = GameCard(
    id: 'neutral_kick_strong',
    name: 'Patada Fuerte',
    lore: 'Una patada con todo el cuerpo detrás. Sin estilo, pero con consecuencias.',
    category: CardCategory.kick,
    rarity: CardRarity.neutral,
    staminaCost: 2,
    baseDamage: 14,
  );

  static final GameCard agarreBasico = GameCard(
    id: 'neutral_grapple_basic',
    name: 'Agarre Básico',
    lore: 'Tomar al otro. Sin técnica de proyección — solo control. A veces es suficiente.',
    category: CardCategory.grapple,
    rarity: CardRarity.neutral,
    staminaCost: 2,
    baseDamage: 10,
  );

  static final GameCard llaveBasica = GameCard(
    id: 'neutral_grapple_lock',
    name: 'Llave Básica',
    lore: 'Una presión sobre la articulación correcta. No importa el arte — duele igual.',
    category: CardCategory.grapple,
    rarity: CardRarity.neutral,
    staminaCost: 2,
    baseDamage: 12,
  );

  static final GameCard guardiaBasica = GameCard(
    id: 'neutral_defense_basic',
    name: 'Guardia Básica',
    lore: 'Brazos arriba. Lo primero que enseñan. Y lo que más vidas salva.',
    category: CardCategory.defense,
    rarity: CardRarity.neutral,
    staminaCost: 1,
  );

  static final GameCard bloqueoBasico = GameCard(
    id: 'neutral_defense_solid',
    name: 'Bloqueo Básico',
    lore: 'Un bloqueo con intención. No solo los brazos — el cuerpo entero.',
    category: CardCategory.defense,
    rarity: CardRarity.neutral,
    staminaCost: 2,
  );

  static final GameCard pasoBasico = GameCard(
    id: 'neutral_dodge_step',
    name: 'Paso Básico',
    lore: 'Un paso lateral. Simple. El golpe pasa al lado y vos seguís en pie.',
    category: CardCategory.dodge,
    rarity: CardRarity.neutral,
    staminaCost: 1,
  );

  static final GameCard esquiveBasico = GameCard(
    id: 'neutral_dodge_full',
    name: 'Esquive Básico',
    lore: 'Un movimiento completo de evasión. Más amplio, más deliberado, más efectivo.',
    category: CardCategory.dodge,
    rarity: CardRarity.neutral,
    staminaCost: 2,
  );

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
}