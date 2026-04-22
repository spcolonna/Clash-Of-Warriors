// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Arena de Guerreiros';

  @override
  String get login_title => 'ARENA DE GUERREIROS';

  @override
  String get login_subtitle => 'COMBATE TÁTICO';

  @override
  String get login_placeholder => 'Nome...';

  @override
  String get login_prompt => 'Digite seu nome de guerreiro';

  @override
  String get login_enter => 'ENTRAR';

  @override
  String home_hello(String name) {
    return 'Olá, $name';
  }

  @override
  String get home_ready => 'Pronto para lutar?';

  @override
  String get home_1v1 => '⚔️ COMBATER 1v1';

  @override
  String get home_3v3 => '🏆 COMBATE 3v3';

  @override
  String get home_story => '📜 MODO LENDA';

  @override
  String get home_ranking => '🏆 RANKING';

  @override
  String get home_shop => '🛒 LOJA';

  @override
  String get home_upgrades => '⬆️ MELHORIAS';

  @override
  String get home_rules => '📜 REGRAS';

  @override
  String get home_pro_teaser_title => '🔥 MODO LENDA';

  @override
  String get home_pro_teaser_desc =>
      'Desbloqueie heróis, suba de nível, melhore stats e compita em 3v3.';

  @override
  String get home_pro_teaser_cta => 'ATIVAR PRO →';

  @override
  String get heroes_title => 'ESCOLHA SEU GUERREIRO';

  @override
  String get heroes_subtitle => 'Toque para ver detalhes';

  @override
  String heroes_unlock(int cost) {
    return '🔓 DESBLOQUEAR ($cost 🪙)';
  }

  @override
  String get heroes_choose => 'ESCOLHER →';

  @override
  String get heroes_lore_btn => '🔄 VER LORE E GOLPES';

  @override
  String get heroes_stats_btn => '🔄 VER STATS';

  @override
  String get heroes_first => '⭐ MEU PRIMEIRO GUERREIRO';

  @override
  String get diff_title => 'DIFICULDADE';

  @override
  String get diff_easy => 'Fácil';

  @override
  String get diff_easy_desc => 'Escolhe aleatório';

  @override
  String get diff_normal => 'Normal';

  @override
  String get diff_normal_desc => 'Usa melhores stats';

  @override
  String get diff_hard => 'Difícil';

  @override
  String get diff_hard_desc => 'Lê suas jogadas';

  @override
  String get diff_go => '⚔️ PARA A ARENA!';

  @override
  String battle_round(int n) {
    return 'ROUND $n';
  }

  @override
  String get battle_pick => 'ESCOLHA SUA TÉCNICA';

  @override
  String get battle_fighting => 'COMBATENDO!';

  @override
  String get battle_win => 'VOCÊ VENCEU!';

  @override
  String get battle_lose => 'VOCÊ PERDEU';

  @override
  String get battle_draw => 'EMPATE!';

  @override
  String get battle_next => 'PRÓXIMO ROUND →';

  @override
  String get battle_ref => '📖 REF';

  @override
  String get battle_history => 'HISTÓRICO';

  @override
  String battle_power(int n) {
    return 'Poder $n';
  }

  @override
  String get battle_beats => 'vence';

  @override
  String battle3v3_round(int n) {
    return '🏆 ROUND $n';
  }

  @override
  String get battle3v3_subtitle =>
      '1 técnica = ataque + defesa · Resolução simultânea';

  @override
  String get battle3v3_enemies => '⚔️ INIMIGOS';

  @override
  String get battle3v3_your_team => '🛡️ SUA EQUIPE';

  @override
  String battle3v3_pick_tech(String name) {
    return '$name: escolha TÉCNICA';
  }

  @override
  String get battle3v3_pick_hint =>
      '⚔️ Ataque e 🛡️ defenda com a mesma técnica';

  @override
  String battle3v3_pick_target(String name) {
    return '$name: quem atacar?';
  }

  @override
  String get battle3v3_target_hint =>
      'Toque um inimigo acima · Sua técnica também defende';

  @override
  String get battle3v3_all_ready => '✅ Todos os guerreiros prontos';

  @override
  String get battle3v3_execute => '⚔️ EXECUTAR RODADA!';

  @override
  String get battle3v3_your_attacks => '⚔️ SEUS ATAQUES';

  @override
  String get battle3v3_rival_attacks =>
      '🛡️ ATAQUES RIVAIS — Sua técnica defende';

  @override
  String get battle3v3_focus_fire => '🎯 FOCUS FIRE';

  @override
  String get battle3v3_next_round => 'PRÓXIMA RODADA →';

  @override
  String get battle3v3_tap_advance => 'Toque para avançar';

  @override
  String get battle3v3_your_attack => '⚔️ SEU ATAQUE';

  @override
  String get battle3v3_rival_attack => '🛡️ ATAQUE RIVAL';

  @override
  String anim_hit(int n) {
    return 'ACERTOU! −$n HP';
  }

  @override
  String get anim_blocked => 'BLOQUEADO!';

  @override
  String anim_draw_dmg(int n) {
    return 'EMPATE −$n HP';
  }

  @override
  String get anim_draw_neutral => 'EMPATE NEUTRO';

  @override
  String get result_victory => 'VITÓRIA!';

  @override
  String get result_defeat => 'DERROTA';

  @override
  String get result_draw => 'EMPATE';

  @override
  String get result_victory_3v3 => 'VITÓRIA 3v3!';

  @override
  String get result_defeat_3v3 => 'DERROTA 3v3';

  @override
  String get result_draw_3v3 => 'EMPATE 3v3';

  @override
  String result_rounds(int n) {
    return '$n rounds';
  }

  @override
  String get result_rematch => '⚔️ REVANCHE';

  @override
  String get result_change_hero => '🔄 TROCAR GUERREIRO';

  @override
  String get result_menu => 'MENU PRINCIPAL';

  @override
  String get result_another_3v3 => '🏆 OUTRO 3v3';

  @override
  String get rank_title => '🏆 RANKING';

  @override
  String get rank_empty => 'Sem guerreiros ainda';

  @override
  String get rank_wins => 'Vitórias';

  @override
  String get rank_elo => 'ELO';

  @override
  String get rank_streak => 'Sequência';

  @override
  String get settings_title => '⚙️ AJUSTES';

  @override
  String get settings_pro => 'Modo PRO';

  @override
  String get settings_pro_desc_on => 'Progressão, níveis, 3v3';

  @override
  String get settings_pro_desc_off => '\$2.99 para desbloquear';

  @override
  String get settings_tokens => '🪙 Tokens';

  @override
  String get settings_close => 'FECHAR';

  @override
  String get shop_title => '🛒 LOJA';

  @override
  String get shop_tokens_title => 'PACOTES DE TOKENS';

  @override
  String get shop_special_title => 'PACKS ESPECIAIS';

  @override
  String get shop_pack_handful => 'Punhado de Tokens';

  @override
  String get shop_pack_bag => 'Saco de Tokens';

  @override
  String get shop_pack_chest => 'Baú de Tokens';

  @override
  String get shop_pack_treasure => 'Tesouro Lendário';

  @override
  String get shop_special_warrior => 'Pack Guerreiro';

  @override
  String get shop_special_warrior_desc => '1 herói aleatório + 300 tokens';

  @override
  String get shop_special_legend => 'Pack Lenda';

  @override
  String get shop_special_legend_desc => '3 heróis aleatórios + 800 tokens';

  @override
  String get shop_special_ultimate => 'Pack Definitivo';

  @override
  String get shop_special_ultimate_desc => 'Todos os heróis + 2000 tokens';

  @override
  String get shop_popular => 'POPULAR';

  @override
  String get shop_confirm_title => 'CONFIRMAR COMPRA';

  @override
  String shop_confirm_charge(String price) {
    return 'Será cobrado $price';
  }

  @override
  String get shop_confirm_btn => '✅ CONFIRMAR COMPRA';

  @override
  String get shop_cancel => 'CANCELAR';

  @override
  String get shop_success => 'COMPRA REALIZADA!';

  @override
  String get shop_tokens_total => 'tokens totais';

  @override
  String get shop_heroes_unlocked => 'HERÓIS DESBLOQUEADOS';

  @override
  String get shop_great => 'ÓTIMO!';

  @override
  String get upgrade_title => '⬆️ MELHORIAS';

  @override
  String get upgrade_level_up => 'SUBIR DE NÍVEL';

  @override
  String get upgrade_unlock_heroes => 'DESBLOQUEAR HERÓIS';

  @override
  String upgrade_cards(int have, int need) {
    return 'Cartas: $have/$need';
  }

  @override
  String upgrade_improve(int cost) {
    return 'MELHORAR ($cost 🪙)';
  }

  @override
  String get upgrade_new_warrior => 'NOVO GUERREIRO!';

  @override
  String get upgrade_level_up_title => 'LEVEL UP!';

  @override
  String get upgrade_card_obtained => 'CARTA OBTIDA';

  @override
  String get upgrade_stats_plus1 => 'Todas as stats +1';

  @override
  String upgrade_remaining(int n) {
    return '🪙 $n tokens restantes';
  }

  @override
  String upgrade_more_for(int n, int lv) {
    return '$n mais para nível $lv';
  }

  @override
  String get story_title => 'MODO LENDA';

  @override
  String get story_subtitle => 'O Torneio das Eras — Escolha seu herói';

  @override
  String story_chapters(int n, int total) {
    return '$n/$total capítulos';
  }

  @override
  String get story_locked => 'HERÓIS BLOQUEADOS';

  @override
  String get story_play => 'JOGAR →';

  @override
  String get story_boss => '⚠️ BOSS';

  @override
  String get story_final => 'FINAL';

  @override
  String get story_combat => 'Combate';

  @override
  String get story_next => 'PRÓXIMO →';

  @override
  String get story_fight => '⚔️ LUTAR!';

  @override
  String get story_continue => 'CONTINUAR →';

  @override
  String get story_complete => '🏆 COMPLETAR';

  @override
  String get story_retry => '🔄 TENTAR NOVAMENTE';

  @override
  String get story_completed_title => 'LENDA COMPLETADA!';

  @override
  String story_completed_desc(String name) {
    return '$name libertou a Arena';
  }

  @override
  String get story_another => '📜 OUTRA LENDA';

  @override
  String get story_epilogue =>
      'O Oráculo foi derrotado e os guerreiros presos estão livres. Mas a Arena sempre volta...';

  @override
  String get team_title => '🏆 COMBATE 3v3';

  @override
  String get team_subtitle => 'Escolha 3 guerreiros';

  @override
  String get rules_title => 'REGRAS';

  @override
  String get rules_damage => 'Dano: Seu stat na técnica';

  @override
  String get rules_draw => 'Empate: Maior stat ganha (+1)';

  @override
  String get rules_ko => 'KO: Lute até HP=0';

  @override
  String get rules_understood => 'ENTENDI';

  @override
  String get ad_space => '— ESPAÇO PUBLICITÁRIO —';

  @override
  String get ad_remove => 'Ative PRO para remover anúncios';

  @override
  String get ad_continue => 'CONTINUAR';

  @override
  String ad_reward_watch(int n) {
    return 'Ver anúncio = +$n 🪙';
  }

  @override
  String get daily_title => '🎁 RECOMPENSA DIÁRIA';

  @override
  String get daily_claim => 'RESGATAR!';

  @override
  String daily_day(int n) {
    return 'Dia $n';
  }

  @override
  String get tech_fist => 'Punho';

  @override
  String get tech_kick => 'Chute';

  @override
  String get tech_grapple => 'Agarrão';

  @override
  String get tech_block => 'Bloqueio';

  @override
  String get tech_palm => 'Palma';

  @override
  String get verb_fist_kick => 'O Punho intercepta o Chute';

  @override
  String get verb_fist_grapple => 'O Punho golpeia antes do Agarrão';

  @override
  String get verb_kick_grapple => 'O Chute afasta do Agarrão';

  @override
  String get verb_kick_block => 'O Chute quebra o Bloqueio';

  @override
  String get verb_grapple_block => 'O Agarrão anula o Bloqueio';

  @override
  String get verb_grapple_palm => 'O Agarrão interrompe a Palma';

  @override
  String get verb_block_palm => 'O Bloqueio desvia a Palma';

  @override
  String get verb_block_fist => 'O Bloqueio detém o Punho';

  @override
  String get verb_palm_fist => 'A Palma desvia o Punho';

  @override
  String get verb_palm_kick => 'A Palma neutraliza o Chute';

  @override
  String get verb_draw => 'Empate de técnicas';

  @override
  String get hero_karate => 'Karateca';

  @override
  String get hero_karate_desc => 'Disciplina e golpe certeiro';

  @override
  String get hero_karate_lore => 'Treinado no dojo desde os cinco anos.';

  @override
  String get move_karate_fist => 'Punho de Ferro';

  @override
  String get move_karate_kick => 'Mae Geri';

  @override
  String get move_karate_grapple => 'Agarre Ippon';

  @override
  String get move_karate_block => 'Uke Bloqueio';

  @override
  String get move_karate_palm => 'Palma Shuto';

  @override
  String get hero_templar => 'Templário';

  @override
  String get hero_templar_desc => 'Defesa e golpe letal';

  @override
  String get hero_templar_lore =>
      'Cavaleiro cruzado jurado a proteger os sagrados.';

  @override
  String get move_templar_fist => 'Golpe Sagrado';

  @override
  String get move_templar_kick => 'Chute Cruzado';

  @override
  String get move_templar_grapple => 'Presa de Ferro';

  @override
  String get move_templar_block => 'Escudo Divino';

  @override
  String get move_templar_palm => 'Imposição Santa';

  @override
  String get hero_ninja => 'Ninja';

  @override
  String get hero_ninja_desc => 'Velocidade oculta';

  @override
  String get hero_ninja_lore =>
      'Sombra entre sombras. Quando você o vê, já é tarde.';

  @override
  String get move_ninja_fist => 'Golpe Sombra';

  @override
  String get move_ninja_kick => 'Chute Relâmpago';

  @override
  String get move_ninja_grapple => 'Chave Serpente';

  @override
  String get move_ninja_block => 'Névoa Evasiva';

  @override
  String get move_ninja_palm => 'Toque Mortal';

  @override
  String get hero_sumo => 'Sumô';

  @override
  String get hero_sumo_desc => 'Força e agarrão';

  @override
  String get hero_sumo_lore => 'Montanha de músculos e tradição milenar.';

  @override
  String get move_sumo_fist => 'Punho Terremoto';

  @override
  String get move_sumo_kick => 'Pisão Sísmico';

  @override
  String get move_sumo_grapple => 'Abraço de Urso';

  @override
  String get move_sumo_block => 'Postura Montanha';

  @override
  String get move_sumo_palm => 'Empurrão Tsunami';

  @override
  String get hero_kungfu => 'Kung Fu';

  @override
  String get hero_kungfu_desc => 'Ofensiva total';

  @override
  String get hero_kungfu_lore => 'Mestre das formas animais.';

  @override
  String get move_kungfu_fist => 'Punho do Tigre';

  @override
  String get move_kungfu_kick => 'Chute da Garça';

  @override
  String get move_kungfu_grapple => 'Garra do Leopardo';

  @override
  String get move_kungfu_block => 'Postura do Macaco';

  @override
  String get move_kungfu_palm => 'Palma da Serpente';

  @override
  String get hero_samurai => 'Samurai';

  @override
  String get hero_samurai_desc => 'Precisão e honra';

  @override
  String get hero_samurai_lore => 'Segue o código do Bushido com devoção.';

  @override
  String get move_samurai_fist => 'Golpe Bushido';

  @override
  String get move_samurai_kick => 'Chute do Ronin';

  @override
  String get move_samurai_grapple => 'Agarre Kendo';

  @override
  String get move_samurai_block => 'Guarda Iaido';

  @override
  String get move_samurai_palm => 'Palma do Vazio';

  @override
  String get hero_gladiator => 'Gladiador';

  @override
  String get hero_gladiator_desc => 'Feroz do Coliseu';

  @override
  String get hero_gladiator_lore => 'Nascido na arena, forjado pelo sangue.';

  @override
  String get move_gladiator_fist => 'Punho do Coliseu';

  @override
  String get move_gladiator_kick => 'Chute Gladius';

  @override
  String get move_gladiator_grapple => 'Presa Mortal';

  @override
  String get move_gladiator_block => 'Escudo Romano';

  @override
  String get move_gladiator_palm => 'Palma de César';

  @override
  String get hero_monk => 'Monge Tibetano';

  @override
  String get hero_monk_desc => 'Defesa suprema';

  @override
  String get hero_monk_lore => 'Anos de meditação lhe deram domínio do chi.';

  @override
  String get move_monk_fist => 'Toque de Paz';

  @override
  String get move_monk_kick => 'Passo Iluminado';

  @override
  String get move_monk_grapple => 'Abraço Compassivo';

  @override
  String get move_monk_block => 'Barreira de Chi';

  @override
  String get move_monk_palm => 'Palma Celestial';

  @override
  String get hero_viking => 'Viking';

  @override
  String get hero_viking_desc => 'Fúria nórdica';

  @override
  String get hero_viking_lore => 'Descendente de Odin, não conhece o medo.';

  @override
  String get move_viking_fist => 'Punho de Thor';

  @override
  String get move_viking_kick => 'Chute Berserker';

  @override
  String get move_viking_grapple => 'Agarre do Lobo';

  @override
  String get move_viking_block => 'Muro de Escudos';

  @override
  String get move_viking_palm => 'Palma Rúnica';

  @override
  String get hero_capoeira => 'Capoeirista';

  @override
  String get hero_capoeira_desc => 'Dança mortal';

  @override
  String get hero_capoeira_lore =>
      'Nas ruas de Salvador, a capoeira é liberdade.';

  @override
  String get move_capoeira_fist => 'Golpe Mandinga';

  @override
  String get move_capoeira_kick => 'Meia Lua de Compasso';

  @override
  String get move_capoeira_grapple => 'Rasteira';

  @override
  String get move_capoeira_block => 'Esquiva Ginga';

  @override
  String get move_capoeira_palm => 'Palma Axé';

  @override
  String get hero_spartan => 'Espartano';

  @override
  String get hero_spartan_desc => 'Disciplina absoluta';

  @override
  String get hero_spartan_lore => 'Criado na agogê, sua vida inteira é guerra.';

  @override
  String get move_spartan_fist => 'Punho Espartano';

  @override
  String get move_spartan_kick => 'Chute do Abismo';

  @override
  String get move_spartan_grapple => 'Presa Falange';

  @override
  String get move_spartan_block => 'Escudo Termópilas';

  @override
  String get move_spartan_palm => 'Golpe de Lança';

  @override
  String get hero_muaythai => 'Nak Muay';

  @override
  String get hero_muaythai_desc => 'Oito membros';

  @override
  String get hero_muaythai_lore => 'A arte dos oito membros.';

  @override
  String get move_muaythai_fist => 'Cotovelo Devastador';

  @override
  String get move_muaythai_kick => 'Joelhada Wai Kru';

  @override
  String get move_muaythai_grapple => 'Clinch Tailandês';

  @override
  String get move_muaythai_block => 'Guarda Alta';

  @override
  String get move_muaythai_palm => 'Palma Muay Boran';

  @override
  String get hero_taichi => 'Tai Chi';

  @override
  String get hero_taichi_desc => 'Redireciona a força';

  @override
  String get hero_taichi_lore => 'A água vence a rocha.';

  @override
  String get move_taichi_fist => 'Punho de Algodão';

  @override
  String get move_taichi_kick => 'Chute Nuvem';

  @override
  String get move_taichi_grapple => 'Fluxo do Rio';

  @override
  String get move_taichi_block => 'Raiz do Salgueiro';

  @override
  String get move_taichi_palm => 'Palma Tai Ji';

  @override
  String get hero_wrestler => 'Lutador Olímpico';

  @override
  String get hero_wrestler_desc => 'Domínio do solo';

  @override
  String get hero_wrestler_lore => 'Técnica de derrubada perfeita.';

  @override
  String get move_wrestler_fist => 'Cross de Luta';

  @override
  String get move_wrestler_kick => 'Rasteira Olímpica';

  @override
  String get move_wrestler_grapple => 'Derrubada Dupla';

  @override
  String get move_wrestler_block => 'Sprawl Defensivo';

  @override
  String get move_wrestler_palm => 'Palma de Controle';

  @override
  String get hero_pirate => 'Pirata';

  @override
  String get hero_pirate_desc => 'Sem regras';

  @override
  String get hero_pirate_lore => 'Os sete mares forjaram seu estilo.';

  @override
  String get move_pirate_fist => 'Soco de Rum';

  @override
  String get move_pirate_kick => 'Chute Corsário';

  @override
  String get move_pirate_grapple => 'Abraço do Kraken';

  @override
  String get move_pirate_block => 'Tábua Salvadora';

  @override
  String get move_pirate_palm => 'Bofetada Pirata';

  @override
  String get hero_amazon => 'Amazona';

  @override
  String get hero_amazon_desc => 'Guerreira da selva';

  @override
  String get hero_amazon_lore => 'Filha da selva, criada entre onças.';

  @override
  String get move_amazon_fist => 'Punho Selvagem';

  @override
  String get move_amazon_kick => 'Chute Jaguar';

  @override
  String get move_amazon_grapple => 'Cipó Mortal';

  @override
  String get move_amazon_block => 'Escudo de Casca';

  @override
  String get move_amazon_palm => 'Palma Venenosa';

  @override
  String get hero_shaman => 'Xamã';

  @override
  String get hero_shaman_desc => 'Poder místico';

  @override
  String get hero_shaman_lore => 'Conectado com os espíritos ancestrais.';

  @override
  String get move_shaman_fist => 'Golpe Espiritual';

  @override
  String get move_shaman_kick => 'Dança do Fogo';

  @override
  String get move_shaman_grapple => 'Raízes Ancestrais';

  @override
  String get move_shaman_block => 'Barreira Mística';

  @override
  String get move_shaman_palm => 'Palma do Além';

  @override
  String get hero_berserker => 'Berserker';

  @override
  String get hero_berserker_desc => 'Raiva sem defesa';

  @override
  String get hero_berserker_lore => 'A fúria o consome em batalha.';

  @override
  String get move_berserker_fist => 'Punho de Fúria';

  @override
  String get move_berserker_kick => 'Chute Selvagem';

  @override
  String get move_berserker_grapple => 'Investida Brutal';

  @override
  String get move_berserker_block => 'Grito de Guerra';

  @override
  String get move_berserker_palm => 'Garrada Final';

  @override
  String get hero_wushu => 'Wushu';

  @override
  String get hero_wushu_desc => 'Forma perfeita';

  @override
  String get hero_wushu_lore => 'Cada movimento coreografado com perfeição.';

  @override
  String get move_wushu_fist => 'Punho Flor de Lótus';

  @override
  String get move_wushu_kick => 'Chute Borboleta';

  @override
  String get move_wushu_grapple => 'Chave de Seda';

  @override
  String get move_wushu_block => 'Postura da Fênix';

  @override
  String get move_wushu_palm => 'Palma do Dragão Dourado';

  @override
  String get hero_mongol => 'Mongol';

  @override
  String get hero_mongol_desc => 'Adaptação brutal';

  @override
  String get hero_mongol_lore => 'Herdeiro de Genghis Khan.';

  @override
  String get move_mongol_fist => 'Punho da Estepe';

  @override
  String get move_mongol_kick => 'Chute do Cavaleiro';

  @override
  String get move_mongol_grapple => 'Laço Mongol';

  @override
  String get move_mongol_block => 'Guarda Nômade';

  @override
  String get move_mongol_palm => 'Palma do Khan';
}
