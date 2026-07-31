import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/entities/battle_state.dart';
import 'package:clash_of_styles/domain/entities/game_card.dart';
import 'package:clash_of_styles/domain/entities/hero_entity.dart';
import 'package:clash_of_styles/domain/usecases/resolve_combat_use_case.dart';

HeroEntity _hero() => HeroEntity(
      id: 'h', name: 'H', title: '', faction: Faction.boxer, rarity: 'common',
      stats: const HeroStats(punch: 10, kick: 10, grapple: 10, defense: 10, dodge: 10),
      maxHp: 100, maxStamina: 10,
      passive: const GameCard(id: 'p', name: 'p', lore: '',
          category: CardCategory.punch, rarity: CardRarity.neutral, staminaCost: 0),
      lore: '', imagePath: '',
    );

GameCard _card(CardCategory cat, {String id = 'c', int dmg = 10}) => GameCard(
      id: id, name: id, lore: '', category: cat,
      rarity: CardRarity.neutral, staminaCost: 1, baseDamage: dmg,
    );

CombatantState _c(List<GameCard?> seq) => CombatantState(
      hero: _hero(), currentHp: 100, currentStamina: 10, hand: const [],
      deck: const [], discardPile: const [], plannedSequence: seq);

void main() {
  group('Daño con slots vacíos', () {
    // El síntoma reportado: "gané un slot sin carta del rival enfrente y aun
    // así me sacó vida". El slot en sí está bien; lo que faltaba era avisar.
    test('si el rival no juega carta, el jugador no recibe daño en ese slot', () {
      final res = CombatEngine.resolveRound(
        roundNumber: 1,
        player: _c([_card(CardCategory.punch), null, null]),
        opponent: _c([null, null, null]),
      );
      final slot0 = res.slotResults[0];
      expect(slot0.winner, 'player');
      expect(slot0.opponentDamageDealt, 0);
      expect(slot0.playerDamageDealt, greaterThan(0));
      expect(res.totalOpponentDamage, 0);
    });

    test('los slots vacíos conservan su índice real', () {
      final res = CombatEngine.resolveRound(
        roundNumber: 1,
        player: _c([_card(CardCategory.punch), null, null]),
        opponent: _c([_card(CardCategory.kick), null, null]),
      );
      // Antes el caso "ambos vacíos" devolvía slotIndex 0 fijo, así que la UI
      // buscaba por índice y mostraba el badge de otro slot.
      for (int i = 0; i < res.slotResults.length; i++) {
        expect(res.slotResults[i].slotIndex, i);
      }
    });
  });

  group('Combos', () {
    // One-Two exigía solo hacer daño en el slot 1, y en un empate ambos lados
    // hacen daño: el rival cobraba combo sin haber ganado nada.
    test('One-Two no se dispara si el segundo slot fue empate', () {
      final punch = _card(CardCategory.punch);
      final res = CombatEngine.resolveRound(
        roundNumber: 1,
        // Ambos Puño en los dos slots → los dos empatan.
        player: _c([punch, punch, null]),
        opponent: _c([punch, punch, null]),
      );
      expect(res.slotResults[1].winner, 'tie');
      expect(res.playerComboName, isNull);
      expect(res.opponentComboName, isNull);
      expect(res.opponentComboDamage, 0);
    });

    test('One-Two sí se dispara ganando el segundo slot', () {
      final res = CombatEngine.resolveRound(
        roundNumber: 1,
        player: _c([
          _card(CardCategory.punch),
          _card(CardCategory.punch),
          null,
        ]),
        // Patada en el slot 1 → el Puño del jugador gana ese slot.
        opponent: _c([null, _card(CardCategory.kick), null]),
      );
      expect(res.slotResults[1].winner, 'player');
      expect(res.playerComboName, 'One-Two');
      expect(res.playerComboDamage, greaterThan(0));
    });
  });

  group('Modo Normal con categorías fuera de tabla', () {
    // Agarre/Esquive no existen en el RPS de 3, pero llegan por la pasiva.
    // Antes caían en "empate" y ambos lados recibían daño sin motivo.
    test('la carta fuera de tabla gana en vez de empatar con daño mutuo', () {
      final res = CombatEngine.resolveRound(
        roundNumber: 1,
        player: _c([_card(CardCategory.grapple), null, null]),
        opponent: _c([_card(CardCategory.punch), null, null]),
        mode: GameMode.normal,
      );
      final slot0 = res.slotResults[0];
      expect(slot0.winner, 'player');
      expect(slot0.opponentDamageDealt, 0);
    });

    test('dos cartas fuera de tabla siguen empatando', () {
      final res = CombatEngine.resolveRound(
        roundNumber: 1,
        player: _c([_card(CardCategory.grapple), null, null]),
        opponent: _c([_card(CardCategory.dodge), null, null]),
        mode: GameMode.normal,
      );
      expect(res.slotResults[0].winner, 'tie');
    });
  });
}
