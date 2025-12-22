import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import 'assign_routine_page.dart';

/// Página de solicitudes de rutina y pedidos de tienda para el entrenador
class TrainerRequestsPage extends ConsumerStatefulWidget {
  const TrainerRequestsPage({super.key});

  @override
  ConsumerState<TrainerRequestsPage> createState() => _TrainerRequestsPageState();
}

class _TrainerRequestsPageState extends ConsumerState<TrainerRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(pendingRoutines, activeOrders),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildTabBar(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRoutineRequestsTab(),
                          _buildStoreOrdersTab(),
                        ],
                      ),
                    ),
                  ],
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

  SliverAppBar _buildAppBar(int pendingRoutines, int activeOrders) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.9),
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
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notificaciones',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$pendingRoutines solicitudes · $activeOrders pedidos',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingM),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        labelColor: AppColors.backgroundDark,
        unselectedLabelColor: AppColors.textSecondaryDark,
        labelStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Solicitudes de Rutina'),
          Tab(text: 'Pedidos de Tienda'),
        ],
      ),
    );
  }

  Widget _buildRoutineRequestsTab() {
    final requestsAsync = ref.watch(routineRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.fitness_center,
            title: 'Sin solicitudes de rutina',
            message: 'Cuando los clientes soliciten rutinas, aparecerán aquí',
          );
        }

        final pending = requests
            .where((r) => r.estado == RequestStatus.pendiente)
            .toList();
        final completed = requests
            .where((r) => r.estado != RequestStatus.pendiente)
            .toList();

        return ListView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          children: [
            if (pending.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                child: Text(
                  'Pendientes (${pending.length})',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...pending.map((request) => _buildRoutineRequestCard(request)),
              const SizedBox(height: AppConstants.spacingL),
            ],
            if (completed.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                child: Text(
                  'Completadas (${completed.length})',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...completed.map((request) => _buildRoutineRequestCard(request)),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildRoutineRequestCard(RoutineRequestModel request) {
    final isPending = request.estado == RequestStatus.pendiente;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: InkWell(
        onTap: isPending
            ? () => _handleRoutineRequest(request)
            : null,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    backgroundImage: request.clientePhotoUrl != null
                        ? CachedNetworkImageProvider(request.clientePhotoUrl!)
                        : null,
                    child: request.clientePhotoUrl == null
                        ? Text(
                            request.clienteNombre[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.estado).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      border: Border.all(
                        color: _getStatusColor(request.estado),
                      ),
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
                            color: _getStatusColor(request.estado),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingM),
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Row(
                  children: [
                    Text(
                      request.parteDelCuerpo.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Text(
                      'Solicita: ${request.parteDelCuerpo.displayName}',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPending) ...[
                const SizedBox(height: AppConstants.spacingM),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleRoutineRequest(request),
                    icon: const Icon(Icons.assignment_add),
                    label: const Text('Asignar Rutina'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundDark,
                    ),
                  ),
                ),
              ],
              if (request.respuestaNota != null) ...[
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  'Nota: ${request.respuestaNota}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreOrdersTab() {
    final ordersAsync = ref.watch(storeOrdersProvider);

    return ordersAsync.when(
      data: (orders) {
        final activeOrders = orders
            .where((o) =>
                o.estado == OrderStatus.pendiente ||
                o.estado == OrderStatus.enPreparacion ||
                o.estado == OrderStatus.listo)
            .toList();

        if (activeOrders.isEmpty) {
          return _buildEmptyState(
            icon: Icons.shopping_bag,
            title: 'Sin pedidos activos',
            message: 'Los pedidos de la tienda aparecerán aquí',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          children: activeOrders.map((order) => _buildStoreOrderCard(order)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildStoreOrderCard(StoreOrderModel order) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundImage: order.clientePhotoUrl != null
                      ? CachedNetworkImageProvider(order.clientePhotoUrl!)
                      : null,
                  child: order.clientePhotoUrl == null
                      ? Text(
                          order.clienteNombre[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getOrderStatusColor(order.estado).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    border: Border.all(
                      color: _getOrderStatusColor(order.estado),
                    ),
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
                          color: _getOrderStatusColor(order.estado),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            const Divider(color: AppColors.surfaceLight),
            const SizedBox(height: AppConstants.spacingS),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}x',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingS),
                      Expanded(
                        child: Text(
                          item.productName,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                      ),
                      Text(
                        '\$${item.subtotal.toStringAsFixed(0)}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AppConstants.spacingS),
            const Divider(color: AppColors.surfaceLight),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '\$${order.total.toStringAsFixed(0)}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (order.estado != OrderStatus.listo) ...[
              const SizedBox(height: AppConstants.spacingM),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _markOrderAsReady(order.id),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Marcar como Listo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
              padding: const EdgeInsets.all(AppConstants.spacingXL),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.textSecondaryDark,
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

  Color _getOrderStatusColor(OrderStatus status) {
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

  Future<void> _handleRoutineRequest(RoutineRequestModel request) async {
    try {
      // Obtener el cliente desde Firestore
      final client = await ref.read(firebaseServiceProvider).getUser(request.clienteId);

      if (client == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo encontrar el cliente'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (mounted) {
        // Navegar a la página de asignación de rutina
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _markOrderAsReady(String orderId) async {
    try {
      await ref.read(firebaseServiceProvider).markOrderAsReady(orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido marcado como listo'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace ${weeks}sem';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace ${months}mes';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace ${years}año${years > 1 ? 's' : ''}';
    }
  }
}
