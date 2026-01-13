import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';

/// Página de historial de entrenamientos del cliente
class ClientHistoryPage extends ConsumerWidget {
  const ClientHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(currentUserHistoryProvider);
    final unreadCount = ref.watch(unreadAnnouncementsCountProvider).value ?? 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(context, unreadCount),
              historyAsync.when(
                data: (history) {
                  if (history.isEmpty) {
                    return SliverFillRemaining(child: _buildEmptyState());
                  }
                  return _buildHistoryList(context, ref, history);
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (error, _) => SliverFillRemaining(
                  child: _buildErrorState(error.toString()),
                ),
              ),
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
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.backgroundDark,
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, int unreadCount) {
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
                        Icons.history_rounded,
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
                            'Historial',
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Tus entrenamientos completados',
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'Sin historial',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
            child: Text(
              'Completa tu primer entrenamiento para comenzar a ver tu historial aquí.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'Error al cargar',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          Text(
            error,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, WidgetRef ref, List<TrainingHistory> history) {
    // Agrupar por mes
    final grouped = <String, List<TrainingHistory>>{};
    for (final item in history) {
      final monthKey = DateFormat('MMMM yyyy', 'es').format(item.fecha);
      grouped.putIfAbsent(monthKey, () => []).add(item);
    }

    final months = grouped.keys.toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final month = months[index];
          final items = grouped[month]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacingM,
                  AppConstants.spacingL,
                  AppConstants.spacingM,
                  AppConstants.spacingS,
                ),
                child: Row(
                  children: [
                    Text(
                      month.substring(0, 1).toUpperCase() + month.substring(1),
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                      ),
                      child: Text(
                        '${items.length}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...items.map((item) => _HistoryCard(
                history: item,
                onDelete: () => _confirmDeleteHistory(context, ref, item),
              )),
            ],
          );
        },
        childCount: months.length,
      ),
    );
  }

  /// Muestra diálogo de confirmación para eliminar entrada del historial
  void _confirmDeleteHistory(BuildContext context, WidgetRef ref, TrainingHistory history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Eliminar entrenamiento',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar este entrenamiento del ${DateFormat('d MMMM yyyy', 'es').format(history.fecha)}?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(firebaseServiceProvider).deleteTrainingHistory(history.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Entrenamiento eliminado'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TrainingHistory history;
  final VoidCallback? onDelete;

  const _HistoryCard({required this.history, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      child: Dismissible(
        key: Key(history.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          onDelete?.call();
          return false; // No eliminar automáticamente, el callback maneja la confirmación
        },
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
            size: 28,
          ),
        ),
        child: GlassCard(
          child: Row(
            children: [
              // Fecha
              Container(
                width: 50,
                padding: const EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: history.completada
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Column(
                  children: [
                    Text(
                      '${history.fecha.day}',
                      style: AppTypography.titleLarge.copyWith(
                        color: history.completada ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      DateFormat('MMM', 'es').format(history.fecha).toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: history.completada ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.rutinaNombre,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: AppColors.textSecondaryDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          history.duracionMinutos != null
                              ? '${history.duracionMinutos} min'
                              : '~60 min',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          history.completada
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 14,
                          color: history.completada
                              ? AppColors.success
                              : AppColors.textSecondaryDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          history.completada ? 'Completada' : 'Parcial',
                          style: AppTypography.bodySmall.copyWith(
                            color: history.completada
                                ? AppColors.success
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                    if (history.notas != null && history.notas!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        history.notas!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Botón de eliminar
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.textSecondaryDark,
                  size: 20,
                ),
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
