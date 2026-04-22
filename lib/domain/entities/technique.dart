/// Técnicas de combate y reglas RPSLS

enum Technique { fist, kick, grapple, block, palm }

class TechniqueData {
  final Technique id;
  final String nameKey; // l10n key
  final String icon;
  final int colorHex;
  final List<Technique> beats;

  const TechniqueData({
    required this.id,
    required this.nameKey,
    required this.icon,
    required this.colorHex,
    required this.beats,
  });

  List<Technique> get losesTo {
    return TechniqueRegistry.all
        .where((t) => t.beats.contains(id))
        .map((t) => t.id)
        .toList();
  }
}

/// Registro central de técnicas — cambiar beats acá cambia toda la lógica
class TechniqueRegistry {
  static const List<TechniqueData> all = [
    TechniqueData(
      id: Technique.fist,
      nameKey: 'tech_fist',
      icon: '👊',
      colorHex: 0xFFC62828,
      beats: [Technique.kick, Technique.grapple],
    ),
    TechniqueData(
      id: Technique.kick,
      nameKey: 'tech_kick',
      icon: '🦶',
      colorHex: 0xFFE65100,
      beats: [Technique.grapple, Technique.block],
    ),
    TechniqueData(
      id: Technique.grapple,
      nameKey: 'tech_grapple',
      icon: '🤼',
      colorHex: 0xFF2E7D32,
      beats: [Technique.block, Technique.palm],
    ),
    TechniqueData(
      id: Technique.block,
      nameKey: 'tech_block',
      icon: '🛡️',
      colorHex: 0xFF1565C0,
      beats: [Technique.palm, Technique.fist],
    ),
    TechniqueData(
      id: Technique.palm,
      nameKey: 'tech_palm',
      icon: '🖐️',
      colorHex: 0xFF6A1B9A,
      beats: [Technique.fist, Technique.kick],
    ),
  ];

  static TechniqueData get(Technique t) => all.firstWhere((x) => x.id == t);

  /// Frases de victoria: "atacante > defensor"
  static const Map<String, String> beatVerbKeys = {
    'fist>kick': 'verb_fist_kick',
    'fist>grapple': 'verb_fist_grapple',
    'kick>grapple': 'verb_kick_grapple',
    'kick>block': 'verb_kick_block',
    'grapple>block': 'verb_grapple_block',
    'grapple>palm': 'verb_grapple_palm',
    'block>palm': 'verb_block_palm',
    'block>fist': 'verb_block_fist',
    'palm>fist': 'verb_palm_fist',
    'palm>kick': 'verb_palm_kick',
  };
}

enum CombatResult { attackerWins, defenderWins, draw }

CombatResult resolveTechniques(Technique attacker, Technique defender) {
  if (attacker == defender) return CombatResult.draw;
  final atkData = TechniqueRegistry.get(attacker);
  return atkData.beats.contains(defender)
      ? CombatResult.attackerWins
      : CombatResult.defenderWins;
}
