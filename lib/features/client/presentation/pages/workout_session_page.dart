import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../routines/data/exercises_data.dart';

/// Página de sesión de entrenamiento con progreso por serie
class WorkoutSessionPage extends ConsumerStatefulWidget {
  final RoutineModel routine;
  final String? assignmentId;

  const WorkoutSessionPage({
    super.key,
    required this.routine,
    this.assignmentId,
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
    // Detener timers antes de cualquier cosa
    _timer?.cancel();
    _restTimer?.cancel();

    // Confirmar si quiere terminar
    final result = await showDialog<_FinishWorkoutResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _FinishWorkoutDialog(
        completedSets: _getTotalCompletedSets(),
        totalSets: _getTotalSets(),
      ),
    );

    // Si cancela, reiniciar el timer
    if (result == null || !result.shouldFinish) {
      _startTimer();
      return;
    }

    // Usuario confirmó finalizar - navegar inmediatamente y guardar en background
    if (!mounted) return;

    // Capturar datos necesarios antes de navegar
    final user = ref.read(userModelProvider).valueOrNull;
    final firebaseService = ref.read(firebaseServiceProvider);
    final notes = result.notes;
    final progress = _getOverallProgress();
    final duration = _elapsedSeconds ~/ 60;
    final assignmentId = widget.assignmentId;
    final routineId = widget.routine.id;
    final routineName = widget.routine.nombre;
    final startTime = _startTime;

    // Navegar primero - esto es crítico para la UX
    // Usar Navigator.pop() porque entramos con Navigator.push()
    if (mounted) {
      Navigator.of(context).pop();
    }

    // Guardar datos en background (no bloquea la UI)
    _saveWorkoutDataInBackground(
      user: user,
      firebaseService: firebaseService,
      notes: notes,
      progress: progress,
      duration: duration,
      assignmentId: assignmentId,
      routineId: routineId,
      routineName: routineName,
      startTime: startTime,
    );
  }

  /// Guarda los datos del entrenamiento en background sin bloquear la navegación
  Future<void> _saveWorkoutDataInBackground({
    required UserModel? user,
    required dynamic firebaseService,
    required String? notes,
    required double progress,
    required int duration,
    required String? assignmentId,
    required String routineId,
    required String routineName,
    required DateTime startTime,
  }) async {
    if (user == null) return;

    try {
      final history = TrainingHistory(
        id: '',
        clienteId: user.uid,
        rutinaId: routineId,
        rutinaNombre: routineName,
        fecha: startTime,
        duracionMinutos: duration,
        notas: notes,
        completada: progress >= 0.7,
      );

      // Guardar historial de entrenamiento
      await firebaseService.addTrainingHistory(history);

      // Actualizar racha de días
      await firebaseService.updateStreak(user.uid);

      // Si hay una rutina asignada, marcarla como completada
      if (assignmentId != null && assignmentId.isNotEmpty) {
        await firebaseService.completeAssignedRoutine(assignmentId);
      }

      // Limpiar la rutina asignada
      await firebaseService.clearAssignedRoutine(user.uid);
    } catch (e) {
      // Log error silently - el usuario ya navegó
      debugPrint('Error guardando entrenamiento: $e');
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
                Navigator.of(context).pop();
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
                  // En móvil, mostrar lista horizontal
                  SizedBox(
                    height: 480, // Altura fija para la lista horizontal
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: exercisesWithIndices.length,
                      itemBuilder: (context, i) {
                        final exercise = exercisesWithIndices[i]['exercise'] as RoutineExercise;
                        final gIndex = exercisesWithIndices[i]['globalIndex'] as int;
                        final completedSets = _getCompletedSetsCount(gIndex);
                        final isCurrent = gIndex == _currentExerciseIndex;
                        final screenWidth = MediaQuery.of(context).size.width;
                        final cardWidth = screenWidth * 0.85;

                        return Container(
                          width: cardWidth,
                          margin: EdgeInsets.only(
                            right: i < exercisesWithIndices.length - 1
                                ? AppConstants.spacingM
                                : 0,
                          ),
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
                      },
                    ),
                  )
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
          // En móvil, usar ListView horizontal con tarjetas grandes
          return _buildMobileHorizontalView();
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

  /// Vista horizontal optimizada para móvil
  Widget _buildMobileHorizontalView() {
    final exercises = widget.routine.ejercicios;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85; // 85% del ancho de pantalla

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final completedSets = _getCompletedSetsCount(index);
        final isCurrent = index == _currentExerciseIndex;

        return Container(
          width: cardWidth,
          margin: EdgeInsets.only(
            right: index < exercises.length - 1 ? AppConstants.spacingM : 0,
          ),
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
        child: Row(
          children: [
            // Botón de ayuda al coach (solo icono)
            SizedBox(
              width: 56,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _requestCoachHelp(_currentExerciseIndex),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                  foregroundColor: AppColors.warning,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    side: const BorderSide(
                      color: AppColors.warning,
                      width: 2,
                    ),
                  ),
                  elevation: 0,
                ),
                child: const Icon(
                  Icons.support_agent,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            // Botón de finalizar entrenamiento
            Expanded(
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
          ],
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

    // Obtener imagen: primero del ejercicio, luego del mapeo de máquinas
    String? imageUrl = exercise.machineImageUrl?.isNotEmpty == true
        ? exercise.machineImageUrl
        : ExercisesData.getImageForMachine(exercise.machineId) ??
          ExercisesData.getImageForMachine(exercise.machineName);

    // Obtener ejercicio completo para las instrucciones
    final exerciseData = ExercisesData.getExerciseForMachine(exercise.machineId) ??
        ExercisesData.getExerciseForMachine(exercise.machineName);

    // Obtener nombre del ejercicio: del ExerciseModel o del machineName
    final exerciseName = exerciseData?.nombre ?? exercise.machineName;

    // Fallback URL para imágenes cuando no hay imagen disponible
    const fallbackImageUrl = 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&q=80';

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
          // Exercise Image - SIEMPRE se muestra
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppConstants.radiusM),
              topRight: Radius.circular(AppConstants.radiusM),
            ),
            child: Stack(
              children: [
                // Imagen del ejercicio
                imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('assets/')
                    ? Image.asset(
                        imageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            fallbackImageUrl,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          );
                        },
                      )
                    : Image.network(
                        imageUrl ?? fallbackImageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
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
                        AppColors.backgroundDark.withValues(alpha: 0.8),
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
                // Nombre del ejercicio overlay - SIEMPRE se muestra
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    exerciseName,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
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

                  // Instrucciones del ejercicio (reemplaza el botón de ayuda)
                  if (exerciseData?.instrucciones != null && exerciseData!.instrucciones!.isNotEmpty)
                    Expanded(
                      child: _buildInstructionsSection(exerciseData),
                    )
                  else if (exercise.notas != null && exercise.notas!.trim().isNotEmpty)
                    Expanded(
                      child: _buildNotesSection(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder para cuando no hay imagen
  Widget _buildImagePlaceholder() {
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
  }

  /// Sección de instrucciones del ejercicio
  Widget _buildInstructionsSection(ExerciseModel exerciseData) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingS),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Instrucciones',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: exerciseData.instrucciones!.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondaryDark,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de notas personalizadas
  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingS),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Notas',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                exercise.notas!,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
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
