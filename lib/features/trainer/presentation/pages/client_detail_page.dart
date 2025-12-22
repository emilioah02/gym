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
import 'weekly_routine_builder_page.dart';

/// Página de detalle de cliente para el entrenador
class ClientDetailPage extends ConsumerStatefulWidget {
  final UserModel client;

  const ClientDetailPage({
    super.key,
    required this.client,
  });

  @override
  ConsumerState<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends ConsumerState<ClientDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildClientHeader()),
            SliverToBoxAdapter(child: _buildQuickStats()),
            SliverToBoxAdapter(child: _buildTabBar()),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _DatosTab(client: widget.client),
            _ProgresoTab(client: widget.client),
            _HistorialTab(client: widget.client),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.9),
      elevation: 0,
      title: Text(
        'Detalle de Cliente',
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondaryDark),
            color: AppColors.surfaceDark,
            onSelected: (value) {
              switch (value) {
                case 'assign_routine':
                  _navigateToAssignRoutine();
                  break;
                case 'assign_weekly':
                  _navigateToWeeklyRoutine();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'assign_routine',
                child: Row(
                  children: [
                    const Icon(Icons.fitness_center, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Asignar rutina', style: AppTypography.bodyMediumDark),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'assign_weekly',
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Asignar semana', style: AppTypography.bodyMediumDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Row(
        children: [
          // Avatar grande
          Hero(
            tag: 'client_avatar_${widget.client.uid}',
            child: CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundImage: widget.client.photoUrl != null
                  ? CachedNetworkImageProvider(widget.client.photoUrl!)
                  : null,
              child: widget.client.photoUrl == null
                  ? Text(
                      (widget.client.nombre ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppConstants.spacingL),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.client.nombre ?? 'Sin nombre',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (widget.client.genero != null) ...[
                      Icon(
                        widget.client.genero == UserGender.hombre
                            ? Icons.male
                            : Icons.female,
                        size: 16,
                        color: widget.client.genero == UserGender.hombre
                            ? Colors.blue
                            : Colors.pink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.client.genero!.displayName,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (widget.client.edad != null) ...[
                      Text(
                        '${widget.client.edad} años',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Estado de rutina
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.client.rutinaAsignadaId != null
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                  ),
                  child: Text(
                    widget.client.estadoRutina,
                    style: TextStyle(
                      color: widget.client.rutinaAsignadaId != null
                          ? AppColors.success
                          : AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
      child: Row(
        children: [
          Expanded(
            child: _QuickStatCard(
              icon: Icons.monitor_weight,
              label: 'IMC',
              value: widget.client.imc?.toStringAsFixed(1) ?? '-',
              subValue: widget.client.rangoIMC?.displayName,
              color: _getIMCColor(widget.client.rangoIMC),
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: _QuickStatCard(
              icon: Icons.local_fire_department,
              label: 'Racha',
              value: '${widget.client.rachasDias}',
              subValue: 'días',
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: _QuickStatCard(
              icon: Icons.access_time,
              label: 'Último',
              value: widget.client.ultimoEntrenamientoTexto,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIMCColor(IMCRange? range) {
    switch (range) {
      case IMCRange.bajoPeso:
        return AppColors.info;
      case IMCRange.normal:
        return AppColors.success;
      case IMCRange.sobrepeso:
        return AppColors.warning;
      case IMCRange.obesidad:
        return AppColors.error;
      default:
        return AppColors.textSecondaryDark;
    }
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingM),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glassDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppConstants.radiusL - 2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.backgroundDark,
        unselectedLabelColor: AppColors.textSecondaryDark,
        labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Datos'),
          Tab(text: 'Progreso'),
          Tab(text: 'Historial'),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _navigateToAssignRoutine,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.backgroundDark,
      icon: const Icon(Icons.add),
      label: const Text('Asignar Rutina'),
    );
  }

  void _navigateToAssignRoutine() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignRoutinePage(client: widget.client),
      ),
    );
  }

  void _navigateToWeeklyRoutine() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeeklyRoutineBuilderPage(clientId: widget.client.uid),
      ),
    );
  }
}

/// Card de estadística rápida
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;
  final Color color;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subValue != null)
            Text(
              subValue!,
              style: AppTypography.labelSmall.copyWith(
                color: color,
              ),
            ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab de datos del cliente
class _DatosTab extends StatelessWidget {
  final UserModel client;

  const _DatosTab({required this.client});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      children: [
        // Datos físicos
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Datos Físicos',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              _DataRow(
                icon: Icons.monitor_weight,
                label: 'Peso actual',
                value: client.peso != null ? '${client.peso} kg' : '-',
              ),
              _DataRow(
                icon: Icons.height,
                label: 'Altura',
                value: client.altura != null ? '${client.altura} m' : '-',
              ),
              _DataRow(
                icon: Icons.calculate,
                label: 'IMC',
                value: client.imc?.toStringAsFixed(2) ?? '-',
                valueColor: _getIMCColor(client.rangoIMC),
              ),
              _DataRow(
                icon: Icons.health_and_safety,
                label: 'Rango OMS',
                value: client.rangoIMC?.displayName ?? '-',
                valueColor: _getIMCColor(client.rangoIMC),
              ),
              if (client.pesoInicial != null)
                _DataRow(
                  icon: Icons.timeline,
                  label: 'Peso inicial',
                  value: '${client.pesoInicial} kg',
                ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),

        // Objetivo
        if (client.objetivo != null)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Objetivo',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingM),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Text(
                      client.objetivo!.displayName,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: AppConstants.spacingM),

        // Días de entrenamiento
        if (client.diasEntrenamiento != null && client.diasEntrenamiento!.isNotEmpty)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Días de Entrenamiento',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final dayNumber = index + 1;
                    final isActive = client.diasEntrenamiento!.contains(dayNumber);
                    final dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.glassDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive ? AppColors.primary : AppColors.glassBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          dayNames[index],
                          style: TextStyle(
                            color: isActive ? AppColors.primary : AppColors.textSecondaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getIMCColor(IMCRange? range) {
    switch (range) {
      case IMCRange.bajoPeso:
        return AppColors.info;
      case IMCRange.normal:
        return AppColors.success;
      case IMCRange.sobrepeso:
        return AppColors.warning;
      case IMCRange.obesidad:
        return AppColors.error;
      default:
        return AppColors.textSecondaryDark;
    }
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondaryDark),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: valueColor ?? AppColors.textPrimaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab de progreso del cliente
class _ProgresoTab extends ConsumerWidget {
  final UserModel client;

  const _ProgresoTab({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      children: [
        // Progreso de peso
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progreso de Peso',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),
              if (client.pesoInicial != null && client.peso != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _WeightCard(
                      label: 'Inicial',
                      value: '${client.pesoInicial}',
                      unit: 'kg',
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.textSecondaryDark,
                    ),
                    _WeightCard(
                      label: 'Actual',
                      value: '${client.peso}',
                      unit: 'kg',
                      isHighlight: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingL),
                // Diferencia
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getProgressColor(client).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getProgressIcon(client),
                          color: _getProgressColor(client),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getProgressText(client),
                          style: TextStyle(
                            color: _getProgressColor(client),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 48,
                        color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sin datos de progreso',
                        style: AppTypography.bodyMedium.copyWith(
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

        // Resumen de entrenamientos
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen de Entrenamientos',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.local_fire_department,
                      value: '${client.rachasDias}',
                      label: 'Racha actual',
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.calendar_today,
                      value: client.ultimoEntrenamientoTexto,
                      label: 'Último entrenamiento',
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(UserModel client) {
    if (client.pesoInicial == null || client.peso == null) {
      return AppColors.textSecondaryDark;
    }

    final diff = client.peso! - client.pesoInicial!;

    // Depende del objetivo
    if (client.objetivo == UserGoal.bajarGrasa) {
      return diff < 0 ? AppColors.success : AppColors.warning;
    } else if (client.objetivo == UserGoal.aumentarMusculo) {
      return diff > 0 ? AppColors.success : AppColors.warning;
    }

    return AppColors.info;
  }

  IconData _getProgressIcon(UserModel client) {
    if (client.pesoInicial == null || client.peso == null) {
      return Icons.remove;
    }

    final diff = client.peso! - client.pesoInicial!;
    if (diff < 0) return Icons.trending_down;
    if (diff > 0) return Icons.trending_up;
    return Icons.trending_flat;
  }

  String _getProgressText(UserModel client) {
    if (client.pesoInicial == null || client.peso == null) {
      return 'Sin cambios';
    }

    final diff = (client.peso! - client.pesoInicial!).abs();
    final direction = client.peso! > client.pesoInicial! ? 'aumentado' : 'bajado';

    return '${diff.toStringAsFixed(1)} kg $direction';
  }
}

class _WeightCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool isHighlight;

  const _WeightCard({
    required this.label,
    required this.value,
    required this.unit,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
                color: isHighlight ? AppColors.primary : AppColors.textPrimaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                unit,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Tab de historial de entrenamientos
class _HistorialTab extends ConsumerWidget {
  final UserModel client;

  const _HistorialTab({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(clientHistoryProvider(client.uid));

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppConstants.spacingM),
                Text(
                  'Sin historial de entrenamientos',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return _HistoryCard(history: item);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Text('Error: $error', style: AppTypography.bodyMediumDark),
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
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: GlassCard(
        child: Row(
          children: [
            // Fecha
            Container(
              width: 50,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '${history.fecha.day}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _getMonthName(history.fecha.month),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
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
                  if (history.duracionMinutos != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          size: 14,
                          color: AppColors.textSecondaryDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${history.duracionMinutos} min',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  if (history.notas != null)
                    Text(
                      history.notas!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondaryDark,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            // Estado
            Icon(
              history.completada ? Icons.check_circle : Icons.radio_button_unchecked,
              color: history.completada ? AppColors.success : AppColors.textSecondaryDark,
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return months[month - 1];
  }
}
