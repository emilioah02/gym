import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipos de anuncio
enum AnnouncementType {
  oferta,
  aviso,
  promocion,
  informacion,
}

/// Modelo para anuncios/notificaciones personalizadas del entrenador
class AnnouncementModel {
  final String id;
  final String titulo;
  final String mensaje;
  final AnnouncementType tipo;
  final String entrenadorId;
  final String entrenadorNombre;
  final DateTime fechaCreacion;
  final List<String> clientesIds; // Vacío = todos los clientes
  final String? imageUrl;
  final bool activo;

  const AnnouncementModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.entrenadorId,
    required this.entrenadorNombre,
    required this.fechaCreacion,
    this.clientesIds = const [],
    this.imageUrl,
    this.activo = true,
  });

  /// Convertir desde Firestore
  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      titulo: data['titulo'] as String? ?? '',
      mensaje: data['mensaje'] as String? ?? '',
      tipo: _parseAnnouncementType(data['tipo'] as String?),
      entrenadorId: data['entrenadorId'] as String? ?? '',
      entrenadorNombre: data['entrenadorNombre'] as String? ?? '',
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      clientesIds: (data['clientesIds'] as List<dynamic>?)?.cast<String>() ?? [],
      imageUrl: data['imageUrl'] as String?,
      activo: data['activo'] as bool? ?? true,
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo.name,
      'entrenadorId': entrenadorId,
      'entrenadorNombre': entrenadorNombre,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'clientesIds': clientesIds,
      'imageUrl': imageUrl,
      'activo': activo,
    };
  }

  /// Parse announcement type from string
  static AnnouncementType _parseAnnouncementType(String? type) {
    switch (type) {
      case 'oferta':
        return AnnouncementType.oferta;
      case 'aviso':
        return AnnouncementType.aviso;
      case 'promocion':
        return AnnouncementType.promocion;
      case 'informacion':
        return AnnouncementType.informacion;
      default:
        return AnnouncementType.aviso;
    }
  }

  /// Obtener color según el tipo de anuncio
  String getColorName() {
    switch (tipo) {
      case AnnouncementType.oferta:
        return 'success';
      case AnnouncementType.promocion:
        return 'primary';
      case AnnouncementType.aviso:
        return 'warning';
      case AnnouncementType.informacion:
        return 'info';
    }
  }

  /// Obtener icono según el tipo de anuncio
  String getIconName() {
    switch (tipo) {
      case AnnouncementType.oferta:
        return 'local_offer';
      case AnnouncementType.promocion:
        return 'celebration';
      case AnnouncementType.aviso:
        return 'notifications_active';
      case AnnouncementType.informacion:
        return 'info';
    }
  }

  /// Verificar si el anuncio es para un cliente específico
  bool isForClient(String clientId) {
    // Si la lista está vacía, es para todos los clientes
    if (clientesIds.isEmpty) return true;
    // Si no, verificar si el cliente está en la lista
    return clientesIds.contains(clientId);
  }

  /// Copiar con modificaciones
  AnnouncementModel copyWith({
    String? id,
    String? titulo,
    String? mensaje,
    AnnouncementType? tipo,
    String? entrenadorId,
    String? entrenadorNombre,
    DateTime? fechaCreacion,
    List<String>? clientesIds,
    String? imageUrl,
    bool? activo,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      entrenadorId: entrenadorId ?? this.entrenadorId,
      entrenadorNombre: entrenadorNombre ?? this.entrenadorNombre,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      clientesIds: clientesIds ?? this.clientesIds,
      imageUrl: imageUrl ?? this.imageUrl,
      activo: activo ?? this.activo,
    );
  }
}

/// Modelo para seguimiento de notificaciones leídas por cliente
class ClientNotificationStatus {
  final String id;
  final String clienteId;
  final String anuncioId;
  final DateTime fechaLeido;
  final bool eliminado;

  const ClientNotificationStatus({
    required this.id,
    required this.clienteId,
    required this.anuncioId,
    required this.fechaLeido,
    this.eliminado = false,
  });

  /// Convertir desde Firestore
  factory ClientNotificationStatus.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClientNotificationStatus(
      id: doc.id,
      clienteId: data['clienteId'] as String? ?? '',
      anuncioId: data['anuncioId'] as String? ?? '',
      fechaLeido: (data['fechaLeido'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eliminado: data['eliminado'] as bool? ?? false,
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'anuncioId': anuncioId,
      'fechaLeido': Timestamp.fromDate(fechaLeido),
      'eliminado': eliminado,
    };
  }
}
