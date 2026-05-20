// lib/domain/entities/story_arc.dart

import 'battle_state.dart' show BotDifficulty, GameMode;

enum StageType { dialogue, battle }

class DialogueLine {
  final String speakerId;   // hero id o narrator
  final String speakerName;
  final String text;
  final bool speakerIsLeft;

  const DialogueLine({
    required this.speakerId,
    required this.speakerName,
    required this.text,
    required this.speakerIsLeft,
  });

  factory DialogueLine.fromMap(Map<String, dynamic> m) => DialogueLine(
    speakerId:    m['speakerId']    as String? ?? 'narrator',
    speakerName:  m['speakerName']  as String? ?? 'Narrador',
    text:         m['text']         as String? ?? '',
    speakerIsLeft: m['speakerIsLeft'] as bool? ?? true,
  );

  Map<String, dynamic> toMap() => {
    'speakerId':    speakerId,
    'speakerName':  speakerName,
    'text':         text,
    'speakerIsLeft': speakerIsLeft,
  };
}

class DialogueStage {
  final int stageIndex;
  final String locationName; // nombre del lugar, ej: "La Montaña Sagrada"
  final List<DialogueLine> lines;

  const DialogueStage({
    required this.stageIndex,
    required this.locationName,
    required this.lines,
  });

  factory DialogueStage.fromMap(Map<String, dynamic> m) => DialogueStage(
    stageIndex:   m['stageIndex']   as int? ?? 0,
    locationName: m['locationName'] as String? ?? '',
    lines: (m['lines'] as List<dynamic>? ?? [])
        .map((l) => DialogueLine.fromMap(l as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    'stageIndex':   stageIndex,
    'locationName': locationName,
    'lines':        lines.map((l) => l.toMap()).toList(),
  };
}

class BattleStage {
  final int stageIndex;
  final String botHeroId;
  final BotDifficulty difficulty;
  final GameMode gameMode;
  final String briefingText; // texto antes del combate

  const BattleStage({
    required this.stageIndex,
    required this.botHeroId,
    required this.difficulty,
    this.gameMode = GameMode.expert,
    required this.briefingText,
  });

  factory BattleStage.fromMap(Map<String, dynamic> m) => BattleStage(
    stageIndex:   m['stageIndex']  as int? ?? 0,
    botHeroId:    m['botHeroId']   as String? ?? 'puo_liu',
    difficulty:   _parseDifficulty(m['difficulty'] as String? ?? 'easy'),
    gameMode:     _parseGameMode(m['gameMode']   as String? ?? 'expert'),
    briefingText: m['briefingText'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'stageIndex':    stageIndex,
    'botHeroId':     botHeroId,
    'difficulty':    difficulty.name,
    'gameMode':      gameMode.name,
    'briefingText':  briefingText,
  };

  static BotDifficulty _parseDifficulty(String s) => switch (s) {
    'normal' => BotDifficulty.normal,
    'hard'   => BotDifficulty.hard,
    _        => BotDifficulty.easy,
  };

  static GameMode _parseGameMode(String s) => switch (s) {
    'normal' => GameMode.normal,
    _        => GameMode.expert,
  };
}

class StoryStage {
  final int index;
  final StageType type;
  final DialogueStage? dialogue;
  final BattleStage? battle;

  StoryStage.dialogue({required DialogueStage stage})
      : index = stage.stageIndex,
        type = StageType.dialogue,
        dialogue = stage,
        battle = null;

  StoryStage.battle({required BattleStage stage})
      : index = stage.stageIndex,
        type = StageType.battle,
        dialogue = null,
        battle = stage;

  factory StoryStage.fromMap(Map<String, dynamic> m) {
    final typeStr = m['type'] as String? ?? 'dialogue';
    if (typeStr == 'battle') {
      return StoryStage.battle(
        stage: BattleStage.fromMap(m['battle'] as Map<String, dynamic>? ?? {}),
      );
    }
    return StoryStage.dialogue(
      stage: DialogueStage.fromMap(m['dialogue'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type.name,
    if (type == StageType.dialogue && dialogue != null) 'dialogue': dialogue!.toMap(),
    if (type == StageType.battle   && battle   != null) 'battle':   battle!.toMap(),
  };
}

class StoryArc {
  final String heroId;
  final String rarity;
  final String title;
  final List<StoryStage> stages; // exactamente 10 entries

  const StoryArc({
    required this.heroId,
    required this.rarity,
    required this.title,
    required this.stages,
  });

  String get arcId => '${heroId}_$rarity';

  factory StoryArc.fromMap(String id, Map<String, dynamic> m) {
    final parts = id.split('_');
    return StoryArc(
      heroId: m['heroId'] as String? ?? parts.first,
      rarity: m['rarity'] as String? ?? (parts.length > 1 ? parts.last : 'common'),
      title:  m['title']  as String? ?? '',
      stages: (m['stages'] as List<dynamic>? ?? [])
          .map((s) => StoryStage.fromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'heroId': heroId,
    'rarity': rarity,
    'title':  title,
    'stages': stages.map((s) => s.toMap()).toList(),
  };
}

/// Contexto de una batalla en modo historia — se pasa al BattleScreen para saber
/// que es una historia y poder volver al arco al terminar.
class StoryBattleContext {
  final String heroId;
  final String rarity;
  final int stageIndex;

  const StoryBattleContext({
    required this.heroId,
    required this.rarity,
    required this.stageIndex,
  });
}
