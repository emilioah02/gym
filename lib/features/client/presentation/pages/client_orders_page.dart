import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';

/// Página para ver los pedidos del cliente
class ClientOrdersPage extends ConsumerWidget {
  const ClientOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider).value;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: const Text('Mis Pedidos'),
          backgroundColor: AppColors.backgroundDark,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final ordersAsync = ref.watch(clientStoreOrdersProvider(user.uid));

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
                sliver: ordersAsync.when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return SliverFillRemaining(
                        child: _buildEmptyState(),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppConstants.spacingM,
                            ),
                            child: _OrderCard(order: orders[index]),
                          );
                        },
                        childCount: orders.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: AppConstants.spacingM),
                          Text(
                            'Error al cargar pedidos',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingS),
                          Text(
                            error.toString(),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.9),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
        onPressed: () => Navigator.of(context).pop(),
      ),
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
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Mis Pedidos',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Historial de compras',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              'No hay pedidos',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Aún no has realizado ningún pedido.\nVisita la tienda para comenzar.',
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

/// Widget de tarjeta de pedido
class _OrderCard extends ConsumerWidget {
  final StoreOrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(order.estado);
    final statusText = _getStatusText(order.estado);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estado y fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: AppConstants.spacingS,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: statusColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(order.estado),
                      color: statusColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: AppTypography.labelMedium.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(order.fechaPedido),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          const Divider(color: AppColors.glassBorder, height: 1),
          const SizedBox(height: AppConstants.spacingM),

          // Lista de items
          Text(
            'Productos (${order.items.length})',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Expanded(
                      child: Text(
                        '${item.productName} x${item.quantity}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                    Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: AppConstants.spacingM),
          const Divider(color: AppColors.glassBorder, height: 1),
          const SizedBox(height: AppConstants.spacingM),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)} MXN',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Botón para marcar como recibido si está listo
          if (order.estado == OrderStatus.listo) ...[
            const SizedBox(height: AppConstants.spacingM),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await ref
                        .read(firebaseServiceProvider)
                        .markOrderAsDelivered(order.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Pedido marcado como recibido'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusM),
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
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusM),
                          ),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.check_circle, size: 20),
                label: const Text('Marcar como recibido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendiente:
        return AppColors.warning;
      case OrderStatus.enPreparacion:
        return AppColors.info;
      case OrderStatus.listo:
        return AppColors.success;
      case OrderStatus.entregado:
        return AppColors.textSecondaryDark;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendiente:
        return 'Pendiente';
      case OrderStatus.enPreparacion:
        return 'En preparación';
      case OrderStatus.listo:
        return 'Listo para recoger';
      case OrderStatus.entregado:
        return 'Entregado';
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendiente:
        return Icons.schedule;
      case OrderStatus.enPreparacion:
        return Icons.kitchen;
      case OrderStatus.listo:
        return Icons.check_circle;
      case OrderStatus.entregado:
        return Icons.done_all;
    }
  }
}
