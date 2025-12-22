import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/models/models.dart';
import '../../../../shared/widgets/widgets.dart';

/// Página de administración de productos de la tienda
class StoreAdminPage extends ConsumerStatefulWidget {
  const StoreAdminPage({super.key});

  @override
  ConsumerState<StoreAdminPage> createState() => _StoreAdminPageState();
}

class _StoreAdminPageState extends ConsumerState<StoreAdminPage> {
  ProductCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: AppConstants.spacingM),
                      _buildCategoryFilter(),
                      const SizedBox(height: AppConstants.spacingM),
                    ],
                  ),
                ),
              ),
              productsAsync.when(
                data: (products) => _buildProductsList(products),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Error: $error',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.backgroundDark,
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/trainer');
          }
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(
            60,
            60,
            AppConstants.spacingL,
            AppConstants.spacingM,
          ),
          child: Row(
            children: [
              Text(
                'Administrar Tienda',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      style: const TextStyle(color: AppColors.textPrimaryDark),
      decoration: InputDecoration(
        hintText: 'Buscar productos...',
        hintStyle: TextStyle(color: AppColors.textSecondaryDark.withValues(alpha: 0.6)),
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip('Todos', null),
          const SizedBox(width: AppConstants.spacingS),
          ...ProductCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: AppConstants.spacingS),
              child: _buildCategoryChip(
                '${category.emoji} ${category.displayName}',
                category,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, ProductCategory? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedCategory = selected ? category : null);
      },
      backgroundColor: AppColors.surfaceDark,
      selectedColor: AppColors.primary.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      checkmarkColor: AppColors.primary,
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.transparent,
        width: 1.5,
      ),
    );
  }

  Widget _buildProductsList(List<ProductModel> allProducts) {
    // Filtrar productos
    var products = allProducts;

    if (_selectedCategory != null) {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      products = products.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);
      }).toList();
    }

    if (products.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: AppColors.textSecondaryDark,
              ),
              SizedBox(height: AppConstants.spacingM),
              Text(
                'No hay productos',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
            final product = products[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
              child: _buildProductCard(product),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GlassCard(
      onTap: () => _editProduct(product),
      child: Row(
        children: [
          // Imagen del producto
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 80,
                height: 80,
                color: AppColors.surfaceDark,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 80,
                height: 80,
                color: AppColors.surfaceDark,
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Badge de estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: product.isActive
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.error.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                      ),
                      child: Text(
                        product.isActive ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                          color: product.isActive ? AppColors.success : AppColors.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.category.emoji} ${product.category.displayName}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Text(
                      'Stock: ${product.stock}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          // Botón de más opciones
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondaryDark),
            color: AppColors.surfaceDark,
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editProduct(product);
                  break;
                case 'toggle':
                  _toggleProductStatus(product);
                  break;
                case 'delete':
                  _confirmDelete(product);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Editar', style: TextStyle(color: AppColors.textPrimaryDark)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      product.isActive ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product.isActive ? 'Desactivar' : 'Activar',
                      style: const TextStyle(color: AppColors.textPrimaryDark),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error, size: 20),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: AppColors.textPrimaryDark)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _addProduct(),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Agregar Producto',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Acciones
  void _addProduct() {
    context.push('/trainer/store-admin/product/new');
  }

  void _editProduct(ProductModel product) {
    context.push('/trainer/store-admin/product/${product.id}');
  }

  Future<void> _toggleProductStatus(ProductModel product) async {
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.toggleProductStatus(product.id, !product.isActive);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Producto ${product.isActive ? "desactivado" : "activado"}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          'Eliminar Producto',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${product.name}"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final firebaseService = ref.read(firebaseServiceProvider);
        await firebaseService.deleteProduct(product.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
