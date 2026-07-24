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

  /// Catálogo de la tienda premium: docs premium_shop/{bundles|token_packs|
  /// hero_offers}, cada uno con un campo `items` (array de maps).
  /// Retorna mapas vacíos si los docs no existen (el caller usa el fallback
  /// local hardcodeado).
  Future<Map<String, List<Map<String, dynamic>>>> fetchPremiumShop() async {
    Future<List<Map<String, dynamic>>> items(String docId) async {
      final doc = await _db.collection('premium_shop').doc(docId).get();
      final raw = doc.data()?['items'] as List<dynamic>? ?? const [];
      return raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    final results = await Future.wait([
      items('bundles'),
      items('token_packs'),
      items('hero_offers'),
    ]);
    return {
      'bundles': results[0],
      'tokenPacks': results[1],
      'heroOffers': results[2],
    };
  }
}
