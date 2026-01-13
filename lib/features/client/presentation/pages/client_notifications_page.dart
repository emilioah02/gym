import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';

/// Página de notificaciones para clientes
/// Muestra anuncios y ofertas del entrenador
class ClientNotificationsPage extends ConsumerWidget {
  const ClientNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUser = ref.watch(firebaseUserProvider).value;

    if (firebaseUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    // Usar el activeUserIdProvider para obtener el ID correcto (modo prueba o real)
    final activeUserId = ref.watch(activeUserIdProvider);
    final clientId = activeUserId ?? firebaseUser.uid;

    final announcementsAsync = ref.watch(currentUserAnnouncementsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacingM,
                  0,
                  AppConstants.spacingM,
                  AppConstants.spacingM,
                ),
                sliver: announcementsAsync.when(
                  data: (announcements) {
                    if (announcements.isEmpty) {
                      return SliverFillRemaining(
                        child: _buildEmptyState(),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                            child: _AnnouncementCard(
                              announcement: announcements[index],
                              clientId: clientId,
                            ),
                          );
                        },
                        childCount: announcements.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Error: $error',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ),
              ),
              // Espacio para el navbar flotante
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
          center: Alignment.topRight,
          radius: 1.5,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.backgroundDark,
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingM,
              AppConstants.spacingS,
              AppConstants.spacingM,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Avisos',
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Ofertas y anuncios del gimnasio',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingS),
              ],
            ),
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
              'No tienes notificaciones por el momento.\nLas ofertas y anuncios aparecerán aquí.',
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

class _AnnouncementCard extends ConsumerWidget {
  final AnnouncementModel announcement;
  final String clientId;

  const _AnnouncementCard({
    required this.announcement,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(announcement.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.spacingL),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      onDismissed: (direction) {
        ref.read(firebaseServiceProvider).dismissAnnouncementForClient(
          clientId,
          announcement.id,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación eliminada'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: GlassCard(
        onTap: () {
          // Marcar como leído al tocar
          ref.read(firebaseServiceProvider).markAnnouncementAsRead(
            clientId,
            announcement.id,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con tipo e icono
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    color: _getTypeColor(announcement.tipo).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Icon(
                    _getTypeIcon(announcement.tipo),
                    color: _getTypeColor(announcement.tipo),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.titulo,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(announcement.fechaCreacion),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(announcement.tipo).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    border: Border.all(color: _getTypeColor(announcement.tipo)),
                  ),
                  child: Text(
                    _getTypeName(announcement.tipo),
                    style: AppTypography.labelSmall.copyWith(
                      color: _getTypeColor(announcement.tipo),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            const Divider(color: AppColors.surfaceLight, height: 1),
            const SizedBox(height: AppConstants.spacingM),

            // Mensaje
            Text(
              announcement.mensaje,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),

            // Footer con info del entrenador
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.textSecondaryDark,
                ),
                const SizedBox(width: 4),
                Text(
                  'De: ${announcement.entrenadorNombre}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeName(AnnouncementType type) {
    switch (type) {
      case AnnouncementType.oferta:
        return 'OFERTA';
      case AnnouncementType.promocion:
        return 'PROMO';
      case AnnouncementType.aviso:
        return 'AVISO';
      case AnnouncementType.informacion:
        return 'INFO';
    }
  }

  Color _getTypeColor(AnnouncementType type) {
    switch (type) {
      case AnnouncementType.oferta:
        return AppColors.success;
      case AnnouncementType.promocion:
        return AppColors.primary;
      case AnnouncementType.aviso:
        return AppColors.warning;
      case AnnouncementType.informacion:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(AnnouncementType type) {
    switch (type) {
      case AnnouncementType.oferta:
        return Icons.local_offer;
      case AnnouncementType.promocion:
        return Icons.celebration;
      case AnnouncementType.aviso:
        return Icons.notifications_active;
      case AnnouncementType.informacion:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Ahora';
        }
        return 'Hace ${diff.inMinutes} min';
      }
      return 'Hace ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
