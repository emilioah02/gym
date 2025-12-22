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

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              historyAsync.when(
                data: (history) {
                  if (history.isEmpty) {
                    return SliverFillRemaining(child: _buildEmptyState());
                  }
                  return _buildHistoryList(history);
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

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Historial',
        style: AppTypography.headlineMedium.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
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

  Widget _buildHistoryList(List<TrainingHistory> history) {
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
              ...items.map((item) => _HistoryCard(history: item)),
            ],
          );
        },
        childCount: months.length,
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TrainingHistory history;

  const _HistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
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
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondaryDark,
            ),
          ],
        ),
      ),
    );
  }
}
