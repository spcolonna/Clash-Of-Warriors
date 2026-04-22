// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Arena de Guerreros';

  @override
  String get login_title => 'ARENA DE GUERREROS';

  @override
  String get login_subtitle => 'COMBATE TÁCTICO';

  @override
  String get login_placeholder => 'Nombre...';

  @override
  String get login_prompt => 'Ingresa tu nombre de guerrero';

  @override
  String get login_enter => 'ENTRAR';

  @override
  String home_hello(String name) {
    return 'Hola, $name';
  }

  @override
  String get home_ready => '¿Listo para pelear?';

  @override
  String get home_1v1 => '⚔️ COMBATIR 1v1';

  @override
  String get home_3v3 => '🏆 COMBATE 3v3';

  @override
  String get home_story => '📜 MODO LEYENDA';

  @override
  String get home_ranking => '🏆 RANKING';

  @override
  String get home_shop => '🛒 TIENDA';

  @override
  String get home_upgrades => '⬆️ MEJORAS';

  @override
  String get home_rules => '📜 REGLAS';

  @override
  String get home_pro_teaser_title => '🔥 MODO LEYENDA';

  @override
  String get home_pro_teaser_desc =>
      'Desbloquea héroes, sube de nivel, mejora stats y compite en 3v3.';

  @override
  String get home_pro_teaser_cta => 'ACTIVAR PRO →';

  @override
  String get heroes_title => 'ELIGE TU GUERRERO';

  @override
  String get heroes_subtitle => 'Toca para ver detalle';

  @override
  String heroes_unlock(int cost) {
    return '🔓 DESBLOQUEAR ($cost 🪙)';
  }

  @override
  String get heroes_choose => 'ELEGIR →';

  @override
  String get heroes_lore_btn => '🔄 VER LORE Y MOVIMIENTOS';

  @override
  String get heroes_stats_btn => '🔄 VER STATS';

  @override
  String get heroes_first => '⭐ MI PRIMER GUERRERO';

  @override
  String get diff_title => 'DIFICULTAD';

  @override
  String get diff_easy => 'Fácil';

  @override
  String get diff_easy_desc => 'Elige al azar';

  @override
  String get diff_normal => 'Normal';

  @override
  String get diff_normal_desc => 'Usa sus mejores stats';

  @override
  String get diff_hard => 'Difícil';

  @override
  String get diff_hard_desc => 'Lee tus jugadas';

  @override
  String get diff_go => '⚔️ ¡A LA ARENA!';

  @override
  String battle_round(int n) {
    return 'ROUND $n';
  }

  @override
  String get battle_pick => 'ELIGE TU TÉCNICA';

  @override
  String get battle_fighting => '¡COMBATIENDO!';

  @override
  String get battle_win => '¡GANASTE!';

  @override
  String get battle_lose => 'PERDISTE';

  @override
  String get battle_draw => '¡EMPATE!';

  @override
  String get battle_next => 'SIGUIENTE ROUND →';

  @override
  String get battle_ref => '📖 REF';

  @override
  String get battle_history => 'HISTORIAL';

  @override
  String battle_power(int n) {
    return 'Poder $n';
  }

  @override
  String get battle_beats => 'vence';

  @override
  String battle3v3_round(int n) {
    return '🏆 RONDA $n';
  }

  @override
  String get battle3v3_subtitle =>
      '1 técnica = ataque + defensa · Resolución simultánea';

  @override
  String get battle3v3_enemies => '⚔️ ENEMIGOS';

  @override
  String get battle3v3_your_team => '🛡️ TU EQUIPO';

  @override
  String battle3v3_pick_tech(String name) {
    return '$name: elige TÉCNICA';
  }

  @override
  String get battle3v3_pick_hint =>
      '⚔️ Ataca y 🛡️ defiende con la misma técnica';

  @override
  String battle3v3_pick_target(String name) {
    return '$name: ¿a quién atacar?';
  }

  @override
  String get battle3v3_target_hint =>
      'Toca un enemigo arriba · Tu técnica también te defiende';

  @override
  String get battle3v3_all_ready => '✅ Todos los guerreros listos';

  @override
  String get battle3v3_execute => '⚔️ ¡EJECUTAR RONDA!';

  @override
  String get battle3v3_your_attacks => '⚔️ TUS ATAQUES';

  @override
  String get battle3v3_rival_attacks =>
      '🛡️ ATAQUES RIVALES — Tu técnica defiende';

  @override
  String get battle3v3_focus_fire => '🎯 FOCUS FIRE';

  @override
  String get battle3v3_next_round => 'SIGUIENTE RONDA →';

  @override
  String get battle3v3_tap_advance => 'Toca para avanzar';

  @override
  String get battle3v3_your_attack => '⚔️ TU ATAQUE';

  @override
  String get battle3v3_rival_attack => '🛡️ ATAQUE RIVAL';

  @override
  String anim_hit(int n) {
    return '¡GOLPE! −$n HP';
  }

  @override
  String get anim_blocked => '¡BLOQUEADO!';

  @override
  String anim_draw_dmg(int n) {
    return 'EMPATE −$n HP';
  }

  @override
  String get anim_draw_neutral => 'EMPATE NEUTRO';

  @override
  String get result_victory => '¡VICTORIA!';

  @override
  String get result_defeat => 'DERROTA';

  @override
  String get result_draw => 'EMPATE';

  @override
  String get result_victory_3v3 => '¡VICTORIA 3v3!';

  @override
  String get result_defeat_3v3 => 'DERROTA 3v3';

  @override
  String get result_draw_3v3 => 'EMPATE 3v3';

  @override
  String result_rounds(int n) {
    return '$n rounds';
  }

  @override
  String get result_rematch => '⚔️ REVANCHA';

  @override
  String get result_change_hero => '🔄 CAMBIAR GUERRERO';

  @override
  String get result_menu => 'MENÚ PRINCIPAL';

  @override
  String get result_another_3v3 => '🏆 OTRA 3v3';

  @override
  String get rank_title => '🏆 RANKING';

  @override
  String get rank_empty => 'Sin guerreros aún';

  @override
  String get rank_wins => 'Victorias';

  @override
  String get rank_elo => 'ELO';

  @override
  String get rank_streak => 'Racha';

  @override
  String get settings_title => '⚙️ AJUSTES';

  @override
  String get settings_pro => 'Modo PRO';

  @override
  String get settings_pro_desc_on => 'Progresión, niveles, 3v3';

  @override
  String get settings_pro_desc_off => '\$2.99 para desbloquear';

  @override
  String get settings_tokens => '🪙 Tokens';

  @override
  String get settings_close => 'CERRAR';

  @override
  String get shop_title => '🛒 TIENDA';

  @override
  String get shop_tokens_title => 'PAQUETES DE TOKENS';

  @override
  String get shop_special_title => 'PACKS ESPECIALES';

  @override
  String get shop_pack_handful => 'Puñado de Tokens';

  @override
  String get shop_pack_bag => 'Bolsa de Tokens';

  @override
  String get shop_pack_chest => 'Cofre de Tokens';

  @override
  String get shop_pack_treasure => 'Tesoro Legendario';

  @override
  String get shop_special_warrior => 'Pack Guerrero';

  @override
  String get shop_special_warrior_desc => '1 héroe aleatorio + 300 tokens';

  @override
  String get shop_special_legend => 'Pack Leyenda';

  @override
  String get shop_special_legend_desc => '3 héroes aleatorios + 800 tokens';

  @override
  String get shop_special_ultimate => 'Pack Definitivo';

  @override
  String get shop_special_ultimate_desc => 'Todos los héroes + 2000 tokens';

  @override
  String get shop_popular => 'POPULAR';

  @override
  String get shop_confirm_title => 'CONFIRMAR COMPRA';

  @override
  String shop_confirm_charge(String price) {
    return 'Se cobrará $price a tu cuenta';
  }

  @override
  String get shop_confirm_btn => '✅ CONFIRMAR COMPRA';

  @override
  String get shop_cancel => 'CANCELAR';

  @override
  String get shop_success => '¡COMPRA EXITOSA!';

  @override
  String get shop_tokens_total => 'tokens totales';

  @override
  String get shop_heroes_unlocked => 'HÉROES DESBLOQUEADOS';

  @override
  String get shop_great => '¡GENIAL!';

  @override
  String get upgrade_title => '⬆️ MEJORAS';

  @override
  String get upgrade_level_up => 'SUBIR DE NIVEL';

  @override
  String get upgrade_unlock_heroes => 'DESBLOQUEAR HÉROES';

  @override
  String upgrade_cards(int have, int need) {
    return 'Cartas: $have/$need';
  }

  @override
  String upgrade_improve(int cost) {
    return 'MEJORAR ($cost 🪙)';
  }

  @override
  String get upgrade_new_warrior => '¡NUEVO GUERRERO!';

  @override
  String get upgrade_level_up_title => '¡LEVEL UP!';

  @override
  String get upgrade_card_obtained => 'CARTA OBTENIDA';

  @override
  String get upgrade_stats_plus1 => 'Todas las stats +1';

  @override
  String upgrade_remaining(int n) {
    return '🪙 $n tokens restantes';
  }

  @override
  String upgrade_more_for(int n, int lv) {
    return '$n más para nivel $lv';
  }

  @override
  String get story_title => 'MODO LEYENDA';

  @override
  String get story_subtitle => 'El Torneo de las Eras — Elige tu héroe';

  @override
  String story_chapters(int n, int total) {
    return '$n/$total capítulos';
  }

  @override
  String get story_locked => 'HÉROES BLOQUEADOS';

  @override
  String get story_play => 'JUGAR →';

  @override
  String get story_boss => '⚠️ BOSS';

  @override
  String get story_final => 'FINAL';

  @override
  String get story_combat => 'Combate';

  @override
  String get story_next => 'SIGUIENTE →';

  @override
  String get story_fight => '⚔️ ¡COMBATIR!';

  @override
  String get story_continue => 'CONTINUAR →';

  @override
  String get story_complete => '🏆 COMPLETAR';

  @override
  String get story_retry => '🔄 REINTENTAR';

  @override
  String get story_completed_title => '¡LEYENDA COMPLETADA!';

  @override
  String story_completed_desc(String name) {
    return '$name ha liberado la Arena';
  }

  @override
  String get story_another => '📜 OTRA LEYENDA';

  @override
  String get story_epilogue =>
      'El Oráculo ha sido derrotado y los guerreros atrapados son libres. Pero la Arena siempre vuelve...';

  @override
  String get team_title => '🏆 COMBATE 3v3';

  @override
  String get team_subtitle => 'Elige 3 guerreros';

  @override
  String get rules_title => 'REGLAS';

  @override
  String get rules_damage => 'Daño: Tu stat en la técnica';

  @override
  String get rules_draw => 'Empate: Mayor stat gana (+1)';

  @override
  String get rules_ko => 'KO: Pelea hasta HP=0';

  @override
  String get rules_understood => 'ENTENDIDO';

  @override
  String get ad_space => '— ESPACIO PUBLICITARIO —';

  @override
  String get ad_remove => 'Activa PRO para remover anuncios';

  @override
  String get ad_continue => 'CONTINUAR';

  @override
  String ad_reward_watch(int n) {
    return 'Ver anuncio = +$n 🪙';
  }

  @override
  String get daily_title => '🎁 RECOMPENSA DIARIA';

  @override
  String get daily_claim => '¡RECLAMAR!';

  @override
  String daily_day(int n) {
    return 'Día $n';
  }

  @override
  String get tech_fist => 'Puño';

  @override
  String get tech_kick => 'Patada';

  @override
  String get tech_grapple => 'Agarre';

  @override
  String get tech_block => 'Bloqueo';

  @override
  String get tech_palm => 'Palma';

  @override
  String get verb_fist_kick => 'El Puño intercepta la Patada';

  @override
  String get verb_fist_grapple => 'El Puño golpea antes del Agarre';

  @override
  String get verb_kick_grapple => 'La Patada aleja del Agarre';

  @override
  String get verb_kick_block => 'La Patada rompe el Bloqueo';

  @override
  String get verb_grapple_block => 'El Agarre anula el Bloqueo';

  @override
  String get verb_grapple_palm => 'El Agarre interrumpe la Palma';

  @override
  String get verb_block_palm => 'El Bloqueo desvía la Palma';

  @override
  String get verb_block_fist => 'El Bloqueo detiene el Puño';

  @override
  String get verb_palm_fist => 'La Palma desvía el Puño';

  @override
  String get verb_palm_kick => 'La Palma neutraliza la Patada';

  @override
  String get verb_draw => 'Empate de técnicas';

  @override
  String get hero_karate => 'Karateca';

  @override
  String get hero_karate_desc => 'Disciplina y golpe certero';

  @override
  String get hero_karate_lore =>
      'Formado en el dojo desde los cinco años, el karate moldeó su carácter tanto como su cuerpo.';

  @override
  String get move_karate_fist => 'Puño de Hierro';

  @override
  String get move_karate_kick => 'Mae Geri';

  @override
  String get move_karate_grapple => 'Agarre Ippon';

  @override
  String get move_karate_block => 'Uke Bloqueo';

  @override
  String get move_karate_palm => 'Palma Shuto';

  @override
  String get hero_templar => 'Templario';

  @override
  String get hero_templar_desc => 'Defensa y golpe letal';

  @override
  String get hero_templar_lore =>
      'Caballero cruzado jurado a proteger los sagrados.';

  @override
  String get move_templar_fist => 'Golpe Sagrado';

  @override
  String get move_templar_kick => 'Patada Cruzada';

  @override
  String get move_templar_grapple => 'Presa de Hierro';

  @override
  String get move_templar_block => 'Escudo Divino';

  @override
  String get move_templar_palm => 'Imposición Santa';

  @override
  String get hero_ninja => 'Ninja';

  @override
  String get hero_ninja_desc => 'Velocidad oculta';

  @override
  String get hero_ninja_lore =>
      'Sombra entre sombras. Cuando lo ves, ya es tarde.';

  @override
  String get move_ninja_fist => 'Golpe Sombra';

  @override
  String get move_ninja_kick => 'Patada Relámpago';

  @override
  String get move_ninja_grapple => 'Llave Serpiente';

  @override
  String get move_ninja_block => 'Niebla Evasiva';

  @override
  String get move_ninja_palm => 'Toque Mortal';

  @override
  String get hero_sumo => 'Sumo';

  @override
  String get hero_sumo_desc => 'Fuerza y agarre';

  @override
  String get hero_sumo_lore => 'Montaña de músculos y tradición milenaria.';

  @override
  String get move_sumo_fist => 'Puño Terremoto';

  @override
  String get move_sumo_kick => 'Pisotón Sísmico';

  @override
  String get move_sumo_grapple => 'Abrazo de Oso';

  @override
  String get move_sumo_block => 'Postura Montaña';

  @override
  String get move_sumo_palm => 'Empujón Tsunami';

  @override
  String get hero_kungfu => 'Kung Fu';

  @override
  String get hero_kungfu_desc => 'Ofensiva total';

  @override
  String get hero_kungfu_lore =>
      'Maestro de las formas animales, cada golpe es un arte.';

  @override
  String get move_kungfu_fist => 'Puño del Tigre';

  @override
  String get move_kungfu_kick => 'Patada de la Grulla';

  @override
  String get move_kungfu_grapple => 'Zarpa del Leopardo';

  @override
  String get move_kungfu_block => 'Postura del Mono';

  @override
  String get move_kungfu_palm => 'Palma de la Serpiente';

  @override
  String get hero_samurai => 'Samurai';

  @override
  String get hero_samurai_desc => 'Precisión y honor';

  @override
  String get hero_samurai_lore =>
      'Sigue el código del Bushido con devoción absoluta.';

  @override
  String get move_samurai_fist => 'Golpe Bushido';

  @override
  String get move_samurai_kick => 'Patada del Ronin';

  @override
  String get move_samurai_grapple => 'Agarre Kendo';

  @override
  String get move_samurai_block => 'Guardia Iaido';

  @override
  String get move_samurai_palm => 'Palma del Vacío';

  @override
  String get hero_gladiator => 'Gladiador';

  @override
  String get hero_gladiator_desc => 'Feroz del Coliseo';

  @override
  String get hero_gladiator_lore =>
      'Nacido en la arena, forjado por la sangre.';

  @override
  String get move_gladiator_fist => 'Puño del Coliseo';

  @override
  String get move_gladiator_kick => 'Patada Gladius';

  @override
  String get move_gladiator_grapple => 'Presa Mortal';

  @override
  String get move_gladiator_block => 'Escudo Romano';

  @override
  String get move_gladiator_palm => 'Palma del César';

  @override
  String get hero_monk => 'Monje Tibetano';

  @override
  String get hero_monk_desc => 'Defensa suprema';

  @override
  String get hero_monk_lore =>
      'Años de meditación le otorgaron el dominio del chi.';

  @override
  String get move_monk_fist => 'Toque de Paz';

  @override
  String get move_monk_kick => 'Paso Iluminado';

  @override
  String get move_monk_grapple => 'Abrazo Compasivo';

  @override
  String get move_monk_block => 'Barrera de Chi';

  @override
  String get move_monk_palm => 'Palma Celestial';

  @override
  String get hero_viking => 'Vikingo';

  @override
  String get hero_viking_desc => 'Furia nórdica';

  @override
  String get hero_viking_lore => 'Descendiente de Odín, no conoce el miedo.';

  @override
  String get move_viking_fist => 'Puño de Thor';

  @override
  String get move_viking_kick => 'Patada Berserker';

  @override
  String get move_viking_grapple => 'Agarre del Lobo';

  @override
  String get move_viking_block => 'Muro de Escudos';

  @override
  String get move_viking_palm => 'Palma Rúnica';

  @override
  String get hero_capoeira => 'Capoeirista';

  @override
  String get hero_capoeira_desc => 'Danza mortal';

  @override
  String get hero_capoeira_lore =>
      'En las calles de Salvador, la capoeira es libertad.';

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
  String get hero_spartan_lore =>
      'Criado en la agogé, su vida entera es guerra.';

  @override
  String get move_spartan_fist => 'Puño Espartano';

  @override
  String get move_spartan_kick => 'Patada del Abismo';

  @override
  String get move_spartan_grapple => 'Presa Falange';

  @override
  String get move_spartan_block => 'Escudo Termópilas';

  @override
  String get move_spartan_palm => 'Golpe de Lanza';

  @override
  String get hero_muaythai => 'Nak Muay';

  @override
  String get hero_muaythai_desc => 'Ocho miembros';

  @override
  String get hero_muaythai_lore =>
      'El arte de los ocho miembros: puños, codos, rodillas y espinillas.';

  @override
  String get move_muaythai_fist => 'Codo Devastador';

  @override
  String get move_muaythai_kick => 'Rodillazo Wai Kru';

  @override
  String get move_muaythai_grapple => 'Clinch Tailandés';

  @override
  String get move_muaythai_block => 'Guardia Alta';

  @override
  String get move_muaythai_palm => 'Palma Muay Boran';

  @override
  String get hero_taichi => 'Tai Chi';

  @override
  String get hero_taichi_desc => 'Redirige la fuerza';

  @override
  String get hero_taichi_lore =>
      'El agua vence a la roca. Suave por fuera, letal por dentro.';

  @override
  String get move_taichi_fist => 'Puño de Algodón';

  @override
  String get move_taichi_kick => 'Patada Nube';

  @override
  String get move_taichi_grapple => 'Flujo del Río';

  @override
  String get move_taichi_block => 'Raíz del Sauce';

  @override
  String get move_taichi_palm => 'Palma Tai Ji';

  @override
  String get hero_wrestler => 'Luchador Olímpico';

  @override
  String get hero_wrestler_desc => 'Dominio del suelo';

  @override
  String get hero_wrestler_lore =>
      'Su técnica de derribo es perfecta. En el suelo, el combate ya terminó.';

  @override
  String get move_wrestler_fist => 'Cross de Lucha';

  @override
  String get move_wrestler_kick => 'Barrida Olímpica';

  @override
  String get move_wrestler_grapple => 'Derribo Doble';

  @override
  String get move_wrestler_block => 'Sprawl Defensivo';

  @override
  String get move_wrestler_palm => 'Palma de Control';

  @override
  String get hero_pirate => 'Pirata';

  @override
  String get hero_pirate_desc => 'Sin reglas';

  @override
  String get hero_pirate_lore =>
      'Los siete mares forjaron su estilo: sucio e impredecible.';

  @override
  String get move_pirate_fist => 'Puño de Ron';

  @override
  String get move_pirate_kick => 'Patada Corsaria';

  @override
  String get move_pirate_grapple => 'Abrazo del Kraken';

  @override
  String get move_pirate_block => 'Tabla Salvadora';

  @override
  String get move_pirate_palm => 'Bofetada Pirata';

  @override
  String get hero_amazon => 'Amazona';

  @override
  String get hero_amazon_desc => 'Guerrera de la selva';

  @override
  String get hero_amazon_lore => 'Hija de la selva, criada entre jaguares.';

  @override
  String get move_amazon_fist => 'Puño Salvaje';

  @override
  String get move_amazon_kick => 'Patada Jaguar';

  @override
  String get move_amazon_grapple => 'Liana Mortal';

  @override
  String get move_amazon_block => 'Escudo de Corteza';

  @override
  String get move_amazon_palm => 'Palma Venenosa';

  @override
  String get hero_shaman => 'Chamán';

  @override
  String get hero_shaman_desc => 'Poder místico';

  @override
  String get hero_shaman_lore => 'Conectado con los espíritus ancestrales.';

  @override
  String get move_shaman_fist => 'Golpe Espiritual';

  @override
  String get move_shaman_kick => 'Danza de Fuego';

  @override
  String get move_shaman_grapple => 'Raíces Ancestrales';

  @override
  String get move_shaman_block => 'Barrera Mística';

  @override
  String get move_shaman_palm => 'Palma del Más Allá';

  @override
  String get hero_berserker => 'Berserker';

  @override
  String get hero_berserker_desc => 'Rabia sin defensa';

  @override
  String get hero_berserker_lore =>
      'La furia lo consume en batalla. No siente dolor.';

  @override
  String get move_berserker_fist => 'Puño de Furia';

  @override
  String get move_berserker_kick => 'Patada Salvaje';

  @override
  String get move_berserker_grapple => 'Embestida Brutal';

  @override
  String get move_berserker_block => 'Grito de Guerra';

  @override
  String get move_berserker_palm => 'Zarpazo Final';

  @override
  String get hero_wushu => 'Wushu';

  @override
  String get hero_wushu_desc => 'Forma perfecta';

  @override
  String get hero_wushu_lore =>
      'Cada movimiento es coreografiado a la perfección.';

  @override
  String get move_wushu_fist => 'Puño Flor de Loto';

  @override
  String get move_wushu_kick => 'Patada Mariposa';

  @override
  String get move_wushu_grapple => 'Llave de Seda';

  @override
  String get move_wushu_block => 'Postura del Fénix';

  @override
  String get move_wushu_palm => 'Palma del Dragón Dorado';

  @override
  String get hero_mongol => 'Mongol';

  @override
  String get hero_mongol_desc => 'Adaptación brutal';

  @override
  String get hero_mongol_lore =>
      'Heredero de Genghis Khan, imparable como la horda dorada.';

  @override
  String get move_mongol_fist => 'Puño de la Estepa';

  @override
  String get move_mongol_kick => 'Patada del Jinete';

  @override
  String get move_mongol_grapple => 'Lazo Mongol';

  @override
  String get move_mongol_block => 'Guardia Nómada';

  @override
  String get move_mongol_palm => 'Palma del Khan';
}
