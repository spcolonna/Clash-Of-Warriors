import 'package:flutter_test/flutter_test.dart';
import 'package:clash_of_styles/domain/config/game_config.dart';
import 'package:clash_of_styles/domain/entities/battle_state.dart';
import 'package:clash_of_styles/domain/entities/game_card.dart';
import 'package:clash_of_styles/domain/entities/hero_entity.dart';
import 'package:clash_of_styles/domain/usecases/resolve_combat_use_case.dart';

HeroEntity _hero(Faction faction) => HeroEntity(
      id: 'test_${faction.name}',
      name: 'Test',
      title: '',
      faction: faction,
      rarity: 'common',
      stats: const HeroStats(
          punch: 10, kick: 10, grapple: 10, defense: 10, dodge: 10),
      maxHp: 100,
      maxStamina: 10,
      passive: const GameCard(
        id: 'p',
        name: 'p',
        lore: '',
        category: CardCategory.punch,
        rarity: CardRarity.neutral,
        staminaCost: 0,
      ),
      lore: '',
      imagePath: '',
    );

GameCard _punch(String id, {String? factionId}) => GameCard(
      id: id,
      name: id,
      lore: '',
      category: CardCategory.punch,
      rarity: CardRarity.common,
      staminaCost: 2,
      baseDamage: 10,
      factionId: factionId,
    );

/// Golpe directo (oponente con slot vacío) → devuelve el daño del jugador.
SlotResult _directHit(HeroEntity hero, GameCard card) => CombatEngine.resolveSlot(
      slotIndex: 0,
      playerCard: card,
      opponentCard: null,
      playerHero: hero,
      opponentHero: hero,
    );

void main() {
  group('factionAffinityFor', () {
    test('misma facción = affinity', () {
      expect(factionAffinityFor(Faction.shaolin, 'shaolin'),
          FactionAffinity.affinity);
    });
    test('facción rival del lore = rival', () {
      expect(factionAffinityFor(Faction.shaolin, 'ninja'),
          FactionAffinity.rival);
      expect(factionAffinityFor(Faction.ninja, 'capoeira'),
          FactionAffinity.rival);
      expect(factionAffinityFor(Faction.judoka, 'boxer'),
          FactionAffinity.rival);
    });
    test('facción no rival = none', () {
      expect(factionAffinityFor(Faction.shaolin, 'judoka'),
          FactionAffinity.none);
    });
    test('neutral / id desconocido = none', () {
      expect(factionAffinityFor(Faction.shaolin, null), FactionAffinity.none);
      expect(factionAffinityFor(Faction.shaolin, 'xyz'), FactionAffinity.none);
    });
  });

  group('multiplicador de daño por afinidad', () {
    final hero = _hero(Faction.shaolin);
    // baseline neutral: 10 * (10/10) * 1.0 * damageScale
    final baseline = 10 * GameConfig.damageScale;

    test('carta neutral: sin cambio, sin flags', () {
      final r = _directHit(hero, _punch('neutral'));
      expect(r.playerDamageDealt, closeTo(baseline, 0.001));
      expect(r.affinityBy, isNull);
      expect(r.rivalBy, isNull);
    });

    test('carta afín: +20% y affinityBy = player', () {
      final r = _directHit(hero, _punch('aff', factionId: 'shaolin'));
      expect(r.playerDamageDealt,
          closeTo(baseline * GameConfig.factionAffinityMultiplier, 0.001));
      expect(r.affinityBy, 'player');
      expect(r.rivalBy, isNull);
    });

    test('carta rival: −20% y rivalBy = player', () {
      final r = _directHit(hero, _punch('riv', factionId: 'ninja'));
      expect(r.playerDamageDealt,
          closeTo(baseline * GameConfig.factionRivalMultiplier, 0.001));
      expect(r.rivalBy, 'player');
      expect(r.affinityBy, isNull);
    });

    test('el bot también recibe afinidad (opponentDamage)', () {
      final ninjaHero = _hero(Faction.ninja);
      final r = CombatEngine.resolveSlot(
        slotIndex: 0,
        playerCard: null,
        opponentCard: _punch('ninjacard', factionId: 'ninja'),
        playerHero: _hero(Faction.shaolin),
        opponentHero: ninjaHero,
      );
      expect(r.opponentDamageDealt,
          closeTo(baseline * GameConfig.factionAffinityMultiplier, 0.001));
      expect(r.affinityBy, 'opponent');
    });
  });
}
