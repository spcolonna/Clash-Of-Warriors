// lib/delivery/widgets/game_card_widget.dart
//
// Alturas de cada sección (todas proporcionales a `width`):
//
//   HEADER:  height * 0.18  → 18% de la altura total
//   IMAGEN:  height * 0.48  → 48% de la altura total
//   BADGE:   height * 0.12  → 12% de la altura total
//   LORE:    height * 0.18  → 18% de la altura total
//   GAPS:    height * 0.04  →  4% (2% entre cada sección × 2 gaps)
//            Total = 100%
//
// Para ajustar, cambiá los factores de cada SizedBox.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/game_card.dart';

class GameCardWidget extends StatelessWidget {
  final GameCard card;
  final double width;
  final bool isPassive;

  const GameCardWidget({
    super.key,
    required this.card,
    this.width = 100,
    this.isPassive = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = width * 1.5; // altura total de la carta

    // ── Alturas de cada sección ──────────────────────────────────────────
    final headerH = h * 0.12; // header con nombre y burbujas
    final imageH  = h * 0.4; // área de imagen
    final badgeH  = h * 0.12; // badge de tipo (PUÑO, PATADA…)
    final loreH   = h * 0.26; // área de lore
    final gapH    = h * 0.02; // espacio entre secciones (× 2 = 4%)
    // ─────────────────────────────────────────────────────────────────────

    final bubbleSize = headerH * 0.55; // burbujas = 55% del alto del header

    return Container(
      width: width,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPassive ? Colors.amber : const Color(0xFFB0B0B0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── HEADER ──────────────────────────────────────────────────────
          SizedBox(
            height: headerH,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.5)),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFDDDDDD), width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Columna 1: nombre
                  Expanded(
                    child: Text(
                      card.name,
                      style: TextStyle(
                        color: const Color(0xFF1A1A1A),
                        fontSize: headerH * 0.32,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: width * 0.02),
                  // Columna 2: stamina
                  _Bubble(
                    value: '${card.staminaCost}',
                    color: const Color(0xFFF5B800),
                    size: bubbleSize,
                  ),
                  SizedBox(width: width * 0.02),
                  // Columna 3: daño base (placeholder vacío si no hay)
                  SizedBox(
                    width: bubbleSize,
                    height: bubbleSize,
                    child: card.baseDamage != null
                        ? _Bubble(
                      value: '${card.baseDamage}',
                      color: _categoryColor(card.category),
                      size: bubbleSize,
                    )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: gapH),

          // ── IMAGEN ──────────────────────────────────────────────────────
          SizedBox(
            height: imageH,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEAEA),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFCCCCCC),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _categoryEmoji(card.category),
                    style: GoogleFonts.notoColorEmoji(
                      textStyle: TextStyle(fontSize: imageH * 0.65),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: gapH),

          // ── BADGE DE TIPO ────────────────────────────────────────────────
          SizedBox(
            height: badgeH,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  color: _categoryColor(card.category).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _categoryEmoji(card.category),
                      style: GoogleFonts.notoColorEmoji(
                        textStyle: TextStyle(fontSize: badgeH * 0.55),
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    Text(
                      _categoryLabel(card.category),
                      style: TextStyle(
                        color: _categoryColor(card.category),
                        fontSize: badgeH * 0.40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: gapH),

          // ── LORE ─────────────────────────────────────────────────────────
          SizedBox(
            height: loreH,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                width * 0.05,
                0,
                width * 0.05,
                gapH,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: width * 0.02,
                ),
                child: Center(
                  child: Text(
                    card.lore.isEmpty ? '' : card.lore,
                    style: TextStyle(
                      color: const Color(0xFF5A5A5A),
                      fontSize: loreH * 0.165,
                      fontStyle: FontStyle.italic,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String value;
  final Color color;
  final double size;

  const _Bubble({
    required this.value,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.50,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}

Color _categoryColor(CardCategory category) => switch (category) {
  CardCategory.punch   => const Color(0xFFE74C3C),
  CardCategory.kick    => const Color(0xFFE67E22),
  CardCategory.grapple => const Color(0xFF8E44AD),
  CardCategory.defense => const Color(0xFF2980B9),
  CardCategory.dodge   => const Color(0xFF27AE60),
};

String _categoryEmoji(CardCategory category) => switch (category) {
  CardCategory.punch   => '👊',
  CardCategory.kick    => '🦵',
  CardCategory.grapple => '🤼',
  CardCategory.defense => '🛡️',
  CardCategory.dodge   => '💨',
};

String _categoryLabel(CardCategory category) => switch (category) {
  CardCategory.punch   => 'PUÑO',
  CardCategory.kick    => 'PATADA',
  CardCategory.grapple => 'AGARRE',
  CardCategory.defense => 'DEFENSA',
  CardCategory.dodge   => 'ESQUIVE',
};