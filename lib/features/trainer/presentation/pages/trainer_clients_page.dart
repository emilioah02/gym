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
    final cachedClients = ref.watch(cachedClientsProvider);

    // Actualizar caché cuando hay datos nuevos
    ref.listen<AsyncValue<List<UserModel>>>(clientsProvider, (_, next) {
      if (next.hasValue && next.value != null) {
        ref.read(cachedClientsProvider.notifier).state = next.value;
      }
    });

    // Usar datos cacheados si el provider está cargando o tiene error
    final List<UserModel> clients;
    final bool isLoading;
    final bool hasError;

    if (clientsAsync.hasValue) {
      clients = clientsAsync.value!;
      isLoading = false;
      hasError = false;
    } else if (cachedClients != null) {
      // Usar caché mientras carga o si hay error
      clients = cachedClients;
      isLoading = clientsAsync.isLoading;
      hasError = false; // No mostrar error si tenemos caché
    } else {
      // Primera carga sin caché
      clients = [];
      isLoading = clientsAsync.isLoading;
      hasError = clientsAsync.hasError;
    }

    final filteredClients = _filterClients(clients, searchQuery);

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
              SliverToBoxAdapter(child: _buildStats(clients)),
              // Mostrar lista directamente, sin estados de carga
              if (hasError && clients.isEmpty)
                SliverFillRemaining(
                  child: Center(
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
                          'Error al cargar clientes',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingS),
                        Text(
                          'No se pudieron cargar los clientes.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingL),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(clientsProvider),
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
                )
              else
                _buildClientsList(filteredClients),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          // Indicador sutil de actualización en la parte superior
          if (isLoading && clients.isNotEmpty)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: AppColors.primary,
              ),
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
                        Icons.people_rounded,
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
                            'Clientes',
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Gestiona tus clientes',
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

  Widget _buildStats(List<UserModel> clients) {
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
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          // Determinar número de columnas según el ancho disponible
          int crossAxisCount = 1;
          if (constraints.crossAxisExtent >= 1400) {
            crossAxisCount = 4; // 4 columnas en pantallas muy grandes
          } else if (constraints.crossAxisExtent >= 1000) {
            crossAxisCount = 3; // 3 columnas en pantallas grandes
          } else if (constraints.crossAxisExtent >= 700) {
            crossAxisCount = 2; // 2 columnas en tablets
          }

          // En móvil usar lista, en pantallas grandes usar grid
          if (crossAxisCount == 1) {
            return SliverList(
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
            );
          }

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 450, // Ancho máximo por tarjeta
              crossAxisSpacing: AppConstants.spacingM,
              mainAxisSpacing: AppConstants.spacingM,
              mainAxisExtent: 100, // Altura fija que permite el contenido
            ),
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
          );
        },
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

/// Card de cliente con diseño autoajustable
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        child: Row(
          children: [
            // Avatar - tamaño fijo
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundImage: client.photoUrl != null
                  ? CachedNetworkImageProvider(client.photoUrl!)
                  : null,
              child: client.photoUrl == null
                  ? Text(
                      (client.nombre ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppConstants.spacingS),
            // Info - flexible
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Primera fila: Nombre + Badge estado
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          client.nombre ?? 'Sin nombre',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge de estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
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
                  // Segunda fila: Info secundaria con Flexible
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
                        const SizedBox(width: 2),
                      ],
                      if (client.edad != null) ...[
                        Text(
                          '${client.edad} años',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondaryDark,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          client.ultimoEntrenamientoTexto,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Tercera fila: Objetivo (solo si existe y hay espacio)
                  if (client.objetivo != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.flag,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            client.objetivo!.displayName,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondaryDark,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
