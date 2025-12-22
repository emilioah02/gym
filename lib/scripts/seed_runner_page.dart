import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/constants/typography.dart';
import '../core/constants/app_constants.dart';
import 'seed_routines.dart';
import 'seed_products.dart';

/// Página de utilidad para ejecutar scripts de seed
/// Solo para desarrollo/administración
class SeedRunnerPage extends StatefulWidget {
  const SeedRunnerPage({super.key});

  @override
  State<SeedRunnerPage> createState() => _SeedRunnerPageState();
}

class _SeedRunnerPageState extends State<SeedRunnerPage> {
  bool _isLoadingRoutines = false;
  bool _isLoadingProducts = false;
  String _routinesStatus = '';
  String _productsStatus = '';

  Future<void> _runRoutinesSeed() async {
    setState(() {
      _isLoadingRoutines = true;
      _routinesStatus = 'Cargando rutinas...';
    });

    try {
      await seedRoutines();
      setState(() {
        _routinesStatus = '✅ Rutinas cargadas exitosamente';
        _isLoadingRoutines = false;
      });
    } catch (e) {
      setState(() {
        _routinesStatus = '❌ Error al cargar rutinas: $e';
        _isLoadingRoutines = false;
      });
    }
  }

  Future<void> _runProductsSeed() async {
    setState(() {
      _isLoadingProducts = true;
      _productsStatus = 'Cargando productos...';
    });

    try {
      await seedProducts();
      setState(() {
        _productsStatus = '✅ Productos cargados exitosamente';
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _productsStatus = '❌ Error al cargar productos: $e';
        _isLoadingProducts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Scripts de Seed',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning card
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.warning),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 32,
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo Desarrollo',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Estos scripts son para desarrollo y administración. No usar en producción.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingL),

              // Routines Seed Card
              _buildSeedCard(
                title: 'Cargar Rutinas de Ejemplo',
                description:
                    'Carga 9 rutinas de entrenamiento predefinidas con ejercicios correctamente configurados.',
                icon: Icons.fitness_center,
                iconColor: AppColors.primary,
                isLoading: _isLoadingRoutines,
                status: _routinesStatus,
                onPressed: _runRoutinesSeed,
              ),

              const SizedBox(height: AppConstants.spacingM),

              // Products Seed Card
              _buildSeedCard(
                title: 'Cargar Productos de Ejemplo',
                description:
                    'Carga productos de ejemplo para la tienda (suplementos, ropa, accesorios).',
                icon: Icons.store,
                iconColor: AppColors.success,
                isLoading: _isLoadingProducts,
                status: _productsStatus,
                onPressed: _runProductsSeed,
              ),

              const SizedBox(height: AppConstants.spacingL),

              // Info card
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.glassDark,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: AppConstants.spacingS),
                        Text(
                          'Información',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    _buildInfoItem(
                        'Los datos se cargarán en Firebase Firestore'),
                    _buildInfoItem(
                        'Las rutinas incluyen ejercicios con nombres e imágenes correctas'),
                    _buildInfoItem(
                        'Puedes ejecutar los scripts múltiples veces (creará duplicados)'),
                    _buildInfoItem(
                        'Verifica los datos en Firebase Console después de cargar'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeedCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isLoading,
    required String status,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.glassDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                disabledBackgroundColor: AppColors.glassDark,
                padding:
                    const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Ejecutar',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          if (status.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingS),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: status.startsWith('✅')
                    ? AppColors.success.withValues(alpha: 0.1)
                    : status.startsWith('❌')
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Text(
                status,
                style: AppTypography.bodySmall.copyWith(
                  color: status.startsWith('✅')
                      ? AppColors.success
                      : status.startsWith('❌')
                          ? AppColors.error
                          : AppColors.textSecondaryDark,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
