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
import '../../domain/entities/game_card.dart';

class GameCardWidget extends StatefulWidget {
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
  State<GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<GameCardWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _glowController;
  Animation<double>? _glowAnim;

  bool get _isPassive =>
      widget.isPassive || widget.card.id.startsWith('passive_');

  @override
  void initState() {
    super.initState();
    _syncGlow();
  }

  @override
  void didUpdateWidget(covariant GameCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // El framework puede reutilizar este State con otra carta (p.ej. cuando
    // la pasiva se inyecta en la mano): sincronizar la animación de brillo.
    _syncGlow();
  }

  void _syncGlow() {
    if (_isPassive && _glowController == null) {
      _glowController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);
      _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut),
      );
    } else if (!_isPassive && _glowController != null) {
      _glowController!.dispose();
      _glowController = null;
      _glowAnim = null;
    }
  }

  @override
  void dispose() {
    _glowController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final width = widget.width;
    final h = width * 1.5;

    final headerH = h * 0.12;
    final imageH  = h * 0.4;
    final badgeH  = h * 0.12;
    final loreH   = h * 0.26;
    final gapH    = h * 0.02;
    final bubbleSize = headerH * 0.55;

    if (!_isPassive) {
      return _buildCard(
        card: card, width: width, h: h,
        headerH: headerH, imageH: imageH, badgeH: badgeH,
        loreH: loreH, gapH: gapH, bubbleSize: bubbleSize, glowAlpha: 0,
      );
    }

    return AnimatedBuilder(
      animation: _glowAnim!,
      builder: (context, _) => _buildCard(
        card: card, width: width, h: h,
        headerH: headerH, imageH: imageH, badgeH: badgeH,
        loreH: loreH, gapH: gapH, bubbleSize: bubbleSize,
        glowAlpha: _glowAnim!.value,
      ),
    );
  }

  Widget _buildCard({
    required GameCard card,
    required double width,
    required double h,
    required double headerH,
    required double imageH,
    required double badgeH,
    required double loreH,
    required double gapH,
    required double bubbleSize,
    required double glowAlpha,
  }) {
    final factionColor = _isPassive ? null : _factionColor(card.factionId);
    final effectiveBorderColor = _isPassive
        ? const Color(0xFFF5B800)
        : (factionColor ?? const Color(0xFFB0B0B0));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          height: h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: effectiveBorderColor,
              width: _isPassive || factionColor != null ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 5,
                offset: const Offset(1, 2),
              ),
              if (_isPassive)
                BoxShadow(
                  color: const Color(0xFFF5B800)
                      .withValues(alpha: glowAlpha * 0.7),
                  blurRadius: 12 + glowAlpha * 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── HEADER ────────────────────────────────────────────────
              SizedBox(
                height: headerH,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                  decoration: BoxDecoration(
                    color: factionColor ?? const Color(0xFFF0F0F0),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8.5)),
                    border: Border(
                      bottom: BorderSide(
                        color: factionColor != null
                            ? Colors.black.withValues(alpha: 0.20)
                            : const Color(0xFFDDDDDD),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          card.name,
                          style: TextStyle(
                            color: factionColor != null
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                            fontSize: headerH * 0.32,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      _Bubble(
                        value: '${card.staminaCost}',
                        color: const Color(0xFFF5B800),
                        size: bubbleSize,
                      ),
                      SizedBox(width: width * 0.02),
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

              // ── IMAGEN ────────────────────────────────────────────────
              SizedBox(
                height: imageH,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                        _resolveCardImagePath(card),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: imageH,
                        errorBuilder: (_, __, ___) => Image.asset(
                          _categoryImagePath(card.category),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: imageH,
                        ),
                      ),
                  ),
                ),
              ),

              SizedBox(height: gapH),

              // ── BADGE DE TIPO ─────────────────────────────────────────
              SizedBox(
                height: badgeH,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _categoryColor(card.category).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categoryIcon(card.category),
                          size: badgeH * 0.52,
                          color: _categoryColor(card.category),
                        ),
                        SizedBox(width: width * 0.02),
                        Flexible(
                          child: Text(
                            _categoryLabel(card.category),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: _categoryColor(card.category),
                              fontSize: badgeH * 0.40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: gapH),

              // ── LORE ──────────────────────────────────────────────────
              // Expanded absorbe el espacio restante: evita overflow cuando
              // el borde del Container consume píxeles de la altura total.
              Expanded(
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
                          color: const Color(0xFF3A3A3A),
                          fontSize: loreH * 0.165,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
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
        ),
        // ── BADGE "PASIVA" (top-right corner) ─────────────────────────
        if (_isPassive)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5B800), Color(0xFFFF8F00)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PASIVA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

        // ── BADGE DE FACCIÓN (top-right, solo cartas no-pasivas con facción)
        if (!_isPassive && factionColor != null && card.factionId != null)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: factionColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                card.factionId!.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
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
            color: color.withValues(alpha: 0.4),
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

IconData _categoryIcon(CardCategory category) => switch (category) {
  CardCategory.punch   => Icons.sports_mma,
  CardCategory.kick    => Icons.sports_martial_arts,
  CardCategory.grapple => Icons.people_alt,
  CardCategory.defense => Icons.shield,
  CardCategory.dodge   => Icons.directions_run,
};

String _categoryImagePath(CardCategory category) => switch (category) {
  CardCategory.punch   => 'assets/images/defaultCards/card_punch.png',
  CardCategory.kick    => 'assets/images/defaultCards/card_kick.png',
  CardCategory.grapple => 'assets/images/defaultCards/card_grapple.png',
  CardCategory.defense => 'assets/images/defaultCards/card_defense.png',
  CardCategory.dodge   => 'assets/images/defaultCards/card_dodge.png',
};

Color _categoryColor(CardCategory category) => switch (category) {
  CardCategory.punch   => const Color(0xFFE74C3C),
  CardCategory.kick    => const Color(0xFFE67E22),
  CardCategory.grapple => const Color(0xFF8E44AD),
  CardCategory.defense => const Color(0xFF2980B9),
  CardCategory.dodge   => const Color(0xFF27AE60),
};


String _categoryLabel(CardCategory category) => switch (category) {
  CardCategory.punch   => 'PUÑO',
  CardCategory.kick    => 'PATADA',
  CardCategory.grapple => 'AGARRE',
  CardCategory.defense => 'DEFENSA',
  CardCategory.dodge   => 'ESQUIVE',
};

String _resolveCardImagePath(GameCard card) {
  if (card.imageFolder != null && card.imageName != null) {
    return 'assets/images/cards/${card.imageFolder}/${card.imageName}';
  }
  return _categoryImagePath(card.category);
}

Color? _factionColor(String? factionId) => switch (factionId) {
  'shaolin'  => const Color(0xFFFF6F00),
  'ninja'    => const Color(0xFF37474F),
  'judoka'   => const Color(0xFF1565C0),
  'boxer'    => const Color(0xFFB71C1C),
  'capoeira' => const Color(0xFF2E7D32),
  _          => null,
};
