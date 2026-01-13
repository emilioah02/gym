import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import 'assign_routine_page.dart';

/// Centro de Notificaciones del Entrenador
/// Dos tabs: Solicitudes de Entrenamiento | Pedidos de Tienda
class TrainerNotificationsCenterPage extends ConsumerStatefulWidget {
  /// Tab inicial: 0 = Entrenamientos, 1 = Pedidos
  final int initialTab;

  const TrainerNotificationsCenterPage({
    super.key,
    this.initialTab = 0,
  });

  @override
  ConsumerState<TrainerNotificationsCenterPage> createState() =>
      _TrainerNotificationsCenterPageState();
}

class _TrainerNotificationsCenterPageState
    extends ConsumerState<TrainerNotificationsCenterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasMarkedAsRead = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    // Marcar notificaciones como leídas al abrir la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markNotificationsAsRead();
    });
  }

  Future<void> _markNotificationsAsRead() async {
    if (_hasMarkedAsRead) return;
    _hasMarkedAsRead = true;

    final firebaseUser = ref.read(firebaseUserProvider).value;
    if (firebaseUser != null) {
      await ref.read(firebaseServiceProvider).markAllNotificationsAsRead(firebaseUser.uid);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routineRequests = ref.watch(routineRequestsProvider);
    final storeOrders = ref.watch(activeStoreOrdersProvider);

    final pendingRoutines = routineRequests.value
            ?.where((r) => r.estado == RequestStatus.pendiente)
            .length ??
        0;
    final activeOrders = storeOrders.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: FloatingActionButton.extended(
          onPressed: () => _showAnnouncementModal(context, ref),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.backgroundDark,
          icon: const Icon(Icons.campaign),
          label: Text(
            'Anuncio',
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildAppBar(context, pendingRoutines, activeOrders),
              SliverToBoxAdapter(child: _buildTabBar()),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _TrainingRequestsTab(key: const ValueKey('training_tab')),
                _StoreOrdersTab(key: const ValueKey('orders_tab')),
                _SentAnnouncementsTab(key: const ValueKey('announcements_tab')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAnnouncementModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AnnouncementModal(),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.backgroundDark,
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, int pendingRoutines, int activeOrders) {
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
                            'Solicitudes, pedidos y anuncios',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildCompactBadge(
                      count: pendingRoutines,
                      icon: Icons.fitness_center,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    _buildCompactBadge(
                      count: activeOrders,
                      icon: Icons.shopping_bag,
                      color: AppColors.success,
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

  Widget _buildCompactBadge({
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.3),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondaryDark,
        labelStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        dividerHeight: 0,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, size: 16),
                SizedBox(width: 4),
                Text('Entrenos', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag, size: 16),
                SizedBox(width: 4),
                Text('Pedidos', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign, size: 16),
                SizedBox(width: 4),
                Text('Enviados', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 1: SOLICITUDES DE ENTRENAMIENTO
// ============================================================================

class _TrainingRequestsTab extends ConsumerWidget {
  const _TrainingRequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(routineRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.fitness_center,
            title: 'Sin solicitudes de entrenamiento',
            message:
                'Cuando los clientes soliciten rutinas personalizadas, aparecerán aquí',
          );
        }

        final pending =
            requests.where((r) => r.estado == RequestStatus.pendiente).toList()
              ..sort((a, b) => b.fechaSolicitud.compareTo(a.fechaSolicitud));
        final completed =
            requests.where((r) => r.estado != RequestStatus.pendiente).toList()
              ..sort((a, b) => b.fechaSolicitud.compareTo(a.fechaSolicitud));

        return ListView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          children: [
            if (pending.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Pendientes',
                count: pending.length,
                color: AppColors.warning,
                icon: Icons.schedule,
              ),
              const SizedBox(height: AppConstants.spacingS),
              ...pending.map((request) => _DismissibleRequestCard(
                    request: request,
                    key: ValueKey(request.id),
                  )),
              const SizedBox(height: AppConstants.spacingL),
            ],
            if (completed.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Completadas',
                count: completed.length,
                color: AppColors.success,
                icon: Icons.check_circle,
              ),
              const SizedBox(height: AppConstants.spacingS),
              ...completed.map((request) => _DismissibleRequestCard(
                    request: request,
                    key: ValueKey(request.id),
                  )),
            ],
            const SizedBox(height: 100), // Espacio para bottom nav
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error al cargar solicitudes',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              message,
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

/// Widget Dismissible para solicitudes de entrenamiento
class _DismissibleRequestCard extends ConsumerWidget {
  final RoutineRequestModel request;

  const _DismissibleRequestCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('dismiss_${request.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Eliminar solicitud',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            content: Text(
              '¿Deseas eliminar esta solicitud de ${request.clienteNombre}?',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondaryDark),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) async {
        try {
          await ref.read(firebaseServiceProvider).deleteRoutineRequest(request.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Solicitud eliminada'),
                backgroundColor: AppColors.surfaceDark,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: AppColors.primary,
                  onPressed: () {},
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      child: _TrainingRequestCard(request: request),
    );
  }
}

/// Card de solicitud de entrenamiento
class _TrainingRequestCard extends ConsumerWidget {
  final RoutineRequestModel request;

  const _TrainingRequestCard({
    required this.request,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = request.estado == RequestStatus.pendiente;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      onTap: isPending ? () => _navigateToAssignRoutine(context, ref) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con avatar y nombre
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.clienteNombre,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(request.fechaSolicitud),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Info de parte del cuerpo solicitada
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Text(
                  request.parteDelCuerpo.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rutina Solicitada',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      Text(
                        request.parteDelCuerpo.displayName,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPending)
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),

          // Botón de asignar rutina (solo si está pendiente)
          if (isPending) ...[
            const SizedBox(height: AppConstants.spacingM),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToAssignRoutine(context, ref),
                icon: const Icon(Icons.assignment_add, size: 20),
                label: const Text('Asignar Rutina'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
              ),
            ),
          ],

          // Nota de respuesta (si existe)
          if (request.respuestaNota != null &&
              request.respuestaNota!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingS),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.comment,
                    size: 16,
                    color: AppColors.textSecondaryDark,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.respuestaNota!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
      backgroundImage: request.clientePhotoUrl != null
          ? CachedNetworkImageProvider(request.clientePhotoUrl!)
          : null,
      child: request.clientePhotoUrl == null
          ? Text(
              request.clienteNombre.isNotEmpty
                  ? request.clienteNombre[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            )
          : null,
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor(request.estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            request.estado.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            request.estado.displayName,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pendiente:
        return AppColors.warning;
      case RequestStatus.asignada:
        return AppColors.success;
      case RequestStatus.rechazada:
        return AppColors.error;
    }
  }

  Future<void> _navigateToAssignRoutine(
      BuildContext context, WidgetRef ref) async {
    try {
      final client =
          await ref.read(firebaseServiceProvider).getUser(request.clienteId);

      if (client == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo encontrar el cliente'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignRoutinePage(
              client: client,
              requestId: request.id,
              suggestedBodyPart: request.parteDelCuerpo,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}

// ============================================================================
// TAB 2: PEDIDOS DE TIENDA
// ============================================================================

class _StoreOrdersTab extends ConsumerWidget {
  const _StoreOrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(storeOrdersProvider);

    return ordersAsync.when(
      data: (orders) {
        // Separar por estado
        final pendientes = orders
            .where((o) => o.estado == OrderStatus.pendiente)
            .toList()
          ..sort((a, b) => b.fechaPedido.compareTo(a.fechaPedido));
        final enPreparacion = orders
            .where((o) => o.estado == OrderStatus.enPreparacion)
            .toList()
          ..sort((a, b) => b.fechaPedido.compareTo(a.fechaPedido));
        final listos = orders
            .where((o) => o.estado == OrderStatus.listo)
            .toList()
          ..sort((a, b) => b.fechaPedido.compareTo(a.fechaPedido));
        final entregados = orders
            .where((o) => o.estado == OrderStatus.entregado)
            .toList()
          ..sort((a, b) => b.fechaPedido.compareTo(a.fechaPedido));

        final hasActiveOrders =
            pendientes.isNotEmpty || enPreparacion.isNotEmpty || listos.isNotEmpty;

        if (orders.isEmpty) {
          return _buildEmptyState();
        }

        return ListView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          children: [
            // Resumen rápido de estados activos
            if (hasActiveOrders) ...[
              _buildQuickStats(pendientes.length, enPreparacion.length, listos.length),
              const SizedBox(height: AppConstants.spacingL),
            ],

            // Pedidos Pendientes
            if (pendientes.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Nuevos Pedidos',
                count: pendientes.length,
                color: AppColors.warning,
                icon: Icons.new_releases,
              ),
              const SizedBox(height: AppConstants.spacingS),
              ...pendientes.map((order) => _DismissibleOrderCard(
                    order: order,
                    key: ValueKey(order.id),
                  )),
              const SizedBox(height: AppConstants.spacingL),
            ],

            // En Preparación
            if (enPreparacion.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'En Preparación',
                count: enPreparacion.length,
                color: Colors.orange,
                icon: Icons.kitchen,
              ),
              const SizedBox(height: AppConstants.spacingS),
              ...enPreparacion.map((order) => _DismissibleOrderCard(
                    order: order,
                    key: ValueKey(order.id),
                  )),
              const SizedBox(height: AppConstants.spacingL),
            ],

            // Listos para Recoger
            if (listos.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Listos para Recoger',
                count: listos.length,
                color: AppColors.success,
                icon: Icons.check_circle,
              ),
              const SizedBox(height: AppConstants.spacingS),
              ...listos.map((order) => _DismissibleOrderCard(
                    order: order,
                    key: ValueKey(order.id),
                  )),
              const SizedBox(height: AppConstants.spacingL),
            ],

            // Entregados (últimos 10)
            if (entregados.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Entregados Recientes',
                count: entregados.length,
                color: AppColors.textSecondaryDark,
                icon: Icons.done_all,
              ),
              const SizedBox(height: AppConstants.spacingS),
              ...entregados.take(10).map((order) => _DismissibleOrderCard(
                    order: order,
                    key: ValueKey(order.id),
                  )),
            ],

            const SizedBox(height: 100), // Espacio para bottom nav
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error al cargar pedidos',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(int pendientes, int enPreparacion, int listos) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceDark,
            AppColors.surfaceDark.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            count: pendientes,
            label: 'Nuevos',
            color: AppColors.warning,
            icon: Icons.fiber_new,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.glassBorder,
          ),
          _buildStatItem(
            count: enPreparacion,
            label: 'Preparando',
            color: Colors.orange,
            icon: Icons.kitchen,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.glassBorder,
          ),
          _buildStatItem(
            count: listos,
            label: 'Listos',
            color: AppColors.success,
            icon: Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required int count,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: AppTypography.headlineSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              'Sin pedidos',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Los pedidos de la tienda aparecerán aquí\ncuando los clientes realicen compras',
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

/// Widget Dismissible para pedidos de tienda
class _DismissibleOrderCard extends ConsumerWidget {
  final StoreOrderModel order;

  const _DismissibleOrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('dismiss_order_${order.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Eliminar pedido',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            content: Text(
              '¿Deseas eliminar este pedido de ${order.clienteNombre}?',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondaryDark),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) async {
        try {
          await ref.read(firebaseServiceProvider).deleteStoreOrder(order.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Pedido eliminado'),
                backgroundColor: AppColors.surfaceDark,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: AppColors.primary,
                  onPressed: () {},
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      child: _StoreOrderCard(order: order),
    );
  }
}

/// Card de pedido de tienda con acciones
class _StoreOrderCard extends ConsumerWidget {
  final StoreOrderModel order;

  const _StoreOrderCard({
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      onTap: () => _showOrderDetailModal(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con cliente y estado
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.clienteNombre,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(order.fechaPedido),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Resumen de items
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingS),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Column(
              children: [
                ...order.items.take(2).map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item.quantity}x',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.productName,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textPrimaryDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\$${item.subtotal.toStringAsFixed(0)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (order.items.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${order.items.length - 2} productos más...',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingM),

          // Total y acciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    Text(
                      '\$${order.total.toStringAsFixed(0)} MXN',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingS),
              Flexible(child: _buildActionButton(context, ref)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.success.withValues(alpha: 0.2),
      backgroundImage: order.clientePhotoUrl != null
          ? CachedNetworkImageProvider(order.clientePhotoUrl!)
          : null,
      child: order.clientePhotoUrl == null
          ? Text(
              order.clienteNombre.isNotEmpty
                  ? order.clienteNombre[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            )
          : null,
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor(order.estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            order.estado.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            order.estado.displayName,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref) {
    switch (order.estado) {
      case OrderStatus.pendiente:
        return ElevatedButton.icon(
          onPressed: () => _updateOrderStatus(
              context, ref, OrderStatus.enPreparacion, 'Pedido en preparación'),
          icon: const Icon(Icons.kitchen, size: 16),
          label: const Text('Preparar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      case OrderStatus.enPreparacion:
        return ElevatedButton.icon(
          onPressed: () => _markAsReady(context, ref),
          icon: const Icon(Icons.check_circle, size: 16),
          label: const Text('Listo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      case OrderStatus.listo:
        return ElevatedButton.icon(
          onPressed: () => _markAsDelivered(context, ref),
          icon: const Icon(Icons.done_all, size: 16),
          label: const Text('Entregar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      case OrderStatus.entregado:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.done_all,
                  size: 16, color: AppColors.textSecondaryDark),
              const SizedBox(width: 4),
              Text(
                'Completado',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        );
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendiente:
        return AppColors.warning;
      case OrderStatus.enPreparacion:
        return Colors.orange;
      case OrderStatus.listo:
        return AppColors.success;
      case OrderStatus.entregado:
        return AppColors.textSecondaryDark;
    }
  }

  Future<void> _updateOrderStatus(
    BuildContext context,
    WidgetRef ref,
    OrderStatus newStatus,
    String message,
  ) async {
    try {
      await ref.read(firebaseServiceProvider).updateOrderStatus(
            order.id,
            newStatus,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _markAsReady(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(firebaseServiceProvider).markOrderAsReady(order.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Pedido listo - Cliente notificado para recoger en caja'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _markAsDelivered(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(firebaseServiceProvider).markOrderAsDelivered(order.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido entregado con exito'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showOrderDetailModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailModal(order: order),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}

/// Modal de detalle de orden con todas las acciones
class _OrderDetailModal extends ConsumerWidget {
  final StoreOrderModel order;

  const _OrderDetailModal({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.success.withValues(alpha: 0.2),
                      backgroundImage: order.clientePhotoUrl != null
                          ? CachedNetworkImageProvider(order.clientePhotoUrl!)
                          : null,
                      child: order.clientePhotoUrl == null
                          ? Text(
                              order.clienteNombre.isNotEmpty
                                  ? order.clienteNombre[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pedido de ${order.clienteNombre}',
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm')
                                .format(order.fechaPedido),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close,
                          color: AppColors.textSecondaryDark),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.glassBorder, height: 1),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  children: [
                    // Estado actual
                    _buildStatusTimeline(),
                    const SizedBox(height: AppConstants.spacingL),

                    // Productos
                    Text(
                      'Productos del Pedido',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    ...order.items.map((item) => _buildProductItem(item)),

                    const SizedBox(height: AppConstants.spacingL),
                    const Divider(color: AppColors.glassBorder),
                    const SizedBox(height: AppConstants.spacingM),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total a Cobrar',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$${order.total.toStringAsFixed(2)} MXN',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    // Notas
                    if (order.notas != null && order.notas!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacingL),
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingM),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sticky_note_2,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Notas del cliente',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    order.notas!,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textPrimaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppConstants.spacingXL),

                    // Botones de acción
                    _buildActionButtons(context, ref),
                    const SizedBox(height: AppConstants.spacingL),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusTimeline() {
    final statuses = [
      OrderStatus.pendiente,
      OrderStatus.enPreparacion,
      OrderStatus.listo,
      OrderStatus.entregado,
    ];

    final currentIndex = statuses.indexOf(order.estado);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: statuses.asMap().entries.map((entry) {
          final index = entry.key;
          final status = entry.value;
          final isActive = index <= currentIndex;
          final isCurrent = index == currentIndex;

          return Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive
                      ? _getStatusColor(status)
                      : AppColors.surfaceLight.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(
                          color: _getStatusColor(status),
                          width: 3,
                        )
                      : null,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color:
                                _getStatusColor(status).withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    status.emoji,
                    style: TextStyle(
                      fontSize: isActive ? 16 : 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getShortStatusName(status),
                style: AppTypography.labelSmall.copyWith(
                  color:
                      isActive ? _getStatusColor(status) : AppColors.textSecondaryDark,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 10,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getShortStatusName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendiente:
        return 'Nuevo';
      case OrderStatus.enPreparacion:
        return 'Preparando';
      case OrderStatus.listo:
        return 'Listo';
      case OrderStatus.entregado:
        return 'Entregado';
    }
  }

  Widget _buildProductItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${item.price.toStringAsFixed(2)} c/u',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    switch (order.estado) {
      case OrderStatus.pendiente:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(firebaseServiceProvider).updateOrderStatus(
                        order.id,
                        OrderStatus.enPreparacion,
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pedido en preparación'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.kitchen),
                label: const Text('Comenzar a Preparar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        );
      case OrderStatus.enPreparacion:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await ref.read(firebaseServiceProvider).markOrderAsReady(order.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.notifications_active,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                              'Pedido listo - Cliente notificado para pasar a caja'),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Marcar como Listo y Notificar Cliente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      case OrderStatus.listo:
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active,
                      color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cliente Notificado',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'El cliente recibió la notificación para pasar a caja',
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
            const SizedBox(height: AppConstants.spacingM),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref
                      .read(firebaseServiceProvider)
                      .markOrderAsDelivered(order.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pedido entregado exitosamente'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.done_all),
                label: const Text('Confirmar Entrega'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        );
      case OrderStatus.entregado:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacingL),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'Pedido Completado',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (order.fechaEntregado != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Entregado el ${DateFormat('dd/MM/yyyy HH:mm').format(order.fechaEntregado!)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendiente:
        return AppColors.warning;
      case OrderStatus.enPreparacion:
        return Colors.orange;
      case OrderStatus.listo:
        return AppColors.success;
      case OrderStatus.entregado:
        return AppColors.textSecondaryDark;
    }
  }
}

// ============================================================================
// MODAL DE ANUNCIOS
// ============================================================================

class _AnnouncementModal extends ConsumerStatefulWidget {
  const _AnnouncementModal();

  @override
  ConsumerState<_AnnouncementModal> createState() => _AnnouncementModalState();
}

class _AnnouncementModalState extends ConsumerState<_AnnouncementModal> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _mensajeController = TextEditingController();

  AnnouncementType _tipoSeleccionado = AnnouncementType.aviso;
  bool _enviarATodos = true;
  final Set<String> _clientesSeleccionados = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _enviarAnuncio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firebaseUser = ref.read(firebaseUserProvider).value;
      final userModel = ref.read(userModelProvider).value;

      if (firebaseUser == null || userModel == null) {
        throw Exception('Usuario no autenticado');
      }

      final announcement = AnnouncementModel(
        id: '',
        titulo: _tituloController.text.trim(),
        mensaje: _mensajeController.text.trim(),
        tipo: _tipoSeleccionado,
        entrenadorId: firebaseUser.uid,
        entrenadorNombre: userModel.nombre ?? 'Entrenador',
        fechaCreacion: DateTime.now(),
        clientesIds: _enviarATodos ? [] : _clientesSeleccionados.toList(),
        activo: true,
      );

      await ref.read(firebaseServiceProvider).createAnnouncement(announcement);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anuncio enviado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar anuncio: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.campaign,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Text(
                        'Nuevo Anuncio',
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.textSecondaryDark),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.glassBorder, height: 1),

              // Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    children: [
                      // Tipo de anuncio
                      Text(
                        'Tipo de Anuncio',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      _buildAnnouncementTypeSelector(),
                      const SizedBox(height: AppConstants.spacingL),

                      // Título
                      Text(
                        'Título',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      TextFormField(
                        controller: _tituloController,
                        style: const TextStyle(color: AppColors.textPrimaryDark),
                        decoration: InputDecoration(
                          hintText: 'Ej: ¡Oferta especial!',
                          hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                          filled: true,
                          fillColor: AppColors.backgroundDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            borderSide: BorderSide(color: AppColors.glassBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            borderSide: BorderSide(color: AppColors.glassBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa un título';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingL),

                      // Mensaje
                      Text(
                        'Mensaje',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      TextFormField(
                        controller: _mensajeController,
                        style: const TextStyle(color: AppColors.textPrimaryDark),
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Escribe tu mensaje aquí...',
                          hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                          filled: true,
                          fillColor: AppColors.backgroundDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            borderSide: BorderSide(color: AppColors.glassBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            borderSide: BorderSide(color: AppColors.glassBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa un mensaje';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingL),

                      // Destinatarios
                      Text(
                        'Destinatarios',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark,
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text(
                                'Enviar a todos los clientes',
                                style: TextStyle(color: AppColors.textPrimaryDark),
                              ),
                              value: _enviarATodos,
                              onChanged: (value) {
                                setState(() {
                                  _enviarATodos = value;
                                  if (value) _clientesSeleccionados.clear();
                                });
                              },
                              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                              activeThumbColor: AppColors.primary,
                            ),
                            if (!_enviarATodos) ...[
                              const Divider(color: AppColors.glassBorder, height: 1),
                              clientsAsync.when(
                                data: (clients) {
                                  if (clients.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(AppConstants.spacingM),
                                      child: Text(
                                        'No hay clientes disponibles',
                                        style: TextStyle(color: AppColors.textSecondaryDark),
                                      ),
                                    );
                                  }
                                  return Column(
                                    children: clients.map((client) {
                                      final isSelected = _clientesSeleccionados.contains(client.uid);
                                      return CheckboxListTile(
                                        title: Text(
                                          client.nombre ?? 'Cliente',
                                          style: const TextStyle(color: AppColors.textPrimaryDark),
                                        ),
                                        value: isSelected,
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == true) {
                                              _clientesSeleccionados.add(client.uid);
                                            } else {
                                              _clientesSeleccionados.remove(client.uid);
                                            }
                                          });
                                        },
                                        activeColor: AppColors.primary,
                                      );
                                    }).toList(),
                                  );
                                },
                                loading: () => const Padding(
                                  padding: EdgeInsets.all(AppConstants.spacingM),
                                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                ),
                                error: (_, __) => const Padding(
                                  padding: EdgeInsets.all(AppConstants.spacingM),
                                  child: Text('Error al cargar clientes', style: TextStyle(color: AppColors.error)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXL),

                      // Botón de enviar
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _enviarAnuncio,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send),
                                    SizedBox(width: AppConstants.spacingS),
                                    Text(
                                      'Enviar Anuncio',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingL),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementTypeSelector() {
    return Wrap(
      spacing: AppConstants.spacingS,
      runSpacing: AppConstants.spacingS,
      children: AnnouncementType.values.map((type) {
        final isSelected = _tipoSeleccionado == type;
        return ChoiceChip(
          label: Text(_getTypeName(type)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _tipoSeleccionado = type);
          },
          selectedColor: _getTypeColor(type),
          backgroundColor: AppColors.backgroundDark,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.backgroundDark : AppColors.textPrimaryDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          avatar: Icon(
            _getTypeIcon(type),
            color: isSelected ? AppColors.backgroundDark : _getTypeColor(type),
            size: 18,
          ),
        );
      }).toList(),
    );
  }

  String _getTypeName(AnnouncementType type) {
    switch (type) {
      case AnnouncementType.oferta:
        return 'Oferta';
      case AnnouncementType.promocion:
        return 'Promoción';
      case AnnouncementType.aviso:
        return 'Aviso';
      case AnnouncementType.informacion:
        return 'Info';
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
}

// ============================================================================
// TAB 3: ANUNCIOS ENVIADOS
// ============================================================================

class _SentAnnouncementsTab extends ConsumerWidget {
  const _SentAnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(trainerAnnouncementsProvider);

    return announcementsAsync.when(
      data: (announcements) {
        if (announcements.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          itemCount: announcements.length + 1, // +1 for bottom padding
          itemBuilder: (context, index) {
            if (index == announcements.length) {
              return const SizedBox(height: 100); // Espacio para bottom nav
            }
            return _SentAnnouncementCard(
              announcement: announcements[index],
              key: ValueKey(announcements[index].id),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error al cargar anuncios',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.campaign_outlined,
                size: 64,
                color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              'Sin anuncios enviados',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Los anuncios que envíes a tus clientes\naparecerán aquí',
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

/// Card de anuncio enviado
class _SentAnnouncementCard extends ConsumerWidget {
  final AnnouncementModel announcement;

  const _SentAnnouncementCard({
    super.key,
    required this.announcement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('dismiss_announcement_${announcement.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Eliminar anuncio',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            content: Text(
              '¿Deseas eliminar este anuncio? Los clientes ya no podrán verlo.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondaryDark),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) async {
        try {
          await ref.read(firebaseServiceProvider).deleteAnnouncement(announcement.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Anuncio eliminado'),
                backgroundColor: AppColors.surfaceDark,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: AppColors.primary,
                  onPressed: () {},
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con tipo y fecha
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getTypeColor(announcement.tipo).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTypeIcon(announcement.tipo),
                    color: _getTypeColor(announcement.tipo),
                    size: 22,
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
                        _formatTimeAgo(announcement.fechaCreacion),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(announcement.tipo).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getTypeColor(announcement.tipo),
                    ),
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

            // Mensaje
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Text(
                announcement.mensaje,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Destinatarios
            Row(
              children: [
                Icon(
                  announcement.clientesIds.isEmpty
                      ? Icons.groups
                      : Icons.person,
                  size: 16,
                  color: AppColors.textSecondaryDark,
                ),
                const SizedBox(width: 6),
                Text(
                  announcement.clientesIds.isEmpty
                      ? 'Enviado a todos los clientes'
                      : 'Enviado a ${announcement.clientesIds.length} cliente(s)',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}
