/// ═══════════════════════════════════════════════════════════
/// GAME CONFIG — Todas las variables de balance en un solo lugar
/// Cambiar cualquier valor aquí afecta todo el juego al instante.
/// En producción esto se puede migrar a Firebase Remote Config.
/// ═══════════════════════════════════════════════════════════

class GameConfig {
  // ── COMBATE ───────────────────────────────────────────
  static const int maxHP = 20;
  static const int maxHP3v3Boss = 30;
  static const int maxStatBase = 5;
  static const int maxStatPro = 10;

  // Daño en empate: si tu stat > rival stat, hacés 1 de daño
  static const int drawDamage = 1;

  // ── TOKENS / ECONOMÍA ─────────────────────────────────
  static const int tokenRewardEasy = 5;
  static const int tokenRewardNormal = 10;
  static const int tokenRewardHard = 20;
  static const int tokenRewardLoss = 2;
  static const int tokenReward3v3Multiplier = 3;
  static const int tokenRewardStoryMultiplier = 2;
  static const int tokenRewardStoryComplete = 4; // x diff reward

  static const int heroUnlockCost = 200;
  static const int cardCost = 50;

  // ── NIVELES / PROGRESIÓN ──────────────────────────────
  /// Cartas necesarias para subir de nivel N a N+1
  static const List<int> cardsNeededPerLevel = [
    0, 2, 4, 8, 12, 16, 24, 32, 40, 50, 60, 70, 80, 90
  ];

  /// Obtener cartas necesarias para subir del nivel dado
  static int cardsNeeded(int currentLevel) {
    if (currentLevel < 0) return 999;
    if (currentLevel >= cardsNeededPerLevel.length) return 999;
    return cardsNeededPerLevel[currentLevel];
  }

  /// Stat bonus por nivel: cada nivel sube todas las stats en 1
  static const int statBonusPerLevel = 1;

  // ── RAREZAS ───────────────────────────────────────────
  static const List<RarityConfig> rarities = [
    RarityConfig(name: 'Common', colorHex: 0xFF888888, minLevel: 1),
    RarityConfig(name: 'Rare', colorHex: 0xFF1565C0, minLevel: 4),
    RarityConfig(name: 'Epic', colorHex: 0xFF6A1B9A, minLevel: 7),
    RarityConfig(name: 'Legendary', colorHex: 0xFFE65100, minLevel: 10),
  ];

  static RarityConfig getRarity(int level) {
    for (int i = rarities.length - 1; i >= 0; i--) {
      if (level >= rarities[i].minLevel) return rarities[i];
    }
    return rarities[0];
  }

  // ── PUBLICIDAD ────────────────────────────────────────
  /// Cada cuántas batallas mostrar interstitial (solo free)
  static const int adInterstitialEveryNBattles = 3;

  /// Tokens por ver rewarded ad
  static const int rewardedAdTokens = 20;

  /// Mostrar banner en estas pantallas
  static const List<String> bannerScreens = [
    'home', 'heroes', 'ranking', 'diff', 'result',
  ];

  // ── TIENDA (precios reales) ───────────────────────────
  static const List<ShopPackConfig> tokenPacks = [
    ShopPackConfig(id: 'tokens_100', nameKey: 'shop_pack_handful', tokens: 100, price: 0.99, icon: '🪙'),
    ShopPackConfig(id: 'tokens_500', nameKey: 'shop_pack_bag', tokens: 500, price: 3.99, icon: '💰', isPopular: true),
    ShopPackConfig(id: 'tokens_1200', nameKey: 'shop_pack_chest', tokens: 1200, price: 7.99, icon: '🏆'),
    ShopPackConfig(id: 'tokens_3000', nameKey: 'shop_pack_treasure', tokens: 3000, price: 14.99, icon: '👑'),
  ];

  static const List<ShopPackConfig> specialPacks = [
    ShopPackConfig(id: 'pack_warrior', nameKey: 'shop_special_warrior', tokens: 300, heroes: 1, price: 4.99, icon: '⚔️'),
    ShopPackConfig(id: 'pack_legend', nameKey: 'shop_special_legend', tokens: 800, heroes: 3, price: 9.99, icon: '🔥'),
    ShopPackConfig(id: 'pack_ultimate', nameKey: 'shop_special_ultimate', tokens: 2000, heroes: 20, price: 24.99, icon: '👑'),
  ];

  // ── DAILY REWARDS ─────────────────────────────────────
  static const List<int> dailyRewardTokens = [10, 15, 20, 25, 30, 50, 100];

  // ── DIFICULTAD BOT ────────────────────────────────────
  static const double botHardReadChance = 0.6;
  static const double eloMultiplierEasy = 0.5;
  static const double eloMultiplierNormal = 1.0;
  static const double eloMultiplierHard = 1.5;
  static const int eloWinBase = 25;
  static const int eloLossBase = 15;
  static const int eloDrawBonus = 5;

  // ── MODO HISTORIA ─────────────────────────────────────
  static const int storyTotalChapters = 20;
  static const List<int> storyBossChapters = [5, 10, 15, 20];

  // ── ANIMACIÓN 3v3 ─────────────────────────────────────
  static const int animAutoAdvanceMs = 2200;

  // ── SONIDOS ───────────────────────────────────────────
  static const String sfxPath = 'assets/sounds/';
  static const Map<String, String> sfxFiles = {
    'punch': 'punch.mp3', 'kick': 'kick.mp3', 'block': 'block.mp3',
    'grapple': 'grapple.mp3', 'palm': 'palm.mp3', 'hit': 'hit.mp3',
    'ko': 'ko.mp3', 'victory': 'victory.mp3', 'defeat': 'defeat.mp3',
    'round_start': 'round_start.mp3', 'select': 'select.mp3',
    'coin': 'coin.mp3', 'level_up': 'level_up.mp3',
    'unlock': 'unlock.mp3', 'menu_tap': 'menu_tap.mp3',
  };
}

class RarityConfig {
  final String name;
  final int colorHex;
  final int minLevel;
  const RarityConfig({required this.name, required this.colorHex, required this.minLevel});
}

class ShopPackConfig {
  final String id;
  final String nameKey;
  final int tokens;
  final int heroes;
  final double price;
  final String icon;
  final bool isPopular;
  const ShopPackConfig({
    required this.id, required this.nameKey, required this.tokens,
    this.heroes = 0, required this.price, required this.icon, this.isPopular = false,
  });
}
