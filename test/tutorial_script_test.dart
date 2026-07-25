import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/config/game_config.dart';
import 'package:clash_of_styles/domain/entities/battle_state.dart';
import 'package:clash_of_styles/domain/entities/game_card.dart';
import 'package:clash_of_styles/domain/entities/hero_entity.dart';
import 'package:clash_of_styles/domain/usecases/resolve_combat_use_case.dart';
import 'package:clash_of_styles/infra/local/tutorial_script.dart';

HeroEntity _hero() => HeroEntity(
      id: 'h', name: 'H', title: '', faction: Faction.boxer, rarity: 'common',
      stats: const HeroStats(punch: 10, kick: 10, grapple: 10, defense: 10, dodge: 10),
      maxHp: 100, maxStamina: 10,
      passive: const GameCard(id: 'p', name: 'p', lore: '', category: CardCategory.punch, rarity: CardRarity.neutral, staminaCost: 0),
      lore: '', imagePath: '',
    );

CombatantState _c(List<GameCard?> seq) => CombatantState(
      hero: _hero(), currentHp: 100, currentStamina: 10, hand: const [],
      deck: const [], discardPile: const [], plannedSequence: seq);

void main() {
  group('Guion del tutorial', () {
    test('la mano fija resuelve a cartas reales', () {
      final hand = TutorialScript.playerHand();
      expect(hand.length, greaterThanOrEqualTo(3));
      expect(hand.every((c) => c.baseDamage != null), isTrue);
    });

    test('secuencia del bot ronda 1: apertura Patada + Defensa', () {
      final seq = TutorialScript.botSequence(1);
      expect(seq[0]!.category, CardCategory.kick);   // Patada (tu Puño gana)
      expect(seq[1]!.category, CardCategory.defense); // Defensa (tu Patada gana)
      expect(seq[2], isNull);
    });

    test('stepIndex mapea rondas a los pasos', () {
      expect(TutorialScript.stepIndex(1, 0), 0);
      expect(TutorialScript.stepIndex(1, 2), 2);
      expect(TutorialScript.stepIndex(2, 0), 3);
      // Los steps existen para todos los índices que puede pedir el guion.
      expect(TutorialScript.steps.length, greaterThanOrEqualTo(5));
    });

    // ── Este test ATRAPA el soft-lock: las cartas forzadas de cada ronda
    // deben entrar en la stamina de esa ronda, o la 2da carta queda injugable.
    test('las cartas forzadas de cada ronda entran en la stamina disponible', () {
      // Agrupar los requiredCardId por forcedSlot dentro de cada ronda.
      double costOf(String id) => TutorialScript.card(id)!.staminaCost.toDouble();

      for (int round = 1; round <= TutorialScript.totalRounds; round++) {
        final base = (round - 1) * 3;
        double sum = 0;
        for (int s = 0; s < 3; s++) {
          final idx = base + s;
          if (idx >= TutorialScript.steps.length) break;
          final step = TutorialScript.steps[idx];
          if (step.requiredCardId != null) sum += costOf(step.requiredCardId!);
        }
        final stamina = GameConfig.staminaForRound(round, 20);
        expect(sum, lessThanOrEqualTo(stamina.toDouble()),
            reason: 'Las cartas de la ronda $round ($sum) superan la stamina ($stamina)');
      }
    });

    test('en modo Normal, la ronda 1 del guion: gano ambos slots y encadeno', () {
      // Jugador: las dos cartas forzadas de la ronda 1 (Puño luego Patada).
      final player = _c([
        TutorialScript.card(TutorialScript.steps[0].requiredCardId!),
        TutorialScript.card(TutorialScript.steps[1].requiredCardId!),
        null,
      ]);
      final opponent = _c(TutorialScript.botSequence(1));
      final res = CombatEngine.resolveRound(
        roundNumber: 1, player: player, opponent: opponent,
        mode: GameMode.normal,
      );
      expect(res.slotResults[0].winner, 'player'); // Puño > Patada
      expect(res.slotResults[1].winner, 'player'); // Patada > Defensa
      expect(res.slotResults[1].chainBonusBy, 'player'); // cadena Puño→Patada
    });

    test('ronda 2: mi Defensa le gana al Puño del rival', () {
      final player = _c([
        TutorialScript.card(TutorialScript.steps[3].requiredCardId!), // Defensa
        null, null,
      ]);
      final opponent = _c(TutorialScript.botSequence(2)); // slot0 = Puño
      final res = CombatEngine.resolveRound(
        roundNumber: 2, player: player, opponent: opponent,
        mode: GameMode.normal,
      );
      expect(res.slotResults[0].winner, 'player'); // Defensa > Puño
    });
  });
}
