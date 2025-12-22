import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';

/// Página para crear rutinas semanales
class WeeklyRoutineBuilderPage extends ConsumerStatefulWidget {
  final String? clientId; // Si es null, es una plantilla general

  const WeeklyRoutineBuilderPage({
    super.key,
    this.clientId,
  });

  @override
  ConsumerState<WeeklyRoutineBuilderPage> createState() =>
      _WeeklyRoutineBuilderPageState();
}

class _WeeklyRoutineBuilderPageState
    extends ConsumerState<WeeklyRoutineBuilderPage> {
  final Map<int, String?> _weeklyPlan = {
    1: null, // Lunes
    2: null, // Martes
    3: null, // Miércoles
    4: null, // Jueves
    5: null, // Viernes
    6: null, // Sábado
    7: null, // Domingo
  };

  final Map<int, RoutineModel?> _selectedRoutines = {};
  bool _isLoading = false;

  final List<String> _dayNames = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Rutina Semanal',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isLoading ? null : _saveWeeklyRoutine,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Guardar',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          ListView(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            children: [
              // Instrucciones
              GlassCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Text(
                        'Asigna una rutina a cada día de la semana. Puedes dejar días vacíos para descanso.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Días de la semana
              ...List.generate(7, (index) {
                final dayNumber = index + 1;
                return _DayCard(
                  dayNumber: dayNumber,
                  dayName: _dayNames[index],
                  selectedRoutine: _selectedRoutines[dayNumber],
                  onSelectRoutine: () => _showRoutineSelector(dayNumber),
                  onClear: _weeklyPlan[dayNumber] != null
                      ? () => _clearDay(dayNumber)
                      : null,
                  onDuplicate: _selectedRoutines[dayNumber] != null
                      ? () => _showDuplicateOptions(dayNumber)
                      : null,
                );
              }),

              const SizedBox(height: AppConstants.spacingL),

              // Acciones rápidas
              Text(
                'Acciones Rápidas',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.content_copy,
                      label: 'Copiar día',
                      onTap: _showCopyDaySheet,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.clear_all,
                      label: 'Limpiar todo',
                      onTap: _clearAll,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
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
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.backgroundDark,
          ],
        ),
      ),
    );
  }

  void _showRoutineSelector(int dayNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RoutineSelectorSheet(
        onSelect: (routine) {
          setState(() {
            _weeklyPlan[dayNumber] = routine.id;
            _selectedRoutines[dayNumber] = routine;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _clearDay(int dayNumber) {
    setState(() {
      _weeklyPlan[dayNumber] = null;
      _selectedRoutines[dayNumber] = null;
    });
  }

  void _showDuplicateOptions(int sourceDayNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DuplicateOptionsSheet(
        sourceDayName: _dayNames[sourceDayNumber - 1],
        dayNames: _dayNames,
        onDuplicateTo: (targetDayNumber) {
          setState(() {
            _weeklyPlan[targetDayNumber] = _weeklyPlan[sourceDayNumber];
            _selectedRoutines[targetDayNumber] =
                _selectedRoutines[sourceDayNumber];
          });
          Navigator.pop(context);
        },
        onDuplicateToAll: () {
          setState(() {
            for (int i = 1; i <= 7; i++) {
              _weeklyPlan[i] = _weeklyPlan[sourceDayNumber];
              _selectedRoutines[i] = _selectedRoutines[sourceDayNumber];
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCopyDaySheet() {
    // Encontrar días con rutina asignada
    final daysWithRoutine = _weeklyPlan.entries
        .where((e) => e.value != null)
        .map((e) => e.key)
        .toList();

    if (daysWithRoutine.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay días con rutinas asignadas')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingL),
                Text(
                  'Selecciona el día a copiar',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingM),
                ...daysWithRoutine.map((dayNumber) => ListTile(
                      title: Text(
                        _dayNames[dayNumber - 1],
                        style: AppTypography.bodyLargeDark,
                      ),
                      subtitle: Text(
                        _selectedRoutines[dayNumber]?.nombre ?? '',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showDuplicateOptions(dayNumber);
                      },
                    )),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Limpiar todo', style: AppTypography.titleLargeDark),
        content: Text(
          '¿Estás seguro de eliminar todas las rutinas asignadas?',
          style: AppTypography.bodyMediumDark,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (int i = 1; i <= 7; i++) {
                  _weeklyPlan[i] = null;
                  _selectedRoutines[i] = null;
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWeeklyRoutine() async {
    // Verificar que hay al menos una rutina
    final hasRoutines = _weeklyPlan.values.any((v) => v != null);
    if (!hasRoutines) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asigna al menos una rutina')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final weeklyRoutine = WeeklyRoutine(
        id: '',
        clienteId: widget.clientId ?? '',
        lunes: _weeklyPlan[1],
        martes: _weeklyPlan[2],
        miercoles: _weeklyPlan[3],
        jueves: _weeklyPlan[4],
        viernes: _weeklyPlan[5],
        sabado: _weeklyPlan[6],
        domingo: _weeklyPlan[7],
      );

      await ref.read(firebaseServiceProvider).saveWeeklyRoutine(weeklyRoutine);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rutina semanal guardada')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Card de día de la semana
class _DayCard extends StatelessWidget {
  final int dayNumber;
  final String dayName;
  final RoutineModel? selectedRoutine;
  final VoidCallback onSelectRoutine;
  final VoidCallback? onClear;
  final VoidCallback? onDuplicate;

  const _DayCard({
    required this.dayNumber,
    required this.dayName,
    required this.selectedRoutine,
    required this.onSelectRoutine,
    this.onClear,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final hasRoutine = selectedRoutine != null;
    final isWeekend = dayNumber >= 6;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: GlassCard(
        onTap: onSelectRoutine,
        child: Row(
          children: [
            // Indicador de día
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: hasRoutine
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : isWeekend
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : AppColors.glassDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName.substring(0, 3).toUpperCase(),
                    style: TextStyle(
                      color: hasRoutine
                          ? AppColors.primary
                          : AppColors.textSecondaryDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
                    dayName,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasRoutine) ...[
                    Text(
                      selectedRoutine!.nombre,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 12,
                          color: AppColors.textSecondaryDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${selectedRoutine!.ejercicioCount} ejercicios',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.timer,
                          size: 12,
                          color: AppColors.textSecondaryDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          selectedRoutine!.duracionTexto,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      isWeekend ? 'Descanso' : 'Sin asignar',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
            // Acciones
            if (hasRoutine) ...[
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                color: AppColors.info,
                onPressed: onDuplicate,
                tooltip: 'Duplicar',
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.error,
                onPressed: onClear,
                tooltip: 'Quitar',
              ),
            ] else
              const Icon(
                Icons.add_circle_outline,
                color: AppColors.textSecondaryDark,
              ),
          ],
        ),
      ),
    );
  }
}

/// Botón de acción rápida
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sheet para seleccionar rutina
class _RoutineSelectorSheet extends ConsumerWidget {
  final Function(RoutineModel) onSelect;

  const _RoutineSelectorSheet({required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.glassBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingL),
                        Text(
                          'Seleccionar Rutina',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: routinesAsync.when(
                      data: (routines) {
                        if (routines.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  size: 64,
                                  color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: AppConstants.spacingM),
                                Text(
                                  'No hay rutinas disponibles',
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: AppColors.textSecondaryDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                          ),
                          itemCount: routines.length,
                          itemBuilder: (context, index) {
                            final routine = routines[index];
                            return _RoutineListItem(
                              routine: routine,
                              onTap: () => onSelect(routine),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                      error: (error, _) => Center(
                        child: Text('Error: $error'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoutineListItem extends StatelessWidget {
  final RoutineModel routine;
  final VoidCallback onTap;

  const _RoutineListItem({
    required this.routine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: _getDifficultyColor(routine.dificultad),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.nombre,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.fitness_center,
                        label: routine.parteDelCuerpo.displayName,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.timer,
                        label: routine.duracionTexto,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.list,
                        label: '${routine.ejercicioCount}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.add_circle,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(RoutineDifficulty difficulty) {
    switch (difficulty) {
      case RoutineDifficulty.principiante:
        return AppColors.success;
      case RoutineDifficulty.medio:
        return AppColors.info;
      case RoutineDifficulty.avanzado:
        return AppColors.warning;
      case RoutineDifficulty.experto:
        return AppColors.error;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondaryDark),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }
}

/// Sheet de opciones de duplicación
class _DuplicateOptionsSheet extends StatelessWidget {
  final String sourceDayName;
  final List<String> dayNames;
  final Function(int) onDuplicateTo;
  final VoidCallback onDuplicateToAll;

  const _DuplicateOptionsSheet({
    required this.sourceDayName,
    required this.dayNames,
    required this.onDuplicateTo,
    required this.onDuplicateToAll,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),
              Text(
                'Duplicar $sourceDayName',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Opción de duplicar a toda la semana
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'Duplicar a toda la semana',
                  style: AppTypography.bodyLargeDark,
                ),
                subtitle: Text(
                  'Aplicar esta rutina a todos los días',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                onTap: onDuplicateToAll,
              ),
              const Divider(color: AppColors.glassBorder),

              // Lista de días
              ...List.generate(7, (index) {
                final dayNumber = index + 1;
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.glassDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        dayNames[index].substring(0, 3),
                        style: TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    dayNames[index],
                    style: AppTypography.bodyLargeDark,
                  ),
                  onTap: () => onDuplicateTo(dayNumber),
                );
              }),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
