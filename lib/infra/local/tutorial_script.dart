// lib/infra/local/tutorial_script.dart
//
// Guion determinístico del tutorial: una batalla totalmente pautada donde el
// jugador solo puede jugar la carta señalada, en el slot forzado, y el bot
// juega cartas fijas para mostrar cada mecánica. Estilo "siguiente-siguiente-
// finalizar". El fin de la batalla lo fuerza el guion (no depende de HP).
//
// Modo Normal (Puño > Patada > Defensa > Puño). Cartas neutrales de
// puño/patada/defensa. Única cadena posible: Puño→Patada (+50%).

import '../../domain/entities/game_card.dart';
import 'neutral_cards_data.dart';

/// A qué apunta la manito/puntero en un paso del guion.
enum TutorialPointerKind { handCard, slot, confirmButton }

class TutorialPointer {
  final TutorialPointerKind kind;
  final int? slotIndex; // para kind == slot

  const TutorialPointer.handCard() : kind = TutorialPointerKind.handCard, slotIndex = null;
  const TutorialPointer.slot(this.slotIndex) : kind = TutorialPointerKind.slot;
  const TutorialPointer.confirm() : kind = TutorialPointerKind.confirmButton, slotIndex = null;
}

class TutorialStep {
  final String coachText;

  /// Carta que el jugador DEBE jugar en este paso (null = paso de Confirmar).
  final String? requiredCardId;

  /// Slot al que se fuerza la carta (null en pasos de Confirmar).
  final int? forcedSlot;

  /// A qué apunta el puntero.
  final TutorialPointer pointer;

  /// True si este paso se cumple tocando "Confirmar" (no jugando una carta).
  bool get isConfirm => requiredCardId == null;

  const TutorialStep({
    required this.coachText,
    this.requiredCardId,
    this.forcedSlot,
    required this.pointer,
  });
}

class TutorialScript {
  // ── Cartas (ids neutrales) ────────────────────────────────────────────────
  // Se usan cartas de costo 1 para las jugadas del jugador: la ronda 1 solo da
  // 3 de stamina, así que apertura + combo deben entrar sin quedar bloqueadas.
  static const _golpeBasico   = 'neutral_punch_basic';   // Puño 14, costo 1
  static const _patadaBasica  = 'neutral_kick_basic';    // Patada 12, costo 1
  static const _guardiaBasica = 'neutral_defense_basic'; // Defensa 10, costo 1
  static const _bloqueoBasico = 'neutral_defense_solid'; // Defensa 16, costo 2

  /// Mano fija del jugador (orden estable, sin shuffle). El orden importa: el
  /// puntero señala la carta del step por su id, no por posición.
  static const playerHandIds = <String>[
    _golpeBasico,   // R1 apertura (Puño, costo 1)
    _patadaBasica,  // R1 combo (Patada, costo 1)
    _bloqueoBasico, // R2 defensa (costo 2)
    _guardiaBasica, // relleno / remate alternativo
  ];

  /// Secuencia fija del bot por ronda (índice 0 = ronda 1). null = slot vacío.
  static const botSequenceByRound = <List<String?>>[
    // Ronda 1: abre con Patada (tu Puño gana) y defiende en slot 1 (tu Patada
    // gana y encadena +50%).
    [_patadaBasica, _guardiaBasica, null],
    // Ronda 2: ataca con Puño (tu Defensa lo gana) y descansa el resto.
    [_golpeBasico, null, null],
  ];

  /// HP del bot para el tutorial guionado (bajo: KO natural en la ronda 2;
  /// igual el guion fuerza la victoria al final).
  static const botHp = 30;

  /// Cantidad de rondas del guion.
  static const totalRounds = 2;

  // ── Pasos ─────────────────────────────────────────────────────────────────
  // Ronda 1 usa pasos 0,1,2 (apertura, combo, confirmar). Ronda 2 usa 3,4
  // (defensa, confirmar). stepIndex mapea (ronda, cartas puestas) a estos.
  static const steps = <TutorialStep>[
    // Ronda 1
    TutorialStep(
      coachText:
          'Esta es tu apertura. Jugá el Golpe que te señalo. '
          'Al colocarlo, el rival muestra su carta.',
      requiredCardId: _golpeBasico,
      forcedSlot: 0,
      pointer: TutorialPointer.handCard(),
    ),
    TutorialStep(
      coachText:
          '¡El rival abrió con Patada y tu Puño le gana! Ahora encadená: '
          'jugá la Patada. Como venís de ganar con Puño, pega +50%.',
      requiredCardId: _patadaBasica,
      forcedSlot: 1,
      pointer: TutorialPointer.handCard(),
    ),
    TutorialStep(
      coachText: 'Todo listo. Tocá Confirmar para resolver la ronda.',
      pointer: TutorialPointer.confirm(),
    ),
    // Ronda 2
    TutorialStep(
      coachText:
          'El rival ataca con Puño. Defendé: jugá tu Bloqueo. La Defensa le '
          'gana al Puño y te protege del golpe.',
      requiredCardId: _bloqueoBasico,
      forcedSlot: 0,
      pointer: TutorialPointer.handCard(),
    ),
    TutorialStep(
      coachText: 'Confirmá para cerrar la pelea. ¡Buena pelea!',
      pointer: TutorialPointer.confirm(),
    ),
  ];

  /// Índice del step (según cuántos pasos ya se completaron) que corresponde
  /// a una ronda + cuántas cartas colocó el jugador.
  /// Ronda 1 usa pasos 0,1,2 · Ronda 2 usa 3,4,5.
  static int stepIndex(int round, int cardsPlacedThisRound) {
    final base = (round - 1) * 3;
    return base + cardsPlacedThisRound;
  }

  static GameCard? card(String id) => NeutralCardsData.findById(id);

  /// Secuencia del bot resuelta a GameCards para la ronda dada (1-based).
  static List<GameCard?> botSequence(int round) {
    final idx = round - 1;
    if (idx < 0 || idx >= botSequenceByRound.length) {
      return List<GameCard?>.filled(3, null);
    }
    return botSequenceByRound[idx].map((id) => id == null ? null : card(id)).toList();
  }

  /// Mano fija resuelta a GameCards.
  static List<GameCard> playerHand() =>
      playerHandIds.map((id) => card(id)!).toList();
}
