import 'models/routine_model.dart';
import 'machines_data.dart';

/// Sample routines data
class RoutinesData {
  RoutinesData._();

  static List<RoutineModel> get allRoutines => [
        _fullBodyMen,
        _fullBodyWomen,
        _upperBodyMen,
        _upperBodyWomen,
        _legDayMen,
        _legDayWomen,
        _pushDay,
        _pullDay,
        _cardioHiit,
      ];

  static List<RoutineModel> getByGender(RoutineGender gender) {
    if (gender == RoutineGender.unisex) return allRoutines;
    return allRoutines
        .where((r) => r.gender == gender || r.gender == RoutineGender.unisex)
        .toList();
  }

  static RoutineModel? getById(String id) {
    try {
      return allRoutines.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // ============ ROUTINES ============

  static final _fullBodyMen = RoutineModel(
    id: 'full_body_men',
    name: 'Fuerza Cuerpo Completo',
    description: 'Entrenamiento completo de cuerpo entero para todos los grupos musculares principales para hombres.',
    gender: RoutineGender.men,
    duration: '60 min',
    imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
    exercises: [
      RoutineExercise(machine: MachinesData.allMachines[6], sets: 4, reps: 10), // Squat Rack
      RoutineExercise(machine: MachinesData.allMachines[5], sets: 4, reps: 10), // Leg Press
      RoutineExercise(machine: MachinesData.allMachines[13], sets: 4, reps: 12), // Chest Press
      RoutineExercise(machine: MachinesData.allMachines[18], sets: 4, reps: 12), // Lat Pulldown
      RoutineExercise(machine: MachinesData.allMachines[23], sets: 4, reps: 12), // Shoulder Press
      RoutineExercise(machine: MachinesData.allMachines[25], sets: 3, reps: 12), // Triceps
      RoutineExercise(machine: MachinesData.allMachines[26], sets: 3, reps: 12), // Biceps
      RoutineExercise(machine: MachinesData.allMachines[27], sets: 3, reps: 20), // Ab Crunch
    ],
  );

  static final _fullBodyWomen = RoutineModel(
    id: 'full_body_women',
    name: 'Tonificación Cuerpo Completo',
    description: 'Rutina equilibrada de cuerpo completo para tonificación y fuerza para mujeres.',
    gender: RoutineGender.women,
    duration: '50 min',
    imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&q=80',
    exercises: [
      RoutineExercise(machine: MachinesData.allMachines[5], sets: 3, reps: 15), // Leg Press
      RoutineExercise(machine: MachinesData.allMachines[28], sets: 3, reps: 15), // Glute Machine
      RoutineExercise(machine: MachinesData.allMachines[11], sets: 3, reps: 15), // Abductor
      RoutineExercise(machine: MachinesData.allMachines[13], sets: 3, reps: 12), // Chest Press
      RoutineExercise(machine: MachinesData.allMachines[18], sets: 3, reps: 12), // Lat Pulldown
      RoutineExercise(machine: MachinesData.allMachines[24], sets: 3, reps: 15), // Lateral Raise
      RoutineExercise(machine: MachinesData.allMachines[27], sets: 3, reps: 20), // Ab Crunch
      RoutineExercise(machine: MachinesData.allMachines[1], sets: 1, reps: 15), // Bike
    ],
  );

  static final _upperBodyMen = RoutineModel(
    id: 'upper_body_men',
    name: 'Potencia Tren Superior',
    description: 'Entrenamiento intenso de tren superior para desarrollar pecho, espalda y brazos.',
    gender: RoutineGender.men,
    duration: '55 min',
    imageUrl: 'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=800&q=80',
    exercises: [
      RoutineExercise(machine: MachinesData.allMachines[17], sets: 4, reps: 10), // Flat Bench
      RoutineExercise(machine: MachinesData.allMachines[16], sets: 4, reps: 10), // Incline Bench
      RoutineExercise(machine: MachinesData.allMachines[15], sets: 4, reps: 12), // Cable Crossover
      RoutineExercise(machine: MachinesData.allMachines[18], sets: 4, reps: 10), // Lat Pulldown
      RoutineExercise(machine: MachinesData.allMachines[19], sets: 4, reps: 12), // Seated Row
      RoutineExercise(machine: MachinesData.allMachines[23], sets: 4, reps: 10), // Shoulder Press
      RoutineExercise(machine: MachinesData.allMachines[25], sets: 3, reps: 12), // Triceps
      RoutineExercise(machine: MachinesData.allMachines[26], sets: 3, reps: 12), // Biceps
    ],
  );

  static final _upperBodyWomen = RoutineModel(
    id: 'upper_body_women',
    name: 'Esculpir Tren Superior',
    description: 'Entrenamiento de tonificación para brazos, hombros, pecho y espalda.',
    gender: RoutineGender.women,
    duration: '45 min',
    imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&q=80',
    exercises: [
      RoutineExercise(machine: MachinesData.allMachines[13], sets: 3, reps: 15), // Chest Press
      RoutineExercise(machine: MachinesData.allMachines[14], sets: 3, reps: 15), // Pec Deck
      RoutineExercise(machine: MachinesData.allMachines[18], sets: 3, reps: 12), // Lat Pulldown
      RoutineExercise(machine: MachinesData.allMachines[20], sets: 3, reps: 10), // Assisted Pullup
      RoutineExercise(machine: MachinesData.allMachines[23], sets: 3, reps: 15), // Shoulder Press
      RoutineExercise(machine: MachinesData.allMachines[24], sets: 3, reps: 15), // Lateral Raise
      RoutineExercise(machine: MachinesData.allMachines[25], sets: 3, reps: 15), // Triceps
    ],
  );

  static final _legDayMen = RoutineModel(
    id: 'leg_day_men',
    name: 'Destructor de Piernas',
    description: 'Entrenamiento pesado de piernas para desarrollar cuádriceps, isquiotibiales y glúteos.',
    gender: RoutineGender.men,
    duration: '60 min',
    imageUrl: 'https://images.unsplash.com/photo-1434682772747-f16d3ea162c3?w=800&q=80',
    exercises: [
      RoutineExercise(machine: MachinesData.allMachines[6], sets: 5, reps: 8), // Squat Rack
      RoutineExercise(machine: MachinesData.allMachines[5], sets: 4, reps: 12), // Leg Press
      RoutineExercise(machine: MachinesData.allMachines[7], sets: 4, reps: 10), // Hack Squat
      RoutineExercise(machine: MachinesData.allMachines[8], sets: 3, reps: 15), // Leg Extension
      RoutineExercise(machine: MachinesData.allMachines[9], sets: 3, reps: 15), // Leg Curl
      RoutineExercise(machine: MachinesData.allMachines[10], sets: 4, reps: 15), // Calf Raise
    ],
  );

  static final _legDayWomen = RoutineModel(
    id: 'leg_day_women',
    name: 'Enfoque Glúteos y Piernas',
    description: 'Entrenamiento de tren inferior enfocado en glúteos, muslos y piernas.',
    gender: RoutineGender.women,
    duration: '50 min',
    imageUrl: 'https://images.unsplash.com/photo-1550345332-09e3ac987658?w=800&q=80',
    exercises: [
      RoutineExercise(machine: MachinesData.allMachines[28], sets: 4, reps: 15), // Glute Machine
      RoutineExercise(machine: MachinesData.allMachines[5], sets: 4, reps: 15), // Leg Press
      RoutineExercise(machine: MachinesData.allMachines[11], sets: 3, reps: 20), // Abductor
      RoutineExercise(machine: MachinesData.allMachines[8], sets: 3, reps: 15), // Leg Extension
      RoutineExercise(machine: MachinesData.allMachines[9], sets: 3, reps: 15), // Leg Curl
      RoutineExercise(machine: MachinesData.allMachines[10], sets: 3, reps: 20), // Calf Raise
      RoutineExercise(machine: MachinesData.allMachines[4], sets: 1, reps: 15), // Stepper
    ],
  );

  static final _pushDay = RoutineModel(
    id: 'push_day',
    name: 'Día de Empuje',
    description: 'Entrenamiento clásico de empuje: pecho, hombros y tríceps.',
    gender: RoutineGender.unisex,
    duration: '50 min',
    imageUrl: 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&q=80',
    exercises: [
      RoutineExercise(machine: MachinesData.allMachines[17], sets: 4, reps: 10), // Flat Bench
      RoutineExercise(machine: MachinesData.allMachines[16], sets: 3, reps: 12), // Incline Bench
      RoutineExercise(machine: MachinesData.allMachines[14], sets: 3, reps: 12), // Pec Deck
      RoutineExercise(machine: MachinesData.allMachines[23], sets: 4, reps: 10), // Shoulder Press
      RoutineExercise(machine: MachinesData.allMachines[24], sets: 3, reps: 15), // Lateral Raise
      RoutineExercise(machine: MachinesData.allMachines[25], sets: 4, reps: 12), // Triceps
    ],
  );

  static final _pullDay = RoutineModel(
    id: 'pull_day',
    name: 'Día de Jalón',
    description: 'Entrenamiento clásico de jalón: enfoque en espalda y bíceps.',
    gender: RoutineGender.unisex,
    duration: '50 min',
    imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&q=80',
    exercises: [
      RoutineExercise(machine: MachinesData.allMachines[18], sets: 4, reps: 10), // Lat Pulldown
      RoutineExercise(machine: MachinesData.allMachines[19], sets: 4, reps: 12), // Seated Row
      RoutineExercise(machine: MachinesData.allMachines[20], sets: 3, reps: 10), // Assisted Pullup
      RoutineExercise(machine: MachinesData.allMachines[21], sets: 3, reps: 12), // Iso Row
      RoutineExercise(machine: MachinesData.allMachines[26], sets: 4, reps: 12), // Biceps
    ],
  );

  static final _cardioHiit = RoutineModel(
    id: 'cardio_hiit',
    name: 'Cardio HIIT Explosivo',
    description: 'Circuito de cardio de alta intensidad para máxima quema de grasa.',
    gender: RoutineGender.unisex,
    duration: '30 min',
    imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&q=80',
    exercises: [
      RoutineExercise(machine: MachinesData.allMachines[0], sets: 1, reps: 10, notes: '10 min calentamiento'), // Treadmill
      RoutineExercise(machine: MachinesData.allMachines[3], sets: 3, reps: 2, notes: 'intervalos de 2 min'), // Rowing
      RoutineExercise(machine: MachinesData.allMachines[29], sets: 3, reps: 30), // Battle Ropes
      RoutineExercise(machine: MachinesData.allMachines[34], sets: 3, reps: 15), // Plyo Box
      RoutineExercise(machine: MachinesData.allMachines[1], sets: 1, reps: 5, notes: '5 min enfriamiento'), // Bike
    ],
  );
}
