import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import 'routine_builder_page.dart';

/// Página para asignar rutinas a un cliente
class AssignRoutinePage extends ConsumerStatefulWidget {
  final UserModel client;
  final String? requestId; // ID de la solicitud de rutina si viene desde notificaciones
  final RequestedBodyPart? suggestedBodyPart; // Parte del cuerpo sugerida

  const AssignRoutinePage({
    super.key,
    required this.client,
    this.requestId,
    this.suggestedBodyPart,
  });

  @override
  ConsumerState<AssignRoutinePage> createState() => _AssignRoutinePageState();
}

class _AssignRoutinePageState extends ConsumerState<AssignRoutinePage> {
  RoutineBodyPart? _selectedBodyPart;
  RoutineDifficulty? _selectedDifficulty;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Si viene una sugerencia de parte del cuerpo, pre-seleccionarla y avanzar al paso 2
    if (widget.suggestedBodyPart != null) {
      _selectedBodyPart = _mapRequestedBodyPartToRoutineBodyPart(widget.suggestedBodyPart!);
      _currentStep = 1; // Saltar directamente a la selección de rutina
    }
  }

  // Mapear RequestedBodyPart a RoutineBodyPart
  RoutineBodyPart _mapRequestedBodyPartToRoutineBodyPart(RequestedBodyPart requested) {
    switch (requested) {
      case RequestedBodyPart.pierna:
        return RoutineBodyPart.pierna;
      case RequestedBodyPart.pecho:
        return RoutineBodyPart.pecho;
      case RequestedBodyPart.espalda:
        return RoutineBodyPart.espalda;
      case RequestedBodyPart.hombro:
        return RoutineBodyPart.hombro;
      case RequestedBodyPart.brazo:
        return RoutineBodyPart.brazo;
      case RequestedBodyPart.fullBody:
        return RoutineBodyPart.fullBody;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Asignar Rutina',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          Positioned.fill(
            child: _currentStep == 0
                ? _buildBodyPartSelection()
                : _buildRoutineSelection(),
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

  Widget _buildBodyPartSelection() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      children: [
        // Info del cliente
        GlassCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  (widget.client.nombre ?? 'U')[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.client.nombre ?? 'Sin nombre',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.client.objetivo != null)
                    Text(
                      'Objetivo: ${widget.client.objetivo!.displayName}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingL),

        // Título
        Text(
          'Paso 1: Selecciona la parte del cuerpo',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),

        // Opciones de parte del cuerpo
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppConstants.spacingM,
          crossAxisSpacing: AppConstants.spacingM,
          childAspectRatio: 1.3,
          children: [
            _BodyPartCard(
              bodyPart: RoutineBodyPart.pierna,
              icon: Icons.directions_walk,
              isSelected: _selectedBodyPart == RoutineBodyPart.pierna,
              onTap: () => _selectBodyPart(RoutineBodyPart.pierna),
            ),
            _BodyPartCard(
              bodyPart: RoutineBodyPart.pecho,
              icon: Icons.fitness_center,
              isSelected: _selectedBodyPart == RoutineBodyPart.pecho,
              onTap: () => _selectBodyPart(RoutineBodyPart.pecho),
            ),
            _BodyPartCard(
              bodyPart: RoutineBodyPart.espalda,
              icon: Icons.accessibility_new,
              isSelected: _selectedBodyPart == RoutineBodyPart.espalda,
              onTap: () => _selectBodyPart(RoutineBodyPart.espalda),
            ),
            _BodyPartCard(
              bodyPart: RoutineBodyPart.hombro,
              icon: Icons.sports_gymnastics,
              isSelected: _selectedBodyPart == RoutineBodyPart.hombro,
              onTap: () => _selectBodyPart(RoutineBodyPart.hombro),
            ),
            _BodyPartCard(
              bodyPart: RoutineBodyPart.brazo,
              icon: Icons.sports_martial_arts,
              isSelected: _selectedBodyPart == RoutineBodyPart.brazo,
              onTap: () => _selectBodyPart(RoutineBodyPart.brazo),
            ),
            _BodyPartCard(
              bodyPart: RoutineBodyPart.fullBody,
              icon: Icons.person,
              isSelected: _selectedBodyPart == RoutineBodyPart.fullBody,
              onTap: () => _selectBodyPart(RoutineBodyPart.fullBody),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingL),

        // Opción de crear rutina personalizada
        GlassCard(
          onTap: _createCustomRoutine,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crear rutina personalizada',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Diseña una rutina especial para este cliente',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
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
        ),
      ],
    );
  }

  Widget _buildRoutineSelection() {
    final routinesAsync = ref.watch(routinesProvider);

    // Debug: mostrar estado de las rutinas
    routinesAsync.when(
      data: (routines) {
        print('🔍 [DEBUG] Total rutinas recibidas: ${routines.length}');
        print('🔍 [DEBUG] Parte del cuerpo seleccionada: $_selectedBodyPart');
        print('🔍 [DEBUG] Género del cliente: ${widget.client.genero}');
        final filtered = _filterRoutines(routines);
        print('🔍 [DEBUG] Rutinas después de filtrar: ${filtered.length}');
        if (filtered.isEmpty && routines.isNotEmpty) {
          print('⚠️ [DEBUG] Rutinas por parte del cuerpo:');
          for (final r in routines) {
            print('   - ${r.nombre}: ${r.parteDelCuerpo}, género: ${r.genero}');
          }
        }
      },
      loading: () => print('🔍 [DEBUG] Cargando rutinas...'),
      error: (e, _) => print('❌ [DEBUG] Error cargando rutinas: $e'),
    );

    return Column(
      children: [
        // Header con filtros
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.textPrimaryDark,
                    onPressed: () => setState(() => _currentStep = 0),
                  ),
                  Expanded(
                    child: Text(
                      'Paso 2: Selecciona la rutina',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Filtro seleccionado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                    ),
                    child: Text(
                      _selectedBodyPart!.displayName,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.client.genero != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.client.genero == UserGender.hombre
                            ? Colors.blue.withValues(alpha: 0.2)
                            : Colors.pink.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                      ),
                      child: Text(
                        widget.client.genero!.displayName,
                        style: TextStyle(
                          color: widget.client.genero == UserGender.hombre
                              ? Colors.blue
                              : Colors.pink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Filtro de nivel
              Text(
                'Filtrar por nivel:',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _LevelChip(
                      label: 'Todos',
                      isSelected: _selectedDifficulty == null,
                      onTap: () => setState(() => _selectedDifficulty = null),
                    ),
                    ...RoutineDifficulty.values.map((difficulty) => _LevelChip(
                          label: difficulty.displayName,
                          isSelected: _selectedDifficulty == difficulty,
                          color: _getDifficultyColor(difficulty),
                          onTap: () => setState(() => _selectedDifficulty = difficulty),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lista de rutinas
        Expanded(
          child: routinesAsync.when(
            data: (routines) {
              final filtered = _filterRoutines(routines);

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      // DEBUG INFO - Mostrar en UI para diagnóstico
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '🔍 DEBUG INFO',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Total rutinas en Firebase: ${routines.length}',
                              style: TextStyle(color: AppColors.warning, fontSize: 12),
                            ),
                            Text(
                              'Filtro parte cuerpo: $_selectedBodyPart',
                              style: TextStyle(color: AppColors.warning, fontSize: 12),
                            ),
                            Text(
                              'Género cliente: ${widget.client.genero}',
                              style: TextStyle(color: AppColors.warning, fontSize: 12),
                            ),
                            if (routines.isNotEmpty)
                              Text(
                                'Partes: ${routines.map((r) => r.parteDelCuerpo).toSet().join(", ")}',
                                style: TextStyle(color: AppColors.warning, fontSize: 10),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      Text(
                        'No hay rutinas disponibles',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      ElevatedButton.icon(
                        onPressed: _createCustomRoutine,
                        icon: const Icon(Icons.add),
                        label: const Text('Crear nueva rutina'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.backgroundDark,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final routine = filtered[index];
                  return _RoutineCard(
                    routine: routine,
                    onTap: () => _showRoutineDetail(routine),
                    onAssign: () => _assignRoutine(routine),
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
    );
  }

  List<RoutineModel> _filterRoutines(List<RoutineModel> routines) {
    return routines.where((routine) {
      // Filtrar por parte del cuerpo
      if (_selectedBodyPart != null &&
          routine.parteDelCuerpo != _selectedBodyPart &&
          routine.parteDelCuerpo != RoutineBodyPart.mixto &&
          routine.parteDelCuerpo != RoutineBodyPart.fullBody) {
        return false;
      }

      // Filtrar por dificultad
      if (_selectedDifficulty != null && routine.dificultad != _selectedDifficulty) {
        return false;
      }

      // Filtrar por género del cliente
      if (widget.client.genero != null) {
        final clientGender = widget.client.genero == UserGender.hombre
            ? RoutineGender.hombre
            : RoutineGender.mujer;

        if (routine.genero != RoutineGender.unisex && routine.genero != clientGender) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _selectBodyPart(RoutineBodyPart bodyPart) {
    setState(() {
      _selectedBodyPart = bodyPart;
      _currentStep = 1;
    });
  }

  void _createCustomRoutine() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineBuilderPage(
          mode: RoutineBuilderMode.mixed,
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

  void _showRoutineDetail(RoutineModel routine) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RoutineDetailSheet(
        routine: routine,
        onAssign: () {
          Navigator.pop(context);
          _assignRoutine(routine);
        },
      ),
    );
  }

  Future<void> _assignRoutine(RoutineModel routine) async {
    // Show dialog asking: assign for today or for the week
    final assignmentType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          '¿Cómo deseas asignar esta rutina?',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Elige si quieres asignar esta rutina solo para hoy o para toda la semana.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, 'today'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Solo hoy'),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'weekly'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Toda la semana'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
    );

    if (assignmentType == null) return;

    try {
      if (assignmentType == 'today') {
        // Assign for today only
        await _assignForToday(routine);
      } else {
        // Assign for the entire week (same routine every day)
        await _assignForWeek(routine);
      }

      // Si viene de una solicitud, marcarla como asignada
      if (widget.requestId != null) {
        await ref.read(firebaseServiceProvider).markRoutineRequestAsAssigned(
          widget.requestId!,
          routine.id,
          'Rutina "${routine.nombre}" asignada ${assignmentType == 'today' ? 'para hoy' : 'para toda la semana'}',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              assignmentType == 'today'
                  ? 'Rutina "${routine.nombre}" asignada para hoy a ${widget.client.nombre}'
                  : 'Rutina "${routine.nombre}" asignada para toda la semana a ${widget.client.nombre}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _assignForToday(RoutineModel routine) async {
    final firebaseService = ref.read(firebaseServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    final trainerId = ref.read(firebaseUserProvider).value?.uid;
    final trainerName = ref.read(userModelProvider).value?.nombre ?? 'Tu entrenador';

    // Usar assignRoutineToClient para crear una rutina temporal (3 horas)
    // Esto guarda en 'assigned_routines' que el cliente revisa primero
    await firebaseService.assignRoutineToClient(
      clienteId: widget.client.uid,
      rutinaId: routine.id,
      rutinaNombre: routine.nombre,
      trainerId: trainerId,
    );

    // Enviar notificación push al cliente
    await notificationService.sendPushNotification(
      recipientUserId: widget.client.uid,
      title: '¡Tu rutina está lista!',
      body: '$trainerName te asignó "${routine.nombre}" para hoy. ¡A entrenar!',
      data: {
        'type': 'routine_assigned',
        'routineId': routine.id,
        'assignmentType': 'today',
      },
    );
  }

  Future<void> _assignForWeek(RoutineModel routine) async {
    final firebaseService = ref.read(firebaseServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    final trainerName = ref.read(userModelProvider).value?.nombre ?? 'Tu entrenador';

    // Assign the same routine for all 7 days
    final routineData = {
      'clienteId': widget.client.uid,
      'lunes': routine.id,
      'martes': routine.id,
      'miercoles': routine.id,
      'jueves': routine.id,
      'viernes': routine.id,
      'sabado': routine.id,
      'domingo': routine.id,
      'creadoPor': ref.read(firebaseUserProvider).value?.uid,
    };

    await firebaseService.setWeeklyRoutine(widget.client.uid, routineData);

    // Enviar notificación push al cliente
    await notificationService.sendPushNotification(
      recipientUserId: widget.client.uid,
      title: '¡Tu rutina semanal está lista!',
      body: '$trainerName te asignó "${routine.nombre}" para toda la semana. ¡Comienza cuando quieras!',
      data: {
        'type': 'routine_assigned',
        'routineId': routine.id,
        'assignmentType': 'weekly',
      },
    );
  }
}

/// Card de parte del cuerpo
class _BodyPartCard extends StatelessWidget {
  final RoutineBodyPart bodyPart;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _BodyPartCard({
    required this.bodyPart,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      backgroundColor: isSelected
          ? AppColors.primary.withValues(alpha: 0.2)
          : null,
      borderColor: isSelected ? AppColors.primary : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 36,
            color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
          ),
          const SizedBox(height: 8),
          Text(
            bodyPart.displayName,
            style: AppTypography.titleSmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textPrimaryDark,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de nivel
class _LevelChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _LevelChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? effectiveColor.withValues(alpha: 0.2)
                : AppColors.glassDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            border: Border.all(
              color: isSelected ? effectiveColor : AppColors.glassBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? effectiveColor : AppColors.textSecondaryDark,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Card de rutina
class _RoutineCard extends StatelessWidget {
  final RoutineModel routine;
  final VoidCallback onTap;
  final VoidCallback onAssign;

  const _RoutineCard({
    required this.routine,
    required this.onTap,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Indicador de dificultad
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: _getDifficultyColor(routine.dificultad),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    routine.nombre,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 14, color: AppColors.textSecondaryDark),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          routine.duracionTexto,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.fitness_center, size: 14, color: AppColors.textSecondaryDark),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${routine.ejercicioCount} ejercicios',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(routine.dificultad).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      routine.dificultad.displayName,
                      style: TextStyle(
                        color: _getDifficultyColor(routine.dificultad),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacingS),
            // Botón asignar - envuelto en SizedBox para constraints adecuados
            SizedBox(
              width: 90,
              child: ElevatedButton(
                onPressed: onAssign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                child: const Text('Asignar', style: TextStyle(fontSize: 12)),
              ),
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

/// Sheet de detalle de rutina
class _RoutineDetailSheet extends StatelessWidget {
  final RoutineModel routine;
  final VoidCallback onAssign;

  const _RoutineDetailSheet({
    required this.routine,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppConstants.spacingL),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.glassBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                  Text(
                    routine.nombre,
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (routine.descripcion != null) ...[
                    const SizedBox(height: AppConstants.spacingS),
                    Text(
                      routine.descripcion!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppConstants.spacingM),
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Tag(label: routine.parteDelCuerpo.displayName, color: AppColors.primary),
                      _Tag(
                        label: routine.dificultad.displayName,
                        color: _getDifficultyColor(routine.dificultad),
                      ),
                      _Tag(label: routine.duracionTexto, color: AppColors.info),
                      _Tag(label: '${routine.ejercicioCount} ejercicios', color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  Text(
                    'Ejercicios',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  ...routine.ejercicios.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exercise = entry.value;
                    return _ExerciseItem(index: index + 1, exercise: exercise);
                  }),
                  const SizedBox(height: AppConstants.spacingXL),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAssign,
                      icon: const Icon(Icons.check),
                      label: const Text('Asignar esta rutina'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.backgroundDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ),
        );
      },
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

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  final int index;
  final RoutineExercise exercise;

  const _ExerciseItem({required this.index, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
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
                    exercise.machineName,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${exercise.sets} series x ${exercise.reps} reps',
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
    );
  }
}
