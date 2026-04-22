// lib/domain/entities/game_card.dart

enum CardCategory { punch, kick, grapple, defense, dodge }

enum CardRarity { neutral, common, rare, epic, legendary }

class GameCard {
  final String id;
  final String name;
  final String lore;
  final CardCategory category;
  final CardRarity rarity;
  final int staminaCost;
  final int? baseDamage;      // null para Defensa (bloqueo binario)
  final int? staminaBonus;    // para Esquive: cuánta stamina recupera
  final bool requiresDice;
  final String? heroId;        // null = carta neutral
  final String? factionId;     // null = neutral

  const GameCard({
    required this.id,
    required this.name,
    required this.lore,
    required this.category,
    required this.rarity,
    required this.staminaCost,
    this.baseDamage,
    this.staminaBonus,
    this.requiresDice = false,
    this.heroId,
    this.factionId,
  });

  bool get isNeutral => heroId == null && factionId == null;
  bool get isDefense => category == CardCategory.defense;
  bool get isDodge => category == CardCategory.dodge;

  @override
  String toString() => 'GameCard($name, ${category.name}, ${staminaCost}st)';
}
