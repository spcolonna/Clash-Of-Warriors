// lib/delivery/screens/battle/battle_screen.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/config/game_config.dart';
import '../../../domain/config/ring_events.dart';
import '../../../domain/entities/battle_state.dart';
import '../../../domain/entities/game_card.dart';
import '../../../domain/entities/hero_entity.dart';
import '../../../domain/usecases/resolve_combat_use_case.dart' show CombatEngine;
import '../../../infra/services/haptics_service.dart';
import '../../../infra/sound/sound_service.dart';
import '../../state/battle_provider.dart';
import '../../widgets/game_card_widget.dart';
import '../../widgets/hero_stats_dialog.dart';
import '../../widgets/passive_ready_banner.dart';
import '../../widgets/player_hand_widget.dart';
import '../../widgets/card_conjure_overlay.dart';
import '../../widgets/card_preview_dialog.dart';
import '../../widgets/round_banner.dart';
import '../../widgets/slot_clash_animator.dart';
import '../../widgets/surrender_dialog.dart';
import '../../widgets/tutorial_coach_banner.dart';
import '../../widgets/tutorial_tap_pointer.dart';
import '../../../infra/local/tutorial_script.dart';
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
  ({String title, String subtitle, Duration duration})? _banner;
  int _bannerSeq = 0; // fuerza rebuild del banner entre usos consecutivos
  late final AnimationController _shakeController;

  /// Step actual del guion del tutorial (null fuera de tutorial/planning o si
  /// ya no quedan pasos). Se deriva del estado: ronda + cartas colocadas.
  TutorialStep? _scriptStep(BattleState b) {
    if (!b.isTutorial || b.phase != BattlePhase.planning) return null;
    final placed = b.player.plannedSequence.whereType<GameCard>().length;
    final idx = TutorialScript.stepIndex(b.currentRound, placed);
    if (idx < 0 || idx >= TutorialScript.steps.length) return null;
    return TutorialScript.steps[idx];
  }

  // Beats del coach que se disparan cuando OCURRE la mecánica (una sola vez).
  final Set<String> _seenBeats = {};

  /// Muestra un beat del coach al resolverse un slot (tutorial): la primera
  /// vez que ganás un choque y la primera vez que tu Defensa mitiga.
  Future<void> _maybeCoachOnResolve(SlotResult r) async {
    // Ganaste tu primer choque con ambas cartas en juego.
    if (!_seenBeats.contains('firstWin') &&
        r.winner == 'player' &&
        r.playerCard != null &&
        r.opponentCard != null) {
      _seenBeats.add('firstWin');
      await _showBannerAndWait('¡GANASTE EL CHOQUE!',
          '${_catName(r.playerCard!.category)} venció a ${_catName(r.opponentCard!.category)}. Esa es la regla de oro.');
      return;
    }
    // Tu Defensa perdió el choque pero bloqueó la mitad del daño.
    if (!_seenBeats.contains('mitigate') && r.mitigatedBy == 'player') {
      _seenBeats.add('mitigate');
      await _showBannerAndWait('DEFENSA = SEGURO',
          'Tu Defensa perdió el choque pero igual bloqueó la mitad del daño.');
    }
  }

  static String _catName(CardCategory c) => switch (c) {
        CardCategory.punch => 'Puño',
        CardCategory.kick => 'Patada',
        CardCategory.grapple => 'Agarre',
        CardCategory.defense => 'Defensa',
        CardCategory.dodge => 'Esquive',
      };


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

  /// Muestra el banner central y devuelve cuánto dura, para poder esperarlo
  /// sin desincronizar el delay con la animación (antes eran números sueltos).
  Duration _showBanner(String title, String subtitle, {Duration? duration}) {
    final d = duration ?? const Duration(milliseconds: 1200);
    setState(() {
      _banner = (title: title, subtitle: subtitle, duration: d);
      _bannerSeq++;
    });
    return d;
  }

  /// Banner explicativo (combo, evento, mecánica): se sostiene lo suficiente
  /// para leerlo y el flujo espera exactamente eso.
  Future<void> _showBannerAndWait(String title, String subtitle,
      {Duration? duration}) async {
    final d = _showBanner(title, subtitle,
        duration: duration ?? RoundBanner.readable);
    await Future.delayed(d);
  }

  void _showRoundBanner(int round, {bool scoutEarned = false}) {
    SoundService().play('round_start');
    _showBanner(
      'RONDA $round',
      scoutEarned ? '+1 SCOUT · ¡PELEA!' : '¡PELEA!',
    );
  }

  void _triggerShake() {
    HapticsService().heavy();
    _shakeController.forward(from: 0);
  }

  /// Coloca la carta desde el tap de la mano. En el tutorial guionado la
  /// fuerza al slot que indica el paso; fuera de él, al primer slot libre.
  void _onCardPlay(GameCard card) {
    final notifier = ref.read(battleProvider.notifier);
    final step = _scriptStep(ref.read(battleProvider));
    final int slot;
    if (step?.forcedSlot != null) {
      slot = notifier.placeCardInSlot(card, step!.forcedSlot!)
          ? step.forcedSlot!
          : -1;
    } else {
      slot = notifier.playCardToFirstFreeSlot(card);
    }
    if (slot >= 0) {
      HapticsService().medium();
      SoundService().play('card_place');
      // En tutorial no disparamos el overlay de conjuro: mantiene el flujo
      // guionado ágil y sin overlays que tapen la carta/puntero.
      if (!ref.read(battleProvider).isTutorial) {
        setState(() => _conjuredCard = card);
      }
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
                  Builder(builder: (context) {
                    final step = _scriptStep(battle);
                    return _BottomSection(
                      battle: battle,
                      handReady: _handReady,
                      onConfirm: _handReady ? _onConfirmSequence : () {},
                      onDealComplete: () {
                        if (mounted) setState(() => _handReady = true);
                      },
                      onCardPlay: _onCardPlay,
                      // Tutorial guionado: solo la carta del paso es jugable,
                      // tap-directo (sin preview), sin drag; el botón Confirmar
                      // solo en pasos de confirmar (con puntero de tap).
                      handPlayableIds: step == null
                          ? null
                          : (step.requiredCardId == null
                              ? <String>{}
                              : {step.requiredCardId!}),
                      handAllowDrag: !battle.isTutorial,
                      handDirectTapPlay: battle.isTutorial,
                      confirmBlocked: step != null && !step.isConfirm,
                      showConfirmPointer: step != null && step.isConfirm,
                    );
                  }),
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
          if (_banner != null)
            Positioned.fill(
              child: RoundBanner(
                key: ValueKey('banner_$_bannerSeq'),
                title: _banner!.title,
                subtitle: _banner!.subtitle,
                duration: _banner!.duration,
                onComplete: () {
                  if (mounted) setState(() => _banner = null);
                },
              ),
            ),
          // ── Coach del tutorial guionado (info por paso, sin OK) ───────────
          Builder(builder: (context) {
            final step = _scriptStep(battle);
            if (step == null) return const SizedBox.shrink();
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  // 70 (altura de _TopHpRow) + ~85 (SizedBox(10) + fila de
                  // slots del rival, 72px) para no tapar la apertura revelada.
                  padding: const EdgeInsets.only(top: 155),
                  child: TutorialCoachBanner(
                    key: ValueKey('coach_${battle.currentRound}_${step.coachText.hashCode}'),
                    text: step.coachText,
                  ),
                ),
              ),
            );
          }),
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

      // Lectura: counteraste una carta repetida del rival → daño ×2.
      if (lastRound.slotResults[i].readBy == 'player') {
        SoundService().play('level_up');
        HapticsService().success();
        await _showBannerAndWait(
            '¡LECTURA!', 'Castigaste la repetición · daño ×2',
            duration: const Duration(milliseconds: 1800));
      }

      // Coach del tutorial: explicar la mecánica JUSTO cuando ocurre.
      if (ref.read(battleProvider).isTutorial) {
        await _maybeCoachOnResolve(lastRound.slotResults[i]);
      }

      await Future.delayed(const Duration(milliseconds: 400));

      // KO en medio del round: si alguien cayó a 0, el combate termina acá.
      // Los slots restantes NO se aplican — quien llegó a 0 primero perdió,
      // aunque el golpe rival del slot siguiente también hubiera sido letal.
      final afterSlot = ref.read(battleProvider);
      if (!afterSlot.player.isAlive || !afterSlot.opponent.isAlive) break;
    }

    if (mounted) setState(() => _resolvingSlot = -1);

    final scoutsBefore = ref.read(battleProvider).scoutTokensRemaining;
    notifier.finalizeRound();
    final scoutEarned =
        ref.read(battleProvider).scoutTokensRemaining > scoutsBefore;

    // Banner de ronda perfecta (el bonus ya se aplicó en finalizeRound)
    final finalized = ref.read(battleProvider);
    if (finalized.roundHistory.isNotEmpty) {
      final last = finalized.roundHistory.last;
      if (last.playerPerfectBonus > 0) {
        SoundService().play('level_up');
        HapticsService().success();
        await _showBannerAndWait(
            '¡RONDA PERFECTA!', '+${last.playerPerfectBonus} DAÑO EXTRA');
      } else if (last.opponentPerfectBonus > 0) {
        _triggerShake();
        await _showBannerAndWait(
            'RONDA PERFECTA RIVAL', '-${last.opponentPerfectBonus} HP');
      }

      // Banner de combo posicional (el daño/cura ya se aplicó en finalizeRound).
      if (last.playerComboName != null) {
        SoundService().play('level_up');
        HapticsService().success();
        final sub = last.playerComboHeal > 0
            ? '+${last.playerComboHeal} HP'
            : '+${last.playerComboDamage} DAÑO EXTRA';
        await _showBannerAndWait(
            '¡COMBO ${last.playerComboName!.toUpperCase()}!', sub);
      }
    }

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
        // Evento de ring de la nueva ronda tiene prioridad de banner.
        final ringEvent = RingEvents.byId(nextState.activeRingEvent);
        if (ringEvent != null) {
          HapticsService().medium();
          SoundService().play('whoosh');
          // El evento define la ronda entera: hay que poder leer qué hace.
          await _showBannerAndWait(
              'EVENTO: ${ringEvent.name.toUpperCase()}', ringEvent.description,
              duration: const Duration(milliseconds: 3000));
          if (!mounted) return;
        } else {
          _showRoundBanner(nextState.currentRound, scoutEarned: scoutEarned);
        }
      }
      if (nextState.passiveJustUnlocked) {
        setState(() => _showPassiveBanner = true);
        // Coach: explicar la pasiva la primera vez que se desbloquea (tutorial).
        if (nextState.isTutorial && !_seenBeats.contains('passive')) {
          _seenBeats.add('passive');
          await _showBannerAndWait('¡CARTA PASIVA!',
              'Tu HP bajó al 40%: apareció tu carta especial de remontada. Jugala en el momento justo.',
              duration: const Duration(milliseconds: 3000));
        }
      }
    }
  }

  Future<void> _showHoldCardSheet(
    List<GameCard> hand,
    BattleNotifier notifier,
  ) async {
    // Descartable y con auto-continuar: un tap guarda, ninguno sigue de largo.
    final selected = await showModalBottomSheet<GameCard>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _HoldCardSheet(hand: hand),
    );
    if (selected != null) {
      HapticsService().light();
      notifier.holdCard(selected);
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
            Builder(builder: (context) {
              const slotH = 100.0;
              const slotW = slotH / 1.5;
              final blockedSlots = player.statusEffects
                  .where((e) => e.type == StatusEffectType.slotBlocked)
                  .map((e) => e.value)
                  .toList();
              final seq = player.plannedSequence;

              Widget slotAt(int i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _PlayerSlot(
                      slotIndex: i,
                      card: seq[i],
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
                        if (i == 0 && seq[0] != null) {
                          // Apertura sellada: no se puede quitar
                          HapticsService().error();
                          return;
                        }
                        HapticsService().light();
                        ref
                            .read(battleProvider.notifier)
                            .removeCardFromSlot(i);
                      },
                    ),
                  );

              // Eslabón entre slots: se enciende si las cartas colocadas
              // forman cadena (Puño→Patada→Agarre→Puño).
              bool chained(int i) =>
                  seq[i] != null &&
                  seq[i + 1] != null &&
                  CombatEngine.chainMap[seq[i]!.category] ==
                      seq[i + 1]!.category;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  slotAt(0),
                  _ChainLink(active: chained(0)),
                  slotAt(1),
                  _ChainLink(active: chained(1)),
                  slotAt(2),
                ],
              );
            }),
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

    // La apertura del rival se revela recién cuando el jugador compromete la
    // suya (o si su slot 0 está bloqueado y no puede colocar nada ahí).
    final playerSlot0Blocked = battle.player.statusEffects.any(
        (e) => e.type == StatusEffectType.slotBlocked && e.value == 0);
    final openingCommitted =
        battle.player.plannedSequence[0] != null || playerSlot0Blocked;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Columna de tokens de scout (izquierda)
        _ScoutTokensColumn(remaining: battle.scoutTokensRemaining),
        const SizedBox(width: 8),
        ...List.generate(3, (i) {
          const slotH = 72.0;
          const slotW = slotH / 1.5;
          final isOpening = i == 0;
          final revealedCard = isOpening
              ? (battle.phase == BattlePhase.planning && openingCommitted
                  ? opponent.plannedSequence[0]
                  : null)
              : battle.revealedOpponentSlots[i];
          final slotCanScout = !isOpening && canScout && revealedCard == null;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: slotCanScout
                  ? () => onScoutSlot!(i)
                  : revealedCard != null
                      // Carta revelada (apertura o scout): tap para verla en grande
                      ? () {
                          HapticsService().selection();
                          CardPreviewDialog.show(context, revealedCard);
                        }
                      : null,
              child: _OpponentSlot(
                card: opponent.plannedSequence[i],
                phase: battle.phase,
                isResolving: resolvingSlot == i,
                width: slotW,
                height: slotH,
                revealedCard: revealedCard,
                canScout: slotCanScout,
                isOpening: isOpening,
                openingHidden: isOpening &&
                    battle.phase == BattlePhase.planning &&
                    !openingCommitted,
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
  // Tutorial guionado (null/false/true = comportamiento normal):
  final Set<String>? handPlayableIds;
  final bool handAllowDrag;
  final bool handDirectTapPlay;
  final bool confirmBlocked;
  final bool showConfirmPointer;

  const _BottomSection({
    required this.battle,
    required this.handReady,
    required this.onConfirm,
    required this.onDealComplete,
    required this.onCardPlay,
    this.handPlayableIds,
    this.handAllowDrag = true,
    this.handDirectTapPlay = false,
    this.confirmBlocked = false,
    this.showConfirmPointer = false,
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
                hero: battle.player.hero,
                nextSlotIsOpening: battle.player.plannedSequence[0] == null &&
                    !battle.player.statusEffects.any((e) =>
                        e.type == StatusEffectType.slotBlocked &&
                        e.value == 0),
                playableCardIds: handPlayableIds,
                allowDrag: handAllowDrag,
                directTapPlay: handDirectTapPlay,
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
            confirmBlocked: confirmBlocked,
            showConfirmPointer: showConfirmPointer,
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
      children: List.generate(GameConfig.scoutMaxTokens, (i) {
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

// ─── CHAIN LINK ───────────────────────────────────────────────────────────────

/// Eslabón entre slots del jugador: se ilumina cuando las dos cartas
/// adyacentes forman una cadena de combo.
class _ChainLink extends StatelessWidget {
  final bool active;
  const _ChainLink({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: active ? 1.0 : 0.15,
      child: Icon(
        Icons.link,
        size: 16,
        color: active ? const Color(0xFFF5B800) : Colors.white38,
        shadows: active
            ? const [Shadow(color: Color(0xFFF5B800), blurRadius: 8)]
            : null,
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
  final GameCard? revealedCard; // carta revelada por scout o apertura
  final bool canScout;
  final bool isOpening; // slot 0: apertura
  final bool openingHidden; // apertura aún oculta (falta comprometer la tuya)

  const _OpponentSlot({
    this.card,
    required this.phase,
    required this.isResolving,
    required this.width,
    required this.height,
    this.revealedCard,
    this.canScout = false,
    this.isOpening = false,
    this.openingHidden = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRevealed =
        phase == BattlePhase.resolving || phase == BattlePhase.roundEnd;
    final cardToShow = revealedCard ?? (isRevealed ? card : null);
    final isScouted = revealedCard != null && !isOpening;
    final isOpenNow =
        isOpening && phase == BattlePhase.planning && !openingHidden;
    const openingColor = Color(0xFFE5A93C);

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
                  : isOpenNow
                      ? openingColor
                      : canScout
                          ? Colors.white24
                          : const Color(0xFF2A2A3E),
          width: isScouted || isResolving || isOpenNow ? 2 : 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: cardToShow != null
                ? GameCardWidget(card: cardToShow, width: width)
                : isOpenNow
                    // Apertura vacía: el rival descansa este slot (info gratis)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hotel,
                              color: openingColor.withValues(alpha: 0.6),
                              size: height * 0.25),
                          const SizedBox(height: 2),
                          Text(
                            'descansa',
                            style: TextStyle(
                                color: openingColor.withValues(alpha: 0.6),
                                fontSize: height * 0.1),
                          ),
                        ],
                      )
                : openingHidden && phase == BattlePhase.planning
                    // Apertura oculta: se revela al comprometer la tuya
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline,
                              color: openingColor.withValues(alpha: 0.45),
                              size: height * 0.22),
                          const SizedBox(height: 2),
                          Text(
                            'poné tu\napertura',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: openingColor.withValues(alpha: 0.45),
                                fontSize: height * 0.09,
                                height: 1.2),
                          ),
                        ],
                      )
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
          // Badge "APERTURA" (slot 0 visible gratis)
          if (isOpenNow)
            Positioned(
              top: -7,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: openingColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'APERTURA',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 6.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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
                : Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GameCardWidget(card: card!, width: width),
                      // Apertura sellada: candado (no se puede quitar)
                      if (slotIndex == 0)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5A93C),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Icon(Icons.lock,
                                size: 8, color: Colors.black),
                          ),
                        ),
                    ],
                  ),
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
  final bool confirmBlocked;
  final bool showConfirmPointer;

  const _ActionBar({
    required this.battle,
    required this.onConfirm,
    this.confirmBlocked = false,
    this.showConfirmPointer = false,
  });

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
          // Botón confirmar — centrado y compacto. En el paso de confirmar del
          // tutorial se le superpone el puntero de tap.
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                TapScaleButton(
                  height: 44,
                  borderRadius: 12,
                  color: const Color(0xFFE74C3C),
                  disabledColor: const Color(0xFF2A2A3E),
                  onPressed: isPlanning && hasAnyCard && !confirmBlocked
                      ? onConfirm
                      : null,
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
                if (showConfirmPointer)
                  const Positioned(
                    right: -6,
                    top: -18,
                    child: TutorialTapPointer(size: 46),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSurrender(BuildContext context, WidgetRef ref) async {
    final confirmed = await SurrenderDialog.show(context);
    if (confirmed) ref.read(battleProvider.notifier).surrender();
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
                const _LogChip(label: '⚡ bonus', color: Color(0xFFF5B800)),
              if (slot.chainBonusBy != null)
                _LogChip(
                  label: '⛓ cadena',
                  color: slot.chainBonusBy == 'player'
                      ? const Color(0xFFF5B800)
                      : const Color(0xFFE74C3C),
                ),
              if (slot.mitigatedBy != null)
                _LogChip(
                  label: '🛡 bloqueo',
                  color: slot.mitigatedBy == 'player'
                      ? const Color(0xFF3498DB)
                      : const Color(0xFF8A8A9A),
                ),
              if (slot.affinityBy != null)
                _LogChip(
                  label: '⚡ afinidad',
                  color: slot.affinityBy == 'player'
                      ? const Color(0xFFF5B800)
                      : const Color(0xFFE74C3C),
                ),
              if (slot.rivalBy != null)
                const _LogChip(label: '💢 rival', color: Color(0xFF9B59B6)),
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

class _LogChip extends StatelessWidget {
  final String label;
  final Color color;
  const _LogChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.bold),
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

  const _HoldCardSheet({required this.hand});

  @override
  State<_HoldCardSheet> createState() => _HoldCardSheetState();
}

class _HoldCardSheetState extends State<_HoldCardSheet> {
  static const _autoContinueSeconds = 4;
  Timer? _timer;
  int _remaining = _autoContinueSeconds;

  @override
  void initState() {
    super.initState();
    // Auto-continuar: si el jugador no elige, la ronda sigue sola.
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tocá una carta para guardarla',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              // Countdown de auto-continuar
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: Center(
                  child: Text(
                    '$_remaining',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Pasa a tu próxima mano. Tocá afuera (o esperá) para no guardar.',
            style: TextStyle(color: Colors.white54, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: widget.hand.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final card = widget.hand[i];
                return GestureDetector(
                  // Un solo tap: guarda y sigue.
                  onTap: () => Navigator.of(context).pop(card),
                  child: GameCardWidget(card: card, width: 72),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
