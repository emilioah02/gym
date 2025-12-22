// Script para actualizar las solicitudes de rutina existentes con el campo trainerId
const admin = require('firebase-admin');

// Inicializar Firebase Admin con credenciales de la cuenta de servicio
const serviceAccount = require('./mexican-bulking-firebase-adminsdk-fbsvc-14058731a4.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'mexican-bulking'
});

const db = admin.firestore();

async function updateRoutineRequests() {
  console.log('🔄 Actualizando solicitudes de rutina existentes...\n');

  try {
    // Obtener todas las solicitudes de rutina
    const snapshot = await db.collection('routine_requests').get();

    console.log(`📊 Total de solicitudes encontradas: ${snapshot.size}\n`);

    if (snapshot.empty) {
      console.log('ℹ️  No hay solicitudes para actualizar.\n');
      process.exit(0);
    }

    const batch = db.batch();
    let updated = 0;

    snapshot.docs.forEach((doc) => {
      const data = doc.data();

      // Si ya tiene trainerId, no hacer nada
      if (data.trainerId !== undefined) {
        console.log(`⏭️  ${doc.id} - Ya tiene trainerId: ${data.trainerId}`);
        return;
      }

      // Agregar trainerId como null (cualquier entrenador puede atender)
      batch.update(doc.ref, {
        trainerId: null
      });

      console.log(`✅ ${doc.id} - Cliente: ${data.clienteNombre || 'Sin nombre'} - Agregando trainerId: null`);
      updated++;
    });

    if (updated > 0) {
      await batch.commit();
      console.log(`\n✨ ${updated} solicitudes actualizadas correctamente!`);
    } else {
      console.log('\nℹ️  Todas las solicitudes ya tienen el campo trainerId.');
    }

    console.log('\n📱 Las notificaciones ahora mostrarán estas solicitudes a los entrenadores.\n');
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error al actualizar solicitudes:', error);
    process.exit(1);
  }
}

updateRoutineRequests();
