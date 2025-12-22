import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

/// Signup Page with Google Sign-In - Mexican Bulking Theme (Negro/Amarillo)
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
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

    // Listen for successful signup - redirect is handled by router
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
                    // Logo
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
                    ),

                    const SizedBox(height: 8),

                    Text(
                      AppConstants.appTaglineSecondary,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryDark,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Card de signup con glassmorfismo
                    _buildSignupCard(authState),

                    const SizedBox(height: 24),

                    // Ya tienes cuenta
                    _buildLoginLink(),
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
          center: Alignment.bottomCenter,
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
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
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
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 50,
            spreadRadius: 15,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 100,
            height: 100,
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
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_add,
              size: 50,
              color: AppColors.backgroundDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupCard(AuthState authState) {
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
                  'Únete al Equipo',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Crea tu cuenta y comienza\ntu transformación',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Beneficios
                _buildBenefitsList(),

                const SizedBox(height: AppConstants.spacingXL),

                // Google Sign-Up Button
                _buildGoogleButton(authState),

                const SizedBox(height: AppConstants.spacingL),

                // Términos
                Text(
                  'Al registrarte, aceptas nuestros términos de servicio y política de privacidad.',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = [
      {'icon': Icons.fitness_center, 'text': 'Rutinas personalizadas'},
      {'icon': Icons.trending_up, 'text': 'Seguimiento de progreso'},
      {'icon': Icons.calendar_today, 'text': 'Planificación semanal'},
      {'icon': Icons.emoji_events, 'text': 'Logros y rachas'},
    ];

    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                benefit['text'] as String,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
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
                splashColor: Colors.white.withValues(alpha: 0.2),
                child: Center(
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.backgroundDark,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Image.network(
                                'https://www.google.com/favicon.ico',
                                width: 20,
                                height: 20,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.g_mobiledata,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingM),
                            Text(
                              'Registrarse con Google',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.backgroundDark,
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: Text(
            'Inicia sesión',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFloatingElements(Size size) {
    return [
      // Orbes decorativos
      Positioned(
        top: -80,
        left: -80,
        child: _buildGlowingOrb(
          size: 250,
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),

      Positioned(
        bottom: -60,
        right: -60,
        child: _buildGlowingOrb(
          size: 200,
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),

      // Iconos flotantes
      _FloatingIcon(
        right: size.width * 0.1,
        top: size.height * 0.12,
        icon: Icons.star,
        color: AppColors.primary,
        controller: _floatingController,
      ),

      _FloatingIcon(
        left: size.width * 0.08,
        top: size.height * 0.22,
        icon: Icons.bolt,
        color: AppColors.primary.withValues(alpha: 0.7),
        controller: _floatingController,
        delay: 0.2,
      ),

      _FloatingIcon(
        right: size.width * 0.15,
        bottom: size.height * 0.18,
        icon: Icons.local_fire_department,
        color: AppColors.primary.withValues(alpha: 0.6),
        controller: _floatingController,
        delay: 0.5,
      ),

      _FloatingIcon(
        left: size.width * 0.12,
        bottom: size.height * 0.25,
        icon: Icons.emoji_events,
        color: AppColors.primary.withValues(alpha: 0.5),
        controller: _floatingController,
        delay: 0.7,
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
          final offset = (value - 0.5) * 25;

          return Transform.translate(
            offset: Offset(0, offset),
            child: Opacity(
              opacity: 0.35,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: color.withValues(alpha: 0.7),
                      size: 26,
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
