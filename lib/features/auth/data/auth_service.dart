import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication service handling Google Sign-In with Firebase
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Para web: forzar siempre el selector de cuentas de Google
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        // IMPORTANTE: Forzar que Google muestre el selector de cuentas
        // Esto previene el auto-login con la cuenta anterior
        googleProvider.setCustomParameters({
          'prompt': 'select_account',
        });
        return await _auth.signInWithPopup(googleProvider);
      }

      // Mobile flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } on FirebaseException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed');
    } catch (e) {
      throw AuthException('Error al iniciar sesión con Google. Por favor intenta de nuevo.');
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'popup-closed-by-user':
        return 'Inicio de sesión cancelado';
      case 'popup-blocked':
        return 'El popup fue bloqueado. Permite popups para este sitio.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este email';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      case 'operation-not-allowed':
        return 'Google Sign-In no está habilitado en Firebase';
      case 'unauthorized-domain':
        return 'Este dominio no está autorizado en Firebase';
      default:
        return 'Error de autenticación: $code';
    }
  }

  /// Sign out - Cierra sesión completamente de Firebase y Google
  Future<void> signOut() async {
    try {
      if (kIsWeb) {
        // En web: solo cerrar sesión de Firebase
        // El prompt: 'select_account' en signIn se encargará de pedir
        // selección de cuenta la próxima vez
        await _auth.signOut();
      } else {
        // En móvil: cerrar sesión de Firebase Y desconectar Google
        // disconnect() revoca el acceso y fuerza selección de cuenta
        await _auth.signOut();
        try {
          await _googleSignIn.disconnect();
        } catch (e) {
          // Si disconnect falla, intentar signOut de Google
          await _googleSignIn.signOut();
        }
      }
    } catch (e) {
      // Fallback: al menos cerrar Firebase
      await _auth.signOut();
    }
  }
}

/// Custom exception for auth errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
