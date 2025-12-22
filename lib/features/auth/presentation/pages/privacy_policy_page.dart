import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';

/// Privacy Policy Page - Required by Google Play Store
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Política de Privacidad',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última actualización: Diciembre 2025',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryDark,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            _buildSection(
              title: '1. Información que Recopilamos',
              content: 'Mexican Bulking recopila la siguiente información cuando utilizas nuestra aplicación:\n\n'
                  '• Información de cuenta de Google (nombre, correo electrónico, foto de perfil)\n'
                  '• Datos de entrenamiento y rutinas personalizadas\n'
                  '• Estadísticas de progreso y ejercicios completados\n'
                  '• Información de perfil del usuario (peso, altura, objetivos)',
            ),

            _buildSection(
              title: '2. Cómo Usamos tu Información',
              content: 'Utilizamos la información recopilada para:\n\n'
                  '• Proporcionar y mejorar nuestros servicios\n'
                  '• Personalizar tu experiencia de entrenamiento\n'
                  '• Comunicarnos contigo sobre actualizaciones y notificaciones\n'
                  '• Mantener la seguridad de tu cuenta\n'
                  '• Generar estadísticas y análisis de uso',
            ),

            _buildSection(
              title: '3. Almacenamiento de Datos',
              content: 'Tus datos se almacenan de forma segura en Firebase (Google Cloud Platform) con las siguientes medidas de seguridad:\n\n'
                  '• Encriptación en tránsito y en reposo\n'
                  '• Autenticación segura mediante Google\n'
                  '• Acceso restringido solo a usuarios autorizados\n'
                  '• Copias de seguridad regulares',
            ),

            _buildSection(
              title: '4. Compartir Información',
              content: 'No vendemos ni compartimos tu información personal con terceros, excepto:\n\n'
                  '• Con tu entrenador asignado (para rutinas personalizadas)\n'
                  '• Cuando sea requerido por ley\n'
                  '• Para proteger los derechos y seguridad de Mexican Bulking y sus usuarios',
            ),

            _buildSection(
              title: '5. Tus Derechos',
              content: 'Como usuario, tienes derecho a:\n\n'
                  '• Acceder a tus datos personales\n'
                  '• Solicitar la corrección de datos incorrectos\n'
                  '• Solicitar la eliminación de tu cuenta y datos\n'
                  '• Exportar tus datos\n'
                  '• Retirar tu consentimiento en cualquier momento',
            ),

            _buildSection(
              title: '6. Cookies y Tecnologías Similares',
              content: 'Utilizamos tecnologías como tokens de autenticación y almacenamiento local para:\n\n'
                  '• Mantener tu sesión activa\n'
                  '• Recordar tus preferencias\n'
                  '• Mejorar el rendimiento de la aplicación',
            ),

            _buildSection(
              title: '7. Seguridad de Menores',
              content: 'Nuestra aplicación está diseñada para usuarios mayores de 13 años. No recopilamos intencionalmente información de menores de 13 años sin el consentimiento de los padres.',
            ),

            _buildSection(
              title: '8. Cambios a esta Política',
              content: 'Podemos actualizar esta política de privacidad periódicamente. Te notificaremos sobre cambios significativos mediante un aviso en la aplicación o por correo electrónico.',
            ),

            _buildSection(
              title: '9. Contacto',
              content: 'Si tienes preguntas sobre esta política de privacidad, contáctanos:\n\n'
                  'Mexican Bulking Gym\n'
                  'Calz. Aragón 14, Lindavista\n'
                  '07300 Ciudad de México, CDMX\n\n'
                  'Instagram: @mexicanbulking\n'
                  'Facebook: Mexican Bulking',
            ),

            const SizedBox(height: AppConstants.spacingXXL),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Al usar Mexican Bulking, aceptas esta Política de Privacidad y nuestros Términos y Condiciones.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            content,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
