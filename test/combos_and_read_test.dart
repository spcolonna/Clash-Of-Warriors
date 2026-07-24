import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/entities/battle_state.dart';
import 'package:clash_of_styles/domain/entities/game_card.dart';
import 'package:clash_of_styles/domain/entities/hero_entity.dart';
import 'package:clash_of_styles/domain/usecases/resolve_combat_use_case.dart';

HeroEntity _hero() => HeroEntity(
      id: 'h',
      name: 'H',
      title: '',
      faction: Faction.boxer,
      rarity: 'common',
      stats: const HeroStats(punch: 10, kick: 10, grapple: 10, defense: 10, dodge: 10),
      maxHp: 100,
      maxStamina: 10,
      passive: const GameCard(id: 'p', name: 'p', lore: '', category: CardCategory.punch, rarity: CardRarity.neutral, staminaCost: 0),
      lore: '',
      imagePath: '',
    );

GameCard _card(String id, CardCategory cat, {int dmg = 10}) => GameCard(
      id: id, name: id, lore: '', category: cat, rarity: CardRarity.common,
      staminaCost: 1, baseDamage: dmg,
    );

CombatantState _combatant(List<GameCard?> seq, {int hp = 100}) => CombatantState(
      hero: _hero(), currentHp: hp, currentStamina: 10,
      hand: const [], deck: const [], discardPile: const [], plannedSequence: seq,
    );

void main() {
  group('Combos posicionales', () {
    test('One-Two: dos Puños seguidos → combo con daño extra', () {
      // Jugador: Puño, Puño, vacío. Oponente: descansa (slots vacíos) → el
      // jugador gana los golpes sin resistencia.
      final res = CombatEngine.resolveRound(
        roundNumber: 1,
        player: _combatant([_card('p1', CardCategory.punch), _card('p2', CardCategory.punch), null]),
        opponent: _combatant([null, null, null]),
      );
      expect(res.playerComboName, 'One-Two');
      expect(res.playerComboDamage, greaterThan(0));
    });

    test('Tortuga: 3 Defensas → cura, sin daño extra', () {
      final res = CombatEngine.resolveRound(
        roundNumber: 1,
        player: _combatant([_card('d1', CardCategory.defense), _card('d2', CardCategory.defense), _card('d3', CardCategory.defense)]),
        opponent: _combatant([null, null, null]),
      );
      expect(res.playerComboName, 'Tortuga');
      expect(res.playerComboHeal, greaterThan(0));
      expect(res.playerComboDamage, 0);
    });

    test('sin secuencia especial → sin combo', () {
      final res = CombatEngine.resolveRound(
        roundNumber: 1,
        player: _combatant([_card('p', CardCategory.punch), _card('k', CardCategory.kick), null]),
        opponent: _combatant([null, null, null]),
      );
      expect(res.playerComboName, isNull);
    });
  });

  group('Lectura (castigo a la repetición)', () {
    test('counter a categoría repetida → daño ×2 y readBy', () {
      // Oponente repite Puño en slot 0 y 1. El jugador juega algo que pierde en
      // slot 0 y el counter (Defensa vence a Puño) en slot 1 → lectura.
      final prev = <SlotResult>[
        const SlotResult(
          slotIndex: 0, playerCard: null,
          opponentCard: GameCard(id: 'op0', name: 'op0', lore: '', category: CardCategory.punch, rarity: CardRarity.common, staminaCost: 1, baseDamage: 10),
          playerDamageDealt: 0, opponentDamageDealt: 10, winner: 'opponent', narrative: '',
        ),
      ];
      final res = CombatEngine.resolveSlot(
        slotIndex: 1,
        playerCard: _card('def', CardCategory.defense),
        opponentCard: _card('op1', CardCategory.punch), // repite Puño
        playerHero: _hero(),
        opponentHero: _hero(),
        previousSlotResults: prev,
      );
      expect(res.winner, 'player'); // Defensa vence a Puño
      expect(res.readBy, 'player');
    });

    test('sin repetición → sin lectura', () {
      final prev = <SlotResult>[
        const SlotResult(
          slotIndex: 0, playerCard: null,
          opponentCard: GameCard(id: 'op0', name: 'op0', lore: '', category: CardCategory.kick, rarity: CardRarity.common, staminaCost: 1, baseDamage: 10),
          playerDamageDealt: 0, opponentDamageDealt: 10, winner: 'opponent', narrative: '',
        ),
      ];
      final res = CombatEngine.resolveSlot(
        slotIndex: 1,
        playerCard: _card('def', CardCategory.defense),
        opponentCard: _card('op1', CardCategory.punch), // NO repite (antes kick)
        playerHero: _hero(),
        opponentHero: _hero(),
        previousSlotResults: prev,
      );
      expect(res.readBy, isNull);
    });
  });
}
