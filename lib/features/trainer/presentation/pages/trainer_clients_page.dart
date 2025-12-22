import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import 'client_detail_page.dart';

/// Pantalla de clientes para el entrenador (CRM)
class TrainerClientsPage extends ConsumerStatefulWidget {
  const TrainerClientsPage({super.key});

  @override
  ConsumerState<TrainerClientsPage> createState() => _TrainerClientsPageState();
}

class _TrainerClientsPageState extends ConsumerState<TrainerClientsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'todos'; // todos, con_rutina, sin_rutina

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);
    final searchQuery = ref.watch(clientSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildFilterChips()),
              SliverToBoxAdapter(child: _buildStats(clientsAsync)),
              clientsAsync.when(
                data: (clients) {
                  final filteredClients = _filterClients(clients, searchQuery);
                  return _buildClientsList(filteredClients);
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
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
    final unreadCountAsync = ref.watch(unreadNotificationsCountProvider);

    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Clientes',
        style: AppTypography.headlineMedium.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        // Botón de notificaciones con badge
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: unreadCountAsync.when(
            data: (count) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondaryDark),
                  onPressed: () => context.push('/trainer/notifications'),
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            loading: () => IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondaryDark),
              onPressed: () => context.push('/trainer/notifications'),
            ),
            error: (_, __) => IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondaryDark),
              onPressed: () => context.push('/trainer/notifications'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            icon: const Icon(Icons.sort, color: AppColors.textSecondaryDark),
            onPressed: () => _showSortOptions(),
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
          hintText: 'Buscar clientes...',
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
                    ref.read(clientSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
        ),
        onChanged: (value) {
          ref.read(clientSearchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
      child: Row(
        children: [
          _FilterStatusChip(
            label: 'Todos',
            isSelected: _filterStatus == 'todos',
            onTap: () => setState(() => _filterStatus = 'todos'),
          ),
          const SizedBox(width: AppConstants.spacingS),
          _FilterStatusChip(
            label: 'Con rutina',
            isSelected: _filterStatus == 'con_rutina',
            color: AppColors.success,
            onTap: () => setState(() => _filterStatus = 'con_rutina'),
          ),
          const SizedBox(width: AppConstants.spacingS),
          _FilterStatusChip(
            label: 'Sin rutina',
            isSelected: _filterStatus == 'sin_rutina',
            color: AppColors.warning,
            onTap: () => setState(() => _filterStatus = 'sin_rutina'),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(AsyncValue<List<UserModel>> clientsAsync) {
    return clientsAsync.when(
      data: (clients) {
        final total = clients.length;
        final conRutina = clients.where((c) => c.rutinaAsignadaId != null).length;
        final sinRutina = total - conRutina;

        return Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  value: '$total',
                  label: 'Total',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingS),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  value: '$conRutina',
                  label: 'Con rutina',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppConstants.spacingS),
              Expanded(
                child: _StatCard(
                  icon: Icons.warning,
                  value: '$sinRutina',
                  label: 'Sin rutina',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  List<UserModel> _filterClients(List<UserModel> clients, String searchQuery) {
    var filtered = clients;

    // Filtro por estado
    if (_filterStatus == 'con_rutina') {
      filtered = filtered.where((c) => c.rutinaAsignadaId != null).toList();
    } else if (_filterStatus == 'sin_rutina') {
      filtered = filtered.where((c) => c.rutinaAsignadaId == null).toList();
    }

    // Filtro por búsqueda
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where((c) => c.nombre?.toLowerCase().contains(query) ?? false)
          .toList();
    }

    return filtered;
  }

  Widget _buildClientsList(List<UserModel> clients) {
    if (clients.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'No se encontraron clientes',
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
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final client = clients[index];
            return _ClientCard(
              client: client,
              onTap: () => _navigateToClientDetail(client),
            );
          },
          childCount: clients.length,
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
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
                  'Ordenar por',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingM),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha, color: AppColors.primary),
                  title: Text('Nombre (A-Z)', style: AppTypography.bodyLargeDark),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.access_time, color: AppColors.primary),
                  title: Text('Último entrenamiento', style: AppTypography.bodyLargeDark),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.fitness_center, color: AppColors.primary),
                  title: Text('Estado de rutina', style: AppTypography.bodyLargeDark),
                  onTap: () => Navigator.pop(context),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToClientDetail(UserModel client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetailPage(client: client),
      ),
    );
  }
}

/// Card de estadísticas
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
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
      ),
    );
  }
}

/// Chip de filtro por estado
class _FilterStatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterStatusChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
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
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Card de cliente
class _ClientCard extends StatelessWidget {
  final UserModel client;
  final VoidCallback onTap;

  const _ClientCard({
    required this.client,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasRoutine = client.rutinaAsignadaId != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundImage: client.photoUrl != null
                  ? CachedNetworkImageProvider(client.photoUrl!)
                  : null,
              child: client.photoUrl == null
                  ? Text(
                      (client.nombre ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppConstants.spacingM),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          client.nombre ?? 'Sin nombre',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: hasRoutine
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                        ),
                        child: Text(
                          hasRoutine ? 'Con rutina' : 'Sin rutina',
                          style: TextStyle(
                            color: hasRoutine ? AppColors.success : AppColors.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (client.genero != null) ...[
                        Icon(
                          client.genero == UserGender.hombre
                              ? Icons.male
                              : Icons.female,
                          size: 14,
                          color: client.genero == UserGender.hombre
                              ? AppColors.info
                              : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (client.edad != null) ...[
                        Text(
                          '${client.edad} años',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        client.ultimoEntrenamientoTexto,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                  if (client.objetivo != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.flag,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          client.objetivo!.displayName,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
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
