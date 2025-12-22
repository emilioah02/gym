import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/models/routine_model.dart';
import '../../data/routines_data.dart';
import '../../data/machines_data.dart';

/// Routines List Page with gender toggle and machine library
class RoutinesListPage extends StatefulWidget {
  const RoutinesListPage({super.key});

  @override
  State<RoutinesListPage> createState() => _RoutinesListPageState();
}

class _RoutinesListPageState extends State<RoutinesListPage>
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
            isSelected: _selectedGender == RoutineGender.men,
            onTap: () => setState(() => _selectedGender = RoutineGender.men),
          ),
          const SizedBox(width: AppConstants.spacingS),
          _GenderChip(
            label: 'Mujeres',
            icon: Icons.female,
            isSelected: _selectedGender == RoutineGender.women,
            onTap: () => setState(() => _selectedGender = RoutineGender.women),
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
    final routines = RoutinesData.getByGender(_selectedGender);

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      itemCount: routines.length,
      itemBuilder: (context, index) {
        final routine = routines[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
          child: RoutineTile(
            title: routine.name,
            subtitle: routine.description,
            imageUrl: routine.imageUrl,
            exerciseCount: routine.exerciseCount,
            duration: routine.duration,
            onTap: () => context.go('/routines/${routine.id}'),
          ),
        );
      },
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
