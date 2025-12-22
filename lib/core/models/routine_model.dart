import 'package:cloud_firestore/cloud_firestore.dart';

/// Nivel de dificultad de rutina
enum RoutineDifficulty {
  principiante,
  medio,
  avanzado,
  experto,
}

extension RoutineDifficultyExtension on RoutineDifficulty {
  String get displayName {
    switch (this) {
      case RoutineDifficulty.principiante:
        return 'Principiante';
      case RoutineDifficulty.medio:
        return 'Medio';
      case RoutineDifficulty.avanzado:
        return 'Avanzado';
      case RoutineDifficulty.experto:
        return 'Experto';
    }
  }

  String get value {
    switch (this) {
      case RoutineDifficulty.principiante:
        return 'principiante';
      case RoutineDifficulty.medio:
        return 'medio';
      case RoutineDifficulty.avanzado:
        return 'avanzado';
      case RoutineDifficulty.experto:
        return 'experto';
    }
  }

  int get order {
    switch (this) {
      case RoutineDifficulty.principiante:
        return 0;
      case RoutineDifficulty.medio:
        return 1;
      case RoutineDifficulty.avanzado:
        return 2;
      case RoutineDifficulty.experto:
        return 3;
    }
  }

  static RoutineDifficulty fromString(String value) {
    switch (value.toLowerCase()) {
      case 'principiante':
        return RoutineDifficulty.principiante;
      case 'medio':
        return RoutineDifficulty.medio;
      case 'avanzado':
        return RoutineDifficulty.avanzado;
      case 'experto':
        return RoutineDifficulty.experto;
      default:
        return RoutineDifficulty.principiante;
    }
  }
}

/// Parte del cuerpo objetivo de la rutina
enum RoutineBodyPart {
  pierna,
  pecho,
  espalda,
  hombro,
  brazo,
  mixto,
  fullBody,
  trenSuperior,
  trenInferior,
}

extension RoutineBodyPartExtension on RoutineBodyPart {
  String get displayName {
    switch (this) {
      case RoutineBodyPart.pierna:
        return 'Pierna';
      case RoutineBodyPart.pecho:
        return 'Pecho';
      case RoutineBodyPart.espalda:
        return 'Espalda';
      case RoutineBodyPart.hombro:
        return 'Hombro';
      case RoutineBodyPart.brazo:
        return 'Brazo';
      case RoutineBodyPart.mixto:
        return 'Mixto';
      case RoutineBodyPart.fullBody:
        return 'Full Body';
      case RoutineBodyPart.trenSuperior:
        return 'Tren Superior';
      case RoutineBodyPart.trenInferior:
        return 'Tren Inferior';
    }
  }

  String get value {
    switch (this) {
      case RoutineBodyPart.pierna:
        return 'pierna';
      case RoutineBodyPart.pecho:
        return 'pecho';
      case RoutineBodyPart.espalda:
        return 'espalda';
      case RoutineBodyPart.hombro:
        return 'hombro';
      case RoutineBodyPart.brazo:
        return 'brazo';
      case RoutineBodyPart.mixto:
        return 'mixto';
      case RoutineBodyPart.fullBody:
        return 'full_body';
      case RoutineBodyPart.trenSuperior:
        return 'tren_superior';
      case RoutineBodyPart.trenInferior:
        return 'tren_inferior';
    }
  }

  static RoutineBodyPart fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pierna':
        return RoutineBodyPart.pierna;
      case 'pecho':
        return RoutineBodyPart.pecho;
      case 'espalda':
        return RoutineBodyPart.espalda;
      case 'hombro':
        return RoutineBodyPart.hombro;
      case 'brazo':
        return RoutineBodyPart.brazo;
      case 'mixto':
        return RoutineBodyPart.mixto;
      case 'full_body':
        return RoutineBodyPart.fullBody;
      case 'tren_superior':
        return RoutineBodyPart.trenSuperior;
      case 'tren_inferior':
        return RoutineBodyPart.trenInferior;
      default:
        return RoutineBodyPart.mixto;
    }
  }
}

/// Género objetivo de la rutina
enum RoutineGender {
  hombre,
  mujer,
  unisex,
}

extension RoutineGenderExtension on RoutineGender {
  String get displayName {
    switch (this) {
      case RoutineGender.hombre:
        return 'Hombre';
      case RoutineGender.mujer:
        return 'Mujer';
      case RoutineGender.unisex:
        return 'Unisex';
    }
  }

  String get value {
    switch (this) {
      case RoutineGender.hombre:
        return 'hombre';
      case RoutineGender.mujer:
        return 'mujer';
      case RoutineGender.unisex:
        return 'unisex';
    }
  }

  static RoutineGender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'hombre':
      case 'men':
        return RoutineGender.hombre;
      case 'mujer':
      case 'women':
        return RoutineGender.mujer;
      case 'unisex':
        return RoutineGender.unisex;
      default:
        return RoutineGender.unisex;
    }
  }
}

/// Ejercicio dentro de una rutina
class RoutineExercise {
  final String machineId;
  final String machineName;
  final String? machineImageUrl;
  final int sets;
  final int reps;
  final String? notas;
  final int orden;

  const RoutineExercise({
    required this.machineId,
    required this.machineName,
    this.machineImageUrl,
    this.sets = 3,
    this.reps = 12,
    this.notas,
    this.orden = 0,
  });

  factory RoutineExercise.fromMap(Map<String, dynamic> data) {
    return RoutineExercise(
      machineId: data['machineId'] ?? '',
      machineName: data['machineName'] ?? '',
      machineImageUrl: data['machineImageUrl'],
      sets: data['sets'] ?? 3,
      reps: data['reps'] ?? 12,
      notas: data['notas'],
      orden: data['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'machineId': machineId,
      'machineName': machineName,
      'machineImageUrl': machineImageUrl,
      'sets': sets,
      'reps': reps,
      'notas': notas,
      'orden': orden,
    };
  }

  RoutineExercise copyWith({
    String? machineId,
    String? machineName,
    String? machineImageUrl,
    int? sets,
    int? reps,
    String? notas,
    int? orden,
  }) {
    return RoutineExercise(
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      machineImageUrl: machineImageUrl ?? this.machineImageUrl,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      notas: notas ?? this.notas,
      orden: orden ?? this.orden,
    );
  }
}

/// Set de ejercicios (grupo de 3-4 máquinas)
class ExerciseSet {
  final String nombre;
  final List<RoutineExercise> ejercicios;
  final int orden;

  const ExerciseSet({
    required this.nombre,
    required this.ejercicios,
    this.orden = 0,
  });

  factory ExerciseSet.fromMap(Map<String, dynamic> data) {
    return ExerciseSet(
      nombre: data['nombre'] ?? '',
      ejercicios: (data['ejercicios'] as List<dynamic>?)
              ?.map((e) => RoutineExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      orden: data['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'ejercicios': ejercicios.map((e) => e.toMap()).toList(),
      'orden': orden,
    };
  }
}

/// Modelo completo de rutina
class RoutineModel {
  final String id;
  final String nombre;
  final String? descripcion;
  final RoutineDifficulty dificultad;
  final RoutineBodyPart parteDelCuerpo;
  final RoutineGender genero;
  final List<RoutineExercise> ejercicios;
  final List<ExerciseSet>? sets;
  final int duracionMinutos;
  final String? imageUrl;
  final bool esPlantilla;
  final String? creadoPor; // UID del entrenador
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoutineModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.dificultad,
    required this.parteDelCuerpo,
    this.genero = RoutineGender.unisex,
    required this.ejercicios,
    this.sets,
    this.duracionMinutos = 60,
    this.imageUrl,
    this.esPlantilla = false,
    this.creadoPor,
    this.createdAt,
    this.updatedAt,
  });

  int get ejercicioCount => ejercicios.length;

  String get duracionTexto {
    if (duracionMinutos < 60) {
      return '$duracionMinutos min';
    } else {
      final horas = duracionMinutos ~/ 60;
      final minutos = duracionMinutos % 60;
      if (minutos == 0) {
        return '$horas h';
      }
      return '$horas h $minutos min';
    }
  }

  /// Crear desde Firestore
  factory RoutineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return RoutineModel(
        id: doc.id,
        nombre: '',
        dificultad: RoutineDifficulty.principiante,
        parteDelCuerpo: RoutineBodyPart.mixto,
        ejercicios: [],
      );
    }

    return RoutineModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'],
      dificultad:
          RoutineDifficultyExtension.fromString(data['dificultad'] ?? ''),
      parteDelCuerpo:
          RoutineBodyPartExtension.fromString(data['parteDelCuerpo'] ?? ''),
      genero: RoutineGenderExtension.fromString(data['genero'] ?? 'unisex'),
      ejercicios: (data['ejercicios'] as List<dynamic>?)
              ?.map((e) => RoutineExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      sets: (data['sets'] as List<dynamic>?)
          ?.map((e) => ExerciseSet.fromMap(e as Map<String, dynamic>))
          .toList(),
      duracionMinutos: data['duracionMinutos'] ?? 60,
      imageUrl: data['imageUrl'],
      esPlantilla: data['esPlantilla'] ?? false,
      creadoPor: data['creadoPor'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'dificultad': dificultad.value,
      'parteDelCuerpo': parteDelCuerpo.value,
      'genero': genero.value,
      'ejercicios': ejercicios.map((e) => e.toMap()).toList(),
      'sets': sets?.map((e) => e.toMap()).toList(),
      'duracionMinutos': duracionMinutos,
      'imageUrl': imageUrl,
      'esPlantilla': esPlantilla,
      'creadoPor': creadoPor,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copiar con cambios
  RoutineModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    RoutineDifficulty? dificultad,
    RoutineBodyPart? parteDelCuerpo,
    RoutineGender? genero,
    List<RoutineExercise>? ejercicios,
    List<ExerciseSet>? sets,
    int? duracionMinutos,
    String? imageUrl,
    bool? esPlantilla,
    String? creadoPor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      dificultad: dificultad ?? this.dificultad,
      parteDelCuerpo: parteDelCuerpo ?? this.parteDelCuerpo,
      genero: genero ?? this.genero,
      ejercicios: ejercicios ?? this.ejercicios,
      sets: sets ?? this.sets,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      imageUrl: imageUrl ?? this.imageUrl,
      esPlantilla: esPlantilla ?? this.esPlantilla,
      creadoPor: creadoPor ?? this.creadoPor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Rutina semanal asignada a un cliente
class WeeklyRoutine {
  final String id;
  final String clienteId;
  final String? lunes;
  final String? martes;
  final String? miercoles;
  final String? jueves;
  final String? viernes;
  final String? sabado;
  final String? domingo;
  final DateTime? createdAt;
  final String? creadoPor;
  final DateTime? weekStartDate; // Fecha de inicio de la semana
  final DateTime? expiresAt; // weekStartDate + 7 días

  const WeeklyRoutine({
    required this.id,
    required this.clienteId,
    this.lunes,
    this.martes,
    this.miercoles,
    this.jueves,
    this.viernes,
    this.sabado,
    this.domingo,
    this.createdAt,
    this.creadoPor,
    this.weekStartDate,
    this.expiresAt,
  });

  String? getRutinaDelDia(int diaSemana) {
    switch (diaSemana) {
      case 1:
        return lunes;
      case 2:
        return martes;
      case 3:
        return miercoles;
      case 4:
        return jueves;
      case 5:
        return viernes;
      case 6:
        return sabado;
      case 7:
        return domingo;
      default:
        return null;
    }
  }

  factory WeeklyRoutine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return WeeklyRoutine(id: doc.id, clienteId: '');
    }

    return WeeklyRoutine(
      id: doc.id,
      clienteId: data['clienteId'] ?? '',
      lunes: data['lunes'],
      martes: data['martes'],
      miercoles: data['miercoles'],
      jueves: data['jueves'],
      viernes: data['viernes'],
      sabado: data['sabado'],
      domingo: data['domingo'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      creadoPor: data['creadoPor'],
      weekStartDate: data['weekStartDate'] != null
          ? (data['weekStartDate'] as Timestamp).toDate()
          : null,
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clienteId': clienteId,
      'lunes': lunes,
      'martes': martes,
      'miercoles': miercoles,
      'jueves': jueves,
      'viernes': viernes,
      'sabado': sabado,
      'domingo': domingo,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'creadoPor': creadoPor,
      'weekStartDate':
          weekStartDate != null ? Timestamp.fromDate(weekStartDate!) : null,
      'expiresAt':
          expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  WeeklyRoutine copyWith({
    String? id,
    String? clienteId,
    String? lunes,
    String? martes,
    String? miercoles,
    String? jueves,
    String? viernes,
    String? sabado,
    String? domingo,
    DateTime? createdAt,
    String? creadoPor,
    DateTime? weekStartDate,
    DateTime? expiresAt,
  }) {
    return WeeklyRoutine(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      lunes: lunes ?? this.lunes,
      martes: martes ?? this.martes,
      miercoles: miercoles ?? this.miercoles,
      jueves: jueves ?? this.jueves,
      viernes: viernes ?? this.viernes,
      sabado: sabado ?? this.sabado,
      domingo: domingo ?? this.domingo,
      createdAt: createdAt ?? this.createdAt,
      creadoPor: creadoPor ?? this.creadoPor,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// Historial de entrenamiento
class TrainingHistory {
  final String id;
  final String clienteId;
  final String rutinaId;
  final String rutinaNombre;
  final DateTime fecha;
  final int? duracionMinutos;
  final String? notas;
  final bool completada;

  const TrainingHistory({
    required this.id,
    required this.clienteId,
    required this.rutinaId,
    required this.rutinaNombre,
    required this.fecha,
    this.duracionMinutos,
    this.notas,
    this.completada = true,
  });

  factory TrainingHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return TrainingHistory(
        id: doc.id,
        clienteId: '',
        rutinaId: '',
        rutinaNombre: '',
        fecha: DateTime.now(),
      );
    }

    return TrainingHistory(
      id: doc.id,
      clienteId: data['clienteId'] ?? '',
      rutinaId: data['rutinaId'] ?? '',
      rutinaNombre: data['rutinaNombre'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      duracionMinutos: data['duracionMinutos'],
      notas: data['notas'],
      completada: data['completada'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clienteId': clienteId,
      'rutinaId': rutinaId,
      'rutinaNombre': rutinaNombre,
      'fecha': Timestamp.fromDate(fecha),
      'duracionMinutos': duracionMinutos,
      'notas': notas,
      'completada': completada,
    };
  }
}
