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
import 'client_orders_page.dart';

/// Provider para el carrito de compras
final cartProvider = StateNotifierProvider<CartNotifier, Map<String, int>>((
  ref,
) {
  return CartNotifier();
});

/// Notifier para manejar el estado del carrito
class CartNotifier extends StateNotifier<Map<String, int>> {
  CartNotifier() : super({});

  void addItem(String productId) {
    state = {...state, productId: (state[productId] ?? 0) + 1};
  }

  void removeItem(String productId) {
    if (state[productId] == null) return;

    if (state[productId]! <= 1) {
      final newState = Map<String, int>.from(state);
      newState.remove(productId);
      state = newState;
    } else {
      state = {...state, productId: state[productId]! - 1};
    }
  }

  void clearCart() {
    state = {};
  }

  int get totalItems {
    return state.values.fold(0, (sum, quantity) => sum + quantity);
  }
}

/// Configuración de degradados e iconos por categoría
class CategoryConfig {
  final List<Color> gradientColors;
  final IconData icon;

  const CategoryConfig({
    required this.gradientColors,
    required this.icon,
  });

  static CategoryConfig getConfig(ProductCategory category) {
    switch (category) {
      case ProductCategory.bebidas:
        return const CategoryConfig(
          gradientColors: [Color(0xFF00BCD4), Color(0xFF0288D1)],
          icon: Icons.local_drink,
        );
      case ProductCategory.suplementos:
        return const CategoryConfig(
          gradientColors: [Color(0xFFFF9800), Color(0xFFFF5722)],
          icon: Icons.science,
        );
      case ProductCategory.ropa:
        return const CategoryConfig(
          gradientColors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
          icon: Icons.checkroom,
        );
      case ProductCategory.accesorios:
        return const CategoryConfig(
          gradientColors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
          icon: Icons.fitness_center,
        );
      case ProductCategory.otros:
        return const CategoryConfig(
          gradientColors: [Color(0xFF607D8B), Color(0xFF455A64)],
          icon: Icons.shopping_bag,
        );
    }
  }
}

/// Página de tienda para clientes
class ClientStorePage extends ConsumerStatefulWidget {
  const ClientStorePage({super.key});

  @override
  ConsumerState<ClientStorePage> createState() => _ClientStorePageState();
}

class _ClientStorePageState extends ConsumerState<ClientStorePage> {
  ProductCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final productsAsync = ref.watch(activeProductsProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryFilter(),
                      const SizedBox(height: AppConstants.spacingL),
                    ],
                  ),
                ),
              ),
              productsAsync.when(
                data: (products) => _buildProductGrid(products, screenWidth),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
                error: (error, _) => SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Error al cargar productos',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          // Floating cart button
          if (cartNotifier.totalItems > 0)
            Positioned(
              right: AppConstants.spacingM,
              bottom: AppConstants.spacingXL,
              child: _buildCartButton(cart, productsAsync.value ?? []),
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
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.backgroundDark,
          ],
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
                  Icons.shopping_bag,
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
                      'Tienda',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Todo lo que necesitas para entrenar',
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
              // Botón de pedidos
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClientOrdersPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      (null, 'Todos'),
      (ProductCategory.bebidas, 'Bebidas'),
      (ProductCategory.suplementos, 'Suplementos'),
      (ProductCategory.ropa, 'Ropa'),
      (ProductCategory.accesorios, 'Accesorios'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((item) {
          final category = item.$1;
          final label = item.$2;
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.spacingS),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: AppConstants.animationFast,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: AppConstants.spacingS,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.glassDark,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.glassBorder,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.backgroundDark
                        : AppColors.textPrimaryDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products, double screenWidth) {
    final filteredProducts = _selectedCategory == null
        ? products
        : products.where((p) => p.category == _selectedCategory).toList();

    // Grid responsive: 2 columnas para móvil, 3-4 para tablet, 4-6 para desktop
    int crossAxisCount = 2;
    if (screenWidth > 1200) {
      crossAxisCount = 5;
    } else if (screenWidth > 900) {
      crossAxisCount = 4;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    }

    if (filteredProducts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'No hay productos disponibles',
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
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: AppConstants.spacingM,
          mainAxisSpacing: AppConstants.spacingM,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = filteredProducts[index];
            return _ProductCard(product: product);
          },
          childCount: filteredProducts.length,
        ),
      ),
    );
  }

  Widget _buildCartButton(Map<String, int> cart, List<ProductModel> products) {
    final cartNotifier = ref.read(cartProvider.notifier);

    return GestureDetector(
      onTap: () => _showCartBottomSheet(context, cart, products),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingL,
              vertical: AppConstants.spacingM,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart,
                  color: AppColors.backgroundDark,
                ),
                const SizedBox(width: AppConstants.spacingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusRound,
                    ),
                  ),
                  child: Text(
                    '${cartNotifier.totalItems}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context, Map<String, int> cart, List<ProductModel> products) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CartBottomSheet(cart: cart, products: products),
    );
  }
}

/// Widget mejorado de imagen de producto con fallback visual
class _ProductImage extends StatelessWidget {
  final ProductModel product;

  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    final config = CategoryConfig.getConfig(product.category);

    return CachedNetworkImage(
      imageUrl: product.imageUrl,
      height: 140,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildShimmerPlaceholder(config),
      errorWidget: (context, url, error) => _buildFallbackGradient(config),
    );
  }

  Widget _buildShimmerPlaceholder(CategoryConfig config) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.gradientColors[0].withValues(alpha: 0.3),
            config.gradientColors[1].withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white.withValues(alpha: 0.7),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildFallbackGradient(CategoryConfig config) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: config.gradientColors,
        ),
      ),
      child: Center(
        child: Icon(
          config.icon,
          size: 50,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

/// Widget de tarjeta de producto mejorado
class _ProductCard extends ConsumerWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final quantity = cart[product.id] ?? 0;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto con fallback mejorado
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusM),
            ),
            child: Stack(
              children: [
                _ProductImage(product: product),
                // Badge de categoría
                Positioned(
                  top: 8,
                  right: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.category.emoji,
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.category.displayName,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Información del producto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _AddToCartButton(
                        productId: product.id,
                        quantity: quantity,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón para agregar al carrito
class _AddToCartButton extends ConsumerWidget {
  final String productId;
  final int quantity;

  const _AddToCartButton({required this.productId, required this.quantity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);

    if (quantity == 0) {
      return GestureDetector(
        onTap: () => cartNotifier.addItem(productId),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: const Icon(
            Icons.add,
            color: AppColors.backgroundDark,
            size: 20,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => cartNotifier.removeItem(productId),
            child: const Icon(Icons.remove, color: AppColors.primary, size: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => cartNotifier.addItem(productId),
            child: const Icon(Icons.add, color: AppColors.primary, size: 16),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet del carrito
class _CartBottomSheet extends ConsumerWidget {
  final Map<String, int> cart;
  final List<ProductModel> products;

  const _CartBottomSheet({required this.cart, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusXL),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusXL),
            ),
            border: Border.all(color: AppColors.glassBorder),
          ),
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
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

              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tu carrito',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondaryDark,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Lista de productos en el carrito
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final productId = cart.keys.elementAt(index);
                  final quantity = cart[productId]!;
                  final product = products.firstWhere(
                    (p) => p.id == productId,
                    orElse: () => ProductModel(
                      id: productId,
                      name: 'Producto no encontrado',
                      description: '',
                      price: 0,
                      imageUrl: '',
                      category: ProductCategory.otros,
                      isActive: true,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      stock: 0,
                    ),
                  );

                  return _CartItem(product: product, quantity: quantity);
                },
              ),

              const Divider(color: AppColors.glassBorder, height: 32),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '\$${_calculateTotal(cart, products).toStringAsFixed(2)} MXN',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingL),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        cartNotifier.clearCart();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusM,
                          ),
                        ),
                      ),
                      child: const Text('Vaciar'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _createStoreOrder(context, cart, products, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.backgroundDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusM,
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text('Enviar pedido'),
                        ],
                      ),
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

  double _calculateTotal(Map<String, int> cart, List<ProductModel> products) {
    double total = 0;
    cart.forEach((productId, quantity) {
      final product = products.firstWhere(
        (p) => p.id == productId,
        orElse: () => ProductModel(
          id: productId,
          name: '',
          description: '',
          price: 0,
          imageUrl: '',
          category: ProductCategory.otros,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          stock: 0,
        ),
      );
      total += product.price * quantity;
    });
    return total;
  }

  Future<void> _createStoreOrder(BuildContext context, Map<String, int> cart, List<ProductModel> products, WidgetRef ref) async {
    try {
      final user = ref.read(userModelProvider).value;
      if (user == null) {
        throw Exception('Usuario no encontrado');
      }

      // Convertir el carrito a lista de OrderItems
      final items = <OrderItem>[];
      cart.forEach((productId, quantity) {
        final product = products.firstWhere((p) => p.id == productId);
        items.add(OrderItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: quantity,
          category: product.category.displayName,
        ));
      });

      final total = _calculateTotal(cart, products);

      // Crear el pedido
      final order = StoreOrderModel(
        id: '',
        clienteId: user.uid,
        clienteNombre: user.nombre ?? 'Cliente',
        clientePhotoUrl: user.photoUrl,
        items: items,
        total: total,
        estado: OrderStatus.pendiente,
        fechaPedido: DateTime.now(),
      );

      // Guardar en Firestore
      await ref.read(firebaseServiceProvider).createStoreOrder(order);

      // Limpiar el carrito
      ref.read(cartProvider.notifier).clearCart();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pedido enviado exitosamente. El coach te notificará cuando esté listo.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el pedido: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
          ),
        );
      }
    }
  }
}

/// Widget de item en el carrito con imagen mejorada
class _CartItem extends ConsumerWidget {
  final ProductModel product;
  final int quantity;

  const _CartItem({required this.product, required this.quantity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final config = CategoryConfig.getConfig(product.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        children: [
          // Imagen mejorada
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      config.gradientColors[0].withValues(alpha: 0.3),
                      config.gradientColors[1].withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white.withValues(alpha: 0.7),
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: config.gradientColors,
                  ),
                ),
                child: Icon(
                  config.icon,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),

          // Info del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${product.price.toStringAsFixed(2)} MXN',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),

          // Controles de cantidad
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.glassDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => cartNotifier.removeItem(product.id),
                  child: const Icon(
                    Icons.remove,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => cartNotifier.addItem(product.id),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.primary,
                    size: 20,
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
