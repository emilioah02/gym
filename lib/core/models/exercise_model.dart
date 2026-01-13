import 'package:cloud_firestore/cloud_firestore.dart';
import 'machine_model.dart';
import 'routine_model.dart';

/// Tipo de movimiento del ejercicio
enum MovementType {
  empuje, // Push movements
  tiron, // Pull movements
  sentadilla, // Squat patterns
  bisagra, // Hip hinge patterns
  acarreo, // Carry movements
  rotacion, // Rotational movements
  aislamiento, // Isolation movements
  isometrico, // Isometric holds
  pliometrico, // Plyometric/explosive
  cardio, // Cardiovascular
}

extension MovementTypeExtension on MovementType {
  String get displayName {
    switch (this) {
      case MovementType.empuje:
        return 'Empuje';
      case MovementType.tiron:
        return 'Tirón';
      case MovementType.sentadilla:
        return 'Sentadilla';
      case MovementType.bisagra:
        return 'Bisagra de Cadera';
      case MovementType.acarreo:
        return 'Acarreo';
      case MovementType.rotacion:
        return 'Rotación';
      case MovementType.aislamiento:
        return 'Aislamiento';
      case MovementType.isometrico:
        return 'Isométrico';
      case MovementType.pliometrico:
        return 'Pliométrico';
      case MovementType.cardio:
        return 'Cardiovascular';
    }
  }

  String get value => name;

  static MovementType fromString(String value) {
    return MovementType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => MovementType.aislamiento,
    );
  }
}

/// Estado de la animación del ejercicio
enum AnimationStatus {
  pendiente, // No tiene animación aún
  enProceso, // Animación en desarrollo
  disponible, // Animación lista para usar
}

extension AnimationStatusExtension on AnimationStatus {
  String get displayName {
    switch (this) {
      case AnimationStatus.pendiente:
        return 'Pendiente';
      case AnimationStatus.enProceso:
        return 'En Proceso';
      case AnimationStatus.disponible:
        return 'Disponible';
    }
  }

  String get value => name;

  static AnimationStatus fromString(String value) {
    return AnimationStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AnimationStatus.pendiente,
    );
  }
}

/// Datos de animación para el ejercicio
class ExerciseAnimation {
  final String? animationUrl; // URL del archivo de animación (Lottie, Rive, etc.)
  final String? thumbnailUrl; // Miniatura de la animación
  final AnimationStatus status; // Estado de la animación
  final int? durationMs; // Duración de la animación en milisegundos
  final List<String>? keyFrames; // Puntos clave del movimiento para guía

  const ExerciseAnimation({
    this.animationUrl,
    this.thumbnailUrl,
    this.status = AnimationStatus.pendiente,
    this.durationMs,
    this.keyFrames,
  });

  factory ExerciseAnimation.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return const ExerciseAnimation();
    }
    return ExerciseAnimation(
      animationUrl: data['animationUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      status: AnimationStatusExtension.fromString(data['status'] ?? 'pendiente'),
      durationMs: data['durationMs'],
      keyFrames: (data['keyFrames'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'animationUrl': animationUrl,
      'thumbnailUrl': thumbnailUrl,
      'status': status.value,
      'durationMs': durationMs,
      'keyFrames': keyFrames,
    };
  }

  bool get hasAnimation => status == AnimationStatus.disponible && animationUrl != null;
}

/// Indicadores de seguridad del ejercicio
class SafetyIndicators {
  final bool requiresSpotter; // Requiere asistente
  final bool highInjuryRisk; // Alto riesgo de lesión si se hace mal
  final List<String>? contraindicaciones; // Condiciones donde no se recomienda
  final List<String>? precauciones; // Precauciones especiales

  const SafetyIndicators({
    this.requiresSpotter = false,
    this.highInjuryRisk = false,
    this.contraindicaciones,
    this.precauciones,
  });

  factory SafetyIndicators.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return const SafetyIndicators();
    }
    return SafetyIndicators(
      requiresSpotter: data['requiresSpotter'] ?? false,
      highInjuryRisk: data['highInjuryRisk'] ?? false,
      contraindicaciones: (data['contraindicaciones'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      precauciones: (data['precauciones'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requiresSpotter': requiresSpotter,
      'highInjuryRisk': highInjuryRisk,
      'contraindicaciones': contraindicaciones,
      'precauciones': precauciones,
    };
  }
}

/// Modelo de ejercicio - representa un ejercicio que se puede realizar en una maquina
/// Los ejercicios estan condicionados a las maquinas disponibles en el gym
class ExerciseModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String? imageUrl;
  final String? videoUrl;
  final String machineId; // ID de la maquina asociada
  final String machineName; // Nombre de la maquina (para display)
  final MachineCategory categoria;
  final MachineCategory? categoriaSecundaria;
  final DifficultyLevel nivel;
  final RoutineGender genero; // Genero objetivo del ejercicio
  final int defaultSets;
  final int defaultReps;
  final int? defaultWeight; // Peso sugerido en kg (opcional)
  final int? restSeconds; // Segundos de descanso sugerido
  final List<String>? instrucciones;
  final List<String>? tips;
  final List<String>? erroresComunes;
  final List<String>? variaciones; // Variaciones del ejercicio
  final List<String>? musculos; // Musculos trabajados
  final bool isActive; // Si el ejercicio esta activo/disponible
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy; // ID del entrenador que creo el ejercicio

  // Nuevos campos para clasificación y animación
  final MovementType? tipoMovimiento; // Clasificación del patrón de movimiento
  final List<MuscleGroup>? musculosPrincipales; // Grupos musculares principales (tipado)
  final List<MuscleGroup>? musculosSecundarios; // Grupos musculares secundarios (tipado)
  final ExerciseAnimation? animacion; // Datos de animación
  final SafetyIndicators? seguridad; // Indicadores de seguridad
  final int? tempoRecomendado; // Tempo en formato XYZW (ej: 3010 = 3seg excéntrico)
  final String? equipamientoAdicional; // Equipamiento extra necesario (cinturón, straps, etc.)

  const ExerciseModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.imageUrl,
    this.videoUrl,
    required this.machineId,
    required this.machineName,
    required this.categoria,
    this.categoriaSecundaria,
    required this.nivel,
    this.genero = RoutineGender.unisex,
    this.defaultSets = 3,
    this.defaultReps = 12,
    this.defaultWeight,
    this.restSeconds = 60,
    this.instrucciones,
    this.tips,
    this.erroresComunes,
    this.variaciones,
    this.musculos,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    // Nuevos campos
    this.tipoMovimiento,
    this.musculosPrincipales,
    this.musculosSecundarios,
    this.animacion,
    this.seguridad,
    this.tempoRecomendado,
    this.equipamientoAdicional,
  });

  /// Crear desde Firestore
  factory ExerciseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return ExerciseModel(
        id: doc.id,
        nombre: '',
        descripcion: '',
        machineId: '',
        machineName: '',
        categoria: MachineCategory.functional,
        nivel: DifficultyLevel.principiante,
      );
    }

    return ExerciseModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      imageUrl: data['imageUrl'],
      videoUrl: data['videoUrl'],
      machineId: data['machineId'] ?? '',
      machineName: data['machineName'] ?? '',
      categoria: MachineCategoryExtension.fromString(data['categoria'] ?? ''),
      categoriaSecundaria: data['categoriaSecundaria'] != null
          ? MachineCategoryExtension.fromString(data['categoriaSecundaria'])
          : null,
      nivel: DifficultyLevelExtension.fromString(data['nivel'] ?? 'principiante'),
      genero: RoutineGenderExtension.fromString(data['genero'] ?? 'unisex'),
      defaultSets: data['defaultSets'] ?? 3,
      defaultReps: data['defaultReps'] ?? 12,
      defaultWeight: data['defaultWeight'],
      restSeconds: data['restSeconds'] ?? 60,
      instrucciones: (data['instrucciones'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      tips: (data['tips'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      erroresComunes: (data['erroresComunes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      variaciones: (data['variaciones'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      musculos: (data['musculos'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'],
      // Nuevos campos
      tipoMovimiento: data['tipoMovimiento'] != null
          ? MovementTypeExtension.fromString(data['tipoMovimiento'])
          : null,
      musculosPrincipales: (data['musculosPrincipales'] as List<dynamic>?)
          ?.map((e) => MuscleGroupExtension.fromString(e.toString()))
          .toList(),
      musculosSecundarios: (data['musculosSecundarios'] as List<dynamic>?)
          ?.map((e) => MuscleGroupExtension.fromString(e.toString()))
          .toList(),
      animacion: ExerciseAnimation.fromMap(data['animacion'] as Map<String, dynamic>?),
      seguridad: SafetyIndicators.fromMap(data['seguridad'] as Map<String, dynamic>?),
      tempoRecomendado: data['tempoRecomendado'],
      equipamientoAdicional: data['equipamientoAdicional'],
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'machineId': machineId,
      'machineName': machineName,
      'categoria': categoria.value,
      'categoriaSecundaria': categoriaSecundaria?.value,
      'nivel': nivel.value,
      'genero': genero.value,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'defaultWeight': defaultWeight,
      'restSeconds': restSeconds,
      'instrucciones': instrucciones,
      'tips': tips,
      'erroresComunes': erroresComunes,
      'variaciones': variaciones,
      'musculos': musculos,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      // Nuevos campos
      'tipoMovimiento': tipoMovimiento?.value,
      'musculosPrincipales': musculosPrincipales?.map((e) => e.value).toList(),
      'musculosSecundarios': musculosSecundarios?.map((e) => e.value).toList(),
      'animacion': animacion?.toMap(),
      'seguridad': seguridad?.toMap(),
      'tempoRecomendado': tempoRecomendado,
      'equipamientoAdicional': equipamientoAdicional,
    };
  }

  /// Copiar con cambios
  ExerciseModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? imageUrl,
    String? videoUrl,
    String? machineId,
    String? machineName,
    MachineCategory? categoria,
    MachineCategory? categoriaSecundaria,
    DifficultyLevel? nivel,
    RoutineGender? genero,
    int? defaultSets,
    int? defaultReps,
    int? defaultWeight,
    int? restSeconds,
    List<String>? instrucciones,
    List<String>? tips,
    List<String>? erroresComunes,
    List<String>? variaciones,
    List<String>? musculos,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    // Nuevos campos
    MovementType? tipoMovimiento,
    List<MuscleGroup>? musculosPrincipales,
    List<MuscleGroup>? musculosSecundarios,
    ExerciseAnimation? animacion,
    SafetyIndicators? seguridad,
    int? tempoRecomendado,
    String? equipamientoAdicional,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      categoria: categoria ?? this.categoria,
      categoriaSecundaria: categoriaSecundaria ?? this.categoriaSecundaria,
      nivel: nivel ?? this.nivel,
      genero: genero ?? this.genero,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      restSeconds: restSeconds ?? this.restSeconds,
      instrucciones: instrucciones ?? this.instrucciones,
      tips: tips ?? this.tips,
      erroresComunes: erroresComunes ?? this.erroresComunes,
      variaciones: variaciones ?? this.variaciones,
      musculos: musculos ?? this.musculos,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      // Nuevos campos
      tipoMovimiento: tipoMovimiento ?? this.tipoMovimiento,
      musculosPrincipales: musculosPrincipales ?? this.musculosPrincipales,
      musculosSecundarios: musculosSecundarios ?? this.musculosSecundarios,
      animacion: animacion ?? this.animacion,
      seguridad: seguridad ?? this.seguridad,
      tempoRecomendado: tempoRecomendado ?? this.tempoRecomendado,
      equipamientoAdicional: equipamientoAdicional ?? this.equipamientoAdicional,
    );
  }

  /// Duracion estimada en minutos
  int get duracionEstimadaMinutos {
    final totalSets = defaultSets;
    final restMinutes = (restSeconds ?? 60) / 60;
    final timePerSet = 0.5; // 30 segundos por serie en promedio
    return ((totalSets * timePerSet) + ((totalSets - 1) * restMinutes)).ceil();
  }

  /// Texto de duracion formateado
  String get duracionTexto {
    final mins = duracionEstimadaMinutos;
    return '$mins min';
  }

  /// Texto de series y reps
  String get setsRepsTexto => '$defaultSets x $defaultReps';
}
