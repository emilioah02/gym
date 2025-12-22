import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/models/models.dart';
import '../../../../shared/widgets/widgets.dart';

/// Página de formulario para agregar/editar productos
class ProductFormPage extends ConsumerStatefulWidget {
  final String? productId;

  const ProductFormPage({super.key, this.productId});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _stockController = TextEditingController();

  ProductCategory _selectedCategory = ProductCategory.bebidas;
  bool _isActive = true;
  bool _isLoading = false;
  ProductModel? _existingProduct;

  bool get isEditing => widget.productId != null && widget.productId != 'new';

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    try {
      setState(() => _isLoading = true);
      final firebaseService = ref.read(firebaseServiceProvider);
      final product = await firebaseService.getProduct(widget.productId!);

      if (product != null && mounted) {
        setState(() {
          _existingProduct = product;
          _nameController.text = product.name;
          _descriptionController.text = product.description;
          _priceController.text = product.price.toString();
          _imageUrlController.text = product.imageUrl;
          _stockController.text = product.stock.toString();
          _selectedCategory = product.category;
          _isActive = product.isActive;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar producto: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _stockController.dispose();
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
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.spacingXL),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _buildForm(),
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
        onPressed: () => context.pop(),
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
                isEditing ? 'Editar Producto' : 'Nuevo Producto',
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

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview de imagen
            if (_imageUrlController.text.isNotEmpty) ...[
              _buildImagePreview(),
              const SizedBox(height: AppConstants.spacingL),
            ],

            // URL de imagen (Unsplash)
            _buildSectionTitle('Imagen del Producto'),
            const SizedBox(height: AppConstants.spacingS),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _imageUrlController,
                    style: const TextStyle(color: AppColors.textPrimaryDark),
                    decoration: InputDecoration(
                      labelText: 'URL de Unsplash',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondaryDark.withValues(alpha: 0.8),
                      ),
                      hintText: 'https://images.unsplash.com/...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.primary),
                        onPressed: () => setState(() {}),
                        tooltip: 'Actualizar vista previa',
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una URL de imagen';
                      }
                      if (!value.startsWith('http')) {
                        return 'La URL debe comenzar con http:// o https://';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Auto-actualizar preview después de un delay
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) setState(() {});
                      });
                    },
                  ),
                  const Divider(color: AppColors.surfaceDark, height: 1),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Tip: Busca imágenes en unsplash.com y copia la URL',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondaryDark,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Nombre del producto
            _buildSectionTitle('Información Básica'),
            const SizedBox(height: AppConstants.spacingS),
            GlassCard(
              child: TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                decoration: InputDecoration(
                  labelText: 'Nombre del Producto',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.8),
                  ),
                  hintText: 'Ej: Proteína Whey',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Descripción
            GlassCard(
              child: TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.8),
                  ),
                  hintText: 'Describe el producto...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Precio y Stock
            _buildSectionTitle('Precio y Disponibilidad'),
            const SizedBox(height: AppConstants.spacingS),
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    child: TextFormField(
                      controller: _priceController,
                      style: const TextStyle(color: AppColors.textPrimaryDark),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        labelStyle: TextStyle(
                          color: AppColors.textSecondaryDark.withValues(alpha: 0.8),
                        ),
                        prefixText: '\$ ',
                        prefixStyle: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa precio';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Precio inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: GlassCard(
                    child: TextFormField(
                      controller: _stockController,
                      style: const TextStyle(color: AppColors.textPrimaryDark),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Stock',
                        labelStyle: TextStyle(
                          color: AppColors.textSecondaryDark.withValues(alpha: 0.8),
                        ),
                        suffixText: 'unidades',
                        suffixStyle: TextStyle(
                          color: AppColors.textSecondaryDark.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa stock';
                        }
                        final stock = int.tryParse(value);
                        if (stock == null || stock < 0) {
                          return 'Stock inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Categoría
            _buildSectionTitle('Categoría'),
            const SizedBox(height: AppConstants.spacingS),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona una categoría',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Wrap(
                    spacing: AppConstants.spacingS,
                    runSpacing: AppConstants.spacingS,
                    children: ProductCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(
                          '${category.emoji} ${category.displayName}',
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = category);
                          }
                        },
                        backgroundColor: AppColors.surfaceDark,
                        selectedColor: AppColors.primary.withValues(alpha: 0.3),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondaryDark,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 1.5,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Estado (Activo/Inactivo)
            GlassCard(
              child: SwitchListTile(
                title: const Text(
                  'Producto activo',
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _isActive
                      ? 'El producto será visible para los clientes'
                      : 'El producto estará oculto',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeTrackColor: AppColors.success.withValues(alpha: 0.5),
                activeThumbColor: AppColors.success,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditing ? 'Guardar Cambios' : 'Crear Producto',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildImagePreview() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vista Previa',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            child: CachedNetworkImage(
              imageUrl: _imageUrlController.text,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 200,
                color: AppColors.surfaceDark,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                height: 200,
                color: AppColors.surfaceDark,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Text(
                      'Error al cargar imagen',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firebaseService = ref.read(firebaseServiceProvider);

      final product = ProductModel(
        id: _existingProduct?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text.trim(),
        category: _selectedCategory,
        isActive: _isActive,
        stock: int.parse(_stockController.text),
        createdAt: _existingProduct?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await firebaseService.updateProduct(widget.productId!, product);
      } else {
        await firebaseService.createProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Producto actualizado exitosamente'
                  : 'Producto creado exitosamente',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
