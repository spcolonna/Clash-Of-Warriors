// lib/delivery/screens/battle/battle_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/battle_state.dart';
import '../../../domain/entities/game_card.dart';
import '../../../domain/entities/hero_entity.dart';
import '../../state/battle_provider.dart';
import '../../widgets/game_card_widget.dart';
import '../../widgets/hero_stats_dialog.dart';
import '../../widgets/passive_ready_banner.dart';
import '../../widgets/player_hand_widget.dart';
import '../../widgets/card_conjure_overlay.dart';
import '../../widgets/slot_clash_animator.dart';
import '../../widgets/stamina_globe.dart';
import '../../widgets/tap_scale_button.dart';
import '../help/how_to_play_screen.dart';
import '../heroes/character_select_screen.dart';

class BattleScreen extends ConsumerStatefulWidget {
  const BattleScreen({super.key});

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen> {
  int _resolvingSlot = -1;
  bool _handReady = false;
  Widget? _activeClash;
  GameCard? _conjuredCard;
  bool _showPassiveBanner = false;

  @override
  Widget build(BuildContext context) {
    final battle = ref.watch(battleProvider);

    ref.listen(battleProvider, (prev, next) {
      if (next.isBattleOver && !(prev?.isBattleOver ?? false)) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) context.go('/end-battle');
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // ── Fondo ──────────────────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_battle_screen.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── UI principal ───────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. HP bars de ambos luchadores
                _TopHpRow(battle: battle),

                // 2. Arena: slots del oponente + sprites + slots del jugador
                Expanded(
                  child: _ArenaZone(
                    battle: battle,
                    resolvingSlot: _resolvingSlot,
                    onCardConjured: (card) =>
                        setState(() => _conjuredCard = card),
                    onShowLog: battle.roundHistory.isNotEmpty
                        ? () => _showRoundLog(context, battle.roundHistory.last)
                        : null,
                  ),
                ),

                // 3. Mano + acción
                _BottomSection(
                  battle: battle,
                  handReady: _handReady,
                  onConfirm: _handReady ? _onConfirmSequence : () {},
                  onDealComplete: () {
                    if (mounted) setState(() => _handReady = true);
                  },
                ),
              ],
            ),
          ),

          // ── Overlays ───────────────────────────────────────────────────────
          if (_conjuredCard != null)
            Positioned.fill(
              child: CardConjureOverlay(
                key: UniqueKey(),
                card: _conjuredCard!,
                onComplete: () {
                  if (mounted) setState(() => _conjuredCard = null);
                },
              ),
            ),
          if (_activeClash != null) Positioned.fill(child: _activeClash!),
          if (_showPassiveBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: PassiveReadyBanner(
                  passiveCard: battle.player.hero.passive,
                  faction: battle.player.hero.faction,
                  onDismissed: () => setState(() => _showPassiveBanner = false),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onConfirmSequence() async {
    final notifier = ref.read(battleProvider.notifier);
    await notifier.confirmSequenceAndResolve();

    if (!mounted) return;
    final state = ref.read(battleProvider);
    if (state.roundHistory.isEmpty) return;
    final lastRound = state.roundHistory.last;

    for (int i = 0; i < 3; i++) {
      if (!mounted) return;
      setState(() => _resolvingSlot = i);

      await _playSlotAnimation(lastRound.slotResults[i]);
      notifier.applySlotDamage(i);
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (mounted) setState(() => _resolvingSlot = -1);

    notifier.finalizeRound();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final endState = ref.read(battleProvider);
    if (!endState.isBattleOver) {
      notifier.startNextRound();
      if (mounted && ref.read(battleProvider).passiveJustUnlocked) {
        setState(() => _showPassiveBanner = true);
      }
    }
  }

  void _showRoundLog(BuildContext context, RoundResult last) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RoundLogSheet(result: last),
    );
  }

  Future<void> _playSlotAnimation(SlotResult result) async {
    final completer = Completer<void>();
    setState(() {
      _activeClash = SlotClashAnimator(
        result: result,
        onComplete: () {
          if (mounted) setState(() => _activeClash = null);
          if (!completer.isCompleted) completer.complete();
        },
      );
    });
    await completer.future;
  }
}

// ─── TOP HP ROW ───────────────────────────────────────────────────────────────

class _TopHpRow extends StatelessWidget {
  final BattleState battle;
  const _TopHpRow({required this.battle});

  @override
  Widget build(BuildContext context) {
    final opp = battle.opponent;
    final player = battle.player;
    final oppColor = factionColor(opp.hero.faction);
    final playerColor = factionColor(player.hero.faction);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
      ),
      child: Row(
        children: [
          _HeroAvatar(
            emoji: factionEmoji(opp.hero.faction),
            color: oppColor,
            size: 52,
            imagePath: opp.hero.imagePath,
            hero: opp.hero,
            currentHp: battle.opponent.currentHp,
            currentStamina: battle.opponent.currentStamina,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _HealthBar(
              current: opp.currentHp,
              max: opp.hero.maxHp,
              color: oppColor,
              reversed: false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _HealthBar(
              current: player.currentHp,
              max: player.hero.maxHp,
              color: playerColor,
              reversed: true,
            ),
          ),
          const SizedBox(width: 6),
          StaminaGlobe(
            currentStamina: player.currentStamina,
            remainingStamina: player.remainingStamina,
            size: 44,
          ),
          const SizedBox(width: 6),
          _HeroAvatar(
            emoji: factionEmoji(player.hero.faction),
            color: playerColor,
            size: 52,
            imagePath: player.hero.imagePath,
            hero: player.hero,
            currentHp: battle.player.currentHp,
            currentStamina: battle.player.currentStamina,
          ),
        ],
      ),
    );
  }
}

// ─── ARENA ZONE ───────────────────────────────────────────────────────────────

class _ArenaZone extends ConsumerWidget {
  final BattleState battle;
  final int resolvingSlot;
  final void Function(GameCard) onCardConjured;
  final VoidCallback? onShowLog;

  const _ArenaZone({
    required this.battle,
    required this.resolvingSlot,
    required this.onCardConjured,
    required this.onShowLog,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = battle.player;
    final playerColor = factionColor(player.hero.faction);

    return Stack(
      children: [
        // ── Layout principal ──────────────────────────────────────────────
        Positioned.fill(
          child: Column(
            children: [
            const SizedBox(height: 10),
            _OpponentSlotsRow(battle: battle, resolvingSlot: resolvingSlot),
            Expanded(
              child: _HeroFaceoffSection(battle: battle),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                const slotH = 100.0;
                const slotW = slotH / 1.5;
                final blockedSlots = player.statusEffects
                    .where((e) => e.type == StatusEffectType.slotBlocked)
                    .map((e) => e.value)
                    .toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _PlayerSlot(
                    slotIndex: i,
                    card: player.plannedSequence[i],
                    isResolving: resolvingSlot == i,
                    isBlocked: blockedSlots.contains(i),
                    width: slotW,
                    height: slotH,
                    slotResult: battle.roundHistory.isNotEmpty
                        ? battle.roundHistory.last.slotResults
                            .where((r) => r.slotIndex == i)
                            .firstOrNull
                        : null,
                    onDrop: (card) {
                      ref.read(battleProvider.notifier).placeCardInSlot(card, i);
                      onCardConjured(card);
                    },
                    onTap: () =>
                        ref.read(battleProvider.notifier).removeCardFromSlot(i),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 2),
              child: Text(
                '${player.currentHp} / ${player.hero.maxHp} HP',
                style: TextStyle(
                  color: playerColor.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),      // Column
        ),      // Positioned.fill

        // ── Botón log — arriba a la derecha ───────────────────────────────
        if (onShowLog != null)
          Positioned(
            top: 6,
            right: 12,
            child: GestureDetector(
              onTap: onShowLog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.history, size: 14, color: Colors.white60),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── OPPONENT SLOTS ROW ───────────────────────────────────────────────────────

class _OpponentSlotsRow extends StatelessWidget {
  final BattleState battle;
  final int resolvingSlot;
  const _OpponentSlotsRow({required this.battle, required this.resolvingSlot});

  @override
  Widget build(BuildContext context) {
    final opponent = battle.opponent;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        const slotH = 72.0;
        const slotW = slotH / 1.5;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _OpponentSlot(
            card: opponent.plannedSequence[i],
            phase: battle.phase,
            isResolving: resolvingSlot == i,
            width: slotW,
            height: slotH,
          ),
        );
      }),
    );
  }
}

// ─── HERO FACEOFF ─────────────────────────────────────────────────────────────

class _HeroFaceoffSection extends StatelessWidget {
  final BattleState battle;

  const _HeroFaceoffSection({required this.battle});

  String _withoutBgPath(String path) {
    final fileName = path.split('/').last;
    return 'assets/images/heros/withoutBG/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Héroes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Oponente — sin flip (imagen original mira al frente/derecha)
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  _withoutBgPath(battle.opponent.hero.imagePath),
                  height: 130,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(width: 80, height: 130),
                ),
              ),
            ),

            // VS central
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFE5A93C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: const Text(
                'VS',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),

            // Jugador — espejado para que mire al oponente (izquierda)
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(-1, 1, 1),
                  child: Image.asset(
                    _withoutBgPath(battle.player.hero.imagePath),
                    height: 130,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 80, height: 130),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Round indicator — centrado arriba
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                'Ronda ${battle.currentRound}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
}

// ─── BOTTOM SECTION ───────────────────────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  final BattleState battle;
  final bool handReady;
  final VoidCallback onConfirm;
  final VoidCallback onDealComplete;

  const _BottomSection({
    required this.battle,
    required this.handReady,
    required this.onConfirm,
    required this.onDealComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mano: sin fondo propio, las cartas pueden desbordar hacia arriba
        // libremente. El Stack usa Clip.none para ese desbordamiento.
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: PlayerHandWidget(
                cards: battle.player.hand,
                isDraggable: battle.phase == BattlePhase.planning,
                onDealAnimationComplete: onDealComplete,
              ),
            ),
            Positioned(
              top: 4,
              right: 12,
              child: _CompactDeckCounter(
                remaining: battle.player.deck.length,
                total: 20,
              ),
            ),
          ],
        ),
        // Action bar con fondo propio para tapar cualquier desborde de cartas
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
          ),
          child: _ActionBar(
            battle: battle,
            onConfirm: handReady ? onConfirm : () {},
          ),
        ),
      ],
    );
  }
}

// ─── HERO AVATAR ──────────────────────────────────────────────────────────────

class _HeroAvatar extends StatelessWidget {
  final String emoji;
  final Color color;
  final double size;
  final String? imagePath;
  final HeroEntity? hero;
  final int? currentHp;
  final int? currentStamina;

  const _HeroAvatar({
    required this.emoji,
    required this.color,
    this.size = 60,
    this.imagePath,
    this.hero,
    this.currentHp,
    this.currentStamina,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)
        ],
      ),
      child: ClipOval(
        child: imagePath != null
            ? Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
                ),
              )
            : Center(
                child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
              ),
      ),
    );

    if (hero == null) return avatar;

    return GestureDetector(
      onTap: () => HeroStatsDialog.show(
        context,
        hero: hero!,
        currentHp: currentHp ?? hero!.maxHp,
        currentStamina: currentStamina ?? hero!.maxStamina,
      ),
      child: avatar,
    );
  }
}

// ─── HEALTH BAR ───────────────────────────────────────────────────────────────

class _HealthBar extends StatefulWidget {
  final int current;
  final int max;
  final Color color;
  final bool reversed;

  const _HealthBar({
    required this.current,
    required this.max,
    required this.color,
    this.reversed = false,
  });

  @override
  State<_HealthBar> createState() => _HealthBarState();
}

class _HealthBarState extends State<_HealthBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  int? _lastHp;
  double _previousFraction = 0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _lastHp = widget.current;
    _previousFraction = (widget.current / widget.max).clamp(0.0, 1.0);
  }

  @override
  void didUpdateWidget(covariant _HealthBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_lastHp != null && widget.current < _lastHp!) {
      _shakeController.forward(from: 0);
      _previousFraction = (oldWidget.current / oldWidget.max).clamp(0.0, 1.0);
    }
    _lastHp = widget.current;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetFraction = (widget.current / widget.max).clamp(0.0, 1.0);

    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: _previousFraction, end: targetFraction),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          minHeight: 10,
          backgroundColor: Colors.white10,
          valueColor: AlwaysStoppedAnimation(widget.color),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final v = _shakeController.value;
        final offset = v == 0 ? 0.0 : (v * 20 % 2 < 1 ? -6.0 : 6.0) * (1 - v);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment:
            widget.reversed ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          widget.reversed
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(-1, 1, 1),
                  child: bar,
                )
              : bar,
          const SizedBox(height: 3),
          Text(
            '${widget.current} / ${widget.max} HP',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── OPPONENT SLOT ────────────────────────────────────────────────────────────

class _OpponentSlot extends StatelessWidget {
  final GameCard? card;
  final BattlePhase phase;
  final bool isResolving;
  final double width;
  final double height;

  const _OpponentSlot({
    this.card,
    required this.phase,
    required this.isResolving,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isRevealed =
        phase == BattlePhase.resolving || phase == BattlePhase.roundEnd;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isResolving ? Colors.yellow : const Color(0xFF2A2A3E),
          width: isResolving ? 2 : 1,
        ),
      ),
      child: Center(
        child: isRevealed && card != null
            ? GameCardWidget(card: card!, width: width)
            : Icon(Icons.help_outline,
                color: Colors.white10, size: height * 0.3),
      ),
    );
  }
}

// ─── PLAYER SLOT ──────────────────────────────────────────────────────────────

class _PlayerSlot extends StatelessWidget {
  final int slotIndex;
  final GameCard? card;
  final bool isResolving;
  final bool isBlocked;
  final SlotResult? slotResult;
  final double width;
  final double height;
  final void Function(GameCard) onDrop;
  final VoidCallback onTap;

  const _PlayerSlot({
    required this.slotIndex,
    this.card,
    required this.isResolving,
    this.isBlocked = false,
    this.slotResult,
    required this.width,
    required this.height,
    required this.onDrop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isBlocked) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: Colors.red.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, color: Colors.red, size: 18),
              const SizedBox(height: 2),
              Text('${slotIndex + 1}',
                  style: const TextStyle(color: Colors.red, fontSize: 10)),
            ],
          ),
        ),
      );
    }

    return DragTarget<GameCard>(
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? Colors.white10
                  : const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isResolving
                    ? Colors.yellow
                    : (slotResult != null
                        ? (slotResult!.winner == 'player'
                            ? Colors.green
                            : Colors.red)
                        : const Color(0xFF2A2A3E)),
                width: 1.5,
              ),
            ),
            child: card == null
                ? Center(
                    child: Text('${slotIndex + 1}',
                        style: const TextStyle(color: Colors.white24)),
                  )
                : GameCardWidget(card: card!, width: width),
          ),
        );
      },
    );
  }
}

// ─── COMPACT DECK COUNTER ─────────────────────────────────────────────────────

class _CompactDeckCounter extends StatelessWidget {
  final int remaining;
  final int total;
  const _CompactDeckCounter({required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.style, size: 12, color: Colors.white54),
          const SizedBox(width: 4),
          Text(
            '$remaining/$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ACTION BAR ───────────────────────────────────────────────────────────────

class _ActionBar extends ConsumerWidget {
  final BattleState battle;
  final VoidCallback onConfirm;

  const _ActionBar({required this.battle, required this.onConfirm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAnyCard = battle.player.plannedSequence.any((c) => c != null);
    final isPlanning = battle.phase == BattlePhase.planning;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),
      child: Row(
        children: [
          // Botón info — pequeño
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showDialog(
                context: context,
                barrierColor: Colors.black.withValues(alpha: 0.85),
                builder: (_) => const HowToPlayDialog(),
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Center(
                  child: Text(
                    'i',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Botón rendirse — pequeño
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isPlanning ? () => _confirmSurrender(context, ref) : null,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isPlanning ? Colors.white24 : Colors.white12,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.flag_outlined,
                    color: isPlanning ? Colors.white54 : Colors.white24,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Botón confirmar — centrado y compacto
          Expanded(
            child: TapScaleButton(
              height: 44,
              borderRadius: 12,
              color: const Color(0xFFE74C3C),
              disabledColor: const Color(0xFF2A2A3E),
              onPressed: isPlanning && hasAnyCard ? onConfirm : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPlanning ? Icons.sports_mma : Icons.hourglass_bottom,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPlanning ? 'Confirmar' : 'Resolviendo...',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSurrender(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rendirse',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          '¿Seguro que querés abandonar el combate? Perderás esta batalla.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(battleProvider.notifier).surrender();
            },
            child: const Text('Rendirse',
                style: TextStyle(
                    color: Color(0xFFE74C3C), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── LOG DE RONDA ─────────────────────────────────────────────────────────────

class _RoundLogSheet extends StatelessWidget {
  final RoundResult result;
  const _RoundLogSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    final totalPlayer = result.totalPlayerDamage.ceil();
    final totalOpponent = result.totalOpponentDamage.ceil();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Ronda ${result.roundNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...result.slotResults.map((s) => _SlotLogRow(slot: s)),
          const Divider(color: Colors.white12, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DmgChip(
                  value: totalPlayer,
                  label: 'infligido',
                  color: const Color(0xFF27AE60)),
              const SizedBox(width: 16),
              _DmgChip(
                  value: totalOpponent,
                  label: 'recibido',
                  color: const Color(0xFFE74C3C)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SlotLogRow extends StatelessWidget {
  final SlotResult slot;
  const _SlotLogRow({required this.slot});

  @override
  Widget build(BuildContext context) {
    final winner = slot.winner;
    final Color resultColor = switch (winner) {
      'player' => const Color(0xFF27AE60),
      'opponent' => const Color(0xFFE74C3C),
      _ => Colors.white38,
    };
    final IconData resultIcon = switch (winner) {
      'player' => Icons.arrow_upward,
      'opponent' => Icons.arrow_downward,
      _ => Icons.remove,
    };
    final String resultLabel = switch (winner) {
      'player' => 'ganás',
      'opponent' => 'perdés',
      'tie' => 'empate',
      _ => 'vacío',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text('${slot.slotIndex + 1}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
                textAlign: TextAlign.center),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _CardLabel(
                card: slot.playerCard,
                dmg: slot.playerDamageDealt,
                alignRight: false),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(resultIcon, size: 14, color: resultColor),
              Text(resultLabel,
                  style: TextStyle(
                      color: resultColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CardLabel(
                card: slot.opponentCard,
                dmg: slot.opponentDamageDealt,
                alignRight: true),
          ),
        ],
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  final GameCard? card;
  final double dmg;
  final bool alignRight;
  const _CardLabel(
      {required this.card, required this.dmg, required this.alignRight});

  String _categoryLabel(CardCategory cat) => switch (cat) {
        CardCategory.punch => 'Puño',
        CardCategory.kick => 'Patada',
        CardCategory.grapple => 'Lucha',
        CardCategory.defense => 'Defensa',
        CardCategory.dodge => 'Esquive',
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          card != null ? _categoryLabel(card!.category) : '— vacío —',
          style: TextStyle(
            color: card != null ? Colors.white : Colors.white30,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
        ),
        if (dmg > 0)
          Text(
            '-${dmg.ceil()} HP',
            style: const TextStyle(color: Color(0xFFE74C3C), fontSize: 9),
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
          ),
      ],
    );
  }
}

class _DmgChip extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  const _DmgChip(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$value HP',
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}
