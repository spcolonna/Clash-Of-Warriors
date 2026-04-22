/// ═══════════════════════════════════════════════════════════
/// FIREBASE CONFIG — Datos del proyecto
/// Extraído de GoogleService-Info.plist
/// ═══════════════════════════════════════════════════════════

class FirebaseConfig {
  static const String projectId = 'clashofwarriors-309ed';
  static const String bundleId = 'com.clashofwarriors';
  static const String storageBucket = 'clashofwarriors-309ed.firebasestorage.app';
  static const String googleAppId = '1:289945463663:ios:40ca2a0544259c41f6d69a';
  static const String gcmSenderId = '289945463663';
  static const String apiKey = 'AIzaSyDi9ns4j0BirWkTis3xubrhrF-4lHPRqnY';
  static const String clientId = '289945463663-vh5fjuge5ne1qanfbuv2o4a58bnd8adj.apps.googleusercontent.com';
  static const String reversedClientId = 'com.googleusercontent.apps.289945463663-vh5fjuge5ne1qanfbuv2o4a58bnd8adj';

  // ── Firestore Collections ──
  static const String usersCollection = 'users';
  static const String matchesCollection = 'matches';
  static const String leaderboardCollection = 'leaderboard';
  static const String purchasesCollection = 'purchases';
}
