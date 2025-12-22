import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _machinesCollection =>
      _firestore.collection('machines');

  CollectionReference<Map<String, dynamic>> get _routinesCollection =>
      _firestore.collection('routines');

  CollectionReference<Map<String, dynamic>> get _weeklyRoutinesCollection =>
      _firestore.collection('weekly_routines');

  CollectionReference<Map<String, dynamic>> get _historyCollection =>
      _firestore.collection('history');

  CollectionReference<Map<String, dynamic>> get _trainersCollection =>
      _firestore.collection('trainers');

  CollectionReference<Map<String, dynamic>> get _routineRequestsCollection =>
      _firestore.collection('routine_requests');

  CollectionReference<Map<String, dynamic>> get _storeOrdersCollection =>
      _firestore.collection('store_orders');

  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get _announcementsCollection =>
      _firestore.collection('announcements');

  CollectionReference<Map<String, dynamic>> get _clientNotificationStatusCollection =>
      _firestore.collection('client_notification_status');

  // ============ USERS ============

  /// Obtener usuario por UID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Stream de usuario
  Stream<UserModel?> userStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// Crear o actualizar usuario
  Future<void> saveUser(UserModel user) async {
    await _usersCollection.doc(user.uid).set(
          user.toFirestore(),
          SetOptions(merge: true),
        );
  }

  /// Verificar si el email es de entrenador (legacy - mantener para compatibilidad)
  Future<bool> isTrainer(String email) async {
    final query = await _trainersCollection
        .where('email', isEqualTo: email.toLowerCase())
        .where('activo', isEqualTo: true)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Obtener rol del usuario por UID desde su documento en Firestore
  Future<UserRole> getUserRole(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) {
        print('⚠️ [getUserRole] Usuario no existe en Firestore: $uid');
        return UserRole.cliente; // Default role
      }

      final data = doc.data();
      if (data == null) {
        print('⚠️ [getUserRole] Documento sin datos: $uid');
        return UserRole.cliente;
      }

      final rolString = data['rol'] as String?;
      if (rolString == null) {
        print('⚠️ [getUserRole] Campo rol no encontrado para: $uid');
        return UserRole.cliente;
      }

      final role = UserRole.fromString(rolString);
      print('✅ [getUserRole] Rol obtenido para $uid: ${role.value}');
      return role;
    } catch (e) {
      print('❌ [getUserRole] Error obteniendo rol: $e');
      return UserRole.cliente; // Default role en caso de error
    }
  }

  /// Obtener todos los clientes (para entrenador)
  Stream<List<UserModel>> getAllClients() {
    return _usersCollection
        .where('rol', isEqualTo: 'cliente')
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  /// Buscar clientes por nombre
  Stream<List<UserModel>> searchClients(String query) {
    if (query.isEmpty) return getAllClients();

    final queryLower = query.toLowerCase();
    return _usersCollection
        .where('rol', isEqualTo: 'cliente')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .where((user) =>
                user.nombre?.toLowerCase().contains(queryLower) ?? false)
            .toList());
  }

  /// Actualizar datos del cliente
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _usersCollection.doc(uid).update(data);
  }

  /// Limpiar rutina asignada del cliente (después de completar entrenamiento)
  Future<void> clearAssignedRoutine(String uid) async {
    await _usersCollection.doc(uid).update({
      'rutinaAsignadaId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============ MACHINES ============

  /// Obtener todas las máquinas
  Stream<List<MachineModel>> getAllMachines() {
    return _machinesCollection.orderBy('nombre').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => MachineModel.fromFirestore(doc)).toList());
  }

  /// Obtener máquinas por categoría
  Stream<List<MachineModel>> getMachinesByCategory(MachineCategory category) {
    return _machinesCollection
        .where('categoria', isEqualTo: category.value)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MachineModel.fromFirestore(doc))
            .toList());
  }

  /// Obtener máquina por ID
  Future<MachineModel?> getMachine(String id) async {
    final doc = await _machinesCollection.doc(id).get();
    if (!doc.exists) return null;
    return MachineModel.fromFirestore(doc);
  }

  /// Guardar máquina
  Future<void> saveMachine(MachineModel machine) async {
    await _machinesCollection.doc(machine.id).set(machine.toFirestore());
  }

  /// Actualizar máquina
  Future<void> updateMachine(String id, MachineModel machine) async {
    await _machinesCollection.doc(id).set(
      machine.toFirestore(),
      SetOptions(merge: true),
    );
  }

  /// Guardar múltiples máquinas (para migración)
  Future<void> saveMachinesBatch(List<MachineModel> machines) async {
    final batch = _firestore.batch();
    for (final machine in machines) {
      batch.set(_machinesCollection.doc(machine.id), machine.toFirestore());
    }
    await batch.commit();
  }

  // ============ ROUTINES ============

  /// Obtener todas las rutinas
  Stream<List<RoutineModel>> getAllRoutines() {
    return _routinesCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => RoutineModel.fromFirestore(doc)).toList());
  }

  /// Obtener rutinas ordenadas por dificultad
  Stream<List<RoutineModel>> getRoutinesByDifficulty() {
    return _routinesCollection.snapshots().map((snapshot) {
      final routines = snapshot.docs
          .map((doc) => RoutineModel.fromFirestore(doc))
          .toList();
      routines.sort((a, b) => a.dificultad.order.compareTo(b.dificultad.order));
      return routines;
    });
  }

  /// Obtener rutinas por parte del cuerpo
  Stream<List<RoutineModel>> getRoutinesByBodyPart(RoutineBodyPart bodyPart) {
    return _routinesCollection
        .where('parteDelCuerpo', isEqualTo: bodyPart.value)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoutineModel.fromFirestore(doc))
            .toList());
  }

  /// Obtener rutinas por género
  Stream<List<RoutineModel>> getRoutinesByGender(RoutineGender gender) {
    return _routinesCollection
        .where('genero', whereIn: [gender.value, 'unisex'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoutineModel.fromFirestore(doc))
            .toList());
  }

  /// Obtener rutinas filtradas
  Stream<List<RoutineModel>> getFilteredRoutines({
    RoutineBodyPart? bodyPart,
    RoutineDifficulty? difficulty,
    RoutineGender? gender,
  }) {
    Query<Map<String, dynamic>> query = _routinesCollection;

    if (bodyPart != null) {
      query = query.where('parteDelCuerpo', isEqualTo: bodyPart.value);
    }

    if (difficulty != null) {
      query = query.where('dificultad', isEqualTo: difficulty.value);
    }

    if (gender != null) {
      query = query.where('genero', whereIn: [gender.value, 'unisex']);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => RoutineModel.fromFirestore(doc)).toList());
  }

  /// Obtener plantillas de rutinas
  Stream<List<RoutineModel>> getRoutineTemplates() {
    return _routinesCollection
        .where('esPlantilla', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoutineModel.fromFirestore(doc))
            .toList());
  }

  /// Obtener rutina por ID
  Future<RoutineModel?> getRoutine(String id) async {
    final doc = await _routinesCollection.doc(id).get();
    if (!doc.exists) return null;
    return RoutineModel.fromFirestore(doc);
  }

  /// Guardar rutina
  Future<String> saveRoutine(RoutineModel routine) async {
    if (routine.id.isEmpty) {
      final doc = await _routinesCollection.add(routine.toFirestore());
      return doc.id;
    } else {
      await _routinesCollection.doc(routine.id).set(routine.toFirestore());
      return routine.id;
    }
  }

  /// Eliminar rutina
  Future<void> deleteRoutine(String id) async {
    await _routinesCollection.doc(id).delete();
  }

  /// Duplicar rutina
  Future<String> duplicateRoutine(String id, String newName) async {
    final original = await getRoutine(id);
    if (original == null) throw Exception('Rutina no encontrada');

    final copy = original.copyWith(
      id: '',
      nombre: newName,
      esPlantilla: false,
    );
    return saveRoutine(copy);
  }

  /// Guardar múltiples rutinas (para migración)
  Future<void> saveRoutinesBatch(List<RoutineModel> routines) async {
    final batch = _firestore.batch();
    for (final routine in routines) {
      if (routine.id.isEmpty) {
        final doc = _routinesCollection.doc();
        batch.set(doc, routine.toFirestore());
      } else {
        batch.set(_routinesCollection.doc(routine.id), routine.toFirestore());
      }
    }
    await batch.commit();
  }

  // ============ WEEKLY ROUTINES ============

  /// Obtener rutina semanal de un cliente
  Future<WeeklyRoutine?> getWeeklyRoutine(String clienteId) async {
    final query = await _weeklyRoutinesCollection
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return WeeklyRoutine.fromFirestore(query.docs.first);
  }

  /// Stream de rutina semanal
  Stream<WeeklyRoutine?> weeklyRoutineStream(String clienteId) {
    return _weeklyRoutinesCollection
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return WeeklyRoutine.fromFirestore(snapshot.docs.first);
    });
  }

  /// Guardar rutina semanal
  Future<void> saveWeeklyRoutine(WeeklyRoutine weeklyRoutine) async {
    if (weeklyRoutine.id.isEmpty) {
      await _weeklyRoutinesCollection.add(weeklyRoutine.toFirestore());
    } else {
      await _weeklyRoutinesCollection
          .doc(weeklyRoutine.id)
          .set(weeklyRoutine.toFirestore());
    }
  }

  /// Asignar rutina a un día específico
  Future<void> assignRoutineToDay(
    String clienteId,
    int diaSemana,
    String rutinaId,
    String trainerId,
  ) async {
    final existing = await getWeeklyRoutine(clienteId);
    final dayField = _getDayField(diaSemana);

    if (existing != null) {
      await _weeklyRoutinesCollection.doc(existing.id).update({
        dayField: rutinaId,
      });
    } else {
      // Calcular fechas de expiración para nuevas rutinas semanales
      final now = DateTime.now();
      final weekStartDate = _getStartOfWeek(now);
      final expiresAt = weekStartDate.add(const Duration(days: 7));

      await _weeklyRoutinesCollection.add({
        'clienteId': clienteId,
        dayField: rutinaId,
        'createdAt': FieldValue.serverTimestamp(),
        'creadoPor': trainerId,
        'weekStartDate': Timestamp.fromDate(weekStartDate),
        'expiresAt': Timestamp.fromDate(expiresAt),
      });
    }
  }

  /// Set weekly routine (can set multiple days at once)
  Future<void> setWeeklyRoutine(
    String clienteId,
    Map<String, dynamic> routineData,
  ) async {
    final existing = await getWeeklyRoutine(clienteId);

    // Ensure clienteId is in the data
    routineData['clienteId'] = clienteId;

    if (existing != null) {
      // Update existing weekly routine
      await _weeklyRoutinesCollection.doc(existing.id).update(routineData);
    } else {
      // Create new weekly routine with expiration dates
      final now = DateTime.now();
      final weekStartDate = _getStartOfWeek(now);
      final expiresAt = weekStartDate.add(const Duration(days: 7));

      routineData['createdAt'] = FieldValue.serverTimestamp();
      routineData['weekStartDate'] = Timestamp.fromDate(weekStartDate);
      routineData['expiresAt'] = Timestamp.fromDate(expiresAt);
      await _weeklyRoutinesCollection.add(routineData);
    }
  }

  /// Obtener el inicio de la semana (lunes) para una fecha dada
  DateTime _getStartOfWeek(DateTime date) {
    // weekday: 1 = Monday, 7 = Sunday
    final daysToSubtract = date.weekday - 1;
    final monday = date.subtract(Duration(days: daysToSubtract));
    return DateTime(monday.year, monday.month, monday.day);
  }

  String _getDayField(int diaSemana) {
    switch (diaSemana) {
      case 1:
        return 'lunes';
      case 2:
        return 'martes';
      case 3:
        return 'miercoles';
      case 4:
        return 'jueves';
      case 5:
        return 'viernes';
      case 6:
        return 'sabado';
      case 7:
        return 'domingo';
      default:
        return 'lunes';
    }
  }

  // ============ HISTORY ============

  /// Obtener historial de un cliente
  Stream<List<TrainingHistory>> getClientHistory(String clienteId) {
    return _historyCollection
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrainingHistory.fromFirestore(doc))
            .toList());
  }

  /// Obtener historial limitado
  Future<List<TrainingHistory>> getClientHistoryLimited(
    String clienteId,
    int limit,
  ) async {
    final query = await _historyCollection
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fecha', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => TrainingHistory.fromFirestore(doc))
        .toList();
  }

  /// Agregar entrada al historial
  Future<void> addTrainingHistory(TrainingHistory history) async {
    await _historyCollection.add(history.toFirestore());

    // Actualizar último entrenamiento del cliente
    await _usersCollection.doc(history.clienteId).update({
      'fechaUltimoEntrenamiento': Timestamp.fromDate(history.fecha),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Actualizar racha de entrenamiento del usuario
  Future<void> updateStreak(String userId) async {
    final user = await getUser(userId);
    if (user == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Si no hay fecha de último entrenamiento, iniciar racha en 1
    if (user.fechaUltimoEntrenamiento == null) {
      await _usersCollection.doc(userId).update({
        'rachasDias': 1,
        'fechaUltimoEntrenamiento': Timestamp.fromDate(now),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final lastWorkout = DateTime(
      user.fechaUltimoEntrenamiento!.year,
      user.fechaUltimoEntrenamiento!.month,
      user.fechaUltimoEntrenamiento!.day,
    );

    final daysDifference = today.difference(lastWorkout).inDays;

    int newStreak;
    if (daysDifference == 0) {
      // Mismo día - no incrementar racha
      newStreak = user.rachasDias;
    } else if (daysDifference == 1) {
      // Día consecutivo - incrementar racha
      newStreak = user.rachasDias + 1;
    } else {
      // Más de 24 horas - resetear racha a 1
      newStreak = 1;
    }

    await _usersCollection.doc(userId).update({
      'rachasDias': newStreak,
      'fechaUltimoEntrenamiento': Timestamp.fromDate(now),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Obtener progreso de peso del cliente
  Future<List<Map<String, dynamic>>> getWeightProgress(String clienteId) async {
    final user = await getUser(clienteId);
    if (user == null) return [];

    // Aquí podríamos agregar una colección separada para tracking de peso
    // Por ahora retornamos peso inicial y actual
    return [
      if (user.pesoInicial != null)
        {
          'fecha': user.createdAt ?? DateTime.now(),
          'peso': user.pesoInicial,
        },
      if (user.peso != null)
        {
          'fecha': DateTime.now(),
          'peso': user.peso,
        },
    ];
  }

  // ============ TRAINERS ============

  /// Agregar email de entrenador
  Future<void> addTrainer(String email) async {
    await _trainersCollection.doc(email.toLowerCase()).set({
      'email': email.toLowerCase(),
      'activo': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remover email de entrenador
  Future<void> removeTrainer(String email) async {
    await _trainersCollection.doc(email.toLowerCase()).update({
      'activo': false,
    });
  }

  /// Obtener todos los entrenadores (usuarios con rol entrenador o admin)
  Future<List<UserModel>> getTrainers() async {
    final query = await _usersCollection
        .where('rol', whereIn: ['entrenador', 'admin'])
        .orderBy('nombre')
        .get();

    return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Actualizar rol de un usuario
  Future<void> updateUserRole(String uid, UserRole newRole) async {
    await _usersCollection.doc(uid).update({
      'rol': newRole.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Buscar usuario por email
  Future<UserModel?> getUserByEmail(String email) async {
    final query = await _usersCollection
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return UserModel.fromFirestore(query.docs.first);
  }

  /// Convertir múltiples usuarios a entrenadores por email
  /// Retorna un mapa con el resultado de cada email
  Future<Map<String, String>> makeUsersTrainers(List<String> emails) async {
    final results = <String, String>{};

    for (final email in emails) {
      try {
        final query = await _usersCollection
            .where('email', isEqualTo: email.toLowerCase())
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          // Intentar buscar sin toLowerCase
          final query2 = await _usersCollection
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (query2.docs.isEmpty) {
            results[email] = 'No encontrado';
            continue;
          }

          await query2.docs.first.reference.update({
            'rol': 'entrenador',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          results[email] = 'Actualizado a entrenador';
          continue;
        }

        final currentRole = query.docs.first.data()['rol'] as String?;
        if (currentRole == 'entrenador') {
          results[email] = 'Ya es entrenador';
          continue;
        }

        await query.docs.first.reference.update({
          'rol': 'entrenador',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        results[email] = 'Actualizado a entrenador (antes: $currentRole)';
      } catch (e) {
        results[email] = 'Error: $e';
      }
    }

    return results;
  }

  // ============ NOTIFICATIONS ============

  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      _firestore.collection('notifications');

  /// Enviar solicitud de ayuda al entrenador
  Future<void> sendCoachHelpRequest({
    required String trainerId,
    required String clientId,
    required String clientName,
    required String exerciseName,
    required String routineName,
  }) async {
    // Guardar notificación en Firestore
    await _notificationsCollection.add({
      'tipo': 'ayuda_ejercicio',
      'entrenadorId': trainerId,
      'clienteId': clientId,
      'clienteNombre': clientName,
      'ejercicioNombre': exerciseName,
      'rutinaNombre': routineName,
      'leido': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Enviar notificación push al entrenador
    try {
      final trainerDoc = await _usersCollection.doc(trainerId).get();
      final fcmToken = trainerDoc.data()?['fcmToken'] as String?;

      if (fcmToken != null) {
        // Crear notificación push para que Cloud Functions la procese
        await _firestore.collection('push_notifications').add({
          'to': fcmToken,
          'notification': {
            'title': '🆘 Solicitud de Ayuda',
            'body': '$clientName necesita ayuda con: $exerciseName',
          },
          'data': {
            'tipo': 'ayuda_ejercicio',
            'clienteId': clientId,
            'clienteNombre': clientName,
            'ejercicioNombre': exerciseName,
            'rutinaNombre': routineName,
          },
          'priority': 'high',
          'createdAt': FieldValue.serverTimestamp(),
          'processed': false,
        });
      }
    } catch (e) {
      // Si falla el push, al menos la notificación en Firestore se guardó
      print('⚠️ No se pudo enviar notificación push: $e');
    }
  }

  /// Obtener notificaciones del entrenador (solicitudes de ayuda)
  Stream<List<Map<String, dynamic>>> getTrainerHelpNotifications(String trainerId) {
    return _notificationsCollection
        .where('entrenadorId', isEqualTo: trainerId)
        .where('leido', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'tipo': data['tipo'] ?? 'ayuda', // Usar tipo del documento o 'ayuda' por defecto
                ...data,
              };
            })
            .toList());
  }

  /// Obtener notificaciones de pedidos nuevos (para todos los entrenadores)
  Stream<List<Map<String, dynamic>>> getOrderNotifications() {
    return _notificationsCollection
        .where('tipo', isEqualTo: 'nuevo_pedido')
        .where('leido', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// Obtener solicitudes de rutina pendientes (para cualquier entrenador)
  Stream<List<Map<String, dynamic>>> getTrainerRoutineRequests() {
    return _routineRequestsCollection
        .where('estado', isEqualTo: 'pendiente')
        .orderBy('fechaSolicitud', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'tipo': 'rutina', // Tipo de notificación
                  ...doc.data(),
                })
            .toList());
  }

  /// Obtener TODAS las notificaciones del entrenador (ayuda + solicitudes de rutina + pedidos)
  Stream<List<Map<String, dynamic>>> getTrainerNotifications(String trainerId) {
    // Combinar múltiples streams: solicitudes de ayuda, rutinas y pedidos
    return getTrainerHelpNotifications(trainerId).asyncMap((helpNotifications) async {
      // Obtener solicitudes de rutina pendientes
      final routineSnapshot = await _routineRequestsCollection
          .where('estado', isEqualTo: 'pendiente')
          .orderBy('fechaSolicitud', descending: true)
          .limit(50)
          .get();

      final routineRequests = routineSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'tipo': 'rutina',
          ...data,
          // Convertir Timestamp a DateTime para ordenamiento consistente
          'createdAt': data['fechaSolicitud'],
        };
      }).toList();

      // Obtener notificaciones de pedidos nuevos
      final ordersSnapshot = await _notificationsCollection
          .where('tipo', isEqualTo: 'nuevo_pedido')
          .where('leido', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final orderNotifications = ordersSnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();

      // Combinar y ordenar por fecha
      final allNotifications = [...helpNotifications, ...routineRequests, ...orderNotifications];
      allNotifications.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime); // Más reciente primero
      });

      return allNotifications;
    });
  }

  /// Marcar notificación como leída
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      // Primero intentar en la colección notifications
      final notificationDoc = await _notificationsCollection.doc(notificationId).get();

      if (notificationDoc.exists) {
        await _notificationsCollection.doc(notificationId).update({
          'leido': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Si no existe en notifications, podría ser una solicitud de rutina
        final routineDoc = await _routineRequestsCollection.doc(notificationId).get();

        if (routineDoc.exists) {
          // Para solicitudes de rutina, agregar campo leido
          await _routineRequestsCollection.doc(notificationId).update({
            'leido': true,
          });
        }
      }
    } catch (e) {
      print('❌ Error marcando notificación como leída $notificationId: $e');
    }
  }

  /// Eliminar notificación
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Primero intentar obtener el documento de notifications
      final notificationDoc = await _notificationsCollection.doc(notificationId).get();

      if (notificationDoc.exists) {
        // Si existe en notifications, eliminarlo de ahí
        await _notificationsCollection.doc(notificationId).delete();
        print('✅ Notificación eliminada de notifications: $notificationId');
      } else {
        // Si no existe en notifications, verificar si es una solicitud de rutina
        final routineDoc = await _routineRequestsCollection.doc(notificationId).get();

        if (routineDoc.exists) {
          // Si existe en routine_requests, marcarla como rechazada o eliminarla
          await _routineRequestsCollection.doc(notificationId).update({
            'estado': 'rechazada',
            'fechaRechazo': FieldValue.serverTimestamp(),
          });
          print('✅ Solicitud de rutina rechazada: $notificationId');
        } else {
          print('⚠️ Notificación no encontrada: $notificationId');
        }
      }
    } catch (e) {
      print('❌ Error eliminando notificación $notificationId: $e');
      rethrow;
    }
  }

  /// Contar notificaciones no leídas
  Stream<int> getUnreadNotificationsCount(String trainerId) {
    return _notificationsCollection
        .where('entrenadorId', isEqualTo: trainerId)
        .where('leido', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ============ MIGRATION ============

  /// Verificar si las colecciones están vacías
  Future<bool> isMachinesCollectionEmpty() async {
    final snapshot = await _machinesCollection.limit(1).get();
    return snapshot.docs.isEmpty;
  }

  Future<bool> isRoutinesCollectionEmpty() async {
    final snapshot = await _routinesCollection.limit(1).get();
    return snapshot.docs.isEmpty;
  }

  // ============ DATA CLEANUP (Cost Prevention) ============

  /// Limpiar datos antiguos para mantenerse dentro del plan gratuito de Firebase
  /// Esta función debe ser llamada automáticamente en el login del usuario
  Future<void> cleanupOldData() async {
    try {
      print('🧹 [CLEANUP] Iniciando limpieza de datos antiguos...');

      // 1. Limpiar historial de entrenamientos > 365 días
      await _cleanupOldTrainingHistory();

      // 2. Limpiar rutinas semanales expiradas > 30 días
      await _cleanupExpiredWeeklyRoutines();

      print('✅ [CLEANUP] Limpieza completada exitosamente');
    } catch (e) {
      print('❌ [CLEANUP] Error durante la limpieza: $e');
      // No lanzamos error para no interrumpir el flujo del login
    }
  }

  /// Eliminar historial de entrenamientos con más de 1 año de antigüedad
  Future<void> _cleanupOldTrainingHistory() async {
    try {
      // Calcular fecha límite (hace 365 días)
      final cutoffDate = DateTime.now().subtract(const Duration(days: 365));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      print('🧹 [CLEANUP] Buscando entrenamientos antes de: ${cutoffDate.toString()}');

      // Buscar documentos antiguos (limitamos a 100 por lote para evitar problemas)
      final oldDocs = await _historyCollection
          .where('fecha', isLessThan: cutoffTimestamp)
          .limit(100)
          .get();

      if (oldDocs.docs.isEmpty) {
        print('✅ [CLEANUP] No hay entrenamientos antiguos para eliminar');
        return;
      }

      // Eliminar en batch para eficiencia
      final batch = _firestore.batch();
      for (final doc in oldDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('✅ [CLEANUP] Eliminados ${oldDocs.docs.length} entrenamientos antiguos');
    } catch (e) {
      print('❌ [CLEANUP] Error al limpiar historial: $e');
    }
  }

  /// Eliminar rutinas semanales expiradas con más de 30 días
  Future<void> _cleanupExpiredWeeklyRoutines() async {
    try {
      // Calcular fecha límite (hace 30 días desde su expiración)
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      print('🧹 [CLEANUP] Buscando rutinas semanales expiradas antes de: ${cutoffDate.toString()}');

      // Buscar rutinas expiradas (limitamos a 100 por lote)
      final expiredDocs = await _weeklyRoutinesCollection
          .where('expiresAt', isLessThan: cutoffTimestamp)
          .limit(100)
          .get();

      if (expiredDocs.docs.isEmpty) {
        print('✅ [CLEANUP] No hay rutinas semanales expiradas para eliminar');
        return;
      }

      // Eliminar en batch
      final batch = _firestore.batch();
      for (final doc in expiredDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('✅ [CLEANUP] Eliminadas ${expiredDocs.docs.length} rutinas semanales expiradas');
    } catch (e) {
      print('❌ [CLEANUP] Error al limpiar rutinas semanales: $e');
    }
  }

  // ============ HELPER: Asegurar campos de expiración en rutinas semanales ============

  /// Actualizar rutina semanal existente con campos de expiración si no los tiene
  Future<void> ensureWeeklyRoutineExpiration(String weeklyRoutineId) async {
    try {
      final doc = await _weeklyRoutinesCollection.doc(weeklyRoutineId).get();
      if (!doc.exists) return;

      final data = doc.data();
      if (data == null) return;

      // Si ya tiene expiresAt, no hacer nada
      if (data['expiresAt'] != null) return;

      // Calcular weekStartDate y expiresAt
      DateTime weekStartDate;
      if (data['weekStartDate'] != null) {
        weekStartDate = (data['weekStartDate'] as Timestamp).toDate();
      } else if (data['createdAt'] != null) {
        weekStartDate = (data['createdAt'] as Timestamp).toDate();
      } else {
        weekStartDate = DateTime.now();
      }

      final expiresAt = weekStartDate.add(const Duration(days: 7));

      // Actualizar documento
      await _weeklyRoutinesCollection.doc(weeklyRoutineId).update({
        'weekStartDate': Timestamp.fromDate(weekStartDate),
        'expiresAt': Timestamp.fromDate(expiresAt),
      });

      print('✅ [CLEANUP] Campos de expiración agregados a rutina semanal: $weeklyRoutineId');
    } catch (e) {
      print('❌ [CLEANUP] Error al agregar campos de expiración: $e');
    }
  }

  // ============ ROUTINE REQUESTS ============

  /// Crear solicitud de rutina
  Future<String> createRoutineRequest(RoutineRequestModel request) async {
    final docRef = await _routineRequestsCollection.add(request.toFirestore());
    return docRef.id;
  }

  /// Stream de todas las solicitudes pendientes (para el coach)
  Stream<List<RoutineRequestModel>> routineRequestsStream() {
    return _routineRequestsCollection
        .orderBy('fechaSolicitud', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoutineRequestModel.fromFirestore(doc))
            .toList());
  }

  /// Stream de solicitudes de un cliente específico
  Stream<List<RoutineRequestModel>> clientRoutineRequestsStream(
      String clienteId) {
    return _routineRequestsCollection
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fechaSolicitud', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoutineRequestModel.fromFirestore(doc))
            .toList());
  }

  /// Actualizar estado de solicitud de rutina
  Future<void> updateRoutineRequest(
      String requestId, Map<String, dynamic> updates) async {
    await _routineRequestsCollection.doc(requestId).update(updates);
  }

  /// Marcar solicitud como asignada
  Future<void> markRoutineRequestAsAssigned(
    String requestId,
    String rutinaAsignadaId,
    String? nota,
  ) async {
    await _routineRequestsCollection.doc(requestId).update({
      'estado': RequestStatus.asignada.name,
      'rutinaAsignadaId': rutinaAsignadaId,
      'respuestaNota': nota,
      'fechaRespuesta': FieldValue.serverTimestamp(),
    });
  }

  /// Eliminar solicitud de rutina
  Future<void> deleteRoutineRequest(String requestId) async {
    await _routineRequestsCollection.doc(requestId).delete();
  }

  // ============ STORE ORDERS ============

  /// Crear pedido de tienda
  Future<String> createStoreOrder(StoreOrderModel order) async {
    final docRef = await _storeOrdersCollection.add(order.toFirestore());
    final orderId = docRef.id;

    // Enviar notificación a todos los entrenadores
    try {
      await _notifyTrainersAboutNewOrder(orderId, order);
    } catch (e) {
      // Si falla la notificación, el pedido ya se guardó
      print('⚠️ No se pudo notificar a entrenadores: $e');
    }

    return orderId;
  }

  /// Notificar a todos los entrenadores sobre un nuevo pedido
  Future<void> _notifyTrainersAboutNewOrder(String orderId, StoreOrderModel order) async {
    // Obtener todos los usuarios con rol entrenador o admin que tengan fcmToken
    final trainersQuery = await _usersCollection
        .where('rol', whereIn: ['entrenador', 'admin'])
        .get();

    // Crear notificación en la colección de notificaciones
    await _notificationsCollection.add({
      'tipo': 'nuevo_pedido',
      'orderId': orderId,
      'clienteId': order.clienteId,
      'clienteNombre': order.clienteNombre,
      'total': order.total,
      'itemsCount': order.items.length,
      'leido': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Enviar push notification a cada entrenador
    for (final trainerDoc in trainersQuery.docs) {
      final data = trainerDoc.data();
      final fcmToken = data['fcmToken'] as String?;
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await _firestore.collection('push_notifications').add({
          'to': fcmToken,
          'notification': {
            'title': '🛒 Nuevo Pedido',
            'body': '${order.clienteNombre} realizó un pedido por \$${order.total.toStringAsFixed(2)} MXN',
          },
          'data': {
            'tipo': 'nuevo_pedido',
            'orderId': orderId,
            'clienteId': order.clienteId,
            'clienteNombre': order.clienteNombre,
            'total': order.total.toString(),
          },
          'priority': 'high',
          'createdAt': FieldValue.serverTimestamp(),
          'processed': false,
        });
      }
    }
  }

  /// Stream de todos los pedidos (para el coach)
  Stream<List<StoreOrderModel>> storeOrdersStream() {
    return _storeOrdersCollection
        .orderBy('fechaPedido', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoreOrderModel.fromFirestore(doc))
            .toList());
  }

  /// Stream de pedidos de un cliente específico
  Stream<List<StoreOrderModel>> clientStoreOrdersStream(String clienteId) {
    return _storeOrdersCollection
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fechaPedido', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoreOrderModel.fromFirestore(doc))
            .toList());
  }

  /// Stream de pedidos pendientes (sin entregar)
  Stream<List<StoreOrderModel>> pendingStoreOrdersStream() {
    return _storeOrdersCollection
        .where('estado',
            whereIn: [OrderStatus.pendiente.name, OrderStatus.listo.name])
        .orderBy('fechaPedido', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoreOrderModel.fromFirestore(doc))
            .toList());
  }

  /// Actualizar estado del pedido
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final updates = <String, dynamic>{
      'estado': newStatus.name,
    };

    if (newStatus == OrderStatus.listo) {
      updates['fechaListo'] = FieldValue.serverTimestamp();
    } else if (newStatus == OrderStatus.entregado) {
      updates['fechaEntregado'] = FieldValue.serverTimestamp();
    }

    await _storeOrdersCollection.doc(orderId).update(updates);
  }

  /// Marcar pedido como listo
  Future<void> markOrderAsReady(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.listo);
  }

  /// Marcar pedido como entregado
  Future<void> markOrderAsDelivered(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.entregado);
  }

  // ============ CLEANUP: STORE ORDERS ============

  /// Eliminar pedidos entregados con más de 7 días
  Future<void> _cleanupDeliveredOrders() async {
    try {
      // Calcular fecha límite (hace 7 días)
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      print('🧹 [CLEANUP] Buscando pedidos entregados antes de: ${cutoffDate.toString()}');

      // Buscar pedidos entregados antiguos (limitamos a 100 por lote)
      final deliveredDocs = await _storeOrdersCollection
          .where('estado', isEqualTo: OrderStatus.entregado.name)
          .where('fechaEntregado', isLessThan: cutoffTimestamp)
          .limit(100)
          .get();

      if (deliveredDocs.docs.isEmpty) {
        print('✅ [CLEANUP] No hay pedidos entregados antiguos para eliminar');
        return;
      }

      // Eliminar en batch
      final batch = _firestore.batch();
      for (final doc in deliveredDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('✅ [CLEANUP] Eliminados ${deliveredDocs.docs.length} pedidos entregados antiguos');
    } catch (e) {
      print('❌ [CLEANUP] Error al limpiar pedidos entregados: $e');
    }
  }

  // ============ CLEANUP: ROUTINE REQUESTS ============

  /// Eliminar solicitudes de rutina completadas con más de 30 días
  Future<void> _cleanupCompletedRoutineRequests() async {
    try {
      // Calcular fecha límite (hace 30 días)
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      print('🧹 [CLEANUP] Buscando solicitudes completadas antes de: ${cutoffDate.toString()}');

      // Buscar solicitudes completadas antiguas (limitamos a 100 por lote)
      final completedDocs = await _routineRequestsCollection
          .where('estado', isEqualTo: RequestStatus.asignada.name)
          .where('fechaRespuesta', isLessThan: cutoffTimestamp)
          .limit(100)
          .get();

      if (completedDocs.docs.isEmpty) {
        print('✅ [CLEANUP] No hay solicitudes completadas antiguas para eliminar');
        return;
      }

      // Eliminar en batch
      final batch = _firestore.batch();
      for (final doc in completedDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('✅ [CLEANUP] Eliminadas ${completedDocs.docs.length} solicitudes completadas antiguas');
    } catch (e) {
      print('❌ [CLEANUP] Error al limpiar solicitudes de rutina: $e');
    }
  }

  // ============ CLEANUP COORDINATOR ============

  /// Ejecutar todas las tareas de limpieza
  Future<void> runCleanupTasks() async {
    print('🧹 [CLEANUP] Iniciando limpieza de datos...');

    await Future.wait([
      _cleanupExpiredWeeklyRoutines(),
      _cleanupDeliveredOrders(),
      _cleanupCompletedRoutineRequests(),
    ]);

    print('✅ [CLEANUP] Limpieza completada');
  }

  // ============ PRODUCTS ============

  /// Obtener todos los productos (stream)
  Stream<List<ProductModel>> getAllProducts() {
    return _productsCollection
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
      // Sort in-memory by category and name to avoid composite index
      products.sort((a, b) {
        final categoryComparison = a.category.displayName.compareTo(b.category.displayName);
        if (categoryComparison != 0) return categoryComparison;
        return a.name.compareTo(b.name);
      });
      return products;
    });
  }

  /// Obtener solo productos activos (stream)
  /// Filtra en memoria para evitar requerir índices compuestos en Firestore
  Stream<List<ProductModel>> getActiveProducts() {
    return _productsCollection.snapshots().map((snapshot) {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((product) => product.isActive)
          .toList();
      // Sort in-memory by category and name
      products.sort((a, b) {
        final categoryComparison =
            a.category.displayName.compareTo(b.category.displayName);
        if (categoryComparison != 0) return categoryComparison;
        return a.name.compareTo(b.name);
      });
      return products;
    });
  }

  /// Obtener productos por categoría (stream)
  /// Filtra en memoria para evitar requerir índices compuestos en Firestore
  Stream<List<ProductModel>> getProductsByCategory(ProductCategory category) {
    return _productsCollection.snapshots().map((snapshot) {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((product) => product.category == category && product.isActive)
          .toList();
      // Sort in-memory by name
      products.sort((a, b) => a.name.compareTo(b.name));
      return products;
    });
  }

  /// Obtener un producto específico
  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _productsCollection.doc(productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }

  /// Crear nuevo producto
  Future<String> createProduct(ProductModel product) async {
    final now = DateTime.now();
    final docRef = _productsCollection.doc();

    final newProduct = product.copyWith(
      id: docRef.id,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(newProduct.toFirestore());
    print('✅ [PRODUCTS] Producto creado: ${newProduct.name} (${docRef.id})');
    return docRef.id;
  }

  /// Actualizar producto existente
  Future<void> updateProduct(String productId, ProductModel product) async {
    final updatedProduct = product.copyWith(
      id: productId,
      updatedAt: DateTime.now(),
    );

    await _productsCollection.doc(productId).set(
          updatedProduct.toFirestore(),
          SetOptions(merge: true),
        );
    print('✅ [PRODUCTS] Producto actualizado: ${product.name}');
  }

  /// Eliminar producto
  Future<void> deleteProduct(String productId) async {
    await _productsCollection.doc(productId).delete();
    print('✅ [PRODUCTS] Producto eliminado: $productId');
  }

  /// Activar/Desactivar producto
  Future<void> toggleProductStatus(String productId, bool isActive) async {
    await _productsCollection.doc(productId).update({
      'isActive': isActive,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    print('✅ [PRODUCTS] Producto ${isActive ? "activado" : "desactivado"}: $productId');
  }

  /// Actualizar stock del producto
  Future<void> updateProductStock(String productId, int newStock) async {
    await _productsCollection.doc(productId).update({
      'stock': newStock,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    print('✅ [PRODUCTS] Stock actualizado para producto $productId: $newStock');
  }

  /// Migrar productos existentes para agregar campos faltantes
  Future<Map<String, int>> migrateProducts() async {
    int updated = 0;
    int errors = 0;
    int skipped = 0;

    try {
      final snapshot = await _productsCollection.get();

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final updates = <String, dynamic>{};

          // Agregar campo 'displayed' si no existe
          if (!data.containsKey('displayed')) {
            updates['displayed'] = true;
          }

          // Agregar campo 'imagen' si no existe (usar imageUrl)
          if (!data.containsKey('imagen')) {
            final imageUrl = data['imageUrl'] as String? ?? '';
            updates['imagen'] = imageUrl;
          }

          // Agregar 'imageUrl' si no existe (usar imagen)
          if (!data.containsKey('imageUrl') && data.containsKey('imagen')) {
            updates['imageUrl'] = data['imagen'];
          }

          // Asegurar que existe 'isActive'
          if (!data.containsKey('isActive')) {
            updates['isActive'] = true;
          }

          // Asegurar que existe 'stock'
          if (!data.containsKey('stock')) {
            updates['stock'] = 0;
          }

          // Actualizar si hay cambios
          if (updates.isNotEmpty) {
            updates['updatedAt'] = FieldValue.serverTimestamp();
            await doc.reference.update(updates);
            updated++;
          } else {
            skipped++;
          }
        } catch (e) {
          print('❌ [MIGRATION] Error en producto ${doc.id}: $e');
          errors++;
        }
      }

      print('✅ [MIGRATION] Migración completada: $updated actualizados, $skipped sin cambios, $errors errores');
      return {'updated': updated, 'skipped': skipped, 'errors': errors};
    } catch (e) {
      print('❌ [MIGRATION] Error fatal: $e');
      rethrow;
    }
  }

  /// Buscar productos por nombre
  Stream<List<ProductModel>> searchProducts(String query) {
    if (query.isEmpty) {
      return getActiveProducts();
    }

    final lowerQuery = query.toLowerCase();
    return getActiveProducts().map((products) {
      return products.where((product) {
        return product.name.toLowerCase().contains(lowerQuery) ||
            product.description.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  /// Seed de productos de ejemplo (para desarrollo)
  Future<Map<String, int>> seedProducts() async {
    int created = 0;
    int errors = 0;

    final products = [
      // BEBIDAS
      ProductModel(
        id: '',
        name: 'Proteína Whey 2kg',
        description: 'Proteína de suero de leche de alta calidad, sabor chocolate',
        price: 899.00,
        imageUrl: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=800&q=80',
        category: ProductCategory.bebidas,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stock: 25,
        displayed: true,
      ),
      ProductModel(
        id: '',
        name: 'Creatina Monohidrato 300g',
        description: 'Creatina pura micronizada, sin sabor',
        price: 349.00,
        imageUrl: 'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=800&q=80',
        category: ProductCategory.bebidas,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stock: 30,
        displayed: true,
      ),
      ProductModel(
        id: '',
        name: 'Pre-Entreno Energía',
        description: 'Pre-entreno con cafeína y beta-alanina, sabor frutas',
        price: 549.00,
        imageUrl: 'https://images.unsplash.com/photo-1617885901257-4e6d2f6e93d9?w=800&q=80',
        category: ProductCategory.bebidas,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stock: 20,
        displayed: true,
      ),
      // SUPLEMENTOS
      ProductModel(
        id: '',
        name: 'Multivitamínico Completo',
        description: 'Vitaminas y minerales esenciales, 60 cápsulas',
        price: 299.00,
        imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&q=80',
        category: ProductCategory.suplementos,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stock: 40,
        displayed: true,
      ),
      ProductModel(
        id: '',
        name: 'Omega 3 Fish Oil',
        description: 'Aceite de pescado premium, 90 cápsulas',
        price: 249.00,
        imageUrl: 'https://images.unsplash.com/photo-1550572017-4a2f71a3d66e?w=800&q=80',
        category: ProductCategory.suplementos,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stock: 35,
        displayed: true,
      ),
      // ROPA
      ProductModel(
        id: '',
        name: 'Playera Deportiva Dry-Fit',
        description: 'Playera técnica de secado rápido, varios colores',
        price: 349.00,
        imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&q=80',
        category: ProductCategory.ropa,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stock: 50,
        displayed: true,
      ),
      ProductModel(
        id: '',
        name: 'Short Deportivo',
        description: 'Short ligero con bolsillos, ideal para entrenar',
        price: 399.00,
        imageUrl: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800&q=80',
        category: ProductCategory.ropa,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stock: 45,
        displayed: true,
      ),
      // ACCESORIOS
      ProductModel(
        id: '',
        name: 'Guantes de Gimnasio',
        description: 'Guantes acolchados con muñequeras, talla M/L',
        price: 249.00,
        imageUrl: 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800&q=80',
        category: ProductCategory.accesorios,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stock: 60,
        displayed: true,
      ),
      ProductModel(
        id: '',
        name: 'Cinturón de Levantamiento',
        description: 'Cinturón de powerlifting de cuero genuino',
        price: 899.00,
        imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&q=80',
        category: ProductCategory.accesorios,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stock: 15,
        displayed: true,
      ),
      ProductModel(
        id: '',
        name: 'Shaker Mezclador 700ml',
        description: 'Vaso mezclador con compartimento para suplementos',
        price: 149.00,
        imageUrl: 'https://images.unsplash.com/photo-1625772452859-1c03d5bf1137?w=800&q=80',
        category: ProductCategory.accesorios,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stock: 100,
        displayed: true,
      ),
    ];

    try {
      for (final product in products) {
        try {
          await createProduct(product);
          created++;
        } catch (e) {
          print('❌ [SEED] Error al crear ${product.name}: $e');
          errors++;
        }
      }

      print('✅ [SEED] Productos creados: $created, errores: $errors');
      return {'created': created, 'errors': errors};
    } catch (e) {
      print('❌ [SEED] Error fatal: $e');
      rethrow;
    }
  }

  // ============ ANNOUNCEMENTS ============

  /// Crear anuncio personalizado
  Future<String> createAnnouncement(AnnouncementModel announcement) async {
    final docRef = await _announcementsCollection.add(announcement.toMap());
    print('✅ [ANNOUNCEMENTS] Anuncio creado: ${announcement.titulo} (${docRef.id})');

    // Enviar notificación push a los clientes destinatarios
    await _sendAnnouncementPushNotifications(docRef.id, announcement);

    return docRef.id;
  }

  /// Enviar notificaciones push para un anuncio
  Future<void> _sendAnnouncementPushNotifications(
    String announcementId,
    AnnouncementModel announcement,
  ) async {
    try {
      List<String> targetClientIds = announcement.clientesIds;

      // Si la lista está vacía, enviar a todos los clientes
      if (targetClientIds.isEmpty) {
        final clientsSnapshot = await _usersCollection
            .where('rol', isEqualTo: UserRole.cliente.value)
            .get();
        targetClientIds = clientsSnapshot.docs.map((doc) => doc.id).toList();
      }

      // Enviar notificación push a cada cliente
      for (final clientId in targetClientIds) {
        final userDoc = await _usersCollection.doc(clientId).get();
        final fcmToken = userDoc.data()?['fcmToken'] as String?;

        if (fcmToken != null) {
          await _firestore.collection('push_notifications').add({
            'to': fcmToken,
            'notification': {
              'title': announcement.titulo,
              'body': announcement.mensaje,
            },
            'data': {
              'tipo': 'anuncio',
              'anuncioId': announcementId,
              'tipoAnuncio': announcement.tipo.name,
            },
            'priority': 'high',
            'createdAt': FieldValue.serverTimestamp(),
            'processed': false,
          });
        }
      }

      print('✅ [ANNOUNCEMENTS] Notificaciones push enviadas a ${targetClientIds.length} clientes');
    } catch (e) {
      print('❌ [ANNOUNCEMENTS] Error enviando notificaciones push: $e');
    }
  }

  /// Obtener todos los anuncios activos (para entrenador)
  Stream<List<AnnouncementModel>> getAnnouncementsStream() {
    return _announcementsCollection
        .where('activo', isEqualTo: true)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AnnouncementModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Obtener anuncios para un cliente específico
  Stream<List<AnnouncementModel>> getClientAnnouncementsStream(String clientId) {
    return _announcementsCollection
        .where('activo', isEqualTo: true)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final announcements = snapshot.docs
          .map((doc) => AnnouncementModel.fromFirestore(doc))
          .where((announcement) => announcement.isForClient(clientId))
          .toList();

      // Filtrar anuncios que no han sido eliminados por el cliente
      final filteredAnnouncements = <AnnouncementModel>[];
      for (final announcement in announcements) {
        final status = await _getClientNotificationStatus(clientId, announcement.id);
        if (status == null || !status.eliminado) {
          filteredAnnouncements.add(announcement);
        }
      }

      return filteredAnnouncements;
    });
  }

  /// Obtener estado de notificación del cliente
  Future<ClientNotificationStatus?> _getClientNotificationStatus(
    String clientId,
    String announcementId,
  ) async {
    final query = await _clientNotificationStatusCollection
        .where('clienteId', isEqualTo: clientId)
        .where('anuncioId', isEqualTo: announcementId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return ClientNotificationStatus.fromFirestore(query.docs.first);
  }

  /// Marcar anuncio como leído por cliente
  Future<void> markAnnouncementAsRead(String clientId, String announcementId) async {
    final existingStatus = await _getClientNotificationStatus(clientId, announcementId);

    if (existingStatus != null) {
      await _clientNotificationStatusCollection.doc(existingStatus.id).update({
        'fechaLeido': FieldValue.serverTimestamp(),
      });
    } else {
      await _clientNotificationStatusCollection.add({
        'clienteId': clientId,
        'anuncioId': announcementId,
        'fechaLeido': FieldValue.serverTimestamp(),
        'eliminado': false,
      });
    }
    print('✅ [ANNOUNCEMENTS] Anuncio marcado como leído: $announcementId para cliente $clientId');
  }

  /// Eliminar (ocultar) anuncio para un cliente específico
  Future<void> dismissAnnouncementForClient(String clientId, String announcementId) async {
    final existingStatus = await _getClientNotificationStatus(clientId, announcementId);

    if (existingStatus != null) {
      await _clientNotificationStatusCollection.doc(existingStatus.id).update({
        'eliminado': true,
      });
    } else {
      await _clientNotificationStatusCollection.add({
        'clienteId': clientId,
        'anuncioId': announcementId,
        'fechaLeido': FieldValue.serverTimestamp(),
        'eliminado': true,
      });
    }
    print('✅ [ANNOUNCEMENTS] Anuncio eliminado para cliente: $announcementId');
  }

  /// Actualizar anuncio
  Future<void> updateAnnouncement(String announcementId, AnnouncementModel announcement) async {
    await _announcementsCollection.doc(announcementId).update(announcement.toMap());
    print('✅ [ANNOUNCEMENTS] Anuncio actualizado: ${announcement.titulo}');
  }

  /// Desactivar anuncio
  Future<void> deactivateAnnouncement(String announcementId) async {
    await _announcementsCollection.doc(announcementId).update({
      'activo': false,
    });
    print('✅ [ANNOUNCEMENTS] Anuncio desactivado: $announcementId');
  }

  /// Eliminar anuncio permanentemente
  Future<void> deleteAnnouncement(String announcementId) async {
    await _announcementsCollection.doc(announcementId).delete();

    // Eliminar estados de notificación relacionados
    final statusDocs = await _clientNotificationStatusCollection
        .where('anuncioId', isEqualTo: announcementId)
        .get();

    final batch = _firestore.batch();
    for (final doc in statusDocs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    print('✅ [ANNOUNCEMENTS] Anuncio eliminado: $announcementId');
  }

  /// Contar anuncios no leídos para un cliente
  Stream<int> getUnreadAnnouncementsCount(String clientId) {
    return getClientAnnouncementsStream(clientId).asyncMap((announcements) async {
      int unreadCount = 0;
      for (final announcement in announcements) {
        final status = await _getClientNotificationStatus(clientId, announcement.id);
        if (status == null) {
          unreadCount++;
        }
      }
      return unreadCount;
    });
  }
}
