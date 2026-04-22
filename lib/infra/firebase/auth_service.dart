/// Firebase Auth Service
/// Soporta: Email, Google, Apple, Guest (anonymous linkeable)
///
/// TODO: Implementar cuando Firebase esté configurado
/// Dependencias:
///   firebase_auth: ^5.x
///   google_sign_in: ^6.x
///   sign_in_with_apple: ^6.x

abstract class AuthService {
  Future<String?> signInAnonymous();
  Future<String?> signInEmail(String email, String password);
  Future<String?> signUpEmail(String email, String password);
  Future<String?> signInGoogle();
  Future<String?> signInApple();
  Future<void> linkAnonymousToEmail(String email, String password);
  Future<void> linkAnonymousToGoogle();
  Future<void> signOut();
  String? get currentUserId;
  bool get isAnonymous;
  Stream<String?> get authStateChanges;
}
