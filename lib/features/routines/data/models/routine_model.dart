import 'machine_model.dart';

/// Model representing a workout routine
class RoutineModel {
  final String id;
  final String name;
  final String description;
  final List<RoutineExercise> exercises;
  final RoutineGender gender;
  final String duration;
  final String? imageUrl;

  const RoutineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.gender,
    required this.duration,
    this.imageUrl,
  });

  int get exerciseCount => exercises.length;
}

/// Exercise within a routine with custom sets/reps
class RoutineExercise {
  final MachineModel machine;
  final int sets;
  final int reps;
  final String? notes;

  const RoutineExercise({
    required this.machine,
    required this.sets,
    required this.reps,
    this.notes,
  });
}

/// Gender filter for routines
enum RoutineGender {
  men,
  women,
  unisex,
}

extension RoutineGenderExtension on RoutineGender {
  String get displayName {
    switch (this) {
      case RoutineGender.men:
        return 'Hombres';
      case RoutineGender.women:
        return 'Mujeres';
      case RoutineGender.unisex:
        return 'Unisex';
    }
  }
}
