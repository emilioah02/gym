import '../models/models.dart';
import 'firebase_service.dart';
import 'migration_service.dart';

/// Servicio para inicializar la base de datos de Firebase con datos iniciales
class DatabaseInitializer {
  final FirebaseService _firebaseService;
  final MigrationService _migrationService;

  DatabaseInitializer(this._firebaseService)
      : _migrationService = MigrationService(_firebaseService);

  /// Inicializa la base de datos con todos los datos necesarios
  Future<void> initializeDatabase() async {
    // 1. Agregar entrenadores
    await _initializeTrainers();

    // 2. Migrar máquinas
    await _migrationService.migrateMachines();

    // 3. Migrar rutinas
    await _migrationService.migrateRoutines();
  }

  /// Inicializa los entrenadores en la base de datos
  Future<void> _initializeTrainers() async {
    final trainers = [
      'emilioah02@gmail.com', // Entrenador principal
    ];

    for (final email in trainers) {
      await _firebaseService.addTrainer(email);
    }
  }

  /// Crea un usuario cliente de prueba cuando inicie sesión
  /// Este método se llama después de la autenticación
  Future<void> setupTestClient(String uid, String email) async {
    // Verificar si ya existe
    final existingUser = await _firebaseService.getUser(uid);
    if (existingUser != null) return;

    // Crear usuario cliente de prueba
    final testClient = UserModel(
      uid: uid,
      email: email,
      nombre: 'Jack Cliente',
      rol: UserRole.cliente,
      edad: 28,
      altura: 1.75,
      peso: 75.0,
      pesoInicial: 78.0,
      genero: UserGender.hombre,
      objetivo: UserGoal.bajarGrasa,
      diasEntrenamiento: [1, 2, 4, 5], // Lunes, Martes, Jueves, Viernes
      onboardingCompleto: true,
      rachasDias: 5,
      createdAt: DateTime.now(),
    );

    await _firebaseService.saveUser(testClient);
  }

  /// Verifica si la base de datos ya tiene datos
  Future<bool> isDatabaseInitialized() async {
    final hasMachines = !await _firebaseService.isMachinesCollectionEmpty();
    final hasRoutines = !await _firebaseService.isRoutinesCollectionEmpty();
    return hasMachines && hasRoutines;
  }

  /// Crea datos de ejemplo para pruebas
  Future<void> createSampleData() async {
    // Crear historial de ejemplo para el cliente de prueba
    // Este se crea cuando el cliente completa una rutina
  }
}

/// Extensión para inicialización rápida desde cualquier parte de la app
extension FirebaseServiceExtensions on FirebaseService {
  /// Inicializa la base de datos si es necesario
  Future<void> initializeIfNeeded() async {
    final initializer = DatabaseInitializer(this);

    final isInitialized = await initializer.isDatabaseInitialized();
    if (!isInitialized) {
      await initializer.initializeDatabase();
    }
  }
}
