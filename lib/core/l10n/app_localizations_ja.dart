// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class SJa extends S {
  SJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '闘技場';

  @override
  String get login_title => '闘技場';

  @override
  String get login_subtitle => 'タクティカルコンバット';

  @override
  String get login_placeholder => '名前...';

  @override
  String get login_prompt => '戦士の名前を入力';

  @override
  String get login_enter => '入場';

  @override
  String home_hello(String name) {
    return 'やあ、$name';
  }

  @override
  String get home_ready => '戦う準備はいい？';

  @override
  String get home_1v1 => '⚔️ 1対1';

  @override
  String get home_3v3 => '🏆 3対3';

  @override
  String get home_story => '📜 レジェンドモード';

  @override
  String get home_ranking => '🏆 ランキング';

  @override
  String get home_shop => '🛒 ショップ';

  @override
  String get home_upgrades => '⬆️ 強化';

  @override
  String get home_rules => '📜 ルール';

  @override
  String get home_pro_teaser_title => '🔥 レジェンドモード';

  @override
  String get home_pro_teaser_desc => 'ヒーロー解放、レベルアップ、ステータス強化、3対3で戦おう。';

  @override
  String get home_pro_teaser_cta => 'PROを有効化 →';

  @override
  String get heroes_title => '戦士を選べ';

  @override
  String get heroes_subtitle => 'タップで詳細を見る';

  @override
  String heroes_unlock(int cost) {
    return '🔓 解放 ($cost 🪙)';
  }

  @override
  String get heroes_choose => '選択 →';

  @override
  String get heroes_lore_btn => '🔄 伝承と技を見る';

  @override
  String get heroes_stats_btn => '🔄 ステータスを見る';

  @override
  String get heroes_first => '⭐ 最初の戦士';

  @override
  String get diff_title => '難易度';

  @override
  String get diff_easy => 'イージー';

  @override
  String get diff_easy_desc => 'ランダムに選択';

  @override
  String get diff_normal => 'ノーマル';

  @override
  String get diff_normal_desc => '最強ステータスを使用';

  @override
  String get diff_hard => 'ハード';

  @override
  String get diff_hard_desc => 'あなたの動きを読む';

  @override
  String get diff_go => '⚔️ 闘技場へ！';

  @override
  String battle_round(int n) {
    return 'ラウンド $n';
  }

  @override
  String get battle_pick => '技を選べ';

  @override
  String get battle_fighting => '戦闘中！';

  @override
  String get battle_win => '勝利！';

  @override
  String get battle_lose => '敗北';

  @override
  String get battle_draw => '引き分け！';

  @override
  String get battle_next => '次のラウンド →';

  @override
  String get battle_ref => '📖 参照';

  @override
  String get battle_history => '履歴';

  @override
  String battle_power(int n) {
    return '威力 $n';
  }

  @override
  String get battle_beats => '有効';

  @override
  String battle3v3_round(int n) {
    return '🏆 ラウンド $n';
  }

  @override
  String get battle3v3_subtitle => '1つの技 = 攻撃 + 防御 · 同時解決';

  @override
  String get battle3v3_enemies => '⚔️ 敵チーム';

  @override
  String get battle3v3_your_team => '🛡️ 味方チーム';

  @override
  String battle3v3_pick_tech(String name) {
    return '$name: 技を選べ';
  }

  @override
  String get battle3v3_pick_hint => '⚔️ 攻撃と 🛡️ 防御を同じ技で';

  @override
  String battle3v3_pick_target(String name) {
    return '$name: 誰を攻撃する？';
  }

  @override
  String get battle3v3_target_hint => '上の敵をタップ · あなたの技は防御にもなる';

  @override
  String get battle3v3_all_ready => '✅ 全戦士準備完了';

  @override
  String get battle3v3_execute => '⚔️ ラウンド実行！';

  @override
  String get battle3v3_your_attacks => '⚔️ あなたの攻撃';

  @override
  String get battle3v3_rival_attacks => '🛡️ 敵の攻撃 — あなたの技が防御';

  @override
  String get battle3v3_focus_fire => '🎯 集中攻撃';

  @override
  String get battle3v3_next_round => '次のラウンド →';

  @override
  String get battle3v3_tap_advance => 'タップで進む';

  @override
  String get battle3v3_your_attack => '⚔️ あなたの攻撃';

  @override
  String get battle3v3_rival_attack => '🛡️ 敵の攻撃';

  @override
  String anim_hit(int n) {
    return '命中！ −$n HP';
  }

  @override
  String get anim_blocked => 'ブロック！';

  @override
  String anim_draw_dmg(int n) {
    return '引分 −$n HP';
  }

  @override
  String get anim_draw_neutral => '完全引分';

  @override
  String get result_victory => '勝利！';

  @override
  String get result_defeat => '敗北';

  @override
  String get result_draw => '引き分け';

  @override
  String get result_victory_3v3 => '3対3 勝利！';

  @override
  String get result_defeat_3v3 => '3対3 敗北';

  @override
  String get result_draw_3v3 => '3対3 引分';

  @override
  String result_rounds(int n) {
    return '$n ラウンド';
  }

  @override
  String get result_rematch => '⚔️ リマッチ';

  @override
  String get result_change_hero => '🔄 戦士変更';

  @override
  String get result_menu => 'メインメニュー';

  @override
  String get result_another_3v3 => '🏆 もう一度3v3';

  @override
  String get rank_title => '🏆 ランキング';

  @override
  String get rank_empty => 'まだ戦士がいません';

  @override
  String get rank_wins => '勝利';

  @override
  String get rank_elo => 'ELO';

  @override
  String get rank_streak => '連勝';

  @override
  String get settings_title => '⚙️ 設定';

  @override
  String get settings_pro => 'PROモード';

  @override
  String get settings_pro_desc_on => '成長、レベル、3対3';

  @override
  String get settings_pro_desc_off => '\$2.99で解放';

  @override
  String get settings_tokens => '🪙 トークン';

  @override
  String get settings_close => '閉じる';

  @override
  String get shop_title => '🛒 ショップ';

  @override
  String get shop_tokens_title => 'トークンパック';

  @override
  String get shop_special_title => 'スペシャルパック';

  @override
  String get shop_pack_handful => 'トークン少量';

  @override
  String get shop_pack_bag => 'トークン袋';

  @override
  String get shop_pack_chest => 'トークン宝箱';

  @override
  String get shop_pack_treasure => '伝説の財宝';

  @override
  String get shop_special_warrior => '戦士パック';

  @override
  String get shop_special_warrior_desc => 'ランダムヒーロー1体 + 300トークン';

  @override
  String get shop_special_legend => 'レジェンドパック';

  @override
  String get shop_special_legend_desc => 'ランダムヒーロー3体 + 800トークン';

  @override
  String get shop_special_ultimate => '究極パック';

  @override
  String get shop_special_ultimate_desc => '全ヒーロー + 2000トークン';

  @override
  String get shop_popular => '人気';

  @override
  String get shop_confirm_title => '購入確認';

  @override
  String shop_confirm_charge(String price) {
    return '$priceが請求されます';
  }

  @override
  String get shop_confirm_btn => '✅ 購入確定';

  @override
  String get shop_cancel => 'キャンセル';

  @override
  String get shop_success => '購入成功！';

  @override
  String get shop_tokens_total => '合計トークン';

  @override
  String get shop_heroes_unlocked => '解放されたヒーロー';

  @override
  String get shop_great => '素晴らしい！';

  @override
  String get upgrade_title => '⬆️ 強化';

  @override
  String get upgrade_level_up => 'レベルアップ';

  @override
  String get upgrade_unlock_heroes => 'ヒーロー解放';

  @override
  String upgrade_cards(int have, int need) {
    return 'カード: $have/$need';
  }

  @override
  String upgrade_improve(int cost) {
    return '強化 ($cost 🪙)';
  }

  @override
  String get upgrade_new_warrior => '新しい戦士！';

  @override
  String get upgrade_level_up_title => 'レベルアップ！';

  @override
  String get upgrade_card_obtained => 'カード獲得';

  @override
  String get upgrade_stats_plus1 => '全ステータス +1';

  @override
  String upgrade_remaining(int n) {
    return '🪙 残り $n トークン';
  }

  @override
  String upgrade_more_for(int n, int lv) {
    return 'レベル $lv まであと $n';
  }

  @override
  String get story_title => 'レジェンドモード';

  @override
  String get story_subtitle => '時代の闘技会 — ヒーローを選べ';

  @override
  String story_chapters(int n, int total) {
    return '$n/$total 章';
  }

  @override
  String get story_locked => 'ロック中のヒーロー';

  @override
  String get story_play => 'プレイ →';

  @override
  String get story_boss => '⚠️ ボス';

  @override
  String get story_final => '最終';

  @override
  String get story_combat => '戦闘';

  @override
  String get story_next => '次へ →';

  @override
  String get story_fight => '⚔️ 戦え！';

  @override
  String get story_continue => '続ける →';

  @override
  String get story_complete => '🏆 完了';

  @override
  String get story_retry => '🔄 再挑戦';

  @override
  String get story_completed_title => 'レジェンド完了！';

  @override
  String story_completed_desc(String name) {
    return '$nameが闘技場を解放した';
  }

  @override
  String get story_another => '📜 別のレジェンド';

  @override
  String get story_epilogue => '神託者は倒され、囚われた戦士たちは自由になった。しかし闘技場はいつも戻ってくる...';

  @override
  String get team_title => '🏆 3対3バトル';

  @override
  String get team_subtitle => '3人の戦士を選べ';

  @override
  String get rules_title => 'ルール';

  @override
  String get rules_damage => 'ダメージ: 技のステータス値';

  @override
  String get rules_draw => '引分: 高いステータスが勝ち (+1)';

  @override
  String get rules_ko => 'KO: HP=0まで戦う';

  @override
  String get rules_understood => '了解';

  @override
  String get ad_space => '— 広告スペース —';

  @override
  String get ad_remove => 'PROで広告を削除';

  @override
  String get ad_continue => '続ける';

  @override
  String ad_reward_watch(int n) {
    return '広告視聴 = +$n 🪙';
  }

  @override
  String get daily_title => '🎁 デイリー報酬';

  @override
  String get daily_claim => '受け取る！';

  @override
  String daily_day(int n) {
    return '$n日目';
  }

  @override
  String get tech_fist => '拳';

  @override
  String get tech_kick => '蹴り';

  @override
  String get tech_grapple => '組技';

  @override
  String get tech_block => '防御';

  @override
  String get tech_palm => '掌';

  @override
  String get verb_fist_kick => '拳が蹴りを迎撃';

  @override
  String get verb_fist_grapple => '拳が組技より先に命中';

  @override
  String get verb_kick_grapple => '蹴りが組技を引き離す';

  @override
  String get verb_kick_block => '蹴りが防御を破る';

  @override
  String get verb_grapple_block => '組技が防御を無効化';

  @override
  String get verb_grapple_palm => '組技が掌を中断';

  @override
  String get verb_block_palm => '防御が掌をそらす';

  @override
  String get verb_block_fist => '防御が拳を止める';

  @override
  String get verb_palm_fist => '掌が拳をそらす';

  @override
  String get verb_palm_kick => '掌が蹴りを無力化';

  @override
  String get verb_draw => '技の引き分け';

  @override
  String get hero_karate => '空手家';

  @override
  String get hero_karate_desc => '規律と正確な打撃';

  @override
  String get hero_karate_lore => '五歳から道場で鍛えられた。';

  @override
  String get move_karate_fist => '鉄拳';

  @override
  String get move_karate_kick => '前蹴り';

  @override
  String get move_karate_grapple => '一本掴み';

  @override
  String get move_karate_block => '受け';

  @override
  String get move_karate_palm => '手刀';

  @override
  String get hero_templar => 'テンプル騎士';

  @override
  String get hero_templar_desc => '防御と必殺の一撃';

  @override
  String get hero_templar_lore => '聖地を守る十字軍の騎士。';

  @override
  String get move_templar_fist => '聖なる打撃';

  @override
  String get move_templar_kick => '十字蹴り';

  @override
  String get move_templar_grapple => '鉄の掴み';

  @override
  String get move_templar_block => '神聖盾';

  @override
  String get move_templar_palm => '聖なる手';

  @override
  String get hero_ninja => '忍者';

  @override
  String get hero_ninja_desc => '隠された速さ';

  @override
  String get hero_ninja_lore => '影の中の影。見た時にはもう遅い。';

  @override
  String get move_ninja_fist => '影打ち';

  @override
  String get move_ninja_kick => '稲妻蹴り';

  @override
  String get move_ninja_grapple => '蛇縛り';

  @override
  String get move_ninja_block => '霧隠れ';

  @override
  String get move_ninja_palm => '死の触れ';

  @override
  String get hero_sumo => '力士';

  @override
  String get hero_sumo_desc => '力と組技';

  @override
  String get hero_sumo_lore => '筋肉の山と千年の伝統。';

  @override
  String get move_sumo_fist => '地震拳';

  @override
  String get move_sumo_kick => '地響き踏み';

  @override
  String get move_sumo_grapple => '熊抱き';

  @override
  String get move_sumo_block => '山の構え';

  @override
  String get move_sumo_palm => '津波押し';

  @override
  String get hero_kungfu => 'カンフー';

  @override
  String get hero_kungfu_desc => '全力攻撃';

  @override
  String get hero_kungfu_lore => '動物の形の達人。';

  @override
  String get move_kungfu_fist => '虎拳';

  @override
  String get move_kungfu_kick => '鶴蹴り';

  @override
  String get move_kungfu_grapple => '豹爪';

  @override
  String get move_kungfu_block => '猿の構え';

  @override
  String get move_kungfu_palm => '蛇掌';

  @override
  String get hero_samurai => '侍';

  @override
  String get hero_samurai_desc => '精密と名誉';

  @override
  String get hero_samurai_lore => '武士道に絶対的な献身。';

  @override
  String get move_samurai_fist => '武士道打ち';

  @override
  String get move_samurai_kick => '浪人蹴り';

  @override
  String get move_samurai_grapple => '剣道掴み';

  @override
  String get move_samurai_block => '居合の構え';

  @override
  String get move_samurai_palm => '空の掌';

  @override
  String get hero_gladiator => '剣闘士';

  @override
  String get hero_gladiator_desc => 'コロセウムの猛者';

  @override
  String get hero_gladiator_lore => '闘技場に生まれ、血で鍛えられた。';

  @override
  String get move_gladiator_fist => '闘技場の拳';

  @override
  String get move_gladiator_kick => '剣闘蹴り';

  @override
  String get move_gladiator_grapple => '死の掴み';

  @override
  String get move_gladiator_block => 'ローマ盾';

  @override
  String get move_gladiator_palm => '皇帝の掌';

  @override
  String get hero_monk => 'チベット僧';

  @override
  String get hero_monk_desc => '究極の防御';

  @override
  String get hero_monk_lore => '長年の瞑想で気を習得。';

  @override
  String get move_monk_fist => '平和の触れ';

  @override
  String get move_monk_kick => '悟りの歩み';

  @override
  String get move_monk_grapple => '慈悲の抱擁';

  @override
  String get move_monk_block => '気の壁';

  @override
  String get move_monk_palm => '天の掌';

  @override
  String get hero_viking => 'ヴァイキング';

  @override
  String get hero_viking_desc => '北欧の怒り';

  @override
  String get hero_viking_lore => 'オーディンの子孫。恐れを知らない。';

  @override
  String get move_viking_fist => 'トールの拳';

  @override
  String get move_viking_kick => '狂戦士蹴り';

  @override
  String get move_viking_grapple => '狼掴み';

  @override
  String get move_viking_block => '盾の壁';

  @override
  String get move_viking_palm => 'ルーンの掌';

  @override
  String get hero_capoeira => 'カポエイリスタ';

  @override
  String get hero_capoeira_desc => '致命的な踊り';

  @override
  String get hero_capoeira_lore => 'サルバドールの路上でカポエイラは自由。';

  @override
  String get move_capoeira_fist => 'マンジンガ打ち';

  @override
  String get move_capoeira_kick => 'メイア・ルア';

  @override
  String get move_capoeira_grapple => 'ハステイラ';

  @override
  String get move_capoeira_block => 'ジンガ回避';

  @override
  String get move_capoeira_palm => 'アシェの掌';

  @override
  String get hero_spartan => 'スパルタ戦士';

  @override
  String get hero_spartan_desc => '絶対的規律';

  @override
  String get hero_spartan_lore => 'アゴーゲーで育ち、生涯が戦い。';

  @override
  String get move_spartan_fist => 'スパルタ拳';

  @override
  String get move_spartan_kick => '深淵蹴り';

  @override
  String get move_spartan_grapple => 'ファランクス掴み';

  @override
  String get move_spartan_block => 'テルモピュライ盾';

  @override
  String get move_spartan_palm => '槍撃';

  @override
  String get hero_muaythai => 'ナックモエ';

  @override
  String get hero_muaythai_desc => '八つの武器';

  @override
  String get hero_muaythai_lore => '八つの武器の技術。';

  @override
  String get move_muaythai_fist => '破壊肘';

  @override
  String get move_muaythai_kick => 'ワイクルー膝';

  @override
  String get move_muaythai_grapple => 'タイクリンチ';

  @override
  String get move_muaythai_block => '高い構え';

  @override
  String get move_muaythai_palm => 'ムエボーラン掌';

  @override
  String get hero_taichi => '太極拳';

  @override
  String get hero_taichi_desc => '力を流す';

  @override
  String get hero_taichi_lore => '水は岩に勝つ。';

  @override
  String get move_taichi_fist => '綿の拳';

  @override
  String get move_taichi_kick => '雲蹴り';

  @override
  String get move_taichi_grapple => '川の流れ';

  @override
  String get move_taichi_block => '柳の根';

  @override
  String get move_taichi_palm => '太極掌';

  @override
  String get hero_wrestler => 'レスラー';

  @override
  String get hero_wrestler_desc => '地上の支配';

  @override
  String get hero_wrestler_lore => '完璧なテイクダウン技術。';

  @override
  String get move_wrestler_fist => 'レスリング打ち';

  @override
  String get move_wrestler_kick => 'オリンピック払い';

  @override
  String get move_wrestler_grapple => 'ダブルテイクダウン';

  @override
  String get move_wrestler_block => 'スプロール';

  @override
  String get move_wrestler_palm => '制御の掌';

  @override
  String get hero_pirate => '海賊';

  @override
  String get hero_pirate_desc => 'ルールなし';

  @override
  String get hero_pirate_lore => '七つの海が彼のスタイルを鍛えた。';

  @override
  String get move_pirate_fist => 'ラム酒パンチ';

  @override
  String get move_pirate_kick => '海賊蹴り';

  @override
  String get move_pirate_grapple => 'クラーケンの抱擁';

  @override
  String get move_pirate_block => '板の盾';

  @override
  String get move_pirate_palm => '海賊の平手';

  @override
  String get hero_amazon => 'アマゾネス';

  @override
  String get hero_amazon_desc => '密林の戦士';

  @override
  String get hero_amazon_lore => '密林の娘、ジャガーと共に育った。';

  @override
  String get move_amazon_fist => '野生の拳';

  @override
  String get move_amazon_kick => 'ジャガー蹴り';

  @override
  String get move_amazon_grapple => '致命の蔓';

  @override
  String get move_amazon_block => '樹皮の盾';

  @override
  String get move_amazon_palm => '毒の掌';

  @override
  String get hero_shaman => 'シャーマン';

  @override
  String get hero_shaman_desc => '神秘の力';

  @override
  String get hero_shaman_lore => '祖先の霊と繋がる。';

  @override
  String get move_shaman_fist => '霊打ち';

  @override
  String get move_shaman_kick => '火の踊り';

  @override
  String get move_shaman_grapple => '祖先の根';

  @override
  String get move_shaman_block => '神秘の壁';

  @override
  String get move_shaman_palm => '彼方の掌';

  @override
  String get hero_berserker => 'バーサーカー';

  @override
  String get hero_berserker_desc => '防御なき怒り';

  @override
  String get hero_berserker_lore => '戦場で怒りに飲まれる。痛みを感じない。';

  @override
  String get move_berserker_fist => '怒りの拳';

  @override
  String get move_berserker_kick => '野蛮蹴り';

  @override
  String get move_berserker_grapple => '残忍な突進';

  @override
  String get move_berserker_block => '鬨の声';

  @override
  String get move_berserker_palm => '最後の爪';

  @override
  String get hero_wushu => '武術';

  @override
  String get hero_wushu_desc => '完璧な型';

  @override
  String get hero_wushu_lore => '全ての動きが完璧に振り付けられている。';

  @override
  String get move_wushu_fist => '蓮花拳';

  @override
  String get move_wushu_kick => '蝶蹴り';

  @override
  String get move_wushu_grapple => '絹の鍵';

  @override
  String get move_wushu_block => '鳳凰の構え';

  @override
  String get move_wushu_palm => '金龍掌';

  @override
  String get hero_mongol => 'モンゴル戦士';

  @override
  String get hero_mongol_desc => '残忍な適応';

  @override
  String get hero_mongol_lore => 'チンギス・ハーンの後継者。';

  @override
  String get move_mongol_fist => '草原の拳';

  @override
  String get move_mongol_kick => '騎手蹴り';

  @override
  String get move_mongol_grapple => 'モンゴル投げ縄';

  @override
  String get move_mongol_block => '遊牧の構え';

  @override
  String get move_mongol_palm => '大汗の掌';
}
