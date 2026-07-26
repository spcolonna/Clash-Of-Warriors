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
      // Cartas con arte propio (imageUrl subido desde el admin): layout
      // "full-art" estilo Legends of Runeterra — la ilustración vertical
      // 2:3 ocupa toda la carta y nombre/coste/daño/lore van superpuestos.
      // Las genéricas (sin arte) mantienen el layout clásico de secciones.
      if (card.imageUrl != null && card.imageUrl!.isNotEmpty) {
        return _withAffinity(_buildFullArtCard(card, width, h));
      }
      return _withAffinity(_buildCard(
        card: card, width: width, h: h,
        headerH: headerH, imageH: imageH, badgeH: badgeH,
        loreH: loreH, gapH: gapH, bubbleSize: bubbleSize, glowAlpha: 0,
      ));
    }

    // Las pasivas no son cartas de mazo: no tienen arte ni se compran. Usan
    // un layout propio tipo "sello del héroe", donde lo que manda es CUÁNDO
    // se activa y qué hace — no la ilustración.
    return AnimatedBuilder(
      animation: _glowAnim!,
      builder: (context, _) =>
          _buildPassiveCard(card, width, h, _glowAnim!.value),
    );
  }

  // ── Layout de carta PASIVA ──────────────────────────────────────────────
  // Sello dorado del héroe: emblema de categoría, condición de activación
  // bien visible y la descripción como protagonista (no en una cajita chica).
  Widget _buildPassiveCard(
      GameCard card, double width, double h, double glowAlpha) {
    const gold = Color(0xFFF5B800);
    final catColor = _categoryColor(card.category);
    final frameW = (width * 0.028).clamp(2.5, 6.0);
    final emblem = width * 0.30;
    final pad = width * 0.075;

    return Container(
      width: width,
      height: h,
      padding: EdgeInsets.all(frameW),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: _metalFrameGradient(gold),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.25 + 0.45 * glowAlpha),
            blurRadius: 12 + 10 * glowAlpha,
            spreadRadius: 1 + 2 * glowAlpha,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.45),
              radius: 1.1,
              colors: [Color(0xFF2B2110), Color(0xFF12100C)],
            ),
          ),
          child: Column(
            children: [
              // Cinta superior: qué es y cuándo entra en juego.
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: width * 0.035),
                color: gold.withValues(alpha: 0.16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'PASIVA · SE ACTIVA AL 40% HP',
                    style: TextStyle(
                      color: gold,
                      fontSize: (width * 0.058).clamp(7.0, 11.0),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: width * 0.05),
              // Emblema de categoría (reemplaza la ilustración que no tienen)
              Container(
                width: emblem,
                height: emblem,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: catColor.withValues(alpha: 0.16),
                  border: Border.all(
                      color: gold.withValues(alpha: 0.55 + 0.35 * glowAlpha),
                      width: 2),
                ),
                child: Icon(_categoryIcon(card.category),
                    size: emblem * 0.52, color: gold),
              ),
              SizedBox(height: width * 0.045),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Text(
                  card.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (width * 0.095).clamp(11.0, 19.0),
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ),
              SizedBox(height: width * 0.03),
              // Datos de juego: categoría · coste · daño
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PassiveStat(
                      icon: _categoryIcon(card.category),
                      label: _categoryLabel(card.category),
                      color: catColor,
                      width: width,
                    ),
                    SizedBox(width: width * 0.04),
                    _PassiveStat(
                      icon: Icons.bolt,
                      label: '${card.staminaCost}',
                      color: const Color(0xFF4FC3F7),
                      width: width,
                    ),
                    if (card.baseDamage != null) ...[
                      SizedBox(width: width * 0.04),
                      _PassiveStat(
                        icon: Icons.local_fire_department,
                        label: '${_displayDamage(card)}',
                        color: const Color(0xFFE74C3C),
                        width: width,
                      ),
                    ],
                  ],
                ),
              ),
              // Descripción: protagonista de la carta, con aire y contraste.
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, width * 0.05, pad, pad),
                  child: Center(
                    child: Text(
                      card.lore,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: (width * 0.068).clamp(9.5, 14.0),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Layout "full-art" (estilo Legends of Runeterra) ─────────────────────
  // La ilustración vertical llena la carta entera; coste, daño, nombre,
  // categoría y lore van superpuestos sobre un degradado inferior.

  static Color _rarityBorderColor(CardRarity rarity) => switch (rarity) {
        CardRarity.rare => const Color(0xFF4FC3F7),
        CardRarity.epic => const Color(0xFFCE93D8),
        CardRarity.legendary => const Color(0xFFFFD700),
        _ => const Color(0xFF90A4AE), // common / neutral: plata
      };

  /// Gradiente "metálico" del marco: claros y oscuros del color de rareza
  /// alternados en diagonal, como el bisel de metal de las cartas TCG.
  static LinearGradient _metalFrameGradient(Color base) {
    Color tone(double towardsWhite) => towardsWhite >= 0
        ? Color.lerp(base, Colors.white, towardsWhite)!
        : Color.lerp(base, Colors.black, -towardsWhite)!;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      colors: [
        tone(0.65), // brillo superior
        tone(0.1),
        tone(-0.45), // sombra central
        tone(0.15),
        tone(0.55), // brillo inferior
      ],
    );
  }

  Widget _buildFullArtCard(GameCard card, double width, double h) {
    final rarityColor = _rarityBorderColor(card.rarity);
    final isLegendary = card.rarity == CardRarity.legendary;
    final gem = width * 0.21;
    // En tamaños chicos (mano de retención, tiles) el lore es ilegible:
    // solo se muestra a partir de ~105px, igual que hace LoR con el texto.
    final showLore = width >= 105 && card.lore.isNotEmpty;
    // Marco proporcional: metal afuera + línea de tinta que separa del arte.
    final frameW = (width * 0.028).clamp(2.5, 6.0);
    final inkW = (width * 0.008).clamp(1.0, 2.0);

    return Container(
      width: width,
      height: h,
      // Capa 1: marco metálico (gradiente de la rareza)
      padding: EdgeInsets.all(frameW),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: _metalFrameGradient(rarityColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(1, 3),
          ),
          if (isLegendary)
            BoxShadow(
              color: rarityColor.withValues(alpha: 0.5),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      // Capa 2: línea interior de tinta (separa el metal del arte)
      child: Container(
        padding: EdgeInsets.all(inkW),
        decoration: BoxDecoration(
          color: const Color(0xFF14100C),
          borderRadius: BorderRadius.circular(9),
        ),
        // Capa 3: el arte con todo superpuesto
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Stack(
            fit: StackFit.expand,
            children: [
          // Ilustración full-bleed (cache + fallback ya resueltos)
          _CardImage(card: card, height: h),

          // Degradado inferior para legibilidad del texto
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 0.72, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),

          // Gema de coste (stamina) — arriba a la izquierda
          Positioned(
            top: 4,
            left: 4,
            child: _FullArtGem(
              value: '${card.staminaCost}',
              color: const Color(0xFFF5B800),
              size: gem,
            ),
          ),

          // Badge de facción — arriba a la derecha
          if (card.factionId != null)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: _factionColor(card.factionId) ?? Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black54),
                ),
                child: Text(
                  card.factionId!.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (width * 0.055).clamp(6.0, 9.0),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

          // Bloque inferior: categoría + nombre + lore
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            // Scrim propio del bloque de texto: como el bloque mide lo que
            // mide su contenido, el degradado SIEMPRE cubre todo el texto
            // (el degradado global de la carta arranca fijo al 72% y dejaba
            // el lore de varias líneas sobre la ilustración, ilegible).
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.35, 1.0],
                  colors: [
                    Color(0x00000000),
                    Color(0xB3000000),
                    Color(0xF2000000),
                  ],
                ),
              ),
              child: Padding(
              // Aire a la derecha para no chocar con la gema de daño
              padding: EdgeInsets.fromLTRB(
                  width * 0.06, width * 0.05, width * 0.06 + gem * 0.9, width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Categoría como mini-chip
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categoryIcon(card.category),
                          size: (width * 0.085).clamp(8.0, 13.0),
                          color: _categoryColor(card.category),
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          _categoryLabel(card.category),
                          style: TextStyle(
                            color: _categoryColor(card.category),
                            fontSize: (width * 0.062).clamp(6.0, 10.0),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: width * 0.015),
                  // Nombre
                  Text(
                    card.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (width * 0.09).clamp(9.0, 18.0),
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 4),
                        Shadow(color: Colors.black87, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                  if (showLore) ...[
                    SizedBox(height: width * 0.025),
                    Text(
                      card.lore,
                      maxLines: width >= 200 ? 4 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        // Sin itálica, con más cuerpo y blanco casi puro: a
                        // 7-9px la itálica al 85% era ilegible sobre el arte.
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: (width * 0.068).clamp(9.5, 14.0),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 4),
                          Shadow(color: Colors.black, offset: Offset(0, 1)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              ),
            ),
          ),

          // Gema de daño (poder) — abajo a la derecha, con el daño real
          if (card.baseDamage != null)
            Positioned(
              bottom: 4,
              right: 4,
              child: _FullArtGem(
                value: '${_displayDamage(card)}',
                color: _damageBubbleColor(card),
                size: gem,
              ),
            ),
            ],
          ),
        ),
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
                          color: const Color(0xFF2A2A2A),
                          // Piso de tamaño: proporcional puro daba ~6.5px en
                          // cartas de 110px (ilegible). Prefiere recortar
                          // texto antes que achicarlo por debajo de 9px.
                          fontSize: (loreH * 0.185).clamp(9.0, 14.0),
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

/// Gema circular del layout full-art (coste arriba, daño abajo): como las
/// gemas de maná/poder de Legends of Runeterra — círculo saturado con borde
/// oscuro y número grande legible sobre el arte.
/// Dato compacto de la carta pasiva (categoría, coste o daño).
class _PassiveStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double width;

  const _PassiveStat({
    required this.icon,
    required this.label,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.045, vertical: width * 0.022),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(width * 0.05),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: (width * 0.075).clamp(9.0, 14.0), color: color),
          SizedBox(width: width * 0.018),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: (width * 0.062).clamp(8.0, 12.0),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullArtGem extends StatelessWidget {
  final String value;
  final Color color;
  final double size;

  const _FullArtGem({
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
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.25)!,
            color,
            Color.lerp(color, Colors.black, 0.35)!,
          ],
        ),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.75),
          width: (size * 0.09).clamp(1.5, 3.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.w900,
            height: 1,
            shadows: const [Shadow(color: Colors.black87, blurRadius: 2)],
          ),
        ),
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
