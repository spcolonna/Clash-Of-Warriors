// lib/delivery/screens/battle/battle_screen.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/battle_state.dart';
import '../../../domain/entities/game_card.dart';
import '../../../domain/entities/hero_entity.dart';
import '../../../infra/services/haptics_service.dart';
import '../../../infra/sound/sound_service.dart';
import '../../state/battle_provider.dart';
import '../../widgets/game_card_widget.dart';
import '../../widgets/hero_stats_dialog.dart';
import '../../widgets/passive_ready_banner.dart';
import '../../widgets/player_hand_widget.dart';
import '../../widgets/card_conjure_overlay.dart';
import '../../widgets/round_banner.dart';
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

class _BattleScreenState extends ConsumerState<BattleScreen>
    with SingleTickerProviderStateMixin {
  int _resolvingSlot = -1;
  bool _handReady = false;
  Widget? _activeClash;
  GameCard? _conjuredCard;
  bool _showPassiveBanner = false;
  int? _bannerRound;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    // Banner de ronda 1 al entrar a la batalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showRoundBanner(1);
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _showRoundBanner(int round) {
    SoundService().play('round_start');
    setState(() => _bannerRound = round);
  }

  void _triggerShake() {
    HapticsService().heavy();
    _shakeController.forward(from: 0);
  }

  /// Coloca la carta desde el tap de la mano (primer slot libre).
  void _onCardPlay(GameCard card) {
    final slot =
        ref.read(battleProvider.notifier).playCardToFirstFreeSlot(card);
    if (slot >= 0) {
      HapticsService().medium();
      SoundService().play('card_place');
      setState(() => _conjuredCard = card);
    } else {
      HapticsService().error();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('No hay slot libre o falta stamina'),
            duration: Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF2A2A3E),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final battle = ref.watch(battleProvider);

    ref.listen(battleProvider, (prev, next) {
      if (next.isBattleOver && !(prev?.isBattleOver ?? false)) {
        SoundService().play('ko');
        HapticsService().success();
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

          // ── UI principal (con screen shake al recibir daño) ────────────────
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final v = _shakeController.value;
              final dx = v == 0 || v == 1
                  ? 0.0
                  : (v * 24 % 2 < 1 ? -1 : 1) * 7.0 * (1 - v);
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: SafeArea(
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
                          ? () =>
                              _showRoundLog(context, battle.roundHistory.last)
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
                    onCardPlay: _onCardPlay,
                  ),
                ],
              ),
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
          if (_bannerRound != null)
            Positioned.fill(
              child: RoundBanner(
                key: ValueKey('round_banner_$_bannerRound'),
                round: _bannerRound!,
                onComplete: () {
                  if (mounted) setState(() => _bannerRound = null);
                },
              ),
            ),
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
    HapticsService().medium();
    SoundService().play('select');
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

      final hpBefore = ref.read(battleProvider).player.currentHp;
      notifier.applySlotDamage(i);
      final hpAfter = ref.read(battleProvider).player.currentHp;
      if (hpAfter < hpBefore) _triggerShake();

      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (mounted) setState(() => _resolvingSlot = -1);

    notifier.finalizeRound();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final endState = ref.read(battleProvider);
    if (!endState.isBattleOver) {
      // Mecánica de carta retenida (solo batallas no-tutorial)
      if (!endState.isTutorial && endState.player.hand.isNotEmpty) {
        await _showHoldCardSheet(endState.player.hand, notifier);
      }
      if (!mounted) return;
      notifier.startNextRound();
      if (!mounted) return;
      final nextState = ref.read(battleProvider);
      if (!nextState.isBattleOver) {
        _showRoundBanner(nextState.currentRound);
      }
      if (nextState.passiveJustUnlocked) {
        setState(() => _showPassiveBanner = true);
      }
    }
  }

  Future<void> _showHoldCardSheet(
    List<GameCard> hand,
    BattleNotifier notifier,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _HoldCardSheet(
        hand: hand,
        onHold: (card) {
          if (card != null) notifier.holdCard(card);
          Navigator.of(context).pop();
        },
      ),
    );
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
          const SizedBox(width: 4),
          _OpponentStaminaBadge(
            stamina: opp.currentStamina,
            maxStamina: opp.hero.maxStamina,
          ),
          const SizedBox(width: 6),
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
            _OpponentSlotsRow(
              battle: battle,
              resolvingSlot: resolvingSlot,
              onScoutSlot: battle.phase == BattlePhase.planning &&
                      battle.scoutTokensRemaining > 0
                  ? (slotIndex) => _showScoutDialog(context, ref, slotIndex, battle)
                  : null,
            ),
            Expanded(
              child: _HeroFaceoffSection(
                battle: battle,
                resolvingSlot: resolvingSlot,
              ),
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
                      final placed = ref
                          .read(battleProvider.notifier)
                          .placeCardInSlot(card, i);
                      if (placed) {
                        HapticsService().medium();
                        SoundService().play('card_place');
                        onCardConjured(card);
                      } else {
                        HapticsService().error();
                      }
                    },
                    onTap: () {
                      HapticsService().light();
                      ref.read(battleProvider.notifier).removeCardFromSlot(i);
                    },
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

  static void _showScoutDialog(
    BuildContext context,
    WidgetRef ref,
    int slotIndex,
    BattleState battle,
  ) {
    if (battle.revealedOpponentSlots.containsKey(slotIndex)) return;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Querés ver la carta de tu oponente?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        content: Text(
          'Consumirás un scout  ·  Te quedan ${battle.scoutTokensRemaining}',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              HapticsService().medium();
              SoundService().play('unlock');
              ref.read(battleProvider.notifier).useScout(slotIndex);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Ver',
              style: TextStyle(color: Color(0xFF3498DB), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── OPPONENT SLOTS ROW ───────────────────────────────────────────────────────

class _OpponentSlotsRow extends StatelessWidget {
  final BattleState battle;
  final int resolvingSlot;
  final void Function(int slotIndex)? onScoutSlot;

  const _OpponentSlotsRow({
    required this.battle,
    required this.resolvingSlot,
    this.onScoutSlot,
  });

  @override
  Widget build(BuildContext context) {
    final opponent = battle.opponent;
    final canScout = onScoutSlot != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Columna de tokens de scout (izquierda)
        _ScoutTokensColumn(remaining: battle.scoutTokensRemaining),
        const SizedBox(width: 8),
        ...List.generate(3, (i) {
          const slotH = 72.0;
          const slotW = slotH / 1.5;
          final revealedCard = battle.revealedOpponentSlots[i];
          final slotCanScout = canScout && revealedCard == null;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: slotCanScout ? () => onScoutSlot!(i) : null,
              child: _OpponentSlot(
                card: opponent.plannedSequence[i],
                phase: battle.phase,
                isResolving: resolvingSlot == i,
                width: slotW,
                height: slotH,
                revealedCard: revealedCard,
                canScout: slotCanScout,
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── HERO FACEOFF ─────────────────────────────────────────────────────────────

class _HeroFaceoffSection extends StatefulWidget {
  final BattleState battle;
  final int resolvingSlot;

  const _HeroFaceoffSection({
    required this.battle,
    required this.resolvingSlot,
  });

  @override
  State<_HeroFaceoffSection> createState() => _HeroFaceoffSectionState();
}

class _HeroFaceoffSectionState extends State<_HeroFaceoffSection>
    with TickerProviderStateMixin {
  // Idle: respiración continua sutil de ambos héroes.
  late final AnimationController _idleController;
  // Reacción del slot en resolución: lunge del atacante + flinch del golpeado.
  late final AnimationController _playerReact;
  late final AnimationController _opponentReact;
  String? _playerRole; // 'attack' | 'hurt' | null
  String? _opponentRole;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _playerReact = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _opponentReact = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void didUpdateWidget(covariant _HeroFaceoffSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resolvingSlot != oldWidget.resolvingSlot &&
        widget.resolvingSlot >= 0 &&
        widget.battle.roundHistory.isNotEmpty) {
      final slots = widget.battle.roundHistory.last.slotResults;
      if (widget.resolvingSlot < slots.length) {
        _reactToSlot(slots[widget.resolvingSlot]);
      }
    }
  }

  /// Sincronizado con SlotClashAnimator (~1.5s): el choque ocurre alrededor
  /// de t≈0.35 → disparamos las reacciones ~500ms después de iniciar el slot.
  Future<void> _reactToSlot(SlotResult slot) async {
    if (slot.winner == null || slot.winner == 'empty') return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _playerRole = switch (slot.winner) {
        'player' => 'attack',
        'opponent' => 'hurt',
        _ => slot.playerCard != null ? 'attack' : null,
      };
      _opponentRole = switch (slot.winner) {
        'player' => 'hurt',
        'opponent' => 'attack',
        _ => slot.opponentCard != null ? 'attack' : null,
      };
    });
    if (_playerRole != null) _playerReact.forward(from: 0);
    if (_opponentRole != null) _opponentReact.forward(from: 0);
  }

  @override
  void dispose() {
    _idleController.dispose();
    _playerReact.dispose();
    _opponentReact.dispose();
    super.dispose();
  }

  String _withoutBgPath(String path) {
    final fileName = path.split('/').last;
    return 'assets/images/heros/withoutBG/$fileName';
  }

  /// Offset y tinte del héroe según su rol en la reacción actual.
  /// [towardCenter]: dirección del lunge (+1 = derecha, -1 = izquierda).
  Widget _animatedHero({
    required Widget child,
    required AnimationController react,
    required String? role,
    required double towardCenter,
    required double idlePhase,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idleController, react]),
      builder: (context, _) {
        // Respiración: bob vertical sutil, desfasado entre héroes
        final idleT = _idleController.value;
        final bob = math.sin((idleT + idlePhase) * math.pi) * 3.0;

        double dx = 0, dy = -bob;
        Color? tint;
        final t = react.value;
        if (role == 'attack' && t > 0 && t < 1) {
          // Lunge: avanza rápido y vuelve (curva de ida y vuelta)
          final lunge = math.sin(t * math.pi);
          dx = towardCenter * lunge * 26;
          dy -= lunge * 6;
        } else if (role == 'hurt' && t > 0 && t < 1) {
          // Flinch: sacudida + retroceso + tinte rojo
          final recoil = math.sin(t * math.pi);
          dx = -towardCenter * recoil * 14 +
              (t * 30 % 2 < 1 ? -1 : 1) * 4.0 * (1 - t);
          tint = Colors.red.withValues(alpha: recoil * 0.45);
        }

        Widget hero = Transform.translate(offset: Offset(dx, dy), child: child);
        if (tint != null) {
          hero = ColorFiltered(
            colorFilter: ColorFilter.mode(tint, BlendMode.srcATop),
            child: hero,
          );
        }
        return hero;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final battle = widget.battle;
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
                child: _animatedHero(
                  react: _opponentReact,
                  role: _opponentRole,
                  towardCenter: 1,
                  idlePhase: 0.0,
                  child: Image.asset(
                    _withoutBgPath(battle.opponent.hero.imagePath),
                    height: 130,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 80, height: 130),
                  ),
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
                child: _animatedHero(
                  react: _playerReact,
                  role: _playerRole,
                  towardCenter: -1,
                  idlePhase: 0.5,
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
  final void Function(GameCard card) onCardPlay;

  const _BottomSection({
    required this.battle,
    required this.handReady,
    required this.onConfirm,
    required this.onDealComplete,
    required this.onCardPlay,
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
                remainingStamina: battle.player.remainingStamina,
                onCardPlay: onCardPlay,
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

// ─── OPPONENT STAMINA BADGE ───────────────────────────────────────────────────

class _OpponentStaminaBadge extends StatelessWidget {
  final int stamina;
  final int maxStamina;

  const _OpponentStaminaBadge({required this.stamina, required this.maxStamina});

  @override
  Widget build(BuildContext context) {
    final fraction = maxStamina > 0 ? stamina / maxStamina : 0.0;
    final color = fraction > 0.6
        ? const Color(0xFF27AE60)
        : fraction > 0.3
            ? const Color(0xFFE67E22)
            : const Color(0xFFE74C3C);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt, size: 9, color: color),
              const SizedBox(width: 2),
              Text(
                '$stamina',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'STM',
          style: TextStyle(
            color: color.withValues(alpha: 0.6),
            fontSize: 7,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─── SCOUT TOKENS COLUMN ─────────────────────────────────────────────────────

class _ScoutTokensColumn extends StatelessWidget {
  final int remaining;
  const _ScoutTokensColumn({required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isActive = i < remaining;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Icon(
            isActive ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
            size: 15,
            color: isActive ? const Color(0xFF3498DB) : Colors.white12,
          ),
        );
      }),
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
  final GameCard? revealedCard; // carta revelada por scout
  final bool canScout;

  const _OpponentSlot({
    this.card,
    required this.phase,
    required this.isResolving,
    required this.width,
    required this.height,
    this.revealedCard,
    this.canScout = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRevealed =
        phase == BattlePhase.resolving || phase == BattlePhase.roundEnd;
    final cardToShow = revealedCard ?? (isRevealed ? card : null);
    final isScouted = revealedCard != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isScouted
              ? const Color(0xFF3498DB)
              : isResolving
                  ? Colors.yellow
                  : canScout
                      ? Colors.white24
                      : const Color(0xFF2A2A3E),
          width: isScouted || isResolving ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: cardToShow != null
                ? GameCardWidget(card: cardToShow, width: width)
                : canScout
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove_red_eye,
                              color: Colors.white24, size: height * 0.25),
                          const SizedBox(height: 2),
                          Text(
                            'ver',
                            style: TextStyle(
                                color: Colors.white24,
                                fontSize: height * 0.11),
                          ),
                        ],
                      )
                    : Icon(Icons.help_outline,
                        color: Colors.white10, size: height * 0.3),
          ),
          // Badge scout (ojo azul en esquina superior derecha)
          if (isScouted)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Icon(Icons.remove_red_eye,
                    size: 7, color: Colors.white),
              ),
            ),
        ],
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
              if (slot.conditionalBonusApplied)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5B800).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: const Color(0xFFF5B800).withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    '⚡ bonus',
                    style: TextStyle(color: Color(0xFFF5B800), fontSize: 7, fontWeight: FontWeight.bold),
                  ),
                ),
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

// ─── HOLD CARD SHEET ─────────────────────────────────────────────────────────

class _HoldCardSheet extends StatefulWidget {
  final List<GameCard> hand;
  final void Function(GameCard?) onHold;

  const _HoldCardSheet({required this.hand, required this.onHold});

  @override
  State<_HoldCardSheet> createState() => _HoldCardSheetState();
}

class _HoldCardSheetState extends State<_HoldCardSheet> {
  GameCard? _selected;

  @override
  Widget build(BuildContext context) {
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
          const Text(
            '¿Cuál carta guardás?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'La carta elegida pasa a tu próxima mano. Las demás se descartan.',
            style: TextStyle(color: Colors.white54, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: widget.hand.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final card = widget.hand[i];
                final isSelected = _selected == card;
                return GestureDetector(
                  onTap: () => setState(() => _selected = card),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF5B800)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF5B800).withValues(alpha: 0.4),
                                blurRadius: 8,
                              )
                            ]
                          : null,
                    ),
                    child: GameCardWidget(card: card, width: 72),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => widget.onHold(null),
                  child: const Text(
                    'No guardar',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selected != null
                        ? const Color(0xFFF5B800)
                        : const Color(0xFF2A2A3E),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _selected != null
                      ? () => widget.onHold(_selected)
                      : null,
                  child: Text(
                    _selected != null ? 'Guardar' : 'Elegir carta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _selected != null ? Colors.black : Colors.white24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
