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
import '../../../routines/data/exercises_data.dart';
import 'routine_builder_page.dart';
import 'weekly_routine_builder_page.dart';
// MachineDetailSheet, EditMachineDialog and AddMachineDialog are imported from trainer_machines_page.dart
import 'trainer_machines_page.dart'
    show MachineDetailSheet, EditMachineDialog, AddMachineDialog;

/// Pantalla de rutinas para el entrenador
class TrainerRoutinesPage extends ConsumerStatefulWidget {
  const TrainerRoutinesPage({super.key});

  @override
  ConsumerState<TrainerRoutinesPage> createState() =>
      _TrainerRoutinesPageState();
}

class _TrainerRoutinesPageState extends ConsumerState<TrainerRoutinesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
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
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildAppBar(),
                SliverToBoxAdapter(child: _buildTabBar()),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [_RoutinesTab(), _ExercisesTab(), _MachinesTab()],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _buildFAB(),
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
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.backgroundDark,
          ],
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
                    IconButton(
                      icon: const Icon(Icons.calendar_month, color: AppColors.primary),
                      tooltip: 'Crear semana de rutinas',
                      onPressed: () => _navigateToWeeklyBuilder(),
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
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
        labelStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          const Tab(text: 'Rutinas'),
          Tab(text: 'Ejercicios (${ExercisesData.totalExercises})'),
          const Tab(text: 'Máquinas'),
        ],
      ),
    );
  }

  /// FAB contextual que cambia según el tab activo
  Widget? _buildFAB() {
    switch (_currentTabIndex) {
      case 0: // Tab Rutinas
        return _buildRoutinesFAB();
      case 1: // Tab Ejercicios
        return _buildExercisesFAB();
      case 2: // Tab Máquinas
        return _buildMachinesFAB();
      default:
        return null;
    }
  }

  /// FAB para la sección de Rutinas
  Widget _buildRoutinesFAB() {
    return Padding(
      key: const ValueKey('fab_routines'),
      padding: const EdgeInsets.only(bottom: 110),
      child: FloatingActionButton.extended(
        heroTag: 'fab_routines',
        onPressed: () => _showCreateOptions(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundDark,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text('Crear Rutina'),
      ),
    );
  }

  /// FAB para la sección de Máquinas
  Widget _buildMachinesFAB() {
    return Padding(
      key: const ValueKey('fab_machines'),
      padding: const EdgeInsets.only(bottom: 110),
      child: FloatingActionButton.extended(
        heroTag: 'fab_machines',
        onPressed: () => _showAddMachineDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundDark,
        elevation: 8,
        icon: const Icon(Icons.fitness_center),
        label: const Text('Agregar Máquina'),
      ),
    );
  }

  /// Mostrar diálogo para agregar nueva máquina
  void _showAddMachineDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddMachineDialog(),
    );
  }

  /// FAB para la sección de Ejercicios
  Widget _buildExercisesFAB() {
    return Padding(
      key: const ValueKey('fab_exercises'),
      padding: const EdgeInsets.only(bottom: 110),
      child: FloatingActionButton.extended(
        heroTag: 'fab_exercises',
        onPressed: () => _showAddExerciseDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundDark,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Ejercicio'),
      ),
    );
  }

  /// Mostrar diálogo para agregar nuevo ejercicio
  void _showAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddExerciseDialog(),
    );
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateOptionsSheet(
        onCreateByBodyPart: () {
          Navigator.pop(context);
          _navigateToBuilder(RoutineBuilderMode.byBodyPart);
        },
        onCreateMixed: () {
          Navigator.pop(context);
          _navigateToBuilder(RoutineBuilderMode.mixed);
        },
        onCreateFromTemplate: () {
          Navigator.pop(context);
          _showTemplateSelector();
        },
        onCreateWeekly: () {
          Navigator.pop(context);
          _navigateToWeeklyBuilder();
        },
      ),
    );
  }

  void _navigateToBuilder(RoutineBuilderMode mode, {RoutineModel? template}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RoutineBuilderPage(mode: mode, template: template),
      ),
    );
  }

  void _navigateToWeeklyBuilder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeeklyRoutineBuilderPage()),
    );
  }

  void _showTemplateSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TemplateSelectorSheet(
        onSelect: (template) {
          Navigator.pop(context);
          _navigateToBuilder(
            RoutineBuilderMode.fromTemplate,
            template: template,
          );
        },
      ),
    );
  }
}

/// Tab de rutinas del entrenador con filtros
class _RoutinesTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_RoutinesTab> createState() => _RoutinesTabState();
}

class _RoutinesTabState extends ConsumerState<_RoutinesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  RoutineDifficulty? _selectedDifficulty;
  RoutineGender? _selectedGender;
  RoutineBodyPart? _selectedBodyPart;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filtra las rutinas según los criterios seleccionados
  List<RoutineModel> _filterRoutines(List<RoutineModel> routines) {
    return routines.where((routine) {
      // Excluir plantillas
      if (routine.esPlantilla) return false;

      // Filtro de búsqueda por texto
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = routine.nombre.toLowerCase().contains(query);
        final matchesDescription =
            routine.descripcion?.toLowerCase().contains(query) ?? false;
        if (!matchesName && !matchesDescription) return false;
      }

      // Filtro por dificultad
      if (_selectedDifficulty != null &&
          routine.dificultad != _selectedDifficulty) {
        return false;
      }

      // Filtro por género
      if (_selectedGender != null && routine.genero != _selectedGender) {
        return false;
      }

      // Filtro por parte del cuerpo
      if (_selectedBodyPart != null &&
          routine.parteDelCuerpo != _selectedBodyPart) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Verifica si hay filtros activos
  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedDifficulty != null ||
      _selectedGender != null ||
      _selectedBodyPart != null;

  /// Limpia todos los filtros
  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedDifficulty = null;
      _selectedGender = null;
      _selectedBodyPart = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(routinesProvider);

    return Column(
      children: [
        // Barra de búsqueda y filtros
        _buildFiltersSection(),
        // Lista de rutinas
        Expanded(
          child: routinesAsync.when(
            data: (routines) {
              final filteredRoutines = _filterRoutines(routines);

              if (filteredRoutines.isEmpty) {
                if (_hasActiveFilters) {
                  return _buildNoResultsState();
                }
                return _EmptyState(
                  icon: Icons.fitness_center,
                  title: 'Sin rutinas',
                  subtitle: 'Crea tu primera rutina presionando el botón +',
                );
              }

              return _buildRoutinesList(filteredRoutines);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, _) => _buildErrorState(),
          ),
        ),
        SizedBox(height: 110),
      ],
    );
  }

  /// Construye la sección de filtros
  Widget _buildFiltersSection() {
    return Padding(
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
              hintText: 'Buscar rutinas...',
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
          // Fila de filtros con scroll horizontal
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Chip para limpiar filtros (solo si hay filtros activos)
                if (_hasActiveFilters) ...[
                  _FilterChip(
                    label: 'Limpiar',
                    icon: Icons.clear_all,
                    isSelected: false,
                    isDestructive: true,
                    onTap: _clearAllFilters,
                  ),
                  const SizedBox(width: 8),
                ],
                // Filtro de Dificultad
                _FilterDropdownChip<RoutineDifficulty>(
                  label: _selectedDifficulty?.displayName ?? 'Dificultad',
                  icon: Icons.speed,
                  isSelected: _selectedDifficulty != null,
                  options: RoutineDifficulty.values,
                  selectedOption: _selectedDifficulty,
                  getDisplayName: (d) => d.displayName,
                  onSelected: (difficulty) =>
                      setState(() => _selectedDifficulty = difficulty),
                  onClear: () => setState(() => _selectedDifficulty = null),
                ),
                const SizedBox(width: 8),
                // Filtro de Género
                _FilterDropdownChip<RoutineGender>(
                  label: _selectedGender?.displayName ?? 'Género',
                  icon: Icons.person,
                  isSelected: _selectedGender != null,
                  options: RoutineGender.values,
                  selectedOption: _selectedGender,
                  getDisplayName: (g) => g.displayName,
                  onSelected: (gender) =>
                      setState(() => _selectedGender = gender),
                  onClear: () => setState(() => _selectedGender = null),
                ),
                const SizedBox(width: 8),
                // Filtro de Parte del cuerpo
                _FilterDropdownChip<RoutineBodyPart>(
                  label: _selectedBodyPart?.displayName ?? 'Parte del cuerpo',
                  icon: Icons.accessibility_new,
                  isSelected: _selectedBodyPart != null,
                  options: RoutineBodyPart.values,
                  selectedOption: _selectedBodyPart,
                  getDisplayName: (b) => b.displayName,
                  onSelected: (bodyPart) =>
                      setState(() => _selectedBodyPart = bodyPart),
                  onClear: () => setState(() => _selectedBodyPart = null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el estado de sin resultados
  Widget _buildNoResultsState() {
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
            'No se encontraron rutinas',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Intenta cambiar los filtros de búsqueda',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          TextButton.icon(
            onPressed: _clearAllFilters,
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpiar filtros'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  /// Construye el estado de error
  Widget _buildErrorState() {
    return Center(
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
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'Error al cargar rutinas',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'No se pudieron cargar las rutinas.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(routinesProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDark,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingL,
                vertical: AppConstants.spacingM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la lista/grid de rutinas
  Widget _buildRoutinesList(List<RoutineModel> routines) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar número de columnas según el ancho disponible
        int crossAxisCount = 1;
        double childAspectRatio = 2.2; // Más ancho para móvil horizontal

        if (constraints.maxWidth >= 1400) {
          crossAxisCount = 4; // 4 columnas en pantallas muy grandes
          childAspectRatio = 1.4; // Cards más compactas
        } else if (constraints.maxWidth >= 1000) {
          crossAxisCount = 3; // 3 columnas en pantallas grandes
          childAspectRatio = 1.35;
        } else if (constraints.maxWidth >= 700) {
          crossAxisCount = 2; // 2 columnas en tablets
          childAspectRatio = 1.5;
        }

        // En móvil usar lista, en pantallas grandes usar grid
        if (crossAxisCount == 1) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
            ),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                child: _RoutineCard(
                  routine: routine,
                  useFixedHeight: true, // Altura fija en ListView
                  onTap: () => _showRoutineDetail(context, routine, ref),
                  onMoreOptions: () =>
                      _showRoutineOptions(context, ref, routine),
                ),
              );
            },
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppConstants.spacingM,
            mainAxisSpacing: AppConstants.spacingM,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: routines.length,
          itemBuilder: (context, index) {
            final routine = routines[index];
            return _RoutineCard(
              routine: routine,
              onTap: () => _showRoutineDetail(context, routine, ref),
              onMoreOptions: () => _showRoutineOptions(context, ref, routine),
            );
          },
        );
      },
    );
  }

  void _showRoutineDetail(
    BuildContext context,
    RoutineModel routine,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RoutineDetailSheet(
        routine: routine,
        onEdit: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoutineBuilderPage(
                mode: RoutineBuilderMode.edit,
                existingRoutine: routine,
              ),
            ),
          );
        },
        onDuplicate: () async {
          Navigator.pop(context);
          try {
            await ref
                .read(firebaseServiceProvider)
                .duplicateRoutine(routine.id, '${routine.nombre} (copia)');
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Rutina duplicada')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
        onDelete: () async {
          Navigator.pop(context);
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              title: Text(
                'Eliminar rutina',
                style: AppTypography.titleLargeDark,
              ),
              content: Text(
                '¿Estás seguro de eliminar "${routine.nombre}"?',
                style: AppTypography.bodyMediumDark,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            try {
              await ref.read(firebaseServiceProvider).deleteRoutine(routine.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rutina eliminada')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          }
        },
      ),
    );
  }

  void _showRoutineOptions(
    BuildContext context,
    WidgetRef ref,
    RoutineModel routine,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _RoutineOptionsSheet(
        routine: routine,
        onEdit: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoutineBuilderPage(
                mode: RoutineBuilderMode.edit,
                existingRoutine: routine,
              ),
            ),
          );
        },
        onDuplicate: () async {
          Navigator.pop(context);
          try {
            await ref
                .read(firebaseServiceProvider)
                .duplicateRoutine(routine.id, '${routine.nombre} (copia)');
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Rutina duplicada')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
        onDelete: () async {
          Navigator.pop(context);
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              title: Text(
                'Eliminar rutina',
                style: AppTypography.titleLargeDark,
              ),
              content: Text(
                '¿Estás seguro de eliminar "${routine.nombre}"?',
                style: AppTypography.bodyMediumDark,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            try {
              await ref.read(firebaseServiceProvider).deleteRoutine(routine.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rutina eliminada')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          }
        },
      ),
    );
  }
}

/// Tab de ejercicios del entrenador
class _ExercisesTab extends StatefulWidget {
  @override
  State<_ExercisesTab> createState() => _ExercisesTabState();
}

class _ExercisesTabState extends State<_ExercisesTab> {
  MachineCategory? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    List<ExerciseModel> exercises = ExercisesData.allExercises;

    // Filtrar por categoria
    if (_selectedCategory != null) {
      exercises = ExercisesData.getByCategory(_selectedCategory!);
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

  void _showExerciseDetail(BuildContext context, ExerciseModel exercise) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ExerciseDetailSheet(exercise: exercise),
    );
  }
}

/// Tab de máquinas del entrenador
class _MachinesTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MachinesTab> createState() => _MachinesTabState();
}

class _MachinesTabState extends ConsumerState<_MachinesTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final machinesAsync = ref.watch(machinesProvider);
    final filters = ref.watch(machineFiltersProvider);

    return Column(
      children: [
        // Barra de búsqueda y filtros
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            children: [
              // Buscador
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(machineFiltersProvider.notifier).state = ref
                      .read(machineFiltersProvider)
                      .copyWith(searchQuery: value);
                },
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar máquinas...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondaryDark,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondaryDark,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(machineFiltersProvider.notifier)
                                .state = ref
                                .read(machineFiltersProvider)
                                .copyWith(searchQuery: '');
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
              // Filtros por categoría
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _MachineFilterChip(
                      label: 'Todos',
                      isSelected: filters.category == null,
                      onTap: () {
                        ref.read(machineFiltersProvider.notifier).state =
                            filters.copyWith(clearCategory: true);
                      },
                    ),
                    ...MachineCategory.values.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _MachineFilterChip(
                          label: category.displayName,
                          isSelected: filters.category == category,
                          onTap: () {
                            ref.read(machineFiltersProvider.notifier).state =
                                filters.copyWith(category: category);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Lista de máquinas
        Expanded(
          child: machinesAsync.when(
            data: (machines) {
              final filteredMachines = _filterMachines(machines, filters);
              return _buildMachinesGrid(filteredMachines);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, _) => Center(
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
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    'Error al cargar máquinas',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'No se pudieron cargar las máquinas.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(machinesProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingL,
                        vertical: AppConstants.spacingM,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 110),
      ],
    );
  }

  List<MachineModel> _filterMachines(
    List<MachineModel> machines,
    MachineFilters filters,
  ) {
    return machines.where((machine) {
      if (filters.category != null && machine.categoria != filters.category) {
        return false;
      }
      if (filters.type != null && machine.tipo != filters.type) {
        return false;
      }
      if (filters.level != null && machine.nivel != filters.level) {
        return false;
      }
      if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
        final query = filters.searchQuery!.toLowerCase();
        return machine.nombre.toLowerCase().contains(query) ||
            machine.descripcion.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  Widget _buildMachinesGrid(List<MachineModel> machines) {
    if (machines.isEmpty) {
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
              'No se encontraron máquinas',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular número de columnas basado en el ancho
        int crossAxisCount;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppConstants.spacingM,
            crossAxisSpacing: AppConstants.spacingM,
            childAspectRatio: 0.85,
          ),
          itemCount: machines.length,
          itemBuilder: (context, index) {
            final machine = machines[index];
            return _MachineCardItem(
              machine: machine,
              onTap: () => _showMachineDetail(machine),
            );
          },
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
        showEditButton: true,
        onEdit: () {
          Navigator.pop(context);
          _showEditMachineDialog(machine);
        },
      ),
    );
  }

  void _showEditMachineDialog(MachineModel machine) {
    showDialog(
      context: context,
      builder: (context) => EditMachineDialog(machine: machine),
    );
  }
}

/// Chip de filtro para máquinas
class _MachineFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MachineFilterChip({
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

/// Card de máquina para el grid
class _MachineCardItem extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback onTap;

  const _MachineCardItem({required this.machine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusL),
              ),
              child: machine.imageUrl != null && machine.imageUrl!.isNotEmpty
                  ? _buildMachineImage(machine.imageUrl!, machine.categoria)
                  : _buildPlaceholderImage(machine.categoria),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  machine.nombre,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
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
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        machine.tipo.displayName,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.info,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${machine.defaultSets}x${machine.defaultReps} reps',
                  style: AppTypography.bodySmall.copyWith(
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

  /// Construye la imagen de la máquina (local o de red)
  Widget _buildMachineImage(String imageUrl, MachineCategory category) {
    // Verificar si es un asset local
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage(category);
        },
      );
    }
    // Si es URL de red, usar CachedNetworkImage
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: AppColors.surfaceDark,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildPlaceholderImage(category),
    );
  }

  Widget _buildPlaceholderImage(MachineCategory category) {
    IconData icon;
    Color color;

    switch (category) {
      case MachineCategory.cardio:
        icon = Icons.directions_run;
        color = AppColors.success;
        break;
      case MachineCategory.pierna:
        icon = Icons.directions_walk;
        color = AppColors.info;
        break;
      case MachineCategory.pecho:
        icon = Icons.fitness_center;
        color = AppColors.warning;
        break;
      case MachineCategory.espalda:
        icon = Icons.accessibility_new;
        color = AppColors.error;
        break;
      case MachineCategory.brazo:
        icon = Icons.sports_martial_arts;
        color = AppColors.primary;
        break;
      case MachineCategory.hombro:
        icon = Icons.sports_gymnastics;
        color = Colors.purple;
        break;
      case MachineCategory.core:
        icon = Icons.self_improvement;
        color = Colors.orange;
        break;
      case MachineCategory.functional:
        icon = Icons.person;
        color = AppColors.primary;
        break;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.3), AppColors.surfaceDark],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 64, color: color.withValues(alpha: 0.8)),
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

/// Card de rutina con diseño moderno y soporte para imágenes
class _RoutineCard extends StatelessWidget {
  final RoutineModel routine;
  final bool isTemplate;
  final VoidCallback onTap;
  final VoidCallback? onMoreOptions;
  final bool useFixedHeight; // Para ListView (móvil)

  const _RoutineCard({
    required this.routine,
    this.isTemplate = false,
    required this.onTap,
    this.onMoreOptions,
    this.useFixedHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    // En móvil (ListView) usamos altura fija para evitar el problema de unbounded height
    final cardContent = _buildCardContent();

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      height: useFixedHeight ? 180 : null, // Altura compacta para móvil
      child: cardContent,
    );
  }

  Widget _buildCardContent() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la rutina - Ocupa ~55% del espacio disponible
            Expanded(
              flex: 55,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.radiusL),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getDifficultyColor(
                        routine.dificultad,
                      ).withValues(alpha: 0.3),
                      _getDifficultyColor(
                        routine.dificultad,
                      ).withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: _buildRoutineImage(),
              ),
            ),
            // Contenido compacto - 45% del espacio
            Expanded(
              flex: 45,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingS,
                  vertical: AppConstants.spacingXS,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badges (plantilla, dificultad)
                    Row(
                      children: [
                        if (isTemplate)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PLANTILLA',
                              style: TextStyle(
                                color: AppColors.info,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(
                              routine.dificultad,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            routine.dificultad.displayName,
                            style: TextStyle(
                              color: _getDifficultyColor(routine.dificultad),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (routine.genero != RoutineGender.unisex) ...[
                          const SizedBox(width: 4),
                          Icon(
                            routine.genero == RoutineGender.hombre
                                ? Icons.male
                                : Icons.female,
                            size: 12,
                            color: routine.genero == RoutineGender.hombre
                                ? Colors.blue
                                : Colors.pink,
                          ),
                        ],
                      ],
                    ),
                    // Título y descripción
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          routine.nombre,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          routine.descripcion ?? routine.parteDelCuerpo.displayName,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // Info chips compactos
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.fitness_center,
                          label: '${routine.ejercicioCount}',
                        ),
                        const SizedBox(width: 10),
                        _InfoChip(
                          icon: Icons.schedule,
                          label: routine.duracionTexto,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Botón de opciones
        if (onMoreOptions != null)
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onMoreOptions,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.textPrimaryDark,
                  size: 18,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Construye la imagen de la rutina basada en imageUrl o género
  Widget _buildRoutineImage() {
    // Determinar la URL de imagen a usar
    String? imageUrl = routine.imageUrl;

    // Si no tiene imageUrl, usar la imagen basada en género
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = ExercisesData.getImageForRoutineGender(routine.genero);
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusL),
      ),
      child: imageUrl.startsWith('assets/')
          ? Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
            ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.fitness_center,
        size: 48,
        color: AppColors.primary.withValues(alpha: 0.5),
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

/// Estado vacío
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            subtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Sheet de opciones de creación
class _CreateOptionsSheet extends StatelessWidget {
  final VoidCallback onCreateByBodyPart;
  final VoidCallback onCreateMixed;
  final VoidCallback onCreateFromTemplate;
  final VoidCallback onCreateWeekly;

  const _CreateOptionsSheet({
    required this.onCreateByBodyPart,
    required this.onCreateMixed,
    required this.onCreateFromTemplate,
    required this.onCreateWeekly,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
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
                    'Crear Rutina',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                  _OptionTile(
                    icon: Icons.fitness_center,
                    title: 'Por parte del cuerpo',
                    subtitle: 'Selecciona un grupo muscular específico',
                    onTap: onCreateByBodyPart,
                  ),
                  _OptionTile(
                    icon: Icons.shuffle,
                    title: 'Rutina mixta avanzada',
                    subtitle:
                        'Combina ejercicios de cualquier parte del cuerpo',
                    onTap: onCreateMixed,
                  ),
                  _OptionTile(
                    icon: Icons.description,
                    title: 'Desde plantilla',
                    subtitle: 'Usa una plantilla predefinida como base',
                    onTap: onCreateFromTemplate,
                  ),
                  _OptionTile(
                    icon: Icons.calendar_month,
                    title: 'Rutina semanal',
                    subtitle: 'Crea una semana completa de rutinas',
                    onTap: onCreateWeekly,
                  ),
                  SizedBox(
                    height:
                        MediaQuery.of(context).padding.bottom +
                        AppConstants.spacingM,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondaryDark),
          ],
        ),
      ),
    );
  }
}

/// Sheet de opciones de rutina con diseño glassmorphism elegante
class _RoutineOptionsSheet extends StatelessWidget {
  final RoutineModel routine;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _RoutineOptionsSheet({
    required this.routine,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // Handle indicator
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Título
                Text(
                  routine.nombre,
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Opciones
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _OptionItem(
                        icon: Icons.edit_outlined,
                        label: 'Editar',
                        onTap: onEdit,
                      ),
                      _OptionItem(
                        icon: Icons.copy_outlined,
                        label: 'Duplicar',
                        onTap: onDuplicate,
                      ),
                      _OptionItem(
                        icon: Icons.delete_outline,
                        label: 'Eliminar',
                        onTap: onDelete,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Botón cancelar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _CancelButton(onTap: () => Navigator.pop(context)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Item de opción individual con estilo minimalista
class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isDestructive
                      ? Colors.red.shade300
                      : Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isDestructive
                        ? Colors.red.shade300
                        : Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón de cancelar
class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Cancelar',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Sheet de selector de plantillas
class _TemplateSelectorSheet extends ConsumerWidget {
  final Function(RoutineModel) onSelect;

  const _TemplateSelectorSheet({required this.onSelect});

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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
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
                          'Seleccionar Plantilla',
                          style: AppTypography.headlineSmall.copyWith(
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
                        final templates = routines
                            .where((r) => r.esPlantilla)
                            .toList();

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                          ),
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            final template = templates[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppConstants.spacingM,
                              ),
                              child: _RoutineCard(
                                routine: template,
                                isTemplate: true,
                                useFixedHeight: true, // Altura fija en ListView
                                onTap: () => onSelect(template),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                      error: (error, _) => Center(child: Text('Error: $error')),
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

/// Sheet de detalle de rutina
class _RoutineDetailSheet extends StatelessWidget {
  final RoutineModel routine;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const _RoutineDetailSheet({
    required this.routine,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Header con título y botón de opciones
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                routine.nombre,
                                style: AppTypography.headlineMedium.copyWith(
                                  color: AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (onEdit != null ||
                                onDuplicate != null ||
                                onDelete != null)
                              IconButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: AppColors.textPrimaryDark,
                                ),
                                onPressed: () => _showOptionsMenu(context),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Contenido scrolleable
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingL,
                      ),
                      children: [
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
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Tag(
                              label: routine.parteDelCuerpo.displayName,
                              color: AppColors.primary,
                            ),
                            _Tag(
                              label: routine.dificultad.displayName,
                              color: _getDifficultyColor(routine.dificultad),
                            ),
                            _Tag(
                              label: routine.duracionTexto,
                              color: AppColors.info,
                            ),
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
                          return _ExerciseItem(
                            index: index + 1,
                            exercise: exercise,
                          );
                        }),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 20,
                        ),
                      ],
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

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (onEdit != null)
                          _buildOptionItem(
                            icon: Icons.edit_outlined,
                            label: 'Editar',
                            onTap: onEdit!,
                          ),
                        if (onDuplicate != null)
                          _buildOptionItem(
                            icon: Icons.copy_outlined,
                            label: 'Duplicar',
                            onTap: onDuplicate!,
                          ),
                        if (onDelete != null)
                          _buildOptionItem(
                            icon: Icons.delete_outline,
                            label: 'Eliminar',
                            onTap: onDelete!,
                            isDestructive: true,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(12),
                        splashColor: Colors.white.withValues(alpha: 0.1),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Cancelar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isDestructive
                      ? Colors.red.shade300
                      : Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isDestructive
                        ? Colors.red.shade300
                        : Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
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
      ),
    );
  }
}

/// Chip de filtro simple con opción de destrucción
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDestructive
                    ? color.withValues(alpha: 0.1)
                    : AppColors.glassDark),
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          border: Border.all(
            color: isSelected
                ? color
                : (isDestructive ? color : AppColors.glassBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? AppColors.backgroundDark
                    : (isDestructive ? color : AppColors.textPrimaryDark),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.backgroundDark
                    : (isDestructive ? color : AppColors.textPrimaryDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip de filtro con dropdown para seleccionar opciones
class _FilterDropdownChip<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final List<T> options;
  final T? selectedOption;
  final String Function(T) getDisplayName;
  final void Function(T) onSelected;
  final VoidCallback onClear;

  const _FilterDropdownChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.options,
    required this.selectedOption,
    required this.getDisplayName,
    required this.onSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptionsSheet(context),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? AppColors.backgroundDark
                  : AppColors.textPrimaryDark,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.backgroundDark
                    : AppColors.textPrimaryDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: isSelected
                  ? AppColors.backgroundDark
                  : AppColors.textSecondaryDark,
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  // Handle indicator
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Título
                  Text(
                    label,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Opción para limpiar
                  if (isSelected)
                    _buildOptionTile(
                      context: ctx,
                      label: 'Todos',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(ctx);
                        onClear();
                      },
                      showClearIcon: true,
                    ),
                  // Opciones
                  ...options.map(
                    (option) => _buildOptionTile(
                      context: ctx,
                      label: getDisplayName(option),
                      isSelected: selectedOption == option,
                      onTap: () {
                        Navigator.pop(ctx);
                        onSelected(option);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool showClearIcon = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              if (showClearIcon) ...[
                Icon(
                  Icons.clear_all,
                  size: 20,
                  color: AppColors.textSecondaryDark,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimaryDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, size: 20, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo para agregar nuevo ejercicio
class AddExerciseDialog extends ConsumerStatefulWidget {
  const AddExerciseDialog({super.key});

  @override
  ConsumerState<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends ConsumerState<AddExerciseDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _setsController = TextEditingController(text: '4');
  final _repsController = TextEditingController(text: '12');
  final _restController = TextEditingController(text: '60');

  MachineCategory _selectedCategory = MachineCategory.pierna;
  DifficultyLevel _selectedLevel = DifficultyLevel.principiante;
  MachineModel? _selectedMachine;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre no puede estar vacío'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La descripción no puede estar vacía'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedMachine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una máquina'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final sets = int.tryParse(_setsController.text) ?? 4;
    final reps = int.tryParse(_repsController.text) ?? 12;
    final rest = int.tryParse(_restController.text) ?? 60;

    if (sets < 1 || sets > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las series deben estar entre 1 y 10'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (reps < 1 || reps > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las repeticiones deben estar entre 1 y 50'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Generar ID único basado en el nombre
      final id = _nameController.text
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');

      final newExercise = ExerciseModel(
        id: 'custom_$id',
        nombre: _nameController.text.trim(),
        descripcion: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? _selectedMachine?.imageUrl
            : _imageUrlController.text.trim(),
        machineId: _selectedMachine!.id,
        machineName: _selectedMachine!.nombre,
        categoria: _selectedCategory,
        nivel: _selectedLevel,
        defaultSets: sets,
        defaultReps: reps,
        restSeconds: rest,
        createdAt: DateTime.now(),
      );

      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.saveExercise(newExercise);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ejercicio agregado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final machines = ref.watch(machinesProvider).value ?? [];
    final filteredMachines = machines
        .where((m) => m.categoria == _selectedCategory)
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 750),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: Text(
                          'Nuevo Ejercicio',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Nombre
                  _buildLabel('Nombre *'),
                  const SizedBox(height: AppConstants.spacingS),
                  _buildTextField(_nameController, 'Nombre del ejercicio'),
                  const SizedBox(height: AppConstants.spacingM),

                  // Descripción
                  _buildLabel('Descripción *'),
                  const SizedBox(height: AppConstants.spacingS),
                  _buildTextField(
                    _descriptionController,
                    'Descripción del ejercicio',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppConstants.spacingM),

                  // Categoría y Nivel
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Categoría'),
                            const SizedBox(height: AppConstants.spacingS),
                            _buildDropdown<MachineCategory>(
                              value: _selectedCategory,
                              items: MachineCategory.values,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                  _selectedMachine = null;
                                });
                              },
                              labelBuilder: (cat) => cat.displayName,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Nivel'),
                            const SizedBox(height: AppConstants.spacingS),
                            _buildDropdown<DifficultyLevel>(
                              value: _selectedLevel,
                              items: DifficultyLevel.values,
                              onChanged: (value) =>
                                  setState(() => _selectedLevel = value!),
                              labelBuilder: (level) => level.displayName,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingM),

                  // Máquina
                  _buildLabel('Máquina *'),
                  const SizedBox(height: AppConstants.spacingS),
                  _buildDropdown<MachineModel?>(
                    value: _selectedMachine,
                    items: [null, ...filteredMachines],
                    onChanged: (value) => setState(() => _selectedMachine = value),
                    labelBuilder: (machine) =>
                        machine?.nombre ?? 'Seleccionar máquina...',
                  ),
                  const SizedBox(height: AppConstants.spacingM),

                  // Series, Reps y Descanso
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Series'),
                            const SizedBox(height: AppConstants.spacingS),
                            _buildTextField(
                              _setsController,
                              '4',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingS),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Reps'),
                            const SizedBox(height: AppConstants.spacingS),
                            _buildTextField(
                              _repsController,
                              '12',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingS),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Descanso (seg)'),
                            const SizedBox(height: AppConstants.spacingS),
                            _buildTextField(
                              _restController,
                              '60',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingM),

                  // URL Imagen (opcional)
                  _buildLabel('URL Imagen (opcional)'),
                  const SizedBox(height: AppConstants.spacingS),
                  _buildTextField(_imageUrlController, 'https://...'),
                  const SizedBox(height: AppConstants.spacingL),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondaryDark,
                            side: BorderSide(
                              color: AppColors.glassDark,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusM),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveExercise,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusM),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTypography.labelMedium.copyWith(
        color: AppColors.textSecondaryDark,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: AppColors.glassDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) labelBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.glassDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppColors.surfaceDark,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              labelBuilder(item),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
