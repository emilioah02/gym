import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
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

  CollectionReference<Map<String, dynamic>> get _exercisesCollection =>
      _firestore.collection('exercises');

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
        return UserRole.cliente; // Default role
      }

      final data = doc.data();
      if (data == null) {
        return UserRole.cliente;
      }

      final rolString = data['rol'] as String?;
      if (rolString == null) {
        return UserRole.cliente;
      }

      return UserRole.fromString(rolString);
    } catch (e) {
      if (kDebugMode) debugPrint('Error obteniendo rol: $e');
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

  // ============ EXERCISES ============

  /// Obtener todos los ejercicios
  Stream<List<ExerciseModel>> getAllExercises() {
    return _exercisesCollection.orderBy('nombre').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ExerciseModel.fromFirestore(doc)).toList());
  }

  /// Obtener ejercicios por categoría
  Stream<List<ExerciseModel>> getExercisesByCategory(MachineCategory category) {
    return _exercisesCollection
        .where('categoria', isEqualTo: category.value)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExerciseModel.fromFirestore(doc))
            .toList());
  }

  /// Obtener ejercicio por ID
  Future<ExerciseModel?> getExerciseById(String id) async {
    final doc = await _exercisesCollection.doc(id).get();
    if (!doc.exists) return null;
    return ExerciseModel.fromFirestore(doc);
  }

  /// Guardar ejercicio
  Future<void> saveExercise(ExerciseModel exercise) async {
    await _exercisesCollection.doc(exercise.id).set(exercise.toFirestore());
  }

  /// Actualizar ejercicio
  Future<void> updateExercise(String id, ExerciseModel exercise) async {
    await _exercisesCollection.doc(id).set(
      exercise.toFirestore(),
      SetOptions(merge: true),
    );
  }

  /// Eliminar ejercicio
  Future<void> deleteExercise(String id) async {
    await _exercisesCollection.doc(id).delete();
  }

  // ============ ROUTINES ============

  /// Obtener todas las rutinas
  Stream<List<RoutineModel>> getAllRoutines() {
    return _routinesCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => RoutineModel.fromFirestore(doc)).toList());
  }

  /// Obtener todas las rutinas una sola vez (para migración)
  Future<List<RoutineModel>> getAllRoutinesOnce() async {
    final snapshot = await _routinesCollection.get();
    return snapshot.docs.map((doc) => RoutineModel.fromFirestore(doc)).toList();
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

    // Actualizar el campo rutinaAsignadaId del cliente
    final firstRoutineId = weeklyRoutine.lunes ??
        weeklyRoutine.martes ??
        weeklyRoutine.miercoles ??
        weeklyRoutine.jueves ??
        weeklyRoutine.viernes ??
        weeklyRoutine.sabado ??
        weeklyRoutine.domingo;

    if (firstRoutineId != null && weeklyRoutine.clienteId.isNotEmpty) {
      await _usersCollection.doc(weeklyRoutine.clienteId).update({
        'rutinaAsignadaId': firstRoutineId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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

    // Actualizar el campo rutinaAsignadaId del cliente
    await _usersCollection.doc(clienteId).update({
      'rutinaAsignadaId': rutinaId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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

    // Actualizar el campo rutinaAsignadaId del cliente
    // Buscar la primera rutina asignada en los datos
    final days = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
    String? firstRoutineId;
    for (final day in days) {
      if (routineData[day] != null && routineData[day].toString().isNotEmpty) {
        firstRoutineId = routineData[day].toString();
        break;
      }
    }

    if (firstRoutineId != null) {
      await _usersCollection.doc(clienteId).update({
        'rutinaAsignadaId': firstRoutineId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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

  /// Actualiza la racha de días de entrenamiento del usuario.
  ///
  /// Lógica de racha:
  /// - Cuenta días de entrenamiento (no días consecutivos del calendario)
  /// - Permite hasta 2 días de descanso sin resetear la racha
  /// - Si pasan más de 2 días sin entrenar, la racha se resetea a 1
  /// - Si entrena el mismo día, no incrementa (ya contó ese día)
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
      print('🔥 [STREAK] Usuario $userId - Primera racha iniciada: 1');
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
      // Mismo día - no incrementar racha (ya entrenó hoy)
      newStreak = user.rachasDias;
      print('🔥 [STREAK] Usuario $userId - Mismo día, racha se mantiene: $newStreak');
    } else if (daysDifference <= 2) {
      // Hasta 2 días de diferencia - incrementar racha (permite días de descanso)
      // Esto permite: entrenar Lunes, descansar Martes, entrenar Miércoles
      newStreak = user.rachasDias + 1;
      print('🔥 [STREAK] Usuario $userId - Nuevo día de entrenamiento (diferencia: $daysDifference días), racha incrementada: $newStreak');
    } else {
      // Más de 2 días sin entrenar - resetear racha a 1
      newStreak = 1;
      print('🔥 [STREAK] Usuario $userId - Más de 2 días sin entrenar ($daysDifference días), racha reseteada: $newStreak');
    }

    await _usersCollection.doc(userId).update({
      'rachasDias': newStreak,
      'fechaUltimoEntrenamiento': Timestamp.fromDate(now),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Eliminar una entrada del historial
  Future<void> deleteTrainingHistory(String historyId) async {
    await _historyCollection.doc(historyId).delete();
  }

  /// Recalcula la racha de un usuario basándose en su historial de entrenamientos.
  ///
  /// Útil para corregir rachas que no se calcularon correctamente.
  /// Cuenta días únicos de entrenamiento, permitiendo hasta 2 días de descanso entre sesiones.
  Future<int> recalculateStreak(String userId) async {
    // Obtener historial ordenado por fecha descendente
    final snapshot = await _historyCollection
        .where('clienteId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .get();

    if (snapshot.docs.isEmpty) {
      await _usersCollection.doc(userId).update({
        'rachasDias': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('🔥 [STREAK RECALC] Usuario $userId - Sin historial, racha: 0');
      return 0;
    }

    // Extraer fechas únicas de entrenamiento (sin hora)
    final Set<DateTime> uniqueDays = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final fecha = (data['fecha'] as Timestamp).toDate();
      uniqueDays.add(DateTime(fecha.year, fecha.month, fecha.day));
    }

    // Ordenar fechas de más reciente a más antigua
    final sortedDays = uniqueDays.toList()..sort((a, b) => b.compareTo(a));

    // Calcular racha: contar días consecutivos permitiendo hasta 2 días de descanso
    int streak = 0;
    DateTime? previousDay;

    for (final day in sortedDays) {
      if (previousDay == null) {
        // Primer día (más reciente)
        streak = 1;
        previousDay = day;
      } else {
        final daysDifference = previousDay.difference(day).inDays;
        if (daysDifference <= 2) {
          // Día válido (hasta 2 días de diferencia permitidos)
          streak++;
          previousDay = day;
        } else {
          // Más de 2 días de diferencia, la racha se rompe aquí
          break;
        }
      }
    }

    // Verificar que el último entrenamiento no sea muy antiguo
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastWorkoutDay = sortedDays.first;
    final daysSinceLastWorkout = today.difference(lastWorkoutDay).inDays;

    if (daysSinceLastWorkout > 2) {
      // Más de 2 días sin entrenar desde el último - resetear racha
      streak = 0;
      print('🔥 [STREAK RECALC] Usuario $userId - Más de 2 días sin entrenar ($daysSinceLastWorkout días), racha reseteada: 0');
    } else {
      print('🔥 [STREAK RECALC] Usuario $userId - Racha calculada: $streak (${uniqueDays.length} días únicos de entrenamiento)');
    }

    // Actualizar en Firebase
    await _usersCollection.doc(userId).update({
      'rachasDias': streak,
      'fechaUltimoEntrenamiento': Timestamp.fromDate(sortedDays.first),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return streak;
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
      if (kDebugMode) debugPrint('Error marcando notificación como leída: $e');
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
      } else {
        // Si no existe en notifications, verificar si es una solicitud de rutina
        final routineDoc = await _routineRequestsCollection.doc(notificationId).get();

        if (routineDoc.exists) {
          // Si existe en routine_requests, marcarla como rechazada o eliminarla
          await _routineRequestsCollection.doc(notificationId).update({
            'estado': 'rechazada',
            'fechaRechazo': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error eliminando notificación: $e');
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

  /// Marcar todas las notificaciones como leídas para un entrenador
  /// Usa batch write para eficiencia (máx 500 operaciones por batch)
  Future<void> markAllNotificationsAsRead(String trainerId) async {
    try {
      final snapshot = await _notificationsCollection
          .where('entrenadorId', isEqualTo: trainerId)
          .where('leido', isEqualTo: false)
          .limit(500) // Límite de batch
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'leido': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      if (kDebugMode) debugPrint('Error marcando notificaciones como leídas: $e');
    }
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
      // 1. Limpiar historial de entrenamientos > 365 días
      await _cleanupOldTrainingHistory();

      // 2. Limpiar rutinas semanales expiradas > 30 días
      await _cleanupExpiredWeeklyRoutines();
    } catch (e) {
      // No lanzamos error para no interrumpir el flujo del login
    }
  }

  /// Eliminar historial de entrenamientos con más de 1 año de antigüedad
  Future<void> _cleanupOldTrainingHistory() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 365));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      final oldDocs = await _historyCollection
          .where('fecha', isLessThan: cutoffTimestamp)
          .limit(100)
          .get();

      if (oldDocs.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in oldDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // Silently fail - cleanup is not critical
    }
  }

  /// Eliminar rutinas semanales expiradas con más de 30 días
  Future<void> _cleanupExpiredWeeklyRoutines() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      final expiredDocs = await _weeklyRoutinesCollection
          .where('expiresAt', isLessThan: cutoffTimestamp)
          .limit(100)
          .get();

      if (expiredDocs.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in expiredDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // Silently fail - cleanup is not critical
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
    } catch (e) {
      // Silently fail
    }
  }

  // ============ ROUTINE REQUESTS ============

  /// Crear solicitud de rutina
  Future<String> createRoutineRequest(RoutineRequestModel request) async {
    final docRef = await _routineRequestsCollection.add(request.toFirestore());
    final requestId = docRef.id;

    // Crear notificación para todos los entrenadores
    try {
      await _notifyTrainersAboutNewRoutineRequest(requestId, request);
    } catch (e) {
      // Si falla la notificación, la solicitud ya se guardó
      if (kDebugMode) debugPrint('Error creando notificación de solicitud: $e');
    }

    return requestId;
  }

  /// Notificar a todos los entrenadores sobre una nueva solicitud de rutina
  Future<void> _notifyTrainersAboutNewRoutineRequest(
    String requestId,
    RoutineRequestModel request,
  ) async {
    // Obtener todos los usuarios con rol entrenador o admin
    final trainersQuery = await _usersCollection
        .where('rol', whereIn: ['entrenador', 'admin'])
        .get();

    // Crear una notificación para cada entrenador
    final batch = _firestore.batch();
    for (final trainerDoc in trainersQuery.docs) {
      final notificationRef = _notificationsCollection.doc();
      batch.set(notificationRef, {
        'tipo': 'solicitud_rutina',
        'requestId': requestId,
        'entrenadorId': trainerDoc.id,
        'clienteId': request.clienteId,
        'clienteNombre': request.clienteNombre,
        'parteDelCuerpo': request.parteDelCuerpo.name,
        'leido': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // También enviar push notification si tiene token FCM
      final data = trainerDoc.data();
      final fcmToken = data['fcmToken'] as String?;
      if (fcmToken != null && fcmToken.isNotEmpty) {
        final pushRef = _firestore.collection('push_notifications').doc();
        batch.set(pushRef, {
          'to': fcmToken,
          'notification': {
            'title': '💪 Nueva Solicitud de Entrenamiento',
            'body': '${request.clienteNombre} solicita rutina de ${request.parteDelCuerpo.displayName}',
          },
          'data': {
            'tipo': 'solicitud_rutina',
            'requestId': requestId,
            'clienteId': request.clienteId,
          },
          'priority': 'high',
          'createdAt': FieldValue.serverTimestamp(),
          'processed': false,
        });
      }
    }
    await batch.commit();
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
    }

    return orderId;
  }

  /// Notificar a todos los entrenadores sobre un nuevo pedido
  Future<void> _notifyTrainersAboutNewOrder(String orderId, StoreOrderModel order) async {
    // Obtener todos los usuarios con rol entrenador o admin
    final trainersQuery = await _usersCollection
        .where('rol', whereIn: ['entrenador', 'admin'])
        .get();

    // Crear una notificación para cada entrenador (con su entrenadorId)
    final batch = _firestore.batch();
    for (final trainerDoc in trainersQuery.docs) {
      final notificationRef = _notificationsCollection.doc();
      batch.set(notificationRef, {
        'tipo': 'nuevo_pedido',
        'orderId': orderId,
        'entrenadorId': trainerDoc.id,
        'clienteId': order.clienteId,
        'clienteNombre': order.clienteNombre,
        'total': order.total,
        'itemsCount': order.items.length,
        'leido': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // También enviar push notification si tiene token FCM
      final data = trainerDoc.data();
      final fcmToken = data['fcmToken'] as String?;
      if (fcmToken != null && fcmToken.isNotEmpty) {
        final pushRef = _firestore.collection('push_notifications').doc();
        batch.set(pushRef, {
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
    await batch.commit();
  }

  /// Stream de todos los pedidos (para el coach)
  /// También ejecuta limpieza de pedidos antiguos en segundo plano
  Stream<List<StoreOrderModel>> storeOrdersStream() {
    // Ejecutar limpieza de pedidos antiguos en segundo plano
    _cleanupDeliveredOrders();

    return _storeOrdersCollection
        .orderBy('fechaPedido', descending: true)
        .snapshots()
        .map((snapshot) {
          final List<StoreOrderModel> orders = [];
          for (final doc in snapshot.docs) {
            try {
              orders.add(StoreOrderModel.fromFirestore(doc));
            } catch (e) {
              // Skip malformed documents
            }
          }
          return orders;
        });
  }

  /// Stream de pedidos de un cliente específico
  /// También ejecuta limpieza de pedidos antiguos en segundo plano
  Stream<List<StoreOrderModel>> clientStoreOrdersStream(String clienteId) {
    // Ejecutar limpieza de pedidos antiguos en segundo plano
    _cleanupDeliveredOrders();

    return _storeOrdersCollection
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fechaPedido', descending: true)
        .snapshots()
        .map((snapshot) {
          final List<StoreOrderModel> orders = [];
          for (final doc in snapshot.docs) {
            try {
              orders.add(StoreOrderModel.fromFirestore(doc));
            } catch (e) {
              // Skip malformed documents
            }
          }
          return orders;
        });
  }

  /// Stream de pedidos pendientes (sin entregar)
  Stream<List<StoreOrderModel>> pendingStoreOrdersStream() {
    return _storeOrdersCollection
        .where('estado',
            whereIn: [OrderStatus.pendiente.name, OrderStatus.listo.name])
        .orderBy('fechaPedido', descending: false)
        .snapshots()
        .map((snapshot) {
          final List<StoreOrderModel> orders = [];
          for (final doc in snapshot.docs) {
            try {
              orders.add(StoreOrderModel.fromFirestore(doc));
            } catch (e) {
              // Skip malformed documents
            }
          }
          return orders;
        });
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

  /// Eliminar un pedido de tienda
  Future<void> deleteStoreOrder(String orderId) async {
    await _storeOrdersCollection.doc(orderId).delete();
  }

  // ============ CLEANUP: STORE ORDERS ============

  /// Eliminar pedidos entregados con más de 24 horas
  Future<void> _cleanupDeliveredOrders() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(hours: 24));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      final deliveredDocs = await _storeOrdersCollection
          .where('estado', isEqualTo: OrderStatus.entregado.name)
          .where('fechaEntregado', isLessThan: cutoffTimestamp)
          .limit(100)
          .get();

      if (deliveredDocs.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in deliveredDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // Silently fail - cleanup is not critical
    }
  }

  // ============ CLEANUP: ROUTINE REQUESTS ============

  /// Eliminar solicitudes de rutina completadas con más de 30 días
  Future<void> _cleanupCompletedRoutineRequests() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      final completedDocs = await _routineRequestsCollection
          .where('estado', isEqualTo: RequestStatus.asignada.name)
          .where('fechaRespuesta', isLessThan: cutoffTimestamp)
          .limit(100)
          .get();

      if (completedDocs.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in completedDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // Silently fail - cleanup is not critical
    }
  }

  // ============ CLEANUP COORDINATOR ============

  /// Ejecutar todas las tareas de limpieza
  Future<void> runCleanupTasks() async {
    await Future.wait([
      _cleanupExpiredWeeklyRoutines(),
      _cleanupDeliveredOrders(),
      _cleanupCompletedRoutineRequests(),
    ]);
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
  }

  /// Eliminar producto
  Future<void> deleteProduct(String productId) async {
    await _productsCollection.doc(productId).delete();
  }

  /// Activar/Desactivar producto
  Future<void> toggleProductStatus(String productId, bool isActive) async {
    await _productsCollection.doc(productId).update({
      'isActive': isActive,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Actualizar stock del producto
  Future<void> updateProductStock(String productId, int newStock) async {
    await _productsCollection.doc(productId).update({
      'stock': newStock,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
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
          errors++;
        }
      }

      return {'updated': updated, 'skipped': skipped, 'errors': errors};
    } catch (e) {
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
          errors++;
        }
      }

      return {'created': created, 'errors': errors};
    } catch (e) {
      rethrow;
    }
  }

  // ============ ANNOUNCEMENTS ============

  /// Crear anuncio personalizado
  Future<String> createAnnouncement(AnnouncementModel announcement) async {
    if (kDebugMode) {
      debugPrint('📢 [CreateAnnouncement] Título: ${announcement.titulo}');
      debugPrint('📢 [CreateAnnouncement] ClientesIds: ${announcement.clientesIds}');
      debugPrint('📢 [CreateAnnouncement] Activo: ${announcement.activo}');
    }

    final docRef = await _announcementsCollection.add(announcement.toMap());

    if (kDebugMode) {
      debugPrint('📢 [CreateAnnouncement] Creado con ID: ${docRef.id}');
    }

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

    } catch (e) {
      // Silently fail - push notifications are not critical
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
    if (kDebugMode) {
      debugPrint('📢 [Announcements] Iniciando stream para cliente: $clientId');
    }

    return _announcementsCollection
        .where('activo', isEqualTo: true)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (kDebugMode) {
        debugPrint('📢 [Announcements] Documentos recibidos: ${snapshot.docs.length}');
      }

      final allAnnouncements = snapshot.docs
          .map((doc) => AnnouncementModel.fromFirestore(doc))
          .toList();

      if (kDebugMode) {
        for (final ann in allAnnouncements) {
          debugPrint('📢 [Announcements] Anuncio: ${ann.titulo}, clientesIds: ${ann.clientesIds}, isForClient: ${ann.isForClient(clientId)}');
        }
      }

      final announcements = allAnnouncements
          .where((announcement) => announcement.isForClient(clientId))
          .toList();

      if (kDebugMode) {
        debugPrint('📢 [Announcements] Anuncios filtrados para cliente: ${announcements.length}');
      }

      // Filtrar anuncios que no han sido eliminados por el cliente
      // Si hay error en la consulta de estado, incluimos el anuncio de todas formas
      final filteredAnnouncements = <AnnouncementModel>[];
      for (final announcement in announcements) {
        try {
          final status = await _getClientNotificationStatus(clientId, announcement.id);
          if (status == null || !status.eliminado) {
            filteredAnnouncements.add(announcement);
          }
        } catch (e) {
          // En caso de error, incluimos el anuncio para no bloquear el flujo
          if (kDebugMode) {
            debugPrint('⚠️ [Announcements] Error obteniendo estado para ${announcement.id}: $e');
          }
          filteredAnnouncements.add(announcement);
        }
      }

      if (kDebugMode) {
        debugPrint('📢 [Announcements] Anuncios finales (no eliminados): ${filteredAnnouncements.length}');
      }

      return filteredAnnouncements;
    }).handleError((error, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [Announcements] Error en stream: $error');
        debugPrint('❌ [Announcements] Stack: $stackTrace');
      }
      // Retornamos lista vacía si hay error crítico en el stream
      return <AnnouncementModel>[];
    });
  }

  /// Obtener estado de notificación del cliente
  Future<ClientNotificationStatus?> _getClientNotificationStatus(
    String clientId,
    String announcementId,
  ) async {
    try {
      final query = await _clientNotificationStatusCollection
          .where('clienteId', isEqualTo: clientId)
          .where('anuncioId', isEqualTo: announcementId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return ClientNotificationStatus.fromFirestore(query.docs.first);
    } catch (e) {
      // Si hay error (ej: índice no listo), asumimos que no ha sido eliminado
      if (kDebugMode) {
        debugPrint('⚠️ [NotificationStatus] Error consultando estado: $e');
      }
      return null;
    }
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
  }

  /// Actualizar anuncio
  Future<void> updateAnnouncement(String announcementId, AnnouncementModel announcement) async {
    await _announcementsCollection.doc(announcementId).update(announcement.toMap());
  }

  /// Desactivar anuncio
  Future<void> deactivateAnnouncement(String announcementId) async {
    await _announcementsCollection.doc(announcementId).update({
      'activo': false,
    });
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

  // ============ ASSIGNED ROUTINES (3 HOUR EXPIRATION) ============

  CollectionReference<Map<String, dynamic>> get _assignedRoutinesCollection =>
      _firestore.collection('assigned_routines');

  /// Asignar rutina a un cliente (expira en 3 horas)
  Future<String> assignRoutineToClient({
    required String clienteId,
    required String rutinaId,
    required String rutinaNombre,
    String? trainerId,
  }) async {
    print('📝 [ASSIGN] Asignando rutina a cliente:');
    print('   - clienteId: $clienteId');
    print('   - rutinaId: $rutinaId');
    print('   - rutinaNombre: $rutinaNombre');
    print('   - trainerId: $trainerId');

    // Primero, marcar cualquier rutina activa anterior como expirada
    await _expireClientActiveRoutines(clienteId);

    // Crear nueva asignación
    final assignment = AssignedRoutineModel.create(
      clienteId: clienteId,
      rutinaId: rutinaId,
      rutinaNombre: rutinaNombre,
      trainerId: trainerId,
    );

    print('📝 [ASSIGN] Guardando asignación en Firestore...');
    final docRef = await _assignedRoutinesCollection.add(assignment.toFirestore());
    print('✅ [ASSIGN] Asignación guardada con ID: ${docRef.id}');

    // Actualizar el campo rutinaAsignadaId del cliente para que aparezca "Con rutina"
    await _usersCollection.doc(clienteId).update({
      'rutinaAsignadaId': rutinaId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('✅ [ASSIGN] Usuario actualizado con rutinaAsignadaId');

    return docRef.id;
  }

  /// Expirar todas las rutinas activas de un cliente
  Future<void> _expireClientActiveRoutines(String clienteId) async {
    // Consulta simple solo por clienteId para evitar problemas de índices
    final allRoutines = await _assignedRoutinesCollection
        .where('clienteId', isEqualTo: clienteId)
        .get();

    if (allRoutines.docs.isEmpty) return;

    // Filtrar las activas en memoria
    final activeRoutineDocs = allRoutines.docs.where((doc) {
      final data = doc.data();
      return data['estado'] == 'activa';
    }).toList();

    if (activeRoutineDocs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in activeRoutineDocs) {
      batch.update(doc.reference, {'estado': 'expirada'});
    }
    await batch.commit();
  }

  /// Obtener rutina activa del cliente (si existe y no ha expirado)
  Future<AssignedRoutineModel?> getActiveAssignedRoutine(String clienteId) async {
    // Consulta simple solo por clienteId para evitar problemas de índices
    final query = await _assignedRoutinesCollection
        .where('clienteId', isEqualTo: clienteId)
        .get();

    if (query.docs.isEmpty) return null;

    // Filtrar y ordenar en memoria
    final assignments = query.docs
        .map((doc) => AssignedRoutineModel.fromFirestore(doc))
        .where((a) => a.estado == AssignedRoutineStatus.activa)
        .toList();

    if (assignments.isEmpty) return null;

    // Ordenar por fecha de asignación (más reciente primero)
    assignments.sort((a, b) => b.fechaAsignacion.compareTo(a.fechaAsignacion));

    final assignment = assignments.first;

    // Verificar si ha expirado
    if (assignment.isExpired) {
      // Marcar como expirada en Firestore
      await _assignedRoutinesCollection.doc(assignment.id).update({
        'estado': 'expirada',
      });
      return null;
    }

    return assignment;
  }

  /// Stream de rutina activa del cliente
  /// Consulta simplificada para mayor compatibilidad con índices
  Stream<AssignedRoutineModel?> activeAssignedRoutineStream(String clienteId) {
    print('🔍 [FIRESTORE] activeAssignedRoutineStream - clienteId: $clienteId');

    // Usar consulta simple solo por clienteId para evitar problemas de índices compuestos
    return _assignedRoutinesCollection
        .where('clienteId', isEqualTo: clienteId)
        .snapshots()
        .handleError((error, stackTrace) {
          print('❌ [FIRESTORE] Error en query assigned_routines: $error');
          print('   Stack: $stackTrace');
        })
        .map((snapshot) {
      print('🔍 [FIRESTORE] Snapshot recibido - docs count: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('⚠️ [FIRESTORE] No hay documentos para clienteId: $clienteId');
        return null;
      }

      // Mostrar todos los documentos encontrados para debug
      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('   📄 Doc ${doc.id}: clienteId=${data['clienteId']}, estado=${data['estado']}');
      }

      // Filtrar y ordenar en memoria para mayor robustez
      final assignments = snapshot.docs
          .map((doc) => AssignedRoutineModel.fromFirestore(doc))
          .where((a) => a.estado == AssignedRoutineStatus.activa)
          .toList();

      print('🔍 [FIRESTORE] Asignaciones activas encontradas: ${assignments.length}');

      if (assignments.isEmpty) {
        print('⚠️ [FIRESTORE] No hay asignaciones activas');
        return null;
      }

      // Ordenar por fecha de asignación (más reciente primero)
      assignments.sort((a, b) => b.fechaAsignacion.compareTo(a.fechaAsignacion));

      final assignment = assignments.first;
      print('✅ [FIRESTORE] Rutina activa encontrada: ${assignment.rutinaNombre}');

      // Verificar si ha expirado
      if (assignment.isExpired) {
        print('⚠️ [FIRESTORE] Rutina expirada, marcando...');
        // Marcar como expirada en Firestore (en background)
        _assignedRoutinesCollection.doc(assignment.id).update({
          'estado': 'expirada',
        });
        return null;
      }

      return assignment;
    });
  }

  /// Marcar rutina asignada como completada
  Future<void> completeAssignedRoutine(String assignmentId) async {
    await _assignedRoutinesCollection.doc(assignmentId).update({
      'estado': 'completada',
      'fechaCompletada': FieldValue.serverTimestamp(),
    });
  }

  /// Descartar/liberar rutina asignada (el cliente la rechaza)
  /// Esto permite al usuario autoasignarse otra rutina o pedir una nueva al coach
  Future<void> dismissAssignedRoutine(String assignmentId, String clienteId) async {
    // Marcar la rutina como descartada
    await _assignedRoutinesCollection.doc(assignmentId).update({
      'estado': 'descartada',
    });

    // Limpiar el campo rutinaAsignadaId del cliente
    await _usersCollection.doc(clienteId).update({
      'rutinaAsignadaId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Limpiar rutinas asignadas expiradas (para mantenimiento)
  Future<void> cleanupExpiredAssignedRoutines() async {
    try {
      final now = DateTime.now();

      // Obtener todas las rutinas y filtrar en memoria para evitar índices
      final allDocs = await _assignedRoutinesCollection
          .limit(200)
          .get();

      if (allDocs.docs.isEmpty) return;

      // Filtrar las que están activas pero expiradas
      final expiredDocs = allDocs.docs.where((doc) {
        final data = doc.data();
        if (data['estado'] != 'activa') return false;
        final fechaExpiracion = data['fechaExpiracion'] as Timestamp?;
        if (fechaExpiracion == null) return false;
        return fechaExpiracion.toDate().isBefore(now);
      }).toList();

      if (expiredDocs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in expiredDocs) {
        batch.update(doc.reference, {'estado': 'expirada'});
      }
      await batch.commit();
    } catch (e) {
      // Silently fail - cleanup is not critical
    }
  }

  /// Eliminar rutinas asignadas antiguas (más de 7 días)
  Future<void> deleteOldAssignedRoutines() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      final oldDocs = await _assignedRoutinesCollection
          .where('fechaAsignacion', isLessThan: cutoffTimestamp)
          .limit(100)
          .get();

      if (oldDocs.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in oldDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // Silently fail - cleanup is not critical
    }
  }

  /// Obtener historial de rutinas asignadas del cliente
  Stream<List<AssignedRoutineModel>> clientAssignedRoutinesHistory(String clienteId) {
    return _assignedRoutinesCollection
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fechaAsignacion', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssignedRoutineModel.fromFirestore(doc))
            .toList());
  }
}
