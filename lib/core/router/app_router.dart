import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/landing/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/routines/presentation/pages/routines_list_page.dart';
import '../../features/routines/presentation/pages/routine_detail_page.dart';

// Trainer pages
import '../../features/trainer/presentation/pages/trainer_shell.dart';
import '../../features/trainer/presentation/pages/trainer_clients_page.dart';
import '../../features/trainer/presentation/pages/trainer_routines_page.dart';
import '../../features/trainer/presentation/pages/trainer_machines_page.dart';
import '../../features/trainer/presentation/pages/trainer_profile_page.dart';
import '../../features/trainer/presentation/pages/trainer_notifications_page.dart';
import '../../features/trainer/presentation/pages/store_admin_page.dart';
import '../../features/trainer/presentation/pages/product_form_page.dart';
import '../../features/trainer/presentation/pages/send_announcement_page.dart';
import '../../features/trainer/presentation/pages/trainer_requests_page.dart';

// Client pages
import '../../features/client/presentation/pages/client_shell.dart';
import '../../features/client/presentation/pages/client_onboarding_page.dart';
import '../../features/client/presentation/pages/client_home_page.dart';
import '../../features/client/presentation/pages/client_history_page.dart';
import '../../features/client/presentation/pages/client_profile_page.dart';
import '../../features/client/presentation/pages/client_store_page.dart';
import '../../features/client/presentation/pages/client_notifications_page.dart';

import '../models/models.dart';
import 'go_router_refresh_stream.dart';
import 'role_gate.dart';

/// App Route Names - Use these constants for navigation
class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String landing = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Legacy routes (keeping for backward compatibility)
  static const String home = '/home';
  static const String routines = '/routines';
  static const String routineDetail = '/routines/:id';

  // Trainer routes
  static const String trainerHome = '/trainer';
  static const String trainerClients = '/trainer/clients';
  static const String trainerRoutines = '/trainer/routines';
  static const String trainerMachines = '/trainer/machines';
  static const String trainerProfile = '/trainer/profile';
  static const String trainerNotifications = '/trainer/notifications';
  static const String trainerStoreAdmin = '/trainer/store-admin';
  static const String trainerProductForm = '/trainer/store-admin/product/:id';
  static const String trainerSendAnnouncement = '/trainer/send-announcement';
  static const String trainerRequests = '/trainer/requests';

  // Client routes
  static const String clientOnboarding = '/client/onboarding';
  static const String clientHome = '/client/home';
  static const String clientExplore = '/client/explore';
  static const String clientHistory = '/client/history';
  static const String clientProfile = '/client/profile';
  static const String clientStore = '/client/store';
  static const String clientNotifications = '/client/notifications';
}

/// GoRouter Configuration for Mexican Bulking
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Creates the router with Riverpod ref for accessing providers
  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.landing,
      debugLogDiagnostics: true,

      // CRITICAL: refreshListenable reacts to auth state changes
      refreshListenable: GoRouterRefreshStream(
        FirebaseAuth.instance.authStateChanges(),
      ),

      // Simplified redirect - ONLY checks authentication, NOT providers
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        final isLoggedIn = user != null;
        final path = state.matchedLocation;

        // Public routes (no authentication required)
        final publicRoutes = [
          AppRoutes.landing,
          AppRoutes.login,
          AppRoutes.signup,
          AppRoutes.forgotPassword,
        ];

        // Auth-only routes (login, signup, forgot password)
        final authRoutes = [
          AppRoutes.login,
          AppRoutes.signup,
          AppRoutes.forgotPassword,
        ];

        // Legacy routes that should redirect to auth-gate
        final legacyRoutes = [
          AppRoutes.home,
          AppRoutes.routines,
        ];

        // If not logged in and trying to access protected route
        if (!isLoggedIn && !publicRoutes.contains(path)) {
          return AppRoutes.landing;
        }

        // If logged in and on landing page, auth pages, or legacy routes, redirect to auth-gate
        // The auth-gate will handle role-based routing
        if (isLoggedIn && (path == AppRoutes.landing || authRoutes.contains(path) || legacyRoutes.contains(path))) {
          return '/auth-gate';
        }

        return null;
      },

      // Custom page transitions with fade animation
      routes: [
        // ============ AUTH GATE ============
        // This route handles role-based navigation using RoleGate widget
        GoRoute(
          path: '/auth-gate',
          name: 'authGate',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RoleGate(),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // ============ AUTH ROUTES ============

        // Landing Page - Entry point
        GoRoute(
          path: AppRoutes.landing,
          name: 'landing',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LandingPage(),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Login Page
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginPage(),
            transitionsBuilder: _slideTransition,
          ),
        ),

        // Signup Page
        GoRoute(
          path: AppRoutes.signup,
          name: 'signup',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SignupPage(),
            transitionsBuilder: _slideTransition,
          ),
        ),

        // Forgot Password Page
        GoRoute(
          path: AppRoutes.forgotPassword,
          name: 'forgotPassword',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ForgotPasswordPage(),
            transitionsBuilder: _slideTransition,
          ),
        ),

        // ============ LEGACY ROUTES (keeping for backward compatibility) ============

        // Home Page - Main dashboard
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomePage(),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Routines List Page
        GoRoute(
          path: AppRoutes.routines,
          name: 'routines',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RoutinesListPage(),
            transitionsBuilder: _slideTransition,
          ),
        ),

        // Routine Detail Page
        GoRoute(
          path: AppRoutes.routineDetail,
          name: 'routineDetail',
          pageBuilder: (context, state) {
            final routineId = state.pathParameters['id'] ?? '';
            return CustomTransitionPage(
              key: state.pageKey,
              child: RoutineDetailPage(routineId: routineId),
              transitionsBuilder: _slideTransition,
            );
          },
        ),

        // ============ TRAINER ROUTES ============

        // Trainer Home (redirects to clients)
        GoRoute(
          path: AppRoutes.trainerHome,
          name: 'trainerHome',
          redirect: (_, _) => AppRoutes.trainerClients,
        ),

        // Trainer Clients - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.trainerClients,
          name: 'trainerClients',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoleGate(
              allowedRoles: const [UserRole.entrenador],
              child: TrainerShell(
                currentIndex: 0,
                child: const TrainerClientsPage(),
              ),
            ),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Trainer Routines - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.trainerRoutines,
          name: 'trainerRoutines',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoleGate(
              allowedRoles: const [UserRole.entrenador],
              child: TrainerShell(
                currentIndex: 1,
                child: const TrainerRoutinesPage(),
              ),
            ),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Trainer Machines - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.trainerMachines,
          name: 'trainerMachines',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoleGate(
              allowedRoles: const [UserRole.entrenador],
              child: TrainerShell(
                currentIndex: 2,
                child: const TrainerMachinesPage(),
              ),
            ),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Trainer Notifications - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.trainerNotifications,
          name: 'trainerNotifications',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoleGate(
              allowedRoles: const [UserRole.entrenador],
              child: const TrainerNotificationsPage(),
            ),
            transitionsBuilder: _slideTransition,
          ),
        ),

        // Trainer Profile - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.trainerProfile,
          name: 'trainerProfile',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoleGate(
              allowedRoles: const [UserRole.entrenador],
              child: TrainerShell(
                currentIndex: 4,
                child: const TrainerProfilePage(),
              ),
            ),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Trainer Store Admin - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.trainerStoreAdmin,
          name: 'trainerStoreAdmin',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RoleGate(
              allowedRoles: [UserRole.entrenador],
              child: StoreAdminPage(),
            ),
            transitionsBuilder: _slideTransition,
          ),
        ),

        // Trainer Product Form (Add/Edit) - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.trainerProductForm,
          name: 'trainerProductForm',
          pageBuilder: (context, state) {
            final productId = state.pathParameters['id'];
            return CustomTransitionPage(
              key: state.pageKey,
              child: RoleGate(
                allowedRoles: const [UserRole.entrenador],
                child: ProductFormPage(productId: productId),
              ),
              transitionsBuilder: _slideTransition,
            );
          },
        ),

        // Trainer Send Announcement - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.trainerSendAnnouncement,
          name: 'trainerSendAnnouncement',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RoleGate(
              allowedRoles: [UserRole.entrenador],
              child: SendAnnouncementPage(),
            ),
            transitionsBuilder: _slideTransition,
          ),
        ),

        // Trainer Requests (Routine & Store Orders) - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.trainerRequests,
          name: 'trainerRequests',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RoleGate(
              allowedRoles: [UserRole.entrenador],
              child: TrainerRequestsPage(),
            ),
            transitionsBuilder: _slideTransition,
          ),
        ),

        // ============ CLIENT ROUTES ============

        // Client Onboarding - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.clientOnboarding,
          name: 'clientOnboarding',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoleGate(
              allowedRoles: const [UserRole.cliente],
              child: const ClientOnboardingPage(),
            ),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Client Home - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.clientHome,
          name: 'clientHome',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoleGate(
              allowedRoles: const [UserRole.cliente],
              requireOnboardingComplete: true,
              child: ClientShell(
                currentIndex: 0,
                child: const ClientHomePage(),
              ),
            ),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Client Explore (placeholder - uses existing routines page) - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.clientExplore,
          name: 'clientExplore',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoleGate(
              allowedRoles: const [UserRole.cliente],
              requireOnboardingComplete: true,
              child: ClientShell(
                currentIndex: 1,
                child: const RoutinesListPage(),
              ),
            ),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Client History - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.clientHistory,
          name: 'clientHistory',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoleGate(
              allowedRoles: const [UserRole.cliente],
              requireOnboardingComplete: true,
              child: ClientShell(
                currentIndex: 2,
                child: const ClientHistoryPage(),
              ),
            ),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Client Profile - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.clientProfile,
          name: 'clientProfile',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoleGate(
              allowedRoles: const [UserRole.cliente],
              requireOnboardingComplete: true,
              child: ClientShell(
                currentIndex: 3,
                child: const ClientProfilePage(),
              ),
            ),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Client Store - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.clientStore,
          name: 'clientStore',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: RoleGate(
              allowedRoles: const [UserRole.cliente],
              requireOnboardingComplete: true,
              child: ClientShell(
                currentIndex: 4,
                child: const ClientStorePage(),
              ),
            ),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Client Notifications - wrapped with RoleGate
        GoRoute(
          path: AppRoutes.clientNotifications,
          name: 'clientNotifications',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RoleGate(
              allowedRoles: [UserRole.cliente],
              requireOnboardingComplete: true,
              child: ClientNotificationsPage(),
            ),
            transitionsBuilder: _slideTransition,
          ),
        ),
      ],

      // Error page handler
      errorPageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: _ErrorPage(error: state.error?.message ?? 'Page not found'),
        transitionsBuilder: _fadeTransition,
      ),
    );
  }

  // For backward compatibility - static router without ref
  static final GoRouter router = GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'legacy_root'),
    initialLocation: AppRoutes.landing,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final isGoingToProtected = state.matchedLocation == AppRoutes.home ||
          state.matchedLocation == AppRoutes.routines ||
          state.matchedLocation.startsWith('/routines/');

      if (!isLoggedIn && isGoingToProtected) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.landing,
        name: 'landing_legacy',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LandingPage(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login_legacy',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup_legacy',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignupPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword_legacy',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home_legacy',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomePage(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.routines,
        name: 'routines_legacy',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RoutinesListPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.routineDetail,
        name: 'routineDetail_legacy',
        pageBuilder: (context, state) {
          final routineId = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: RoutineDetailPage(routineId: routineId),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: _ErrorPage(error: state.error?.message ?? 'Page not found'),
      transitionsBuilder: _fadeTransition,
    ),
  );

  // Fade transition for main pages
  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
      child: child,
    );
  }

  // Slide transition for detail pages
  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurveTween(curve: Curves.easeInOut).animate(animation)),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Simple error page widget
class _ErrorPage extends StatelessWidget {
  final String error;

  const _ErrorPage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '¡Ups! Algo salió mal',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.landing),
              child: const Text('Ir al Inicio'),
            ),
          ],
        ),
      ),
    );
  }
}

