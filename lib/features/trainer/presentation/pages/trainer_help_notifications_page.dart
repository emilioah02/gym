import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import 'routine_builder_page.dart';

/// Página de notificaciones de ayuda para el entrenador
/// Muestra solicitudes de ayuda de clientes durante ejercicios
class TrainerHelpNotificationsPage extends ConsumerWidget {
  const TrainerHelpNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(trainerNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                sliver: notificationsAsync.when(
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return SliverFillRemaining(
                        child: _buildEmptyState(),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
                            child: _NotificationCard(
                              notification: notifications[index],
                            ),
                          );
                        },
                        childCount: notifications.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: SelectableText.rich(
                        'Error: $error' as TextSpan,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            AppColors.warning.withValues(alpha: 0.15),
            AppColors.backgroundDark,
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.9),
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            icon: const Icon(Icons.campaign, color: AppColors.primary),
            tooltip: 'Enviar Anuncio',
            onPressed: () {
              context.push('/trainer/send-announcement');
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingL,
            60,
            AppConstants.spacingL,
            AppConstants.spacingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingS),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: AppColors.warning,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Text(
                    'Notificaciones',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w700,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingXL),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 64,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              'Sin notificaciones',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Las notificaciones aparecerán aquí',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final Map<String, dynamic> notification;

  const _NotificationCard({
    required this.notification,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipo = notification['tipo'] as String? ?? 'ayuda';
    final clienteNombre = notification['clienteNombre'] as String? ?? 'Cliente';
    final clienteId = notification['clienteId'] as String?;
    final notificationId = notification['id'] as String?;
    final parteDelCuerpo = notification['parteDelCuerpo'] as String?;
    final ejercicioNombre = notification['ejercicioNombre'] as String?;
    final isRoutineRequest = tipo == 'rutina';
    final isOrderNotification = tipo == 'nuevo_pedido';
    final total = notification['total'];
    final leido = notification['leido'] as bool? ?? false;

    return Dismissible(
      key: Key(notificationId ?? UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.spacingL),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: Text(
              'Eliminar notificación',
              style: TextStyle(color: AppColors.textPrimaryDark),
            ),
            content: Text(
              '¿Estás seguro de eliminar esta notificación?',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondaryDark)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        if (notificationId != null) {
          ref.read(firebaseServiceProvider).deleteNotification(notificationId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notificación eliminada'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: GlassCard(
        onTap: () => _handleTap(context, ref, tipo, notificationId, clienteId, parteDelCuerpo),
        child: Row(
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isOrderNotification
                    ? AppColors.success.withValues(alpha: 0.2)
                    : isRoutineRequest
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Icon(
                isOrderNotification
                    ? Icons.shopping_cart
                    : isRoutineRequest
                        ? Icons.assignment
                        : Icons.help_outline,
                color: isOrderNotification
                    ? AppColors.success
                    : isRoutineRequest
                        ? AppColors.primary
                        : AppColors.warning,
                size: 22,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOrderNotification
                        ? 'Nuevo Pedido'
                        : isRoutineRequest
                            ? 'Solicitud de Rutina'
                            : 'Solicitud de Ayuda',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    clienteNombre,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  if (isOrderNotification && total != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${(total is num ? total.toStringAsFixed(2) : total.toString())} MXN',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isRoutineRequest && parteDelCuerpo != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getBodyPartName(parteDelCuerpo),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!isRoutineRequest && !isOrderNotification && ejercicioNombre != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      ejercicioNombre,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Badge nuevo
            if (!leido)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  border: Border.all(color: AppColors.error),
                ),
                child: Text(
                  'NUEVO',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            // Flecha
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondaryDark,
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(
    BuildContext context,
    WidgetRef ref,
    String tipo,
    String? notificationId,
    String? clienteId,
    String? parteDelCuerpo,
  ) {
    // Marcar como leída
    if (notificationId != null) {
      ref.read(firebaseServiceProvider).markNotificationAsRead(notificationId);
    }

    if (tipo == 'rutina') {
      // Navegar al constructor de rutinas con la parte del cuerpo preseleccionada
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoutineBuilderPage(
            mode: RoutineBuilderMode.byBodyPart,
          ),
        ),
      );
    } else if (tipo == 'nuevo_pedido') {
      // Navegar a la página de pedidos
      context.go('/trainer/requests');
    } else {
      // Para solicitudes de ayuda, ver perfil del cliente
      if (clienteId != null) {
        context.push('/trainer/client-profile/$clienteId');
      }
    }
  }

  String _getBodyPartName(String value) {
    switch (value) {
      case 'pierna':
        return 'Pierna';
      case 'pecho':
        return 'Pecho';
      case 'espalda':
        return 'Espalda';
      case 'hombro':
        return 'Hombro';
      case 'brazo':
        return 'Brazo';
      case 'fullBody':
        return 'Full Body';
      case 'mixto':
        return 'Mixto';
      case 'trenSuperior':
        return 'Tren Superior';
      case 'trenInferior':
        return 'Tren Inferior';
      default:
        return value;
    }
  }
}
