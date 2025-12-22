import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/product_model.dart';

/// Script para agregar productos de ejemplo a la tienda
///
/// Ejecutar desde la app o Firebase Console

Future<void> seedProducts() async {
  print('🌱 Iniciando seed de productos...\n');

  final firestore = FirebaseFirestore.instance;
  final productsCollection = firestore.collection('Producto');

  // Lista de productos de ejemplo
  final products = [
    // BEBIDAS
    ProductModel(
      id: '',
      name: 'Proteína Whey 2kg',
      description: 'Proteína de suero de leche de alta calidad, sabor chocolate',
      price: 899.00,
      imageUrl: 'https://images.unsplash.com/photo-1579722820308-d74e571900a9?w=800&q=80',
      category: ProductCategory.bebidas,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 25,
      displayed: true,
    ),
    ProductModel(
      id: '',
      name: 'Creatina Monohidrato 300g',
      description: 'Creatina pura micronizada, sin sabor',
      price: 349.00,
      imageUrl: 'https://images.unsplash.com/photo-1608772623190-c8e4f8c5677d?w=800&q=80',
      category: ProductCategory.bebidas,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 30,
      displayed: true,
    ),
    ProductModel(
      id: '',
      name: 'Pre-Entreno Energía',
      description: 'Pre-entreno con cafeína y beta-alanina, sabor frutas',
      price: 549.00,
      imageUrl: 'https://images.unsplash.com/photo-1594897030264-ab7d87efc473?w=800&q=80',
      category: ProductCategory.bebidas,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 20,
      displayed: true,
    ),
    ProductModel(
      id: '',
      name: 'Amino BCAA 500g',
      description: 'Aminoácidos ramificados 2:1:1, recuperación muscular',
      price: 449.00,
      imageUrl: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=800&q=80',
      category: ProductCategory.bebidas,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 15,
      displayed: true,
    ),

    // SUPLEMENTOS
    ProductModel(
      id: '',
      name: 'Multivitamínico Completo',
      description: 'Vitaminas y minerales esenciales, 60 cápsulas',
      price: 299.00,
      imageUrl: 'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=800&q=80',
      category: ProductCategory.suplementos,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 40,
      displayed: true,
    ),
    ProductModel(
      id: '',
      name: 'Omega 3 Fish Oil',
      description: 'Aceite de pescado premium, 90 cápsulas',
      price: 249.00,
      imageUrl: 'https://images.unsplash.com/photo-1526627818775-799c0737c708?w=800&q=80',
      category: ProductCategory.suplementos,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 35,
      displayed: true,
    ),
    ProductModel(
      id: '',
      name: 'Quemador de Grasa',
      description: 'Termogénico con extractos naturales, 60 cápsulas',
      price: 499.00,
      imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&q=80',
      category: ProductCategory.suplementos,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 18,
      displayed: true,
    ),

    // ROPA
    ProductModel(
      id: '',
      name: 'Playera Deportiva Dry-Fit',
      description: 'Playera técnica de secado rápido, varios colores',
      price: 349.00,
      imageUrl: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=800&q=80',
      category: ProductCategory.ropa,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 50,
      displayed: true,
    ),
    ProductModel(
      id: '',
      name: 'Short Deportivo',
      description: 'Short ligero con bolsillos, ideal para entrenar',
      price: 399.00,
      imageUrl: 'https://images.unsplash.com/photo-1591195845402-2fdb39c9d3e7?w=800&q=80',
      category: ProductCategory.ropa,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 45,
      displayed: true,
    ),
    ProductModel(
      id: '',
      name: 'Sudadera con Capucha',
      description: 'Sudadera premium de algodón, logo del gym',
      price: 699.00,
      imageUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&q=80',
      category: ProductCategory.ropa,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 30,
      displayed: true,
    ),

    // ACCESORIOS
    ProductModel(
      id: '',
      name: 'Guantes de Gimnasio',
      description: 'Guantes acolchados con muñequeras, talla M/L',
      price: 249.00,
      imageUrl: 'https://images.unsplash.com/photo-1584735175315-9d5df23860bc?w=800&q=80',
      category: ProductCategory.accesorios,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 60,
      displayed: true,
    ),
    ProductModel(
      id: '',
      name: 'Cinturón de Levantamiento',
      description: 'Cinturón de powerlifting de cuero genuino',
      price: 899.00,
      imageUrl: 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800&q=80',
      category: ProductCategory.accesorios,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 15,
      displayed: true,
    ),
    ProductModel(
      id: '',
      name: 'Shaker Mezclador 700ml',
      description: 'Vaso mezclador con compartimento para suplementos',
      price: 149.00,
      imageUrl: 'https://images.unsplash.com/photo-1591761058308-2e21e2d2c57f?w=800&q=80',
      category: ProductCategory.accesorios,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 100,
      displayed: true,
    ),
    ProductModel(
      id: '',
      name: 'Straps para Jalones',
      description: 'Correas acolchadas para mejorar agarre en dominadas',
      price: 199.00,
      imageUrl: 'https://images.unsplash.com/photo-1606902965551-dce093cda6e7?w=800&q=80',
      category: ProductCategory.accesorios,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 40,
      displayed: true,
    ),
    ProductModel(
      id: '',
      name: 'Banda de Resistencia Set',
      description: 'Set de 5 bandas elásticas con diferentes resistencias',
      price: 449.00,
      imageUrl: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800&q=80',
      category: ProductCategory.accesorios,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stock: 25,
      displayed: true,
    ),
  ];

  int created = 0;
  int errors = 0;

  for (final product in products) {
    try {
      final docRef = productsCollection.doc();
      final productWithId = product.copyWith(id: docRef.id);

      await docRef.set(productWithId.toFirestore());

      print('✅ Producto creado: ${product.name} - \$${product.price}');
      created++;
    } catch (e) {
      print('❌ Error al crear ${product.name}: $e');
      errors++;
    }
  }

  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✨ Seed completado');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✅ Productos creados: $created');
  print('❌ Errores: $errors');
  print('📦 Total: ${products.length}');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
}

void main() async {
  print('🌱 Script de seed de productos');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  print('⚠️  ADVERTENCIA: Este script debe ejecutarse desde tu app Flutter');
  print('   con Firebase ya inicializado.\n');
}
