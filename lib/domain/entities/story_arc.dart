// lib/domain/entities/story_arc.dart

import 'battle_state.dart' show BotDifficulty, GameMode;

enum StageType { dialogue, battle }

/// Tipo de globo de diálogo (formato cómic).
enum BubbleType { speech, shout, thought, whisper }

BubbleType _parseBubble(String? s) => switch (s) {
  'shout'   => BubbleType.shout,
  'thought' => BubbleType.thought,
  'whisper' => BubbleType.whisper,
  _         => BubbleType.speech,
};

class DialogueLine {
  final String speakerId;   // hero id o narrator
  final String speakerName;
  final String text;
  final bool speakerIsLeft;

  // ── Formato cómic (todos opcionales — retrocompatible con arcos remotos) ──
  /// Emoción del retrato: 'neutral'|'angry'|'determined'|'shocked'|'sad'|'smirk'
  final String? emotion;
  final BubbleType bubbleType;
  /// Onomatopeya que acompaña la línea ("¡CRACK!", "FIUUM")
  final String? sfxText;
  /// Agrupa líneas en la misma viñeta; null → cada línea es su propio panel.
  final int? panelIndex;
  /// Hook para ilustración real del panel (reemplaza el render procedural).
  final String? imagePath;

  const DialogueLine({
    required this.speakerId,
    required this.speakerName,
    required this.text,
    required this.speakerIsLeft,
    this.emotion,
    this.bubbleType = BubbleType.speech,
    this.sfxText,
    this.panelIndex,
    this.imagePath,
  });

  bool get isNarrator => speakerId == 'narrator';

  factory DialogueLine.fromMap(Map<String, dynamic> m) => DialogueLine(
    speakerId:    m['speakerId']    as String? ?? 'narrator',
    speakerName:  m['speakerName']  as String? ?? 'Narrador',
    text:         m['text']         as String? ?? '',
    speakerIsLeft: m['speakerIsLeft'] as bool? ?? true,
    emotion:      m['emotion']      as String?,
    bubbleType:   _parseBubble(m['bubbleType'] as String?),
    sfxText:      m['sfxText']      as String?,
    panelIndex:   m['panelIndex']   as int?,
    imagePath:    m['imagePath']    as String?,
  );

  Map<String, dynamic> toMap() => {
    'speakerId':    speakerId,
    'speakerName':  speakerName,
    'text':         text,
    'speakerIsLeft': speakerIsLeft,
    if (emotion != null) 'emotion': emotion,
    'bubbleType':   bubbleType.name,
    if (sfxText != null) 'sfxText': sfxText,
    if (panelIndex != null) 'panelIndex': panelIndex,
    if (imagePath != null) 'imagePath': imagePath,
  };
}

class DialogueStage {
  final int stageIndex;
  final String locationName; // nombre del lugar, ej: "La Montaña Sagrada"
  final List<DialogueLine> lines;

  // ── Formato cómic ──────────────────────────────────────────────────────
  /// Clave de paleta/fondo ('montana_sagrada', 'arena'...). Si es null se
  /// deriva un slug de [locationName].
  final String? locationId;
  /// Hook para fondo ilustrado real de la escena.
  final String? backgroundPath;
  /// 'auto' | 'single' | 'vertical2' | 'grid3'
  final String pageLayout;

  const DialogueStage({
    required this.stageIndex,
    required this.locationName,
    required this.lines,
    this.locationId,
    this.backgroundPath,
    this.pageLayout = 'auto',
  });

  /// locationId efectivo: el declarado o un slug del nombre.
  String get effectiveLocationId =>
      locationId ??
      locationName
          .toLowerCase()
          .replaceAll(RegExp(r'[áà]'), 'a')
          .replaceAll(RegExp(r'[éè]'), 'e')
          .replaceAll(RegExp(r'[íì]'), 'i')
          .replaceAll(RegExp(r'[óò]'), 'o')
          .replaceAll(RegExp(r'[úù]'), 'u')
          .replaceAll('ñ', 'n')
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_');

  factory DialogueStage.fromMap(Map<String, dynamic> m) => DialogueStage(
    stageIndex:   m['stageIndex']   as int? ?? 0,
    locationName: m['locationName'] as String? ?? '',
    lines: (m['lines'] as List<dynamic>? ?? [])
        .map((l) => DialogueLine.fromMap(l as Map<String, dynamic>))
        .toList(),
    locationId:     m['locationId']     as String?,
    backgroundPath: m['backgroundPath'] as String?,
    pageLayout:     m['pageLayout']     as String? ?? 'auto',
  );

  Map<String, dynamic> toMap() => {
    'stageIndex':   stageIndex,
    'locationName': locationName,
    'lines':        lines.map((l) => l.toMap()).toList(),
    if (locationId != null) 'locationId': locationId,
    if (backgroundPath != null) 'backgroundPath': backgroundPath,
    'pageLayout':   pageLayout,
  };
}

class BattleStage {
  final int stageIndex;
  final String botHeroId;
  final BotDifficulty difficulty;
  final GameMode gameMode;
  final String briefingText; // texto antes del combate

  // ── Formato cómic ──────────────────────────────────────────────────────
  /// Nombre narrativo del rival ("El Arquitecto", "Promotor Vespa").
  /// Si es null, se muestra el nombre del héroe-bot.
  final String? bossName;
  /// Onomatopeya del splash de batalla (default '¡VS!').
  final String vsSfxText;
  final String? locationId;

  const BattleStage({
    required this.stageIndex,
    required this.botHeroId,
    required this.difficulty,
    this.gameMode = GameMode.expert,
    required this.briefingText,
    this.bossName,
    this.vsSfxText = '¡VS!',
    this.locationId,
  });

  factory BattleStage.fromMap(Map<String, dynamic> m) => BattleStage(
    stageIndex:   m['stageIndex']  as int? ?? 0,
    botHeroId:    m['botHeroId']   as String? ?? 'puo_liu',
    difficulty:   _parseDifficulty(m['difficulty'] as String? ?? 'easy'),
    gameMode:     _parseGameMode(m['gameMode']   as String? ?? 'expert'),
    briefingText: m['briefingText'] as String? ?? '',
    bossName:     m['bossName']    as String?,
    vsSfxText:    m['vsSfxText']   as String? ?? '¡VS!',
    locationId:   m['locationId']  as String?,
  );

  Map<String, dynamic> toMap() => {
    'stageIndex':    stageIndex,
    'botHeroId':     botHeroId,
    'difficulty':    difficulty.name,
    'gameMode':      gameMode.name,
    'briefingText':  briefingText,
    if (bossName != null) 'bossName': bossName,
    'vsSfxText':     vsSfxText,
    if (locationId != null) 'locationId': locationId,
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

  // ── Formato cómic ──────────────────────────────────────────────────────
  /// Número de acto de la saga (1..4). Si es null se deriva de la rareza.
  final int? _actNumber;
  /// Subtítulo de portada ("Acto II — Las Cenizas del Consejo").
  final String? coverSubtitle;
  /// Hook para arte de portada real.
  final String? coverImagePath;
  /// Sinopsis/contratapa — se usa en "Anteriormente..." y como teaser.
  final String? synopsis;

  const StoryArc({
    required this.heroId,
    required this.rarity,
    required this.title,
    required this.stages,
    int? actNumber,
    this.coverSubtitle,
    this.coverImagePath,
    this.synopsis,
  }) : _actNumber = actNumber;

  String get arcId => '${heroId}_$rarity';

  /// Acto de la saga: declarado, o derivado de la rareza.
  int get actNumber =>
      _actNumber ??
      switch (rarity) {
        'rare'      => 2,
        'epic'      => 3,
        'legendary' => 4,
        _           => 1,
      };

  factory StoryArc.fromMap(String id, Map<String, dynamic> m) {
    final parts = id.split('_');
    return StoryArc(
      heroId: m['heroId'] as String? ?? parts.first,
      rarity: m['rarity'] as String? ?? (parts.length > 1 ? parts.last : 'common'),
      title:  m['title']  as String? ?? '',
      stages: (m['stages'] as List<dynamic>? ?? [])
          .map((s) => StoryStage.fromMap(s as Map<String, dynamic>))
          .toList(),
      actNumber:      m['actNumber']      as int?,
      coverSubtitle:  m['coverSubtitle']  as String?,
      coverImagePath: m['coverImagePath'] as String?,
      synopsis:       m['synopsis']       as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'heroId': heroId,
    'rarity': rarity,
    'title':  title,
    'stages': stages.map((s) => s.toMap()).toList(),
    if (_actNumber != null) 'actNumber': _actNumber,
    if (coverSubtitle != null) 'coverSubtitle': coverSubtitle,
    if (coverImagePath != null) 'coverImagePath': coverImagePath,
    if (synopsis != null) 'synopsis': synopsis,
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
