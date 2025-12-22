/**
 * Script para actualizar roles de usuarios en Firestore
 * Ejecutar con: node scripts/update_user_roles.js
 */

const admin = require('firebase-admin');

// Inicializar Firebase Admin (usa las credenciales del proyecto)
admin.initializeApp({
  projectId: 'mexican-bulking'
});

const db = admin.firestore();

// Configuración de usuarios
const TRAINERS = [
  'emilioah02@gmail.com',
  'diegopeniche.galindo25@gmail.com',
  'penichealberto56@gmail.com'
];

const CLIENTS = [
  'chapingoopen@gmail.com',
  'jack5591389@gmail.com'
];

async function updateUserRoles() {
  console.log('🔄 Iniciando actualización de roles...\n');

  try {
    // Obtener todos los usuarios de Firestore
    const usersSnapshot = await db.collection('users').get();

    if (usersSnapshot.empty) {
      console.log('⚠️  No se encontraron usuarios en Firestore');
      return;
    }

    console.log(`📊 Total de usuarios encontrados: ${usersSnapshot.size}\n`);

    let trainersUpdated = 0;
    let clientsUpdated = 0;
    let skipped = 0;

    // Actualizar cada usuario según su email
    for (const doc of usersSnapshot.docs) {
      const userData = doc.data();
      const userEmail = userData.email?.toLowerCase();
      const currentRole = userData.rol;

      if (!userEmail) {
        console.log(`⚠️  Usuario ${doc.id} no tiene email, omitiendo...`);
        skipped++;
        continue;
      }

      let newRole = null;

      // Determinar el nuevo rol
      if (TRAINERS.includes(userEmail)) {
        newRole = 'entrenador';
      } else if (CLIENTS.includes(userEmail)) {
        newRole = 'cliente';
      }

      // Solo actualizar si hay un cambio de rol
      if (newRole && newRole !== currentRole) {
        await db.collection('users').doc(doc.id).update({
          rol: newRole,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`✅ ${userEmail}`);
        console.log(`   Rol actualizado: ${currentRole || 'sin rol'} → ${newRole}`);
        console.log(`   UID: ${doc.id}\n`);

        if (newRole === 'entrenador') trainersUpdated++;
        else clientsUpdated++;
      } else if (newRole === currentRole) {
        console.log(`✓  ${userEmail} ya tiene el rol correcto: ${newRole}\n`);
        skipped++;
      } else {
        // Usuario no está en las listas, mantener rol actual o asignar cliente por defecto
        if (!currentRole) {
          await db.collection('users').doc(doc.id).update({
            rol: 'cliente',
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
          });
          console.log(`ℹ️  ${userEmail}`);
          console.log(`   Rol asignado por defecto: cliente\n`);
          clientsUpdated++;
        } else {
          skipped++;
        }
      }
    }

    // Resumen
    console.log('\n' + '='.repeat(50));
    console.log('📋 RESUMEN DE ACTUALIZACIONES');
    console.log('='.repeat(50));
    console.log(`👔 Entrenadores actualizados: ${trainersUpdated}`);
    console.log(`👤 Clientes actualizados: ${clientsUpdated}`);
    console.log(`⏭️  Sin cambios: ${skipped}`);
    console.log(`📊 Total procesados: ${usersSnapshot.size}`);
    console.log('='.repeat(50) + '\n');

    console.log('✅ Actualización completada exitosamente!\n');

    // Mostrar configuración final
    console.log('📌 CONFIGURACIÓN FINAL:');
    console.log('\nEntrenadores:');
    TRAINERS.forEach(email => console.log(`  - ${email}`));
    console.log('\nClientes:');
    CLIENTS.forEach(email => console.log(`  - ${email}`));

  } catch (error) {
    console.error('❌ Error durante la actualización:', error);
    process.exit(1);
  }
}

// Ejecutar
updateUserRoles()
  .then(() => {
    console.log('\n✨ Script finalizado');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Error fatal:', error);
    process.exit(1);
  });
