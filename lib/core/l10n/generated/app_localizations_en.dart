// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Warriors Arena';

  @override
  String get login_title => 'WARRIORS ARENA';

  @override
  String get login_subtitle => 'TACTICAL COMBAT';

  @override
  String get login_placeholder => 'Name...';

  @override
  String get login_prompt => 'Enter your warrior name';

  @override
  String get login_enter => 'ENTER';

  @override
  String home_hello(String name) {
    return 'Hey, $name';
  }

  @override
  String get home_ready => 'Ready to fight?';

  @override
  String get home_1v1 => '⚔️ FIGHT 1v1';

  @override
  String get home_3v3 => '🏆 BATTLE 3v3';

  @override
  String get home_story => '📜 LEGEND MODE';

  @override
  String get home_ranking => '🏆 RANKING';

  @override
  String get home_shop => '🛒 SHOP';

  @override
  String get home_upgrades => '⬆️ UPGRADES';

  @override
  String get home_rules => '📜 RULES';

  @override
  String get home_pro_teaser_title => '🔥 LEGEND MODE';

  @override
  String get home_pro_teaser_desc =>
      'Unlock heroes, level up, improve stats and compete in 3v3.';

  @override
  String get home_pro_teaser_cta => 'ACTIVATE PRO →';

  @override
  String get heroes_title => 'CHOOSE YOUR WARRIOR';

  @override
  String get heroes_subtitle => 'Tap to see details';

  @override
  String heroes_unlock(int cost) {
    return '🔓 UNLOCK ($cost 🪙)';
  }

  @override
  String get heroes_choose => 'CHOOSE →';

  @override
  String get heroes_lore_btn => '🔄 VIEW LORE & MOVES';

  @override
  String get heroes_stats_btn => '🔄 VIEW STATS';

  @override
  String get heroes_first => '⭐ MY FIRST WARRIOR';

  @override
  String get diff_title => 'DIFFICULTY';

  @override
  String get diff_easy => 'Easy';

  @override
  String get diff_easy_desc => 'Picks randomly';

  @override
  String get diff_normal => 'Normal';

  @override
  String get diff_normal_desc => 'Uses best stats';

  @override
  String get diff_hard => 'Hard';

  @override
  String get diff_hard_desc => 'Reads your moves';

  @override
  String get diff_go => '⚔️ TO THE ARENA!';

  @override
  String battle_round(int n) {
    return 'ROUND $n';
  }

  @override
  String get battle_pick => 'CHOOSE YOUR TECHNIQUE';

  @override
  String get battle_fighting => 'FIGHTING!';

  @override
  String get battle_win => 'YOU WIN!';

  @override
  String get battle_lose => 'YOU LOSE';

  @override
  String get battle_draw => 'DRAW!';

  @override
  String get battle_next => 'NEXT ROUND →';

  @override
  String get battle_ref => '📖 REF';

  @override
  String get battle_history => 'HISTORY';

  @override
  String battle_power(int n) {
    return 'Power $n';
  }

  @override
  String get battle_beats => 'beats';

  @override
  String battle3v3_round(int n) {
    return '🏆 ROUND $n';
  }

  @override
  String get battle3v3_subtitle =>
      '1 technique = attack + defense · Simultaneous resolution';

  @override
  String get battle3v3_enemies => '⚔️ ENEMIES';

  @override
  String get battle3v3_your_team => '🛡️ YOUR TEAM';

  @override
  String battle3v3_pick_tech(String name) {
    return '$name: pick TECHNIQUE';
  }

  @override
  String get battle3v3_pick_hint =>
      '⚔️ Attack and 🛡️ defend with the same technique';

  @override
  String battle3v3_pick_target(String name) {
    return '$name: who to attack?';
  }

  @override
  String get battle3v3_target_hint =>
      'Tap an enemy above · Your technique also defends';

  @override
  String get battle3v3_all_ready => '✅ All warriors ready';

  @override
  String get battle3v3_execute => '⚔️ EXECUTE ROUND!';

  @override
  String get battle3v3_your_attacks => '⚔️ YOUR ATTACKS';

  @override
  String get battle3v3_rival_attacks =>
      '🛡️ RIVAL ATTACKS — Your technique defends';

  @override
  String get battle3v3_focus_fire => '🎯 FOCUS FIRE';

  @override
  String get battle3v3_next_round => 'NEXT ROUND →';

  @override
  String get battle3v3_tap_advance => 'Tap to advance';

  @override
  String get battle3v3_your_attack => '⚔️ YOUR ATTACK';

  @override
  String get battle3v3_rival_attack => '🛡️ RIVAL ATTACK';

  @override
  String anim_hit(int n) {
    return 'HIT! −$n HP';
  }

  @override
  String get anim_blocked => 'BLOCKED!';

  @override
  String anim_draw_dmg(int n) {
    return 'DRAW −$n HP';
  }

  @override
  String get anim_draw_neutral => 'NEUTRAL DRAW';

  @override
  String get result_victory => 'VICTORY!';

  @override
  String get result_defeat => 'DEFEAT';

  @override
  String get result_draw => 'DRAW';

  @override
  String get result_victory_3v3 => '3v3 VICTORY!';

  @override
  String get result_defeat_3v3 => '3v3 DEFEAT';

  @override
  String get result_draw_3v3 => '3v3 DRAW';

  @override
  String result_rounds(int n) {
    return '$n rounds';
  }

  @override
  String get result_rematch => '⚔️ REMATCH';

  @override
  String get result_change_hero => '🔄 CHANGE WARRIOR';

  @override
  String get result_menu => 'MAIN MENU';

  @override
  String get result_another_3v3 => '🏆 ANOTHER 3v3';

  @override
  String get rank_title => '🏆 RANKING';

  @override
  String get rank_empty => 'No warriors yet';

  @override
  String get rank_wins => 'Wins';

  @override
  String get rank_elo => 'ELO';

  @override
  String get rank_streak => 'Streak';

  @override
  String get settings_title => '⚙️ SETTINGS';

  @override
  String get settings_pro => 'PRO Mode';

  @override
  String get settings_pro_desc_on => 'Progression, levels, 3v3';

  @override
  String get settings_pro_desc_off => '\$2.99 to unlock';

  @override
  String get settings_tokens => '🪙 Tokens';

  @override
  String get settings_close => 'CLOSE';

  @override
  String get shop_title => '🛒 SHOP';

  @override
  String get shop_tokens_title => 'TOKEN PACKS';

  @override
  String get shop_special_title => 'SPECIAL PACKS';

  @override
  String get shop_pack_handful => 'Handful of Tokens';

  @override
  String get shop_pack_bag => 'Bag of Tokens';

  @override
  String get shop_pack_chest => 'Token Chest';

  @override
  String get shop_pack_treasure => 'Legendary Treasure';

  @override
  String get shop_special_warrior => 'Warrior Pack';

  @override
  String get shop_special_warrior_desc => '1 random hero + 300 tokens';

  @override
  String get shop_special_legend => 'Legend Pack';

  @override
  String get shop_special_legend_desc => '3 random heroes + 800 tokens';

  @override
  String get shop_special_ultimate => 'Ultimate Pack';

  @override
  String get shop_special_ultimate_desc => 'All heroes + 2000 tokens';

  @override
  String get shop_popular => 'POPULAR';

  @override
  String get shop_confirm_title => 'CONFIRM PURCHASE';

  @override
  String shop_confirm_charge(String price) {
    return '$price will be charged';
  }

  @override
  String get shop_confirm_btn => '✅ CONFIRM PURCHASE';

  @override
  String get shop_cancel => 'CANCEL';

  @override
  String get shop_success => 'PURCHASE SUCCESSFUL!';

  @override
  String get shop_tokens_total => 'total tokens';

  @override
  String get shop_heroes_unlocked => 'HEROES UNLOCKED';

  @override
  String get shop_great => 'GREAT!';

  @override
  String get upgrade_title => '⬆️ UPGRADES';

  @override
  String get upgrade_level_up => 'LEVEL UP';

  @override
  String get upgrade_unlock_heroes => 'UNLOCK HEROES';

  @override
  String upgrade_cards(int have, int need) {
    return 'Cards: $have/$need';
  }

  @override
  String upgrade_improve(int cost) {
    return 'UPGRADE ($cost 🪙)';
  }

  @override
  String get upgrade_new_warrior => 'NEW WARRIOR!';

  @override
  String get upgrade_level_up_title => 'LEVEL UP!';

  @override
  String get upgrade_card_obtained => 'CARD OBTAINED';

  @override
  String get upgrade_stats_plus1 => 'All stats +1';

  @override
  String upgrade_remaining(int n) {
    return '🪙 $n tokens remaining';
  }

  @override
  String upgrade_more_for(int n, int lv) {
    return '$n more for level $lv';
  }

  @override
  String get story_title => 'LEGEND MODE';

  @override
  String get story_subtitle => 'Tournament of the Ages — Choose your hero';

  @override
  String story_chapters(int n, int total) {
    return '$n/$total chapters';
  }

  @override
  String get story_locked => 'LOCKED HEROES';

  @override
  String get story_play => 'PLAY →';

  @override
  String get story_boss => '⚠️ BOSS';

  @override
  String get story_final => 'FINAL';

  @override
  String get story_combat => 'Combat';

  @override
  String get story_next => 'NEXT →';

  @override
  String get story_fight => '⚔️ FIGHT!';

  @override
  String get story_continue => 'CONTINUE →';

  @override
  String get story_complete => '🏆 COMPLETE';

  @override
  String get story_retry => '🔄 RETRY';

  @override
  String get story_completed_title => 'LEGEND COMPLETED!';

  @override
  String story_completed_desc(String name) {
    return '$name has freed the Arena';
  }

  @override
  String get story_another => '📜 ANOTHER LEGEND';

  @override
  String get story_epilogue =>
      'The Oracle has been defeated and the trapped warriors are free. But the Arena always returns...';

  @override
  String get team_title => '🏆 BATTLE 3v3';

  @override
  String get team_subtitle => 'Choose 3 warriors';

  @override
  String get rules_title => 'RULES';

  @override
  String get rules_damage => 'Damage: Your stat in the technique';

  @override
  String get rules_draw => 'Draw: Higher stat wins (+1)';

  @override
  String get rules_ko => 'KO: Fight until HP=0';

  @override
  String get rules_understood => 'GOT IT';

  @override
  String get ad_space => '— AD SPACE —';

  @override
  String get ad_remove => 'Activate PRO to remove ads';

  @override
  String get ad_continue => 'CONTINUE';

  @override
  String ad_reward_watch(int n) {
    return 'Watch ad = +$n 🪙';
  }

  @override
  String get daily_title => '🎁 DAILY REWARD';

  @override
  String get daily_claim => 'CLAIM!';

  @override
  String daily_day(int n) {
    return 'Day $n';
  }

  @override
  String get tech_fist => 'Fist';

  @override
  String get tech_kick => 'Kick';

  @override
  String get tech_grapple => 'Grapple';

  @override
  String get tech_block => 'Block';

  @override
  String get tech_palm => 'Palm';

  @override
  String get verb_fist_kick => 'Fist intercepts the Kick';

  @override
  String get verb_fist_grapple => 'Fist strikes before the Grapple';

  @override
  String get verb_kick_grapple => 'Kick pushes away from Grapple';

  @override
  String get verb_kick_block => 'Kick breaks the Block';

  @override
  String get verb_grapple_block => 'Grapple nullifies the Block';

  @override
  String get verb_grapple_palm => 'Grapple interrupts the Palm';

  @override
  String get verb_block_palm => 'Block deflects the Palm';

  @override
  String get verb_block_fist => 'Block stops the Fist';

  @override
  String get verb_palm_fist => 'Palm deflects the Fist';

  @override
  String get verb_palm_kick => 'Palm neutralizes the Kick';

  @override
  String get verb_draw => 'Technique draw';

  @override
  String get hero_karate => 'Karateka';

  @override
  String get hero_karate_desc => 'Discipline and precision';

  @override
  String get hero_karate_lore => 'Trained in the dojo since age five.';

  @override
  String get move_karate_fist => 'Iron Fist';

  @override
  String get move_karate_kick => 'Mae Geri';

  @override
  String get move_karate_grapple => 'Ippon Grab';

  @override
  String get move_karate_block => 'Uke Block';

  @override
  String get move_karate_palm => 'Shuto Palm';

  @override
  String get hero_templar => 'Templar';

  @override
  String get hero_templar_desc => 'Defense and lethal strike';

  @override
  String get hero_templar_lore =>
      'Crusader knight sworn to protect the sacred.';

  @override
  String get move_templar_fist => 'Sacred Strike';

  @override
  String get move_templar_kick => 'Crusade Kick';

  @override
  String get move_templar_grapple => 'Iron Grip';

  @override
  String get move_templar_block => 'Divine Shield';

  @override
  String get move_templar_palm => 'Holy Imposition';

  @override
  String get hero_ninja => 'Ninja';

  @override
  String get hero_ninja_desc => 'Hidden speed';

  @override
  String get hero_ninja_lore =>
      'Shadow among shadows. When you see him, it\'s too late.';

  @override
  String get move_ninja_fist => 'Shadow Strike';

  @override
  String get move_ninja_kick => 'Lightning Kick';

  @override
  String get move_ninja_grapple => 'Snake Lock';

  @override
  String get move_ninja_block => 'Mist Evasion';

  @override
  String get move_ninja_palm => 'Death Touch';

  @override
  String get hero_sumo => 'Sumo';

  @override
  String get hero_sumo_desc => 'Strength and grapple';

  @override
  String get hero_sumo_lore => 'Mountain of muscle and ancient tradition.';

  @override
  String get move_sumo_fist => 'Earthquake Fist';

  @override
  String get move_sumo_kick => 'Seismic Stomp';

  @override
  String get move_sumo_grapple => 'Bear Hug';

  @override
  String get move_sumo_block => 'Mountain Stance';

  @override
  String get move_sumo_palm => 'Tsunami Push';

  @override
  String get hero_kungfu => 'Kung Fu';

  @override
  String get hero_kungfu_desc => 'Total offense';

  @override
  String get hero_kungfu_lore => 'Master of animal forms, every strike is art.';

  @override
  String get move_kungfu_fist => 'Tiger Fist';

  @override
  String get move_kungfu_kick => 'Crane Kick';

  @override
  String get move_kungfu_grapple => 'Leopard Claw';

  @override
  String get move_kungfu_block => 'Monkey Stance';

  @override
  String get move_kungfu_palm => 'Snake Palm';

  @override
  String get hero_samurai => 'Samurai';

  @override
  String get hero_samurai_desc => 'Precision and honor';

  @override
  String get hero_samurai_lore =>
      'Follows the Bushido code with absolute devotion.';

  @override
  String get move_samurai_fist => 'Bushido Strike';

  @override
  String get move_samurai_kick => 'Ronin Kick';

  @override
  String get move_samurai_grapple => 'Kendo Grab';

  @override
  String get move_samurai_block => 'Iaido Guard';

  @override
  String get move_samurai_palm => 'Void Palm';

  @override
  String get hero_gladiator => 'Gladiator';

  @override
  String get hero_gladiator_desc => 'Fierce of the Colosseum';

  @override
  String get hero_gladiator_lore => 'Born in the arena, forged by blood.';

  @override
  String get move_gladiator_fist => 'Colosseum Fist';

  @override
  String get move_gladiator_kick => 'Gladius Kick';

  @override
  String get move_gladiator_grapple => 'Death Grip';

  @override
  String get move_gladiator_block => 'Roman Shield';

  @override
  String get move_gladiator_palm => 'Caesar\'s Palm';

  @override
  String get hero_monk => 'Tibetan Monk';

  @override
  String get hero_monk_desc => 'Supreme defense';

  @override
  String get hero_monk_lore => 'Years of meditation granted mastery of chi.';

  @override
  String get move_monk_fist => 'Touch of Peace';

  @override
  String get move_monk_kick => 'Enlightened Step';

  @override
  String get move_monk_grapple => 'Compassionate Embrace';

  @override
  String get move_monk_block => 'Chi Barrier';

  @override
  String get move_monk_palm => 'Celestial Palm';

  @override
  String get hero_viking => 'Viking';

  @override
  String get hero_viking_desc => 'Norse fury';

  @override
  String get hero_viking_lore => 'Descendant of Odin, knows no fear.';

  @override
  String get move_viking_fist => 'Thor\'s Fist';

  @override
  String get move_viking_kick => 'Berserker Kick';

  @override
  String get move_viking_grapple => 'Wolf Grab';

  @override
  String get move_viking_block => 'Shield Wall';

  @override
  String get move_viking_palm => 'Runic Palm';

  @override
  String get hero_capoeira => 'Capoeirista';

  @override
  String get hero_capoeira_desc => 'Deadly dance';

  @override
  String get hero_capoeira_lore =>
      'In the streets of Salvador, capoeira is freedom.';

  @override
  String get move_capoeira_fist => 'Mandinga Strike';

  @override
  String get move_capoeira_kick => 'Meia Lua de Compasso';

  @override
  String get move_capoeira_grapple => 'Rasteira';

  @override
  String get move_capoeira_block => 'Ginga Dodge';

  @override
  String get move_capoeira_palm => 'Axé Palm';

  @override
  String get hero_spartan => 'Spartan';

  @override
  String get hero_spartan_desc => 'Absolute discipline';

  @override
  String get hero_spartan_lore =>
      'Raised in the agoge, his entire life is war.';

  @override
  String get move_spartan_fist => 'Spartan Fist';

  @override
  String get move_spartan_kick => 'Abyss Kick';

  @override
  String get move_spartan_grapple => 'Phalanx Grip';

  @override
  String get move_spartan_block => 'Thermopylae Shield';

  @override
  String get move_spartan_palm => 'Spear Strike';

  @override
  String get hero_muaythai => 'Nak Muay';

  @override
  String get hero_muaythai_desc => 'Eight limbs';

  @override
  String get hero_muaythai_lore =>
      'The art of eight limbs: fists, elbows, knees and shins.';

  @override
  String get move_muaythai_fist => 'Devastating Elbow';

  @override
  String get move_muaythai_kick => 'Wai Kru Knee';

  @override
  String get move_muaythai_grapple => 'Thai Clinch';

  @override
  String get move_muaythai_block => 'High Guard';

  @override
  String get move_muaythai_palm => 'Muay Boran Palm';

  @override
  String get hero_taichi => 'Tai Chi';

  @override
  String get hero_taichi_desc => 'Redirects force';

  @override
  String get hero_taichi_lore =>
      'Water defeats rock. Soft outside, lethal inside.';

  @override
  String get move_taichi_fist => 'Cotton Fist';

  @override
  String get move_taichi_kick => 'Cloud Kick';

  @override
  String get move_taichi_grapple => 'River Flow';

  @override
  String get move_taichi_block => 'Willow Root';

  @override
  String get move_taichi_palm => 'Tai Ji Palm';

  @override
  String get hero_wrestler => 'Olympic Wrestler';

  @override
  String get hero_wrestler_desc => 'Ground control';

  @override
  String get hero_wrestler_lore =>
      'Perfect takedown technique. On the ground, the fight is over.';

  @override
  String get move_wrestler_fist => 'Wrestling Cross';

  @override
  String get move_wrestler_kick => 'Olympic Sweep';

  @override
  String get move_wrestler_grapple => 'Double Takedown';

  @override
  String get move_wrestler_block => 'Defensive Sprawl';

  @override
  String get move_wrestler_palm => 'Control Palm';

  @override
  String get hero_pirate => 'Pirate';

  @override
  String get hero_pirate_desc => 'No rules';

  @override
  String get hero_pirate_lore =>
      'The seven seas forged his style: dirty and unpredictable.';

  @override
  String get move_pirate_fist => 'Rum Punch';

  @override
  String get move_pirate_kick => 'Corsair Kick';

  @override
  String get move_pirate_grapple => 'Kraken Embrace';

  @override
  String get move_pirate_block => 'Plank Saver';

  @override
  String get move_pirate_palm => 'Pirate Slap';

  @override
  String get hero_amazon => 'Amazon';

  @override
  String get hero_amazon_desc => 'Jungle warrior';

  @override
  String get hero_amazon_lore =>
      'Daughter of the jungle, raised among jaguars.';

  @override
  String get move_amazon_fist => 'Wild Fist';

  @override
  String get move_amazon_kick => 'Jaguar Kick';

  @override
  String get move_amazon_grapple => 'Deadly Vine';

  @override
  String get move_amazon_block => 'Bark Shield';

  @override
  String get move_amazon_palm => 'Poison Palm';

  @override
  String get hero_shaman => 'Shaman';

  @override
  String get hero_shaman_desc => 'Mystic power';

  @override
  String get hero_shaman_lore => 'Connected with ancestral spirits.';

  @override
  String get move_shaman_fist => 'Spirit Strike';

  @override
  String get move_shaman_kick => 'Fire Dance';

  @override
  String get move_shaman_grapple => 'Ancestral Roots';

  @override
  String get move_shaman_block => 'Mystic Barrier';

  @override
  String get move_shaman_palm => 'Beyond Palm';

  @override
  String get hero_berserker => 'Berserker';

  @override
  String get hero_berserker_desc => 'Rage without defense';

  @override
  String get hero_berserker_lore =>
      'Fury consumes him in battle. Feels no pain.';

  @override
  String get move_berserker_fist => 'Fury Fist';

  @override
  String get move_berserker_kick => 'Savage Kick';

  @override
  String get move_berserker_grapple => 'Brutal Charge';

  @override
  String get move_berserker_block => 'War Cry';

  @override
  String get move_berserker_palm => 'Final Claw';

  @override
  String get hero_wushu => 'Wushu';

  @override
  String get hero_wushu_desc => 'Perfect form';

  @override
  String get hero_wushu_lore => 'Every movement choreographed to perfection.';

  @override
  String get move_wushu_fist => 'Lotus Fist';

  @override
  String get move_wushu_kick => 'Butterfly Kick';

  @override
  String get move_wushu_grapple => 'Silk Lock';

  @override
  String get move_wushu_block => 'Phoenix Stance';

  @override
  String get move_wushu_palm => 'Golden Dragon Palm';

  @override
  String get hero_mongol => 'Mongol';

  @override
  String get hero_mongol_desc => 'Brutal adaptation';

  @override
  String get hero_mongol_lore =>
      'Heir of Genghis Khan, unstoppable as the golden horde.';

  @override
  String get move_mongol_fist => 'Steppe Fist';

  @override
  String get move_mongol_kick => 'Rider Kick';

  @override
  String get move_mongol_grapple => 'Mongol Lasso';

  @override
  String get move_mongol_block => 'Nomad Guard';

  @override
  String get move_mongol_palm => 'Khan\'s Palm';
}
