// lib/domain/entities/game_card.dart

enum CardCategory { punch, kick, grapple, defense, dodge }

enum CardRarity { neutral, common, rare, epic, legendary }

/// Bonus condicional que reemplaza al dado. Se evalúa en el momento del choque.
/// Hace que el daño extra dependa de decisiones del jugador, no de la suerte.
enum ConditionalBonus {
  wonPreviousSlot,   // +50% daño si el jugador ganó el slot anterior de esta ronda
  opponentRested,    // +30% daño si el oponente dejó este slot vacío
  playerAhead,       // +50% daño si el HP del jugador supera al del rival
  lowHp,             // +40% daño si el jugador está por debajo del 40% de HP
}

class GameCard {
  final String id;
  final String name;
  final String lore;
  final CardCategory category;
  final CardRarity rarity;
  final int staminaCost;
  final int? baseDamage;      // null para Defensa (bloqueo binario)
  final int? staminaBonus;    // para Esquive: cuánta stamina recupera
  final ConditionalBonus? conditionalBonus;
  final String? heroId;        // null = carta neutral
  final String? factionId;     // null = neutral
  final String? imageFolder;   // subcarpeta dentro de assets/images/cards/
  final String? imageName;     // nombre del archivo, ej. shadow_kick.png
  final String? imageUrl;      // imagen remota (Firebase Storage) — prioridad

  const GameCard({
    required this.id,
    required this.name,
    required this.lore,
    required this.category,
    required this.rarity,
    required this.staminaCost,
    this.baseDamage,
    this.staminaBonus,
    this.conditionalBonus,
    this.heroId,
    this.factionId,
    this.imageFolder,
    this.imageName,
    this.imageUrl,
  });

  bool get isNeutral => heroId == null && factionId == null;
  bool get isDefense => category == CardCategory.defense;
  bool get isDodge => category == CardCategory.dodge;

  @override
  String toString() => 'GameCard($name, ${category.name}, ${staminaCost}st)';
}
