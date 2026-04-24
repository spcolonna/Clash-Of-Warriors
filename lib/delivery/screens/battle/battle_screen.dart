// lib/delivery/screens/battle/battle_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/battle_state.dart';
import '../../../domain/entities/game_card.dart';
import '../../../domain/entities/hero_entity.dart';
import '../../state/battle_provider.dart';
import '../../widgets/deck_counter_widget.dart';
import '../../widgets/game_card_widget.dart';
import '../../widgets/hero_stats_dialog.dart';
import '../../widgets/player_hand_widget.dart';
import '../../widgets/slot_clash_animator.dart';
import '../help/how_to_play_screen.dart';
import '../heroes/character_select_screen.dart';

class BattleScreen extends ConsumerStatefulWidget {
  const BattleScreen({super.key});

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen>
    with TickerProviderStateMixin {
  int _resolvingSlot = -1;
  late AnimationController _entryController;
  bool _handReady = false;
  Widget? _activeClash;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

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
          LayoutBuilder(builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;

            return Column(
              children: [
                Expanded(
                  flex: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.red.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: _OpponentArea(
                        battle: battle,
                        resolvingSlot: _resolvingSlot,
                        maxHeight: availableHeight * 0.4,
                      ),
                    ),
                  ),
                ),
                const _BattleDivider(),
                Expanded(
                  flex: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.blue.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SlotsArea(
                          battle: battle,
                          resolvingSlot: _resolvingSlot,
                          maxHeight: availableHeight * 0.22,
                        ),
                        const Spacer(),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.only(right: 16, bottom: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  DeckCounterWidget(
                                    remaining: battle.player.deck.length,
                                    total: 20,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height:
                              (availableHeight * 0.20).clamp(100.0, 150.0),
                              child: PlayerHandWidget(
                                cards: battle.player.hand,
                                isDraggable:
                                battle.phase == BattlePhase.planning,
                                onDealAnimationComplete: () {
                                  if (mounted) {
                                    setState(() => _handReady = true);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        _ActionBar(
                          battle: battle,
                          onConfirm: _handReady ? _onConfirmSequence : () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          if (_activeClash != null) Positioned.fill(child: _activeClash!),
        ],
      ),
    );
  }

  /// Confirma secuencia, resuelve, anima slot por slot aplicando HP en cada uno.
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

      // 1. Animar el clash del slot
      await _playSlotAnimation(lastRound.slotResults[i]);

      // 2. Aplicar el daño de ESTE slot (la barra se anima)
      notifier.applySlotDamage(i);

      // 3. Pausa para que se vea la barra bajando
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (mounted) setState(() => _resolvingSlot = -1);

    // Cerrar el round (detecta fin de batalla, incrementa round)
    notifier.finalizeRound();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final endState = ref.read(battleProvider);
    if (!endState.isBattleOver) {
      notifier.startNextRound();
    }
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

class _BattleDivider extends StatelessWidget {
  const _BattleDivider();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Divider(
                color: Colors.white.withOpacity(0.1), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "VS",
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
            child: Divider(
                color: Colors.white.withOpacity(0.1), thickness: 1)),
      ],
    );
  }
}

class _OpponentArea extends StatelessWidget {
  final BattleState battle;
  final int resolvingSlot;
  final double maxHeight;

  const _OpponentArea({
    required this.battle,
    required this.resolvingSlot,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final opponent = battle.opponent;
    final color = factionColor(opponent.hero.faction);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
          child: Row(
            children: [
              _HeroAvatar(
                emoji: factionEmoji(opponent.hero.faction),
                color: color,
                size: 50,
                imagePath: opponent.hero.imagePath,
                hero: opponent.hero,                    // ← nuevo
                currentHp: battle.opponent.currentHp,  // ← nuevo
                currentStamina: battle.opponent.currentStamina, // ← nuevo
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HealthBar(
                  current: opponent.currentHp,
                  max: opponent.hero.maxHp,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: List.generate(
              3,
                  (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _OpponentSlot(
                    card: opponent.plannedSequence[i],
                    phase: battle.phase,
                    isResolving: resolvingSlot == i,
                    height: (maxHeight * 0.45).clamp(60.0, 85.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  final String emoji;
  final Color color;
  final double size;
  final String? imagePath;
  final HeroEntity? hero;         // ← nuevo
  final int? currentHp;          // ← nuevo
  final int? currentStamina;     // ← nuevo

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
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)],
      ),
      child: ClipOval(
        child: imagePath != null
            ? Image.asset(
          imagePath!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              emoji,
              style: GoogleFonts.notoColorEmoji(
                textStyle: TextStyle(fontSize: size * 0.5),
              ),
            ),
          ),
        )
            : Center(
          child: Text(
            emoji,
            style: GoogleFonts.notoColorEmoji(
              textStyle: TextStyle(fontSize: size * 0.5),
            ),
          ),
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

class _HealthBar extends StatefulWidget {
  final int current;
  final int max;
  final Color color;

  const _HealthBar({
    required this.current,
    required this.max,
    required this.color,
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
      _previousFraction =
          (oldWidget.current / oldWidget.max).clamp(0.0, 1.0);
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
    final targetFraction =
    (widget.current / widget.max).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final v = _shakeController.value;
        final offset =
        v == 0 ? 0.0 : (v * 20 % 2 < 1 ? -6.0 : 6.0) * (1 - v);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
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
          ),
          const SizedBox(height: 4),
          Text(
            "${widget.current.toInt()} / ${widget.max} HP",
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

class _OpponentSlot extends StatelessWidget {
  final GameCard? card;
  final BattlePhase phase;
  final bool isResolving;
  final double height;

  const _OpponentSlot({
    this.card,
    required this.phase,
    required this.isResolving,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isRevealed =
        phase == BattlePhase.resolving || phase == BattlePhase.roundEnd;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color:
            isResolving ? Colors.yellow : const Color(0xFF2A2A3E),
            width: isResolving ? 2 : 1),
      ),
      child: Center(
        child: isRevealed && card != null
            ? GameCardWidget(card: card!, width: height * 0.65)
            : Icon(Icons.help_outline,
            color: Colors.white10, size: height * 0.3),
      ),
    );
  }
}

class _SlotsArea extends ConsumerWidget {
  final BattleState battle;
  final int resolvingSlot;
  final double maxHeight;

  const _SlotsArea({
    required this.battle,
    required this.resolvingSlot,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = battle.player;
    final color = factionColor(player.hero.faction);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _HealthBar(
                    current: player.currentHp,
                    max: player.hero.maxHp,
                    color: color),
              ),
              const SizedBox(width: 12),
              _HeroAvatar(
                emoji: factionEmoji(player.hero.faction),
                color: color,
                size: 50,
                imagePath: player.hero.imagePath,
                hero: player.hero,                    // ← nuevo
                currentHp: battle.player.currentHp,  // ← nuevo
                currentStamina: battle.player.currentStamina, // ← nuevo
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: List.generate(
              3,
                  (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _PlayerSlot(
                    slotIndex: i,
                    card: player.plannedSequence[i],
                    isResolving: resolvingSlot == i,
                    height: (maxHeight * 0.55).clamp(80.0, 110.0),
                    slotResult: battle.roundHistory.isNotEmpty
                        ? battle.roundHistory.last.slotResults
                        .where((r) => r.slotIndex == i)
                        .firstOrNull
                        : null,
                    onDrop: (card) => ref
                        .read(battleProvider.notifier)
                        .placeCardInSlot(card, i),
                    onTap: () => ref
                        .read(battleProvider.notifier)
                        .removeCardFromSlot(i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerSlot extends StatelessWidget {
  final int slotIndex;
  final GameCard? card;
  final bool isResolving;
  final SlotResult? slotResult;
  final double height;
  final void Function(GameCard) onDrop;
  final VoidCallback onTap;

  const _PlayerSlot({
    required this.slotIndex,
    this.card,
    required this.isResolving,
    this.slotResult,
    required this.height,
    required this.onDrop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<GameCard>(
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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
                : GameCardWidget(card: card!, width: height * 0.65),
          ),
        );
      },
    );
  }
}

class _ActionBar extends StatelessWidget {
  final BattleState battle;
  final VoidCallback onConfirm;

  const _ActionBar({required this.battle, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final hasAnyCard = battle.player.plannedSequence.any((c) => c != null);
    final isPlanning = battle.phase == BattlePhase.planning;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Row(
        children: [
          // Botón "?" — pequeño, a la izquierda
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.85),
                builder: (_) => const HowToPlayDialog(),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Center(
                  child: Text(
                    'i',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Botón confirmar — ocupa el resto
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isPlanning && hasAnyCard ? onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  disabledBackgroundColor: const Color(0xFF2A2A3E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isPlanning ? '⚔️  Confirmar' : '⏳  Resolviendo...',
                  style: GoogleFonts.notoColorEmoji(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
