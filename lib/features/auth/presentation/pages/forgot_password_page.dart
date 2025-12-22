import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/router/app_router.dart';

/// Forgot Password Page - Mexican Bulking Theme (Negro/Amarillo)
/// Informa que usamos Google Sign-In
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Fondo con gradiente
          _buildBackground(),

          // Contenido
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono
                    _buildIcon(),

                    const SizedBox(height: 32),

                    // Card informativa
                    _buildInfoCard(context),

                    const SizedBox(height: 24),

                    // Botón volver
                    _buildBackButton(context),
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
          center: Alignment.center,
          radius: 1.5,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.backgroundDark,
            const Color(0xFF0A0A0A),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 10,
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
              color: AppColors.info.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 50,
              color: AppColors.info,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
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
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Olvidaste tu contraseña?',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingM),

                Text(
                  '¡No te preocupes!',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Info de Google
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.g_mobiledata,
                        color: AppColors.info,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Usamos Google Sign-In',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tu cuenta está vinculada a tu cuenta de Google. No necesitas recordar ninguna contraseña adicional.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Instrucciones
                _buildInstructionItem(
                  icon: Icons.check_circle,
                  text: 'Simplemente inicia sesión con Google',
                ),
                _buildInstructionItem(
                  icon: Icons.security,
                  text: 'Tu cuenta Google maneja la seguridad',
                ),
                _buildInstructionItem(
                  icon: Icons.support,
                  text: 'Si tienes problemas, contacta a Google',
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Botón ir a login
                SizedBox(
                  width: double.infinity,
                  height: AppConstants.buttonHeightL,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Ir a Iniciar Sesión',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.backgroundDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
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
}
