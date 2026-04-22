import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Arena de Guerreros'**
  String get appTitle;

  /// No description provided for @login_title.
  ///
  /// In es, this message translates to:
  /// **'ARENA DE GUERREROS'**
  String get login_title;

  /// No description provided for @login_subtitle.
  ///
  /// In es, this message translates to:
  /// **'COMBATE TÁCTICO'**
  String get login_subtitle;

  /// No description provided for @login_placeholder.
  ///
  /// In es, this message translates to:
  /// **'Nombre...'**
  String get login_placeholder;

  /// No description provided for @login_prompt.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre de guerrero'**
  String get login_prompt;

  /// No description provided for @login_enter.
  ///
  /// In es, this message translates to:
  /// **'ENTRAR'**
  String get login_enter;

  /// No description provided for @home_hello.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String home_hello(String name);

  /// No description provided for @home_ready.
  ///
  /// In es, this message translates to:
  /// **'¿Listo para pelear?'**
  String get home_ready;

  /// No description provided for @home_1v1.
  ///
  /// In es, this message translates to:
  /// **'⚔️ COMBATIR 1v1'**
  String get home_1v1;

  /// No description provided for @home_3v3.
  ///
  /// In es, this message translates to:
  /// **'🏆 COMBATE 3v3'**
  String get home_3v3;

  /// No description provided for @home_story.
  ///
  /// In es, this message translates to:
  /// **'📜 MODO LEYENDA'**
  String get home_story;

  /// No description provided for @home_ranking.
  ///
  /// In es, this message translates to:
  /// **'🏆 RANKING'**
  String get home_ranking;

  /// No description provided for @home_shop.
  ///
  /// In es, this message translates to:
  /// **'🛒 TIENDA'**
  String get home_shop;

  /// No description provided for @home_upgrades.
  ///
  /// In es, this message translates to:
  /// **'⬆️ MEJORAS'**
  String get home_upgrades;

  /// No description provided for @home_rules.
  ///
  /// In es, this message translates to:
  /// **'📜 REGLAS'**
  String get home_rules;

  /// No description provided for @home_pro_teaser_title.
  ///
  /// In es, this message translates to:
  /// **'🔥 MODO LEYENDA'**
  String get home_pro_teaser_title;

  /// No description provided for @home_pro_teaser_desc.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea héroes, sube de nivel, mejora stats y compite en 3v3.'**
  String get home_pro_teaser_desc;

  /// No description provided for @home_pro_teaser_cta.
  ///
  /// In es, this message translates to:
  /// **'ACTIVAR PRO →'**
  String get home_pro_teaser_cta;

  /// No description provided for @heroes_title.
  ///
  /// In es, this message translates to:
  /// **'ELIGE TU GUERRERO'**
  String get heroes_title;

  /// No description provided for @heroes_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Toca para ver detalle'**
  String get heroes_subtitle;

  /// No description provided for @heroes_unlock.
  ///
  /// In es, this message translates to:
  /// **'🔓 DESBLOQUEAR ({cost} 🪙)'**
  String heroes_unlock(int cost);

  /// No description provided for @heroes_choose.
  ///
  /// In es, this message translates to:
  /// **'ELEGIR →'**
  String get heroes_choose;

  /// No description provided for @heroes_lore_btn.
  ///
  /// In es, this message translates to:
  /// **'🔄 VER LORE Y MOVIMIENTOS'**
  String get heroes_lore_btn;

  /// No description provided for @heroes_stats_btn.
  ///
  /// In es, this message translates to:
  /// **'🔄 VER STATS'**
  String get heroes_stats_btn;

  /// No description provided for @heroes_first.
  ///
  /// In es, this message translates to:
  /// **'⭐ MI PRIMER GUERRERO'**
  String get heroes_first;

  /// No description provided for @diff_title.
  ///
  /// In es, this message translates to:
  /// **'DIFICULTAD'**
  String get diff_title;

  /// No description provided for @diff_easy.
  ///
  /// In es, this message translates to:
  /// **'Fácil'**
  String get diff_easy;

  /// No description provided for @diff_easy_desc.
  ///
  /// In es, this message translates to:
  /// **'Elige al azar'**
  String get diff_easy_desc;

  /// No description provided for @diff_normal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get diff_normal;

  /// No description provided for @diff_normal_desc.
  ///
  /// In es, this message translates to:
  /// **'Usa sus mejores stats'**
  String get diff_normal_desc;

  /// No description provided for @diff_hard.
  ///
  /// In es, this message translates to:
  /// **'Difícil'**
  String get diff_hard;

  /// No description provided for @diff_hard_desc.
  ///
  /// In es, this message translates to:
  /// **'Lee tus jugadas'**
  String get diff_hard_desc;

  /// No description provided for @diff_go.
  ///
  /// In es, this message translates to:
  /// **'⚔️ ¡A LA ARENA!'**
  String get diff_go;

  /// No description provided for @battle_round.
  ///
  /// In es, this message translates to:
  /// **'ROUND {n}'**
  String battle_round(int n);

  /// No description provided for @battle_pick.
  ///
  /// In es, this message translates to:
  /// **'ELIGE TU TÉCNICA'**
  String get battle_pick;

  /// No description provided for @battle_fighting.
  ///
  /// In es, this message translates to:
  /// **'¡COMBATIENDO!'**
  String get battle_fighting;

  /// No description provided for @battle_win.
  ///
  /// In es, this message translates to:
  /// **'¡GANASTE!'**
  String get battle_win;

  /// No description provided for @battle_lose.
  ///
  /// In es, this message translates to:
  /// **'PERDISTE'**
  String get battle_lose;

  /// No description provided for @battle_draw.
  ///
  /// In es, this message translates to:
  /// **'¡EMPATE!'**
  String get battle_draw;

  /// No description provided for @battle_next.
  ///
  /// In es, this message translates to:
  /// **'SIGUIENTE ROUND →'**
  String get battle_next;

  /// No description provided for @battle_ref.
  ///
  /// In es, this message translates to:
  /// **'📖 REF'**
  String get battle_ref;

  /// No description provided for @battle_history.
  ///
  /// In es, this message translates to:
  /// **'HISTORIAL'**
  String get battle_history;

  /// No description provided for @battle_power.
  ///
  /// In es, this message translates to:
  /// **'Poder {n}'**
  String battle_power(int n);

  /// No description provided for @battle_beats.
  ///
  /// In es, this message translates to:
  /// **'vence'**
  String get battle_beats;

  /// No description provided for @battle3v3_round.
  ///
  /// In es, this message translates to:
  /// **'🏆 RONDA {n}'**
  String battle3v3_round(int n);

  /// No description provided for @battle3v3_subtitle.
  ///
  /// In es, this message translates to:
  /// **'1 técnica = ataque + defensa · Resolución simultánea'**
  String get battle3v3_subtitle;

  /// No description provided for @battle3v3_enemies.
  ///
  /// In es, this message translates to:
  /// **'⚔️ ENEMIGOS'**
  String get battle3v3_enemies;

  /// No description provided for @battle3v3_your_team.
  ///
  /// In es, this message translates to:
  /// **'🛡️ TU EQUIPO'**
  String get battle3v3_your_team;

  /// No description provided for @battle3v3_pick_tech.
  ///
  /// In es, this message translates to:
  /// **'{name}: elige TÉCNICA'**
  String battle3v3_pick_tech(String name);

  /// No description provided for @battle3v3_pick_hint.
  ///
  /// In es, this message translates to:
  /// **'⚔️ Ataca y 🛡️ defiende con la misma técnica'**
  String get battle3v3_pick_hint;

  /// No description provided for @battle3v3_pick_target.
  ///
  /// In es, this message translates to:
  /// **'{name}: ¿a quién atacar?'**
  String battle3v3_pick_target(String name);

  /// No description provided for @battle3v3_target_hint.
  ///
  /// In es, this message translates to:
  /// **'Toca un enemigo arriba · Tu técnica también te defiende'**
  String get battle3v3_target_hint;

  /// No description provided for @battle3v3_all_ready.
  ///
  /// In es, this message translates to:
  /// **'✅ Todos los guerreros listos'**
  String get battle3v3_all_ready;

  /// No description provided for @battle3v3_execute.
  ///
  /// In es, this message translates to:
  /// **'⚔️ ¡EJECUTAR RONDA!'**
  String get battle3v3_execute;

  /// No description provided for @battle3v3_your_attacks.
  ///
  /// In es, this message translates to:
  /// **'⚔️ TUS ATAQUES'**
  String get battle3v3_your_attacks;

  /// No description provided for @battle3v3_rival_attacks.
  ///
  /// In es, this message translates to:
  /// **'🛡️ ATAQUES RIVALES — Tu técnica defiende'**
  String get battle3v3_rival_attacks;

  /// No description provided for @battle3v3_focus_fire.
  ///
  /// In es, this message translates to:
  /// **'🎯 FOCUS FIRE'**
  String get battle3v3_focus_fire;

  /// No description provided for @battle3v3_next_round.
  ///
  /// In es, this message translates to:
  /// **'SIGUIENTE RONDA →'**
  String get battle3v3_next_round;

  /// No description provided for @battle3v3_tap_advance.
  ///
  /// In es, this message translates to:
  /// **'Toca para avanzar'**
  String get battle3v3_tap_advance;

  /// No description provided for @battle3v3_your_attack.
  ///
  /// In es, this message translates to:
  /// **'⚔️ TU ATAQUE'**
  String get battle3v3_your_attack;

  /// No description provided for @battle3v3_rival_attack.
  ///
  /// In es, this message translates to:
  /// **'🛡️ ATAQUE RIVAL'**
  String get battle3v3_rival_attack;

  /// No description provided for @anim_hit.
  ///
  /// In es, this message translates to:
  /// **'¡GOLPE! −{n} HP'**
  String anim_hit(int n);

  /// No description provided for @anim_blocked.
  ///
  /// In es, this message translates to:
  /// **'¡BLOQUEADO!'**
  String get anim_blocked;

  /// No description provided for @anim_draw_dmg.
  ///
  /// In es, this message translates to:
  /// **'EMPATE −{n} HP'**
  String anim_draw_dmg(int n);

  /// No description provided for @anim_draw_neutral.
  ///
  /// In es, this message translates to:
  /// **'EMPATE NEUTRO'**
  String get anim_draw_neutral;

  /// No description provided for @result_victory.
  ///
  /// In es, this message translates to:
  /// **'¡VICTORIA!'**
  String get result_victory;

  /// No description provided for @result_defeat.
  ///
  /// In es, this message translates to:
  /// **'DERROTA'**
  String get result_defeat;

  /// No description provided for @result_draw.
  ///
  /// In es, this message translates to:
  /// **'EMPATE'**
  String get result_draw;

  /// No description provided for @result_victory_3v3.
  ///
  /// In es, this message translates to:
  /// **'¡VICTORIA 3v3!'**
  String get result_victory_3v3;

  /// No description provided for @result_defeat_3v3.
  ///
  /// In es, this message translates to:
  /// **'DERROTA 3v3'**
  String get result_defeat_3v3;

  /// No description provided for @result_draw_3v3.
  ///
  /// In es, this message translates to:
  /// **'EMPATE 3v3'**
  String get result_draw_3v3;

  /// No description provided for @result_rounds.
  ///
  /// In es, this message translates to:
  /// **'{n} rounds'**
  String result_rounds(int n);

  /// No description provided for @result_rematch.
  ///
  /// In es, this message translates to:
  /// **'⚔️ REVANCHA'**
  String get result_rematch;

  /// No description provided for @result_change_hero.
  ///
  /// In es, this message translates to:
  /// **'🔄 CAMBIAR GUERRERO'**
  String get result_change_hero;

  /// No description provided for @result_menu.
  ///
  /// In es, this message translates to:
  /// **'MENÚ PRINCIPAL'**
  String get result_menu;

  /// No description provided for @result_another_3v3.
  ///
  /// In es, this message translates to:
  /// **'🏆 OTRA 3v3'**
  String get result_another_3v3;

  /// No description provided for @rank_title.
  ///
  /// In es, this message translates to:
  /// **'🏆 RANKING'**
  String get rank_title;

  /// No description provided for @rank_empty.
  ///
  /// In es, this message translates to:
  /// **'Sin guerreros aún'**
  String get rank_empty;

  /// No description provided for @rank_wins.
  ///
  /// In es, this message translates to:
  /// **'Victorias'**
  String get rank_wins;

  /// No description provided for @rank_elo.
  ///
  /// In es, this message translates to:
  /// **'ELO'**
  String get rank_elo;

  /// No description provided for @rank_streak.
  ///
  /// In es, this message translates to:
  /// **'Racha'**
  String get rank_streak;

  /// No description provided for @settings_title.
  ///
  /// In es, this message translates to:
  /// **'⚙️ AJUSTES'**
  String get settings_title;

  /// No description provided for @settings_pro.
  ///
  /// In es, this message translates to:
  /// **'Modo PRO'**
  String get settings_pro;

  /// No description provided for @settings_pro_desc_on.
  ///
  /// In es, this message translates to:
  /// **'Progresión, niveles, 3v3'**
  String get settings_pro_desc_on;

  /// No description provided for @settings_pro_desc_off.
  ///
  /// In es, this message translates to:
  /// **'\$2.99 para desbloquear'**
  String get settings_pro_desc_off;

  /// No description provided for @settings_tokens.
  ///
  /// In es, this message translates to:
  /// **'🪙 Tokens'**
  String get settings_tokens;

  /// No description provided for @settings_close.
  ///
  /// In es, this message translates to:
  /// **'CERRAR'**
  String get settings_close;

  /// No description provided for @shop_title.
  ///
  /// In es, this message translates to:
  /// **'🛒 TIENDA'**
  String get shop_title;

  /// No description provided for @shop_tokens_title.
  ///
  /// In es, this message translates to:
  /// **'PAQUETES DE TOKENS'**
  String get shop_tokens_title;

  /// No description provided for @shop_special_title.
  ///
  /// In es, this message translates to:
  /// **'PACKS ESPECIALES'**
  String get shop_special_title;

  /// No description provided for @shop_pack_handful.
  ///
  /// In es, this message translates to:
  /// **'Puñado de Tokens'**
  String get shop_pack_handful;

  /// No description provided for @shop_pack_bag.
  ///
  /// In es, this message translates to:
  /// **'Bolsa de Tokens'**
  String get shop_pack_bag;

  /// No description provided for @shop_pack_chest.
  ///
  /// In es, this message translates to:
  /// **'Cofre de Tokens'**
  String get shop_pack_chest;

  /// No description provided for @shop_pack_treasure.
  ///
  /// In es, this message translates to:
  /// **'Tesoro Legendario'**
  String get shop_pack_treasure;

  /// No description provided for @shop_special_warrior.
  ///
  /// In es, this message translates to:
  /// **'Pack Guerrero'**
  String get shop_special_warrior;

  /// No description provided for @shop_special_warrior_desc.
  ///
  /// In es, this message translates to:
  /// **'1 héroe aleatorio + 300 tokens'**
  String get shop_special_warrior_desc;

  /// No description provided for @shop_special_legend.
  ///
  /// In es, this message translates to:
  /// **'Pack Leyenda'**
  String get shop_special_legend;

  /// No description provided for @shop_special_legend_desc.
  ///
  /// In es, this message translates to:
  /// **'3 héroes aleatorios + 800 tokens'**
  String get shop_special_legend_desc;

  /// No description provided for @shop_special_ultimate.
  ///
  /// In es, this message translates to:
  /// **'Pack Definitivo'**
  String get shop_special_ultimate;

  /// No description provided for @shop_special_ultimate_desc.
  ///
  /// In es, this message translates to:
  /// **'Todos los héroes + 2000 tokens'**
  String get shop_special_ultimate_desc;

  /// No description provided for @shop_popular.
  ///
  /// In es, this message translates to:
  /// **'POPULAR'**
  String get shop_popular;

  /// No description provided for @shop_confirm_title.
  ///
  /// In es, this message translates to:
  /// **'CONFIRMAR COMPRA'**
  String get shop_confirm_title;

  /// No description provided for @shop_confirm_charge.
  ///
  /// In es, this message translates to:
  /// **'Se cobrará {price} a tu cuenta'**
  String shop_confirm_charge(String price);

  /// No description provided for @shop_confirm_btn.
  ///
  /// In es, this message translates to:
  /// **'✅ CONFIRMAR COMPRA'**
  String get shop_confirm_btn;

  /// No description provided for @shop_cancel.
  ///
  /// In es, this message translates to:
  /// **'CANCELAR'**
  String get shop_cancel;

  /// No description provided for @shop_success.
  ///
  /// In es, this message translates to:
  /// **'¡COMPRA EXITOSA!'**
  String get shop_success;

  /// No description provided for @shop_tokens_total.
  ///
  /// In es, this message translates to:
  /// **'tokens totales'**
  String get shop_tokens_total;

  /// No description provided for @shop_heroes_unlocked.
  ///
  /// In es, this message translates to:
  /// **'HÉROES DESBLOQUEADOS'**
  String get shop_heroes_unlocked;

  /// No description provided for @shop_great.
  ///
  /// In es, this message translates to:
  /// **'¡GENIAL!'**
  String get shop_great;

  /// No description provided for @upgrade_title.
  ///
  /// In es, this message translates to:
  /// **'⬆️ MEJORAS'**
  String get upgrade_title;

  /// No description provided for @upgrade_level_up.
  ///
  /// In es, this message translates to:
  /// **'SUBIR DE NIVEL'**
  String get upgrade_level_up;

  /// No description provided for @upgrade_unlock_heroes.
  ///
  /// In es, this message translates to:
  /// **'DESBLOQUEAR HÉROES'**
  String get upgrade_unlock_heroes;

  /// No description provided for @upgrade_cards.
  ///
  /// In es, this message translates to:
  /// **'Cartas: {have}/{need}'**
  String upgrade_cards(int have, int need);

  /// No description provided for @upgrade_improve.
  ///
  /// In es, this message translates to:
  /// **'MEJORAR ({cost} 🪙)'**
  String upgrade_improve(int cost);

  /// No description provided for @upgrade_new_warrior.
  ///
  /// In es, this message translates to:
  /// **'¡NUEVO GUERRERO!'**
  String get upgrade_new_warrior;

  /// No description provided for @upgrade_level_up_title.
  ///
  /// In es, this message translates to:
  /// **'¡LEVEL UP!'**
  String get upgrade_level_up_title;

  /// No description provided for @upgrade_card_obtained.
  ///
  /// In es, this message translates to:
  /// **'CARTA OBTENIDA'**
  String get upgrade_card_obtained;

  /// No description provided for @upgrade_stats_plus1.
  ///
  /// In es, this message translates to:
  /// **'Todas las stats +1'**
  String get upgrade_stats_plus1;

  /// No description provided for @upgrade_remaining.
  ///
  /// In es, this message translates to:
  /// **'🪙 {n} tokens restantes'**
  String upgrade_remaining(int n);

  /// No description provided for @upgrade_more_for.
  ///
  /// In es, this message translates to:
  /// **'{n} más para nivel {lv}'**
  String upgrade_more_for(int n, int lv);

  /// No description provided for @story_title.
  ///
  /// In es, this message translates to:
  /// **'MODO LEYENDA'**
  String get story_title;

  /// No description provided for @story_subtitle.
  ///
  /// In es, this message translates to:
  /// **'El Torneo de las Eras — Elige tu héroe'**
  String get story_subtitle;

  /// No description provided for @story_chapters.
  ///
  /// In es, this message translates to:
  /// **'{n}/{total} capítulos'**
  String story_chapters(int n, int total);

  /// No description provided for @story_locked.
  ///
  /// In es, this message translates to:
  /// **'HÉROES BLOQUEADOS'**
  String get story_locked;

  /// No description provided for @story_play.
  ///
  /// In es, this message translates to:
  /// **'JUGAR →'**
  String get story_play;

  /// No description provided for @story_boss.
  ///
  /// In es, this message translates to:
  /// **'⚠️ BOSS'**
  String get story_boss;

  /// No description provided for @story_final.
  ///
  /// In es, this message translates to:
  /// **'FINAL'**
  String get story_final;

  /// No description provided for @story_combat.
  ///
  /// In es, this message translates to:
  /// **'Combate'**
  String get story_combat;

  /// No description provided for @story_next.
  ///
  /// In es, this message translates to:
  /// **'SIGUIENTE →'**
  String get story_next;

  /// No description provided for @story_fight.
  ///
  /// In es, this message translates to:
  /// **'⚔️ ¡COMBATIR!'**
  String get story_fight;

  /// No description provided for @story_continue.
  ///
  /// In es, this message translates to:
  /// **'CONTINUAR →'**
  String get story_continue;

  /// No description provided for @story_complete.
  ///
  /// In es, this message translates to:
  /// **'🏆 COMPLETAR'**
  String get story_complete;

  /// No description provided for @story_retry.
  ///
  /// In es, this message translates to:
  /// **'🔄 REINTENTAR'**
  String get story_retry;

  /// No description provided for @story_completed_title.
  ///
  /// In es, this message translates to:
  /// **'¡LEYENDA COMPLETADA!'**
  String get story_completed_title;

  /// No description provided for @story_completed_desc.
  ///
  /// In es, this message translates to:
  /// **'{name} ha liberado la Arena'**
  String story_completed_desc(String name);

  /// No description provided for @story_another.
  ///
  /// In es, this message translates to:
  /// **'📜 OTRA LEYENDA'**
  String get story_another;

  /// No description provided for @story_epilogue.
  ///
  /// In es, this message translates to:
  /// **'El Oráculo ha sido derrotado y los guerreros atrapados son libres. Pero la Arena siempre vuelve...'**
  String get story_epilogue;

  /// No description provided for @team_title.
  ///
  /// In es, this message translates to:
  /// **'🏆 COMBATE 3v3'**
  String get team_title;

  /// No description provided for @team_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige 3 guerreros'**
  String get team_subtitle;

  /// No description provided for @rules_title.
  ///
  /// In es, this message translates to:
  /// **'REGLAS'**
  String get rules_title;

  /// No description provided for @rules_damage.
  ///
  /// In es, this message translates to:
  /// **'Daño: Tu stat en la técnica'**
  String get rules_damage;

  /// No description provided for @rules_draw.
  ///
  /// In es, this message translates to:
  /// **'Empate: Mayor stat gana (+1)'**
  String get rules_draw;

  /// No description provided for @rules_ko.
  ///
  /// In es, this message translates to:
  /// **'KO: Pelea hasta HP=0'**
  String get rules_ko;

  /// No description provided for @rules_understood.
  ///
  /// In es, this message translates to:
  /// **'ENTENDIDO'**
  String get rules_understood;

  /// No description provided for @ad_space.
  ///
  /// In es, this message translates to:
  /// **'— ESPACIO PUBLICITARIO —'**
  String get ad_space;

  /// No description provided for @ad_remove.
  ///
  /// In es, this message translates to:
  /// **'Activa PRO para remover anuncios'**
  String get ad_remove;

  /// No description provided for @ad_continue.
  ///
  /// In es, this message translates to:
  /// **'CONTINUAR'**
  String get ad_continue;

  /// No description provided for @ad_reward_watch.
  ///
  /// In es, this message translates to:
  /// **'Ver anuncio = +{n} 🪙'**
  String ad_reward_watch(int n);

  /// No description provided for @daily_title.
  ///
  /// In es, this message translates to:
  /// **'🎁 RECOMPENSA DIARIA'**
  String get daily_title;

  /// No description provided for @daily_claim.
  ///
  /// In es, this message translates to:
  /// **'¡RECLAMAR!'**
  String get daily_claim;

  /// No description provided for @daily_day.
  ///
  /// In es, this message translates to:
  /// **'Día {n}'**
  String daily_day(int n);

  /// No description provided for @tech_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño'**
  String get tech_fist;

  /// No description provided for @tech_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada'**
  String get tech_kick;

  /// No description provided for @tech_grapple.
  ///
  /// In es, this message translates to:
  /// **'Agarre'**
  String get tech_grapple;

  /// No description provided for @tech_block.
  ///
  /// In es, this message translates to:
  /// **'Bloqueo'**
  String get tech_block;

  /// No description provided for @tech_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma'**
  String get tech_palm;

  /// No description provided for @verb_fist_kick.
  ///
  /// In es, this message translates to:
  /// **'El Puño intercepta la Patada'**
  String get verb_fist_kick;

  /// No description provided for @verb_fist_grapple.
  ///
  /// In es, this message translates to:
  /// **'El Puño golpea antes del Agarre'**
  String get verb_fist_grapple;

  /// No description provided for @verb_kick_grapple.
  ///
  /// In es, this message translates to:
  /// **'La Patada aleja del Agarre'**
  String get verb_kick_grapple;

  /// No description provided for @verb_kick_block.
  ///
  /// In es, this message translates to:
  /// **'La Patada rompe el Bloqueo'**
  String get verb_kick_block;

  /// No description provided for @verb_grapple_block.
  ///
  /// In es, this message translates to:
  /// **'El Agarre anula el Bloqueo'**
  String get verb_grapple_block;

  /// No description provided for @verb_grapple_palm.
  ///
  /// In es, this message translates to:
  /// **'El Agarre interrumpe la Palma'**
  String get verb_grapple_palm;

  /// No description provided for @verb_block_palm.
  ///
  /// In es, this message translates to:
  /// **'El Bloqueo desvía la Palma'**
  String get verb_block_palm;

  /// No description provided for @verb_block_fist.
  ///
  /// In es, this message translates to:
  /// **'El Bloqueo detiene el Puño'**
  String get verb_block_fist;

  /// No description provided for @verb_palm_fist.
  ///
  /// In es, this message translates to:
  /// **'La Palma desvía el Puño'**
  String get verb_palm_fist;

  /// No description provided for @verb_palm_kick.
  ///
  /// In es, this message translates to:
  /// **'La Palma neutraliza la Patada'**
  String get verb_palm_kick;

  /// No description provided for @verb_draw.
  ///
  /// In es, this message translates to:
  /// **'Empate de técnicas'**
  String get verb_draw;

  /// No description provided for @hero_karate.
  ///
  /// In es, this message translates to:
  /// **'Karateca'**
  String get hero_karate;

  /// No description provided for @hero_karate_desc.
  ///
  /// In es, this message translates to:
  /// **'Disciplina y golpe certero'**
  String get hero_karate_desc;

  /// No description provided for @hero_karate_lore.
  ///
  /// In es, this message translates to:
  /// **'Formado en el dojo desde los cinco años, el karate moldeó su carácter tanto como su cuerpo.'**
  String get hero_karate_lore;

  /// No description provided for @move_karate_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño de Hierro'**
  String get move_karate_fist;

  /// No description provided for @move_karate_kick.
  ///
  /// In es, this message translates to:
  /// **'Mae Geri'**
  String get move_karate_kick;

  /// No description provided for @move_karate_grapple.
  ///
  /// In es, this message translates to:
  /// **'Agarre Ippon'**
  String get move_karate_grapple;

  /// No description provided for @move_karate_block.
  ///
  /// In es, this message translates to:
  /// **'Uke Bloqueo'**
  String get move_karate_block;

  /// No description provided for @move_karate_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma Shuto'**
  String get move_karate_palm;

  /// No description provided for @hero_templar.
  ///
  /// In es, this message translates to:
  /// **'Templario'**
  String get hero_templar;

  /// No description provided for @hero_templar_desc.
  ///
  /// In es, this message translates to:
  /// **'Defensa y golpe letal'**
  String get hero_templar_desc;

  /// No description provided for @hero_templar_lore.
  ///
  /// In es, this message translates to:
  /// **'Caballero cruzado jurado a proteger los sagrados.'**
  String get hero_templar_lore;

  /// No description provided for @move_templar_fist.
  ///
  /// In es, this message translates to:
  /// **'Golpe Sagrado'**
  String get move_templar_fist;

  /// No description provided for @move_templar_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada Cruzada'**
  String get move_templar_kick;

  /// No description provided for @move_templar_grapple.
  ///
  /// In es, this message translates to:
  /// **'Presa de Hierro'**
  String get move_templar_grapple;

  /// No description provided for @move_templar_block.
  ///
  /// In es, this message translates to:
  /// **'Escudo Divino'**
  String get move_templar_block;

  /// No description provided for @move_templar_palm.
  ///
  /// In es, this message translates to:
  /// **'Imposición Santa'**
  String get move_templar_palm;

  /// No description provided for @hero_ninja.
  ///
  /// In es, this message translates to:
  /// **'Ninja'**
  String get hero_ninja;

  /// No description provided for @hero_ninja_desc.
  ///
  /// In es, this message translates to:
  /// **'Velocidad oculta'**
  String get hero_ninja_desc;

  /// No description provided for @hero_ninja_lore.
  ///
  /// In es, this message translates to:
  /// **'Sombra entre sombras. Cuando lo ves, ya es tarde.'**
  String get hero_ninja_lore;

  /// No description provided for @move_ninja_fist.
  ///
  /// In es, this message translates to:
  /// **'Golpe Sombra'**
  String get move_ninja_fist;

  /// No description provided for @move_ninja_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada Relámpago'**
  String get move_ninja_kick;

  /// No description provided for @move_ninja_grapple.
  ///
  /// In es, this message translates to:
  /// **'Llave Serpiente'**
  String get move_ninja_grapple;

  /// No description provided for @move_ninja_block.
  ///
  /// In es, this message translates to:
  /// **'Niebla Evasiva'**
  String get move_ninja_block;

  /// No description provided for @move_ninja_palm.
  ///
  /// In es, this message translates to:
  /// **'Toque Mortal'**
  String get move_ninja_palm;

  /// No description provided for @hero_sumo.
  ///
  /// In es, this message translates to:
  /// **'Sumo'**
  String get hero_sumo;

  /// No description provided for @hero_sumo_desc.
  ///
  /// In es, this message translates to:
  /// **'Fuerza y agarre'**
  String get hero_sumo_desc;

  /// No description provided for @hero_sumo_lore.
  ///
  /// In es, this message translates to:
  /// **'Montaña de músculos y tradición milenaria.'**
  String get hero_sumo_lore;

  /// No description provided for @move_sumo_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño Terremoto'**
  String get move_sumo_fist;

  /// No description provided for @move_sumo_kick.
  ///
  /// In es, this message translates to:
  /// **'Pisotón Sísmico'**
  String get move_sumo_kick;

  /// No description provided for @move_sumo_grapple.
  ///
  /// In es, this message translates to:
  /// **'Abrazo de Oso'**
  String get move_sumo_grapple;

  /// No description provided for @move_sumo_block.
  ///
  /// In es, this message translates to:
  /// **'Postura Montaña'**
  String get move_sumo_block;

  /// No description provided for @move_sumo_palm.
  ///
  /// In es, this message translates to:
  /// **'Empujón Tsunami'**
  String get move_sumo_palm;

  /// No description provided for @hero_kungfu.
  ///
  /// In es, this message translates to:
  /// **'Kung Fu'**
  String get hero_kungfu;

  /// No description provided for @hero_kungfu_desc.
  ///
  /// In es, this message translates to:
  /// **'Ofensiva total'**
  String get hero_kungfu_desc;

  /// No description provided for @hero_kungfu_lore.
  ///
  /// In es, this message translates to:
  /// **'Maestro de las formas animales, cada golpe es un arte.'**
  String get hero_kungfu_lore;

  /// No description provided for @move_kungfu_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño del Tigre'**
  String get move_kungfu_fist;

  /// No description provided for @move_kungfu_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada de la Grulla'**
  String get move_kungfu_kick;

  /// No description provided for @move_kungfu_grapple.
  ///
  /// In es, this message translates to:
  /// **'Zarpa del Leopardo'**
  String get move_kungfu_grapple;

  /// No description provided for @move_kungfu_block.
  ///
  /// In es, this message translates to:
  /// **'Postura del Mono'**
  String get move_kungfu_block;

  /// No description provided for @move_kungfu_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma de la Serpiente'**
  String get move_kungfu_palm;

  /// No description provided for @hero_samurai.
  ///
  /// In es, this message translates to:
  /// **'Samurai'**
  String get hero_samurai;

  /// No description provided for @hero_samurai_desc.
  ///
  /// In es, this message translates to:
  /// **'Precisión y honor'**
  String get hero_samurai_desc;

  /// No description provided for @hero_samurai_lore.
  ///
  /// In es, this message translates to:
  /// **'Sigue el código del Bushido con devoción absoluta.'**
  String get hero_samurai_lore;

  /// No description provided for @move_samurai_fist.
  ///
  /// In es, this message translates to:
  /// **'Golpe Bushido'**
  String get move_samurai_fist;

  /// No description provided for @move_samurai_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada del Ronin'**
  String get move_samurai_kick;

  /// No description provided for @move_samurai_grapple.
  ///
  /// In es, this message translates to:
  /// **'Agarre Kendo'**
  String get move_samurai_grapple;

  /// No description provided for @move_samurai_block.
  ///
  /// In es, this message translates to:
  /// **'Guardia Iaido'**
  String get move_samurai_block;

  /// No description provided for @move_samurai_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma del Vacío'**
  String get move_samurai_palm;

  /// No description provided for @hero_gladiator.
  ///
  /// In es, this message translates to:
  /// **'Gladiador'**
  String get hero_gladiator;

  /// No description provided for @hero_gladiator_desc.
  ///
  /// In es, this message translates to:
  /// **'Feroz del Coliseo'**
  String get hero_gladiator_desc;

  /// No description provided for @hero_gladiator_lore.
  ///
  /// In es, this message translates to:
  /// **'Nacido en la arena, forjado por la sangre.'**
  String get hero_gladiator_lore;

  /// No description provided for @move_gladiator_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño del Coliseo'**
  String get move_gladiator_fist;

  /// No description provided for @move_gladiator_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada Gladius'**
  String get move_gladiator_kick;

  /// No description provided for @move_gladiator_grapple.
  ///
  /// In es, this message translates to:
  /// **'Presa Mortal'**
  String get move_gladiator_grapple;

  /// No description provided for @move_gladiator_block.
  ///
  /// In es, this message translates to:
  /// **'Escudo Romano'**
  String get move_gladiator_block;

  /// No description provided for @move_gladiator_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma del César'**
  String get move_gladiator_palm;

  /// No description provided for @hero_monk.
  ///
  /// In es, this message translates to:
  /// **'Monje Tibetano'**
  String get hero_monk;

  /// No description provided for @hero_monk_desc.
  ///
  /// In es, this message translates to:
  /// **'Defensa suprema'**
  String get hero_monk_desc;

  /// No description provided for @hero_monk_lore.
  ///
  /// In es, this message translates to:
  /// **'Años de meditación le otorgaron el dominio del chi.'**
  String get hero_monk_lore;

  /// No description provided for @move_monk_fist.
  ///
  /// In es, this message translates to:
  /// **'Toque de Paz'**
  String get move_monk_fist;

  /// No description provided for @move_monk_kick.
  ///
  /// In es, this message translates to:
  /// **'Paso Iluminado'**
  String get move_monk_kick;

  /// No description provided for @move_monk_grapple.
  ///
  /// In es, this message translates to:
  /// **'Abrazo Compasivo'**
  String get move_monk_grapple;

  /// No description provided for @move_monk_block.
  ///
  /// In es, this message translates to:
  /// **'Barrera de Chi'**
  String get move_monk_block;

  /// No description provided for @move_monk_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma Celestial'**
  String get move_monk_palm;

  /// No description provided for @hero_viking.
  ///
  /// In es, this message translates to:
  /// **'Vikingo'**
  String get hero_viking;

  /// No description provided for @hero_viking_desc.
  ///
  /// In es, this message translates to:
  /// **'Furia nórdica'**
  String get hero_viking_desc;

  /// No description provided for @hero_viking_lore.
  ///
  /// In es, this message translates to:
  /// **'Descendiente de Odín, no conoce el miedo.'**
  String get hero_viking_lore;

  /// No description provided for @move_viking_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño de Thor'**
  String get move_viking_fist;

  /// No description provided for @move_viking_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada Berserker'**
  String get move_viking_kick;

  /// No description provided for @move_viking_grapple.
  ///
  /// In es, this message translates to:
  /// **'Agarre del Lobo'**
  String get move_viking_grapple;

  /// No description provided for @move_viking_block.
  ///
  /// In es, this message translates to:
  /// **'Muro de Escudos'**
  String get move_viking_block;

  /// No description provided for @move_viking_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma Rúnica'**
  String get move_viking_palm;

  /// No description provided for @hero_capoeira.
  ///
  /// In es, this message translates to:
  /// **'Capoeirista'**
  String get hero_capoeira;

  /// No description provided for @hero_capoeira_desc.
  ///
  /// In es, this message translates to:
  /// **'Danza mortal'**
  String get hero_capoeira_desc;

  /// No description provided for @hero_capoeira_lore.
  ///
  /// In es, this message translates to:
  /// **'En las calles de Salvador, la capoeira es libertad.'**
  String get hero_capoeira_lore;

  /// No description provided for @move_capoeira_fist.
  ///
  /// In es, this message translates to:
  /// **'Golpe Mandinga'**
  String get move_capoeira_fist;

  /// No description provided for @move_capoeira_kick.
  ///
  /// In es, this message translates to:
  /// **'Meia Lua de Compasso'**
  String get move_capoeira_kick;

  /// No description provided for @move_capoeira_grapple.
  ///
  /// In es, this message translates to:
  /// **'Rasteira'**
  String get move_capoeira_grapple;

  /// No description provided for @move_capoeira_block.
  ///
  /// In es, this message translates to:
  /// **'Esquiva Ginga'**
  String get move_capoeira_block;

  /// No description provided for @move_capoeira_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma Axé'**
  String get move_capoeira_palm;

  /// No description provided for @hero_spartan.
  ///
  /// In es, this message translates to:
  /// **'Espartano'**
  String get hero_spartan;

  /// No description provided for @hero_spartan_desc.
  ///
  /// In es, this message translates to:
  /// **'Disciplina absoluta'**
  String get hero_spartan_desc;

  /// No description provided for @hero_spartan_lore.
  ///
  /// In es, this message translates to:
  /// **'Criado en la agogé, su vida entera es guerra.'**
  String get hero_spartan_lore;

  /// No description provided for @move_spartan_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño Espartano'**
  String get move_spartan_fist;

  /// No description provided for @move_spartan_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada del Abismo'**
  String get move_spartan_kick;

  /// No description provided for @move_spartan_grapple.
  ///
  /// In es, this message translates to:
  /// **'Presa Falange'**
  String get move_spartan_grapple;

  /// No description provided for @move_spartan_block.
  ///
  /// In es, this message translates to:
  /// **'Escudo Termópilas'**
  String get move_spartan_block;

  /// No description provided for @move_spartan_palm.
  ///
  /// In es, this message translates to:
  /// **'Golpe de Lanza'**
  String get move_spartan_palm;

  /// No description provided for @hero_muaythai.
  ///
  /// In es, this message translates to:
  /// **'Nak Muay'**
  String get hero_muaythai;

  /// No description provided for @hero_muaythai_desc.
  ///
  /// In es, this message translates to:
  /// **'Ocho miembros'**
  String get hero_muaythai_desc;

  /// No description provided for @hero_muaythai_lore.
  ///
  /// In es, this message translates to:
  /// **'El arte de los ocho miembros: puños, codos, rodillas y espinillas.'**
  String get hero_muaythai_lore;

  /// No description provided for @move_muaythai_fist.
  ///
  /// In es, this message translates to:
  /// **'Codo Devastador'**
  String get move_muaythai_fist;

  /// No description provided for @move_muaythai_kick.
  ///
  /// In es, this message translates to:
  /// **'Rodillazo Wai Kru'**
  String get move_muaythai_kick;

  /// No description provided for @move_muaythai_grapple.
  ///
  /// In es, this message translates to:
  /// **'Clinch Tailandés'**
  String get move_muaythai_grapple;

  /// No description provided for @move_muaythai_block.
  ///
  /// In es, this message translates to:
  /// **'Guardia Alta'**
  String get move_muaythai_block;

  /// No description provided for @move_muaythai_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma Muay Boran'**
  String get move_muaythai_palm;

  /// No description provided for @hero_taichi.
  ///
  /// In es, this message translates to:
  /// **'Tai Chi'**
  String get hero_taichi;

  /// No description provided for @hero_taichi_desc.
  ///
  /// In es, this message translates to:
  /// **'Redirige la fuerza'**
  String get hero_taichi_desc;

  /// No description provided for @hero_taichi_lore.
  ///
  /// In es, this message translates to:
  /// **'El agua vence a la roca. Suave por fuera, letal por dentro.'**
  String get hero_taichi_lore;

  /// No description provided for @move_taichi_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño de Algodón'**
  String get move_taichi_fist;

  /// No description provided for @move_taichi_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada Nube'**
  String get move_taichi_kick;

  /// No description provided for @move_taichi_grapple.
  ///
  /// In es, this message translates to:
  /// **'Flujo del Río'**
  String get move_taichi_grapple;

  /// No description provided for @move_taichi_block.
  ///
  /// In es, this message translates to:
  /// **'Raíz del Sauce'**
  String get move_taichi_block;

  /// No description provided for @move_taichi_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma Tai Ji'**
  String get move_taichi_palm;

  /// No description provided for @hero_wrestler.
  ///
  /// In es, this message translates to:
  /// **'Luchador Olímpico'**
  String get hero_wrestler;

  /// No description provided for @hero_wrestler_desc.
  ///
  /// In es, this message translates to:
  /// **'Dominio del suelo'**
  String get hero_wrestler_desc;

  /// No description provided for @hero_wrestler_lore.
  ///
  /// In es, this message translates to:
  /// **'Su técnica de derribo es perfecta. En el suelo, el combate ya terminó.'**
  String get hero_wrestler_lore;

  /// No description provided for @move_wrestler_fist.
  ///
  /// In es, this message translates to:
  /// **'Cross de Lucha'**
  String get move_wrestler_fist;

  /// No description provided for @move_wrestler_kick.
  ///
  /// In es, this message translates to:
  /// **'Barrida Olímpica'**
  String get move_wrestler_kick;

  /// No description provided for @move_wrestler_grapple.
  ///
  /// In es, this message translates to:
  /// **'Derribo Doble'**
  String get move_wrestler_grapple;

  /// No description provided for @move_wrestler_block.
  ///
  /// In es, this message translates to:
  /// **'Sprawl Defensivo'**
  String get move_wrestler_block;

  /// No description provided for @move_wrestler_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma de Control'**
  String get move_wrestler_palm;

  /// No description provided for @hero_pirate.
  ///
  /// In es, this message translates to:
  /// **'Pirata'**
  String get hero_pirate;

  /// No description provided for @hero_pirate_desc.
  ///
  /// In es, this message translates to:
  /// **'Sin reglas'**
  String get hero_pirate_desc;

  /// No description provided for @hero_pirate_lore.
  ///
  /// In es, this message translates to:
  /// **'Los siete mares forjaron su estilo: sucio e impredecible.'**
  String get hero_pirate_lore;

  /// No description provided for @move_pirate_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño de Ron'**
  String get move_pirate_fist;

  /// No description provided for @move_pirate_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada Corsaria'**
  String get move_pirate_kick;

  /// No description provided for @move_pirate_grapple.
  ///
  /// In es, this message translates to:
  /// **'Abrazo del Kraken'**
  String get move_pirate_grapple;

  /// No description provided for @move_pirate_block.
  ///
  /// In es, this message translates to:
  /// **'Tabla Salvadora'**
  String get move_pirate_block;

  /// No description provided for @move_pirate_palm.
  ///
  /// In es, this message translates to:
  /// **'Bofetada Pirata'**
  String get move_pirate_palm;

  /// No description provided for @hero_amazon.
  ///
  /// In es, this message translates to:
  /// **'Amazona'**
  String get hero_amazon;

  /// No description provided for @hero_amazon_desc.
  ///
  /// In es, this message translates to:
  /// **'Guerrera de la selva'**
  String get hero_amazon_desc;

  /// No description provided for @hero_amazon_lore.
  ///
  /// In es, this message translates to:
  /// **'Hija de la selva, criada entre jaguares.'**
  String get hero_amazon_lore;

  /// No description provided for @move_amazon_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño Salvaje'**
  String get move_amazon_fist;

  /// No description provided for @move_amazon_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada Jaguar'**
  String get move_amazon_kick;

  /// No description provided for @move_amazon_grapple.
  ///
  /// In es, this message translates to:
  /// **'Liana Mortal'**
  String get move_amazon_grapple;

  /// No description provided for @move_amazon_block.
  ///
  /// In es, this message translates to:
  /// **'Escudo de Corteza'**
  String get move_amazon_block;

  /// No description provided for @move_amazon_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma Venenosa'**
  String get move_amazon_palm;

  /// No description provided for @hero_shaman.
  ///
  /// In es, this message translates to:
  /// **'Chamán'**
  String get hero_shaman;

  /// No description provided for @hero_shaman_desc.
  ///
  /// In es, this message translates to:
  /// **'Poder místico'**
  String get hero_shaman_desc;

  /// No description provided for @hero_shaman_lore.
  ///
  /// In es, this message translates to:
  /// **'Conectado con los espíritus ancestrales.'**
  String get hero_shaman_lore;

  /// No description provided for @move_shaman_fist.
  ///
  /// In es, this message translates to:
  /// **'Golpe Espiritual'**
  String get move_shaman_fist;

  /// No description provided for @move_shaman_kick.
  ///
  /// In es, this message translates to:
  /// **'Danza de Fuego'**
  String get move_shaman_kick;

  /// No description provided for @move_shaman_grapple.
  ///
  /// In es, this message translates to:
  /// **'Raíces Ancestrales'**
  String get move_shaman_grapple;

  /// No description provided for @move_shaman_block.
  ///
  /// In es, this message translates to:
  /// **'Barrera Mística'**
  String get move_shaman_block;

  /// No description provided for @move_shaman_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma del Más Allá'**
  String get move_shaman_palm;

  /// No description provided for @hero_berserker.
  ///
  /// In es, this message translates to:
  /// **'Berserker'**
  String get hero_berserker;

  /// No description provided for @hero_berserker_desc.
  ///
  /// In es, this message translates to:
  /// **'Rabia sin defensa'**
  String get hero_berserker_desc;

  /// No description provided for @hero_berserker_lore.
  ///
  /// In es, this message translates to:
  /// **'La furia lo consume en batalla. No siente dolor.'**
  String get hero_berserker_lore;

  /// No description provided for @move_berserker_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño de Furia'**
  String get move_berserker_fist;

  /// No description provided for @move_berserker_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada Salvaje'**
  String get move_berserker_kick;

  /// No description provided for @move_berserker_grapple.
  ///
  /// In es, this message translates to:
  /// **'Embestida Brutal'**
  String get move_berserker_grapple;

  /// No description provided for @move_berserker_block.
  ///
  /// In es, this message translates to:
  /// **'Grito de Guerra'**
  String get move_berserker_block;

  /// No description provided for @move_berserker_palm.
  ///
  /// In es, this message translates to:
  /// **'Zarpazo Final'**
  String get move_berserker_palm;

  /// No description provided for @hero_wushu.
  ///
  /// In es, this message translates to:
  /// **'Wushu'**
  String get hero_wushu;

  /// No description provided for @hero_wushu_desc.
  ///
  /// In es, this message translates to:
  /// **'Forma perfecta'**
  String get hero_wushu_desc;

  /// No description provided for @hero_wushu_lore.
  ///
  /// In es, this message translates to:
  /// **'Cada movimiento es coreografiado a la perfección.'**
  String get hero_wushu_lore;

  /// No description provided for @move_wushu_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño Flor de Loto'**
  String get move_wushu_fist;

  /// No description provided for @move_wushu_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada Mariposa'**
  String get move_wushu_kick;

  /// No description provided for @move_wushu_grapple.
  ///
  /// In es, this message translates to:
  /// **'Llave de Seda'**
  String get move_wushu_grapple;

  /// No description provided for @move_wushu_block.
  ///
  /// In es, this message translates to:
  /// **'Postura del Fénix'**
  String get move_wushu_block;

  /// No description provided for @move_wushu_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma del Dragón Dorado'**
  String get move_wushu_palm;

  /// No description provided for @hero_mongol.
  ///
  /// In es, this message translates to:
  /// **'Mongol'**
  String get hero_mongol;

  /// No description provided for @hero_mongol_desc.
  ///
  /// In es, this message translates to:
  /// **'Adaptación brutal'**
  String get hero_mongol_desc;

  /// No description provided for @hero_mongol_lore.
  ///
  /// In es, this message translates to:
  /// **'Heredero de Genghis Khan, imparable como la horda dorada.'**
  String get hero_mongol_lore;

  /// No description provided for @move_mongol_fist.
  ///
  /// In es, this message translates to:
  /// **'Puño de la Estepa'**
  String get move_mongol_fist;

  /// No description provided for @move_mongol_kick.
  ///
  /// In es, this message translates to:
  /// **'Patada del Jinete'**
  String get move_mongol_kick;

  /// No description provided for @move_mongol_grapple.
  ///
  /// In es, this message translates to:
  /// **'Lazo Mongol'**
  String get move_mongol_grapple;

  /// No description provided for @move_mongol_block.
  ///
  /// In es, this message translates to:
  /// **'Guardia Nómada'**
  String get move_mongol_block;

  /// No description provided for @move_mongol_palm.
  ///
  /// In es, this message translates to:
  /// **'Palma del Khan'**
  String get move_mongol_palm;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ja', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
    case 'ja':
      return SJa();
    case 'pt':
      return SPt();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
