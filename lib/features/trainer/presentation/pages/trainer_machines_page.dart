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

/// Pantalla de máquinas para el entrenador
class TrainerMachinesPage extends ConsumerStatefulWidget {
  const TrainerMachinesPage({super.key});

  @override
  ConsumerState<TrainerMachinesPage> createState() => _TrainerMachinesPageState();
}

class _TrainerMachinesPageState extends ConsumerState<TrainerMachinesPage> {
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

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildFilters(filters)),
              machinesAsync.when(
                data: (machines) {
                  final filteredMachines = _filterMachines(machines, filters);
                  return _buildMachinesList(filteredMachines);
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
                error: (error, _) => SliverFillRemaining(
                  child: Center(
                    child: Text('Error: $error', style: AppTypography.bodyMediumDark),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
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

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Máquinas',
        style: AppTypography.headlineMedium.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primary),
            onPressed: () => _showFilterBottomSheet(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: TextField(
        controller: _searchController,
        style: AppTypography.bodyMediumDark,
        decoration: InputDecoration(
          hintText: 'Buscar máquinas...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: AppColors.textSecondaryDark),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondaryDark),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(machineFiltersProvider.notifier).state =
                        ref.read(machineFiltersProvider).copyWith(searchQuery: '');
                  },
                )
              : null,
        ),
        onChanged: (value) {
          ref.read(machineFiltersProvider.notifier).state =
              ref.read(machineFiltersProvider).copyWith(searchQuery: value);
        },
      ),
    );
  }

  Widget _buildFilters(MachineFilters filters) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
      child: Row(
        children: [
          _FilterChip(
            label: 'Parte del cuerpo',
            value: filters.category?.displayName,
            onTap: () => _showCategoryPicker(),
            onClear: filters.category != null
                ? () => ref.read(machineFiltersProvider.notifier).state =
                    filters.copyWith(clearCategory: true)
                : null,
          ),
          const SizedBox(width: AppConstants.spacingS),
          _FilterChip(
            label: 'Tipo',
            value: filters.type?.displayName,
            onTap: () => _showTypePicker(),
            onClear: filters.type != null
                ? () => ref.read(machineFiltersProvider.notifier).state =
                    filters.copyWith(clearType: true)
                : null,
          ),
          const SizedBox(width: AppConstants.spacingS),
          _FilterChip(
            label: 'Nivel',
            value: filters.level?.displayName,
            onTap: () => _showLevelPicker(),
            onClear: filters.level != null
                ? () => ref.read(machineFiltersProvider.notifier).state =
                    filters.copyWith(clearLevel: true)
                : null,
          ),
        ],
      ),
    );
  }

  List<MachineModel> _filterMachines(List<MachineModel> machines, MachineFilters filters) {
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

  Widget _buildMachinesList(List<MachineModel> machines) {
    if (machines.isEmpty) {
      return SliverFillRemaining(
        child: Center(
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
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          // Calcular número de columnas basado en el ancho
          final width = constraints.crossAxisExtent;
          int crossAxisCount;
          if (width >= 1200) {
            crossAxisCount = 5;
          } else if (width >= 900) {
            crossAxisCount = 4;
          } else if (width >= 600) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 2;
          }

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: AppConstants.spacingM,
              crossAxisSpacing: AppConstants.spacingM,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final machine = machines[index];
                return _MachineCard(
                  machine: machine,
                  onTap: () => _showMachineDetail(machine),
                );
              },
              childCount: machines.length,
            ),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        onApply: (category, type, level) {
          ref.read(machineFiltersProvider.notifier).state = MachineFilters(
            category: category,
            type: type,
            level: level,
            searchQuery: ref.read(machineFiltersProvider).searchQuery,
          );
        },
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PickerBottomSheet<MachineCategory>(
        title: 'Parte del cuerpo',
        items: MachineCategory.values,
        itemLabel: (item) => item.displayName,
        onSelect: (category) {
          ref.read(machineFiltersProvider.notifier).state =
              ref.read(machineFiltersProvider).copyWith(category: category);
        },
      ),
    );
  }

  void _showTypePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PickerBottomSheet<MachineType>(
        title: 'Tipo de equipo',
        items: MachineType.values,
        itemLabel: (item) => item.displayName,
        onSelect: (type) {
          ref.read(machineFiltersProvider.notifier).state =
              ref.read(machineFiltersProvider).copyWith(type: type);
        },
      ),
    );
  }

  void _showLevelPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PickerBottomSheet<DifficultyLevel>(
        title: 'Nivel',
        items: DifficultyLevel.values,
        itemLabel: (item) => item.displayName,
        onSelect: (level) {
          ref.read(machineFiltersProvider.notifier).state =
              ref.read(machineFiltersProvider).copyWith(level: level);
        },
      ),
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

/// Card de máquina
class _MachineCard extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback onTap;

  const _MachineCard({
    required this.machine,
    required this.onTap,
  });

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
                  ? CachedNetworkImage(
                      imageUrl: machine.imageUrl!,
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
                      errorWidget: (context, url, error) => _buildPlaceholderImage(machine.categoria),
                    )
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
          colors: [
            color.withValues(alpha: 0.3),
            AppColors.surfaceDark,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 64,
          color: color.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

/// Chip de filtro
class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterChip({
    required this.label,
    this.value,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.glassDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          border: Border.all(
            color: hasValue ? AppColors.primary : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasValue ? value! : label,
              style: TextStyle(
                color: hasValue ? AppColors.primary : AppColors.textSecondaryDark,
                fontSize: 14,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (hasValue && onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ] else ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.textSecondaryDark,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet de filtros completo
class _FilterBottomSheet extends StatefulWidget {
  final Function(MachineCategory?, MachineType?, DifficultyLevel?) onApply;

  const _FilterBottomSheet({required this.onApply});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  MachineCategory? _selectedCategory;
  MachineType? _selectedType;
  DifficultyLevel? _selectedLevel;

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Filtros',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Parte del cuerpo
              Text(
                'Parte del cuerpo',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MachineCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    label: Text(category.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.glassDark,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.backgroundDark : AppColors.textPrimaryDark,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Tipo
              Text(
                'Tipo de equipo',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MachineType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return ChoiceChip(
                    label: Text(type.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = selected ? type : null;
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.glassDark,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.backgroundDark : AppColors.textPrimaryDark,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Nivel
              Text(
                'Nivel',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DifficultyLevel.values.map((level) {
                  final isSelected = _selectedLevel == level;
                  return ChoiceChip(
                    label: Text(level.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedLevel = selected ? level : null;
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.glassDark,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.backgroundDark : AppColors.textPrimaryDark,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = null;
                          _selectedType = null;
                          _selectedLevel = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimaryDark,
                        side: const BorderSide(color: AppColors.glassBorder),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_selectedCategory, _selectedType, _selectedLevel);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.backgroundDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet picker genérico
class _PickerBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final Function(T) onSelect;

  const _PickerBottomSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.onSelect,
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
                title,
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              ...items.map((item) => ListTile(
                    title: Text(
                      itemLabel(item),
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    onTap: () {
                      onSelect(item);
                      Navigator.pop(context);
                    },
                  )),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sheet de detalle de máquina
class MachineDetailSheet extends StatelessWidget {
  final MachineModel machine;
  final bool showAddToRoutine;
  final VoidCallback? onAddToRoutine;
  final bool showEditButton;
  final VoidCallback? onEdit;

  const MachineDetailSheet({
    super.key,
    required this.machine,
    this.showAddToRoutine = false,
    this.onAddToRoutine,
    this.showEditButton = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
                padding: EdgeInsets.zero,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.glassBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Imagen
                  if (machine.imageUrl != null)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: machine.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.glassDark,
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.glassDark,
                          child: const Icon(
                            Icons.fitness_center,
                            color: AppColors.textSecondaryDark,
                            size: 64,
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre
                        Text(
                          machine.nombre,
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingS),

                        // Tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Tag(
                              label: machine.categoria.displayName,
                              color: AppColors.primary,
                            ),
                            if (machine.categoriaSecundaria != null)
                              _Tag(
                                label: machine.categoriaSecundaria!.displayName,
                                color: AppColors.info,
                              ),
                            _Tag(
                              label: machine.tipo.displayName,
                              color: AppColors.success,
                            ),
                            _Tag(
                              label: machine.nivel.displayName,
                              color: _getLevelColor(machine.nivel),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingL),

                        // Descripción
                        Text(
                          'Descripción',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingS),
                        Text(
                          machine.descripcion,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondaryDark,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingL),

                        // Grupo muscular primario
                        _InfoSection(
                          icon: Icons.sports_gymnastics,
                          title: 'Grupo Muscular Primario',
                          content: machine.categoria.displayName,
                        ),

                        // Grupo muscular secundario
                        if (machine.categoriaSecundaria != null)
                          _InfoSection(
                            icon: Icons.fitness_center,
                            title: 'Grupo Muscular Secundario',
                            content: machine.categoriaSecundaria!.displayName,
                          ),

                        // Series y reps por defecto
                        _InfoSection(
                          icon: Icons.repeat,
                          title: 'Configuración Sugerida',
                          content: '${machine.defaultSets} series x ${machine.defaultReps} repeticiones',
                        ),

                        // Tips
                        if (machine.tips != null && machine.tips!.isNotEmpty) ...[
                          const SizedBox(height: AppConstants.spacingL),
                          Text(
                            'Tips',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingS),
                          ...machine.tips!.map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.success,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.textSecondaryDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],

                        // Errores comunes
                        if (machine.erroresComunes != null &&
                            machine.erroresComunes!.isNotEmpty) ...[
                          const SizedBox(height: AppConstants.spacingL),
                          Text(
                            'Errores Comunes',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingS),
                          ...machine.erroresComunes!.map((error) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.warning_amber,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        error,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.textSecondaryDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],

                        // Botón editar
                        if (showEditButton) ...[
                          const SizedBox(height: AppConstants.spacingXL),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit),
                              label: const Text('Editar Máquina'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.backgroundDark,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],

                        // Botón agregar a rutina
                        if (showAddToRoutine) ...[
                          const SizedBox(height: AppConstants.spacingXL),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: onAddToRoutine,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar a Rutina'),
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
                ],
              ),
            ),
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

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                Text(
                  content,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w500,
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

/// Diálogo de edición de máquina
class EditMachineDialog extends ConsumerStatefulWidget {
  final MachineModel machine;

  const EditMachineDialog({
    super.key,
    required this.machine,
  });

  @override
  ConsumerState<EditMachineDialog> createState() => _EditMachineDialogState();
}

class _EditMachineDialogState extends ConsumerState<EditMachineDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.machine.nombre);
    _descriptionController = TextEditingController(text: widget.machine.descripcion);
    _imageUrlController = TextEditingController(text: widget.machine.imageUrl ?? '');
    _setsController = TextEditingController(text: widget.machine.defaultSets.toString());
    _repsController = TextEditingController(text: widget.machine.defaultReps.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  Future<void> _saveMachine() async {
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

    final sets = int.tryParse(_setsController.text) ?? 3;
    final reps = int.tryParse(_repsController.text) ?? 12;

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
      final updatedMachine = widget.machine.copyWith(
        nombre: _nameController.text.trim(),
        descripcion: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        defaultSets: sets,
        defaultReps: reps,
      );

      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.updateMachine(widget.machine.id, updatedMachine);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Máquina actualizada correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
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
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: Text(
                          'Editar Máquina',
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
                  Text(
                    'Nombre',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  TextField(
                    controller: _nameController,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nombre de la máquina',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                      filled: true,
                      fillColor: AppColors.glassDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.glassBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),

                  // Descripción
                  Text(
                    'Descripción',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Descripción de la máquina',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                      filled: true,
                      fillColor: AppColors.glassDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.glassBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),

                  // URL de imagen
                  Text(
                    'URL de Imagen (Unsplash)',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  TextField(
                    controller: _imageUrlController,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'https://images.unsplash.com/...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                      filled: true,
                      fillColor: AppColors.glassDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.glassBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),

                  // Series y Repeticiones
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Series',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.textPrimaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingS),
                            TextField(
                              controller: _setsController,
                              keyboardType: TextInputType.number,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimaryDark,
                              ),
                              decoration: InputDecoration(
                                hintText: '3',
                                hintStyle: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondaryDark,
                                ),
                                filled: true,
                                fillColor: AppColors.glassDark,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.glassBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.glassBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
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
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.textPrimaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingS),
                            TextField(
                              controller: _repsController,
                              keyboardType: TextInputType.number,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimaryDark,
                              ),
                              decoration: InputDecoration(
                                hintText: '12',
                                hintStyle: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondaryDark,
                                ),
                                filled: true,
                                fillColor: AppColors.glassDark,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.glassBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.glassBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingXL),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimaryDark,
                            side: const BorderSide(color: AppColors.glassBorder),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveMachine,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.backgroundDark,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.backgroundDark,
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
}
