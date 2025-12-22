import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';

/// Terms and Conditions Page - Required by Google Play Store
class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

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
          'Términos y Condiciones',
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
              title: '1. Aceptación de los Términos',
              content: 'Al acceder y utilizar la aplicación Mexican Bulking, aceptas estar sujeto a estos Términos y Condiciones. Si no estás de acuerdo con alguna parte de estos términos, no debes usar la aplicación.',
            ),

            _buildSection(
              title: '2. Descripción del Servicio',
              content: 'Mexican Bulking es una aplicación móvil que proporciona:\n\n'
                  '• Rutinas de entrenamiento personalizadas\n'
                  '• Guías de ejercicios y máquinas\n'
                  '• Seguimiento de progreso fitness\n'
                  '• Comunicación con entrenadores certificados\n'
                  '• Tienda de productos relacionados con fitness',
            ),

            _buildSection(
              title: '3. Registro y Cuenta de Usuario',
              content: 'Para utilizar Mexican Bulking, debes:\n\n'
                  '• Tener al menos 13 años de edad\n'
                  '• Proporcionar información precisa y actualizada\n'
                  '• Utilizar una cuenta de Google válida\n'
                  '• Mantener la seguridad de tu cuenta\n'
                  '• No compartir tus credenciales de acceso',
            ),

            _buildSection(
              title: '4. Uso Aceptable',
              content: 'Te comprometes a:\n\n'
                  '• Usar la aplicación solo para fines legales\n'
                  '• No intentar acceder de forma no autorizada a sistemas o datos\n'
                  '• No interferir con el funcionamiento normal de la aplicación\n'
                  '• No acosar, amenazar o intimidar a otros usuarios\n'
                  '• Respetar los derechos de propiedad intelectual',
            ),

            _buildSection(
              title: '5. Servicios de Entrenamiento',
              content: 'Entiendes y aceptas que:\n\n'
                  '• Las rutinas son sugerencias generales, no asesoramiento médico\n'
                  '• Debes consultar a un profesional de la salud antes de comenzar cualquier programa de ejercicios\n'
                  '• Mexican Bulking no es responsable de lesiones resultantes del uso de la aplicación\n'
                  '• Es tu responsabilidad ejercitarte de forma segura y apropiada',
            ),

            _buildSection(
              title: '6. Contenido del Usuario',
              content: 'Al compartir contenido en la aplicación:\n\n'
                  '• Conservas los derechos sobre tu contenido\n'
                  '• Nos otorgas una licencia para usar, mostrar y distribuir tu contenido dentro de la aplicación\n'
                  '• Garantizas que tienes los derechos necesarios sobre el contenido\n'
                  '• Nos autorizas a eliminar contenido inapropiado',
            ),

            _buildSection(
              title: '7. Pagos y Reembolsos',
              content: 'Para compras en la tienda:\n\n'
                  '• Los precios están sujetos a cambios sin previo aviso\n'
                  '• Los pagos se procesan de forma segura\n'
                  '• Las políticas de reembolso se aplican según el gimnasio\n'
                  '• Eres responsable de cualquier impuesto aplicable',
            ),

            _buildSection(
              title: '8. Propiedad Intelectual',
              content: 'Todo el contenido de la aplicación, incluyendo:\n\n'
                  '• Diseño, logos y marcas comerciales\n'
                  '• Textos, imágenes y videos\n'
                  '• Código fuente y software\n\n'
                  'Es propiedad de Mexican Bulking o sus licenciantes y está protegido por leyes de propiedad intelectual.',
            ),

            _buildSection(
              title: '9. Limitación de Responsabilidad',
              content: 'Mexican Bulking no será responsable de:\n\n'
                  '• Lesiones físicas o daños a la salud\n'
                  '• Pérdida de datos o interrupciones del servicio\n'
                  '• Daños indirectos, incidentales o consecuentes\n'
                  '• Contenido de terceros o enlaces externos',
            ),

            _buildSection(
              title: '10. Modificaciones del Servicio',
              content: 'Nos reservamos el derecho de:\n\n'
                  '• Modificar o discontinuar la aplicación en cualquier momento\n'
                  '• Cambiar estos términos y condiciones\n'
                  '• Suspender o terminar cuentas de usuario que violen estos términos',
            ),

            _buildSection(
              title: '11. Terminación',
              content: 'Puedes dejar de usar la aplicación en cualquier momento eliminando tu cuenta. Podemos suspender o terminar tu acceso si violas estos términos.',
            ),

            _buildSection(
              title: '12. Ley Aplicable',
              content: 'Estos términos se rigen por las leyes de los Estados Unidos Mexicanos. Cualquier disputa se resolverá en los tribunales de la Ciudad de México.',
            ),

            _buildSection(
              title: '13. Contacto',
              content: 'Para preguntas sobre estos términos, contáctanos:\n\n'
                  'Mexican Bulking Gym\n'
                  'Calz. Aragón 14, Lindavista\n'
                  '07300 Ciudad de México, CDMX\n\n'
                  'Instagram: @mexicanbulking\n'
                  'Facebook: Mexican Bulking',
            ),

            const SizedBox(height: AppConstants.spacingXXL),

            // Disclaimer de Salud
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.health_and_safety,
                    color: AppColors.error,
                    size: 32,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    'AVISO IMPORTANTE DE SALUD',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Consulta a tu médico antes de comenzar cualquier programa de ejercicios. Esta aplicación no sustituye el consejo médico profesional.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingL),

            // Aceptación
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
                'Al usar Mexican Bulking, aceptas estos Términos y Condiciones y nuestra Política de Privacidad.',
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
