import 'technique.dart';
import '../config/game_config.dart';

class HeroStats {
  final int fist;
  final int kick;
  final int grapple;
  final int block;
  final int palm;

  const HeroStats({
    required this.fist,
    required this.kick,
    required this.grapple,
    required this.block,
    required this.palm,
  });

  int get(Technique t) {
    switch (t) {
      case Technique.fist: return fist;
      case Technique.kick: return kick;
      case Technique.grapple: return grapple;
      case Technique.block: return block;
      case Technique.palm: return palm;
    }
  }

  HeroStats withLevel(int level) {
    final bonus = (level - 1) * GameConfig.statBonusPerLevel;
    return HeroStats(
      fist: fist + bonus,
      kick: kick + bonus,
      grapple: grapple + bonus,
      block: block + bonus,
      palm: palm + bonus,
    );
  }
}

class HeroMoves {
  final String fist;
  final String kick;
  final String grapple;
  final String block;
  final String palm;

  const HeroMoves({
    required this.fist,
    required this.kick,
    required this.grapple,
    required this.block,
    required this.palm,
  });

  String get(Technique t) {
    switch (t) {
      case Technique.fist: return fist;
      case Technique.kick: return kick;
      case Technique.grapple: return grapple;
      case Technique.block: return block;
      case Technique.palm: return palm;
    }
  }
}

class GameHero {
  final String id;
  final String nameKey;    // l10n key
  final String descKey;    // l10n key
  final String loreKey;    // l10n key
  final String spriteAsset;
  final HeroStats baseStats;
  final HeroMoves moves;   // move name l10n keys
  final String rivalId;
  final String allyId;

  const GameHero({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.loreKey,
    required this.spriteAsset,
    required this.baseStats,
    required this.moves,
    required this.rivalId,
    required this.allyId,
  });

  HeroStats statsAtLevel(int level) => baseStats.withLevel(level);
}

/// ═══ REGISTRO DE HÉROES ════════════════════════════════
/// Cambiar stats, moves, relaciones acá afecta todo el juego.
class HeroRegistry {
  static const List<GameHero> all = [
    GameHero(
      id: 'karate', nameKey: 'hero_karate', descKey: 'hero_karate_desc',
      loreKey: 'hero_karate_lore', spriteAsset: 'heroes/karate.png',
      baseStats: HeroStats(fist: 3, kick: 2, grapple: 1, block: 4, palm: 5),
      moves: HeroMoves(fist: 'move_karate_fist', kick: 'move_karate_kick', grapple: 'move_karate_grapple', block: 'move_karate_block', palm: 'move_karate_palm'),
      rivalId: 'muaythai', allyId: 'taichi',
    ),
    GameHero(
      id: 'templar', nameKey: 'hero_templar', descKey: 'hero_templar_desc',
      loreKey: 'hero_templar_lore', spriteAsset: 'heroes/templar.png',
      baseStats: HeroStats(fist: 4, kick: 2, grapple: 3, block: 5, palm: 1),
      moves: HeroMoves(fist: 'move_templar_fist', kick: 'move_templar_kick', grapple: 'move_templar_grapple', block: 'move_templar_block', palm: 'move_templar_palm'),
      rivalId: 'viking', allyId: 'shaman',
    ),
    GameHero(
      id: 'ninja', nameKey: 'hero_ninja', descKey: 'hero_ninja_desc',
      loreKey: 'hero_ninja_lore', spriteAsset: 'heroes/ninja.png',
      baseStats: HeroStats(fist: 2, kick: 5, grapple: 1, block: 2, palm: 5),
      moves: HeroMoves(fist: 'move_ninja_fist', kick: 'move_ninja_kick', grapple: 'move_ninja_grapple', block: 'move_ninja_block', palm: 'move_ninja_palm'),
      rivalId: 'pirate', allyId: 'samurai',
    ),
    GameHero(
      id: 'sumo', nameKey: 'hero_sumo', descKey: 'hero_sumo_desc',
      loreKey: 'hero_sumo_lore', spriteAsset: 'heroes/sumo.png',
      baseStats: HeroStats(fist: 2, kick: 1, grapple: 5, block: 5, palm: 2),
      moves: HeroMoves(fist: 'move_sumo_fist', kick: 'move_sumo_kick', grapple: 'move_sumo_grapple', block: 'move_sumo_block', palm: 'move_sumo_palm'),
      rivalId: 'wrestler', allyId: 'gladiator',
    ),
    GameHero(
      id: 'kungfu', nameKey: 'hero_kungfu', descKey: 'hero_kungfu_desc',
      loreKey: 'hero_kungfu_lore', spriteAsset: 'heroes/kungfu.png',
      baseStats: HeroStats(fist: 5, kick: 4, grapple: 2, block: 1, palm: 3),
      moves: HeroMoves(fist: 'move_kungfu_fist', kick: 'move_kungfu_kick', grapple: 'move_kungfu_grapple', block: 'move_kungfu_block', palm: 'move_kungfu_palm'),
      rivalId: 'capoeira', allyId: 'wushu',
    ),
    GameHero(
      id: 'samurai', nameKey: 'hero_samurai', descKey: 'hero_samurai_desc',
      loreKey: 'hero_samurai_lore', spriteAsset: 'heroes/samurai.png',
      baseStats: HeroStats(fist: 4, kick: 3, grapple: 1, block: 2, palm: 5),
      moves: HeroMoves(fist: 'move_samurai_fist', kick: 'move_samurai_kick', grapple: 'move_samurai_grapple', block: 'move_samurai_block', palm: 'move_samurai_palm'),
      rivalId: 'spartan', allyId: 'ninja',
    ),
    GameHero(
      id: 'gladiator', nameKey: 'hero_gladiator', descKey: 'hero_gladiator_desc',
      loreKey: 'hero_gladiator_lore', spriteAsset: 'heroes/gladiator.png',
      baseStats: HeroStats(fist: 3, kick: 4, grapple: 5, block: 2, palm: 1),
      moves: HeroMoves(fist: 'move_gladiator_fist', kick: 'move_gladiator_kick', grapple: 'move_gladiator_grapple', block: 'move_gladiator_block', palm: 'move_gladiator_palm'),
      rivalId: 'viking', allyId: 'spartan',
    ),
    GameHero(
      id: 'monk', nameKey: 'hero_monk', descKey: 'hero_monk_desc',
      loreKey: 'hero_monk_lore', spriteAsset: 'heroes/monk.png',
      baseStats: HeroStats(fist: 1, kick: 1, grapple: 3, block: 5, palm: 5),
      moves: HeroMoves(fist: 'move_monk_fist', kick: 'move_monk_kick', grapple: 'move_monk_grapple', block: 'move_monk_block', palm: 'move_monk_palm'),
      rivalId: 'berserker', allyId: 'taichi',
    ),
    GameHero(
      id: 'viking', nameKey: 'hero_viking', descKey: 'hero_viking_desc',
      loreKey: 'hero_viking_lore', spriteAsset: 'heroes/viking.png',
      baseStats: HeroStats(fist: 5, kick: 3, grapple: 4, block: 2, palm: 1),
      moves: HeroMoves(fist: 'move_viking_fist', kick: 'move_viking_kick', grapple: 'move_viking_grapple', block: 'move_viking_block', palm: 'move_viking_palm'),
      rivalId: 'templar', allyId: 'mongol',
    ),
    GameHero(
      id: 'capoeira', nameKey: 'hero_capoeira', descKey: 'hero_capoeira_desc',
      loreKey: 'hero_capoeira_lore', spriteAsset: 'heroes/capoeira.png',
      baseStats: HeroStats(fist: 1, kick: 5, grapple: 2, block: 3, palm: 4),
      moves: HeroMoves(fist: 'move_capoeira_fist', kick: 'move_capoeira_kick', grapple: 'move_capoeira_grapple', block: 'move_capoeira_block', palm: 'move_capoeira_palm'),
      rivalId: 'kungfu', allyId: 'amazon',
    ),
    GameHero(
      id: 'spartan', nameKey: 'hero_spartan', descKey: 'hero_spartan_desc',
      loreKey: 'hero_spartan_lore', spriteAsset: 'heroes/spartan.png',
      baseStats: HeroStats(fist: 3, kick: 2, grapple: 4, block: 5, palm: 1),
      moves: HeroMoves(fist: 'move_spartan_fist', kick: 'move_spartan_kick', grapple: 'move_spartan_grapple', block: 'move_spartan_block', palm: 'move_spartan_palm'),
      rivalId: 'samurai', allyId: 'gladiator',
    ),
    GameHero(
      id: 'muaythai', nameKey: 'hero_muaythai', descKey: 'hero_muaythai_desc',
      loreKey: 'hero_muaythai_lore', spriteAsset: 'heroes/muaythai.png',
      baseStats: HeroStats(fist: 4, kick: 5, grapple: 2, block: 3, palm: 1),
      moves: HeroMoves(fist: 'move_muaythai_fist', kick: 'move_muaythai_kick', grapple: 'move_muaythai_grapple', block: 'move_muaythai_block', palm: 'move_muaythai_palm'),
      rivalId: 'karate', allyId: 'wrestler',
    ),
    GameHero(
      id: 'taichi', nameKey: 'hero_taichi', descKey: 'hero_taichi_desc',
      loreKey: 'hero_taichi_lore', spriteAsset: 'heroes/taichi.png',
      baseStats: HeroStats(fist: 1, kick: 2, grapple: 3, block: 4, palm: 5),
      moves: HeroMoves(fist: 'move_taichi_fist', kick: 'move_taichi_kick', grapple: 'move_taichi_grapple', block: 'move_taichi_block', palm: 'move_taichi_palm'),
      rivalId: 'berserker', allyId: 'monk',
    ),
    GameHero(
      id: 'wrestler', nameKey: 'hero_wrestler', descKey: 'hero_wrestler_desc',
      loreKey: 'hero_wrestler_lore', spriteAsset: 'heroes/wrestler.png',
      baseStats: HeroStats(fist: 2, kick: 1, grapple: 5, block: 4, palm: 3),
      moves: HeroMoves(fist: 'move_wrestler_fist', kick: 'move_wrestler_kick', grapple: 'move_wrestler_grapple', block: 'move_wrestler_block', palm: 'move_wrestler_palm'),
      rivalId: 'sumo', allyId: 'muaythai',
    ),
    GameHero(
      id: 'pirate', nameKey: 'hero_pirate', descKey: 'hero_pirate_desc',
      loreKey: 'hero_pirate_lore', spriteAsset: 'heroes/pirate.png',
      baseStats: HeroStats(fist: 4, kick: 3, grapple: 4, block: 1, palm: 3),
      moves: HeroMoves(fist: 'move_pirate_fist', kick: 'move_pirate_kick', grapple: 'move_pirate_grapple', block: 'move_pirate_block', palm: 'move_pirate_palm'),
      rivalId: 'ninja', allyId: 'amazon',
    ),
    GameHero(
      id: 'amazon', nameKey: 'hero_amazon', descKey: 'hero_amazon_desc',
      loreKey: 'hero_amazon_lore', spriteAsset: 'heroes/amazon.png',
      baseStats: HeroStats(fist: 3, kick: 4, grapple: 1, block: 3, palm: 4),
      moves: HeroMoves(fist: 'move_amazon_fist', kick: 'move_amazon_kick', grapple: 'move_amazon_grapple', block: 'move_amazon_block', palm: 'move_amazon_palm'),
      rivalId: 'mongol', allyId: 'capoeira',
    ),
    GameHero(
      id: 'shaman', nameKey: 'hero_shaman', descKey: 'hero_shaman_desc',
      loreKey: 'hero_shaman_lore', spriteAsset: 'heroes/shaman.png',
      baseStats: HeroStats(fist: 1, kick: 2, grapple: 2, block: 5, palm: 5),
      moves: HeroMoves(fist: 'move_shaman_fist', kick: 'move_shaman_kick', grapple: 'move_shaman_grapple', block: 'move_shaman_block', palm: 'move_shaman_palm'),
      rivalId: 'gladiator', allyId: 'templar',
    ),
    GameHero(
      id: 'berserker', nameKey: 'hero_berserker', descKey: 'hero_berserker_desc',
      loreKey: 'hero_berserker_lore', spriteAsset: 'heroes/berserker.png',
      baseStats: HeroStats(fist: 5, kick: 5, grapple: 3, block: 1, palm: 1),
      moves: HeroMoves(fist: 'move_berserker_fist', kick: 'move_berserker_kick', grapple: 'move_berserker_grapple', block: 'move_berserker_block', palm: 'move_berserker_palm'),
      rivalId: 'monk', allyId: 'viking',
    ),
    GameHero(
      id: 'wushu', nameKey: 'hero_wushu', descKey: 'hero_wushu_desc',
      loreKey: 'hero_wushu_lore', spriteAsset: 'heroes/wushu.png',
      baseStats: HeroStats(fist: 3, kick: 4, grapple: 1, block: 2, palm: 5),
      moves: HeroMoves(fist: 'move_wushu_fist', kick: 'move_wushu_kick', grapple: 'move_wushu_grapple', block: 'move_wushu_block', palm: 'move_wushu_palm'),
      rivalId: 'amazon', allyId: 'kungfu',
    ),
    GameHero(
      id: 'mongol', nameKey: 'hero_mongol', descKey: 'hero_mongol_desc',
      loreKey: 'hero_mongol_lore', spriteAsset: 'heroes/mongol.png',
      baseStats: HeroStats(fist: 4, kick: 2, grapple: 5, block: 3, palm: 1),
      moves: HeroMoves(fist: 'move_mongol_fist', kick: 'move_mongol_kick', grapple: 'move_mongol_grapple', block: 'move_mongol_block', palm: 'move_mongol_palm'),
      rivalId: 'amazon', allyId: 'viking',
    ),
  ];

  static GameHero getById(String id) => all.firstWhere((h) => h.id == id);
  static GameHero? findById(String id) {
    try { return getById(id); } catch (_) { return null; }
  }
}
