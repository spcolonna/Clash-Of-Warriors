// lib/infra/local/story/story_helpers.dart
//
// Helpers de construcción de arcos narrativos (formato cómic).
// Usados solo por los archivos arcs_*.dart de este directorio.

import '../../../domain/entities/battle_state.dart' show BotDifficulty, GameMode;
import '../../../domain/entities/story_arc.dart';

DialogueLine line(
  String id,
  String name,
  String text, {
  bool left = true,
  String? emotion,
  BubbleType bubble = BubbleType.speech,
  String? sfx,
  int? panel,
}) =>
    DialogueLine(
      speakerId: id,
      speakerName: name,
      text: text,
      speakerIsLeft: left,
      emotion: emotion,
      bubbleType: bubble,
      sfxText: sfx,
      panelIndex: panel,
    );

DialogueLine narrator(String text, {int? panel}) => DialogueLine(
      speakerId: 'narrator',
      speakerName: 'Narrador',
      text: text,
      speakerIsLeft: true,
      panelIndex: panel,
    );

StoryStage dialogue(
  int index,
  String location,
  List<DialogueLine> lines, {
  String? locationId,
}) =>
    StoryStage.dialogue(
      stage: DialogueStage(
        stageIndex: index,
        locationName: location,
        lines: lines,
        locationId: locationId,
      ),
    );

StoryStage battle(
  int index,
  String botId,
  BotDifficulty diff,
  String briefing, {
  String? bossName,
  String? locationId,
  GameMode mode = GameMode.expert,
}) =>
    StoryStage.battle(
      stage: BattleStage(
        stageIndex: index,
        botHeroId: botId,
        difficulty: diff,
        gameMode: mode,
        briefingText: briefing,
        bossName: bossName,
        locationId: locationId,
      ),
    );
