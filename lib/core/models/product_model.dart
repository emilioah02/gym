import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de producto para la tienda
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final ProductCategory category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int stock;
  final bool displayed; // Campo para controlar si se muestra en la tienda

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.stock = 0,
    this.displayed = true, // Por defecto se muestra
  });

  /// Crear copia con cambios
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    ProductCategory? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? stock,
    bool? displayed,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stock: stock ?? this.stock,
      displayed: displayed ?? this.displayed,
    );
  }

  /// Crear desde Firestore
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Compatibilidad con ambos nombres de campo de imagen
    final imageUrl = data['imageUrl'] as String? ?? data['imagen'] as String? ?? '';

    return ProductModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: imageUrl,
      category: ProductCategory.values.firstWhere(
        (e) => e.name == (data['category'] as String? ?? 'otros'),
        orElse: () => ProductCategory.otros,
      ),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      stock: data['stock'] as int? ?? 0,
      displayed: data['displayed'] as bool? ?? true,
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'imagen': imageUrl, // Mantener compatibilidad con campo antiguo
      'category': category.name,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'stock': stock,
      'displayed': displayed,
    };
  }

  /// Crear producto vacío
  factory ProductModel.empty() {
    return ProductModel(
      id: '',
      name: '',
      description: '',
      price: 0.0,
      imageUrl: '',
      category: ProductCategory.otros,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 0,
      displayed: true,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, category: ${category.displayName}, price: \$$price, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Categorías de productos
enum ProductCategory {
  bebidas('Bebidas', '🥤'),
  suplementos('Suplementos', '💊'),
  ropa('Ropa', '👕'),
  accesorios('Accesorios', '🎒'),
  otros('Otros', '📦');

  final String displayName;
  final String emoji;

  const ProductCategory(this.displayName, this.emoji);

  /// Obtener categoría desde string
  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ProductCategory.otros,
    );
  }
}
