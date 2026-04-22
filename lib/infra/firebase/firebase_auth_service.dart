import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_config.dart';

/// Firebase Auth Service — Implementación completa
/// Soporta: Email, Google, Apple, Guest (anonymous linkeable)
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: FirebaseConfig.clientId,
  );

  // ── Estado ──
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;
  bool get isLoggedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Guest (anonymous) ──
  Future<UserCredential?> signInAnonymous() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  // ── Email/Password ──
  Future<UserCredential?> signUpEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  Future<UserCredential?> signInEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ── Google ──
  Future<UserCredential?> signInGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // ── Apple ──
  Future<UserCredential?> signInApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');
      return await _auth.signInWithProvider(appleProvider);
    } catch (e) {
      print('Error signing in with Apple: $e');
      return null;
    }
  }

  // ── Link anonymous to permanent account ──
  Future<UserCredential?> linkAnonymousToEmail(
      String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      return await _auth.currentUser?.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  Future<UserCredential?> linkAnonymousToGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.currentUser?.linkWithCredential(credential);
    } catch (e) {
      print('Error linking with Google: $e');
      return null;
    }
  }

  // ── Sign Out ──
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Password Reset ──
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Error mapping ──
  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este email ya tiene una cuenta';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres)';
      case 'user-not-found':
        return 'No existe una cuenta con este email';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intentá más tarde';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
