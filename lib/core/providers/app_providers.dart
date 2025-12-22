import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../services/migration_service.dart';
import '../services/notification_service.dart';
import '../router/app_router.dart';

// ============ SERVICES ============

/// Provider para FirebaseService
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// Provider para MigrationService
final migrationServiceProvider = Provider<MigrationService>((ref) {
  return MigrationService(ref.watch(firebaseServiceProvider));
});

/// Provider para NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ============ USER & ROLE ============

/// Provider para el usuario actual de Firebase Auth
final firebaseUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider de estado para el ID de usuario activo (puede ser el real o el de prueba)
/// null = usar usuario real, no-null = usar usuario de prueba
final activeUserIdProvider = StateProvider<String?>((ref) => null);

/// Provider para el modelo de usuario completo desde Firestore
/// Usa el activeUserIdProvider si está configurado, sino usa el usuario autenticado
final userModelProvider = StreamProvider<UserModel?>((ref) {
  final firebaseUser = ref.watch(firebaseUserProvider).value;
  if (firebaseUser == null) return Stream.value(null);

  // Si hay un usuario activo configurado (modo prueba), usar ese ID
  final activeUserId = ref.watch(activeUserIdProvider);
  final uid = activeUserId ?? firebaseUser.uid;

  return ref.watch(firebaseServiceProvider).userStream(uid);
});

/// Provider para verificar y obtener el rol del usuario
final userRoleProvider = FutureProvider<UserRole>((ref) async {
  final firebaseUser = ref.watch(firebaseUserProvider).value;
  if (firebaseUser == null) {
    return UserRole.cliente;
  }

  return ref
      .watch(firebaseServiceProvider)
      .getUserRole(firebaseUser.uid);
});

/// Provider que indica si el usuario es entrenador
final isTrainerProvider = Provider<bool>((ref) {
  final roleAsync = ref.watch(userRoleProvider);
  return roleAsync.when(
    data: (role) => role == UserRole.entrenador,
    loading: () => false,
    error: (_, _) => false,
  );
});

/// Provider que indica si el onboarding está completo
final isOnboardingCompleteProvider = Provider<bool>((ref) {
  final userModel = ref.watch(userModelProvider).value;
  return userModel?.onboardingCompleto ?? false;
});

// ============ MACHINES ============

/// Provider para todas las máquinas
final machinesProvider = StreamProvider<List<MachineModel>>((ref) {
  return ref.watch(firebaseServiceProvider).getAllMachines();
});

/// Provider para máquinas filtradas
final filteredMachinesProvider = Provider.family<List<MachineModel>, MachineFilters>(
  (ref, filters) {
    final machines = ref.watch(machinesProvider).value ?? [];

    return machines.where((machine) {
      // Filtro por categoría
      if (filters.category != null && machine.categoria != filters.category) {
        return false;
      }

      // Filtro por tipo
      if (filters.type != null && machine.tipo != filters.type) {
        return false;
      }

      // Filtro por nivel
      if (filters.level != null && machine.nivel != filters.level) {
        return false;
      }

      // Filtro por búsqueda
      if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
        final query = filters.searchQuery!.toLowerCase();
        return machine.nombre.toLowerCase().contains(query) ||
            machine.descripcion.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  },
);

/// Clase para filtros de máquinas
class MachineFilters {
  final MachineCategory? category;
  final MachineType? type;
  final DifficultyLevel? level;
  final String? searchQuery;

  const MachineFilters({
    this.category,
    this.type,
    this.level,
    this.searchQuery,
  });

  MachineFilters copyWith({
    MachineCategory? category,
    MachineType? type,
    DifficultyLevel? level,
    String? searchQuery,
    bool clearCategory = false,
    bool clearType = false,
    bool clearLevel = false,
  }) {
    return MachineFilters(
      category: clearCategory ? null : (category ?? this.category),
      type: clearType ? null : (type ?? this.type),
      level: clearLevel ? null : (level ?? this.level),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// StateProvider para los filtros actuales de máquinas
final machineFiltersProvider = StateProvider<MachineFilters>((ref) {
  return const MachineFilters();
});

// ============ ROUTINES ============

/// Provider para todas las rutinas
final routinesProvider = StreamProvider<List<RoutineModel>>((ref) {
  return ref.watch(firebaseServiceProvider).getRoutinesByDifficulty();
});

/// Provider para plantillas de rutinas
final routineTemplatesProvider = StreamProvider<List<RoutineModel>>((ref) {
  return ref.watch(firebaseServiceProvider).getRoutineTemplates();
});

/// Provider para rutinas filtradas
final filteredRoutinesProvider = Provider.family<List<RoutineModel>, RoutineFilters>(
  (ref, filters) {
    final routines = ref.watch(routinesProvider).value ?? [];

    return routines.where((routine) {
      // Filtro por dificultad
      if (filters.difficulty != null && routine.dificultad != filters.difficulty) {
        return false;
      }

      // Filtro por parte del cuerpo
      if (filters.bodyPart != null && routine.parteDelCuerpo != filters.bodyPart) {
        return false;
      }

      // Filtro por género
      if (filters.gender != null &&
          routine.genero != filters.gender &&
          routine.genero != RoutineGender.unisex) {
        return false;
      }

      // Filtro por plantilla
      if (filters.onlyTemplates && !routine.esPlantilla) {
        return false;
      }

      // Filtro por búsqueda
      if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
        final query = filters.searchQuery!.toLowerCase();
        return routine.nombre.toLowerCase().contains(query) ||
            (routine.descripcion?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();
  },
);

/// Clase para filtros de rutinas
class RoutineFilters {
  final RoutineDifficulty? difficulty;
  final RoutineBodyPart? bodyPart;
  final RoutineGender? gender;
  final bool onlyTemplates;
  final String? searchQuery;

  const RoutineFilters({
    this.difficulty,
    this.bodyPart,
    this.gender,
    this.onlyTemplates = false,
    this.searchQuery,
  });

  RoutineFilters copyWith({
    RoutineDifficulty? difficulty,
    RoutineBodyPart? bodyPart,
    RoutineGender? gender,
    bool? onlyTemplates,
    String? searchQuery,
    bool clearDifficulty = false,
    bool clearBodyPart = false,
    bool clearGender = false,
  }) {
    return RoutineFilters(
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      bodyPart: clearBodyPart ? null : (bodyPart ?? this.bodyPart),
      gender: clearGender ? null : (gender ?? this.gender),
      onlyTemplates: onlyTemplates ?? this.onlyTemplates,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// StateProvider para los filtros actuales de rutinas
final routineFiltersProvider = StateProvider<RoutineFilters>((ref) {
  return const RoutineFilters();
});

// ============ CLIENTS (TRAINER) ============

/// Provider para todos los clientes (solo para entrenadores)
final clientsProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(firebaseServiceProvider).getAllClients();
});

/// Provider para búsqueda de clientes
final clientSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider para clientes filtrados por búsqueda
final filteredClientsProvider = Provider<List<UserModel>>((ref) {
  final clients = ref.watch(clientsProvider).value ?? [];
  final query = ref.watch(clientSearchQueryProvider).toLowerCase();

  if (query.isEmpty) return clients;

  return clients.where((client) {
    return client.nombre?.toLowerCase().contains(query) ?? false;
  }).toList();
});

// ============ WEEKLY ROUTINES ============

/// Provider para la rutina semanal del cliente actual
final currentUserWeeklyRoutineProvider = StreamProvider<WeeklyRoutine?>((ref) {
  final firebaseUser = ref.watch(firebaseUserProvider).value;
  if (firebaseUser == null) return Stream.value(null);

  return ref.watch(firebaseServiceProvider).weeklyRoutineStream(firebaseUser.uid);
});

/// Provider para la rutina del día actual
final todayRoutineIdProvider = Provider<String?>((ref) {
  final weeklyRoutine = ref.watch(currentUserWeeklyRoutineProvider).value;
  if (weeklyRoutine == null) return null;

  final today = DateTime.now().weekday;
  return weeklyRoutine.getRutinaDelDia(today);
});

/// Provider para obtener la rutina del día
final todayRoutineProvider = FutureProvider<RoutineModel?>((ref) async {
  final routineId = ref.watch(todayRoutineIdProvider);
  if (routineId == null) return null;

  return ref.watch(firebaseServiceProvider).getRoutine(routineId);
});

// ============ HISTORY ============

/// Provider para el historial del cliente actual
final currentUserHistoryProvider = StreamProvider<List<TrainingHistory>>((ref) {
  final firebaseUser = ref.watch(firebaseUserProvider).value;
  if (firebaseUser == null) return Stream.value([]);

  return ref.watch(firebaseServiceProvider).getClientHistory(firebaseUser.uid);
});

/// Provider para el historial de un cliente específico (para entrenador)
final clientHistoryProvider =
    StreamProvider.family<List<TrainingHistory>, String>((ref, clientId) {
  return ref.watch(firebaseServiceProvider).getClientHistory(clientId);
});

// ============ ROUTINE REQUESTS ============

/// Provider para todas las solicitudes de rutina (para el coach)
final routineRequestsProvider = StreamProvider<List<RoutineRequestModel>>((ref) {
  return ref.watch(firebaseServiceProvider).routineRequestsStream();
});

/// Provider para solicitudes pendientes (para el coach)
final pendingRoutineRequestsProvider = Provider<List<RoutineRequestModel>>((ref) {
  final requests = ref.watch(routineRequestsProvider).value ?? [];
  return requests.where((r) => r.estado == RequestStatus.pendiente).toList();
});

/// Provider para solicitudes de un cliente específico
final clientRoutineRequestsProvider =
    StreamProvider.family<List<RoutineRequestModel>, String>((ref, clientId) {
  return ref.watch(firebaseServiceProvider).clientRoutineRequestsStream(clientId);
});

// ============ NOTIFICATIONS ============

/// Provider para notificaciones del entrenador
final trainerNotificationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final firebaseUser = ref.watch(firebaseUserProvider).value;
  if (firebaseUser == null) return Stream.value([]);

  return ref.watch(firebaseServiceProvider).getTrainerNotifications(firebaseUser.uid);
});

/// Provider para el contador de notificaciones no leídas
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final firebaseUser = ref.watch(firebaseUserProvider).value;
  if (firebaseUser == null) return Stream.value(0);

  return ref.watch(firebaseServiceProvider).getUnreadNotificationsCount(firebaseUser.uid);
});

// ============ CLIENT ANNOUNCEMENTS ============

/// Provider para anuncios del cliente
final clientAnnouncementsProvider =
    StreamProvider.family<List<AnnouncementModel>, String>((ref, clientId) {
  return ref.watch(firebaseServiceProvider).getClientAnnouncementsStream(clientId);
});

/// Provider para el contador de anuncios no leídos del cliente
final unreadAnnouncementsCountProvider = StreamProvider<int>((ref) {
  final firebaseUser = ref.watch(firebaseUserProvider).value;
  if (firebaseUser == null) return Stream.value(0);

  return ref.watch(firebaseServiceProvider).getUnreadAnnouncementsCount(firebaseUser.uid);
});

// ============ STORE ORDERS ============

/// Provider para todos los pedidos de tienda (para el coach)
final storeOrdersProvider = StreamProvider<List<StoreOrderModel>>((ref) {
  return ref.watch(firebaseServiceProvider).storeOrdersStream();
});

/// Provider para pedidos activos (pendiente, en preparación, listo) - excluye entregados (para el coach)
final activeStoreOrdersProvider = Provider<List<StoreOrderModel>>((ref) {
  final orders = ref.watch(storeOrdersProvider).value ?? [];
  return orders
      .where((o) =>
          o.estado == OrderStatus.pendiente ||
          o.estado == OrderStatus.enPreparacion ||
          o.estado == OrderStatus.listo)
      .toList();
});

/// Provider para pedidos de un cliente específico
final clientStoreOrdersProvider =
    StreamProvider.family<List<StoreOrderModel>, String>((ref, clientId) {
  return ref.watch(firebaseServiceProvider).clientStoreOrdersStream(clientId);
});

/// Provider para pedidos listos del cliente actual (para notificación)
final currentUserReadyOrdersProvider = Provider<List<StoreOrderModel>>((ref) {
  final firebaseUser = ref.watch(firebaseUserProvider).value;
  if (firebaseUser == null) return [];

  final orders = ref.watch(clientStoreOrdersProvider(firebaseUser.uid)).value ?? [];
  return orders.where((o) => o.estado == OrderStatus.listo).toList();
});

// ============ PRODUCTS ============

/// Provider para todos los productos
final productsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.watch(firebaseServiceProvider).getAllProducts();
});

/// Provider para productos activos solamente
final activeProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.watch(firebaseServiceProvider).getActiveProducts();
});

/// Provider para productos filtrados por categoría
final productsByCategoryProvider =
    StreamProvider.family<List<ProductModel>, ProductCategory>((ref, category) {
  return ref.watch(firebaseServiceProvider).getProductsByCategory(category);
});

/// Provider para búsqueda de productos
final productSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider para productos filtrados por búsqueda
final filteredProductsProvider = Provider<List<ProductModel>>((ref) {
  final query = ref.watch(productSearchQueryProvider);
  final products = ref.watch(activeProductsProvider).value ?? [];

  if (query.isEmpty) return products;

  final lowerQuery = query.toLowerCase();
  return products.where((product) {
    return product.name.toLowerCase().contains(lowerQuery) ||
        product.description.toLowerCase().contains(lowerQuery);
  }).toList();
});

/// Provider para categoría seleccionada en la tienda
final selectedProductCategoryProvider = StateProvider<ProductCategory?>((ref) => null);

/// Provider para productos filtrados por categoría y búsqueda
final storeProductsProvider = Provider<List<ProductModel>>((ref) {
  final selectedCategory = ref.watch(selectedProductCategoryProvider);
  final searchQuery = ref.watch(productSearchQueryProvider);
  final allProducts = ref.watch(activeProductsProvider).value ?? [];

  var filtered = allProducts;

  // Filtrar por categoría si hay una seleccionada
  if (selectedCategory != null) {
    filtered = filtered.where((p) => p.category == selectedCategory).toList();
  }

  // Filtrar por búsqueda
  if (searchQuery.isNotEmpty) {
    final lowerQuery = searchQuery.toLowerCase();
    filtered = filtered.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  return filtered;
});

// ============ INITIALIZATION ============

/// Provider que inicializa datos y migración
final appInitializationProvider = FutureProvider<void>((ref) async {
  final migrationService = ref.watch(migrationServiceProvider);
  await migrationService.migrateAll();
});

// ============ ROUTER ============

/// Provider for the app router with proper refreshListenable setup
/// This provider creates a GoRouter instance that automatically rebuilds
/// when Firebase Auth state changes
final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});
