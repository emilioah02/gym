import '../../../core/models/routine_model.dart';

/// ============================================================================
/// CATÁLOGO COMPLETO DE RUTINAS DEL GIMNASIO
/// ============================================================================
///
/// Organización de rutinas:
/// - Por género: Hombre, Mujer, Unisex
/// - Por dificultad: Principiante, Medio, Avanzado, Experto
/// - Por parte del cuerpo: FullBody, TrenSuperior, TrenInferior, etc.
///
/// Convenciones de ID:
/// - [genero]_[dificultad]_[parte_cuerpo] (ej: hombre_principiante_fullbody)
///
/// Cada rutina incluye:
/// - Ejercicios ordenados por secuencia óptima
/// - Series y repeticiones apropiadas al nivel
/// - Duración estimada en minutos
/// - Notas específicas cuando aplica
///
/// ============================================================================

class RoutinesData {
  RoutinesData._();

  static List<RoutineModel> get allRoutines => [
        // =====================================================================
        // RUTINAS PARA HOMBRES
        // =====================================================================
        ..._rutinasHombrePrincipiante,
        ..._rutinasHombreMedio,
        ..._rutinasHombreAvanzado,
        ..._rutinasHombreExperto,

        // =====================================================================
        // RUTINAS PARA MUJERES
        // =====================================================================
        ..._rutinasMujerPrincipiante,
        ..._rutinasMujerMedio,
        ..._rutinasMujerAvanzado,
        ..._rutinasMujerExperto,

        // =====================================================================
        // RUTINAS UNISEX
        // =====================================================================
        ..._rutinasUnisexPrincipiante,
        ..._rutinasUnisexMedio,
        ..._rutinasUnisexAvanzado,
        ..._rutinasUnisexExperto,
      ];

  // ===========================================================================
  // SECCIÓN 1: RUTINAS HOMBRE - PRINCIPIANTE
  // ===========================================================================

  static const List<RoutineModel> _rutinasHombrePrincipiante = [
    // Full Body Básico para principiantes
    RoutineModel(
      id: 'hombre_principiante_fullbody',
      nombre: 'Full Body Iniciación',
      descripcion:
          'Rutina de cuerpo completo ideal para comenzar. Enfoque en aprender los patrones de movimiento básicos con máquinas guiadas.',
      dificultad: RoutineDifficulty.principiante,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.hombre,
      duracionMinutos: 45,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
      ejercicios: [
        // Tren inferior
        RoutineExercise(
          machineId: 'prensa_45_grados',
          machineName: 'Prensa 45 Grados',
          sets: 3,
          reps: 12,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'extension_cuadriceps',
          machineName: 'Extensión de Cuádriceps',
          sets: 3,
          reps: 12,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'femoral_sentado',
          machineName: 'Femoral Sentado',
          sets: 3,
          reps: 12,
          orden: 3,
        ),
        // Tren superior
        RoutineExercise(
          machineId: 'chest_press_horizontal',
          machineName: 'Press de Pecho Horizontal',
          sets: 3,
          reps: 12,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 3,
          reps: 12,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 3,
          reps: 12,
          orden: 6,
        ),
      ],
    ),

    // Tren Superior Básico
    RoutineModel(
      id: 'hombre_principiante_tren_superior',
      nombre: 'Tren Superior Básico',
      descripcion:
          'Introducción al entrenamiento de tren superior. Pecho, espalda, hombros y brazos con máquinas guiadas.',
      dificultad: RoutineDifficulty.principiante,
      parteDelCuerpo: RoutineBodyPart.trenSuperior,
      genero: RoutineGender.hombre,
      duracionMinutos: 40,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c149a?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'chest_press_horizontal',
          machineName: 'Press de Pecho Horizontal',
          sets: 3,
          reps: 12,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'pec_fly',
          machineName: 'Pec Fly',
          sets: 3,
          reps: 12,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 3,
          reps: 12,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'seated_row_machine',
          machineName: 'Remo Sentado',
          sets: 3,
          reps: 12,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 3,
          reps: 12,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'preacher_curl_machine',
          machineName: 'Curl Predicador',
          sets: 3,
          reps: 12,
          orden: 6,
        ),
      ],
    ),

    // Tren Inferior Básico
    RoutineModel(
      id: 'hombre_principiante_tren_inferior',
      nombre: 'Piernas Básico',
      descripcion:
          'Rutina de piernas para principiantes enfocada en desarrollar fuerza base en cuádriceps, isquiotibiales y glúteos.',
      dificultad: RoutineDifficulty.principiante,
      parteDelCuerpo: RoutineBodyPart.trenInferior,
      genero: RoutineGender.hombre,
      duracionMinutos: 35,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1434608519344-49d77a699e1d?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'prensa_45_grados',
          machineName: 'Prensa 45 Grados',
          sets: 4,
          reps: 12,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'extension_cuadriceps',
          machineName: 'Extensión de Cuádriceps',
          sets: 3,
          reps: 15,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'femoral_sentado',
          machineName: 'Femoral Sentado',
          sets: 3,
          reps: 15,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'abductor_machine',
          machineName: 'Abductor',
          sets: 3,
          reps: 15,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'aductor_machine',
          machineName: 'Aductor',
          sets: 3,
          reps: 15,
          orden: 5,
        ),
      ],
    ),
  ];

  // ===========================================================================
  // SECCIÓN 2: RUTINAS HOMBRE - MEDIO
  // ===========================================================================

  static const List<RoutineModel> _rutinasHombreMedio = [
    // Full Body Intermedio
    RoutineModel(
      id: 'hombre_medio_fullbody',
      nombre: 'Full Body Potencia',
      descripcion:
          'Rutina de cuerpo completo con mayor intensidad. Combina máquinas y ejercicios compuestos para desarrollo equilibrado.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.hombre,
      duracionMinutos: 60,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'squat_rack',
          machineName: 'Rack de Sentadillas',
          sets: 4,
          reps: 10,
          notas: 'Sentadilla libre',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'prensa_45_grados',
          machineName: 'Prensa 45 Grados',
          sets: 4,
          reps: 12,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'chest_press_incline',
          machineName: 'Press Inclinado',
          sets: 4,
          reps: 10,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 4,
          reps: 10,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 3,
          reps: 12,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 3,
          reps: 15,
          orden: 6,
        ),
      ],
    ),

    // Día de Empuje (Push)
    RoutineModel(
      id: 'hombre_medio_push',
      nombre: 'Día de Empuje',
      descripcion:
          'Entrenamiento enfocado en patrones de empuje: pecho, hombros delanteros y tríceps.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.pecho,
      genero: RoutineGender.hombre,
      duracionMinutos: 50,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'chest_press_incline',
          machineName: 'Press Inclinado',
          sets: 4,
          reps: 10,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'chest_press_horizontal',
          machineName: 'Press de Pecho Horizontal',
          sets: 4,
          reps: 10,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'pec_fly',
          machineName: 'Pec Fly',
          sets: 3,
          reps: 12,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 4,
          reps: 10,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'lateral_raise_machine',
          machineName: 'Elevaciones Laterales',
          sets: 3,
          reps: 15,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'cable_crossover',
          machineName: 'Cable Crossover',
          sets: 3,
          reps: 12,
          notas: 'Extensiones de tríceps',
          orden: 6,
        ),
      ],
    ),

    // Día de Jalón (Pull)
    RoutineModel(
      id: 'hombre_medio_pull',
      nombre: 'Día de Jalón',
      descripcion:
          'Entrenamiento enfocado en patrones de tracción: espalda, deltoides posterior y bíceps.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.espalda,
      genero: RoutineGender.hombre,
      duracionMinutos: 50,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 4,
          reps: 10,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'seated_row_machine',
          machineName: 'Remo Sentado',
          sets: 4,
          reps: 10,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'cable_crossover',
          machineName: 'Cable Crossover',
          sets: 3,
          reps: 12,
          notas: 'Face pull para deltoides posterior',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 3,
          reps: 15,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'preacher_curl_machine',
          machineName: 'Curl Predicador',
          sets: 3,
          reps: 12,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'cable_crossover',
          machineName: 'Cable Crossover',
          sets: 3,
          reps: 12,
          notas: 'Curl de bíceps en polea',
          orden: 6,
        ),
      ],
    ),

    // Día de Piernas Intermedio
    RoutineModel(
      id: 'hombre_medio_piernas',
      nombre: 'Piernas Completo',
      descripcion:
          'Rutina completa de tren inferior con énfasis en desarrollo de fuerza y masa muscular.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.trenInferior,
      genero: RoutineGender.hombre,
      duracionMinutos: 55,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'squat_rack',
          machineName: 'Rack de Sentadillas',
          sets: 4,
          reps: 8,
          notas: 'Sentadilla libre con barra',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'prensa_45_grados',
          machineName: 'Prensa 45 Grados',
          sets: 4,
          reps: 10,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'hack_squat',
          machineName: 'Sentadilla Hack',
          sets: 3,
          reps: 12,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'femoral_acostado',
          machineName: 'Femoral Acostado',
          sets: 4,
          reps: 12,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'extension_cuadriceps',
          machineName: 'Extensión de Cuádriceps',
          sets: 3,
          reps: 15,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'glute_kickback',
          machineName: 'Glute Kickback',
          sets: 3,
          reps: 12,
          orden: 6,
        ),
      ],
    ),
  ];

  // ===========================================================================
  // SECCIÓN 3: RUTINAS HOMBRE - AVANZADO
  // ===========================================================================

  static const List<RoutineModel> _rutinasHombreAvanzado = [
    // Push Avanzado
    RoutineModel(
      id: 'hombre_avanzado_push',
      nombre: 'Push Day Intenso',
      descripcion:
          'Rutina de empuje de alta intensidad con técnicas avanzadas. Incluye pre-fatiga y super series.',
      dificultad: RoutineDifficulty.avanzado,
      parteDelCuerpo: RoutineBodyPart.pecho,
      genero: RoutineGender.hombre,
      duracionMinutos: 65,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1532029837206-abbe2b7620e3?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'pec_fly',
          machineName: 'Pec Fly',
          sets: 3,
          reps: 15,
          notas: 'Pre-fatiga antes del press',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'chest_press_incline',
          machineName: 'Press Inclinado',
          sets: 4,
          reps: 8,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'chest_press_hammer',
          machineName: 'Press Hammer',
          sets: 4,
          reps: 10,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'chest_press_decline',
          machineName: 'Press Declinado',
          sets: 3,
          reps: 10,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'cable_crossover',
          machineName: 'Cable Crossover',
          sets: 4,
          reps: 12,
          notas: 'Cruce de cables alto a bajo',
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 4,
          reps: 10,
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'lateral_raise_machine',
          machineName: 'Elevaciones Laterales',
          sets: 4,
          reps: 15,
          notas: 'Drop set en la última serie',
          orden: 7,
        ),
      ],
    ),

    // Pull Avanzado
    RoutineModel(
      id: 'hombre_avanzado_pull',
      nombre: 'Pull Day Intenso',
      descripcion:
          'Entrenamiento de espalda de alto volumen con enfoque en amplitud y grosor.',
      dificultad: RoutineDifficulty.avanzado,
      parteDelCuerpo: RoutineBodyPart.espalda,
      genero: RoutineGender.hombre,
      duracionMinutos: 65,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 4,
          reps: 10,
          notas: 'Agarre ancho para amplitud',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'seated_row_machine',
          machineName: 'Remo Sentado',
          sets: 4,
          reps: 10,
          notas: 'Agarre cerrado para grosor',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'barra_olimpica',
          machineName: 'Barra Olímpica',
          sets: 4,
          reps: 8,
          notas: 'Remo con barra',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'cable_crossover',
          machineName: 'Cable Crossover',
          sets: 3,
          reps: 12,
          notas: 'Pullover en polea alta',
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 3,
          reps: 15,
          notas: 'Con peso adicional',
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'preacher_curl_machine',
          machineName: 'Curl Predicador',
          sets: 4,
          reps: 10,
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'barra_z',
          machineName: 'Barra Z',
          sets: 3,
          reps: 12,
          notas: 'Curl martillo',
          orden: 7,
        ),
      ],
    ),

    // Piernas Avanzado
    RoutineModel(
      id: 'hombre_avanzado_piernas',
      nombre: 'Leg Day Destructor',
      descripcion:
          'Rutina intensa de piernas con alto volumen. Incluye compuestos pesados y aislamiento.',
      dificultad: RoutineDifficulty.avanzado,
      parteDelCuerpo: RoutineBodyPart.trenInferior,
      genero: RoutineGender.hombre,
      duracionMinutos: 70,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1517963879433-6ad2b056d712?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'squat_rack',
          machineName: 'Rack de Sentadillas',
          sets: 5,
          reps: 6,
          notas: 'Sentadilla profunda con pausa',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'hack_squat',
          machineName: 'Sentadilla Hack',
          sets: 4,
          reps: 10,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'sentadilla_pendulo',
          machineName: 'Sentadilla Péndulo',
          sets: 3,
          reps: 12,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'prensa_45_grados',
          machineName: 'Prensa 45 Grados',
          sets: 4,
          reps: 12,
          notas: 'Pies altos para glúteos',
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'femoral_acostado',
          machineName: 'Femoral Acostado',
          sets: 4,
          reps: 12,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'extension_cuadriceps',
          machineName: 'Extensión de Cuádriceps',
          sets: 4,
          reps: 15,
          notas: 'Drop set final',
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'sentadilla_sissy',
          machineName: 'Sentadilla Sissy',
          sets: 3,
          reps: 12,
          notas: 'Finalizador de cuádriceps',
          orden: 7,
        ),
      ],
    ),

    // Full Body Intenso
    RoutineModel(
      id: 'hombre_avanzado_fullbody',
      nombre: 'Full Body Power',
      descripcion:
          'Rutina de cuerpo completo de alta intensidad para atletas experimentados.',
      dificultad: RoutineDifficulty.avanzado,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.hombre,
      duracionMinutos: 75,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'barra_hexagonal',
          machineName: 'Barra Hexagonal',
          sets: 4,
          reps: 6,
          notas: 'Peso muerto trap bar',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'squat_rack',
          machineName: 'Rack de Sentadillas',
          sets: 4,
          reps: 8,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'chest_press_incline',
          machineName: 'Press Inclinado',
          sets: 4,
          reps: 8,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 4,
          reps: 8,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 3,
          reps: 10,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'femoral_acostado',
          machineName: 'Femoral Acostado',
          sets: 3,
          reps: 12,
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 3,
          reps: 15,
          orden: 7,
        ),
      ],
    ),
  ];

  // ===========================================================================
  // SECCIÓN 4: RUTINAS HOMBRE - EXPERTO
  // ===========================================================================

  static const List<RoutineModel> _rutinasHombreExperto = [
    // Fuerza Máxima
    RoutineModel(
      id: 'hombre_experto_fuerza',
      nombre: 'Fuerza Máxima',
      descripcion:
          'Programa de fuerza pura enfocado en los levantamientos principales. Para atletas con mínimo 2 años de experiencia.',
      dificultad: RoutineDifficulty.experto,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.hombre,
      duracionMinutos: 90,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'squat_rack',
          machineName: 'Rack de Sentadillas',
          sets: 5,
          reps: 5,
          notas: 'Sentadilla al 85% 1RM',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'barra_olimpica',
          machineName: 'Barra Olímpica',
          sets: 5,
          reps: 5,
          notas: 'Press banca al 85% 1RM',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'barra_hexagonal',
          machineName: 'Barra Hexagonal',
          sets: 5,
          reps: 5,
          notas: 'Peso muerto al 85% 1RM',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'barra_olimpica',
          machineName: 'Barra Olímpica',
          sets: 4,
          reps: 6,
          notas: 'Remo Pendlay',
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'barra_olimpica',
          machineName: 'Barra Olímpica',
          sets: 4,
          reps: 6,
          notas: 'Press militar de pie',
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 3,
          reps: 12,
          notas: 'Con peso para core',
          orden: 6,
        ),
      ],
    ),

    // Hipertrofia Avanzada
    RoutineModel(
      id: 'hombre_experto_hipertrofia',
      nombre: 'Hipertrofia Extrema',
      descripcion:
          'Rutina de alto volumen diseñada para máxima hipertrofia muscular. Técnicas intensas como rest-pause y drop sets.',
      dificultad: RoutineDifficulty.experto,
      parteDelCuerpo: RoutineBodyPart.trenSuperior,
      genero: RoutineGender.hombre,
      duracionMinutos: 80,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1583500178450-e59e4309b57a?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'chest_press_incline',
          machineName: 'Press Inclinado',
          sets: 5,
          reps: 8,
          notas: 'Rest-pause en última serie',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'cable_crossover',
          machineName: 'Cable Crossover',
          sets: 4,
          reps: 12,
          notas: 'Cruce de cables: super serie con pec fly',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'pec_fly',
          machineName: 'Pec Fly',
          sets: 4,
          reps: 12,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 5,
          reps: 10,
          notas: 'Diferentes agarres cada serie',
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'seated_row_machine',
          machineName: 'Remo Sentado',
          sets: 4,
          reps: 10,
          notas: 'Drop set final',
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 4,
          reps: 10,
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'lateral_raise_machine',
          machineName: 'Elevaciones Laterales',
          sets: 5,
          reps: 15,
          notas: 'Triple drop set final',
          orden: 7,
        ),
      ],
    ),
  ];

  // ===========================================================================
  // SECCIÓN 5: RUTINAS MUJER - PRINCIPIANTE
  // ===========================================================================

  static const List<RoutineModel> _rutinasMujerPrincipiante = [
    // Full Body Tonificación
    RoutineModel(
      id: 'mujer_principiante_fullbody',
      nombre: 'Full Body Tonificación',
      descripcion:
          'Rutina de cuerpo completo ideal para comenzar. Enfoque en tonificación general con máquinas seguras.',
      dificultad: RoutineDifficulty.principiante,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.mujer,
      duracionMinutos: 45,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'prensa_45_grados',
          machineName: 'Prensa 45 Grados',
          sets: 3,
          reps: 15,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'glute_kickback',
          machineName: 'Glute Kickback',
          sets: 3,
          reps: 15,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'abductor_machine',
          machineName: 'Abductor',
          sets: 3,
          reps: 15,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'chest_press_horizontal',
          machineName: 'Press de Pecho Horizontal',
          sets: 3,
          reps: 15,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 3,
          reps: 15,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 3,
          reps: 15,
          orden: 6,
        ),
      ],
    ),

    // Glúteos y Piernas Básico
    RoutineModel(
      id: 'mujer_principiante_gluteos',
      nombre: 'Glúteos y Piernas Básico',
      descripcion:
          'Rutina enfocada en tonificar y fortalecer glúteos, muslos y piernas con máquinas guiadas.',
      dificultad: RoutineDifficulty.principiante,
      parteDelCuerpo: RoutineBodyPart.trenInferior,
      genero: RoutineGender.mujer,
      duracionMinutos: 40,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1609899464726-209befcdd5c9?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'glute_kickback',
          machineName: 'Glute Kickback',
          sets: 4,
          reps: 15,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'prensa_45_grados',
          machineName: 'Prensa 45 Grados',
          sets: 3,
          reps: 15,
          notas: 'Pies altos para glúteos',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'abductor_machine',
          machineName: 'Abductor',
          sets: 3,
          reps: 20,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'aductor_machine',
          machineName: 'Aductor',
          sets: 3,
          reps: 20,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'femoral_sentado',
          machineName: 'Femoral Sentado',
          sets: 3,
          reps: 15,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'extension_cuadriceps',
          machineName: 'Extensión de Cuádriceps',
          sets: 3,
          reps: 15,
          orden: 6,
        ),
      ],
    ),

    // Tren Superior Tonificación
    RoutineModel(
      id: 'mujer_principiante_tren_superior',
      nombre: 'Brazos y Espalda Definidos',
      descripcion:
          'Rutina de tren superior para tonificar brazos, hombros y espalda sin ganar volumen excesivo.',
      dificultad: RoutineDifficulty.principiante,
      parteDelCuerpo: RoutineBodyPart.trenSuperior,
      genero: RoutineGender.mujer,
      duracionMinutos: 35,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1550345332-09e3ac987658?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 3,
          reps: 15,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'seated_row_machine',
          machineName: 'Remo Sentado',
          sets: 3,
          reps: 15,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'chest_press_horizontal',
          machineName: 'Press de Pecho Horizontal',
          sets: 3,
          reps: 15,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 3,
          reps: 15,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'preacher_curl_machine',
          machineName: 'Curl Predicador',
          sets: 3,
          reps: 15,
          orden: 5,
        ),
      ],
    ),
  ];

  // ===========================================================================
  // SECCIÓN 6: RUTINAS MUJER - MEDIO
  // ===========================================================================

  static const List<RoutineModel> _rutinasMujerMedio = [
    // Full Body Intermedio
    RoutineModel(
      id: 'mujer_medio_fullbody',
      nombre: 'Full Body Sculpt',
      descripcion:
          'Rutina de cuerpo completo con mayor intensidad para esculpir y definir el cuerpo.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.mujer,
      duracionMinutos: 55,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1548690312-e3b507d8c110?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'smith_machine',
          machineName: 'Sentadilla en Smith',
          sets: 4,
          reps: 12,
          notas: 'Sentadilla sumo',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'glute_kickback',
          machineName: 'Glute Kickback',
          sets: 4,
          reps: 12,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'prensa_45_grados',
          machineName: 'Prensa 45 Grados',
          sets: 3,
          reps: 12,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'chest_press_incline',
          machineName: 'Press Inclinado',
          sets: 3,
          reps: 12,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 3,
          reps: 12,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'lateral_raise_machine',
          machineName: 'Elevaciones Laterales',
          sets: 3,
          reps: 15,
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 3,
          reps: 15,
          orden: 7,
        ),
      ],
    ),

    // Glúteos Enfoque
    RoutineModel(
      id: 'mujer_medio_gluteos',
      nombre: 'Glute Builder',
      descripcion:
          'Rutina especializada en desarrollo de glúteos con múltiples ángulos y patrones de movimiento.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.trenInferior,
      genero: RoutineGender.mujer,
      duracionMinutos: 50,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'sentadilla_pendulo',
          machineName: 'Sentadilla Péndulo',
          sets: 4,
          reps: 12,
          notas: 'Énfasis en empujar con talones',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'glute_kickback',
          machineName: 'Glute Kickback',
          sets: 4,
          reps: 12,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'prensa_45_grados',
          machineName: 'Prensa 45 Grados',
          sets: 4,
          reps: 12,
          notas: 'Pies muy altos, solo talones',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'abductor_machine',
          machineName: 'Abductor',
          sets: 4,
          reps: 15,
          notas: 'Super serie con aductor',
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'aductor_machine',
          machineName: 'Aductor',
          sets: 4,
          reps: 15,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'femoral_acostado',
          machineName: 'Femoral Acostado',
          sets: 3,
          reps: 15,
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 3,
          reps: 15,
          notas: 'Enfoque en glúteos',
          orden: 7,
        ),
      ],
    ),

    // Tren Superior Definición
    RoutineModel(
      id: 'mujer_medio_tren_superior',
      nombre: 'Upper Body Definition',
      descripcion:
          'Rutina de tren superior para crear definición en brazos, hombros, espalda y pecho.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.trenSuperior,
      genero: RoutineGender.mujer,
      duracionMinutos: 45,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 4,
          reps: 12,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'seated_row_machine',
          machineName: 'Remo Sentado',
          sets: 4,
          reps: 12,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'chest_press_incline',
          machineName: 'Press Inclinado',
          sets: 3,
          reps: 12,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'pec_fly',
          machineName: 'Pec Fly',
          sets: 3,
          reps: 15,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 3,
          reps: 12,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'lateral_raise_machine',
          machineName: 'Elevaciones Laterales',
          sets: 3,
          reps: 15,
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'cable_crossover',
          machineName: 'Cable Crossover',
          sets: 3,
          reps: 15,
          notas: 'Tríceps y bíceps alternados',
          orden: 7,
        ),
      ],
    ),

    // Piernas Completo
    RoutineModel(
      id: 'mujer_medio_piernas',
      nombre: 'Leg Day Complete',
      descripcion:
          'Rutina completa de piernas trabajando cuádriceps, isquiotibiales, glúteos y pantorrillas.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.trenInferior,
      genero: RoutineGender.mujer,
      duracionMinutos: 55,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'smith_machine',
          machineName: 'Sentadilla en Smith',
          sets: 4,
          reps: 12,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'hack_squat',
          machineName: 'Sentadilla Hack',
          sets: 4,
          reps: 12,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'glute_kickback',
          machineName: 'Glute Kickback',
          sets: 3,
          reps: 15,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'femoral_acostado',
          machineName: 'Femoral Acostado',
          sets: 4,
          reps: 12,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'extension_cuadriceps',
          machineName: 'Extensión de Cuádriceps',
          sets: 3,
          reps: 15,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'abductor_machine',
          machineName: 'Abductor',
          sets: 3,
          reps: 20,
          orden: 6,
        ),
      ],
    ),
  ];

  // ===========================================================================
  // SECCIÓN 7: RUTINAS MUJER - AVANZADO
  // ===========================================================================

  static const List<RoutineModel> _rutinasMujerAvanzado = [
    // Full Body Intenso
    RoutineModel(
      id: 'mujer_avanzado_fullbody',
      nombre: 'Full Body Athletic',
      descripcion:
          'Rutina de cuerpo completo de alta intensidad para atletas femeninas experimentadas.',
      dificultad: RoutineDifficulty.avanzado,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.mujer,
      duracionMinutos: 65,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'squat_rack',
          machineName: 'Rack de Sentadillas',
          sets: 4,
          reps: 10,
          notas: 'Sentadilla profunda',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'barra_hexagonal',
          machineName: 'Barra Hexagonal',
          sets: 4,
          reps: 10,
          notas: 'Peso muerto rumano',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'glute_kickback',
          machineName: 'Glute Kickback',
          sets: 4,
          reps: 12,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'chest_press_incline',
          machineName: 'Press Inclinado',
          sets: 4,
          reps: 10,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 4,
          reps: 10,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 3,
          reps: 12,
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 3,
          reps: 15,
          orden: 7,
        ),
      ],
    ),

    // Glúteos Avanzado
    RoutineModel(
      id: 'mujer_avanzado_gluteos',
      nombre: 'Glute Intensive',
      descripcion:
          'Rutina avanzada enfocada en máximo desarrollo de glúteos con técnicas intensificadoras.',
      dificultad: RoutineDifficulty.avanzado,
      parteDelCuerpo: RoutineBodyPart.trenInferior,
      genero: RoutineGender.mujer,
      duracionMinutos: 60,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'squat_rack',
          machineName: 'Rack de Sentadillas',
          sets: 4,
          reps: 10,
          notas: 'Sentadilla sumo con pausa',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'sentadilla_pendulo',
          machineName: 'Sentadilla Péndulo',
          sets: 4,
          reps: 12,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'glute_kickback',
          machineName: 'Glute Kickback',
          sets: 4,
          reps: 12,
          notas: 'Drop set final',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'prensa_45_grados',
          machineName: 'Prensa 45 Grados',
          sets: 4,
          reps: 15,
          notas: 'Unilateral, pies altos',
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'femoral_acostado',
          machineName: 'Femoral Acostado',
          sets: 4,
          reps: 12,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'abductor_machine',
          machineName: 'Abductor',
          sets: 4,
          reps: 20,
          notas: 'Pulsos al final',
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 3,
          reps: 20,
          notas: 'Squeeze de glúteos arriba',
          orden: 7,
        ),
      ],
    ),

    // Push/Pull Combinado
    RoutineModel(
      id: 'mujer_avanzado_push_pull',
      nombre: 'Push Pull Combo',
      descripcion:
          'Rutina de tren superior combinando patrones de empuje y tracción para definición completa.',
      dificultad: RoutineDifficulty.avanzado,
      parteDelCuerpo: RoutineBodyPart.trenSuperior,
      genero: RoutineGender.mujer,
      duracionMinutos: 55,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1597452485669-2c7bb5fef90d?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 4,
          reps: 10,
          notas: 'Super serie con press',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'chest_press_incline',
          machineName: 'Press Inclinado',
          sets: 4,
          reps: 10,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'seated_row_machine',
          machineName: 'Remo Sentado',
          sets: 4,
          reps: 12,
          notas: 'Super serie con pec fly',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'pec_fly',
          machineName: 'Pec Fly',
          sets: 4,
          reps: 12,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 4,
          reps: 10,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'lateral_raise_machine',
          machineName: 'Elevaciones Laterales',
          sets: 4,
          reps: 15,
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'cable_crossover',
          machineName: 'Cable Crossover',
          sets: 3,
          reps: 15,
          notas: 'Face pulls',
          orden: 7,
        ),
      ],
    ),
  ];

  // ===========================================================================
  // SECCIÓN 8: RUTINAS MUJER - EXPERTO
  // ===========================================================================

  static const List<RoutineModel> _rutinasMujerExperto = [
    // Fuerza Funcional
    RoutineModel(
      id: 'mujer_experto_fuerza',
      nombre: 'Fuerza Funcional Femenina',
      descripcion:
          'Programa de fuerza diseñado para atletas femeninas. Enfoque en movimientos compuestos y potencia.',
      dificultad: RoutineDifficulty.experto,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.mujer,
      duracionMinutos: 75,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'squat_rack',
          machineName: 'Rack de Sentadillas',
          sets: 5,
          reps: 5,
          notas: 'Sentadilla trasera pesada',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'barra_hexagonal',
          machineName: 'Barra Hexagonal',
          sets: 5,
          reps: 5,
          notas: 'Peso muerto',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'smith_machine',
          machineName: 'Sentadilla en Smith',
          sets: 4,
          reps: 8,
          notas: 'Hip thrust en Smith',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'barra_olimpica',
          machineName: 'Barra Olímpica',
          sets: 4,
          reps: 8,
          notas: 'Remo con barra',
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'barra_olimpica',
          machineName: 'Barra Olímpica',
          sets: 4,
          reps: 8,
          notas: 'Press militar',
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 3,
          reps: 15,
          notas: 'Con peso',
          orden: 6,
        ),
      ],
    ),

    // Competición Bikini/Fitness
    RoutineModel(
      id: 'mujer_experto_competicion',
      nombre: 'Competition Prep',
      descripcion:
          'Rutina de preparación para competición. Alto volumen enfocado en proporción y simetría.',
      dificultad: RoutineDifficulty.experto,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.mujer,
      duracionMinutos: 80,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1611672585731-fa10603fb9e0?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'sentadilla_pendulo',
          machineName: 'Sentadilla Péndulo',
          sets: 5,
          reps: 12,
          notas: 'Tempo lento 4-0-2',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'glute_kickback',
          machineName: 'Glute Kickback',
          sets: 5,
          reps: 15,
          notas: 'Drop sets',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'femoral_acostado',
          machineName: 'Femoral Acostado',
          sets: 4,
          reps: 12,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 4,
          reps: 12,
          notas: 'Para amplitud de espalda',
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'lateral_raise_machine',
          machineName: 'Elevaciones Laterales',
          sets: 5,
          reps: 15,
          notas: 'Para caps de hombros',
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'cable_crossover',
          machineName: 'Cable Crossover',
          sets: 4,
          reps: 15,
          notas: 'Glute cable kickback',
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 4,
          reps: 20,
          orden: 7,
        ),
      ],
    ),
  ];

  // ===========================================================================
  // SECCIÓN 9: RUTINAS UNISEX - PRINCIPIANTE
  // ===========================================================================

  static const List<RoutineModel> _rutinasUnisexPrincipiante = [
    // Iniciación General
    RoutineModel(
      id: 'unisex_principiante_iniciacion',
      nombre: 'Bienvenida al Gym',
      descripcion:
          'Rutina de introducción perfecta para tu primer día. Conoce las máquinas principales en un circuito suave.',
      dificultad: RoutineDifficulty.principiante,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.unisex,
      duracionMinutos: 30,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'treadmill',
          machineName: 'Caminadora',
          sets: 1,
          reps: 5,
          notas: '5 min calentamiento suave',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'prensa_45_grados',
          machineName: 'Prensa 45 Grados',
          sets: 2,
          reps: 12,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'chest_press_horizontal',
          machineName: 'Press de Pecho Horizontal',
          sets: 2,
          reps: 12,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 2,
          reps: 12,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 2,
          reps: 12,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'stationary_bike',
          machineName: 'Bicicleta Estática',
          sets: 1,
          reps: 5,
          notas: '5 min enfriamiento',
          orden: 6,
        ),
      ],
    ),

    // Cardio Suave
    RoutineModel(
      id: 'unisex_principiante_cardio',
      nombre: 'Cardio Suave',
      descripcion:
          'Sesión cardiovascular de baja intensidad para mejorar resistencia y quemar calorías.',
      dificultad: RoutineDifficulty.principiante,
      parteDelCuerpo: RoutineBodyPart.mixto,
      genero: RoutineGender.unisex,
      duracionMinutos: 35,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'treadmill',
          machineName: 'Caminadora',
          sets: 1,
          reps: 10,
          notas: '10 min caminata inclinada',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'stationary_bike',
          machineName: 'Bicicleta Estática',
          sets: 1,
          reps: 10,
          notas: '10 min ritmo moderado',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'elliptical',
          machineName: 'Elíptica',
          sets: 1,
          reps: 10,
          notas: '10 min bajo impacto',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'step_stepper',
          machineName: 'Step/Stepper',
          sets: 1,
          reps: 5,
          notas: '5 min enfriamiento',
          orden: 4,
        ),
      ],
    ),
  ];

  // ===========================================================================
  // SECCIÓN 10: RUTINAS UNISEX - MEDIO
  // ===========================================================================

  static const List<RoutineModel> _rutinasUnisexMedio = [
    // Push-Pull Básico
    RoutineModel(
      id: 'unisex_medio_push_pull',
      nombre: 'Push-Pull Balance',
      descripcion:
          'Rutina equilibrada que trabaja patrones de empuje y tracción en la misma sesión.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.trenSuperior,
      genero: RoutineGender.unisex,
      duracionMinutos: 50,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1581122584612-713f89daa8eb?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'chest_press_incline',
          machineName: 'Press Inclinado',
          sets: 4,
          reps: 10,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 4,
          reps: 10,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'pec_fly',
          machineName: 'Pec Fly',
          sets: 3,
          reps: 12,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'seated_row_machine',
          machineName: 'Remo Sentado',
          sets: 3,
          reps: 12,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 3,
          reps: 12,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'cable_crossover',
          machineName: 'Cable Crossover',
          sets: 3,
          reps: 12,
          notas: 'Face pulls',
          orden: 6,
        ),
      ],
    ),

    // HIIT Cardio
    RoutineModel(
      id: 'unisex_medio_hiit',
      nombre: 'HIIT Quema Grasa',
      descripcion:
          'Entrenamiento intervalado de alta intensidad para máxima quema calórica.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.mixto,
      genero: RoutineGender.unisex,
      duracionMinutos: 30,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1434596922112-19c563067271?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'treadmill',
          machineName: 'Caminadora',
          sets: 1,
          reps: 5,
          notas: '5 min calentamiento',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'rowing_machine',
          machineName: 'Remo',
          sets: 4,
          reps: 1,
          notas: '30seg sprint / 30seg descanso',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'battle_ropes',
          machineName: 'Battle Ropes',
          sets: 4,
          reps: 30,
          notas: '30seg trabajo / 30seg descanso',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'plyo_box',
          machineName: 'Cajón Pliométrico',
          sets: 4,
          reps: 15,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'stationary_bike',
          machineName: 'Bicicleta Estática',
          sets: 1,
          reps: 5,
          notas: '5 min enfriamiento',
          orden: 5,
        ),
      ],
    ),

    // Full Body Equilibrado
    RoutineModel(
      id: 'unisex_medio_fullbody',
      nombre: 'Full Body Equilibrado',
      descripcion:
          'Rutina de cuerpo completo equilibrada para desarrollo general.',
      dificultad: RoutineDifficulty.medio,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.unisex,
      duracionMinutos: 55,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'smith_machine',
          machineName: 'Sentadilla en Smith',
          sets: 4,
          reps: 10,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'prensa_45_grados',
          machineName: 'Prensa 45 Grados',
          sets: 3,
          reps: 12,
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'chest_press_horizontal',
          machineName: 'Press de Pecho Horizontal',
          sets: 4,
          reps: 10,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 4,
          reps: 10,
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 3,
          reps: 12,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 3,
          reps: 15,
          orden: 6,
        ),
      ],
    ),
  ];

  // ===========================================================================
  // SECCIÓN 11: RUTINAS UNISEX - AVANZADO
  // ===========================================================================

  static const List<RoutineModel> _rutinasUnisexAvanzado = [
    // Push-Pull-Legs en un día
    RoutineModel(
      id: 'unisex_avanzado_ppl',
      nombre: 'PPL Express',
      descripcion:
          'Rutina que combina push, pull y legs en una sola sesión de alta intensidad.',
      dificultad: RoutineDifficulty.avanzado,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.unisex,
      duracionMinutos: 70,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1584380931214-dbb5b72e7fd0?w=800&q=80',
      ejercicios: [
        // Push
        RoutineExercise(
          machineId: 'chest_press_incline',
          machineName: 'Press Inclinado',
          sets: 4,
          reps: 8,
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'shoulder_press_hammer',
          machineName: 'Press de Hombro Hammer',
          sets: 3,
          reps: 10,
          orden: 2,
        ),
        // Pull
        RoutineExercise(
          machineId: 'lat_pulldown_hammer',
          machineName: 'Jalón Hammer',
          sets: 4,
          reps: 8,
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'seated_row_machine',
          machineName: 'Remo Sentado',
          sets: 3,
          reps: 10,
          orden: 4,
        ),
        // Legs
        RoutineExercise(
          machineId: 'squat_rack',
          machineName: 'Rack de Sentadillas',
          sets: 4,
          reps: 8,
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'femoral_acostado',
          machineName: 'Femoral Acostado',
          sets: 3,
          reps: 12,
          orden: 6,
        ),
        // Core
        RoutineExercise(
          machineId: 'hyperextension',
          machineName: 'Hiperextensión',
          sets: 3,
          reps: 15,
          orden: 7,
        ),
      ],
    ),

    // Funcional Avanzado
    RoutineModel(
      id: 'unisex_avanzado_funcional',
      nombre: 'Functional Fitness',
      descripcion:
          'Entrenamiento funcional avanzado que combina fuerza, estabilidad y acondicionamiento.',
      dificultad: RoutineDifficulty.avanzado,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.unisex,
      duracionMinutos: 60,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'kettlebell_station',
          machineName: 'Estación Kettlebell',
          sets: 4,
          reps: 15,
          notas: 'Swing con kettlebell',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'trx_suspension',
          machineName: 'TRX',
          sets: 3,
          reps: 12,
          notas: 'Remo en suspensión',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'trx_suspension',
          machineName: 'TRX',
          sets: 3,
          reps: 12,
          notas: 'Push up en suspensión',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'plyo_box',
          machineName: 'Cajón Pliométrico',
          sets: 4,
          reps: 12,
          notas: 'Box jumps',
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'battle_ropes',
          machineName: 'Battle Ropes',
          sets: 4,
          reps: 30,
          notas: '30 segundos por serie',
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'cable_crossover',
          machineName: 'Cable Crossover',
          sets: 3,
          reps: 12,
          notas: 'Pallof press anti-rotación',
          orden: 6,
        ),
      ],
    ),

    // HIIT Avanzado
    RoutineModel(
      id: 'unisex_avanzado_hiit',
      nombre: 'HIIT Extremo',
      descripcion:
          'Entrenamiento intervalado de máxima intensidad. Solo para atletas experimentados.',
      dificultad: RoutineDifficulty.avanzado,
      parteDelCuerpo: RoutineBodyPart.mixto,
      genero: RoutineGender.unisex,
      duracionMinutos: 45,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1601422407692-ec4eeec1d9b3?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'rowing_machine',
          machineName: 'Remo',
          sets: 5,
          reps: 1,
          notas: '500m sprint máximo',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'battle_ropes',
          machineName: 'Battle Ropes',
          sets: 5,
          reps: 45,
          notas: '45 seg trabajo / 15 seg descanso',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'plyo_box',
          machineName: 'Cajón Pliométrico',
          sets: 5,
          reps: 20,
          notas: 'Burpee box jump',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'kettlebell_station',
          machineName: 'Estación Kettlebell',
          sets: 5,
          reps: 20,
          notas: 'Swing pesado',
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'treadmill',
          machineName: 'Caminadora',
          sets: 1,
          reps: 5,
          notas: 'Sprint final 1 min, 4 min enfriamiento',
          orden: 5,
        ),
      ],
    ),
  ];

  // ===========================================================================
  // SECCIÓN 12: RUTINAS UNISEX - EXPERTO
  // ===========================================================================

  static const List<RoutineModel> _rutinasUnisexExperto = [
    // CrossFit Style
    RoutineModel(
      id: 'unisex_experto_crossfit',
      nombre: 'WOD Intenso',
      descripcion:
          'Workout Of the Day estilo CrossFit. Combina levantamientos olímpicos con alta intensidad.',
      dificultad: RoutineDifficulty.experto,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.unisex,
      duracionMinutos: 60,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1533681904393-9ab6ebed745e?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'barra_olimpica',
          machineName: 'Barra Olímpica',
          sets: 5,
          reps: 3,
          notas: 'Clean & Press',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'squat_rack',
          machineName: 'Rack de Sentadillas',
          sets: 5,
          reps: 5,
          notas: 'Front squat',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'barra_hexagonal',
          machineName: 'Barra Hexagonal',
          sets: 5,
          reps: 5,
          notas: 'Peso muerto pesado',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'multi_gym',
          machineName: 'Multi Gym',
          sets: 4,
          reps: 10,
          notas: 'Pull ups',
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'plyo_box',
          machineName: 'Cajón Pliométrico',
          sets: 4,
          reps: 15,
          notas: 'Box jump over',
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'rowing_machine',
          machineName: 'Remo',
          sets: 1,
          reps: 1,
          notas: '1000m time trial',
          orden: 6,
        ),
      ],
    ),

    // Atletismo y Potencia
    RoutineModel(
      id: 'unisex_experto_atletismo',
      nombre: 'Athletic Power',
      descripcion:
          'Programa de potencia atlética para deportistas. Enfoque en velocidad, explosividad y fuerza.',
      dificultad: RoutineDifficulty.experto,
      parteDelCuerpo: RoutineBodyPart.fullBody,
      genero: RoutineGender.unisex,
      duracionMinutos: 75,
      esPlantilla: true,
      imageUrl: 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800&q=80',
      ejercicios: [
        RoutineExercise(
          machineId: 'plyo_box',
          machineName: 'Cajón Pliométrico',
          sets: 4,
          reps: 5,
          notas: 'Depth jumps',
          orden: 1,
        ),
        RoutineExercise(
          machineId: 'barra_olimpica',
          machineName: 'Barra Olímpica',
          sets: 5,
          reps: 3,
          notas: 'Power clean',
          orden: 2,
        ),
        RoutineExercise(
          machineId: 'squat_rack',
          machineName: 'Rack de Sentadillas',
          sets: 5,
          reps: 3,
          notas: 'Box squat explosivo',
          orden: 3,
        ),
        RoutineExercise(
          machineId: 'barra_hexagonal',
          machineName: 'Barra Hexagonal',
          sets: 4,
          reps: 5,
          notas: 'Salto con barra hexagonal',
          orden: 4,
        ),
        RoutineExercise(
          machineId: 'kettlebell_station',
          machineName: 'Estación Kettlebell',
          sets: 4,
          reps: 8,
          notas: 'Snatch con kettlebell',
          orden: 5,
        ),
        RoutineExercise(
          machineId: 'battle_ropes',
          machineName: 'Battle Ropes',
          sets: 5,
          reps: 30,
          notas: 'Máxima velocidad',
          orden: 6,
        ),
        RoutineExercise(
          machineId: 'treadmill',
          machineName: 'Caminadora',
          sets: 6,
          reps: 1,
          notas: 'Sprints 20seg / descanso 40seg',
          orden: 7,
        ),
      ],
    ),
  ];

  // ===========================================================================
  // MÉTODOS DE ACCESO Y BÚSQUEDA
  // ===========================================================================

  /// Obtener rutinas por género
  static List<RoutineModel> getByGender(RoutineGender gender) {
    if (gender == RoutineGender.unisex) return allRoutines;
    return allRoutines
        .where((r) => r.genero == gender || r.genero == RoutineGender.unisex)
        .toList();
  }

  /// Obtener rutina por ID
  static RoutineModel? getById(String id) {
    try {
      return allRoutines.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Obtener rutinas por dificultad
  static List<RoutineModel> getByDifficulty(RoutineDifficulty difficulty) {
    return allRoutines.where((r) => r.dificultad == difficulty).toList();
  }

  /// Obtener rutinas por parte del cuerpo
  static List<RoutineModel> getByBodyPart(RoutineBodyPart bodyPart) {
    return allRoutines.where((r) => r.parteDelCuerpo == bodyPart).toList();
  }

  /// Obtener rutinas filtradas por género y dificultad
  static List<RoutineModel> getFiltered({
    RoutineGender? gender,
    RoutineDifficulty? difficulty,
    RoutineBodyPart? bodyPart,
  }) {
    return allRoutines.where((r) {
      if (gender != null && gender != RoutineGender.unisex) {
        if (r.genero != gender && r.genero != RoutineGender.unisex) {
          return false;
        }
      }
      if (difficulty != null && r.dificultad != difficulty) return false;
      if (bodyPart != null && r.parteDelCuerpo != bodyPart) return false;
      return true;
    }).toList();
  }

  /// Buscar rutinas por nombre o descripción
  static List<RoutineModel> search(String query) {
    final lowerQuery = query.toLowerCase();
    return allRoutines
        .where((r) =>
            r.nombre.toLowerCase().contains(lowerQuery) ||
            (r.descripcion?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  /// Obtener rutinas que son plantillas
  static List<RoutineModel> get templates {
    return allRoutines.where((r) => r.esPlantilla).toList();
  }

  /// Total de rutinas
  static int get totalRoutines => allRoutines.length;

  /// Conteo por género
  static Map<RoutineGender, int> get countByGender {
    final counts = <RoutineGender, int>{};
    for (final gender in RoutineGender.values) {
      counts[gender] = allRoutines.where((r) => r.genero == gender).length;
    }
    return counts;
  }

  /// Conteo por dificultad
  static Map<RoutineDifficulty, int> get countByDifficulty {
    final counts = <RoutineDifficulty, int>{};
    for (final difficulty in RoutineDifficulty.values) {
      counts[difficulty] =
          allRoutines.where((r) => r.dificultad == difficulty).length;
    }
    return counts;
  }

  /// Conteo por parte del cuerpo
  static Map<RoutineBodyPart, int> get countByBodyPart {
    final counts = <RoutineBodyPart, int>{};
    for (final part in RoutineBodyPart.values) {
      counts[part] = allRoutines.where((r) => r.parteDelCuerpo == part).length;
    }
    return counts;
  }

  /// Obtener rutinas ordenadas por duración
  static List<RoutineModel> get byDurationAscending {
    final sorted = List<RoutineModel>.from(allRoutines);
    sorted.sort((a, b) => a.duracionMinutos.compareTo(b.duracionMinutos));
    return sorted;
  }

  /// Obtener rutinas de corta duración (menos de 40 min)
  static List<RoutineModel> get quickRoutines {
    return allRoutines.where((r) => r.duracionMinutos < 40).toList();
  }

  /// Obtener rutinas largas (más de 60 min)
  static List<RoutineModel> get longRoutines {
    return allRoutines.where((r) => r.duracionMinutos > 60).toList();
  }
}
