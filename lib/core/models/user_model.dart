import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles de usuario en la aplicación
enum UserRole {
  cliente,
  entrenador,
  admin; // Admin tiene permisos de entrenador + gestión de entrenadores

  String get displayName {
    switch (this) {
      case UserRole.cliente:
        return 'Cliente';
      case UserRole.entrenador:
        return 'Entrenador';
      case UserRole.admin:
        return 'Administrador';
    }
  }

  String get value {
    switch (this) {
      case UserRole.cliente:
        return 'cliente';
      case UserRole.entrenador:
        return 'entrenador';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'entrenador':
        return UserRole.entrenador;
      default:
        return UserRole.cliente;
    }
  }

  /// Verifica si el rol tiene permisos de entrenador
  bool get hasTrainerPermissions {
    return this == UserRole.entrenador || this == UserRole.admin;
  }

  /// Verifica si el rol es admin
  bool get isAdmin {
    return this == UserRole.admin;
  }
}

/// Rango de IMC según OMS
enum IMCRange {
  bajoPeso,
  normal,
  sobrepeso,
  obesidad;

  String get displayName {
    switch (this) {
      case IMCRange.bajoPeso:
        return 'Bajo Peso';
      case IMCRange.normal:
        return 'Normal';
      case IMCRange.sobrepeso:
        return 'Sobrepeso';
      case IMCRange.obesidad:
        return 'Obesidad';
    }
  }

  String get value {
    switch (this) {
      case IMCRange.bajoPeso:
        return 'bajo_peso';
      case IMCRange.normal:
        return 'normal';
      case IMCRange.sobrepeso:
        return 'sobrepeso';
      case IMCRange.obesidad:
        return 'obesidad';
    }
  }

  static IMCRange fromIMC(double imc) {
    if (imc < 18.5) return IMCRange.bajoPeso;
    if (imc < 25) return IMCRange.normal;
    if (imc < 30) return IMCRange.sobrepeso;
    return IMCRange.obesidad;
  }

  static IMCRange fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bajo_peso':
        return IMCRange.bajoPeso;
      case 'normal':
        return IMCRange.normal;
      case 'sobrepeso':
        return IMCRange.sobrepeso;
      case 'obesidad':
        return IMCRange.obesidad;
      default:
        return IMCRange.normal;
    }
  }
}

/// Género del usuario
enum UserGender {
  hombre,
  mujer;

  String get displayName {
    switch (this) {
      case UserGender.hombre:
        return 'Hombre';
      case UserGender.mujer:
        return 'Mujer';
    }
  }

  String get value {
    switch (this) {
      case UserGender.hombre:
        return 'hombre';
      case UserGender.mujer:
        return 'mujer';
    }
  }

  static UserGender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mujer':
        return UserGender.mujer;
      default:
        return UserGender.hombre;
    }
  }
}

/// Objetivo del usuario
enum UserGoal {
  bajarGrasa,
  aumentarMusculo,
  mantener,
  mejorarResistencia,
  flexibilidad;

  String get displayName {
    switch (this) {
      case UserGoal.bajarGrasa:
        return 'Bajar Grasa';
      case UserGoal.aumentarMusculo:
        return 'Aumentar Músculo';
      case UserGoal.mantener:
        return 'Mantener';
      case UserGoal.mejorarResistencia:
        return 'Mejorar Resistencia';
      case UserGoal.flexibilidad:
        return 'Flexibilidad';
    }
  }

  String get value {
    switch (this) {
      case UserGoal.bajarGrasa:
        return 'bajar_grasa';
      case UserGoal.aumentarMusculo:
        return 'aumentar_musculo';
      case UserGoal.mantener:
        return 'mantener';
      case UserGoal.mejorarResistencia:
        return 'mejorar_resistencia';
      case UserGoal.flexibilidad:
        return 'flexibilidad';
    }
  }

  static UserGoal fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bajar_grasa':
        return UserGoal.bajarGrasa;
      case 'aumentar_musculo':
        return UserGoal.aumentarMusculo;
      case 'mantener':
        return UserGoal.mantener;
      case 'mejorar_resistencia':
        return UserGoal.mejorarResistencia;
      case 'flexibilidad':
        return UserGoal.flexibilidad;
      default:
        return UserGoal.mantener;
    }
  }
}

/// Tipo de membresía
enum MembershipType {
  mes1,
  meses3,
  meses6,
  anio1;

  String get displayName {
    switch (this) {
      case MembershipType.mes1:
        return '1 Mes';
      case MembershipType.meses3:
        return '3 Meses';
      case MembershipType.meses6:
        return '6 Meses';
      case MembershipType.anio1:
        return '1 Año';
    }
  }

  String get value {
    switch (this) {
      case MembershipType.mes1:
        return 'mes_1';
      case MembershipType.meses3:
        return 'meses_3';
      case MembershipType.meses6:
        return 'meses_6';
      case MembershipType.anio1:
        return 'anio_1';
    }
  }

  int get durationInMonths {
    switch (this) {
      case MembershipType.mes1:
        return 1;
      case MembershipType.meses3:
        return 3;
      case MembershipType.meses6:
        return 6;
      case MembershipType.anio1:
        return 12;
    }
  }

  static MembershipType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mes_1':
        return MembershipType.mes1;
      case 'meses_3':
        return MembershipType.meses3;
      case 'meses_6':
        return MembershipType.meses6;
      case 'anio_1':
        return MembershipType.anio1;
      default:
        return MembershipType.mes1;
    }
  }
}

/// Modelo de usuario completo
class UserModel {
  final String uid;
  final String email;
  final String? nombre;
  final String? photoUrl;
  final UserRole rol;
  final int? edad;
  final double? altura; // en metros
  final double? peso; // en kg
  final double? pesoInicial; // peso al registrarse
  final UserGender? genero;
  final double? imc;
  final IMCRange? rangoIMC;
  final UserGoal? objetivo;
  final List<int>? diasEntrenamiento; // 1=Lunes, 7=Domingo
  final String? rutinaAsignadaId;
  final DateTime? fechaUltimoEntrenamiento;
  final int rachasDias;
  final bool onboardingCompleto;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Campos de membresía
  final MembershipType? tipoMembresia;
  final DateTime? fechaPagoMembresia;
  final DateTime? fechaFinMembresia;

  const UserModel({
    required this.uid,
    required this.email,
    this.nombre,
    this.photoUrl,
    this.rol = UserRole.cliente,
    this.edad,
    this.altura,
    this.peso,
    this.pesoInicial,
    this.genero,
    this.imc,
    this.rangoIMC,
    this.objetivo,
    this.diasEntrenamiento,
    this.rutinaAsignadaId,
    this.fechaUltimoEntrenamiento,
    this.rachasDias = 0,
    this.onboardingCompleto = false,
    this.createdAt,
    this.updatedAt,
    this.tipoMembresia,
    this.fechaPagoMembresia,
    this.fechaFinMembresia,
  });

  /// Calcular IMC automáticamente
  static double calcularIMC(double peso, double altura) {
    if (altura <= 0) return 0;
    return peso / (altura * altura);
  }

  /// Estado del cliente basado en rutina asignada
  String get estadoRutina {
    if (rutinaAsignadaId == null || rutinaAsignadaId!.isEmpty) {
      return 'Sin rutina';
    }
    // Aquí podríamos agregar lógica para verificar si la rutina está vencida
    return 'Con rutina';
  }

  /// Texto del último entrenamiento
  String get ultimoEntrenamientoTexto {
    if (fechaUltimoEntrenamiento == null) return 'Nunca';
    final diferencia = DateTime.now().difference(fechaUltimoEntrenamiento!);
    if (diferencia.inDays == 0) return 'Hoy';
    if (diferencia.inDays == 1) return 'Ayer';
    if (diferencia.inDays < 7) return 'Hace ${diferencia.inDays} días';
    if (diferencia.inDays < 30) return 'Hace ${(diferencia.inDays / 7).floor()} semanas';
    return 'Hace ${(diferencia.inDays / 30).floor()} meses';
  }

  /// Verifica si la membresía está activa
  bool get tieneMembresiaActiva {
    if (fechaFinMembresia == null) return false;
    return DateTime.now().isBefore(fechaFinMembresia!);
  }

  /// Días restantes de membresía
  int get diasRestantesMembresia {
    if (fechaFinMembresia == null) return 0;
    final diferencia = fechaFinMembresia!.difference(DateTime.now());
    return diferencia.inDays > 0 ? diferencia.inDays : 0;
  }

  /// Verifica si la membresía está por vencer (menos de 7 días)
  bool get membresiaPorVencer {
    return tieneMembresiaActiva && diasRestantesMembresia <= 7 && diasRestantesMembresia > 0;
  }

  /// Crear desde Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserModel(uid: doc.id, email: '');
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nombre: data['nombre'],
      photoUrl: data['photoUrl'],
      rol: UserRole.fromString(data['rol'] ?? 'cliente'),
      edad: data['edad'],
      altura: (data['altura'] as num?)?.toDouble(),
      peso: (data['peso'] as num?)?.toDouble(),
      pesoInicial: (data['pesoInicial'] as num?)?.toDouble(),
      genero: data['genero'] != null
          ? UserGender.fromString(data['genero'])
          : null,
      imc: (data['imc'] as num?)?.toDouble(),
      rangoIMC: data['rangoIMC'] != null
          ? IMCRange.fromString(data['rangoIMC'])
          : null,
      objetivo: data['objetivo'] != null
          ? UserGoal.fromString(data['objetivo'])
          : null,
      diasEntrenamiento: (data['diasEntrenamiento'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      rutinaAsignadaId: data['rutinaAsignadaId'],
      fechaUltimoEntrenamiento: data['fechaUltimoEntrenamiento'] != null
          ? (data['fechaUltimoEntrenamiento'] as Timestamp).toDate()
          : null,
      rachasDias: data['rachasDias'] ?? 0,
      onboardingCompleto: data['onboardingCompleto'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      tipoMembresia: data['tipoMembresia'] != null
          ? MembershipType.fromString(data['tipoMembresia'])
          : null,
      fechaPagoMembresia: data['fechaPagoMembresia'] != null
          ? (data['fechaPagoMembresia'] as Timestamp).toDate()
          : null,
      fechaFinMembresia: data['fechaFinMembresia'] != null
          ? (data['fechaFinMembresia'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nombre': nombre,
      'photoUrl': photoUrl,
      'rol': rol.value,
      'edad': edad,
      'altura': altura,
      'peso': peso,
      'pesoInicial': pesoInicial,
      'genero': genero?.value,
      'imc': imc,
      'rangoIMC': rangoIMC?.value,
      'objetivo': objetivo?.value,
      'diasEntrenamiento': diasEntrenamiento,
      'rutinaAsignadaId': rutinaAsignadaId,
      'fechaUltimoEntrenamiento': fechaUltimoEntrenamiento != null
          ? Timestamp.fromDate(fechaUltimoEntrenamiento!)
          : null,
      'rachasDias': rachasDias,
      'onboardingCompleto': onboardingCompleto,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'tipoMembresia': tipoMembresia?.value,
      'fechaPagoMembresia': fechaPagoMembresia != null
          ? Timestamp.fromDate(fechaPagoMembresia!)
          : null,
      'fechaFinMembresia': fechaFinMembresia != null
          ? Timestamp.fromDate(fechaFinMembresia!)
          : null,
    };
  }

  /// Copiar con cambios
  UserModel copyWith({
    String? uid,
    String? email,
    String? nombre,
    String? photoUrl,
    UserRole? rol,
    int? edad,
    double? altura,
    double? peso,
    double? pesoInicial,
    UserGender? genero,
    double? imc,
    IMCRange? rangoIMC,
    UserGoal? objetivo,
    List<int>? diasEntrenamiento,
    String? rutinaAsignadaId,
    DateTime? fechaUltimoEntrenamiento,
    int? rachasDias,
    bool? onboardingCompleto,
    DateTime? createdAt,
    DateTime? updatedAt,
    MembershipType? tipoMembresia,
    DateTime? fechaPagoMembresia,
    DateTime? fechaFinMembresia,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      photoUrl: photoUrl ?? this.photoUrl,
      rol: rol ?? this.rol,
      edad: edad ?? this.edad,
      altura: altura ?? this.altura,
      peso: peso ?? this.peso,
      pesoInicial: pesoInicial ?? this.pesoInicial,
      genero: genero ?? this.genero,
      imc: imc ?? this.imc,
      rangoIMC: rangoIMC ?? this.rangoIMC,
      objetivo: objetivo ?? this.objetivo,
      diasEntrenamiento: diasEntrenamiento ?? this.diasEntrenamiento,
      rutinaAsignadaId: rutinaAsignadaId ?? this.rutinaAsignadaId,
      fechaUltimoEntrenamiento:
          fechaUltimoEntrenamiento ?? this.fechaUltimoEntrenamiento,
      rachasDias: rachasDias ?? this.rachasDias,
      onboardingCompleto: onboardingCompleto ?? this.onboardingCompleto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tipoMembresia: tipoMembresia ?? this.tipoMembresia,
      fechaPagoMembresia: fechaPagoMembresia ?? this.fechaPagoMembresia,
      fechaFinMembresia: fechaFinMembresia ?? this.fechaFinMembresia,
    );
  }
}
