import 'package:cloud_firestore/cloud_firestore.dart';

/// Categorías de máquinas por parte del cuerpo
enum MachineCategory {
  pierna,
  pecho,
  espalda,
  hombro,
  brazo,
  core,
  cardio,
  functional,
}

extension MachineCategoryExtension on MachineCategory {
  String get displayName {
    switch (this) {
      case MachineCategory.pierna:
        return 'Pierna';
      case MachineCategory.pecho:
        return 'Pecho';
      case MachineCategory.espalda:
        return 'Espalda';
      case MachineCategory.hombro:
        return 'Hombro';
      case MachineCategory.brazo:
        return 'Brazo';
      case MachineCategory.core:
        return 'Core';
      case MachineCategory.cardio:
        return 'Cardio';
      case MachineCategory.functional:
        return 'Funcional';
    }
  }

  String get value {
    switch (this) {
      case MachineCategory.pierna:
        return 'pierna';
      case MachineCategory.pecho:
        return 'pecho';
      case MachineCategory.espalda:
        return 'espalda';
      case MachineCategory.hombro:
        return 'hombro';
      case MachineCategory.brazo:
        return 'brazo';
      case MachineCategory.core:
        return 'core';
      case MachineCategory.cardio:
        return 'cardio';
      case MachineCategory.functional:
        return 'functional';
    }
  }

  static MachineCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pierna':
      case 'legs':
        return MachineCategory.pierna;
      case 'pecho':
      case 'chest':
        return MachineCategory.pecho;
      case 'espalda':
      case 'back':
        return MachineCategory.espalda;
      case 'hombro':
      case 'shoulders':
        return MachineCategory.hombro;
      case 'brazo':
      case 'arms':
        return MachineCategory.brazo;
      case 'core':
        return MachineCategory.core;
      case 'cardio':
        return MachineCategory.cardio;
      case 'functional':
        return MachineCategory.functional;
      default:
        return MachineCategory.functional;
    }
  }
}

/// Tipo de máquina/equipo
enum MachineType {
  maquina,
  pesoLibre,
  funcional,
}

extension MachineTypeExtension on MachineType {
  String get displayName {
    switch (this) {
      case MachineType.maquina:
        return 'Máquina';
      case MachineType.pesoLibre:
        return 'Peso Libre';
      case MachineType.funcional:
        return 'Funcional';
    }
  }

  String get value {
    switch (this) {
      case MachineType.maquina:
        return 'maquina';
      case MachineType.pesoLibre:
        return 'peso_libre';
      case MachineType.funcional:
        return 'funcional';
    }
  }

  static MachineType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'maquina':
        return MachineType.maquina;
      case 'peso_libre':
        return MachineType.pesoLibre;
      case 'funcional':
        return MachineType.funcional;
      default:
        return MachineType.maquina;
    }
  }
}

/// Nivel de dificultad
enum DifficultyLevel {
  principiante,
  intermedio,
  avanzado,
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.principiante:
        return 'Principiante';
      case DifficultyLevel.intermedio:
        return 'Intermedio';
      case DifficultyLevel.avanzado:
        return 'Avanzado';
    }
  }

  String get value {
    switch (this) {
      case DifficultyLevel.principiante:
        return 'principiante';
      case DifficultyLevel.intermedio:
        return 'intermedio';
      case DifficultyLevel.avanzado:
        return 'avanzado';
    }
  }

  static DifficultyLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'principiante':
        return DifficultyLevel.principiante;
      case 'intermedio':
        return DifficultyLevel.intermedio;
      case 'avanzado':
        return DifficultyLevel.avanzado;
      default:
        return DifficultyLevel.principiante;
    }
  }
}

/// Grupos musculares específicos
enum MuscleGroup {
  cuadriceps,
  isquiotibiales,
  gluteos,
  aductores,
  abductores,
  pantorrillas,
  pectoralMayor,
  pectoralMenor,
  dorsales,
  trapecios,
  romboides,
  erectoresEspinales,
  deltoidesAnterior,
  deltoidesLateral,
  deltoidesPosterior,
  biceps,
  triceps,
  antebrazos,
  abdominales,
  oblicuos,
  transversoAbdominal,
  flexoresCadera,
  core,
}

extension MuscleGroupExtension on MuscleGroup {
  String get displayName {
    switch (this) {
      case MuscleGroup.cuadriceps:
        return 'Cuádriceps';
      case MuscleGroup.isquiotibiales:
        return 'Isquiotibiales';
      case MuscleGroup.gluteos:
        return 'Glúteos';
      case MuscleGroup.aductores:
        return 'Aductores';
      case MuscleGroup.abductores:
        return 'Abductores';
      case MuscleGroup.pantorrillas:
        return 'Pantorrillas';
      case MuscleGroup.pectoralMayor:
        return 'Pectoral Mayor';
      case MuscleGroup.pectoralMenor:
        return 'Pectoral Menor';
      case MuscleGroup.dorsales:
        return 'Dorsales';
      case MuscleGroup.trapecios:
        return 'Trapecios';
      case MuscleGroup.romboides:
        return 'Romboides';
      case MuscleGroup.erectoresEspinales:
        return 'Erectores Espinales';
      case MuscleGroup.deltoidesAnterior:
        return 'Deltoides Anterior';
      case MuscleGroup.deltoidesLateral:
        return 'Deltoides Lateral';
      case MuscleGroup.deltoidesPosterior:
        return 'Deltoides Posterior';
      case MuscleGroup.biceps:
        return 'Bíceps';
      case MuscleGroup.triceps:
        return 'Tríceps';
      case MuscleGroup.antebrazos:
        return 'Antebrazos';
      case MuscleGroup.abdominales:
        return 'Abdominales';
      case MuscleGroup.oblicuos:
        return 'Oblicuos';
      case MuscleGroup.transversoAbdominal:
        return 'Transverso Abdominal';
      case MuscleGroup.flexoresCadera:
        return 'Flexores de Cadera';
      case MuscleGroup.core:
        return 'Core';
    }
  }

  String get value => name;

  static MuscleGroup fromString(String value) {
    return MuscleGroup.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => MuscleGroup.core,
    );
  }
}

/// Modelo de máquina/equipo de gimnasio
class MachineModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String? imageUrl;
  final MachineCategory categoria;
  final MachineCategory? categoriaSecundaria;
  final MachineType tipo;
  final DifficultyLevel nivel;
  final int defaultSets;
  final int defaultReps;
  final List<String>? tips;
  final List<String>? erroresComunes;

  // Nuevos campos para grupos musculares específicos
  final List<MuscleGroup>? musculosPrincipales;
  final List<MuscleGroup>? musculosSecundarios;

  const MachineModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.imageUrl,
    required this.categoria,
    this.categoriaSecundaria,
    required this.tipo,
    required this.nivel,
    this.defaultSets = 3,
    this.defaultReps = 12,
    this.tips,
    this.erroresComunes,
    this.musculosPrincipales,
    this.musculosSecundarios,
  });

  /// Crear desde Firestore
  factory MachineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return MachineModel(
        id: doc.id,
        nombre: '',
        descripcion: '',
        categoria: MachineCategory.functional,
        tipo: MachineType.maquina,
        nivel: DifficultyLevel.principiante,
      );
    }

    return MachineModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      imageUrl: data['imageUrl'],
      categoria: MachineCategoryExtension.fromString(data['categoria'] ?? ''),
      categoriaSecundaria: data['categoriaSecundaria'] != null
          ? MachineCategoryExtension.fromString(data['categoriaSecundaria'])
          : null,
      tipo: MachineTypeExtension.fromString(data['tipo'] ?? 'maquina'),
      nivel: DifficultyLevelExtension.fromString(data['nivel'] ?? 'principiante'),
      defaultSets: data['defaultSets'] ?? 3,
      defaultReps: data['defaultReps'] ?? 12,
      tips: (data['tips'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      erroresComunes: (data['erroresComunes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      musculosPrincipales: (data['musculosPrincipales'] as List<dynamic>?)
          ?.map((e) => MuscleGroupExtension.fromString(e.toString()))
          .toList(),
      musculosSecundarios: (data['musculosSecundarios'] as List<dynamic>?)
          ?.map((e) => MuscleGroupExtension.fromString(e.toString()))
          .toList(),
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'imageUrl': imageUrl,
      'categoria': categoria.value,
      'categoriaSecundaria': categoriaSecundaria?.value,
      'tipo': tipo.value,
      'nivel': nivel.value,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'tips': tips,
      'erroresComunes': erroresComunes,
      'musculosPrincipales': musculosPrincipales?.map((e) => e.value).toList(),
      'musculosSecundarios': musculosSecundarios?.map((e) => e.value).toList(),
    };
  }

  /// Copiar con cambios
  MachineModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? imageUrl,
    MachineCategory? categoria,
    MachineCategory? categoriaSecundaria,
    MachineType? tipo,
    DifficultyLevel? nivel,
    int? defaultSets,
    int? defaultReps,
    List<String>? tips,
    List<String>? erroresComunes,
    List<MuscleGroup>? musculosPrincipales,
    List<MuscleGroup>? musculosSecundarios,
  }) {
    return MachineModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      imageUrl: imageUrl ?? this.imageUrl,
      categoria: categoria ?? this.categoria,
      categoriaSecundaria: categoriaSecundaria ?? this.categoriaSecundaria,
      tipo: tipo ?? this.tipo,
      nivel: nivel ?? this.nivel,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      tips: tips ?? this.tips,
      erroresComunes: erroresComunes ?? this.erroresComunes,
      musculosPrincipales: musculosPrincipales ?? this.musculosPrincipales,
      musculosSecundarios: musculosSecundarios ?? this.musculosSecundarios,
    );
  }
}
