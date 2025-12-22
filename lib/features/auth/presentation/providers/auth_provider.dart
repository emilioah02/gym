import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_service.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';

/// Provider for AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Provider for current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// State notifier for auth operations
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider), ref);
});

/// Auth state
class AuthState {
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({bool? isLoading, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(const AuthState());

  Future<bool> signInWithGoogle() async {
    print('🔐 [DEBUG] signInWithGoogle() - INICIANDO');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.signInWithGoogle();
      print('🔐 [DEBUG] Auth result: ${result?.user?.email}');

      if (result != null && result.user != null) {
        final firebaseUser = result.user!;
        print('🔐 [DEBUG] Usuario autenticado: ${firebaseUser.uid} - ${firebaseUser.email}');

        // Verificar si el usuario ya existe en Firestore
        final firebaseService = _ref.read(firebaseServiceProvider);
        final existingUser = await firebaseService.getUser(firebaseUser.uid);

        print('🔐 [DEBUG] Usuario existe en Firestore: ${existingUser != null}');

        UserRole userRole;

        if (existingUser == null) {
          // El usuario no existe en Firestore, crearlo
          print('🔐 [DEBUG] Creando usuario en Firestore...');

          // Determinar el rol
          userRole = await firebaseService.getUserRole(firebaseUser.email!);
          print('🔐 [DEBUG] Rol del usuario: $userRole');

          final newUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email!,
            nombre: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
            rol: userRole,
            onboardingCompleto: false, // Siempre false para nuevos usuarios
          );

          await firebaseService.saveUser(newUser);
          print('✅ [DEBUG] Usuario creado en Firestore exitosamente');
        } else {
          print('✅ [DEBUG] Usuario ya existe en Firestore');
          userRole = existingUser.rol;
        }

        // *** LIMPIEZA AUTOMÁTICA DE DATOS ANTIGUOS (Cost Prevention) ***
        // Solo ejecutar para entrenadores/admins que tienen permisos de escritura
        if (userRole == UserRole.entrenador || userRole == UserRole.admin) {
          firebaseService.cleanupOldData().catchError((error) {
            // Silenciar errores de limpieza - no afecta el flujo del usuario
          });
        }
      }

      state = state.copyWith(isLoading: false);
      return result != null;
    } on AuthException catch (e) {
      print('❌ [DEBUG] Error de autenticación: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      print('❌ [DEBUG] Error inesperado en signInWithGoogle: $e');
      state = state.copyWith(isLoading: false, error: 'Error al iniciar sesión');
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _authService.signOut();
    state = state.copyWith(isLoading: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
