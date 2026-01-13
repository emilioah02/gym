import 'package:cloud_firestore/cloud_firestore.dart';

/// Estado de la rutina asignada
enum AssignedRoutineStatus {
  activa,
  completada,
  expirada,
  descartada,
}

extension AssignedRoutineStatusExtension on AssignedRoutineStatus {
  String get value {
    switch (this) {
      case AssignedRoutineStatus.activa:
        return 'activa';
      case AssignedRoutineStatus.completada:
        return 'completada';
      case AssignedRoutineStatus.expirada:
        return 'expirada';
      case AssignedRoutineStatus.descartada:
        return 'descartada';
    }
  }

  String get displayName {
    switch (this) {
      case AssignedRoutineStatus.activa:
        return 'Activa';
      case AssignedRoutineStatus.completada:
        return 'Completada';
      case AssignedRoutineStatus.expirada:
        return 'Expirada';
      case AssignedRoutineStatus.descartada:
        return 'Descartada';
    }
  }

  static AssignedRoutineStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'activa':
        return AssignedRoutineStatus.activa;
      case 'completada':
        return AssignedRoutineStatus.completada;
      case 'expirada':
        return AssignedRoutineStatus.expirada;
      case 'descartada':
        return AssignedRoutineStatus.descartada;
      default:
        return AssignedRoutineStatus.activa;
    }
  }
}

/// Modelo de rutina asignada temporalmente a un cliente
/// Las rutinas asignadas expiran automáticamente después de 3 horas
class AssignedRoutineModel {
  final String id;
  final String clienteId;
  final String rutinaId;
  final String rutinaNombre;
  final String? trainerId;
  final DateTime fechaAsignacion;
  final DateTime fechaExpiracion;
  final AssignedRoutineStatus estado;
  final DateTime? fechaCompletada;

  /// Duración por defecto de una rutina asignada: 3 horas
  static const Duration defaultDuration = Duration(hours: 3);

  const AssignedRoutineModel({
    required this.id,
    required this.clienteId,
    required this.rutinaId,
    required this.rutinaNombre,
    this.trainerId,
    required this.fechaAsignacion,
    required this.fechaExpiracion,
    this.estado = AssignedRoutineStatus.activa,
    this.fechaCompletada,
  });

  /// Verifica si la rutina asignada sigue activa (no expirada y no completada)
  bool get isActive {
    if (estado != AssignedRoutineStatus.activa) return false;
    return DateTime.now().isBefore(fechaExpiracion);
  }

  /// Verifica si la rutina ha expirado
  bool get isExpired {
    return DateTime.now().isAfter(fechaExpiracion) &&
           estado != AssignedRoutineStatus.completada;
  }

  /// Tiempo restante antes de que expire
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(fechaExpiracion)) return Duration.zero;
    return fechaExpiracion.difference(now);
  }

  /// Porcentaje de tiempo transcurrido (0.0 a 1.0)
  double get timeElapsedPercent {
    final totalDuration = fechaExpiracion.difference(fechaAsignacion);
    final elapsed = DateTime.now().difference(fechaAsignacion);
    final percent = elapsed.inSeconds / totalDuration.inSeconds;
    return percent.clamp(0.0, 1.0);
  }

  /// Crear desde Firestore
  factory AssignedRoutineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return AssignedRoutineModel(
        id: doc.id,
        clienteId: '',
        rutinaId: '',
        rutinaNombre: '',
        fechaAsignacion: DateTime.now(),
        fechaExpiracion: DateTime.now(),
      );
    }

    return AssignedRoutineModel(
      id: doc.id,
      clienteId: data['clienteId'] ?? '',
      rutinaId: data['rutinaId'] ?? '',
      rutinaNombre: data['rutinaNombre'] ?? '',
      trainerId: data['trainerId'],
      fechaAsignacion: data['fechaAsignacion'] != null
          ? (data['fechaAsignacion'] as Timestamp).toDate()
          : DateTime.now(),
      fechaExpiracion: data['fechaExpiracion'] != null
          ? (data['fechaExpiracion'] as Timestamp).toDate()
          : DateTime.now().add(defaultDuration),
      estado: AssignedRoutineStatusExtension.fromString(data['estado'] ?? 'activa'),
      fechaCompletada: data['fechaCompletada'] != null
          ? (data['fechaCompletada'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'clienteId': clienteId,
      'rutinaId': rutinaId,
      'rutinaNombre': rutinaNombre,
      'trainerId': trainerId,
      'fechaAsignacion': Timestamp.fromDate(fechaAsignacion),
      'fechaExpiracion': Timestamp.fromDate(fechaExpiracion),
      'estado': estado.value,
      'fechaCompletada': fechaCompletada != null
          ? Timestamp.fromDate(fechaCompletada!)
          : null,
    };
  }

  /// Crear una nueva asignación con expiración de 3 horas
  factory AssignedRoutineModel.create({
    required String clienteId,
    required String rutinaId,
    required String rutinaNombre,
    String? trainerId,
  }) {
    final now = DateTime.now();
    return AssignedRoutineModel(
      id: '',
      clienteId: clienteId,
      rutinaId: rutinaId,
      rutinaNombre: rutinaNombre,
      trainerId: trainerId,
      fechaAsignacion: now,
      fechaExpiracion: now.add(defaultDuration),
      estado: AssignedRoutineStatus.activa,
    );
  }

  /// Copiar con cambios
  AssignedRoutineModel copyWith({
    String? id,
    String? clienteId,
    String? rutinaId,
    String? rutinaNombre,
    String? trainerId,
    DateTime? fechaAsignacion,
    DateTime? fechaExpiracion,
    AssignedRoutineStatus? estado,
    DateTime? fechaCompletada,
  }) {
    return AssignedRoutineModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      rutinaId: rutinaId ?? this.rutinaId,
      rutinaNombre: rutinaNombre ?? this.rutinaNombre,
      trainerId: trainerId ?? this.trainerId,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      fechaExpiracion: fechaExpiracion ?? this.fechaExpiracion,
      estado: estado ?? this.estado,
      fechaCompletada: fechaCompletada ?? this.fechaCompletada,
    );
  }
}
