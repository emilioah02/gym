import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';

/// Página de configuración de notificaciones para entrenadores
class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  bool _newOrderNotifications = true;
  bool _helpRequestNotifications = true;
  bool _routineRequestNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  Future<void> _initializeNotifications() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificaciones configuradas correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al configurar notificaciones: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

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
          'Configurar Notificaciones',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activar notificaciones
            _buildActivateNotificationsCard(),
            const SizedBox(height: AppConstants.spacingL),

            // Tipos de notificaciones
            _buildSectionTitle('Tipos de Notificaciones'),
            const SizedBox(height: AppConstants.spacingM),
            _buildNotificationTypeCard(
              icon: Icons.shopping_bag,
              iconColor: AppColors.success,
              title: 'Nuevos Pedidos',
              subtitle: 'Recibir alertas cuando un cliente hace un pedido',
              value: _newOrderNotifications,
              onChanged: (value) {
                setState(() => _newOrderNotifications = value);
              },
            ),
            const SizedBox(height: AppConstants.spacingS),
            _buildNotificationTypeCard(
              icon: Icons.help_outline,
              iconColor: AppColors.warning,
              title: 'Solicitudes de Ayuda',
              subtitle: 'Recibir alertas cuando un cliente pide ayuda',
              value: _helpRequestNotifications,
              onChanged: (value) {
                setState(() => _helpRequestNotifications = value);
              },
            ),
            const SizedBox(height: AppConstants.spacingS),
            _buildNotificationTypeCard(
              icon: Icons.fitness_center,
              iconColor: AppColors.info,
              title: 'Solicitudes de Rutina',
              subtitle: 'Recibir alertas cuando un cliente pide una rutina',
              value: _routineRequestNotifications,
              onChanged: (value) {
                setState(() => _routineRequestNotifications = value);
              },
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Preferencias
            _buildSectionTitle('Preferencias'),
            const SizedBox(height: AppConstants.spacingM),
            _buildPreferenceCard(
              icon: Icons.volume_up,
              title: 'Sonido',
              subtitle: 'Reproducir sonido con las notificaciones',
              value: _soundEnabled,
              onChanged: (value) {
                setState(() => _soundEnabled = value);
              },
            ),
            const SizedBox(height: AppConstants.spacingS),
            _buildPreferenceCard(
              icon: Icons.vibration,
              title: 'Vibración',
              subtitle: 'Vibrar con las notificaciones',
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() => _vibrationEnabled = value);
              },
            ),

            const SizedBox(height: AppConstants.spacingXL),

            // Información
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivateNotificationsCard() {
    return GlassCard(
      onTap: _initializeNotifications,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activar Notificaciones',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toca para solicitar permisos de notificación',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildNotificationTypeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return AppColors.textSecondaryDark;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary.withValues(alpha: 0.5);
              }
              return AppColors.glassBorder;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return AppColors.textSecondaryDark;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary.withValues(alpha: 0.5);
              }
              return AppColors.glassBorder;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: Text(
              'Las notificaciones te mantienen informado sobre la actividad de tus clientes en tiempo real. Asegúrate de tener los permisos activados en tu dispositivo.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
