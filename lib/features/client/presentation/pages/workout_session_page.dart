import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';

/// Página de sesión de entrenamiento con progreso por serie
class WorkoutSessionPage extends ConsumerStatefulWidget {
  final RoutineModel routine;

  const WorkoutSessionPage({
    super.key,
    required this.routine,
  });

  @override
  ConsumerState<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends ConsumerState<WorkoutSessionPage> {
  // Estado de la sesión
  late DateTime _startTime;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;

  // Progreso de ejercicios
  int _currentExerciseIndex = 0;
  final Map<int, Set<int>> _completedSets = {}; // exerciseIndex -> {setNumbers}

  // Rest timer entre series
  Timer? _restTimer;
  int _restSeconds = 0;
  bool _isResting = false;

  // Notas de la sesión
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _startRestTimer() {
    setState(() {
      _isResting = true;
      _restSeconds = 60; // 60 segundos de descanso
    });

    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restSeconds--;
        if (_restSeconds <= 0) {
          _stopRestTimer();
        }
      });
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSeconds = 0;
    });
  }

  void _toggleSetComplete(int exerciseIndex, int setNumber) {
    setState(() {
      if (!_completedSets.containsKey(exerciseIndex)) {
        _completedSets[exerciseIndex] = {};
      }

      if (_completedSets[exerciseIndex]!.contains(setNumber)) {
        _completedSets[exerciseIndex]!.remove(setNumber);
      } else {
        _completedSets[exerciseIndex]!.add(setNumber);

        // Si completó una serie, iniciar descanso
        if (!_isResting) {
          _startRestTimer();
        }
      }
    });
  }

  bool _isSetComplete(int exerciseIndex, int setNumber) {
    return _completedSets[exerciseIndex]?.contains(setNumber) ?? false;
  }

  int _getCompletedSetsCount(int exerciseIndex) {
    return _completedSets[exerciseIndex]?.length ?? 0;
  }

  void _completeAllSets(int exerciseIndex, int totalSets) {
    setState(() {
      if (!_completedSets.containsKey(exerciseIndex)) {
        _completedSets[exerciseIndex] = {};
      }

      // Si ya están todas completas, desmarcar todas
      if (_completedSets[exerciseIndex]!.length == totalSets) {
        _completedSets[exerciseIndex]!.clear();
      } else {
        // Completar todas las series
        for (int i = 1; i <= totalSets; i++) {
          _completedSets[exerciseIndex]!.add(i);
        }
      }
    });
  }

  int _getTotalCompletedSets() {
    int total = 0;
    for (var sets in _completedSets.values) {
      total += sets.length;
    }
    return total;
  }

  int _getTotalSets() {
    int total = 0;
    for (var exercise in widget.routine.ejercicios) {
      total += exercise.sets;
    }
    return total;
  }

  double _getOverallProgress() {
    final totalSets = _getTotalSets();
    if (totalSets == 0) return 0;
    return _getTotalCompletedSets() / totalSets;
  }

  Future<void> _finishWorkout() async {
    // Confirmar si quiere terminar
    final result = await showDialog<_FinishWorkoutResult>(
      context: context,
      builder: (context) => _FinishWorkoutDialog(
        completedSets: _getTotalCompletedSets(),
        totalSets: _getTotalSets(),
      ),
    );

    if (result != null && result.shouldFinish && mounted) {
      // Guardar en historial
      final user = ref.read(userModelProvider).valueOrNull;
      if (user != null) {
        final history = TrainingHistory(
          id: '',
          clienteId: user.uid,
          rutinaId: widget.routine.id,
          rutinaNombre: widget.routine.nombre,
          fecha: _startTime,
          duracionMinutos: _elapsedSeconds ~/ 60,
          notas: result.notes,
          completada: _getOverallProgress() >= 0.7, // 70% completado
        );

        try {
          final firebaseService = ref.read(firebaseServiceProvider);

          // Guardar historial de entrenamiento
          await firebaseService.addTrainingHistory(history);

          // Actualizar racha de días
          await firebaseService.updateStreak(user.uid);

          // Limpiar la rutina asignada para que el coach pueda asignar una nueva
          await firebaseService.clearAssignedRoutine(user.uid);

          // Volver al home
          if (mounted) {
            context.go('/client/home');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al guardar: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildProgressBar(),
                if (_isResting) _buildRestTimer(),
                Expanded(
                  child: _buildExercisesList(),
                ),
                _buildBottomControls(),
              ],
            ),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          // Botón atrás
          IconButton(
            onPressed: () async {
              final shouldLeave = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surfaceDark,
                  title: Text(
                    '¿Salir del entrenamiento?',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  content: Text(
                    'Tu progreso no se guardará',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );

              if (shouldLeave == true && mounted) {
                context.pop();
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.glassDark,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.glassBorder,
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimaryDark,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          // Nombre de rutina
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.routine.nombre,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.routine.ejercicios.length} ejercicios',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          // Timer
          GlassCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPaused ? Icons.pause : Icons.timer,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(_elapsedSeconds),
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Botón pausa/play
          IconButton(
            onPressed: _togglePause,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                ),
              ),
              child: Icon(
                _isPaused ? Icons.play_arrow : Icons.pause,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _getOverallProgress();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso General',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              Text(
                '${_getTotalCompletedSets()} / ${_getTotalSets()} series',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.glassDark,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress < 0.3
                    ? AppColors.error
                    : progress < 0.7
                        ? AppColors.warning
                        : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestTimer() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingM),
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withValues(alpha: 0.3),
            AppColors.info.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer,
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiempo de descanso',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.info,
                  ),
                ),
                Text(
                  _formatTime(_restSeconds),
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: _stopRestTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
              child: const Text('Omitir'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    // Si la rutina tiene sets definidos, mostrar por sets
    if (widget.routine.sets != null && widget.routine.sets!.isNotEmpty) {
      return _buildSetsView();
    }

    // Si no, mostrar lista plana de ejercicios
    return _buildFlatExercisesView();
  }

  Widget _buildSetsView() {
    final sets = widget.routine.sets!;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar número de columnas según el ancho disponible
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2;
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          itemCount: sets.length,
          itemBuilder: (context, setIndex) {
            final exerciseSet = sets[setIndex];

            // Calculate exercises with their global indices
            final exercisesWithIndices = <Map<String, dynamic>>[];
            int globalIndex = 0;
            for (int i = 0; i < setIndex; i++) {
              globalIndex += sets[i].ejercicios.length;
            }
            for (int i = 0; i < exerciseSet.ejercicios.length; i++) {
              exercisesWithIndices.add({
                'exercise': exerciseSet.ejercicios[i],
                'globalIndex': globalIndex + i,
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Set header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingM,
                          vertical: AppConstants.spacingS,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              exerciseSet.nombre,
                              style: AppTypography.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: Text(
                          '${exerciseSet.ejercicios.length} ejercicios',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Exercises in this set - responsive grid or list
                if (crossAxisCount == 1)
                  // En móvil, mostrar lista
                  ...exercisesWithIndices.map((item) {
                    final exercise = item['exercise'] as RoutineExercise;
                    final gIndex = item['globalIndex'] as int;
                    final completedSets = _getCompletedSetsCount(gIndex);
                    final isCurrent = gIndex == _currentExerciseIndex;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                      child: _ExerciseWorkoutCard(
                        exercise: exercise,
                        exerciseIndex: gIndex,
                        exerciseNumber: gIndex + 1,
                        completedSets: completedSets,
                        isCurrent: isCurrent,
                        onSetToggle: (setNumber) => _toggleSetComplete(gIndex, setNumber),
                        isSetComplete: (setNumber) => _isSetComplete(gIndex, setNumber),
                        onTap: () {
                          setState(() {
                            _currentExerciseIndex = gIndex;
                          });
                        },
                        onHelpRequest: () => _requestCoachHelp(gIndex),
                        onCompleteAllSets: () => _completeAllSets(gIndex, exercise.sets),
                      ),
                    );
                  })
                else
                  // En pantallas grandes, mostrar grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: AppConstants.spacingM,
                      mainAxisSpacing: AppConstants.spacingM,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: exercisesWithIndices.length,
                    itemBuilder: (context, i) {
                      final exercise = exercisesWithIndices[i]['exercise'] as RoutineExercise;
                      final gIndex = exercisesWithIndices[i]['globalIndex'] as int;
                      final completedSets = _getCompletedSetsCount(gIndex);
                      final isCurrent = gIndex == _currentExerciseIndex;

                      return _ExerciseWorkoutCard(
                        exercise: exercise,
                        exerciseIndex: gIndex,
                        exerciseNumber: gIndex + 1,
                        completedSets: completedSets,
                        isCurrent: isCurrent,
                        onSetToggle: (setNumber) => _toggleSetComplete(gIndex, setNumber),
                        isSetComplete: (setNumber) => _isSetComplete(gIndex, setNumber),
                        onTap: () {
                          setState(() {
                            _currentExerciseIndex = gIndex;
                          });
                        },
                        onHelpRequest: () => _requestCoachHelp(gIndex),
                        onCompleteAllSets: () => _completeAllSets(gIndex, exercise.sets),
                      );
                    },
                  ),
                if (setIndex < sets.length - 1)
                  const Divider(
                    color: AppColors.glassBorder,
                    height: 32,
                    thickness: 2,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFlatExercisesView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar número de columnas según el ancho disponible
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2;
        }

        if (crossAxisCount == 1) {
          // En móvil, usar ListView normal
          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            itemCount: widget.routine.ejercicios.length,
            itemBuilder: (context, index) {
              final exercise = widget.routine.ejercicios[index];
              final completedSets = _getCompletedSetsCount(index);
              final isCurrent = index == _currentExerciseIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                child: _ExerciseWorkoutCard(
                  exercise: exercise,
                  exerciseIndex: index,
                  exerciseNumber: index + 1,
                  completedSets: completedSets,
                  isCurrent: isCurrent,
                  onSetToggle: (setNumber) => _toggleSetComplete(index, setNumber),
                  isSetComplete: (setNumber) => _isSetComplete(index, setNumber),
                  onTap: () {
                    setState(() {
                      _currentExerciseIndex = index;
                    });
                  },
                  onHelpRequest: () => _requestCoachHelp(index),
                  onCompleteAllSets: () => _completeAllSets(index, exercise.sets),
                ),
              );
            },
          );
        }

        // En pantallas grandes, usar GridView
        return GridView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppConstants.spacingM,
            mainAxisSpacing: AppConstants.spacingM,
            childAspectRatio: 0.65, // Ajustar proporción de las tarjetas
          ),
          itemCount: widget.routine.ejercicios.length,
          itemBuilder: (context, index) {
            final exercise = widget.routine.ejercicios[index];
            final completedSets = _getCompletedSetsCount(index);
            final isCurrent = index == _currentExerciseIndex;

            return _ExerciseWorkoutCard(
              exercise: exercise,
              exerciseIndex: index,
              exerciseNumber: index + 1,
              completedSets: completedSets,
              isCurrent: isCurrent,
              onSetToggle: (setNumber) => _toggleSetComplete(index, setNumber),
              isSetComplete: (setNumber) => _isSetComplete(index, setNumber),
              onTap: () {
                setState(() {
                  _currentExerciseIndex = index;
                });
              },
              onHelpRequest: () => _requestCoachHelp(index),
              onCompleteAllSets: () => _completeAllSets(index, exercise.sets),
            );
          },
        );
      },
    );
  }

  Future<void> _requestCoachHelp(int exerciseIndex) async {
    // Get exercise info
    final exercise = widget.routine.ejercicios.length > exerciseIndex
        ? widget.routine.ejercicios[exerciseIndex]
        : _getExerciseFromSets(exerciseIndex);

    if (exercise == null) return;

    // Show confirmation dialog
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.support_agent,
              color: AppColors.warning,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '¿Solicitar ayuda?',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Tu entrenador recibirá una notificación de que necesitas ayuda con: ${exercise.machineName}',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: AppColors.backgroundDark,
            ),
            child: const Text('Solicitar'),
          ),
        ],
      ),
    );

    if (shouldRequest == true && mounted) {
      try {
        final user = ref.read(userModelProvider).valueOrNull;
        final firebaseService = ref.read(firebaseServiceProvider);

        // Intentar obtener el entrenador de la rutina, si no hay, buscar cualquier entrenador
        String? trainerId = widget.routine.creadoPor;

        if (trainerId == null || trainerId.isEmpty) {
          // Buscar el primer entrenador disponible
          final trainers = await firebaseService.getTrainers();
          if (trainers.isNotEmpty) {
            trainerId = trainers.first.uid;
          }
        }

        if (user != null && trainerId != null && trainerId.isNotEmpty) {
          // Enviar notificación al entrenador
          await firebaseService.sendCoachHelpRequest(
            trainerId: trainerId,
            clientId: user.uid,
            clientName: user.nombre ?? 'Cliente',
            exerciseName: exercise.machineName,
            routineName: widget.routine.nombre,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solicitud enviada a tu entrenador'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No hay entrenadores disponibles'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
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
      }
    }
  }

  RoutineExercise? _getExerciseFromSets(int globalIndex) {
    if (widget.routine.sets == null) return null;

    int currentIndex = 0;
    for (final set in widget.routine.sets!) {
      for (final exercise in set.ejercicios) {
        if (currentIndex == globalIndex) {
          return exercise;
        }
        currentIndex++;
      }
    }
    return null;
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          top: BorderSide(
            color: AppColors.glassBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _finishWorkout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            icon: const Icon(Icons.check_circle),
            label: const Text(
              'Finalizar Entrenamiento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget de card de ejercicio en sesión
class _ExerciseWorkoutCard extends StatelessWidget {
  final RoutineExercise exercise;
  final int exerciseIndex;
  final int exerciseNumber;
  final int completedSets;
  final bool isCurrent;
  final Function(int setNumber) onSetToggle;
  final bool Function(int setNumber) isSetComplete;
  final VoidCallback onTap;
  final VoidCallback onHelpRequest;
  final VoidCallback onCompleteAllSets;

  const _ExerciseWorkoutCard({
    required this.exercise,
    required this.exerciseIndex,
    required this.exerciseNumber,
    required this.completedSets,
    required this.isCurrent,
    required this.onSetToggle,
    required this.isSetComplete,
    required this.onTap,
    required this.onHelpRequest,
    required this.onCompleteAllSets,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = completedSets == exercise.sets;

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderColor: isCurrent
          ? AppColors.primary
          : isComplete
              ? AppColors.success
              : AppColors.glassBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Image
          if (exercise.machineImageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.radiusM),
                topRight: Radius.circular(AppConstants.radiusM),
              ),
              child: Stack(
                children: [
                  Image.network(
                    exercise.machineImageUrl!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 140,
                        color: AppColors.glassDark,
                        child: const Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      );
                    },
                  ),
                  // Overlay gradient
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.backgroundDark.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Número de ejercicio overlay
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        border: Border.all(
                          color: isComplete
                              ? AppColors.success
                              : isCurrent
                                  ? AppColors.primary
                                  : AppColors.glassBorder,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isComplete
                            ? const Icon(
                                Icons.check,
                                color: AppColors.success,
                                size: 20,
                              )
                            : Text(
                                '$exerciseNumber',
                                style: AppTypography.titleMedium.copyWith(
                                  color: isCurrent
                                      ? AppColors.primary
                                      : AppColors.textSecondaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                  // Progress indicator overlay - clickeable para completar todas las series
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onCompleteAllSets,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: completedSets / exercise.sets,
                                strokeWidth: 3,
                                backgroundColor: AppColors.glassDark,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isComplete ? AppColors.success : AppColors.primary,
                                ),
                              ),
                              if (isComplete)
                                const Icon(
                                  Icons.check,
                                  color: AppColors.success,
                                  size: 16,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Machine name overlay
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            exercise.machineName,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                const Shadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status text
                Row(
                  children: [
                    Icon(
                      isComplete
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: isComplete
                          ? AppColors.success
                          : AppColors.textSecondaryDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$completedSets / ${exercise.sets} series completadas',
                      style: AppTypography.labelMedium.copyWith(
                        color: isComplete
                            ? AppColors.success
                            : AppColors.textSecondaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                if (exercise.notas != null && exercise.notas!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingS),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingS),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exercise.notas!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.spacingM),
                const Divider(color: AppColors.glassBorder, height: 1),
                const SizedBox(height: AppConstants.spacingM),

                // Sets grid
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(exercise.sets, (index) {
                    final setNumber = index + 1;
                    final isChecked = isSetComplete(setNumber);

                    return _SetCheckbox(
                      setNumber: setNumber,
                      reps: exercise.reps,
                      isChecked: isChecked,
                      onToggle: () => onSetToggle(setNumber),
                    );
                  }),
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Help button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onHelpRequest,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(
                        color: AppColors.warning,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      ),
                    ),
                    icon: const Icon(Icons.support_agent),
                    label: const Text(
                      'Solicitar Ayuda al Coach',
                      style: TextStyle(fontWeight: FontWeight.w600),
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
}

// Checkbox de serie
class _SetCheckbox extends StatelessWidget {
  final int setNumber;
  final int reps;
  final bool isChecked;
  final VoidCallback onToggle;

  const _SetCheckbox({
    required this.setNumber,
    required this.reps,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isChecked
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.glassDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          border: Border.all(
            color: isChecked ? AppColors.success : AppColors.glassBorder,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'S$setNumber',
                  style: TextStyle(
                    color: isChecked
                        ? AppColors.success
                        : AppColors.textSecondaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  isChecked ? Icons.check_circle : Icons.circle_outlined,
                  color:
                      isChecked ? AppColors.success : AppColors.textSecondaryDark,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '$reps reps',
              style: TextStyle(
                color: isChecked
                    ? AppColors.textPrimaryDark
                    : AppColors.textSecondaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Resultado del diálogo de finalizar entrenamiento
class _FinishWorkoutResult {
  final bool shouldFinish;
  final String? notes;

  _FinishWorkoutResult({required this.shouldFinish, this.notes});
}

// Diálogo de finalizar entrenamiento
class _FinishWorkoutDialog extends StatefulWidget {
  final int completedSets;
  final int totalSets;

  const _FinishWorkoutDialog({
    required this.completedSets,
    required this.totalSets,
  });

  @override
  State<_FinishWorkoutDialog> createState() => _FinishWorkoutDialogState();
}

class _FinishWorkoutDialogState extends State<_FinishWorkoutDialog> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.completedSets / widget.totalSets;

    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      title: Row(
        children: [
          Icon(
            progress >= 0.7 ? Icons.celebration : Icons.info_outline,
            color: progress >= 0.7 ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Text(
            '¿Finalizar entrenamiento?',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progreso
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: AppColors.glassDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${widget.completedSets}',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Series\ncompletadas',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.glassBorder,
                ),
                Column(
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: AppTypography.headlineMedium.copyWith(
                        color: progress >= 0.7
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Progreso',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          // Notas opcionales
          Text(
            'Notas (opcional)',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
            decoration: InputDecoration(
              hintText: '¿Cómo te sentiste?',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              filled: true,
              fillColor: AppColors.glassDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: const BorderSide(color: AppColors.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: const BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            _FinishWorkoutResult(shouldFinish: false),
          ),
          child: const Text('Continuar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            _FinishWorkoutResult(
              shouldFinish: true,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.backgroundDark,
          ),
          child: const Text('Finalizar'),
        ),
      ],
    );
  }
}
