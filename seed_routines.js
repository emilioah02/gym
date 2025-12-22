// Script para cargar rutinas de ejemplo en Firestore
const admin = require('firebase-admin');

// Inicializar Firebase Admin con credenciales de la cuenta de servicio
const serviceAccount = require('./mexican-bulking-firebase-adminsdk-fbsvc-14058731a4.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'mexican-bulking'
});

const db = admin.firestore();

// Definición de máquinas (igual que en seed_routines.dart)
const machines = {
  'treadmill': {
    id: 'treadmill',
    name: 'Caminadora',
    imageUrl: 'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=400&q=80'
  },
  'leg_press': {
    id: 'leg_press',
    name: 'Prensa de Piernas',
    imageUrl: 'https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=400'
  },
  'chest_press': {
    id: 'chest_press',
    name: 'Press de Pecho',
    imageUrl: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=400'
  },
  'lat_pulldown': {
    id: 'lat_pulldown',
    name: 'Jalón al Pecho',
    imageUrl: 'https://images.unsplash.com/photo-1534438097545-7c88f9c6b48a?w=400'
  },
  'shoulder_press': {
    id: 'shoulder_press',
    name: 'Press de Hombro',
    imageUrl: 'https://images.unsplash.com/photo-1526401485004-46910ecc8e51?w=400'
  },
  'triceps_extension': {
    id: 'triceps_extension',
    name: 'Extensión de Tríceps',
    imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400'
  },
  'biceps_curl': {
    id: 'biceps_curl',
    name: 'Curl de Bíceps',
    imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400'
  },
  'ab_crunch_machine': {
    id: 'ab_crunch_machine',
    name: 'Máquina de Abdominales',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400'
  },
  'glute_machine': {
    id: 'glute_machine',
    name: 'Máquina de Glúteos',
    imageUrl: 'https://images.unsplash.com/photo-1550345332-09e3ac987658?w=400'
  },
  'abductor_machine': {
    id: 'abductor_machine',
    name: 'Abductor',
    imageUrl: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=400'
  },
  'stationary_bike': {
    id: 'stationary_bike',
    name: 'Bicicleta Fija',
    imageUrl: 'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=400&q=80'
  },
  'flat_bench': {
    id: 'flat_bench',
    name: 'Press Banca Plano',
    imageUrl: 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400'
  },
  'incline_bench': {
    id: 'incline_bench',
    name: 'Press Banca Inclinado',
    imageUrl: 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400'
  },
  'cable_crossover': {
    id: 'cable_crossover',
    name: 'Cruces en Polea',
    imageUrl: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=400'
  },
  'seated_row': {
    id: 'seated_row',
    name: 'Remo Sentado',
    imageUrl: 'https://images.unsplash.com/photo-1534438097545-7c88f9c6b48a?w=400'
  },
  'pec_deck': {
    id: 'pec_deck',
    name: 'Pec Deck',
    imageUrl: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=400'
  },
  'assisted_pullup': {
    id: 'assisted_pullup',
    name: 'Dominadas Asistidas',
    imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400'
  },
  'lateral_raise': {
    id: 'lateral_raise',
    name: 'Elevaciones Laterales',
    imageUrl: 'https://images.unsplash.com/photo-1526401485004-46910ecc8e51?w=400'
  },
  'squat_rack': {
    id: 'squat_rack',
    name: 'Sentadilla con Barra',
    imageUrl: 'https://images.unsplash.com/photo-1434682772747-f16d3ea162c3?w=400'
  },
  'hack_squat': {
    id: 'hack_squat',
    name: 'Hack Squat',
    imageUrl: 'https://images.unsplash.com/photo-1434682772747-f16d3ea162c3?w=400'
  },
  'leg_extension': {
    id: 'leg_extension',
    name: 'Extensión de Cuádriceps',
    imageUrl: 'https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=400'
  },
  'leg_curl': {
    id: 'leg_curl',
    name: 'Curl de Femoral',
    imageUrl: 'https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=400'
  },
  'calf_raise': {
    id: 'calf_raise',
    name: 'Elevación de Pantorrilla',
    imageUrl: 'https://images.unsplash.com/photo-1434682772747-f16d3ea162c3?w=400'
  },
  'step_stepper': {
    id: 'step_stepper',
    name: 'Escaladora',
    imageUrl: 'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=400&q=80'
  },
  'rowing_machine': {
    id: 'rowing_machine',
    name: 'Máquina de Remo',
    imageUrl: 'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=400&q=80'
  }
};

function createExercise(machineId, sets, reps, notes = '', orden = 0) {
  const machine = machines[machineId];
  return {
    machineId: machine.id,
    machineName: machine.name,
    machineImageUrl: machine.imageUrl,
    sets,
    reps,
    notas: notes,
    orden
  };
}

const routines = [
  // ============ RUTINA 1: Fuerza Cuerpo Completo (HOMBRES) ============
  {
    nombre: 'Fuerza Cuerpo Completo',
    descripcion: 'Rutina de introducción al gimnasio trabajando todos los grupos musculares principales. Ideal para principiantes.',
    dificultad: 'principiante',
    parteDelCuerpo: 'fullBody',
    genero: 'hombre',
    duracionMinutos: 60,
    esPlantilla: true,
    ejercicios: [
      createExercise('treadmill', 1, 10, '10 min calentamiento', 0),
      createExercise('leg_press', 4, 12, '', 1),
      createExercise('chest_press', 4, 12, '', 2),
      createExercise('lat_pulldown', 4, 12, '', 3),
      createExercise('shoulder_press', 3, 12, '', 4),
      createExercise('triceps_extension', 3, 12, '', 5),
      createExercise('biceps_curl', 3, 12, '', 6),
      createExercise('ab_crunch_machine', 3, 20, '', 7)
    ]
  },

  // ============ RUTINA 2: Tonificación Cuerpo Completo (MUJERES) ============
  {
    nombre: 'Tonificación Cuerpo Completo',
    descripcion: 'Rutina equilibrada de cuerpo completo con énfasis en tonificación y glúteos. Para mujeres principiantes.',
    dificultad: 'principiante',
    parteDelCuerpo: 'fullBody',
    genero: 'mujer',
    duracionMinutos: 50,
    esPlantilla: true,
    ejercicios: [
      createExercise('treadmill', 1, 10, '10 min calentamiento', 0),
      createExercise('leg_press', 3, 15, '', 1),
      createExercise('glute_machine', 3, 15, '', 2),
      createExercise('abductor_machine', 3, 15, '', 3),
      createExercise('chest_press', 3, 12, '', 4),
      createExercise('lat_pulldown', 3, 12, '', 5),
      createExercise('ab_crunch_machine', 3, 20, '', 6),
      createExercise('stationary_bike', 1, 15, '15 min cardio final', 7)
    ]
  },

  // ============ RUTINA 3: Destructor de Piernas (HOMBRES) ============
  {
    nombre: 'Destructor de Piernas',
    descripcion: 'Entrenamiento intenso enfocado en desarrollo de cuádriceps, femorales y glúteos. Nivel intermedio.',
    dificultad: 'medio',
    parteDelCuerpo: 'piernas',
    genero: 'hombre',
    duracionMinutos: 60,
    esPlantilla: true,
    ejercicios: [
      createExercise('treadmill', 1, 5, '5 min calentamiento', 0),
      createExercise('squat_rack', 5, 8, '', 1),
      createExercise('leg_press', 4, 12, '', 2),
      createExercise('hack_squat', 4, 10, '', 3),
      createExercise('leg_extension', 3, 15, '', 4),
      createExercise('leg_curl', 3, 15, '', 5),
      createExercise('calf_raise', 4, 15, '', 6)
    ]
  },

  // ============ RUTINA 4: Enfoque Glúteos y Piernas (MUJERES) ============
  {
    nombre: 'Enfoque Glúteos y Piernas',
    descripcion: 'Rutina especializada en glúteos y piernas con ejercicios de tonificación y fuerza. Nivel intermedio.',
    dificultad: 'medio',
    parteDelCuerpo: 'piernas',
    genero: 'mujer',
    duracionMinutos: 50,
    esPlantilla: true,
    ejercicios: [
      createExercise('step_stepper', 1, 10, '10 min calentamiento', 0),
      createExercise('glute_machine', 4, 15, '', 1),
      createExercise('leg_press', 4, 15, '', 2),
      createExercise('abductor_machine', 3, 20, '', 3),
      createExercise('leg_extension', 3, 15, '', 4),
      createExercise('leg_curl', 3, 15, '', 5),
      createExercise('calf_raise', 3, 20, '', 6),
      createExercise('step_stepper', 1, 15, '15 min cardio final', 7)
    ]
  },

  // ============ RUTINA 5: Potencia Tren Superior (HOMBRES) ============
  {
    nombre: 'Potencia Tren Superior',
    descripcion: 'Entrenamiento intenso de tren superior para desarrollar pecho, espalda y brazos. Nivel intermedio.',
    dificultad: 'medio',
    parteDelCuerpo: 'trenSuperior',
    genero: 'hombre',
    duracionMinutos: 55,
    esPlantilla: true,
    ejercicios: [
      createExercise('flat_bench', 4, 10, '', 0),
      createExercise('incline_bench', 4, 10, '', 1),
      createExercise('cable_crossover', 4, 12, '', 2),
      createExercise('lat_pulldown', 4, 10, '', 3),
      createExercise('seated_row', 4, 12, '', 4),
      createExercise('shoulder_press', 4, 10, '', 5),
      createExercise('triceps_extension', 3, 12, '', 6),
      createExercise('biceps_curl', 3, 12, '', 7)
    ]
  },

  // ============ RUTINA 6: Esculpir Tren Superior (MUJERES) ============
  {
    nombre: 'Esculpir Tren Superior',
    descripcion: 'Entrenamiento de tonificación para brazos, hombros, pecho y espalda. Ideal para definir.',
    dificultad: 'principiante',
    parteDelCuerpo: 'trenSuperior',
    genero: 'mujer',
    duracionMinutos: 45,
    esPlantilla: true,
    ejercicios: [
      createExercise('chest_press', 3, 15, '', 0),
      createExercise('pec_deck', 3, 15, '', 1),
      createExercise('lat_pulldown', 3, 12, '', 2),
      createExercise('assisted_pullup', 3, 10, '', 3),
      createExercise('shoulder_press', 3, 15, '', 4),
      createExercise('lateral_raise', 3, 15, '', 5),
      createExercise('triceps_extension', 3, 15, '', 6)
    ]
  },

  // ============ RUTINA 7: Día de Empuje (UNISEX) ============
  {
    nombre: 'Día de Empuje',
    descripcion: 'Rutina push/pull enfocada en pecho, hombros y tríceps. Nivel intermedio.',
    dificultad: 'medio',
    parteDelCuerpo: 'trenSuperior',
    genero: 'unisex',
    duracionMinutos: 50,
    esPlantilla: true,
    ejercicios: [
      createExercise('flat_bench', 4, 10, '', 0),
      createExercise('incline_bench', 3, 12, '', 1),
      createExercise('pec_deck', 3, 12, '', 2),
      createExercise('shoulder_press', 4, 10, '', 3),
      createExercise('lateral_raise', 3, 15, '', 4),
      createExercise('triceps_extension', 4, 12, '', 5)
    ]
  },

  // ============ RUTINA 8: Día de Jalón (UNISEX) ============
  {
    nombre: 'Día de Jalón',
    descripcion: 'Rutina push/pull enfocada en espalda y bíceps. Nivel intermedio.',
    dificultad: 'medio',
    parteDelCuerpo: 'trenSuperior',
    genero: 'unisex',
    duracionMinutos: 40,
    esPlantilla: true,
    ejercicios: [
      createExercise('lat_pulldown', 4, 10, '', 0),
      createExercise('seated_row', 4, 12, '', 1),
      createExercise('assisted_pullup', 3, 10, '', 2),
      createExercise('biceps_curl', 4, 12, '', 3)
    ]
  },

  // ============ RUTINA 9: Cardio HIIT (UNISEX) ============
  {
    nombre: 'Cardio HIIT Explosivo',
    descripcion: 'Circuito de cardio de alta intensidad para máxima quema de grasa. Entrenamiento por intervalos.',
    dificultad: 'medio',
    parteDelCuerpo: 'mixto',
    genero: 'unisex',
    duracionMinutos: 30,
    esPlantilla: true,
    ejercicios: [
      createExercise('treadmill', 1, 10, '10 min calentamiento', 0),
      createExercise('rowing_machine', 3, 2, 'intervalos de 2 min', 1),
      createExercise('stationary_bike', 3, 3, 'intervalos de 3 min', 2),
      createExercise('step_stepper', 3, 5, 'intervalos de 5 min', 3),
      createExercise('treadmill', 1, 5, '5 min enfriamiento', 4)
    ]
  }
];

async function seedRoutines() {
  console.log('🌱 Iniciando carga de rutinas...\n');

  try {
    // Primero, eliminar todas las rutinas existentes
    console.log('🗑️  Eliminando rutinas antiguas...');
    const existingRoutines = await db.collection('routines').get();
    const deletePromises = existingRoutines.docs.map(doc => doc.ref.delete());
    await Promise.all(deletePromises);
    console.log(`✅ ${existingRoutines.size} rutinas antiguas eliminadas\n`);

    // Cargar nuevas rutinas
    const batch = db.batch();
    let count = 0;

    routines.forEach((routine) => {
      const docRef = db.collection('routines').doc();
      batch.set(docRef, {
        ...routine,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      count++;
      console.log(`✅ ${count}. ${routine.nombre} - ${routine.duracionMinutos} min (${routine.genero})`);
    });

    await batch.commit();
    console.log(`\n✨ ${count} rutinas cargadas exitosamente en Firestore!`);
    console.log('\n📋 Próximos pasos:');
    console.log('1. Ve a Firebase Console y verifica las rutinas en la colección "routines"');
    console.log('2. Como entrenador, asigna la rutina "Fuerza Cuerpo Completo" a un cliente');
    console.log('3. Verifica que los ejercicios ahora muestren los nombres e imágenes correctas\n');
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error al cargar rutinas:', error);
    process.exit(1);
  }
}

seedRoutines();
