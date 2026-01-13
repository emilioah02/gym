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

  // Lista de emails de administradores absolutos (misma que en firestore.rules)
  static const List<String> _absoluteAdminEmails = [
    'emilioah02@gmail.com',
    'diegopeniche.galindo25@gmail.com',
  ];

  /// Verifica si un email es de admin absoluto
  bool _isAbsoluteAdmin(String email) {
    return _absoluteAdminEmails.contains(email.toLowerCase());
  }

  Future<bool> signInWithGoogle() async {
    print('🔐 [AUTH] signInWithGoogle() - INICIANDO');
    state = state.copyWith(isLoading: true, error: null);

    // IMPORTANTE: Resetear el activeUserIdProvider para asegurar estado limpio
    // Esto previene que un usuario anterior en "modo prueba" afecte al nuevo usuario
    _ref.read(activeUserIdProvider.notifier).state = null;
    print('🔐 [AUTH] activeUserIdProvider reseteado a null');

    try {
      final result = await _authService.signInWithGoogle();
      print('🔐 [AUTH] Auth result: ${result?.user?.email}');

      if (result != null && result.user != null) {
        final firebaseUser = result.user!;
        final email = firebaseUser.email ?? '';
        final uid = firebaseUser.uid;

        print('🔐 [AUTH] Usuario autenticado: $uid - $email');

        final firebaseService = _ref.read(firebaseServiceProvider);

        // Verificar si el usuario ya existe en Firestore
        final existingUser = await firebaseService.getUser(uid);
        print('🔐 [AUTH] Usuario existe en Firestore: ${existingUser != null}');

        UserRole userRole;

        if (existingUser == null) {
          // ========== USUARIO NUEVO ==========
          print('🔐 [AUTH] Creando usuario nuevo en Firestore...');

          // Determinar el rol inicial:
          // 1. Si es admin absoluto -> admin
          // 2. Si está en colección trainers -> verificar después de crear
          // 3. Default -> cliente

          if (_isAbsoluteAdmin(email)) {
            // Los admins absolutos se crean directamente como admin
            userRole = UserRole.admin;
            print('🔐 [AUTH] Email es admin absoluto -> rol: admin');
          } else {
            // Todos los demás usuarios se crean como cliente
            // (Las reglas de Firestore solo permiten crear con rol 'cliente')
            userRole = UserRole.cliente;
            print('🔐 [AUTH] Usuario normal -> rol: cliente');
          }

          final newUser = UserModel(
            uid: uid,
            email: email,
            nombre: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
            rol: userRole,
            onboardingCompleto: false,
          );

          await firebaseService.saveUser(newUser);
          print('✅ [AUTH] Usuario creado en Firestore exitosamente con rol: ${userRole.value}');

          // Si el email está en la colección 'trainers' y el usuario no es admin,
          // notificar para que un admin lo actualice manualmente
          if (!_isAbsoluteAdmin(email)) {
            final isInTrainersCollection = await firebaseService.isTrainer(email);
            if (isInTrainersCollection) {
              print('⚠️ [AUTH] Email está en colección trainers. Un admin debe actualizar el rol.');
            }
          }
        } else {
          // ========== USUARIO EXISTENTE ==========
          print('✅ [AUTH] Usuario ya existe en Firestore');
          userRole = existingUser.rol;
          print('✅ [AUTH] Rol existente: ${userRole.value}');
        }

        // *** FORZAR REFRESH DEL TOKEN DE FIREBASE ***
        // Esto asegura que Firestore tenga el token más reciente
        // y evita errores de permisos en usuarios nuevos
        try {
          await firebaseUser.getIdToken(true);
          print('🔐 [AUTH] Token de Firebase actualizado exitosamente');
        } catch (e) {
          print('⚠️ [AUTH] Error actualizando token: $e');
        }

        // *** ESTABLECER CACHÉ DE ROL INMEDIATAMENTE ***
        // Esto permite navegación instantánea sin loader
        _ref.read(cachedUserRoleProvider.notifier).state = userRole;
        print('🔐 [AUTH] Rol cacheado inmediatamente: ${userRole.value}');

        // Si el usuario ya existe, cachear también el modelo
        if (existingUser != null) {
          _ref.read(cachedUserModelProvider.notifier).state = existingUser;
          print('🔐 [AUTH] Modelo de usuario cacheado');
        }

        // *** INVALIDAR PROVIDERS PARA FORZAR RECARGA LIMPIA ***
        // Esto asegura que todos los streams se reconecten con el token actualizado
        _ref.invalidate(userModelProvider);
        _ref.invalidate(userRoleProvider);
        _ref.invalidate(routinesProvider);
        _ref.invalidate(machinesProvider);
        _ref.invalidate(activeProductsProvider);
        print('🔐 [AUTH] Providers invalidados para recarga limpia');

        // *** LIMPIEZA AUTOMÁTICA DE DATOS ANTIGUOS ***
        // Solo ejecutar para entrenadores/admins que tienen permisos de escritura
        if (userRole.hasTrainerPermissions) {
          firebaseService.cleanupOldData().catchError((error) {
            print('⚠️ [AUTH] Error en limpieza automática: $error');
          });
        }
      }

      state = state.copyWith(isLoading: false);
      return result != null;
    } on AuthException catch (e) {
      print('❌ [AUTH] Error de autenticación: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      print('❌ [AUTH] Error inesperado en signInWithGoogle: $e');
      state = state.copyWith(isLoading: false, error: 'Error al iniciar sesión');
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    // IMPORTANTE: Resetear el activeUserIdProvider antes de cerrar sesión
    // Esto limpia el estado del "modo prueba" y previene problemas con el siguiente usuario
    _ref.read(activeUserIdProvider.notifier).state = null;
    print('🔐 [AUTH] activeUserIdProvider reseteado a null (signOut)');

    // *** LIMPIAR CACHÉ DE ROL Y MODELO ***
    // Esto asegura que el próximo usuario no vea datos del usuario anterior
    _ref.read(cachedUserRoleProvider.notifier).state = null;
    _ref.read(cachedUserModelProvider.notifier).state = null;
    print('🔐 [AUTH] Caché de rol y modelo limpiado');

    // *** INVALIDAR TODOS LOS PROVIDERS DE DATOS ***
    // Esto asegura que el próximo usuario comience con estado limpio
    _ref.invalidate(userModelProvider);
    _ref.invalidate(userRoleProvider);
    _ref.invalidate(routinesProvider);
    _ref.invalidate(machinesProvider);
    _ref.invalidate(activeProductsProvider);
    _ref.invalidate(clientsProvider);
    _ref.invalidate(currentUserWeeklyRoutineProvider);
    _ref.invalidate(currentUserHistoryProvider);
    _ref.invalidate(currentUserAnnouncementsProvider);
    print('🔐 [AUTH] Providers invalidados para limpiar estado');

    await _authService.signOut();
    state = state.copyWith(isLoading: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
