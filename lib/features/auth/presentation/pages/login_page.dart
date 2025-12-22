import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

/// Login Page with Google Sign-In - Mexican Bulking Theme (Negro/Amarillo)
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final size = MediaQuery.of(context).size;

    // Listen for auth state changes
    ref.listen<AuthState>(authNotifierProvider, (_, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    // Listen for successful login - redirect is handled by router
    ref.listen(authStateProvider, (_, state) {
      state.whenData((user) {
        if (user != null) {
          // Forzar re-evaluación del router para que detecte el nuevo estado
          context.go(AppRoutes.landing);
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Fondo con gradiente negro/amarillo
          _buildBackground(),

          // Elementos decorativos flotantes
          ..._buildFloatingElements(size),

          // Contenido principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo con efecto de resplandor amarillo
                    _buildLogo(),

                    const SizedBox(height: 16),

                    // Nombre de la app
                    Text(
                      AppConstants.appName.toUpperCase(),
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      AppConstants.appTagline,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryDark,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Card de login con glassmorfismo
                    _buildLoginCard(authState),

                    const SizedBox(height: 24),

                    // Botón volver
                    _buildBackButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.backgroundDark,
            const Color(0xFF0A0A0A),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              Colors.transparent,
              AppColors.primary.withValues(alpha: 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 100,
                  spreadRadius: 40,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 60,
                    color: AppColors.backgroundDark,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginCard(AuthState authState) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingXL),
            decoration: BoxDecoration(
              color: AppColors.glassDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'Bienvenido',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Inicia sesión para continuar\ntu camino fitness',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Google Sign-In Button
                _buildGoogleButton(authState),

                const SizedBox(height: AppConstants.spacingL),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.glassBorder,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingM,
                      ),
                      child: Text(
                        'Acceso seguro',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.glassBorder,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Info
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Usamos Google para mantener tu cuenta segura',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(AuthState authState) {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeightL,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: authState.isLoading
                    ? null
                    : () async {
                        final success = await ref
                            .read(authNotifierProvider.notifier)
                            .signInWithGoogle();
                        if (success && mounted) {
                          context.go('/auth-gate');
                        }
                      },
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                splashColor: AppColors.primary.withValues(alpha: 0.1),
                child: Center(
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.google.com/favicon.ico',
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.g_mobiledata,
                                color: Colors.red,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingM),
                            Text(
                              'Continuar con Google',
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: () => context.go(AppRoutes.landing),
      icon: const Icon(
        Icons.arrow_back,
        size: 18,
        color: AppColors.textSecondaryDark,
      ),
      label: Text(
        'Volver al Inicio',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
    );
  }

  List<Widget> _buildFloatingElements(Size size) {
    return [
      // Elemento decorativo superior derecho
      Positioned(
        top: -50,
        right: -50,
        child: _buildGlowingOrb(
          size: 200,
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),

      // Elemento decorativo inferior izquierdo
      Positioned(
        bottom: -80,
        left: -80,
        child: _buildGlowingOrb(
          size: 250,
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),

      // Pesas flotantes
      _FloatingIcon(
        left: size.width * 0.1,
        top: size.height * 0.15,
        icon: Icons.fitness_center,
        color: AppColors.primary,
        controller: _floatingController,
      ),

      _FloatingIcon(
        right: size.width * 0.1,
        top: size.height * 0.25,
        icon: Icons.sports_gymnastics,
        color: AppColors.primary.withValues(alpha: 0.7),
        controller: _floatingController,
        delay: 0.3,
      ),

      _FloatingIcon(
        left: size.width * 0.15,
        bottom: size.height * 0.2,
        icon: Icons.timer,
        color: AppColors.primary.withValues(alpha: 0.6),
        controller: _floatingController,
        delay: 0.6,
      ),

      _FloatingIcon(
        right: size.width * 0.12,
        bottom: size.height * 0.3,
        icon: Icons.favorite,
        color: AppColors.primary.withValues(alpha: 0.5),
        controller: _floatingController,
        delay: 0.4,
      ),
    ];
  }

  Widget _buildGlowingOrb({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final IconData icon;
  final Color color;
  final AnimationController controller;
  final double delay;

  const _FloatingIcon({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.icon,
    required this.color,
    required this.controller,
    this.delay = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final value = ((controller.value + delay) % 1.0);
          final offset = (value - 0.5) * 30;

          return Transform.translate(
            offset: Offset(0, offset),
            child: Opacity(
              opacity: 0.3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: color.withValues(alpha: 0.6),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
