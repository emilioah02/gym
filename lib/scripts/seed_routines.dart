import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/routine_model.dart';

/// Script para cargar rutinas de ejemplo correctas en Firestore
///
/// Este script crea rutinas con los datos correctos de ejercicios,
/// asegurando que machineId, machineName e machineImageUrl estén correctos

Future<void> seedRoutines() async {
  print('🌱 Iniciando seed de rutinas...\n');

  final firestore = FirebaseFirestore.instance;
  final routinesCollection = firestore.collection('routines');

  // Definición de máquinas con sus datos correctos
  // Estos datos coinciden con machines_data.dart
  final machines = {
    // CARDIO
    'treadmill': {
      'id': 'treadmill',
      'name': 'Caminadora',
      'imageUrl':
          'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=400&q=80',
    },
    'stationary_bike': {
      'id': 'stationary_bike',
      'name': 'Bicicleta Estática',
      'imageUrl':
          'https://images.unsplash.com/photo-1591741535018-d042cbcd0d73?w=400&q=80',
    },
    'rowing_machine': {
      'id': 'rowing_machine',
      'name': 'Máquina de Remo',
      'imageUrl':
          'https://images.unsplash.com/photo-1519505907962-0a6cb0167c73?w=400&q=80',
    },
    'step_stepper': {
      'id': 'step_stepper',
      'name': 'Escaladora',
      'imageUrl':
          'https://images.unsplash.com/photo-1534258936925-c58bed479fcb?w=400&q=80',
    },

    // LEGS
    'leg_press': {
      'id': 'leg_press',
      'name': 'Prensa de Piernas',
      'imageUrl': 'https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=400',
    },
    'smith_machine': {
      'id': 'smith_machine',
      'name': 'Máquina Smith',
      'imageUrl':
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
    },
    'squat_rack': {
      'id': 'squat_rack',
      'name': 'Rack de Sentadillas',
      'imageUrl':
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
    },
    'hack_squat': {
      'id': 'hack_squat',
      'name': 'Hack Squat',
      'imageUrl':
          'https://images.unsplash.com/photo-1581009146145-b5ef050c149a?w=400',
    },
    'leg_extension': {
      'id': 'leg_extension',
      'name': 'Extensión de Piernas',
      'imageUrl':
          'https://images.unsplash.com/photo-1558611848-73f7eb4001a1?w=400',
    },
    'leg_curl': {
      'id': 'leg_curl',
      'name': 'Curl de Piernas',
      'imageUrl':
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400',
    },
    'calf_raise': {
      'id': 'calf_raise',
      'name': 'Máquina de Pantorrillas',
      'imageUrl':
          'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=400',
    },
    'hip_abductor': {
      'id': 'hip_abductor',
      'name': 'Máquina de Abductores',
      'imageUrl':
          'https://images.unsplash.com/photo-1550345332-054861f5c7a3?w=400',
    },

    // CHEST
    'chest_press': {
      'id': 'chest_press',
      'name': 'Press de Pecho',
      'imageUrl':
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400',
    },
    'pec_deck': {
      'id': 'pec_deck',
      'name': 'Pec Deck (Mariposa)',
      'imageUrl':
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400',
    },
    'cable_crossover': {
      'id': 'cable_crossover',
      'name': 'Cruces en Poleas',
      'imageUrl':
          'https://images.unsplash.com/photo-1532029837206-abbe2b7620e3?w=400',
    },
    'incline_bench': {
      'id': 'incline_bench',
      'name': 'Press Inclinado',
      'imageUrl':
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400',
    },
    'flat_bench': {
      'id': 'flat_bench',
      'name': 'Press de Banca Plano',
      'imageUrl':
          'https://images.unsplash.com/photo-1581009146145-b5ef050c149a?w=400',
    },

    // BACK
    'lat_pulldown': {
      'id': 'lat_pulldown',
      'name': 'Jalón al Pecho',
      'imageUrl':
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
    },
    'seated_row': {
      'id': 'seated_row',
      'name': 'Remo Sentado',
      'imageUrl':
          'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=400',
    },
    'assisted_pullup': {
      'id': 'assisted_pullup',
      'name': 'Dominadas Asistidas',
      'imageUrl':
          'https://images.unsplash.com/photo-1521805103424-d8f8430e8933?w=400',
    },

    // SHOULDERS
    'shoulder_press': {
      'id': 'shoulder_press',
      'name': 'Press de Hombro',
      'imageUrl':
          'https://images.unsplash.com/photo-1532029837206-abbe2b7620e3?w=400',
    },
    'lateral_raise': {
      'id': 'lateral_raise',
      'name': 'Elevaciones Laterales',
      'imageUrl':
          'https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=400',
    },

    // ARMS
    'triceps_extension': {
      'id': 'triceps_extension',
      'name': 'Extensión de Tríceps',
      'imageUrl':
          'https://images.unsplash.com/photo-1581009146145-b5ef050c149a?w=400',
    },
    'biceps_curl': {
      'id': 'biceps_curl',
      'name': 'Curl de Bíceps',
      'imageUrl':
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400',
    },

    // CORE
    'ab_crunch': {
      'id': 'ab_crunch',
      'name': 'Máquina de Abdominales',
      'imageUrl':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
    },

    // FUNCTIONAL
    'glute_machine': {
      'id': 'glute_machine',
      'name': 'Máquina de Glúteos',
      'imageUrl':
          'https://images.unsplash.com/photo-1550345332-054861f5c7a3?w=400',
    },
  };

  // Helper para crear RoutineExercise
  RoutineExercise createExercise(String machineId, int sets, int reps,
      {String? notes, int orden = 0}) {
    final machine = machines[machineId]!;
    return RoutineExercise(
      machineId: machine['id'] as String,
      machineName: machine['name'] as String,
      machineImageUrl: machine['imageUrl'] as String,
      sets: sets,
      reps: reps,
      notas: notes,
      orden: orden,
    );
  }

  // Lista de rutinas de ejemplo
  final routines = [
    // ============ RUTINA 1: Fuerza Cuerpo Completo (HOMBRES) ============
    RoutineModel(
      id: '', // Se asignará automáticamente
      nombre: 'Fuerza Cuerpo Completo',
      descripcion:
          'Rutina de introducción para desarrollar fuerza general. Entrenamiento completo que trabaja todos los grupos musculares principales.',
      dificultad: RoutineDifficulty.principiante,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.hombre,
      ejercicios: [
        createExercise('treadmill', 1, 10, notes: '10 min calentamiento', orden: 0),
        createExercise('leg_press', 4, 12, orden: 1),
        createExercise('chest_press', 4, 12, orden: 2),
        createExercise('lat_pulldown', 4, 12, orden: 3),
        createExercise('shoulder_press', 3, 12, orden: 4),
        createExercise('triceps_extension', 3, 12, orden: 5),
        createExercise('biceps_curl', 3, 12, orden: 6),
        createExercise('ab_crunch', 3, 20, orden: 7),
      ],
      duracionMinutos: 60,
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
      esPlantilla: true,
    ),

    // ============ RUTINA 2: Tonificación Cuerpo Completo (MUJERES) ============
    RoutineModel(
      id: '',
      nombre: 'Tonificación Cuerpo Completo',
      descripcion:
          'Rutina equilibrada de cuerpo completo para tonificación y fuerza. Ideal para principiantes.',
      dificultad: RoutineDifficulty.principiante,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.mujer,
      ejercicios: [
        createExercise('leg_press', 3, 15, orden: 0),
        createExercise('glute_machine', 3, 15, orden: 1),
        createExercise('hip_abductor', 3, 15, orden: 2),
        createExercise('chest_press', 3, 12, orden: 3),
        createExercise('lat_pulldown', 3, 12, orden: 4),
        createExercise('lateral_raise', 3, 15, orden: 5),
        createExercise('ab_crunch', 3, 20, orden: 6),
        createExercise('stationary_bike', 1, 15, notes: '15 min enfriamiento', orden: 7),
      ],
      duracionMinutos: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1550345332-054861f5c7a3?w=800&q=80',
      esPlantilla: true,
    ),

    // ============ RUTINA 3: Enfoque Piernas (HOMBRES) ============
    RoutineModel(
      id: '',
      nombre: 'Destructor de Piernas',
      descripcion:
          'Entrenamiento intenso de piernas para desarrollar cuádriceps, isquiotibiales y glúteos. Nivel intermedio.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.pierna,
      genero: RoutineGender.hombre,
      ejercicios: [
        createExercise('squat_rack', 5, 8, orden: 0),
        createExercise('leg_press', 4, 12, orden: 1),
        createExercise('hack_squat', 4, 10, orden: 2),
        createExercise('leg_extension', 3, 15, orden: 3),
        createExercise('leg_curl', 3, 15, orden: 4),
        createExercise('calf_raise', 4, 15, orden: 5),
      ],
      duracionMinutos: 60,
      imageUrl:
          'https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=800&q=80',
      esPlantilla: true,
    ),

    // ============ RUTINA 4: Enfoque Glúteos y Piernas (MUJERES) ============
    RoutineModel(
      id: '',
      nombre: 'Enfoque Glúteos y Piernas',
      descripcion:
          'Entrenamiento de tren inferior enfocado en glúteos, muslos y piernas. Perfecto para tonificar.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.pierna,
      genero: RoutineGender.mujer,
      ejercicios: [
        createExercise('glute_machine', 4, 15, orden: 0),
        createExercise('leg_press', 4, 15, orden: 1),
        createExercise('hip_abductor', 3, 20, orden: 2),
        createExercise('leg_extension', 3, 15, orden: 3),
        createExercise('leg_curl', 3, 15, orden: 4),
        createExercise('calf_raise', 3, 20, orden: 5),
        createExercise('step_stepper', 1, 15, notes: '15 min cardio final', orden: 6),
      ],
      duracionMinutos: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1550345332-054861f5c7a3?w=800&q=80',
      esPlantilla: true,
    ),

    // ============ RUTINA 5: Potencia Tren Superior (HOMBRES) ============
    RoutineModel(
      id: '',
      nombre: 'Potencia Tren Superior',
      descripcion:
          'Entrenamiento intenso de tren superior para desarrollar pecho, espalda y brazos. Nivel intermedio.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.trenSuperior,
      genero: RoutineGender.hombre,
      ejercicios: [
        createExercise('flat_bench', 4, 10, orden: 0),
        createExercise('incline_bench', 4, 10, orden: 1),
        createExercise('cable_crossover', 4, 12, orden: 2),
        createExercise('lat_pulldown', 4, 10, orden: 3),
        createExercise('seated_row', 4, 12, orden: 4),
        createExercise('shoulder_press', 4, 10, orden: 5),
        createExercise('triceps_extension', 3, 12, orden: 6),
        createExercise('biceps_curl', 3, 12, orden: 7),
      ],
      duracionMinutos: 55,
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&q=80',
      esPlantilla: true,
    ),

    // ============ RUTINA 6: Esculpir Tren Superior (MUJERES) ============
    RoutineModel(
      id: '',
      nombre: 'Esculpir Tren Superior',
      descripcion:
          'Entrenamiento de tonificación para brazos, hombros, pecho y espalda. Ideal para definir.',
      dificultad: RoutineDifficulty.principiante,
      parteDelCuerpo: RoutineBodyPart.trenSuperior,
      genero: RoutineGender.mujer,
      ejercicios: [
        createExercise('chest_press', 3, 15, orden: 0),
        createExercise('pec_deck', 3, 15, orden: 1),
        createExercise('lat_pulldown', 3, 12, orden: 2),
        createExercise('assisted_pullup', 3, 10, orden: 3),
        createExercise('shoulder_press', 3, 15, orden: 4),
        createExercise('lateral_raise', 3, 15, orden: 5),
        createExercise('triceps_extension', 3, 15, orden: 6),
      ],
      duracionMinutos: 45,
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&q=80',
      esPlantilla: true,
    ),

    // ============ RUTINA 7: Día de Empuje (UNISEX) ============
    RoutineModel(
      id: '',
      nombre: 'Día de Empuje',
      descripcion:
          'Entrenamiento clásico de empuje: pecho, hombros y tríceps. Rutina push-pull-legs.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.pecho,
      genero: RoutineGender.unisex,
      ejercicios: [
        createExercise('flat_bench', 4, 10, orden: 0),
        createExercise('incline_bench', 3, 12, orden: 1),
        createExercise('pec_deck', 3, 12, orden: 2),
        createExercise('shoulder_press', 4, 10, orden: 3),
        createExercise('lateral_raise', 3, 15, orden: 4),
        createExercise('triceps_extension', 4, 12, orden: 5),
      ],
      duracionMinutos: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&q=80',
      esPlantilla: true,
    ),

    // ============ RUTINA 8: Día de Jalón (UNISEX) ============
    RoutineModel(
      id: '',
      nombre: 'Día de Jalón',
      descripcion:
          'Entrenamiento clásico de jalón: enfoque en espalda y bíceps. Rutina push-pull-legs.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.espalda,
      genero: RoutineGender.unisex,
      ejercicios: [
        createExercise('lat_pulldown', 4, 10, orden: 0),
        createExercise('seated_row', 4, 12, orden: 1),
        createExercise('assisted_pullup', 3, 10, orden: 2),
        createExercise('biceps_curl', 4, 12, orden: 3),
      ],
      duracionMinutos: 40,
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
      esPlantilla: true,
    ),

    // ============ RUTINA 9: Cardio HIIT (UNISEX) ============
    RoutineModel(
      id: '',
      nombre: 'Cardio HIIT Explosivo',
      descripcion:
          'Circuito de cardio de alta intensidad para máxima quema de grasa. Entrenamiento por intervalos.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.mixto,
      genero: RoutineGender.unisex,
      ejercicios: [
        createExercise('treadmill', 1, 10, notes: '10 min calentamiento', orden: 0),
        createExercise('rowing_machine', 3, 2, notes: 'intervalos de 2 min', orden: 1),
        createExercise('stationary_bike', 3, 3, notes: 'intervalos de 3 min', orden: 2),
        createExercise('step_stepper', 3, 5, notes: 'intervalos de 5 min', orden: 3),
        createExercise('treadmill', 1, 5, notes: '5 min enfriamiento', orden: 4),
      ],
      duracionMinutos: 30,
      imageUrl:
          'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=800&q=80',
      esPlantilla: true,
    ),
  ];

  int created = 0;
  int errors = 0;

  for (final routine in routines) {
    try {
      final docRef = routinesCollection.doc();
      final routineWithId = routine.copyWith(id: docRef.id);

      await docRef.set(routineWithId.toFirestore());

      print(
          '✅ Rutina creada: ${routine.nombre} (${routine.dificultad.displayName}, ${routine.ejercicios.length} ejercicios)');
      created++;
    } catch (e) {
      print('❌ Error al crear ${routine.nombre}: $e');
      errors++;
    }
  }

  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✨ Seed de rutinas completado');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✅ Rutinas creadas: $created');
  print('❌ Errores: $errors');
  print('📦 Total: ${routines.length}');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
}

void main() async {
  print('🌱 Script de seed de rutinas');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  print('⚠️  ADVERTENCIA: Este script debe ejecutarse desde tu app Flutter');
  print('   con Firebase ya inicializado.\n');
  print('💡 Para ejecutar este script:');
  print('   1. Importa este archivo en tu app');
  print('   2. Llama a seedRoutines() después de inicializar Firebase');
  print('   3. Verifica que los datos se carguen correctamente\n');
}
