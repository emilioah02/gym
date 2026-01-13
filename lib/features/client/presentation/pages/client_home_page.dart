import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/router/app_router.dart';
import 'workout_session_page.dart';

/// Home del cliente - Diseño moderno y minimalista
class ClientHomePage extends ConsumerWidget {
  const ClientHomePage({super.key});

  /// Número de WhatsApp para sugerencias
  static const String _whatsappNumber = '525536569977';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);
    final todayRoutineAsync = ref.watch(todayRoutineProvider);
    final readyOrders = ref.watch(currentUserReadyOrdersProvider);
    final unreadCount = ref.watch(unreadAnnouncementsCountProvider).value ?? 0;

    // Auto-fix de racha: recalcula automáticamente si detecta inconsistencias
    // (racha 0 pero tiene historial reciente)
    ref.watch(streakAutoFixProvider);

    // Verificar si es usuario de prueba (entrenador en modo cliente)
    // Usamos activeUserIdProvider directamente para mayor robustez
    // Esto evita problemas si hay errores de carga del modelo de usuario
    final activeUserId = ref.watch(activeUserIdProvider);
    final isTestUser = activeUserId != null && activeUserId.contains('_test_client');

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      // FAB solo para usuario de prueba - volver al modo entrenador
      floatingActionButton: isTestUser
          ? _TrainerModeFAB(ref: ref)
          : null,
      body: Stack(
        children: [
          // Fondo con gradiente sutil
          _buildBackground(),

          // Contenido principal
          SafeArea(
            bottom: false,
            child: userAsync.when(
              data: (user) {
                if (user == null) return const _LoadingState();
                // Log del UID para debug
                print('👤 [CLIENT_HOME] Usuario cargado:');
                print('   - uid: ${user.uid}');
                print('   - email: ${user.email}');
                print('   - nombre: ${user.nombre}');
                print('   - activeUserId: $activeUserId');
                print('   - isTestUser: $isTestUser');
                return _buildMainContent(context, ref, user, todayRoutineAsync, unreadCount, isTestUser);
              },
              loading: () => const _LoadingState(),
              error: (error, _) => _ErrorState(error: error.toString()),
            ),
          ),

          // Notificación de pedidos listos
          if (readyOrders.isNotEmpty)
            _OrderReadyNotification(orders: readyOrders),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Gradiente principal
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.8, -0.6),
              radius: 1.8,
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.backgroundDark,
              ],
            ),
          ),
        ),
        // Gradiente secundario
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    AsyncValue<RoutineModel?> todayRoutineAsync,
    int unreadCount,
    bool isTestUser,
  ) {
    final assignedRoutineAsync = ref.watch(activeAssignedRoutineProvider);

    // Verificar si el usuario ya entrenó hoy (usando provider que combina historial + fechaUltimoEntrenamiento)
    final hasTrainedToday = ref.watch(hasTrainedTodayProvider);

    // Verificar si el usuario dismisseó el card de entrenamiento completado
    final dismissedCompletedCard = ref.watch(dismissCompletedWorkoutCardProvider);

    // Verificar si el usuario descartó la rutina del día (plan semanal)
    final dismissedTodayRoutine = ref.watch(dismissTodayRoutineCardProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header con saludo
        SliverToBoxAdapter(
          child: _buildHeader(context, user, unreadCount),
        ),

        // Contenido
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Tarjeta del día
              _buildDateCard(),
              const SizedBox(height: 24),

              // Rutina del día - prioridad: rutina asignada > completado hoy > rutina semanal > sin rutina
              assignedRoutineAsync.when(
                data: (assignedRoutine) {
                  print('🏠 [CLIENT_HOME] assignedRoutine: $assignedRoutine');
                  if (assignedRoutine != null) {
                    print('   - id: ${assignedRoutine.id}');
                    print('   - rutinaNombre: ${assignedRoutine.rutinaNombre}');
                    print('   - estado: ${assignedRoutine.estado}');
                    print('   - isActive: ${assignedRoutine.isActive}');
                    print('   - isExpired: ${assignedRoutine.isExpired}');
                    print('   - fechaExpiracion: ${assignedRoutine.fechaExpiracion}');
                  }

                  // PRIORIDAD 1: Si hay rutina asignada activa, mostrarla SIEMPRE
                  // (permite múltiples entrenamientos por día)
                  if (assignedRoutine != null && assignedRoutine.isActive) {
                    print('✅ [CLIENT_HOME] Mostrando rutina asignada (prioridad máxima)');
                    return _buildAssignedRoutineCard(context, ref, assignedRoutine);
                  }

                  // PRIORIDAD 2: Si ya entrenó hoy y no cerró el card, mostrar felicitación
                  if (hasTrainedToday && !dismissedCompletedCard) {
                    print('🎉 [CLIENT_HOME] Ya entrenó hoy, mostrando felicitación');
                    return _buildWorkoutCompletedCard(context, ref, user);
                  }

                  // PRIORIDAD 3: Intentar rutina semanal del día (si no la descartó)
                  print('⚠️ [CLIENT_HOME] No hay rutina asignada activa, intentando rutina del día');

                  // Si el usuario descartó la rutina del día, mostrar card de sin rutina
                  if (dismissedTodayRoutine) {
                    return _buildNoRoutineCard(context, ref);
                  }

                  return todayRoutineAsync.when(
                    data: (routine) => routine != null
                        ? _buildRoutineCard(context, ref, routine)
                        : _buildNoRoutineCard(context, ref),
                    loading: () => const _RoutineLoadingCard(),
                    error: (_, _) => _buildNoRoutineCard(context, ref),
                  );
                },
                loading: () => const _RoutineLoadingCard(),
                error: (error, stackTrace) {
                  print('❌ [CLIENT_HOME] Error en assignedRoutineAsync: $error');
                  print('   Stack: $stackTrace');

                  // Fallback: si ya entrenó hoy, mostrar felicitación
                  if (hasTrainedToday && !dismissedCompletedCard) {
                    return _buildWorkoutCompletedCard(context, ref, user);
                  }

                  // Si el usuario descartó la rutina del día, mostrar card de sin rutina
                  if (dismissedTodayRoutine) {
                    return _buildNoRoutineCard(context, ref);
                  }

                  return todayRoutineAsync.when(
                    data: (routine) => routine != null
                        ? _buildRoutineCard(context, ref, routine)
                        : _buildNoRoutineCard(context, ref),
                    loading: () => const _RoutineLoadingCard(),
                    error: (_, _) => _buildNoRoutineCard(context, ref),
                  );
                },
              ),

              const SizedBox(height: 28),

              // Resumen semanal
              _buildWeeklySection(ref),

              const SizedBox(height: 28),

              // Historial reciente
              _buildHistorySection(context, ref),

              const SizedBox(height: 28),

              // Stats
              _buildStatsSection(user),

              const SizedBox(height: 28),

              // Botón de sugerencias (solo para clientes normales)
              if (!isTestUser)
                _buildSuggestionsButton(context),

              // Espacio adicional para que no tape el navbar
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  /// Tarjeta de felicitación cuando ya completó el entrenamiento del día
  Widget _buildWorkoutCompletedCard(BuildContext context, WidgetRef ref, UserModel user) {
    return _WorkoutCompletedCard(user: user);
  }

  Widget _buildHeader(BuildContext context, UserModel user, int unreadCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        children: [
          // Avatar con borde gradient
          _buildAvatar(user),
          const SizedBox(width: 16),

          // Saludo y nombre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.nombre ?? 'Usuario',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Racha
          if (user.rachasDias > 0) ...[
            _buildStreakBadge(user.rachasDias),
            const SizedBox(width: 12),
          ],

          // Notificaciones
          _buildNotificationButton(context, unreadCount),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserModel user) {
    final hasValidPhoto = user.photoUrl?.isNotEmpty == true;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceDark,
        ),
        clipBehavior: Clip.antiAlias,
        child: hasValidPhoto
            ? CachedNetworkImage(
                imageUrl: user.photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => _buildAvatarPlaceholder(user),
                errorWidget: (_, _, _) => _buildAvatarPlaceholder(user),
              )
            : _buildAvatarPlaceholder(user),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(UserModel user) {
    return Center(
      child: Text(
        (user.nombre ?? 'U')[0].toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
    );
  }

  Widget _buildStreakBadge(int days) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withValues(alpha: 0.2),
            AppColors.warning.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 18),
          const SizedBox(width: 4),
          Text(
            '$days',
            style: const TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context, int unreadCount) {
    return GestureDetector(
      onTap: () => context.push('/client/notifications'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 22,
            ),
            if (unreadCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  Widget _buildDateCard() {
    final now = DateTime.now();
    final dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final monthNames = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Número del día con gradiente
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${now.day}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    height: 1,
                  ),
                ),
                Text(
                  monthNames[now.month - 1],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Día de la semana
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayNames[now.weekday - 1],
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Hoy',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Reloj estilo iOS
          const _IOSClockWidget(),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(BuildContext context, WidgetRef ref, RoutineModel routine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tu rutina de hoy'),
        const SizedBox(height: 16),
        _ModernRoutineCard(
          routine: routine,
          onStart: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutSessionPage(routine: routine),
              ),
            );
          },
          onDismiss: () => _showDismissTodayRoutineDialog(context, ref, routine),
        ),
      ],
    );
  }

  /// Diálogo de confirmación para descartar rutina del día (plan semanal)
  void _showDismissTodayRoutineDialog(
    BuildContext context,
    WidgetRef ref,
    RoutineModel routine,
  ) {
    showDialog(
      context: context,
      builder: (context) => _DismissTodayRoutineDialog(
        ref: ref,
        routine: routine,
      ),
    );
  }

  Widget _buildAssignedRoutineCard(
    BuildContext context,
    WidgetRef ref,
    AssignedRoutineModel assignment,
  ) {
    return FutureBuilder<RoutineModel?>(
      future: ref.read(firebaseServiceProvider).getRoutine(assignment.rutinaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _RoutineLoadingCard();
        }

        final routine = snapshot.data;
        if (routine == null) return _buildNoRoutineCard(context, ref);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Tu rutina de hoy'),
            const SizedBox(height: 16),
            _ModernRoutineCard(
              routine: routine,
              expirationCountdown: _ExpirationCountdown(assignment: assignment),
              onStart: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutSessionPage(
                      routine: routine,
                      assignmentId: assignment.id,
                    ),
                  ),
                );
              },
              onDismiss: () => _showDismissRoutineDialog(context, ref, assignment),
            ),
          ],
        );
      },
    );
  }

  /// Diálogo de confirmación para descartar rutina asignada
  void _showDismissRoutineDialog(
    BuildContext context,
    WidgetRef ref,
    AssignedRoutineModel assignment,
  ) {
    showDialog(
      context: context,
      builder: (context) => _DismissRoutineDialog(
        ref: ref,
        assignment: assignment,
      ),
    );
  }

  Widget _buildNoRoutineCard(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Icono con efecto glow
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sin rutina asignada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¿Qué parte del cuerpo quieres entrenar hoy?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Botón con gradiente
          GestureDetector(
            onTap: () => _showRoutineRequestDialog(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_task_rounded, color: Colors.black.withValues(alpha: 0.8)),
                  const SizedBox(width: 10),
                  Text(
                    'Solicitar Rutina al Coach',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildWeeklySection(WidgetRef ref) {
    final weeklyRoutineAsync = ref.watch(currentUserWeeklyRoutineProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Esta semana'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: weeklyRoutineAsync.when(
            data: (weekly) {
              if (weekly == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Sin rutina semanal asignada',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                );
              }

              final dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
              final today = DateTime.now().weekday;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final dayNumber = index + 1;
                  final hasRoutine = weekly.getRutinaDelDia(dayNumber) != null;
                  final isToday = dayNumber == today;
                  final isPast = dayNumber < today;

                  return _WeekDayIndicator(
                    day: dayNames[index],
                    hasRoutine: hasRoutine,
                    isToday: isToday,
                    isPast: isPast,
                  );
                }),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (_, _) => Center(
              child: Text(
                'Error al cargar',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(currentUserHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Tu historial'),
            GestureDetector(
              onTap: () => context.push(AppRoutes.clientHistoryFull),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver todo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        historyAsync.when(
          data: (history) {
            if (history.isEmpty) {
              return _buildEmptyHistoryCard();
            }
            // Mostrar solo los últimos 3 entrenamientos
            final recentHistory = history.take(3).toList();
            return Column(
              children: recentHistory.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CompactHistoryCard(history: item),
              )).toList(),
            );
          },
          loading: () => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (_, _) => _buildEmptyHistoryCard(),
        ),
      ],
    );
  }

  Widget _buildEmptyHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sin historial',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completa tu primer entrenamiento',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(UserModel user) {
    double? imc;
    IMCRange? rangoIMC;

    if (user.peso != null && user.altura != null && user.altura! > 0) {
      imc = UserModel.calcularIMC(user.peso!, user.altura!);
      rangoIMC = IMCRange.fromIMC(imc);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tu progreso'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ModernStatCard(
                icon: Icons.monitor_weight_rounded,
                value: user.peso?.toStringAsFixed(1) ?? '-',
                unit: 'kg',
                label: 'Peso',
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernStatCard(
                icon: Icons.calculate_rounded,
                value: imc?.toStringAsFixed(1) ?? '-',
                label: rangoIMC?.displayName ?? 'IMC',
                color: _getIMCColor(rangoIMC),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernStatCard(
                icon: Icons.local_fire_department_rounded,
                value: '${user.rachasDias}',
                unit: 'días',
                label: 'Racha',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getIMCColor(IMCRange? range) {
    switch (range) {
      case IMCRange.bajoPeso:
        return AppColors.info;
      case IMCRange.normal:
        return AppColors.success;
      case IMCRange.sobrepeso:
        return AppColors.warning;
      case IMCRange.obesidad:
        return AppColors.error;
      default:
        return Colors.white.withValues(alpha: 0.5);
    }
  }

  Widget _buildSuggestionsButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _openWhatsAppSuggestions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366), // WhatsApp green
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF25D366).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            const Text(
              'Enviar Sugerencias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsAppSuggestions(BuildContext context) async {
    const message = 'Hola! Tengo una sugerencia para el gimnasio:';
    final url = Uri.parse('https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No se pudo abrir WhatsApp'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showRoutineRequestDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _RoutineRequestDialog(ref: ref),
    );
  }
}

// ============ WIDGETS AUXILIARES ============

/// Reloj estilo iOS que se actualiza cada segundo
class _IOSClockWidget extends StatefulWidget {
  const _IOSClockWidget();

  @override
  State<_IOSClockWidget> createState() => _IOSClockWidgetState();
}

class _IOSClockWidgetState extends State<_IOSClockWidget> {
  late Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    ).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _timeStream,
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final hour = now.hour;
        final minute = now.minute.toString().padLeft(2, '0');

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$hour:$minute',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: -1,
                height: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ModernRoutineCard extends StatelessWidget {
  final RoutineModel routine;
  final Widget? expirationCountdown;
  final VoidCallback onStart;
  final VoidCallback? onDismiss;

  const _ModernRoutineCard({
    required this.routine,
    this.expirationCountdown,
    required this.onStart,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (expirationCountdown != null) ...[
                  expirationCountdown!,
                  const SizedBox(height: 16),
                ],

                // Header con icono, nombre y botón de descartar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.25),
                            AppColors.primary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routine.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _RoutineTag(
                                label: routine.parteDelCuerpo.displayName,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: 8),
                              _RoutineTag(
                                label: routine.dificultad.displayName,
                                color: _getDifficultyColor(routine.dificultad),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Botón para descartar rutina (solo si onDismiss está definido)
                    if (onDismiss != null)
                      GestureDetector(
                        onTap: onDismiss,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white.withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // Lista de ejercicios
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.list_alt_rounded,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${routine.ejercicios.length} ejercicios',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...routine.ejercicios.take(3).map((ejercicio) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ejercicio.machineName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${ejercicio.sets}x${ejercicio.reps}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      if (routine.ejercicios.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+${routine.ejercicios.length - 3} más',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Botón comenzar
          GestureDetector(
            onTap: onStart,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black.withValues(alpha: 0.8),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Comenzar Rutina',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(RoutineDifficulty difficulty) {
    switch (difficulty) {
      case RoutineDifficulty.principiante:
        return AppColors.success;
      case RoutineDifficulty.medio:
        return AppColors.warning;
      case RoutineDifficulty.avanzado:
      case RoutineDifficulty.experto:
        return AppColors.error;
    }
  }
}

class _RoutineTag extends StatelessWidget {
  final String label;
  final Color color;

  const _RoutineTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WeekDayIndicator extends StatelessWidget {
  final String day;
  final bool hasRoutine;
  final bool isToday;
  final bool isPast;

  const _WeekDayIndicator({
    required this.day,
    required this.hasRoutine,
    required this.isToday,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color? borderColor;
    List<BoxShadow>? shadows;

    if (isToday) {
      bgColor = AppColors.primary;
      textColor = Colors.black;
      shadows = [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (hasRoutine) {
      bgColor = isPast
          ? AppColors.success.withValues(alpha: 0.2)
          : AppColors.primary.withValues(alpha: 0.15);
      textColor = isPast ? AppColors.success : AppColors.primary;
      borderColor = isPast
          ? AppColors.success.withValues(alpha: 0.3)
          : AppColors.primary.withValues(alpha: 0.3);
    } else {
      bgColor = Colors.white.withValues(alpha: 0.05);
      textColor = Colors.white.withValues(alpha: 0.4);
      borderColor = Colors.white.withValues(alpha: 0.1);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: borderColor != null ? Border.all(color: borderColor) : null,
        boxShadow: shadows,
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: textColor,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String? unit;
  final String label;
  final Color color;

  const _ModernStatCard({
    required this.icon,
    required this.value,
    this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error al cargar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineLoadingCard extends StatelessWidget {
  const _RoutineLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando tu rutina...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpirationCountdown extends StatefulWidget {
  final AssignedRoutineModel assignment;

  const _ExpirationCountdown({required this.assignment});

  @override
  State<_ExpirationCountdown> createState() => _ExpirationCountdownState();
}

class _ExpirationCountdownState extends State<_ExpirationCountdown> {
  late Duration _timeRemaining;
  late Stream<int> _tickerStream;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.assignment.timeRemaining;
    _tickerStream = Stream.periodic(const Duration(seconds: 1), (x) => x);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _tickerStream,
      builder: (context, snapshot) {
        _timeRemaining = widget.assignment.timeRemaining;
        final isLowTime = _timeRemaining.inMinutes < 30;
        final isVeryLowTime = _timeRemaining.inMinutes < 10;

        Color indicatorColor;
        if (isVeryLowTime) {
          indicatorColor = AppColors.error;
        } else if (isLowTime) {
          indicatorColor = AppColors.warning;
        } else {
          indicatorColor = AppColors.success;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: indicatorColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: indicatorColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 18, color: indicatorColor),
              const SizedBox(width: 8),
              Text(
                'Expira en: ${_formatDuration(_timeRemaining)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: indicatorColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoutineRequestDialog extends StatefulWidget {
  final WidgetRef ref;

  const _RoutineRequestDialog({required this.ref});

  @override
  State<_RoutineRequestDialog> createState() => _RoutineRequestDialogState();
}

class _RoutineRequestDialogState extends State<_RoutineRequestDialog> {
  RequestedBodyPart? _selectedBodyPart;
  bool _isSubmitting = false;

  Future<void> _submitRequest() async {
    if (_selectedBodyPart == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor selecciona qué parte del cuerpo quieres entrenar'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final user = widget.ref.read(userModelProvider).value;
      if (user == null) throw Exception('Usuario no encontrado');

      final request = RoutineRequestModel(
        id: '',
        clienteId: user.uid,
        clienteNombre: user.nombre ?? 'Cliente',
        clientePhotoUrl: user.photoUrl,
        trainerId: null,
        parteDelCuerpo: _selectedBodyPart!,
        estado: RequestStatus.pendiente,
        fechaSolicitud: DateTime.now(),
      );

      await widget.ref.read(firebaseServiceProvider).createRoutineRequest(request);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Solicitud enviada al coach exitosamente'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar solicitud: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.25),
                            AppColors.primary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Solicitar Rutina',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '¿Qué quieres entrenar hoy?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Opciones
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: RequestedBodyPart.values.map((bodyPart) {
                    final isSelected = _selectedBodyPart == bodyPart;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedBodyPart = bodyPart),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.3),
                                    AppColors.primary.withValues(alpha: 0.15),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.15),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(bodyPart.emoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              bodyPart.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? AppColors.primary : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Botón enviar
                GestureDetector(
                  onTap: _isSubmitting ? null : _submitRequest,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: _isSubmitting
                          ? null
                          : const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                            ),
                      color: _isSubmitting ? Colors.white.withValues(alpha: 0.1) : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isSubmitting
                          ? null
                          : [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Enviar Solicitud',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black.withValues(alpha: 0.8),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Diálogo para confirmar el descarte de una rutina asignada
class _DismissRoutineDialog extends StatefulWidget {
  final WidgetRef ref;
  final AssignedRoutineModel assignment;

  const _DismissRoutineDialog({
    required this.ref,
    required this.assignment,
  });

  @override
  State<_DismissRoutineDialog> createState() => _DismissRoutineDialogState();
}

class _DismissRoutineDialogState extends State<_DismissRoutineDialog> {
  bool _isSubmitting = false;

  Future<void> _dismissRoutine() async {
    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      await widget.ref.read(firebaseServiceProvider).dismissAssignedRoutine(
        widget.assignment.id,
        widget.assignment.clienteId,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Rutina descartada. Puedes solicitar otra al coach.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descartar rutina: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.warning.withValues(alpha: 0.25),
                            AppColors.warning.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Descartar Rutina',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.assignment.rutinaNombre,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Mensaje de confirmación
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '¿Estás seguro de que quieres descartar esta rutina?',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Podrás solicitar otra rutina al coach o elegir una del catálogo.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    // Botón cancelar
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón confirmar
                    Expanded(
                      child: GestureDetector(
                        onTap: _isSubmitting ? null : _dismissRoutine,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: _isSubmitting
                                ? null
                                : LinearGradient(
                                    colors: [
                                      AppColors.error,
                                      AppColors.error.withValues(alpha: 0.8),
                                    ],
                                  ),
                            color: _isSubmitting
                                ? Colors.white.withValues(alpha: 0.1)
                                : null,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: _isSubmitting
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppColors.error.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Descartar',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Diálogo para confirmar el descarte de la rutina del día (plan semanal)
class _DismissTodayRoutineDialog extends StatelessWidget {
  final WidgetRef ref;
  final RoutineModel routine;

  const _DismissTodayRoutineDialog({
    required this.ref,
    required this.routine,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.warning.withValues(alpha: 0.25),
                            AppColors.warning.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Descartar Rutina',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            routine.nombre,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Mensaje de confirmación
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '¿No quieres hacer esta rutina hoy?',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Podrás solicitar otra rutina al coach o elegir una diferente del catálogo.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    // Botón cancelar
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón confirmar
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Marcar la rutina del día como descartada
                          ref.read(dismissTodayRoutineCardProvider.notifier).state = true;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Rutina descartada. Puedes solicitar otra al coach.'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.error,
                                AppColors.error.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Descartar',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderReadyNotification extends ConsumerStatefulWidget {
  final List<StoreOrderModel> orders;

  const _OrderReadyNotification({required this.orders});

  @override
  ConsumerState<_OrderReadyNotification> createState() => _OrderReadyNotificationState();
}

class _OrderReadyNotificationState extends ConsumerState<_OrderReadyNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) _hideNotification();
    });
  }

  void _hideNotification() {
    _controller.reverse().then((_) {
      if (mounted) setState(() => _isVisible = false);
    });
  }

  Future<void> _markAsReceived() async {
    try {
      for (final order in widget.orders) {
        await ref.read(firebaseServiceProvider).markOrderAsDelivered(order.id);
      }
      _hideNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.orders.length > 1
                  ? '${widget.orders.length} pedidos marcados como recibidos'
                  : 'Pedido marcado como recibido',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al marcar pedido: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final orderCount = widget.orders.length;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderCount > 1
                                      ? '¡$orderCount pedidos listos!'
                                      : '¡Tu pedido está listo!',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Recógelo en la tienda del gimnasio',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _hideNotification,
                            child: const Icon(Icons.close_rounded, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _markAsReceived,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.success,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                orderCount > 1
                                    ? 'Marcar como recibidos'
                                    : 'Marcar como recibido',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// FAB para volver al modo entrenador - SOLO para usuarios de prueba
class _TrainerModeFAB extends StatelessWidget {
  final WidgetRef ref;

  const _TrainerModeFAB({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 110),
      child: FloatingActionButton.extended(
        onPressed: () {
          // Limpiar caché de rol y modelo antes de cambiar de usuario
          ref.read(cachedUserRoleProvider.notifier).state = null;
          ref.read(cachedUserModelProvider.notifier).state = null;

          // Restablecer el ID de usuario activo a null (usuario real)
          ref.read(activeUserIdProvider.notifier).state = null;

          // Invalidar providers para forzar recarga con el usuario real
          ref.invalidate(userRoleProvider);
          ref.invalidate(userModelProvider);

          // Navegar al modo entrenador
          context.go('/trainer');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundDark,
        elevation: 8,
        icon: const Icon(Icons.admin_panel_settings_rounded),
        label: const Text(
          'Volver a Entrenador',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Widget de entrenamiento completado con auto-dismiss después de 5 segundos
class _WorkoutCompletedCard extends ConsumerStatefulWidget {
  final UserModel user;

  const _WorkoutCompletedCard({required this.user});

  @override
  ConsumerState<_WorkoutCompletedCard> createState() => _WorkoutCompletedCardState();
}

class _WorkoutCompletedCardState extends ConsumerState<_WorkoutCompletedCard> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss después de 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        ref.read(dismissCompletedWorkoutCardProvider.notifier).state = true;
      }
    });
  }

  void _dismiss() {
    ref.read(dismissCompletedWorkoutCardProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withValues(alpha: 0.15),
            AppColors.success.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Botón de cerrar (X) alineado a la derecha dentro del container
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 20,
                ),
              ),
            ),
          ),
          // Icono con efecto glow
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.3),
                  AppColors.success.withValues(alpha: 0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Entrenamiento completado!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ya completaste tu rutina de hoy',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Racha badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warning.withValues(alpha: 0.25),
                  AppColors.warning.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.user.rachasDias} días de racha',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Sigue así! Vuelve mañana para mantener tu racha.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget compacto para mostrar historial de entrenamientos en el home
class _CompactHistoryCard extends StatelessWidget {
  final TrainingHistory history;

  const _CompactHistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Fecha compacta
          Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: history.completada
                    ? [
                        AppColors.success.withValues(alpha: 0.25),
                        AppColors.success.withValues(alpha: 0.1),
                      ]
                    : [
                        AppColors.warning.withValues(alpha: 0.25),
                        AppColors.warning.withValues(alpha: 0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${history.fecha.day}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: history.completada ? AppColors.success : AppColors.warning,
                  ),
                ),
                Text(
                  DateFormat('MMM', 'es').format(history.fecha).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: history.completada ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Info del entrenamiento
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.rutinaNombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      history.duracionMinutos != null
                          ? '${history.duracionMinutos} min'
                          : '~60 min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      history.completada
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 13,
                      color: history.completada
                          ? AppColors.success
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      history.completada ? 'Completada' : 'Parcial',
                      style: TextStyle(
                        fontSize: 12,
                        color: history.completada
                            ? AppColors.success
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
