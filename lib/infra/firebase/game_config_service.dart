// lib/infra/firebase/game_config_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class GameConfigService {
  final FirebaseFirestore _db;

  GameConfigService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Cartas con isEnabled == true desde Firestore.
  Future<List<Map<String, dynamic>>> fetchEnabledCards() async {
    final snap = await _db
        .collection('gameData')
        .doc('cards')
        .collection('items')
        .where('isEnabled', isEqualTo: true)
        .get();
    return snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
  }

  /// Todos los héroes desde Firestore.
  Future<List<Map<String, dynamic>>> fetchHeroes() async {
    final snap = await _db
        .collection('gameData')
        .doc('heroes')
        .collection('items')
        .get();
    return snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
  }

  /// Documento de configuración global (recompensas, puntos, etc.).
  Future<Map<String, dynamic>> fetchSettings() async {
    final doc = await _db.collection('gameConfig').doc('settings').get();
    return doc.exists ? doc.data() ?? {} : {};
  }
}
