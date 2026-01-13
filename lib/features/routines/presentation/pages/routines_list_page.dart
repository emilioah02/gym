import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/exercises_data.dart';

/// Pagina de Explorar para clientes
/// Muestra rutinas y ejercicios disponibles
class RoutinesListPage extends ConsumerStatefulWidget {
  const RoutinesListPage({super.key});

  @override
  ConsumerState<RoutinesListPage> createState() => _RoutinesListPageState();
}

class _RoutinesListPageState extends ConsumerState<RoutinesListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RoutineGender _selectedGender = RoutineGender.unisex;
  MachineCategory? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildGenderToggle()),
              SliverToBoxAdapter(child: _buildTabBar()),
              const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spacingM)),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [_buildRoutinesList(), _buildExercisesList()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -100,
      left: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.primary.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
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
                        Icons.fitness_center_rounded,
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
                            'Explorar',
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rutinas y ejercicios disponibles',
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

  Widget _buildGenderToggle() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Row(
        children: [
          _GenderChip(
            label: 'Todos',
            isSelected: _selectedGender == RoutineGender.unisex,
            onTap: () => setState(() => _selectedGender = RoutineGender.unisex),
          ),
          const SizedBox(width: AppConstants.spacingS),
          _GenderChip(
            label: 'Hombres',
            icon: Icons.male,
            isSelected: _selectedGender == RoutineGender.hombre,
            onTap: () => setState(() => _selectedGender = RoutineGender.hombre),
          ),
          const SizedBox(width: AppConstants.spacingS),
          _GenderChip(
            label: 'Mujeres',
            icon: Icons.female,
            isSelected: _selectedGender == RoutineGender.mujer,
            onTap: () => setState(() => _selectedGender = RoutineGender.mujer),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final exerciseCount = ExercisesData.getByGender(_selectedGender).length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppColors.glassDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.backgroundDark,
        unselectedLabelColor: AppColors.textSecondaryDark,
        labelStyle: AppTypography.labelLarge,
        dividerColor: Colors.transparent,
        tabs: [
          const Tab(text: 'Rutinas'),
          Tab(text: 'Ejercicios ($exerciseCount)'),
        ],
      ),
    );
  }

  Widget _buildRoutinesList() {
    final routinesAsync = ref.watch(routinesProvider);

    return routinesAsync.when(
      data: (allRoutines) {
        // Filtrar rutinas publicas (no plantillas) y por genero seleccionado
        final filteredRoutines = allRoutines.where((routine) {
          // Solo rutinas publicas (no plantillas)
          if (routine.esPlantilla) return false;

          // Filtro por genero
          if (_selectedGender == RoutineGender.unisex) return true;
          return routine.genero == _selectedGender ||
              routine.genero == RoutineGender.unisex;
        }).toList();

        if (filteredRoutines.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingXL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: 64,
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    'No hay rutinas disponibles',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Los entrenadores pronto crearan rutinas para ti',
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

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 1;
            double childAspectRatio = 1.4;

            if (constraints.maxWidth >= 1400) {
              crossAxisCount = 4;
              childAspectRatio = 0.85;
            } else if (constraints.maxWidth >= 1000) {
              crossAxisCount = 3;
              childAspectRatio = 0.85;
            } else if (constraints.maxWidth >= 700) {
              crossAxisCount = 2;
              childAspectRatio = 0.9;
            }

            if (crossAxisCount == 1) {
              return ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                itemCount: filteredRoutines.length,
                itemBuilder: (context, index) {
                  final routine = filteredRoutines[index];
                  // Usar la misma lógica de imágenes que el entrenador:
                  // Si tiene imageUrl usar ese, sino usar imagen por género
                  final imageUrl = (routine.imageUrl != null && routine.imageUrl!.isNotEmpty)
                      ? routine.imageUrl
                      : ExercisesData.getImageForRoutineGender(routine.genero);
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.spacingM,
                    ),
                    child: RoutineTile(
                      title: routine.nombre,
                      subtitle:
                          routine.descripcion ??
                          routine.parteDelCuerpo.displayName,
                      imageUrl: imageUrl,
                      exerciseCount: routine.ejercicioCount,
                      duration: routine.duracionTexto,
                      onTap: () => _showRoutineDetail(context, routine),
                    ),
                  );
                },
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppConstants.spacingM,
                mainAxisSpacing: AppConstants.spacingM,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: filteredRoutines.length,
              itemBuilder: (context, index) {
                final routine = filteredRoutines[index];
                // Usar la misma lógica de imágenes que el entrenador:
                // Si tiene imageUrl usar ese, sino usar imagen por género
                final imageUrl = (routine.imageUrl != null && routine.imageUrl!.isNotEmpty)
                    ? routine.imageUrl
                    : ExercisesData.getImageForRoutineGender(routine.genero);
                return RoutineTile(
                  title: routine.nombre,
                  subtitle:
                      routine.descripcion ?? routine.parteDelCuerpo.displayName,
                  imageUrl: imageUrl,
                  exerciseCount: routine.ejercicioCount,
                  duration: routine.duracionTexto,
                  onTap: () => _showRoutineDetail(context, routine),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),
              Text(
                'Error al cargar rutinas',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                'No se pudieron cargar las rutinas.\nPor favor, intenta de nuevo.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingL),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(routinesProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExercisesList() {
    return Column(
      children: [
        // Barra de busqueda y filtros
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            children: [
              // Buscador
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar ejercicios...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondaryDark,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondaryDark,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.glassDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              // Filtros por categoria
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CategoryChip(
                      label: 'Todos',
                      isSelected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    ...MachineCategory.values.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _CategoryChip(
                          label: category.displayName,
                          isSelected: _selectedCategory == category,
                          onTap: () =>
                              setState(() => _selectedCategory = category),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Lista de ejercicios
        Expanded(child: _buildFilteredExercisesList()),
      ],
    );
  }

  Widget _buildFilteredExercisesList() {
    // Primero filtrar por genero
    List<ExerciseModel> exercises = ExercisesData.getByGender(_selectedGender);

    // Filtrar por categoria
    if (_selectedCategory != null) {
      exercises = exercises
          .where(
            (e) =>
                e.categoria == _selectedCategory ||
                e.categoriaSecundaria == _selectedCategory,
          )
          .toList();
    }

    // Filtrar por busqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      exercises = exercises
          .where(
            (e) =>
                e.nombre.toLowerCase().contains(query) ||
                e.descripcion.toLowerCase().contains(query) ||
                e.machineName.toLowerCase().contains(query),
          )
          .toList();
    }

    if (exercises.isEmpty) {
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
            Text(
              'No se encontraron ejercicios',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
          child: _ExerciseTile(
            exercise: exercise,
            onTap: () => _showExerciseDetail(context, exercise),
          ),
        );
      },
    );
  }

  void _showRoutineDetail(BuildContext context, RoutineModel routine) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RoutineDetailSheet(routine: routine),
    );
  }

  void _showExerciseDetail(BuildContext context, ExerciseModel exercise) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ExerciseDetailSheet(exercise: exercise),
    );
  }
}

// ============ WIDGETS ============

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.glassDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColors.backgroundDark
                    : AppColors.textSecondaryDark,
              ),
              const SizedBox(width: AppConstants.spacingXS),
            ],
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? AppColors.backgroundDark
                    : AppColors.textPrimaryDark,
              ),
            ),
          ],
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.glassDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected
                ? AppColors.backgroundDark
                : AppColors.textPrimaryDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onTap;

  const _ExerciseTile({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Obtener imagen del ejercicio o de la máquina asociada
    final imageUrl = exercise.imageUrl ?? ExercisesData.getImageForExercise(exercise);

    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          // Icono/Imagen
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getCategoryColor(
                exercise.categoria,
              ).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    child: imageUrl.startsWith('assets/')
                        ? Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              _getCategoryIcon(exercise.categoria),
                              color: _getCategoryColor(exercise.categoria),
                              size: 28,
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              _getCategoryIcon(exercise.categoria),
                              color: _getCategoryColor(exercise.categoria),
                              size: 28,
                            ),
                          ),
                  )
                : Icon(
                    _getCategoryIcon(exercise.categoria),
                    color: _getCategoryColor(exercise.categoria),
                    size: 28,
                  ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.nombre,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  exercise.machineName,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoBadge(
                      icon: Icons.repeat,
                      label: exercise.setsRepsTexto,
                    ),
                    const SizedBox(width: 8),
                    _InfoBadge(
                      icon: Icons.timer_outlined,
                      label: exercise.duracionTexto,
                    ),
                    const SizedBox(width: 8),
                    _LevelBadge(level: exercise.nivel),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondaryDark),
        ],
      ),
    );
  }

  Color _getCategoryColor(MachineCategory category) {
    switch (category) {
      case MachineCategory.cardio:
        return Colors.red;
      case MachineCategory.pierna:
        return Colors.blue;
      case MachineCategory.pecho:
        return Colors.orange;
      case MachineCategory.espalda:
        return Colors.green;
      case MachineCategory.hombro:
        return Colors.purple;
      case MachineCategory.brazo:
        return Colors.teal;
      case MachineCategory.core:
        return Colors.amber;
      case MachineCategory.functional:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(MachineCategory category) {
    switch (category) {
      case MachineCategory.cardio:
        return Icons.favorite;
      case MachineCategory.pierna:
        return Icons.directions_walk;
      case MachineCategory.pecho:
        return Icons.fitness_center;
      case MachineCategory.espalda:
        return Icons.accessibility_new;
      case MachineCategory.hombro:
        return Icons.sports_martial_arts;
      case MachineCategory.brazo:
        return Icons.sports_handball;
      case MachineCategory.core:
        return Icons.self_improvement;
      case MachineCategory.functional:
        return Icons.flash_on;
    }
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondaryDark),
        const SizedBox(width: 2),
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

class _LevelBadge extends StatelessWidget {
  final DifficultyLevel level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (level) {
      case DifficultyLevel.principiante:
        color = AppColors.success;
        break;
      case DifficultyLevel.intermedio:
        color = AppColors.warning;
        break;
      case DifficultyLevel.avanzado:
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        level.displayName,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============ DETAIL SHEETS ============

class _RoutineDetailSheet extends ConsumerStatefulWidget {
  final RoutineModel routine;

  const _RoutineDetailSheet({required this.routine});

  @override
  ConsumerState<_RoutineDetailSheet> createState() =>
      _RoutineDetailSheetState();
}

class _RoutineDetailSheetState extends ConsumerState<_RoutineDetailSheet> {
  bool _isAssigning = false;

  Future<void> _assignRoutineToSelf() async {
    final firebaseUser = ref.read(firebaseUserProvider).value;
    if (firebaseUser == null) return;

    // Si hay un usuario activo configurado (modo prueba), usar ese ID
    final activeUserId = ref.read(activeUserIdProvider);
    final clienteId = activeUserId ?? firebaseUser.uid;

    setState(() => _isAssigning = true);

    try {
      await ref
          .read(firebaseServiceProvider)
          .assignRoutineToClient(
            clienteId: clienteId,
            rutinaId: widget.routine.id,
            rutinaNombre: widget.routine.nombre,
            trainerId: null, // null indica autoasignación
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rutina "${widget.routine.nombre}" asignada por 3 horas',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al asignar rutina: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAssigning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si ya tiene una rutina activa
    final activeRoutine = ref.watch(activeAssignedRoutineProvider).value;
    final hasActiveRoutine = activeRoutine != null && activeRoutine.isActive;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  children: [
                    // Header
                    Text(
                      widget.routine.nombre,
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.routine.descripcion != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.routine.descripcion!,
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
                        _Tag(
                          label: widget.routine.parteDelCuerpo.displayName,
                          color: AppColors.primary,
                        ),
                        _Tag(
                          label: widget.routine.dificultad.displayName,
                          color: _getDifficultyColor(widget.routine.dificultad),
                        ),
                        _Tag(
                          label: widget.routine.duracionTexto,
                          color: AppColors.info,
                        ),
                        _Tag(
                          label: '${widget.routine.ejercicioCount} ejercicios',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                    // Botón de asignar rutina
                    _buildAssignButton(hasActiveRoutine),
                    const SizedBox(height: AppConstants.spacingL),
                    // Ejercicios
                    Text(
                      'Ejercicios',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    ...widget.routine.ejercicios.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exercise = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConstants.spacingS,
                        ),
                        child: _ExerciseListItem(
                          index: index + 1,
                          exercise: exercise,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignButton(bool hasActiveRoutine) {
    if (hasActiveRoutine) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning, size: 20),
            const SizedBox(width: AppConstants.spacingS),
            Expanded(
              child: Text(
                'Ya tienes una rutina activa. Complétala o espera a que expire para asignar otra.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _isAssigning ? null : _assignRoutineToSelf,
      icon: _isAssigning
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.play_arrow_rounded),
      label: Text(_isAssigning ? 'Asignando...' : 'Entrenar esta rutina'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundDark,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingM,
        ),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
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

class _ExerciseDetailSheet extends StatelessWidget {
  final ExerciseModel exercise;

  const _ExerciseDetailSheet({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  children: [
                    // Header
                    Text(
                      exercise.nombre,
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          exercise.machineName,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    Text(
                      exercise.descripcion,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Tag(
                          label: exercise.categoria.displayName,
                          color: AppColors.primary,
                        ),
                        _Tag(
                          label: exercise.nivel.displayName,
                          color: _getLevelColor(exercise.nivel),
                        ),
                        _Tag(
                          label: exercise.setsRepsTexto,
                          color: AppColors.info,
                        ),
                        _Tag(
                          label: exercise.duracionTexto,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    // Musculos
                    if (exercise.musculos != null &&
                        exercise.musculos!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacingXL),
                      _SectionTitle(title: 'Musculos trabajados'),
                      const SizedBox(height: AppConstants.spacingS),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: exercise.musculos!
                            .map(
                              (m) => Chip(
                                label: Text(
                                  m,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                                backgroundColor: AppColors.glassDark,
                                side: BorderSide(color: AppColors.glassBorder),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    // Instrucciones
                    if (exercise.instrucciones != null &&
                        exercise.instrucciones!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacingXL),
                      _SectionTitle(title: 'Instrucciones'),
                      const SizedBox(height: AppConstants.spacingS),
                      ...exercise.instrucciones!.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Tips
                    if (exercise.tips != null && exercise.tips!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacingXL),
                      _SectionTitle(title: 'Tips'),
                      const SizedBox(height: AppConstants.spacingS),
                      ...exercise.tips!.map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 18,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Errores comunes
                    if (exercise.erroresComunes != null &&
                        exercise.erroresComunes!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacingXL),
                      _SectionTitle(title: 'Errores comunes a evitar'),
                      const SizedBox(height: AppConstants.spacingS),
                      ...exercise.erroresComunes!.map(
                        (error) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_outlined,
                                size: 18,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Variaciones
                    if (exercise.variaciones != null &&
                        exercise.variaciones!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacingXL),
                      _SectionTitle(title: 'Variaciones'),
                      const SizedBox(height: AppConstants.spacingS),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: exercise.variaciones!
                            .map(
                              (v) => Chip(
                                label: Text(
                                  v,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                                backgroundColor: AppColors.glassDark,
                                side: BorderSide(color: AppColors.glassBorder),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: AppConstants.spacingXL),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getLevelColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.principiante:
        return AppColors.success;
      case DifficultyLevel.intermedio:
        return AppColors.warning;
      case DifficultyLevel.avanzado:
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  final int index;
  final RoutineExercise exercise;

  const _ExerciseListItem({required this.index, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
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
                if (exercise.notas != null)
                  Text(
                    exercise.notas!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
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
