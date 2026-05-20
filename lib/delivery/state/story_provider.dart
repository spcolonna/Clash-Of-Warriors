// lib/delivery/state/story_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/story_arc.dart';
import '../../infra/local/story_arcs_data.dart';
import 'providers.dart';

class StorySessionState {
  final String heroId;
  final String rarity;
  final StoryArc arc;
  final int currentStageIndex;
  final int currentDialogueLine;

  const StorySessionState({
    required this.heroId,
    required this.rarity,
    required this.arc,
    required this.currentStageIndex,
    required this.currentDialogueLine,
  });

  StoryStage get currentStage => arc.stages[currentStageIndex];

  bool get isLastStage => currentStageIndex >= arc.stages.length - 1;

  StorySessionState copyWith({
    int? currentStageIndex,
    int? currentDialogueLine,
  }) =>
      StorySessionState(
        heroId: heroId,
        rarity: rarity,
        arc: arc,
        currentStageIndex: currentStageIndex ?? this.currentStageIndex,
        currentDialogueLine: currentDialogueLine ?? this.currentDialogueLine,
      );
}

class StorySessionNotifier extends Notifier<StorySessionState?> {
  @override
  StorySessionState? build() => null;

  /// Inicia un arco desde el primer stage pendiente.
  /// Retorna false si no se encontró el arco.
  bool startArc(String heroId, String rarity) {
    final arc = StoryArcsData.findArc(heroId, rarity);
    if (arc == null) return false;

    final player = ref.read(playerProvider);
    final lastCompleted = player?.storyStageFor(heroId, rarity) ?? -1;
    // Si el arco fue completado, empezar desde el principio (rerun)
    final startIndex = player?.isArcComplete(heroId, rarity) == true
        ? 0
        : (lastCompleted + 1).clamp(0, arc.stages.length - 1);

    state = StorySessionState(
      heroId: heroId,
      rarity: rarity,
      arc: arc,
      currentStageIndex: startIndex,
      currentDialogueLine: 0,
    );
    return true;
  }

  /// Avanza una línea de diálogo. Si es la última, pasa al siguiente stage.
  void advanceLine() {
    final s = state;
    if (s == null) return;
    final stage = s.currentStage;
    if (stage.type != StageType.dialogue || stage.dialogue == null) return;

    final totalLines = stage.dialogue!.lines.length;
    if (s.currentDialogueLine < totalLines - 1) {
      state = s.copyWith(currentDialogueLine: s.currentDialogueLine + 1);
    } else {
      _completeCurrentStage();
    }
  }

  /// Llamado desde EndBattleScreen cuando el jugador ganó una batalla de historia.
  void completeBattleStage() => _completeCurrentStage();

  /// Avanza al siguiente stage y persiste el progreso.
  void _completeCurrentStage() {
    final s = state;
    if (s == null) return;

    ref.read(playerProvider.notifier)
        .updateStoryProgress(s.heroId, s.rarity, s.currentStageIndex);

    if (s.isLastStage) {
      // El stage 9 (final) se completa via completeArc en EndBattleScreen
      return;
    }

    state = s.copyWith(
      currentStageIndex: s.currentStageIndex + 1,
      currentDialogueLine: 0,
    );
  }

  void reset() => state = null;
}

final storySessionProvider =
    NotifierProvider<StorySessionNotifier, StorySessionState?>(
  StorySessionNotifier.new,
);
