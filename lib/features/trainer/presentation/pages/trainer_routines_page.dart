import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import 'routine_builder_page.dart';
import 'weekly_routine_builder_page.dart';

/// Pantalla de rutinas para el entrenador
class TrainerRoutinesPage extends ConsumerStatefulWidget {
  const TrainerRoutinesPage({super.key});

  @override
  ConsumerState<TrainerRoutinesPage> createState() => _TrainerRoutinesPageState();
}

class _TrainerRoutinesPageState extends ConsumerState<TrainerRoutinesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: _buildTabBar(),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _RoutinesTab(),
                _TemplatesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
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
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Rutinas',
        style: AppTypography.headlineMedium.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            icon: const Icon(Icons.calendar_month, color: AppColors.primary),
            tooltip: 'Crear semana de rutinas',
            onPressed: () => _navigateToWeeklyBuilder(),
          ),
        ),
      ],
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
        labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Mis Rutinas'),
          Tab(text: 'Plantillas'),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateOptions(),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.backgroundDark,
      icon: const Icon(Icons.add),
      label: const Text('Crear'),
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
        builder: (context) => RoutineBuilderPage(
          mode: mode,
          template: template,
        ),
      ),
    );
  }

  void _navigateToWeeklyBuilder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WeeklyRoutineBuilderPage(),
      ),
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
          _navigateToBuilder(RoutineBuilderMode.fromTemplate, template: template);
        },
      ),
    );
  }
}

/// Tab de rutinas del entrenador
class _RoutinesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesProvider);

    return routinesAsync.when(
      data: (routines) {
        final userRoutines = routines.where((r) => !r.esPlantilla).toList();

        if (userRoutines.isEmpty) {
          return _EmptyState(
            icon: Icons.fitness_center,
            title: 'Sin rutinas',
            subtitle: 'Crea tu primera rutina presionando el botón +',
          );
        }

        // Agrupar por dificultad
        final grouped = <RoutineDifficulty, List<RoutineModel>>{};
        for (final routine in userRoutines) {
          grouped.putIfAbsent(routine.dificultad, () => []).add(routine);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          itemCount: RoutineDifficulty.values.length,
          itemBuilder: (context, index) {
            final difficulty = RoutineDifficulty.values[index];
            final routinesInGroup = grouped[difficulty] ?? [];

            if (routinesInGroup.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(difficulty).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                        ),
                        child: Text(
                          difficulty.displayName,
                          style: TextStyle(
                            color: _getDifficultyColor(difficulty),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${routinesInGroup.length})',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                ...routinesInGroup.map((routine) => _RoutineCard(
                      routine: routine,
                      onTap: () => _showRoutineOptions(context, ref, routine),
                    )),
              ],
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Text('Error: $error', style: AppTypography.bodyMediumDark),
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

  void _showRoutineOptions(BuildContext context, WidgetRef ref, RoutineModel routine) {
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
            await ref.read(firebaseServiceProvider).duplicateRoutine(
                  routine.id,
                  '${routine.nombre} (copia)',
                );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rutina duplicada')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
        onDelete: () async {
          Navigator.pop(context);
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              title: Text('Eliminar rutina', style: AppTypography.titleLargeDark),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          }
        },
      ),
    );
  }
}

/// Tab de plantillas
class _TemplatesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesProvider);

    return routinesAsync.when(
      data: (routines) {
        final templates = routines.where((r) => r.esPlantilla).toList();

        if (templates.isEmpty) {
          return _EmptyState(
            icon: Icons.description,
            title: 'Sin plantillas',
            subtitle: 'Las plantillas aparecerán aquí',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return _RoutineCard(
              routine: template,
              isTemplate: true,
              onTap: () => _showTemplateDetail(context, template),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Text('Error: $error', style: AppTypography.bodyMediumDark),
      ),
    );
  }

  void _showTemplateDetail(BuildContext context, RoutineModel template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RoutineDetailSheet(
        routine: template,
        onUseTemplate: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoutineBuilderPage(
                mode: RoutineBuilderMode.fromTemplate,
                template: template,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Card de rutina
class _RoutineCard extends StatelessWidget {
  final RoutineModel routine;
  final bool isTemplate;
  final VoidCallback onTap;

  const _RoutineCard({
    required this.routine,
    this.isTemplate = false,
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
            // Indicador de color por dificultad
            Container(
              width: 4,
              height: 80,
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
                  Row(
                    children: [
                      if (isTemplate)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
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
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          routine.nombre,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                        label: '${routine.ejercicioCount} ejercicios',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(routine.dificultad).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          routine.dificultad.displayName,
                          style: TextStyle(
                            color: _getDifficultyColor(routine.dificultad),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (routine.genero != RoutineGender.unisex) ...[
                        const SizedBox(width: 8),
                        Icon(
                          routine.genero == RoutineGender.hombre
                              ? Icons.male
                              : Icons.female,
                          size: 16,
                          color: routine.genero == RoutineGender.hombre
                              ? Colors.blue
                              : Colors.pink,
                        ),
                      ],
                    ],
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
                    subtitle: 'Combina ejercicios de cualquier parte del cuerpo',
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
                  SizedBox(height: MediaQuery.of(context).padding.bottom + AppConstants.spacingM),
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
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondaryDark,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet de opciones de rutina
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
                routine.nombre,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingL),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: Text('Editar', style: AppTypography.bodyLargeDark),
                onTap: onEdit,
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: AppColors.info),
                title: Text('Duplicar', style: AppTypography.bodyLargeDark),
                onTap: onDuplicate,
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: Text(
                  'Eliminar',
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
                ),
                onTap: onDelete,
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
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
                        final templates = routines.where((r) => r.esPlantilla).toList();

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                          ),
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            final template = templates[index];
                            return _RoutineCard(
                              routine: template,
                              isTemplate: true,
                              onTap: () => onSelect(template),
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

/// Sheet de detalle de rutina
class _RoutineDetailSheet extends StatelessWidget {
  final RoutineModel routine;
  final VoidCallback? onUseTemplate;

  const _RoutineDetailSheet({
    required this.routine,
    this.onUseTemplate,
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
                  if (onUseTemplate != null) ...[
                    const SizedBox(height: AppConstants.spacingXL),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onUseTemplate,
                        icon: const Icon(Icons.content_copy),
                        label: const Text('Usar esta plantilla'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.backgroundDark,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
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

  const _ExerciseItem({
    required this.index,
    required this.exercise,
  });

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
