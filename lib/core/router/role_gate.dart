import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    // Watch user role and user model
    final userRoleAsync = ref.watch(userRoleProvider);
    final userModelAsync = ref.watch(userModelProvider);

    // Handle loading state
    if (userRoleAsync.isLoading || userModelAsync.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Handle error state
    if (userRoleAsync.hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error al cargar el perfil de usuario'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.landing),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      );
    }

    // Get user role and model
    final userRole = userRoleAsync.value ?? UserRole.cliente;
    final userModel = userModelAsync.value;
    final isOnboardingComplete = userModel?.onboardingCompleto ?? false;

    // ========== MODE 1: Auth Gate (no child) ==========
    // Automatically redirect based on role and onboarding status
    if (child == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (userRole.hasTrainerPermissions) {
          // Trainers and admins go directly to their clients page
          context.go(AppRoutes.trainerClients);
        } else {
          // Clients check onboarding status
          if (isOnboardingComplete) {
            context.go(AppRoutes.clientHome);
          } else {
            context.go(AppRoutes.clientOnboarding);
          }
        }
      });

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
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

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
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

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // All checks passed, display the child
    return child!;
  }
}
