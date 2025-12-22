import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import 'workout_session_page.dart';

/// Home del cliente
/// Muestra la rutina asignada del día o un mensaje si no tiene rutina
class ClientHomePage extends ConsumerWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);
    final todayRoutineAsync = ref.watch(todayRoutineProvider);
    final readyOrders = ref.watch(currentUserReadyOrdersProvider);
    final unreadCount = ref.watch(unreadAnnouncementsCountProvider).value ?? 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(context, userAsync.valueOrNull, unreadCount),
              SliverToBoxAdapter(
                child: userAsync.when(
                  data: (user) {
                    if (user == null) {
                      return const _LoadingState();
                    }
                    return _buildContent(context, ref, user, todayRoutineAsync);
                  },
                  loading: () => const _LoadingState(),
                  error: (error, _) => _ErrorState(error: error.toString()),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          // Notification banner for ready orders
          if (readyOrders.isNotEmpty)
            _OrderReadyNotification(orders: readyOrders),
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
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.backgroundDark,
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, UserModel? user, int unreadCount) {
    // Verificar si es un usuario de prueba (entrenador en modo cliente)
    final isTestUser = user?.uid.contains('_test_client') ?? false;

    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      backgroundColor: Colors.transparent,
      actions: [
        // Botón para volver al modo entrenador (solo para usuarios de prueba)
        if (isTestUser)
          _BackToTrainerButton(),
        // Icono de notificaciones con badge
        Padding(
          padding: const EdgeInsets.only(right: AppConstants.spacingM, top: 8),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimaryDark),
                onPressed: () {
                  context.push('/client/notifications');
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
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
          child: Row(
            children: [
              // Avatar
              _buildAvatar(user),
              const SizedBox(width: AppConstants.spacingM),
              // Saludo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user?.nombre ?? 'Usuario',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Racha
              if (user != null && user.rachasDias > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.rachasDias}',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  Widget _buildAvatar(UserModel? user) {
    final hasValidPhoto = user?.photoUrl != null && user?.photoUrl!.isNotEmpty == true;
    const double avatarSize = 56.0;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasValidPhoto
          ? CachedNetworkImage(
              imageUrl: user?.photoUrl ?? '',
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: Text(
                  (user?.nombre ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: Text(
                  (user?.nombre ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                (user?.nombre ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    AsyncValue<RoutineModel?> todayRoutineAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Día actual
          _buildDayCard(),
          const SizedBox(height: AppConstants.spacingL),

          // Rutina del día o mensaje
          todayRoutineAsync.when(
            data: (routine) {
              if (routine != null) {
                return _buildTodayRoutine(context, routine);
              } else if (user.rutinaAsignadaId != null) {
                return _buildAssignedRoutineCard(context, ref, user);
              } else {
                return _buildNoRoutineCard();
              }
            },
            loading: () => const _RoutineLoadingCard(),
            error: (_, _) => _buildNoRoutineCard(),
          ),

          const SizedBox(height: AppConstants.spacingL),

          // Resumen de la semana
          _buildWeeklyOverview(ref),

          const SizedBox(height: AppConstants.spacingL),

          // Stats rápidas
          _buildQuickStats(user),
        ],
      ),
    );
  }

  Widget _buildDayCard() {
    final now = DateTime.now();
    final dayNames = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    final monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Column(
              children: [
                Text(
                  '${now.day}',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  monthNames[now.month - 1].substring(0, 3).toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayNames[now.weekday - 1],
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Hoy',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayRoutine(BuildContext context, RoutineModel routine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tu rutina de hoy',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        GlassCard(
          onTap: () {
            // Navegar a detalle de rutina
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.nombre,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            _RoutineChip(
                              label: routine.parteDelCuerpo.displayName,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 8),
                            _RoutineChip(
                              label: routine.dificultad.displayName,
                              color: _getDifficultyColor(routine.dificultad),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondaryDark,
                  ),
                ],
              ),
              const Divider(color: AppColors.glassBorder, height: 24),
              // Lista de ejercicios preview
              Text(
                '${routine.ejercicios.length} ejercicios',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 8),
              ...routine.ejercicios.take(3).map((ejercicio) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ejercicio.machineName,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                        ),
                        Text(
                          '${ejercicio.sets}x${ejercicio.reps}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  )),
              if (routine.ejercicios.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${routine.ejercicios.length - 3} más',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              const SizedBox(height: AppConstants.spacingM),
              // Botón comenzar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutSessionPage(routine: routine),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.backgroundDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                  child: const Text('Comenzar Rutina'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssignedRoutineCard(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tu rutina',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        GlassCard(
          child: Column(
            children: [
              const Icon(
                Icons.fitness_center,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'Tienes una rutina asignada',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pero hoy es día de descanso',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              OutlinedButton(
                onPressed: () {
                  // Ver rutina completa
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text('Ver mi rutina semanal'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoRoutineCard() {
    return Consumer(
      builder: (context, ref, _) {
        return GlassCard(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center_outlined,
                  size: 48,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),
              Text(
                'Sin rutina asignada',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
                child: Text(
                  '¿Qué parte del cuerpo quieres entrenar hoy?',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),
              ElevatedButton.icon(
                onPressed: () => _showRoutineRequestDialog(context, ref),
                icon: const Icon(Icons.add_task),
                label: const Text('Solicitar Rutina al Coach'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingL,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRoutineRequestDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _RoutineRequestDialog(ref: ref),
    );
  }

  Widget _buildWeeklyOverview(WidgetRef ref) {
    final weeklyRoutineAsync = ref.watch(currentUserWeeklyRoutineProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Esta semana',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        GlassCard(
          child: weeklyRoutineAsync.when(
            data: (weekly) {
              if (weekly == null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                  child: Center(
                    child: Text(
                      'Sin rutina semanal asignada',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                );
              }

              final dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
              final today = DateTime.now().weekday;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final dayNumber = index + 1;
                  final hasRoutine = weekly.getRutinaDelDia(dayNumber) != null;
                  final isToday = dayNumber == today;
                  final isPast = dayNumber < today;

                  return _DayIndicator(
                    day: dayNames[index],
                    hasRoutine: hasRoutine,
                    isToday: isToday,
                    isPast: isPast,
                  );
                }),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, _) => Center(
              child: Text(
                'Error al cargar',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(UserModel user) {
    // Calcular IMC si hay peso y altura disponibles
    double? imc;
    IMCRange? rangoIMC;

    if (user.peso != null && user.altura != null && user.altura! > 0) {
      imc = UserModel.calcularIMC(user.peso!, user.altura!);
      rangoIMC = IMCRange.fromIMC(imc);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tu progreso',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.monitor_weight,
                value: user.peso?.toStringAsFixed(1) ?? '-',
                unit: 'kg',
                label: 'Peso actual',
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: AppConstants.spacingS),
            Expanded(
              child: _StatCard(
                icon: Icons.calculate,
                value: imc?.toStringAsFixed(1) ?? '-',
                label: rangoIMC?.displayName ?? 'IMC',
                color: _getIMCColor(rangoIMC),
              ),
            ),
            const SizedBox(width: AppConstants.spacingS),
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department,
                value: '${user.rachasDias}',
                unit: 'días',
                label: 'Racha',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getDifficultyColor(RoutineDifficulty difficulty) {
    switch (difficulty) {
      case RoutineDifficulty.principiante:
        return AppColors.success;
      case RoutineDifficulty.medio:
        return AppColors.warning;
      case RoutineDifficulty.avanzado:
      case RoutineDifficulty.experto:
        return AppColors.error;
    }
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

// Helper Widgets

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppConstants.spacingXL),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Center(
        child: Column(
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
      ),
    );
  }
}

class _RoutineLoadingCard extends StatelessWidget {
  const _RoutineLoadingCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'Cargando tu rutina...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineChip extends StatelessWidget {
  final String label;
  final Color color;

  const _RoutineChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DayIndicator extends StatelessWidget {
  final String day;
  final bool hasRoutine;
  final bool isToday;
  final bool isPast;

  const _DayIndicator({
    required this.day,
    required this.hasRoutine,
    required this.isToday,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (isToday) {
      bgColor = AppColors.primary;
      textColor = AppColors.backgroundDark;
      borderColor = AppColors.primary;
    } else if (hasRoutine) {
      bgColor = isPast
          ? AppColors.success.withValues(alpha: 0.2)
          : AppColors.primary.withValues(alpha: 0.2);
      textColor = isPast ? AppColors.success : AppColors.primary;
      borderColor = isPast ? AppColors.success : AppColors.primary;
    } else {
      bgColor = Colors.transparent;
      textColor = AppColors.textSecondaryDark;
      borderColor = AppColors.glassBorder;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String? unit;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    this.unit,
    required this.label,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Text(
                  unit!,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ],
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RoutineRequestDialog extends StatefulWidget {
  final WidgetRef ref;

  const _RoutineRequestDialog({required this.ref});

  @override
  State<_RoutineRequestDialog> createState() => _RoutineRequestDialogState();
}

class _RoutineRequestDialogState extends State<_RoutineRequestDialog> {
  RequestedBodyPart? _selectedBodyPart;
  bool _isSubmitting = false;

  Future<void> _submitRequest() async {
    if (_selectedBodyPart == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona qué parte del cuerpo quieres entrenar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final user = widget.ref.read(userModelProvider).value;
      if (user == null) throw Exception('Usuario no encontrado');

      final request = RoutineRequestModel(
        id: '',
        clienteId: user.uid,
        clienteNombre: user.nombre ?? 'Cliente',
        clientePhotoUrl: user.photoUrl,
        trainerId: null, // Por ahora null, cualquier entrenador puede atender
        parteDelCuerpo: _selectedBodyPart!,
        estado: RequestStatus.pendiente,
        fechaSolicitud: DateTime.now(),
      );

      await widget.ref
          .read(firebaseServiceProvider)
          .createRoutineRequest(request);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud enviada al coach exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar solicitud: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    Icons.fitness_center,
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
                        'Solicitar Rutina',
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '¿Qué quieres entrenar hoy?',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondaryDark),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),
            Wrap(
              spacing: AppConstants.spacingS,
              runSpacing: AppConstants.spacingS,
              children: RequestedBodyPart.values.map((bodyPart) {
                final isSelected = _selectedBodyPart == bodyPart;
                return InkWell(
                  onTap: () => setState(() => _selectedBodyPart = bodyPart),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingM,
                      vertical: AppConstants.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.surfaceLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceLight.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bodyPart.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: AppConstants.spacingXS),
                        Text(
                          bodyPart.displayName,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimaryDark,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.spacingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.backgroundDark),
                        ),
                      )
                    : const Text('Enviar Solicitud'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de notificación para pedidos listos
/// Muestra un banner en la parte superior por 10 segundos
class _OrderReadyNotification extends ConsumerStatefulWidget {
  final List<StoreOrderModel> orders;

  const _OrderReadyNotification({required this.orders});

  @override
  ConsumerState<_OrderReadyNotification> createState() => _OrderReadyNotificationState();
}

class _OrderReadyNotificationState extends ConsumerState<_OrderReadyNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto-hide after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _hideNotification();
      }
    });
  }

  void _hideNotification() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  Future<void> _markAsReceived() async {
    try {
      // Marcar todos los pedidos listos como entregados
      for (final order in widget.orders) {
        await ref.read(firebaseServiceProvider).markOrderAsDelivered(order.id);
      }

      // Ocultar la notificación
      _hideNotification();

      // Mostrar mensaje de confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.orders.length > 1
                  ? '${widget.orders.length} pedidos marcados como recibidos'
                  : 'Pedido marcado como recibido',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al marcar pedido: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final orderCount = widget.orders.length;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
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
                                orderCount > 1
                                    ? '¡$orderCount pedidos listos!'
                                    : '¡Tu pedido está listo!',
                                style: AppTypography.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Recógelo en la tienda del gimnasio',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _hideNotification,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _markAsReceived,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: AppConstants.spacingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                        ),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                        label: Text(
                          orderCount > 1 ? 'Marcar como recibidos' : 'Marcar como recibido',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón para volver al modo entrenador
class _BackToTrainerButton extends ConsumerWidget {
  const _BackToTrainerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8),
      child: IconButton(
        icon: const Icon(Icons.admin_panel_settings, color: AppColors.warning),
        tooltip: 'Volver al modo entrenador',
        onPressed: () {
          // Restablecer el ID de usuario activo a null (usuario real)
          ref.read(activeUserIdProvider.notifier).state = null;
          // Navegar al modo entrenador
          context.go('/trainer');
        },
      ),
    );
  }
}
