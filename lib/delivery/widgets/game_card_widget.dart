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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/config/game_config.dart';
import '../../domain/entities/game_card.dart';
import '../../domain/entities/hero_entity.dart';
import '../theme/app_theme.dart' show factionColorFromId;

class GameCardWidget extends StatefulWidget {
  final GameCard card;
  final double width;
  final bool isPassive;

  /// Héroe en cuyo contexto se muestra la carta (mano de batalla).
  /// Si se pasa: las cartas afines brillan (+20%), las rivales se atenúan
  /// (−20%) y la burbuja de daño muestra el DAÑO REAL (stat del héroe ×
  /// escala × afinidad) en vez del daño base. null en tienda/deck builder.
  final HeroEntity? contextHero;

  const GameCardWidget({
    super.key,
    required this.card,
    this.width = 100,
    this.isPassive = false,
    this.contextHero,
  });

  @override
  State<GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<GameCardWidget>
    with TickerProviderStateMixin {
  // TickerProviderStateMixin (no Single-): el glow se crea/destruye cada vez
  // que la carta pasa de pasiva a normal y viceversa (el State se recicla
  // entre cartas de la mano sin keys), así que puede necesitar más de un
  // ticker a lo largo de su vida.
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
      return _withAffinity(_buildCard(
        card: card, width: width, h: h,
        headerH: headerH, imageH: imageH, badgeH: badgeH,
        loreH: loreH, gapH: gapH, bubbleSize: bubbleSize, glowAlpha: 0,
      ));
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

  /// Daño mostrado en la burbuja: si hay héroe de contexto (mano de batalla),
  /// el DAÑO REAL que va a pegar la carta (stat del héroe × escala global ×
  /// afinidad de facción). Sin contexto (tienda/deck), el daño base.
  int _displayDamage(GameCard card) {
    final hero = widget.contextHero;
    if (hero == null || card.baseDamage == null) return card.baseDamage ?? 0;

    double dmg = hero.effectiveDamage(card) * GameConfig.damageScale;
    switch (factionAffinityFor(hero.faction, card.factionId)) {
      case FactionAffinity.affinity:
        dmg *= GameConfig.factionAffinityMultiplier;
      case FactionAffinity.rival:
        dmg *= GameConfig.factionRivalMultiplier;
      case FactionAffinity.none:
        break;
    }
    return dmg.round();
  }

  /// Color de la burbuja de daño: dorado si es afín, violeta si es rival,
  /// color de categoría si es neutral o no hay contexto.
  Color _damageBubbleColor(GameCard card) {
    final hero = widget.contextHero;
    if (hero == null) return _categoryColor(card.category);
    return switch (factionAffinityFor(hero.faction, card.factionId)) {
      FactionAffinity.affinity => const Color(0xFFF5B800),
      FactionAffinity.rival => const Color(0xFF9B59B6),
      FactionAffinity.none => _categoryColor(card.category),
    };
  }

  /// Envuelve la carta con el tratamiento de afinidad de facción cuando se
  /// muestra en el contexto de un héroe (mano de batalla): glow + badge +20%
  /// si es afín, atenuada + badge −20% si es rival.
  Widget _withAffinity(Widget card) {
    final faction = widget.contextHero?.faction;
    if (faction == null || widget.card.factionId == null) return card;

    final affinity = factionAffinityFor(faction, widget.card.factionId);
    if (affinity == FactionAffinity.none) return card;

    final isAffinity = affinity == FactionAffinity.affinity;
    final color =
        isAffinity ? const Color(0xFFF5B800) : const Color(0xFF9B59B6);
    final badgeText = isAffinity ? '+20%' : '−20%';

    Widget content = card;
    if (!isAffinity) {
      // Rival: desaturar levemente para leer "penalizada" de un vistazo.
      content = Opacity(
        opacity: 0.82,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.7, 0.2, 0.1, 0, 0,
            0.2, 0.7, 0.1, 0, 0,
            0.2, 0.2, 0.6, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: card,
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (isAffinity)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        content,
        Positioned(
          bottom: -4,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
                ],
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
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
              // Cartas de facción: borde un poco más marcado (look premium).
              width: _isPassive
                  ? 2.0
                  : (factionColor != null ? 2.5 : 1.5),
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
              // Glow suave del color de facción (cartas temáticas).
              if (!_isPassive && factionColor != null)
                BoxShadow(
                  color: factionColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  spreadRadius: 0.5,
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
                                value: '${_displayDamage(card)}',
                                color: _damageBubbleColor(card),
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
                    child: _CardImage(card: card, height: imageH),
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

/// Imagen de la carta con prioridad: imageUrl (red, cacheada) → asset por
/// imageFolder/imageName → default por categoría. Siempre cae al asset de la
/// categoría si algo falla (offline, URL rota, asset faltante).
class _CardImage extends StatelessWidget {
  final GameCard card;
  final double height;

  const _CardImage({required this.card, required this.height});

  Widget _fallback() => Image.asset(
        _categoryImagePath(card.category),
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
      );

  @override
  Widget build(BuildContext context) {
    final url = card.imageUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        // Tope de decodificación: aunque el archivo ya venga liviano
        // (~100-180KB, comprimido en el admin), sin esto Flutter igual
        // decodificaría el bitmap completo en memoria. Con varias cartas
        // renderizadas a la vez (mano, grilla del mazo, tienda) esto evita
        // gastar RAM/CPU de más en una imagen que se ve a lo sumo a 900px.
        memCacheWidth: 900,
        placeholder: (_, __) => _fallback(),
        errorWidget: (_, __, ___) => _fallback(),
      );
    }

    if (card.imageFolder != null && card.imageName != null) {
      return Image.asset(
        'assets/images/cards/${card.imageFolder}/${card.imageName}',
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return _fallback();
  }
}

// Color de facción: fuente única en theme/app_theme.dart
Color? _factionColor(String? factionId) => factionColorFromId(factionId);
