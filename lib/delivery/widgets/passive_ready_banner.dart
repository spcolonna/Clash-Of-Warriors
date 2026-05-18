import 'package:flutter/material.dart';
import '../../domain/entities/game_card.dart';
import '../../domain/entities/hero_entity.dart';

class PassiveReadyBanner extends StatefulWidget {
  final GameCard passiveCard;
  final Faction faction;
  final VoidCallback onDismissed;

  const PassiveReadyBanner({
    super.key,
    required this.passiveCard,
    required this.faction,
    required this.onDismissed,
  });

  @override
  State<PassiveReadyBanner> createState() => _PassiveReadyBannerState();
}

class _PassiveReadyBannerState extends State<PassiveReadyBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 8),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 72),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _controller.forward().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _factionColor(Faction f) => switch (f) {
    Faction.shaolin  => const Color(0xFFFF6F00),
    Faction.ninja    => const Color(0xFF37474F),
    Faction.judoka   => const Color(0xFF1565C0),
    Faction.boxer    => const Color(0xFFB71C1C),
    Faction.capoeira => const Color(0xFF2E7D32),
  };

  IconData _factionIcon(Faction f) => switch (f) {
    Faction.shaolin  => Icons.self_improvement,
    Faction.ninja    => Icons.dark_mode,
    Faction.judoka   => Icons.sports_martial_arts,
    Faction.boxer    => Icons.sports_mma,
    Faction.capoeira => Icons.directions_run,
  };

  @override
  Widget build(BuildContext context) {
    final color = _factionColor(widget.faction);
    final icon = _factionIcon(widget.faction);

    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.9),
              Colors.black87,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border(
            bottom: BorderSide(color: color.withValues(alpha: 0.6), width: 1),
            top: BorderSide(color: color.withValues(alpha: 0.3), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '¡PASIVA DISPONIBLE!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.passiveCard.name,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, size: 14, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.passiveCard.staminaCost}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
