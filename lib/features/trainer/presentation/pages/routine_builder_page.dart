import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import 'trainer_machines_page.dart';

/// Modo del constructor de rutinas
enum RoutineBuilderMode {
  byBodyPart,
  mixed,
  fromTemplate,
  edit,
}

/// Página para crear/editar rutinas
class RoutineBuilderPage extends ConsumerStatefulWidget {
  final RoutineBuilderMode mode;
  final RoutineModel? template;
  final RoutineModel? existingRoutine;

  const RoutineBuilderPage({
    super.key,
    required this.mode,
    this.template,
    this.existingRoutine,
  });

  @override
  ConsumerState<RoutineBuilderPage> createState() => _RoutineBuilderPageState();
}

class _RoutineBuilderPageState extends ConsumerState<RoutineBuilderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  RoutineBodyPart? _selectedBodyPart;
  RoutineDifficulty _selectedDifficulty = RoutineDifficulty.principiante;
  RoutineGender _selectedGender = RoutineGender.unisex;
  int _durationMinutes = 60;
  List<RoutineExercise> _exercises = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFromExisting();
  }

  void _initializeFromExisting() {
    final source = widget.existingRoutine ?? widget.template;
    if (source != null) {
      _nameController.text = widget.mode == RoutineBuilderMode.fromTemplate
          ? ''
          : source.nombre;
      _descriptionController.text = source.descripcion ?? '';
      _selectedBodyPart = source.parteDelCuerpo;
      _selectedDifficulty = source.dificultad;
      _selectedGender = source.genero;
      _durationMinutes = source.duracionMinutos;
      _exercises = List.from(source.ejercicios);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _getTitle(),
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        actions: [
          if (_exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: _isLoading ? null : _saveRoutine,
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          children: [
            // Información básica
            _buildBasicInfoSection(),
            const SizedBox(height: AppConstants.spacingL),

            // Configuración
            _buildConfigSection(),
            const SizedBox(height: AppConstants.spacingL),

            // Ejercicios
            _buildExercisesSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExerciseSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundDark,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Ejercicio'),
      ),
    );
  }

  String _getTitle() {
    switch (widget.mode) {
      case RoutineBuilderMode.byBodyPart:
        return 'Nueva Rutina';
      case RoutineBuilderMode.mixed:
        return 'Rutina Mixta';
      case RoutineBuilderMode.fromTemplate:
        return 'Desde Plantilla';
      case RoutineBuilderMode.edit:
        return 'Editar Rutina';
    }
  }

  Widget _buildBasicInfoSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Básica',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          TextFormField(
            controller: _nameController,
            style: AppTypography.bodyMediumDark,
            decoration: InputDecoration(
              labelText: 'Nombre de la rutina',
              labelStyle: TextStyle(color: AppColors.textSecondaryDark),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.spacingM),
          TextFormField(
            controller: _descriptionController,
            style: AppTypography.bodyMediumDark,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Descripción (opcional)',
              labelStyle: TextStyle(color: AppColors.textSecondaryDark),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Parte del cuerpo
          Text(
            'Parte del cuerpo',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RoutineBodyPart.values.map((bodyPart) {
              final isSelected = _selectedBodyPart == bodyPart;
              return ChoiceChip(
                label: Text(bodyPart.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedBodyPart = selected ? bodyPart : null;
                  });
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.glassDark,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.backgroundDark
                      : AppColors.textPrimaryDark,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Dificultad
          Text(
            'Nivel de dificultad',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RoutineDifficulty.values.map((difficulty) {
              final isSelected = _selectedDifficulty == difficulty;
              return ChoiceChip(
                label: Text(difficulty.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedDifficulty = difficulty;
                    });
                  }
                },
                selectedColor: _getDifficultyColor(difficulty),
                backgroundColor: AppColors.glassDark,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.backgroundDark
                      : AppColors.textPrimaryDark,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Género
          Text(
            'Género objetivo',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RoutineGender.values.map((gender) {
              final isSelected = _selectedGender == gender;
              return ChoiceChip(
                label: Text(gender.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedGender = gender;
                    });
                  }
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.glassDark,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.backgroundDark
                      : AppColors.textPrimaryDark,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Duración
          Text(
            'Duración estimada: $_durationMinutes minutos',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          Slider(
            value: _durationMinutes.toDouble(),
            min: 15,
            max: 120,
            divisions: 21,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.glassBorder,
            onChanged: (value) {
              setState(() {
                _durationMinutes = value.round();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ejercicios (${_exercises.length})',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_exercises.isNotEmpty)
              TextButton.icon(
                onPressed: _reorderExercises,
                icon: const Icon(Icons.swap_vert, size: 18),
                label: const Text('Reordenar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingM),
        if (_exercises.isEmpty)
          GlassCard(
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    'Sin ejercicios',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Presiona el botón + para agregar ejercicios',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exercises.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = _exercises.removeAt(oldIndex);
                _exercises.insert(newIndex, item);
                _updateExerciseOrder();
              });
            },
            itemBuilder: (context, index) {
              final exercise = _exercises[index];
              return _ExerciseCard(
                key: ValueKey(exercise.machineId + index.toString()),
                index: index + 1,
                exercise: exercise,
                onEdit: () => _editExercise(index),
                onDelete: () => _deleteExercise(index),
              );
            },
          ),
      ],
    );
  }

  void _showAddExerciseSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MachinePickerSheet(
        onSelect: (machine) {
          Navigator.pop(context);
          _showExerciseConfigSheet(machine);
        },
      ),
    );
  }

  void _showExerciseConfigSheet(MachineModel machine, {int? editIndex}) {
    final existing = editIndex != null ? _exercises[editIndex] : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ExerciseConfigSheet(
        machine: machine,
        existingExercise: existing,
        onSave: (exercise) {
          setState(() {
            if (editIndex != null) {
              _exercises[editIndex] = exercise;
            } else {
              _exercises.add(exercise.copyWith(orden: _exercises.length));
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editExercise(int index) async {
    final exercise = _exercises[index];
    final machine = await ref.read(firebaseServiceProvider).getMachine(exercise.machineId);

    if (machine != null && mounted) {
      _showExerciseConfigSheet(machine, editIndex: index);
    }
  }

  void _deleteExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
      _updateExerciseOrder();
    });
  }

  void _updateExerciseOrder() {
    for (int i = 0; i < _exercises.length; i++) {
      _exercises[i] = _exercises[i].copyWith(orden: i);
    }
  }

  void _reorderExercises() {
    // Ya está implementado con ReorderableListView
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Arrastra los ejercicios para reordenarlos'),
        duration: Duration(seconds: 2),
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

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBodyPart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una parte del cuerpo')),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un ejercicio')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final routine = RoutineModel(
        id: widget.existingRoutine?.id ?? '',
        nombre: _nameController.text.trim(),
        descripcion: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dificultad: _selectedDifficulty,
        parteDelCuerpo: _selectedBodyPart!,
        genero: _selectedGender,
        ejercicios: _exercises,
        duracionMinutos: _durationMinutes,
        esPlantilla: false,
      );

      await ref.read(firebaseServiceProvider).saveRoutine(routine);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rutina guardada')),
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

/// Card de ejercicio en el builder
class _ExerciseCard extends StatelessWidget {
  final int index;
  final RoutineExercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseCard({
    super.key,
    required this.index,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Handle para reordenar
              ReorderableDragStartListener(
                index: index - 1,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.drag_handle,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Número
              Container(
                width: 32,
                height: 32,
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
              // Info
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
                    const SizedBox(height: 2),
                    Text(
                      '${exercise.sets} series x ${exercise.reps} reps',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Acciones con separación
              const SizedBox(width: AppConstants.spacingS),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                color: AppColors.primary,
                onPressed: onEdit,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: AppColors.error,
                onPressed: onDelete,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sheet para seleccionar máquina
class _MachinePickerSheet extends ConsumerStatefulWidget {
  final Function(MachineModel) onSelect;

  const _MachinePickerSheet({required this.onSelect});

  @override
  ConsumerState<_MachinePickerSheet> createState() => _MachinePickerSheetState();
}

class _MachinePickerSheetState extends ConsumerState<_MachinePickerSheet> {
  String _searchQuery = '';
  MachineCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final machinesAsync = ref.watch(machinesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
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
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
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
                        const SizedBox(height: AppConstants.spacingM),
                        Text(
                          'Seleccionar Ejercicio',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingM),
                        // Búsqueda
                        TextField(
                          style: AppTypography.bodyMediumDark,
                          decoration: InputDecoration(
                            hintText: 'Buscar...',
                            hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryDark),
                            filled: true,
                            fillColor: AppColors.glassDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                        ),
                        const SizedBox(height: AppConstants.spacingM),
                        // Filtros por categoría
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _CategoryChip(
                                label: 'Todos',
                                isSelected: _selectedCategory == null,
                                onTap: () => setState(() => _selectedCategory = null),
                              ),
                              ...MachineCategory.values.map((cat) => _CategoryChip(
                                    label: cat.displayName,
                                    isSelected: _selectedCategory == cat,
                                    onTap: () => setState(() => _selectedCategory = cat),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Lista
                  Expanded(
                    child: machinesAsync.when(
                      data: (machines) {
                        var filtered = machines;

                        if (_selectedCategory != null) {
                          filtered = filtered
                              .where((m) => m.categoria == _selectedCategory)
                              .toList();
                        }

                        if (_searchQuery.isNotEmpty) {
                          final query = _searchQuery.toLowerCase();
                          filtered = filtered
                              .where((m) =>
                                  m.nombre.toLowerCase().contains(query) ||
                                  m.descripcion.toLowerCase().contains(query))
                              .toList();
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final machine = filtered[index];
                            return _MachineListItem(
                              machine: machine,
                              onTap: () => widget.onSelect(machine),
                              onInfo: () => _showMachineDetail(machine),
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

  void _showMachineDetail(MachineModel machine) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MachineDetailSheet(
        machine: machine,
        showAddToRoutine: true,
        onAddToRoutine: () {
          Navigator.pop(context);
          widget.onSelect(machine);
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.glassDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.backgroundDark : AppColors.textPrimaryDark,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _MachineListItem extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback onTap;
  final VoidCallback onInfo;

  const _MachineListItem({
    required this.machine,
    required this.onTap,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: SizedBox(
                width: 60,
                height: 60,
                child: machine.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: machine.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.glassDark,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.glassDark,
                          child: const Icon(
                            Icons.fitness_center,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.glassDark,
                        child: const Icon(
                          Icons.fitness_center,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine.nombre,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          machine.categoria.displayName,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${machine.defaultSets}x${machine.defaultReps}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Info button
            IconButton(
              icon: const Icon(Icons.info_outline),
              color: AppColors.textSecondaryDark,
              onPressed: onInfo,
            ),
            // Add button
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet para configurar ejercicio
class _ExerciseConfigSheet extends StatefulWidget {
  final MachineModel machine;
  final RoutineExercise? existingExercise;
  final Function(RoutineExercise) onSave;

  const _ExerciseConfigSheet({
    required this.machine,
    this.existingExercise,
    required this.onSave,
  });

  @override
  State<_ExerciseConfigSheet> createState() => _ExerciseConfigSheetState();
}

class _ExerciseConfigSheetState extends State<_ExerciseConfigSheet> {
  late int _sets;
  late int _reps;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sets = widget.existingExercise?.sets ?? widget.machine.defaultSets;
    _reps = widget.existingExercise?.reps ?? widget.machine.defaultReps;
    _notesController.text = widget.existingExercise?.notas ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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
                widget.machine.nombre,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Series
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Series',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _sets > 1
                                  ? () => setState(() => _sets--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppColors.primary,
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.glassDark,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$_sets',
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: AppColors.textPrimaryDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _sets < 10
                                  ? () => setState(() => _sets++)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppColors.primary,
                            ),
                          ],
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
                          'Repeticiones',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _reps > 1
                                  ? () => setState(() => _reps--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppColors.primary,
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.glassDark,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$_reps',
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: AppColors.textPrimaryDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _reps < 50
                                  ? () => setState(() => _reps++)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Notas
              TextField(
                controller: _notesController,
                style: AppTypography.bodyMediumDark,
                decoration: InputDecoration(
                  labelText: 'Notas (opcional)',
                  labelStyle: TextStyle(color: AppColors.textSecondaryDark),
                  hintText: 'ej: Usar agarre cerrado',
                  hintStyle: TextStyle(color: AppColors.textSecondaryDark.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: AppColors.glassDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final exercise = RoutineExercise(
                      machineId: widget.machine.id,
                      machineName: widget.machine.nombre,
                      machineImageUrl: widget.machine.imageUrl,
                      sets: _sets,
                      reps: _reps,
                      notas: _notesController.text.isEmpty ? null : _notesController.text,
                    );
                    widget.onSave(exercise);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.backgroundDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.existingExercise != null ? 'Actualizar' : 'Agregar',
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
