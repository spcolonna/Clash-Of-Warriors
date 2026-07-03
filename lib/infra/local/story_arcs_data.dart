// lib/infra/local/story_arcs_data.dart
//
// Agregador del contenido narrativo. La saga completa (4 actos × 5 héroes)
// vive en lib/infra/local/story/arcs_*.dart. Los arcos pueden reemplazarse
// desde Firestore vía el admin web (applyRemoteArcs).

import '../../domain/entities/story_arc.dart';
import 'story/arcs_kage.dart';
import 'story/arcs_kai.dart';
import 'story/arcs_mila.dart';
import 'story/arcs_puo_liu.dart';
import 'story/arcs_ryoto.dart';

class StoryArcsData {
  static final List<StoryArc> _localArcs = [
    ...puoLiuArcs,
    ...kageArcs,
    ...ryotoArcs,
    ...kaiArcs,
    ...milaArcs,
  ];

  // Cache de arcos cargados desde Firestore (sustituyen a los locales)
  static final Map<String, StoryArc> _remoteArcs = {};

  /// Reemplaza arcos locales con los recibidos desde Firestore.
  /// Llamado al startup desde GameConfigNotifier.
  static void applyRemoteArcs(List<Map<String, dynamic>> firestoreArcs) {
    for (final data in firestoreArcs) {
      final id = data['arcId'] as String? ?? '${data['heroId']}_${data['rarity']}';
      if (id.isNotEmpty) {
        _remoteArcs[id] = StoryArc.fromMap(id, data);
      }
    }
  }

  static StoryArc? findArc(String heroId, String rarity) {
    final id = '${heroId}_$rarity';
    return _remoteArcs[id] ?? _localArcs.where((a) => a.arcId == id).firstOrNull;
  }

  static List<StoryArc> get allArcs => _localArcs;
}
