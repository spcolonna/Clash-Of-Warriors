// lib/delivery/widgets/hero_stats_dialog.dart

import 'dart:math' show pi;
import 'package:flutter/material.dart';
import '../../domain/entities/hero_entity.dart';
import '../screens/heroes/character_select_screen.dart';

class HeroStatsDialog extends StatefulWidget {
  final HeroEntity hero;
  final int currentHp;
  final int currentStamina;

  /// Acción opcional bajo la ficha (ej. comprar el héroe en la tienda). Sin
  /// esto el diálogo es solo lectura, con el botón "Cerrar" de siempre.
  final VoidCallback? onAction;
  final String actionLabel;
  final String disabledLabel;
  final bool canAct;
  final IconData actionIcon;

  const HeroStatsDialog({
    super.key,
    required this.hero,
    required this.currentHp,
    required this.currentStamina,
    this.onAction,
    this.actionLabel = 'Comprar',
    this.disabledLabel = 'Sin monedas',
    this.canAct = true,
    this.actionIcon = Icons.shopping_cart,
  });

  /// [onAction] cierra el diálogo antes de invocarse, igual que hace
  /// CardPreviewDialog: una sola pantalla sirve para ver y para actuar.
  static Future<void> show(
    BuildContext context, {
    required HeroEntity hero,
    int? currentHp,
    int? currentStamina,
    VoidCallback? onAction,
    String actionLabel = 'Comprar',
    String disabledLabel = 'Sin monedas',
    bool canAct = true,
    IconData actionIcon = Icons.shopping_cart,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => HeroStatsDialog(
        hero: hero,
        currentHp: currentHp ?? hero.maxHp,
        currentStamina: currentStamina ?? hero.maxStamina,
        onAction: onAction,
        actionLabel: actionLabel,
        disabledLabel: disabledLabel,
        canAct: canAct,
        actionIcon: actionIcon,
      ),
    );
  }

  @override
  State<HeroStatsDialog> createState() => _HeroStatsDialogState();
}

class _HeroStatsDialogState extends State<HeroStatsDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    setState(() => _flipped = !_flipped);
    if (_flipped) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = factionColor(widget.hero.faction);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: _flip,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            final angle = _anim.value * pi;
            final isBack = angle > pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: isBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child: _buildBack(color),
                    )
                  : _buildFront(color),
            );
          },
        ),
      ),
    );
  }

  // ── Cara delantera ─────────────────────────────────────────────────────────

  Widget _buildFront(Color color) {
    final hero = widget.hero;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Imagen + nombre
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    hero.imagePath,
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) => Container(
                      color: color.withValues(alpha: 0.15),
                      child: Center(
                        child: Icon(Icons.sports_mma, size: 60, color: color),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Nombre y estrellas (abajo izquierda)
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hero.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          hero.title,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Icon(
                                i < hero.stars
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge facción (arriba derecha)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: color.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        factionName(hero.faction),
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Hint de flip (arriba izquierda)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(
                        Icons.flip_rounded,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // HP y Stamina
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: _CurrentStatBar(
                    icon: Icons.favorite,
                    current: widget.currentHp,
                    max: hero.maxHp,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CurrentStatBar(
                    icon: Icons.bolt,
                    current: widget.currentStamina,
                    max: hero.maxStamina,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // boostedStats = la misma fórmula que usa el combate.
                _StatRow(label: 'Puño',    value: hero.boostedStats.punch,   max: 14, color: color),
                const SizedBox(height: 6),
                _StatRow(label: 'Patada',  value: hero.boostedStats.kick,    max: 14, color: color),
                const SizedBox(height: 6),
                _StatRow(label: 'Agarre',  value: hero.boostedStats.grapple, max: 14, color: color),
                const SizedBox(height: 6),
                _StatRow(label: 'Defensa', value: hero.boostedStats.defense, max: 14, color: color),
                const SizedBox(height: 6),
                _StatRow(label: 'Esquive', value: hero.boostedStats.dodge,   max: 14, color: color),
              ],
            ),
          ),

          // Acción opcional (comprar, etc.)
          if (widget.onAction != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.canAct
                      ? () {
                          Navigator.of(context).pop();
                          widget.onAction!();
                        }
                      : null,
                  icon: Icon(widget.actionIcon, size: 18),
                  label: Text(
                    widget.canAct ? widget.actionLabel : widget.disabledLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5B800),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFF2A2A3E),
                    disabledForegroundColor: Colors.white38,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),

          // Cerrar
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              child: const Text(
                'Cerrar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Cara trasera (Lore) ────────────────────────────────────────────────────

  Widget _buildBack(Color color) {
    final hero = widget.hero;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded, size: 32, color: color),
          const SizedBox(height: 14),
          Text(
            hero.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            hero.title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Divider(color: color.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            hero.lore,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Passive info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5B800).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFF5B800).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 11, color: Color(0xFFF5B800)),
                    const SizedBox(width: 4),
                    const Text(
                      'PASIVA · ≤40% HP',
                      style: TextStyle(
                        color: Color(0xFFF5B800),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hero.passive.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hero.passive.lore,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app_rounded,
                  size: 13, color: Colors.white24),
              const SizedBox(width: 5),
              Text(
                'Tocá para ver las stats',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _CurrentStatBar extends StatelessWidget {
  final IconData icon;
  final int current;
  final int max;
  final Color color;

  const _CurrentStatBar({
    required this.icon,
    required this.current,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              '$current / $max',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (current / max).clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / max,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
