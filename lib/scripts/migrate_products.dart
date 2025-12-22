import 'package:cloud_firestore/cloud_firestore.dart';

/// Script para migrar productos existentes y agregar campos faltantes
///
/// Este script:
/// 1. Lee todos los productos de la colección "Producto"
/// 2. Agrega los campos 'displayed' e 'imagen' si no existen
/// 3. Actualiza los documentos en Firestore
///
/// Ejecutar con: flutter run lib/scripts/migrate_products.dart

Future<void> migrateProducts() async {
  print('🚀 Iniciando migración de productos...\n');

  final firestore = FirebaseFirestore.instance;
  final productsCollection = firestore.collection('Producto');

  try {
    // Obtener todos los productos
    final snapshot = await productsCollection.get();
    print('📦 Encontrados ${snapshot.docs.length} productos\n');

    int updated = 0;
    int errors = 0;

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        final updates = <String, dynamic>{};

        // Verificar y agregar campo 'displayed' si no existe
        if (!data.containsKey('displayed')) {
          updates['displayed'] = true;
          print('  ➕ Agregando campo "displayed" = true');
        }

        // Verificar y agregar campo 'imagen' si no existe
        // (usar el valor de 'imageUrl' si existe)
        if (!data.containsKey('imagen')) {
          final imageUrl = data['imageUrl'] as String? ?? '';
          updates['imagen'] = imageUrl;
          print('  ➕ Agregando campo "imagen" = "$imageUrl"');
        }

        // Asegurar que existe 'imageUrl' (copiar de 'imagen' si es necesario)
        if (!data.containsKey('imageUrl') && data.containsKey('imagen')) {
          updates['imageUrl'] = data['imagen'];
          print('  ➕ Agregando campo "imageUrl" desde "imagen"');
        }

        // Asegurar que existe 'isActive'
        if (!data.containsKey('isActive')) {
          updates['isActive'] = true;
          print('  ➕ Agregando campo "isActive" = true');
        }

        // Asegurar que existe 'stock'
        if (!data.containsKey('stock')) {
          updates['stock'] = 0;
          print('  ➕ Agregando campo "stock" = 0');
        }

        // Actualizar documento si hay cambios
        if (updates.isNotEmpty) {
          updates['updatedAt'] = FieldValue.serverTimestamp();
          await doc.reference.update(updates);

          print('✅ Producto "${data['name']}" (${doc.id}) actualizado');
          print('   Campos agregados: ${updates.keys.join(", ")}\n');
          updated++;
        } else {
          print('⏭️  Producto "${data['name']}" (${doc.id}) ya está actualizado\n');
        }
      } catch (e) {
        print('❌ Error al actualizar producto ${doc.id}: $e\n');
        errors++;
      }
    }

    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✨ Migración completada');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 Productos actualizados: $updated');
    print('⚠️  Errores: $errors');
    print('📦 Total procesados: ${snapshot.docs.length}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    if (updated > 0) {
      print('⏳ IMPORTANTE: Espera a que los índices de Firestore terminen de compilarse.');
      print('   Esto puede tomar entre 5-30 minutos.\n');
      print('💡 Verifica el estado en: https://console.firebase.google.com/project/mexican-bulking/firestore/indexes\n');
    }

  } catch (e) {
    print('❌ Error fatal durante la migración: $e');
    rethrow;
  }
}

void main() async {
  print('🔧 Script de migración de productos');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // Nota: Este script requiere que Firebase esté inicializado
  // Normalmente se ejecutaría desde la app principal con Firebase ya inicializado

  print('⚠️  ADVERTENCIA: Este script debe ejecutarse desde tu app Flutter');
  print('   con Firebase ya inicializado.\n');
  print('📝 Para ejecutar:');
  print('   1. Copia la función migrateProducts() a un botón temporal en tu app');
  print('   2. O ejecuta desde Firebase Console usando la consola web\n');
}
