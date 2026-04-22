// lib/delivery/widgets/slot_clash_animator.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/battle_state.dart';
import '../../domain/entities/game_card.dart';
import 'game_card_widget.dart';

/// Overlay de pantalla completa que reproduce la animación de un slot de combate.
/// Muestra la carta del jugador y del oponente chocando, con el resultado claro.
///
/// Duración total: ~1.5s por slot
class SlotClashAnimator extends StatefulWidget {
  final SlotResult result;
  final VoidCallback onComplete;

  const SlotClashAnimator({
    super.key,
    required this.result,
    required this.onComplete,
  });

  /// Helper estático para reproducir la animación desde el battle_screen.
  /// Retorna un Future que se completa cuando la animación termina.
  static Future<void> play(
      BuildContext context, {
        required SlotResult result,
        required void Function(Widget overlay) onShow,
        required VoidCallback onHide,
      }) async {
    final completer = Completer<void>();

    onShow(SlotClashAnimator(
      result: result,
      onComplete: () {
        onHide();
        if (!completer.isCompleted) completer.complete();
      },
    ));

    return completer.future;
  }

  @override
  State<SlotClashAnimator> createState() => _SlotClashAnimatorState();
}

class _SlotClashAnimatorState extends State<SlotClashAnimator>
    with TickerProviderStateMixin {
  // Fases de la animación:
  // 0. Entrada: ambas cartas aparecen desde sus lados (0.0 - 0.25)
  // 1. Choque: cartas se encuentran en el centro, flash (0.25 - 0.45)
  // 2. Veredicto: ganador destacado, perdedor se desvanece (0.45 - 0.75)
  // 3. Daño: número vuela hacia el perdedor (0.75 - 1.0)

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward().then((_) {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: Colors.black.withOpacity(0.35),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            return _buildAnimationFrame(t);
          },
        ),
      ),
    );
  }

  Widget _buildAnimationFrame(double t) {
    final result = widget.result;
    final screenSize = MediaQuery.of(context).size;
    const cardWidth = 130.0;

    // Determinar la variante del slot
    final isEmpty = result.playerCard == null && result.opponentCard == null;
    final playerEmpty = result.playerCard == null;
    final opponentEmpty = result.opponentCard == null;

    if (isEmpty) {
      // Nadie hizo nada - solo mostrar "PASÓ"
      return _buildPassFrame(t);
    }

    if (playerEmpty) {
      // Oponente golpea sin resistencia
      return _buildDirectHitFrame(
        t: t,
        card: result.opponentCard!,
        fromTop: true,
        damage: result.opponentDamageDealt,
        cardWidth: cardWidth,
        screenSize: screenSize,
      );
    }

    if (opponentEmpty) {
      // Jugador golpea sin resistencia
      return _buildDirectHitFrame(
        t: t,
        card: result.playerCard!,
        fromTop: false,
        damage: result.playerDamageDealt,
        cardWidth: cardWidth,
        screenSize: screenSize,
      );
    }

    // Clash normal entre dos cartas
    return _buildClashFrame(
      t: t,
      playerCard: result.playerCard!,
      opponentCard: result.opponentCard!,
      winner: result.winner,
      playerDamage: result.playerDamageDealt,
      opponentDamage: result.opponentDamageDealt,
      cardWidth: cardWidth,
      screenSize: screenSize,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CLASH: dos cartas se enfrentan
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildClashFrame({
    required double t,
    required GameCard playerCard,
    required GameCard opponentCard,
    required String? winner,
    required double playerDamage,
    required double opponentDamage,
    required double cardWidth,
    required Size screenSize,
  }) {
    // Fase 0 — Entrada (0.0 - 0.25)
    // La del oponente baja desde arriba, la del jugador sube desde abajo
    // hasta posicionarse cerca del centro.
    final entryT = (t / 0.25).clamp(0.0, 1.0);
    final entryCurved = Curves.easeOutCubic.transform(entryT);

    // Fase 1 — Choque (0.25 - 0.45)
    // Las cartas colisionan en el centro con un flash.
    final clashT = ((t - 0.25) / 0.20).clamp(0.0, 1.0);

    // Fase 2 — Veredicto (0.45 - 0.75)
    // Winner se destaca con glow, loser se desvanece/encoge.
    final verdictT = ((t - 0.45) / 0.30).clamp(0.0, 1.0);

    // Fase 3 — Daño (0.75 - 1.0)
    final damageT = ((t - 0.75) / 0.25).clamp(0.0, 1.0);

    // Posiciones
    final centerY = screenSize.height / 2;
    final opponentStartY = -cardWidth * 1.5;
    final playerStartY = screenSize.height + cardWidth * 1.5;
    final opponentTargetY = centerY - cardWidth * 0.85;
    final playerTargetY = centerY - cardWidth * 0.15;

    // Durante clash, se acercan aún más
    final clashOffset = clashT * 20;

    // Posición X: ambas cartas inicialmente separadas, se centran durante clash
    final opponentOffsetX = (1 - entryCurved) * -40;
    final playerOffsetX = (1 - entryCurved) * 40;

    // Veredicto: winner hace zoom + glow, loser shrink + fade
    double opponentScale = 1.0;
    double playerScale = 1.0;
    double opponentOpacity = 1.0;
    double playerOpacity = 1.0;
    Color? winnerGlow;

    if (verdictT > 0) {
      if (winner == 'player') {
        playerScale = 1.0 + verdictT * 0.2;
        opponentScale = 1.0 - verdictT * 0.3;
        opponentOpacity = 1.0 - verdictT * 0.6;
        winnerGlow = Colors.green;
      } else if (winner == 'opponent') {
        opponentScale = 1.0 + verdictT * 0.2;
        playerScale = 1.0 - verdictT * 0.3;
        playerOpacity = 1.0 - verdictT * 0.6;
        winnerGlow = Colors.red;
      } else {
        // Tie
        playerScale = 1.0 - verdictT * 0.1;
        opponentScale = 1.0 - verdictT * 0.1;
        winnerGlow = Colors.orange;
      }
    }

    return Stack(
      children: [
        // Flash durante el choque
        if (clashT > 0 && clashT < 1)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(
                clashT < 0.5 ? clashT * 1.4 : (1 - clashT) * 1.4,
              ),
            ),
          ),

        // Glow del ganador detrás (solo durante veredicto)
        if (verdictT > 0 && winnerGlow != null)
          Positioned(
            left: screenSize.width / 2 - cardWidth * 1.2,
            top: centerY - cardWidth * 1.2,
            child: Container(
              width: cardWidth * 2.4,
              height: cardWidth * 2.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: winnerGlow.withOpacity(verdictT * 0.5),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

        // Carta del oponente
        Positioned(
          left: screenSize.width / 2 - cardWidth / 2 + opponentOffsetX,
          top: _lerp(
            opponentStartY,
            opponentTargetY - clashOffset,
            entryCurved,
          ),
          child: Transform.scale(
            scale: opponentScale,
            child: Opacity(
              opacity: opponentOpacity,
              child: _buildHighlightedCard(
                opponentCard,
                cardWidth,
                isWinner: winner == 'opponent',
                isLoser: winner == 'player',
                label: 'RIVAL',
                labelColor: Colors.red.shade300,
                showVerdict: verdictT > 0.3,
              ),
            ),
          ),
        ),

        // Carta del jugador
        Positioned(
          left: screenSize.width / 2 - cardWidth / 2 + playerOffsetX,
          top: _lerp(
            playerStartY,
            playerTargetY + clashOffset,
            entryCurved,
          ),
          child: Transform.scale(
            scale: playerScale,
            child: Opacity(
              opacity: playerOpacity,
              child: _buildHighlightedCard(
                playerCard,
                cardWidth,
                isWinner: winner == 'player',
                isLoser: winner == 'opponent',
                label: 'TÚ',
                labelColor: Colors.green.shade300,
                showVerdict: verdictT > 0.3,
              ),
            ),
          ),
        ),

        // Número de daño volando
        if (damageT > 0)
          _buildDamageNumber(
            damage: winner == 'player' ? playerDamage : opponentDamage,
            isTie: winner == 'tie',
            playerDamage: playerDamage,
            opponentDamage: opponentDamage,
            t: damageT,
            screenSize: screenSize,
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DIRECT HIT: una carta golpea sin resistencia (slot vacío del otro)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildDirectHitFrame({
    required double t,
    required GameCard card,
    required bool fromTop,
    required double damage,
    required double cardWidth,
    required Size screenSize,
  }) {
    // Fase 0 — Entrada (0.0 - 0.35)
    final entryT = (t / 0.35).clamp(0.0, 1.0);
    final entryCurved = Curves.easeOutCubic.transform(entryT);

    // Fase 1 — Impacto (0.35 - 0.55): flash + shake
    final impactT = ((t - 0.35) / 0.20).clamp(0.0, 1.0);

    // Fase 2 — Daño volando (0.55 - 1.0)
    final damageT = ((t - 0.55) / 0.45).clamp(0.0, 1.0);

    final centerX = screenSize.width / 2 - cardWidth / 2;
    final centerY = screenSize.height / 2 - cardWidth * 0.75;
    final startY = fromTop ? -cardWidth * 1.5 : screenSize.height + cardWidth * 1.5;

    // Shake en el impacto
    final shakeX = impactT > 0 && impactT < 1
        ? (impactT * 40 % 2 < 1 ? -8.0 : 8.0) * (1 - impactT)
        : 0.0;

    return Stack(
      children: [
        // Flash en el impacto
        if (impactT > 0 && impactT < 1)
          Positioned.fill(
            child: Container(
              color: Colors.red.withOpacity(
                impactT < 0.5 ? impactT * 0.8 : (1 - impactT) * 0.8,
              ),
            ),
          ),

        // Mensaje "¡GOLPE DIRECTO!"
        if (impactT > 0.2)
          Positioned(
            left: 0,
            right: 0,
            top: centerY - 80,
            child: Opacity(
              opacity: (impactT * 2).clamp(0.0, 1.0),
              child: Center(
                child: Text(
                  '¡GOLPE DIRECTO!',
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 8),
                      Shadow(color: Colors.red.shade900, blurRadius: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // La carta
        Positioned(
          left: centerX + shakeX,
          top: _lerp(startY, centerY, entryCurved),
          child: Transform.scale(
            scale: 1.0 + (impactT > 0 && impactT < 1 ? 0.1 * (1 - impactT) : 0),
            child: _buildHighlightedCard(
              card,
              cardWidth,
              isWinner: true,
              isLoser: false,
              label: fromTop ? 'RIVAL' : 'TÚ',
              labelColor: fromTop ? Colors.red.shade300 : Colors.green.shade300,
              showVerdict: false,
            ),
          ),
        ),

        // Número de daño
        if (damageT > 0)
          _buildDamageNumber(
            damage: damage,
            isTie: false,
            playerDamage: fromTop ? 0 : damage,
            opponentDamage: fromTop ? damage : 0,
            t: damageT,
            screenSize: screenSize,
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PASS: ambos slots vacíos
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPassFrame(double t) {
    final opacity = t < 0.2
        ? (t / 0.2).clamp(0.0, 1.0)
        : t > 0.8
        ? ((1 - t) / 0.2).clamp(0.0, 1.0)
        : 1.0;

    return Center(
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: const Text(
            'SIN ACCIÓN',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildHighlightedCard(
      GameCard card,
      double cardWidth, {
        required bool isWinner,
        required bool isLoser,
        required String label,
        required Color labelColor,
        required bool showVerdict,
      }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showVerdict && (isWinner || isLoser))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isWinner ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isWinner ? '✓ GANA' : '✗ PIERDE',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: labelColor.withOpacity(0.5)),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              if (isWinner)
                BoxShadow(
                  color: Colors.green.withOpacity(0.6),
                  blurRadius: 25,
                  spreadRadius: 4,
                ),
              if (isLoser)
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: GameCardWidget(card: card, width: cardWidth),
        ),
      ],
    );
  }

  Widget _buildDamageNumber({
    required double damage,
    required bool isTie,
    required double playerDamage,
    required double opponentDamage,
    required double t,
    required Size screenSize,
  }) {
    // Si es empate y ambos hicieron daño, mostrar ambos números
    if (isTie && playerDamage > 0 && opponentDamage > 0) {
      return Stack(
        children: [
          _singleDamageNumber(
            damage: opponentDamage,
            targetTop: screenSize.height * 0.7, // va al jugador
            t: t,
            screenSize: screenSize,
          ),
          _singleDamageNumber(
            damage: playerDamage,
            targetTop: screenSize.height * 0.15, // va al oponente
            t: t,
            screenSize: screenSize,
          ),
        ],
      );
    }

    // Caso normal: un solo número
    final targetTop = playerDamage > 0
        ? screenSize.height * 0.15  // daño al oponente (sube)
        : screenSize.height * 0.7;  // daño al jugador (baja)

    return _singleDamageNumber(
      damage: damage,
      targetTop: targetTop,
      t: t,
      screenSize: screenSize,
    );
  }

  Widget _singleDamageNumber({
    required double damage,
    required double targetTop,
    required double t,
    required Size screenSize,
  }) {
    final startTop = screenSize.height / 2;
    final currentTop = _lerp(startTop, targetTop, Curves.easeInCubic.transform(t));
    final opacity = (1 - t * 0.4).clamp(0.0, 1.0);
    final scale = 1.0 + t * 0.8;

    return Positioned(
      left: 0,
      right: 0,
      top: currentTop,
      child: Opacity(
        opacity: opacity,
        child: Center(
          child: Transform.scale(
            scale: scale,
            child: Text(
              '-${damage.round()}',
              style: TextStyle(
                color: Colors.red,
                fontSize: 56,
                fontWeight: FontWeight.w900,
                shadows: [
                  const Shadow(color: Colors.black, blurRadius: 10),
                  Shadow(color: Colors.red.shade900, blurRadius: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}