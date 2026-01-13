import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/colors.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import 'app_router.dart';

/// Check if a role is allowed (admin can access trainer routes)
bool _isRoleAllowed(UserRole userRole, List<UserRole> allowedRoles) {
  // Direct match
  if (allowedRoles.contains(userRole)) return true;

  // Admin can access trainer routes
  if (userRole == UserRole.admin && allowedRoles.contains(UserRole.entrenador)) {
    return true;
  }

  return false;
}

/// RoleGate widget that handles role-based navigation and onboarding checks.
///
/// This widget is designed to be used AFTER authentication is confirmed.
/// It reads async providers safely and handles loading/error states properly.
///
/// Usage:
/// - Without child: Acts as auth-gate, redirects based on role/onboarding
/// - With child: Protects a specific route, ensures role and onboarding requirements
class RoleGate extends ConsumerWidget {
  /// Optional child widget to display after validation
  /// If null, this acts as the auth-gate and performs automatic redirection
  final Widget? child;

  /// List of allowed roles for this route (only used when child is provided)
  final List<UserRole>? allowedRoles;

  /// Whether onboarding must be completed to access this route
  final bool requireOnboardingComplete;

  const RoleGate({
    super.key,
    this.child,
    this.allowedRoles,
    this.requireOnboardingComplete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Verificar que el usuario esté autenticado
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.landing);
      });
      return const SizedBox.shrink();
    }

    // Watch user role and user model - usar valor cacheado si existe
    final userRoleAsync = ref.watch(userRoleProvider);
    final userModelAsync = ref.watch(userModelProvider);

    // IMPORTANTE: Usar el rol cacheado si está disponible para evitar loader
    final cachedRole = ref.read(cachedUserRoleProvider);
    final cachedUserModel = ref.read(cachedUserModelProvider);

    // Si tenemos rol cacheado y es entrenador/admin con child, mostrar directo SIN loader
    if (child != null && cachedRole != null && cachedRole.hasTrainerPermissions) {
      // Verificar que el rol está permitido
      if (allowedRoles == null || _isRoleAllowed(cachedRole, allowedRoles!)) {
        return child!;
      }
    }

    // Si tenemos datos cacheados de cliente con onboarding completo, mostrar directo
    if (child != null && cachedRole != null && cachedUserModel != null) {
      final isOnboardingComplete = cachedUserModel.onboardingCompleto;

      if (allowedRoles == null || _isRoleAllowed(cachedRole, allowedRoles!)) {
        if (!requireOnboardingComplete || isOnboardingComplete) {
          return child!;
        }
      }
    }

    // Handle loading state - solo mostrar loader si NO hay datos cacheados
    if ((userRoleAsync.isLoading || userModelAsync.isLoading) && cachedRole == null) {
      // Para primera carga sin caché, mostrar un contenedor transparente en lugar de loader
      // Esto evita el "flash" de la pantalla de carga
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const SizedBox.shrink(),
      );
    }

    // Handle error state - intentar refrescar o mostrar opción de reintentar
    if (userRoleAsync.hasError || userModelAsync.hasError) {
      final error = userRoleAsync.error ?? userModelAsync.error;
      debugPrint('🚨 [RoleGate] Error: $error');

      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline, size: 64, color: Colors.red),
                ),
                const SizedBox(height: 24),
                Text(
                  'Error al cargar',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No se pudo cargar tu perfil de usuario.\nPor favor, intenta de nuevo.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // Invalidar providers y refrescar
                        ref.invalidate(userRoleProvider);
                        ref.invalidate(userModelProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Cerrar sesión y volver al inicio
                        ref.read(activeUserIdProvider.notifier).state = null;
                        ref.read(cachedUserRoleProvider.notifier).state = null;
                        ref.read(cachedUserModelProvider.notifier).state = null;
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) context.go(AppRoutes.landing);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Get user role and model
    final userRole = userRoleAsync.value ?? cachedRole ?? UserRole.cliente;
    final userModel = userModelAsync.value ?? cachedUserModel;
    final isOnboardingComplete = userModel?.onboardingCompleto ?? false;

    // Actualizar caché para próximas navegaciones
    if (userRoleAsync.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(cachedUserRoleProvider.notifier).state = userRoleAsync.value;
      });
    }
    if (userModelAsync.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(cachedUserModelProvider.notifier).state = userModelAsync.value;
      });
    }

    // ========== MODE 1: Auth Gate (no child) ==========
    // Automatically redirect based on role and onboarding status
    if (child == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Si es entrenador/admin, ir directo a clientes (sin migración bloqueante)
        if (userRole.hasTrainerPermissions) {
          if (context.mounted) {
            context.go(AppRoutes.trainerClients);
          }
        } else {
          // Clients check onboarding status
          if (isOnboardingComplete) {
            context.go(AppRoutes.clientHome);
          } else {
            context.go(AppRoutes.clientOnboarding);
          }
        }
      });

      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const SizedBox.shrink(),
      );
    }

    // ========== MODE 2: Route Protection (with child) ==========
    // Validate role and onboarding requirements

    // Check if user role is allowed (admin can access trainer routes)
    if (allowedRoles != null && !_isRoleAllowed(userRole, allowedRoles!)) {
      // Role not allowed, redirect to appropriate home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (userRole.hasTrainerPermissions) {
          context.go(AppRoutes.trainerClients);
        } else {
          context.go(AppRoutes.clientHome);
        }
      });

      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const SizedBox.shrink(),
      );
    }

    // Check onboarding requirement (only for clients)
    if (requireOnboardingComplete &&
        userRole == UserRole.cliente &&
        !isOnboardingComplete) {
      // Onboarding not complete, redirect to onboarding
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.clientOnboarding);
      });

      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const SizedBox.shrink(),
      );
    }

    // All checks passed, display the child
    return child!;
  }
}
