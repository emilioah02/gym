import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/models/routine_model.dart';
import '../../data/routines_data.dart';

/// Routine Detail Page showing all exercises with sets/reps
class RoutineDetailPage extends StatelessWidget {
  final String routineId;

  const RoutineDetailPage({super.key, required this.routineId});

  @override
  Widget build(BuildContext context) {
    final routine = RoutinesData.getById(routineId);

    if (routine == null) {
      return _buildNotFound(context);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(context, routine),
              SliverToBoxAdapter(child: _buildHeader(routine)),
              SliverToBoxAdapter(child: _buildStats(routine)),
              SliverToBoxAdapter(child: _buildExercisesHeader(routine)),
              _buildExercisesList(routine),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingXXL),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: AppColors.backgroundDark),
        Positioned(
          top: -50,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, RoutineModel routine) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.backgroundDark,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.glassDark,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
        ),
        onPressed: () => context.go('/routines'),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.backgroundDark,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.fitness_center,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(RoutineModel routine) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: AppConstants.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: _getGenderColor(routine.gender).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                ),
                child: Text(
                  routine.gender.displayName,
                  style: AppTypography.labelSmall.copyWith(
                    color: _getGenderColor(routine.gender),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            routine.name,
            style: AppTypography.headlineLargeDark,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            routine.description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(RoutineModel routine) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      child: GlassCard(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.fitness_center,
              value: '${routine.exerciseCount}',
              label: 'Ejercicios',
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.glassBorder,
            ),
            _StatItem(
              icon: Icons.schedule,
              value: routine.duration,
              label: 'Duración',
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.glassBorder,
            ),
            _StatItem(
              icon: Icons.local_fire_department,
              value: '${routine.exerciseCount * 50}',
              label: 'Cal. Est.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesHeader(RoutineModel routine) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ejercicios',
            style: AppTypography.headlineSmallDark,
          ),
          Text(
            '${routine.exerciseCount} en total',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  SliverList _buildExercisesList(RoutineModel routine) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final exercise = routine.exercises[index];
          return Padding(
            padding: EdgeInsets.only(
              left: AppConstants.spacingL,
              right: AppConstants.spacingL,
              bottom: index < routine.exercises.length - 1
                  ? AppConstants.spacingM
                  : 0,
            ),
            child: _ExerciseCard(
              index: index + 1,
              exercise: exercise,
            ),
          );
        },
        childCount: routine.exercises.length,
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/routines'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondaryDark,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'Rutina no encontrada',
              style: AppTypography.titleLargeDark,
            ),
            const SizedBox(height: AppConstants.spacingL),
            PrimaryButton(
              text: 'Ver Rutinas',
              width: 200,
              onPressed: () => context.go('/routines'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGenderColor(RoutineGender gender) {
    switch (gender) {
      case RoutineGender.men:
        return AppColors.info;
      case RoutineGender.women:
        return AppColors.error;
      case RoutineGender.unisex:
        return AppColors.primary;
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: AppConstants.spacingXS),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
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

class _ExerciseCard extends StatelessWidget {
  final int index;
  final RoutineExercise exercise;

  const _ExerciseCard({
    required this.index,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Image
          if (exercise.machine.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.radiusM),
                topRight: Radius.circular(AppConstants.radiusM),
              ),
              child: Stack(
                children: [
                  Image.network(
                    exercise.machine.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: AppColors.glassDark,
                        child: const Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: 40,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      );
                    },
                  ),
                  // Index number overlay
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
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Sets x Reps overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingM,
                        vertical: AppConstants.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${exercise.sets} × ${exercise.reps}',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Exercise Info
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.machine.name,
                  style: AppTypography.titleMediumDark,
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  exercise.machine.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (exercise.notes != null) ...[
                  const SizedBox(height: AppConstants.spacingS),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingS),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exercise.notes!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
