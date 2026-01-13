import '../models/models.dart';
import 'firebase_service.dart';
import '../../features/routines/data/machines_data.dart';

class MigrationService {
  final FirebaseService _firebaseService;

  MigrationService(this._firebaseService);

  /// Migrar todas las máquinas existentes a Firebase
  Future<void> migrateMachines() async {
    final isEmpty = await _firebaseService.isMachinesCollectionEmpty();
    if (!isEmpty) return; // Ya hay datos

    // Usar las máquinas del archivo MachinesData (57 máquinas)
    await _firebaseService.saveMachinesBatch(MachinesData.allMachines);
  }

  /// Forzar seed de todas las máquinas (actualiza/añade las que faltan)
  Future<void> forceSeedMachines() async {
    // Guardar todas las máquinas de MachinesData (sobreescribe existentes)
    await _firebaseService.saveMachinesBatch(MachinesData.allMachines);
  }

  /// Migrar todas las rutinas existentes a Firebase
  /// Si la colección está vacía, añade todas las rutinas
  /// Si ya hay datos, verifica y añade las rutinas faltantes
  Future<void> migrateRoutines() async {
    final isEmpty = await _firebaseService.isRoutinesCollectionEmpty();
    final routines = _getDefaultRoutines();

    if (isEmpty) {
      // Colección vacía, añadir todas las rutinas
      await _firebaseService.saveRoutinesBatch(routines);
    } else {
      // Colección tiene datos, verificar y añadir las faltantes
      await _addMissingRoutines(routines);
    }
  }

  /// Añade las rutinas que faltan en la colección
  Future<void> _addMissingRoutines(List<RoutineModel> defaultRoutines) async {
    try {
      final existingRoutines = await _firebaseService.getAllRoutinesOnce();
      final existingIds = existingRoutines.map((r) => r.id).toSet();

      final missingRoutines = defaultRoutines
          .where((r) => !existingIds.contains(r.id))
          .toList();

      if (missingRoutines.isNotEmpty) {
        await _firebaseService.saveRoutinesBatch(missingRoutines);
      }
    } catch (e) {
      // Si falla, intentar guardar todas las rutinas (las duplicadas se ignorarán)
      await _firebaseService.saveRoutinesBatch(defaultRoutines);
    }
  }

  /// Migrar todo y ejecutar tareas de limpieza
  Future<void> migrateAll() async {
    // Forzar seed de máquinas para asegurar que todas las 57 estén presentes
    await forceSeedMachines();
    await migrateRoutines();

    // Ejecutar limpieza de datos antiguos
    await _firebaseService.runCleanupTasks();
  }

  /// Lista de rutinas predefinidas con plantillas
  List<RoutineModel> _getDefaultRoutines() {
    return [
      // Plantillas rápidas
      RoutineModel(
        id: 'template_fullbody_45',
        nombre: 'Full Body 45 min',
        descripcion: 'Rutina completa de cuerpo en 45 minutos. Ideal para principiantes.',
        dificultad: RoutineDifficulty.principiante,
        parteDelCuerpo: RoutineBodyPart.fullBody,
        genero: RoutineGender.unisex,
        duracionMinutos: 45,
        esPlantilla: true,
        ejercicios: [
          const RoutineExercise(machineId: 'treadmill', machineName: 'Caminadora', sets: 1, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'leg_press', machineName: 'Prensa de Piernas', sets: 3, reps: 12, orden: 1),
          const RoutineExercise(machineId: 'chest_press', machineName: 'Press de Pecho', sets: 3, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'lat_pulldown', machineName: 'Jalón al Pecho', sets: 3, reps: 12, orden: 3),
          const RoutineExercise(machineId: 'shoulder_press', machineName: 'Press de Hombros', sets: 3, reps: 12, orden: 4),
          const RoutineExercise(machineId: 'ab_crunch', machineName: 'Máquina de Abdominales', sets: 3, reps: 15, orden: 5),
        ],
      ),
      RoutineModel(
        id: 'template_upper_hyper',
        nombre: 'Tren Superior Hipertrofia',
        descripcion: 'Enfocada en desarrollo muscular del tren superior.',
        dificultad: RoutineDifficulty.medio,
        parteDelCuerpo: RoutineBodyPart.trenSuperior,
        genero: RoutineGender.unisex,
        duracionMinutos: 60,
        esPlantilla: true,
        ejercicios: [
          const RoutineExercise(machineId: 'chest_press', machineName: 'Press de Pecho', sets: 4, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'dumbbell_bench_incline', machineName: 'Banco Inclinado', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'pec_deck', machineName: 'Pec Deck', sets: 3, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'lat_pulldown', machineName: 'Jalón al Pecho', sets: 4, reps: 10, orden: 3),
          const RoutineExercise(machineId: 'seated_row', machineName: 'Remo Sentado', sets: 4, reps: 10, orden: 4),
          const RoutineExercise(machineId: 'shoulder_press', machineName: 'Press de Hombros', sets: 4, reps: 10, orden: 5),
          const RoutineExercise(machineId: 'lateral_raise', machineName: 'Elevaciones Laterales', sets: 3, reps: 15, orden: 6),
          const RoutineExercise(machineId: 'triceps_pushdown', machineName: 'Jalón de Tríceps', sets: 3, reps: 12, orden: 7),
          const RoutineExercise(machineId: 'biceps_curl', machineName: 'Curl de Bíceps', sets: 3, reps: 12, orden: 8),
        ],
      ),
      RoutineModel(
        id: 'template_glute_leg_a',
        nombre: 'Glúteo/Pierna Día A',
        descripcion: 'Enfoque en cuádriceps y glúteos.',
        dificultad: RoutineDifficulty.medio,
        parteDelCuerpo: RoutineBodyPart.pierna,
        genero: RoutineGender.mujer,
        duracionMinutos: 60,
        esPlantilla: true,
        ejercicios: [
          const RoutineExercise(machineId: 'treadmill', machineName: 'Caminadora', sets: 1, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'squat_rack', machineName: 'Sentadillas', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'leg_press', machineName: 'Prensa de Piernas', sets: 4, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'leg_extension', machineName: 'Extensión de Piernas', sets: 3, reps: 15, orden: 3),
          const RoutineExercise(machineId: 'glute_machine', machineName: 'Máquina de Glúteos', sets: 4, reps: 12, orden: 4),
          const RoutineExercise(machineId: 'abductor_adductor', machineName: 'Abductor/Aductor', sets: 3, reps: 15, orden: 5),
          const RoutineExercise(machineId: 'calf_raise', machineName: 'Pantorrillas', sets: 4, reps: 15, orden: 6),
        ],
      ),
      RoutineModel(
        id: 'template_back_shoulder_b',
        nombre: 'Espalda/Hombro Día B',
        descripcion: 'Desarrollo de espalda y hombros.',
        dificultad: RoutineDifficulty.medio,
        parteDelCuerpo: RoutineBodyPart.espalda,
        genero: RoutineGender.unisex,
        duracionMinutos: 60,
        esPlantilla: true,
        ejercicios: [
          const RoutineExercise(machineId: 'lat_pulldown', machineName: 'Jalón al Pecho', sets: 4, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'seated_row', machineName: 'Remo Sentado', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'assisted_pullup', machineName: 'Dominadas Asistidas', sets: 3, reps: 10, orden: 2),
          const RoutineExercise(machineId: 'iso_row', machineName: 'Remo con Soporte', sets: 3, reps: 12, orden: 3),
          const RoutineExercise(machineId: 'shoulder_press', machineName: 'Press de Hombros', sets: 4, reps: 10, orden: 4),
          const RoutineExercise(machineId: 'lateral_raise', machineName: 'Elevaciones Laterales', sets: 4, reps: 15, orden: 5),
          const RoutineExercise(machineId: 'cable_crossover', machineName: 'Rear Delt en Cables', sets: 3, reps: 15, orden: 6),
        ],
      ),

      // Rutinas por nivel - Principiante
      RoutineModel(
        id: 'routine_full_body_beginner',
        nombre: 'Fuerza Cuerpo Completo',
        descripcion: 'Rutina de introducción para desarrollar fuerza general.',
        dificultad: RoutineDifficulty.principiante,
        parteDelCuerpo: RoutineBodyPart.fullBody,
        genero: RoutineGender.hombre,
        duracionMinutos: 60,
        ejercicios: [
          const RoutineExercise(machineId: 'treadmill', machineName: 'Caminadora', sets: 1, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'leg_press', machineName: 'Prensa de Piernas', sets: 4, reps: 12, orden: 1),
          const RoutineExercise(machineId: 'chest_press', machineName: 'Press de Pecho', sets: 4, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'lat_pulldown', machineName: 'Jalón al Pecho', sets: 4, reps: 12, orden: 3),
          const RoutineExercise(machineId: 'shoulder_press', machineName: 'Press de Hombros', sets: 3, reps: 12, orden: 4),
          const RoutineExercise(machineId: 'triceps_pushdown', machineName: 'Jalón de Tríceps', sets: 3, reps: 12, orden: 5),
          const RoutineExercise(machineId: 'biceps_curl', machineName: 'Curl de Bíceps', sets: 3, reps: 12, orden: 6),
          const RoutineExercise(machineId: 'ab_crunch', machineName: 'Abdominales', sets: 3, reps: 20, orden: 7),
        ],
      ),
      RoutineModel(
        id: 'routine_toning_beginner_w',
        nombre: 'Tonificación Cuerpo Completo',
        descripcion: 'Rutina de tonificación para mujeres principiantes.',
        dificultad: RoutineDifficulty.principiante,
        parteDelCuerpo: RoutineBodyPart.fullBody,
        genero: RoutineGender.mujer,
        duracionMinutos: 50,
        ejercicios: [
          const RoutineExercise(machineId: 'elliptical', machineName: 'Elíptica', sets: 1, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'leg_press', machineName: 'Prensa de Piernas', sets: 3, reps: 15, orden: 1),
          const RoutineExercise(machineId: 'glute_machine', machineName: 'Máquina de Glúteos', sets: 3, reps: 15, orden: 2),
          const RoutineExercise(machineId: 'abductor_adductor', machineName: 'Abductor/Aductor', sets: 3, reps: 15, orden: 3),
          const RoutineExercise(machineId: 'chest_press', machineName: 'Press de Pecho', sets: 3, reps: 12, orden: 4),
          const RoutineExercise(machineId: 'lat_pulldown', machineName: 'Jalón al Pecho', sets: 3, reps: 12, orden: 5),
          const RoutineExercise(machineId: 'shoulder_press', machineName: 'Press de Hombros', sets: 3, reps: 12, orden: 6),
          const RoutineExercise(machineId: 'ab_crunch', machineName: 'Abdominales', sets: 3, reps: 20, orden: 7),
        ],
      ),

      // Rutinas por nivel - Medio
      RoutineModel(
        id: 'routine_upper_power_m',
        nombre: 'Potencia Tren Superior',
        descripcion: 'Rutina de fuerza para tren superior.',
        dificultad: RoutineDifficulty.medio,
        parteDelCuerpo: RoutineBodyPart.trenSuperior,
        genero: RoutineGender.hombre,
        duracionMinutos: 55,
        ejercicios: [
          const RoutineExercise(machineId: 'chest_press', machineName: 'Press de Pecho', sets: 4, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'dumbbell_bench_flat', machineName: 'Banco Plano', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'cable_crossover', machineName: 'Cruce de Cables', sets: 3, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'lat_pulldown', machineName: 'Jalón al Pecho', sets: 4, reps: 10, orden: 3),
          const RoutineExercise(machineId: 'seated_row', machineName: 'Remo Sentado', sets: 4, reps: 10, orden: 4),
          const RoutineExercise(machineId: 'shoulder_press', machineName: 'Press de Hombros', sets: 4, reps: 10, orden: 5),
          const RoutineExercise(machineId: 'triceps_pushdown', machineName: 'Jalón de Tríceps', sets: 3, reps: 12, orden: 6),
          const RoutineExercise(machineId: 'biceps_curl', machineName: 'Curl de Bíceps', sets: 3, reps: 12, orden: 7),
        ],
      ),
      RoutineModel(
        id: 'routine_sculpt_upper_w',
        nombre: 'Esculpir Tren Superior',
        descripcion: 'Tonificación de brazos, espalda y hombros para mujeres.',
        dificultad: RoutineDifficulty.medio,
        parteDelCuerpo: RoutineBodyPart.trenSuperior,
        genero: RoutineGender.mujer,
        duracionMinutos: 45,
        ejercicios: [
          const RoutineExercise(machineId: 'chest_press', machineName: 'Press de Pecho', sets: 3, reps: 12, orden: 0),
          const RoutineExercise(machineId: 'pec_deck', machineName: 'Pec Deck', sets: 3, reps: 12, orden: 1),
          const RoutineExercise(machineId: 'lat_pulldown', machineName: 'Jalón al Pecho', sets: 3, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'seated_row', machineName: 'Remo Sentado', sets: 3, reps: 12, orden: 3),
          const RoutineExercise(machineId: 'shoulder_press', machineName: 'Press de Hombros', sets: 3, reps: 12, orden: 4),
          const RoutineExercise(machineId: 'lateral_raise', machineName: 'Elevaciones Laterales', sets: 3, reps: 15, orden: 5),
          const RoutineExercise(machineId: 'triceps_pushdown', machineName: 'Jalón de Tríceps', sets: 3, reps: 15, orden: 6),
          const RoutineExercise(machineId: 'biceps_curl', machineName: 'Curl de Bíceps', sets: 3, reps: 15, orden: 7),
        ],
      ),

      // Rutinas de pierna
      RoutineModel(
        id: 'routine_leg_focus_m',
        nombre: 'Enfoque de Pierna',
        descripcion: 'Rutina intensiva de pierna para hombres.',
        dificultad: RoutineDifficulty.medio,
        parteDelCuerpo: RoutineBodyPart.pierna,
        genero: RoutineGender.hombre,
        duracionMinutos: 50,
        ejercicios: [
          const RoutineExercise(machineId: 'squat_rack', machineName: 'Sentadillas', sets: 4, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'leg_press', machineName: 'Prensa de Piernas', sets: 4, reps: 12, orden: 1),
          const RoutineExercise(machineId: 'hack_squat', machineName: 'Hack Squat', sets: 4, reps: 10, orden: 2),
          const RoutineExercise(machineId: 'leg_extension', machineName: 'Extensión de Piernas', sets: 3, reps: 15, orden: 3),
          const RoutineExercise(machineId: 'leg_curl', machineName: 'Curl de Piernas', sets: 3, reps: 15, orden: 4),
          const RoutineExercise(machineId: 'calf_raise', machineName: 'Pantorrillas', sets: 4, reps: 15, orden: 5),
          const RoutineExercise(machineId: 'ab_crunch', machineName: 'Abdominales', sets: 3, reps: 20, orden: 6),
        ],
      ),
      RoutineModel(
        id: 'routine_leg_toning_w',
        nombre: 'Tonificación de Pierna',
        descripcion: 'Rutina de tonificación de pierna y glúteos para mujeres.',
        dificultad: RoutineDifficulty.medio,
        parteDelCuerpo: RoutineBodyPart.pierna,
        genero: RoutineGender.mujer,
        duracionMinutos: 45,
        ejercicios: [
          const RoutineExercise(machineId: 'elliptical', machineName: 'Elíptica', sets: 1, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'leg_press', machineName: 'Prensa de Piernas', sets: 4, reps: 12, orden: 1),
          const RoutineExercise(machineId: 'glute_machine', machineName: 'Máquina de Glúteos', sets: 4, reps: 15, orden: 2),
          const RoutineExercise(machineId: 'leg_extension', machineName: 'Extensión de Piernas', sets: 3, reps: 15, orden: 3),
          const RoutineExercise(machineId: 'leg_curl', machineName: 'Curl de Piernas', sets: 3, reps: 15, orden: 4),
          const RoutineExercise(machineId: 'abductor_adductor', machineName: 'Abductor/Aductor', sets: 3, reps: 15, orden: 5),
          const RoutineExercise(machineId: 'calf_raise', machineName: 'Pantorrillas', sets: 3, reps: 15, orden: 6),
        ],
      ),

      // Rutinas avanzadas
      RoutineModel(
        id: 'routine_push_day',
        nombre: 'Push Day',
        descripcion: 'Día de empuje: pecho, hombros y tríceps.',
        dificultad: RoutineDifficulty.avanzado,
        parteDelCuerpo: RoutineBodyPart.trenSuperior,
        genero: RoutineGender.unisex,
        duracionMinutos: 50,
        ejercicios: [
          const RoutineExercise(machineId: 'dumbbell_bench_flat', machineName: 'Banco Plano', sets: 4, reps: 8, orden: 0),
          const RoutineExercise(machineId: 'dumbbell_bench_incline', machineName: 'Banco Inclinado', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'cable_crossover', machineName: 'Cruce de Cables', sets: 3, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'shoulder_press', machineName: 'Press de Hombros', sets: 4, reps: 10, orden: 3),
          const RoutineExercise(machineId: 'lateral_raise', machineName: 'Elevaciones Laterales', sets: 4, reps: 12, orden: 4),
          const RoutineExercise(machineId: 'triceps_pushdown', machineName: 'Jalón de Tríceps', sets: 4, reps: 12, orden: 5),
          const RoutineExercise(machineId: 'pec_deck', machineName: 'Pec Deck', sets: 3, reps: 12, orden: 6),
          const RoutineExercise(machineId: 'ab_crunch', machineName: 'Abdominales', sets: 3, reps: 20, orden: 7),
        ],
      ),
      RoutineModel(
        id: 'routine_pull_day',
        nombre: 'Pull Day',
        descripcion: 'Día de jalón: espalda y bíceps.',
        dificultad: RoutineDifficulty.avanzado,
        parteDelCuerpo: RoutineBodyPart.trenSuperior,
        genero: RoutineGender.unisex,
        duracionMinutos: 55,
        ejercicios: [
          const RoutineExercise(machineId: 'barbell_rack', machineName: 'Peso Muerto', sets: 4, reps: 6, orden: 0),
          const RoutineExercise(machineId: 'lat_pulldown', machineName: 'Jalón al Pecho', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'seated_row', machineName: 'Remo Sentado', sets: 4, reps: 10, orden: 2),
          const RoutineExercise(machineId: 'assisted_pullup', machineName: 'Dominadas', sets: 3, reps: 10, orden: 3),
          const RoutineExercise(machineId: 'iso_row', machineName: 'Remo con Soporte', sets: 3, reps: 12, orden: 4),
          const RoutineExercise(machineId: 'biceps_curl', machineName: 'Curl de Bíceps', sets: 4, reps: 10, orden: 5),
          const RoutineExercise(machineId: 'cable_crossover', machineName: 'Curl en Cable', sets: 3, reps: 12, orden: 6),
          const RoutineExercise(machineId: 'ab_crunch', machineName: 'Abdominales', sets: 3, reps: 20, orden: 7),
        ],
      ),

      // HIIT
      RoutineModel(
        id: 'routine_cardio_hiit',
        nombre: 'Cardio HIIT',
        descripcion: 'Entrenamiento de alta intensidad con intervalos.',
        dificultad: RoutineDifficulty.avanzado,
        parteDelCuerpo: RoutineBodyPart.fullBody,
        genero: RoutineGender.unisex,
        duracionMinutos: 30,
        ejercicios: [
          const RoutineExercise(machineId: 'treadmill', machineName: 'Caminadora Sprint', sets: 5, reps: 1, notas: '30 seg sprint, 30 seg descanso', orden: 0),
          const RoutineExercise(machineId: 'battle_ropes', machineName: 'Cuerdas de Batalla', sets: 4, reps: 30, orden: 1),
          const RoutineExercise(machineId: 'plyo_box', machineName: 'Box Jumps', sets: 4, reps: 10, orden: 2),
          const RoutineExercise(machineId: 'rowing_machine', machineName: 'Remo', sets: 4, reps: 1, notas: '250m sprints', orden: 3),
          const RoutineExercise(machineId: 'kettlebell_station', machineName: 'Kettlebell Swings', sets: 4, reps: 15, orden: 4),
          const RoutineExercise(machineId: 'step_stepper', machineName: 'Escaladora', sets: 3, reps: 1, notas: '2 min intenso', orden: 5),
        ],
      ),

      // Rutina Experto
      RoutineModel(
        id: 'routine_expert_strength',
        nombre: 'Fuerza Máxima',
        descripcion: 'Rutina de fuerza avanzada con ejercicios compuestos.',
        dificultad: RoutineDifficulty.experto,
        parteDelCuerpo: RoutineBodyPart.fullBody,
        genero: RoutineGender.hombre,
        duracionMinutos: 75,
        ejercicios: [
          const RoutineExercise(machineId: 'squat_rack', machineName: 'Sentadillas', sets: 5, reps: 5, orden: 0),
          const RoutineExercise(machineId: 'barbell_rack', machineName: 'Peso Muerto', sets: 5, reps: 5, orden: 1),
          const RoutineExercise(machineId: 'dumbbell_bench_flat', machineName: 'Press Banca', sets: 5, reps: 5, orden: 2),
          const RoutineExercise(machineId: 'assisted_pullup', machineName: 'Dominadas', sets: 4, reps: 8, orden: 3),
          const RoutineExercise(machineId: 'shoulder_press', machineName: 'Press Militar', sets: 4, reps: 6, orden: 4),
          const RoutineExercise(machineId: 'seated_row', machineName: 'Remo con Barra', sets: 4, reps: 8, orden: 5),
          const RoutineExercise(machineId: 'leg_press', machineName: 'Prensa de Piernas', sets: 4, reps: 10, orden: 6),
          const RoutineExercise(machineId: 'ab_crunch', machineName: 'Core', sets: 3, reps: 20, orden: 7),
        ],
      ),

      // ========== RUTINAS DE PECHO ==========
      RoutineModel(
        id: 'routine_chest_beginner',
        nombre: 'Pecho Principiante',
        descripcion: 'Rutina básica para desarrollo del pecho.',
        dificultad: RoutineDifficulty.principiante,
        parteDelCuerpo: RoutineBodyPart.pecho,
        genero: RoutineGender.unisex,
        duracionMinutos: 35,
        ejercicios: [
          const RoutineExercise(machineId: 'chest_press', machineName: 'Press de Pecho', sets: 4, reps: 12, orden: 0),
          const RoutineExercise(machineId: 'pec_deck', machineName: 'Pec Deck', sets: 3, reps: 12, orden: 1),
          const RoutineExercise(machineId: 'seated_chest_press', machineName: 'Press de Pecho Sentado', sets: 3, reps: 12, orden: 2),
        ],
      ),
      RoutineModel(
        id: 'routine_chest_intermediate',
        nombre: 'Pecho Intermedio',
        descripcion: 'Rutina completa de pecho con variedad de ángulos.',
        dificultad: RoutineDifficulty.medio,
        parteDelCuerpo: RoutineBodyPart.pecho,
        genero: RoutineGender.unisex,
        duracionMinutos: 45,
        ejercicios: [
          const RoutineExercise(machineId: 'dumbbell_bench_flat', machineName: 'Banco Plano', sets: 4, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'dumbbell_bench_incline', machineName: 'Banco Inclinado', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'cable_crossover', machineName: 'Cruce de Cables', sets: 3, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'pec_deck', machineName: 'Pec Deck', sets: 3, reps: 12, orden: 3),
          const RoutineExercise(machineId: 'chest_press', machineName: 'Press de Pecho', sets: 3, reps: 12, orden: 4),
        ],
      ),
      RoutineModel(
        id: 'routine_chest_advanced',
        nombre: 'Pecho Avanzado',
        descripcion: 'Rutina intensa de pecho para máximo desarrollo.',
        dificultad: RoutineDifficulty.avanzado,
        parteDelCuerpo: RoutineBodyPart.pecho,
        genero: RoutineGender.hombre,
        duracionMinutos: 55,
        ejercicios: [
          const RoutineExercise(machineId: 'dumbbell_bench_flat', machineName: 'Banco Plano', sets: 5, reps: 8, orden: 0),
          const RoutineExercise(machineId: 'dumbbell_bench_incline', machineName: 'Banco Inclinado', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'cable_crossover', machineName: 'Cruce de Cables', sets: 4, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'pec_deck', machineName: 'Pec Deck', sets: 4, reps: 12, orden: 3),
          const RoutineExercise(machineId: 'chest_press', machineName: 'Press de Pecho', sets: 3, reps: 15, orden: 4),
        ],
      ),

      // ========== RUTINAS DE ESPALDA ==========
      RoutineModel(
        id: 'routine_back_beginner',
        nombre: 'Espalda Principiante',
        descripcion: 'Rutina básica para desarrollo de espalda.',
        dificultad: RoutineDifficulty.principiante,
        parteDelCuerpo: RoutineBodyPart.espalda,
        genero: RoutineGender.unisex,
        duracionMinutos: 35,
        ejercicios: [
          const RoutineExercise(machineId: 'lat_pulldown', machineName: 'Jalón al Pecho', sets: 4, reps: 12, orden: 0),
          const RoutineExercise(machineId: 'seated_row', machineName: 'Remo Sentado', sets: 4, reps: 12, orden: 1),
          const RoutineExercise(machineId: 'assisted_pullup', machineName: 'Dominadas Asistidas', sets: 3, reps: 10, orden: 2),
        ],
      ),
      RoutineModel(
        id: 'routine_back_intermediate',
        nombre: 'Espalda Intermedio',
        descripcion: 'Rutina completa de espalda con múltiples ángulos.',
        dificultad: RoutineDifficulty.medio,
        parteDelCuerpo: RoutineBodyPart.espalda,
        genero: RoutineGender.unisex,
        duracionMinutos: 50,
        ejercicios: [
          const RoutineExercise(machineId: 'lat_pulldown', machineName: 'Jalón al Pecho', sets: 4, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'seated_row', machineName: 'Remo Sentado', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'iso_row', machineName: 'Remo con Soporte', sets: 3, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'assisted_pullup', machineName: 'Dominadas Asistidas', sets: 3, reps: 10, orden: 3),
          const RoutineExercise(machineId: 'rowing_machine', machineName: 'Máquina de Remo', sets: 3, reps: 15, orden: 4),
        ],
      ),
      RoutineModel(
        id: 'routine_back_advanced',
        nombre: 'Espalda Avanzado',
        descripcion: 'Rutina intensa para máximo desarrollo de espalda.',
        dificultad: RoutineDifficulty.avanzado,
        parteDelCuerpo: RoutineBodyPart.espalda,
        genero: RoutineGender.hombre,
        duracionMinutos: 55,
        ejercicios: [
          const RoutineExercise(machineId: 'barbell_rack', machineName: 'Peso Muerto', sets: 4, reps: 6, orden: 0),
          const RoutineExercise(machineId: 'lat_pulldown', machineName: 'Jalón al Pecho', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'seated_row', machineName: 'Remo Sentado', sets: 4, reps: 10, orden: 2),
          const RoutineExercise(machineId: 'iso_row', machineName: 'Remo con Soporte', sets: 4, reps: 10, orden: 3),
          const RoutineExercise(machineId: 'assisted_pullup', machineName: 'Dominadas', sets: 4, reps: 10, orden: 4),
        ],
      ),

      // ========== RUTINAS DE HOMBRO ==========
      RoutineModel(
        id: 'routine_shoulder_beginner',
        nombre: 'Hombro Principiante',
        descripcion: 'Rutina básica para desarrollo de hombros.',
        dificultad: RoutineDifficulty.principiante,
        parteDelCuerpo: RoutineBodyPart.hombro,
        genero: RoutineGender.unisex,
        duracionMinutos: 30,
        ejercicios: [
          const RoutineExercise(machineId: 'shoulder_press', machineName: 'Press de Hombros', sets: 4, reps: 12, orden: 0),
          const RoutineExercise(machineId: 'lateral_raise', machineName: 'Elevaciones Laterales', sets: 3, reps: 15, orden: 1),
        ],
      ),
      RoutineModel(
        id: 'routine_shoulder_intermediate',
        nombre: 'Hombro Intermedio',
        descripcion: 'Rutina completa de hombros con todas las cabezas.',
        dificultad: RoutineDifficulty.medio,
        parteDelCuerpo: RoutineBodyPart.hombro,
        genero: RoutineGender.unisex,
        duracionMinutos: 40,
        ejercicios: [
          const RoutineExercise(machineId: 'shoulder_press', machineName: 'Press de Hombros', sets: 4, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'lateral_raise', machineName: 'Elevaciones Laterales', sets: 4, reps: 12, orden: 1),
          const RoutineExercise(machineId: 'cable_crossover', machineName: 'Elevación Frontal en Cable', sets: 3, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'pec_deck', machineName: 'Rear Delt en Pec Deck', sets: 3, reps: 15, orden: 3),
        ],
      ),
      RoutineModel(
        id: 'routine_shoulder_advanced',
        nombre: 'Hombro Avanzado',
        descripcion: 'Rutina intensa para hombros 3D.',
        dificultad: RoutineDifficulty.avanzado,
        parteDelCuerpo: RoutineBodyPart.hombro,
        genero: RoutineGender.hombre,
        duracionMinutos: 50,
        ejercicios: [
          const RoutineExercise(machineId: 'shoulder_press', machineName: 'Press Militar', sets: 5, reps: 8, orden: 0),
          const RoutineExercise(machineId: 'lateral_raise', machineName: 'Elevaciones Laterales', sets: 4, reps: 12, orden: 1),
          const RoutineExercise(machineId: 'cable_crossover', machineName: 'Elevación Frontal en Cable', sets: 4, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'pec_deck', machineName: 'Rear Delt', sets: 4, reps: 15, orden: 3),
          const RoutineExercise(machineId: 'multi_gym', machineName: 'Face Pulls', sets: 3, reps: 15, orden: 4),
        ],
      ),

      // ========== RUTINAS DE BRAZO ==========
      RoutineModel(
        id: 'routine_arms_beginner',
        nombre: 'Brazos Principiante',
        descripcion: 'Rutina básica para bíceps y tríceps.',
        dificultad: RoutineDifficulty.principiante,
        parteDelCuerpo: RoutineBodyPart.brazo,
        genero: RoutineGender.unisex,
        duracionMinutos: 30,
        ejercicios: [
          const RoutineExercise(machineId: 'biceps_curl', machineName: 'Curl de Bíceps', sets: 3, reps: 12, orden: 0),
          const RoutineExercise(machineId: 'triceps_pushdown', machineName: 'Jalón de Tríceps', sets: 3, reps: 12, orden: 1),
        ],
      ),
      RoutineModel(
        id: 'routine_arms_intermediate',
        nombre: 'Brazos Intermedio',
        descripcion: 'Rutina completa de brazos con variedad de ejercicios.',
        dificultad: RoutineDifficulty.medio,
        parteDelCuerpo: RoutineBodyPart.brazo,
        genero: RoutineGender.unisex,
        duracionMinutos: 40,
        ejercicios: [
          const RoutineExercise(machineId: 'biceps_curl', machineName: 'Curl de Bíceps', sets: 4, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'triceps_pushdown', machineName: 'Jalón de Tríceps', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'cable_crossover', machineName: 'Curl en Cable', sets: 3, reps: 12, orden: 2),
          const RoutineExercise(machineId: 'multi_gym', machineName: 'Extensión de Tríceps', sets: 3, reps: 12, orden: 3),
        ],
      ),
      RoutineModel(
        id: 'routine_arms_advanced',
        nombre: 'Brazos Avanzado',
        descripcion: 'Rutina intensa para máximo desarrollo de brazos.',
        dificultad: RoutineDifficulty.avanzado,
        parteDelCuerpo: RoutineBodyPart.brazo,
        genero: RoutineGender.hombre,
        duracionMinutos: 50,
        ejercicios: [
          const RoutineExercise(machineId: 'biceps_curl', machineName: 'Curl de Bíceps', sets: 4, reps: 10, orden: 0),
          const RoutineExercise(machineId: 'triceps_pushdown', machineName: 'Jalón de Tríceps', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'cable_crossover', machineName: 'Curl Martillo en Cable', sets: 4, reps: 10, orden: 2),
          const RoutineExercise(machineId: 'multi_gym', machineName: 'Extensión de Tríceps', sets: 4, reps: 10, orden: 3),
          const RoutineExercise(machineId: 'cable_crossover', machineName: 'Curl 21s', sets: 3, reps: 21, orden: 4),
          const RoutineExercise(machineId: 'multi_gym', machineName: 'Fondos en Cable', sets: 3, reps: 12, orden: 5),
        ],
      ),

      // ========== RUTINAS ADICIONALES DE PIERNA ==========
      RoutineModel(
        id: 'routine_leg_beginner',
        nombre: 'Pierna Principiante',
        descripcion: 'Rutina básica para desarrollo de piernas.',
        dificultad: RoutineDifficulty.principiante,
        parteDelCuerpo: RoutineBodyPart.pierna,
        genero: RoutineGender.unisex,
        duracionMinutos: 35,
        ejercicios: [
          const RoutineExercise(machineId: 'leg_press', machineName: 'Prensa de Piernas', sets: 4, reps: 12, orden: 0),
          const RoutineExercise(machineId: 'leg_extension', machineName: 'Extensión de Piernas', sets: 3, reps: 15, orden: 1),
          const RoutineExercise(machineId: 'leg_curl', machineName: 'Curl de Piernas', sets: 3, reps: 15, orden: 2),
          const RoutineExercise(machineId: 'calf_raise', machineName: 'Pantorrillas', sets: 3, reps: 15, orden: 3),
        ],
      ),
      RoutineModel(
        id: 'routine_leg_advanced',
        nombre: 'Pierna Avanzado',
        descripcion: 'Rutina intensa para máximo desarrollo de piernas.',
        dificultad: RoutineDifficulty.avanzado,
        parteDelCuerpo: RoutineBodyPart.pierna,
        genero: RoutineGender.unisex,
        duracionMinutos: 60,
        ejercicios: [
          const RoutineExercise(machineId: 'squat_rack', machineName: 'Sentadillas', sets: 5, reps: 8, orden: 0),
          const RoutineExercise(machineId: 'leg_press', machineName: 'Prensa de Piernas', sets: 4, reps: 10, orden: 1),
          const RoutineExercise(machineId: 'hack_squat', machineName: 'Hack Squat', sets: 4, reps: 10, orden: 2),
          const RoutineExercise(machineId: 'leg_extension', machineName: 'Extensión de Piernas', sets: 4, reps: 12, orden: 3),
          const RoutineExercise(machineId: 'leg_curl', machineName: 'Curl de Piernas', sets: 4, reps: 12, orden: 4),
          const RoutineExercise(machineId: 'calf_raise', machineName: 'Pantorrillas', sets: 5, reps: 15, orden: 5),
        ],
      ),
    ];
  }
}
