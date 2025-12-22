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
    );
  }
}
