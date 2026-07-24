// lib/delivery/widgets/shop/purchase_card_dialog.dart
//
// Dialog de compra de cartas en la tienda: mismo preview grande que ya usa
// el juego (CardPreviewDialog), con un botón de acción que resuelve el
// estado (bloqueada / sin monedas / comprar) y, al comprar con éxito, hace
// una animación de "adquisición" (rings de energía + sello dorado) antes de
// cerrarse sola. Evita el efecto "la carta desaparece de golpe" — la compra
// se siente como un evento, no un simple toggle de estado.

import 'package:flutter/material.dart';
import '../../../domain/entities/game_card.dart';
import '../../../infra/services/haptics_service.dart';
import '../../../infra/sound/sound_service.dart';
import '../game_card_widget.dart';

enum _Phase { idle, buying, success, error }

class PurchaseCardDialog extends StatefulWidget {
  final GameCard card;
  final int cost;
  final bool canBuy;
  final String disabledLabel;
  final Future<bool> Function() onBuy;
  final VoidCallback? onPurchased;

  const PurchaseCardDialog({
    super.key,
    required this.card,
    required this.cost,
    required this.canBuy,
    required this.disabledLabel,
    required this.onBuy,
    this.onPurchased,
  });

  static Future<void> show(
    BuildContext context, {
    required GameCard card,
    required int cost,
    required bool canBuy,
    required String disabledLabel,
    required Future<bool> Function() onBuy,
    VoidCallback? onPurchased,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => PurchaseCardDialog(
        card: card,
        cost: cost,
        canBuy: canBuy,
        disabledLabel: disabledLabel,
        onBuy: onBuy,
        onPurchased: onPurchased,
      ),
    );
  }

  @override
  State<PurchaseCardDialog> createState() => _PurchaseCardDialogState();
}

class _PurchaseCardDialogState extends State<PurchaseCardDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  _Phase _phase = _Phase.idle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBuy() async {
    setState(() => _phase = _Phase.buying);
    final success = await widget.onBuy();
    if (!mounted) return;

    if (!success) {
      setState(() => _phase = _Phase.error);
      return;
    }

    widget.onPurchased?.call();
    HapticsService().success();
    SoundService().play('unlock');
    setState(() => _phase = _Phase.success);
    await _controller.forward();
    if (mounted) Navigator.of(context).pop();
  }

  Color get _rarityColor => switch (widget.card.rarity) {
        CardRarity.rare => const Color(0xFF4FC3F7),
        CardRarity.epic => const Color(0xFFCE93D8),
        CardRarity.legendary => const Color(0xFFFFD700),
        _ => const Color(0xFFF5B800),
      };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _phase == _Phase.idle || _phase == _Phase.error
            ? () => Navigator.of(context).pop()
            : null,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: 1.0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            ),
            child: GestureDetector(
              onTap: () {}, // absorbe el tap para no cerrar al tocar la carta
              child: SingleChildScrollView(
                // Defensivo: en pantallas chicas, scrollea en vez de
                // desbordar (carta 260px + botón no siempre entran juntos).
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => _PurchaseStack(
                      card: widget.card,
                      progress: _phase == _Phase.success ? _controller.value : 0,
                      rarityColor: _rarityColor,
                      showStamp: _phase == _Phase.success,
                    ),
                  ),
                  if (_phase != _Phase.success) ...[
                    const SizedBox(height: 16),
                    _ActionButton(
                      phase: _phase,
                      cost: widget.cost,
                      canBuy: widget.canBuy,
                      disabledLabel: widget.disabledLabel,
                      onTap: _handleBuy,
                    ),
                  ],
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final _Phase phase;
  final int cost;
  final bool canBuy;
  final String disabledLabel;
  final VoidCallback onTap;

  const _ActionButton({
    required this.phase,
    required this.cost,
    required this.canBuy,
    required this.disabledLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buying = phase == _Phase.buying;
    final failed = phase == _Phase.error;
    final enabled = canBuy && !buying;

    return SizedBox(
      width: 260,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: failed
              ? const Color(0xFFE74C3C)
              : enabled
                  ? const Color(0xFF27AE60)
                  : const Color(0xFF2A2A3E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: enabled ? onTap : null,
        icon: buying
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
              )
            : Icon(
                failed ? Icons.error_outline : (canBuy ? Icons.shopping_cart : Icons.lock),
                size: 18,
                color: canBuy || failed ? Colors.white : Colors.white38,
              ),
        label: Text(
          buying
              ? 'Comprando...'
              : failed
                  ? 'No se pudo comprar'
                  : (canBuy ? 'Comprar \$$cost' : disabledLabel),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: canBuy || failed ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }
}

/// Card + efecto de adquisición: anillos de energía expandiéndose y un
/// sello dorado "¡ADQUIRIDA!" con overshoot, todo sincronizado a [progress]
/// (0→1, curva del propio AnimationController del dialog).
class _PurchaseStack extends StatelessWidget {
  final GameCard card;
  final double progress;
  final Color rarityColor;
  final bool showStamp;

  const _PurchaseStack({
    required this.card,
    required this.progress,
    required this.rarityColor,
    required this.showStamp,
  });

  @override
  Widget build(BuildContext context) {
    // Fases dentro del progreso total: impacto (0-.25), sello (.15-.55),
    // salida (.65-1.0).
    final impact = Curves.easeOut.transform((progress / 0.25).clamp(0.0, 1.0));
    final ringProgress = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    final stampT = Curves.elasticOut.transform(
      ((progress - 0.15) / 0.4).clamp(0.0, 1.0),
    );
    final exitT = Curves.easeIn.transform(
      ((progress - 0.65) / 0.35).clamp(0.0, 1.0),
    );

    final scale = 1.0 + (0.08 * (1 - (impact - 1).abs())) - (0.1 * exitT);
    final opacity = 1.0 - exitT;

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale.clamp(0.85, 1.1),
        child: SizedBox(
          width: 320,
          height: 400,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (showStamp) ...[
                _EnergyRing(progress: ringProgress, delay: 0.0, color: rarityColor),
                _EnergyRing(progress: ringProgress, delay: 0.15, color: rarityColor),
              ],
              // Mismo ancho que el preview estándar (CardPreviewDialog): a
              // 220px el lore quedaba corto de espacio y se truncaba antes.
              GameCardWidget(card: card, width: 260),
              if (showStamp && stampT > 0.01)
                Positioned(
                  bottom: 18,
                  child: Transform.rotate(
                    angle: -0.09 * (1 - stampT).clamp(0.0, 1.0) - 0.05,
                    child: Transform.scale(
                      scale: stampT.clamp(0.0, 1.3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14100C).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: rarityColor, width: 1.5),
                          boxShadow: [
                            BoxShadow(color: rarityColor.withValues(alpha: 0.5), blurRadius: 14),
                          ],
                        ),
                        child: Text(
                          '¡ADQUIRIDA!',
                          style: TextStyle(
                            color: rarityColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
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
}

class _EnergyRing extends StatelessWidget {
  final double progress;
  final double delay;
  final Color color;

  const _EnergyRing({required this.progress, required this.delay, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
    if (t <= 0) return const SizedBox.shrink();
    final size = 140 + t * 220;
    final opacity = (1 - t) * 0.55;
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
        ),
      ),
    );
  }
}
