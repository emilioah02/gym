import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/machines_data.dart';

/// Routines List Page with gender toggle and machine library
/// Muestra rutinas creadas por entrenadores desde Firestore
class RoutinesListPage extends ConsumerStatefulWidget {
  const RoutinesListPage({super.key});

  @override
  ConsumerState<RoutinesListPage> createState() => _RoutinesListPageState();
}

class _RoutinesListPageState extends ConsumerState<RoutinesListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RoutineGender _selectedGender = RoutineGender.unisex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildGenderToggle()),
              SliverToBoxAdapter(child: _buildTabBar()),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRoutinesList(),
                    _buildMachinesList(),
                  ],
                ),
              ),
            ],
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
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
        onPressed: () => context.pop(),
      ),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explorar',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Rutinas y máquinas disponibles',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
        tabs: const [
          Tab(text: 'Rutinas'),
          Tab(text: 'Máquinas (35)'),
        ],
      ),
    );
  }

  Widget _buildRoutinesList() {
    final routinesAsync = ref.watch(routinesProvider);

    return routinesAsync.when(
      data: (allRoutines) {
        // Filtrar rutinas públicas (no plantillas) y por género seleccionado
        final filteredRoutines = allRoutines.where((routine) {
          // Solo rutinas públicas (no plantillas)
          if (routine.esPlantilla) return false;

          // Filtro por género
          if (_selectedGender == RoutineGender.unisex) return true;
          return routine.genero == _selectedGender || routine.genero == RoutineGender.unisex;
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
                    'Los entrenadores pronto crearán rutinas para ti',
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
            // Determinar número de columnas según el ancho disponible
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

            // En móvil usar lista, en pantallas grandes usar grid
            if (crossAxisCount == 1) {
              return ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                itemCount: filteredRoutines.length,
                itemBuilder: (context, index) {
                  final routine = filteredRoutines[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                    child: RoutineTile(
                      title: routine.nombre,
                      subtitle: routine.descripcion ?? routine.parteDelCuerpo.displayName,
                      imageUrl: routine.imageUrl,
                      exerciseCount: routine.ejercicioCount,
                      duration: routine.duracionTexto,
                      onTap: () {
                        // TODO: Navegar a detalle de rutina
                        // context.go('/routines/${routine.id}');
                      },
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
                return RoutineTile(
                  title: routine.nombre,
                  subtitle: routine.descripcion ?? routine.parteDelCuerpo.displayName,
                  imageUrl: routine.imageUrl,
                  exerciseCount: routine.ejercicioCount,
                  duration: routine.duracionTexto,
                  onTap: () {
                    // TODO: Navegar a detalle de rutina
                    // context.go('/routines/${routine.id}');
                  },
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
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'Error al cargar rutinas',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                error.toString(),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachinesList() {
    final machines = MachinesData.allMachines;

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      itemCount: machines.length,
      itemBuilder: (context, index) {
        final machine = machines[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
          child: MachineTile(
            name: machine.name,
            description: machine.description,
            sets: machine.defaultSets,
            reps: machine.defaultReps,
            imageUrl: machine.imageUrl,
          ),
        );
      },
    );
  }
}

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
