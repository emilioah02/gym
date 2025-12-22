import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para las solicitudes de rutina que hacen los clientes al coach
class RoutineRequestModel {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String? clientePhotoUrl;
  final String? trainerId;
  final RequestedBodyPart parteDelCuerpo;
  final RequestStatus estado;
  final DateTime fechaSolicitud;
  final String? respuestaNota;
  final String? rutinaAsignadaId;
  final DateTime? fechaRespuesta;

  RoutineRequestModel({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    this.clientePhotoUrl,
    this.trainerId,
    required this.parteDelCuerpo,
    required this.estado,
    required this.fechaSolicitud,
    this.respuestaNota,
    this.rutinaAsignadaId,
    this.fechaRespuesta,
  });

  // Factory desde Firestore
  factory RoutineRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoutineRequestModel(
      id: doc.id,
      clienteId: data['clienteId'] ?? '',
      clienteNombre: data['clienteNombre'] ?? 'Cliente',
      clientePhotoUrl: data['clientePhotoUrl'],
      trainerId: data['trainerId'],
      parteDelCuerpo: RequestedBodyPart.values.firstWhere(
        (e) => e.name == data['parteDelCuerpo'],
        orElse: () => RequestedBodyPart.pierna,
      ),
      estado: RequestStatus.values.firstWhere(
        (e) => e.name == data['estado'],
        orElse: () => RequestStatus.pendiente,
      ),
      fechaSolicitud: (data['fechaSolicitud'] as Timestamp).toDate(),
      respuestaNota: data['respuestaNota'],
      rutinaAsignadaId: data['rutinaAsignadaId'],
      fechaRespuesta: data['fechaRespuesta'] != null
          ? (data['fechaRespuesta'] as Timestamp).toDate()
          : null,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'clientePhotoUrl': clientePhotoUrl,
      'trainerId': trainerId,
      'parteDelCuerpo': parteDelCuerpo.name,
      'estado': estado.name,
      'fechaSolicitud': Timestamp.fromDate(fechaSolicitud),
      'respuestaNota': respuestaNota,
      'rutinaAsignadaId': rutinaAsignadaId,
    };

    if (fechaRespuesta != null) {
      map['fechaRespuesta'] = Timestamp.fromDate(fechaRespuesta!);
    }

    return map;
  }

  // CopyWith para actualizaciones inmutables
  RoutineRequestModel copyWith({
    String? id,
    String? clienteId,
    String? clienteNombre,
    String? clientePhotoUrl,
    String? trainerId,
    RequestedBodyPart? parteDelCuerpo,
    RequestStatus? estado,
    DateTime? fechaSolicitud,
    String? respuestaNota,
    String? rutinaAsignadaId,
    DateTime? fechaRespuesta,
  }) {
    return RoutineRequestModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      clientePhotoUrl: clientePhotoUrl ?? this.clientePhotoUrl,
      trainerId: trainerId ?? this.trainerId,
      parteDelCuerpo: parteDelCuerpo ?? this.parteDelCuerpo,
      estado: estado ?? this.estado,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      respuestaNota: respuestaNota ?? this.respuestaNota,
      rutinaAsignadaId: rutinaAsignadaId ?? this.rutinaAsignadaId,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
    );
  }
}

/// Partes del cuerpo que el cliente puede solicitar entrenar
enum RequestedBodyPart {
  pierna('Pierna', '🦵'),
  pecho('Pecho', '💪'),
  espalda('Espalda', '🔙'),
  hombro('Hombro', '💪'),
  brazo('Brazo', '💪'),
  fullBody('Full Body', '🏋️');

  final String displayName;
  final String emoji;
  const RequestedBodyPart(this.displayName, this.emoji);
}

/// Estado de la solicitud
enum RequestStatus {
  pendiente('Pendiente', '⏳'),
  asignada('Asignada', '✅'),
  rechazada('Rechazada', '❌');

  final String displayName;
  final String emoji;
  const RequestStatus(this.displayName, this.emoji);
}
