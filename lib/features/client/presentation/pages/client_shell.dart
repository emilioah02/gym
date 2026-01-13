import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/notification_service.dart';

/// Shell de navegación para el cliente con BottomNavigationBar flotante
/// Diseño moderno con glassmorphism y efectos 3D
/// Incluye listener para notificaciones en tiempo real
class ClientShell extends ConsumerStatefulWidget {
  final Widget child;
  final int currentIndex;

  const ClientShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  ConsumerState<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends ConsumerState<ClientShell> {
  List<AnnouncementModel> _previousAnnouncements = [];
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // Solicitar permisos de notificación web al cargar
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    await NotificationService.requestWebNotificationPermission();
  }

  void _checkForNewAnnouncements(List<AnnouncementModel> currentAnnouncements) {
    if (_isFirstLoad) {
      _previousAnnouncements = List.from(currentAnnouncements);
      _isFirstLoad = false;
      return;
    }

    // Encontrar nuevos anuncios (que no existían antes)
    for (final announcement in currentAnnouncements) {
      final isNew = !_previousAnnouncements.any((prev) => prev.id == announcement.id);

      if (isNew) {
        // Mostrar notificación in-app para el nuevo anuncio
        NotificationService.showInAppNotification(
          title: announcement.titulo,
          body: announcement.mensaje,
          tipo: announcement.tipo.name,
          playSound: true,
          vibrate: true,
          showSystemNotification: true,
        );
      }
    }

    _previousAnnouncements = List.from(currentAnnouncements);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the unread announcements count
    final unreadCountAsync = ref.watch(unreadAnnouncementsCountProvider);

    // Watch announcements para detectar nuevos
    // Usa currentUserAnnouncementsProvider que ya considera el activeUserIdProvider
    final announcementsAsync = ref.watch(currentUserAnnouncementsProvider);
    announcementsAsync.whenData((announcements) {
      // Verificar si hay nuevos anuncios después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForNewAnnouncements(announcements);
      });
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: _buildFloatingNavBar(unreadCountAsync),
    );
  }

  Widget _buildFloatingNavBar(AsyncValue<int> unreadCountAsync) {
    final unreadCount = unreadCountAsync.value ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
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
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FloatingNavItem(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  isSelected: widget.currentIndex == 0,
                  onTap: () => _onNavTap(0),
                ),
                _FloatingNavItem(
                  icon: Icons.explore_rounded,
                  label: 'Explorar',
                  isSelected: widget.currentIndex == 1,
                  onTap: () => _onNavTap(1),
                ),
                _FloatingNavItem(
                  icon: Icons.store_rounded,
                  label: 'Tienda',
                  isSelected: widget.currentIndex == 4,
                  onTap: () => _onNavTap(4),
                ),
                _FloatingNavItem(
                  icon: Icons.notifications_rounded,
                  label: 'Avisos',
                  isSelected: widget.currentIndex == 2,
                  onTap: () => _onNavTap(2),
                  badgeCount: unreadCount,
                ),
                _FloatingNavItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  isSelected: widget.currentIndex == 3,
                  onTap: () => _onNavTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == widget.currentIndex) return;

    switch (index) {
      case 0:
        context.go(AppRoutes.clientHome);
        break;
      case 1:
        context.go(AppRoutes.clientExplore);
        break;
      case 2:
        context.go(AppRoutes.clientNotifications);
        break;
      case 3:
        context.go(AppRoutes.clientProfile);
        break;
      case 4:
        context.go(AppRoutes.clientStore);
        break;
    }
  }
}

class _FloatingNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _FloatingNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  State<_FloatingNavItem> createState() => _FloatingNavItemState();
}

class _FloatingNavItemState extends State<_FloatingNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSelected ? 16 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.primary.withValues(alpha: 0.15),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, widget.isSelected ? -2.0 : 0.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.5),
                      size: widget.isSelected ? 26 : 24,
                    ),
                    // Badge de notificaciones
                    if (widget.badgeCount > 0)
                      Positioned(
                        right: -8,
                        top: -6,
                        child: _NotificationBadge(count: widget.badgeCount),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: widget.isSelected
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: widget.isSelected ? 11 : 10,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: widget.isSelected ? 0.5 : 0,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge animado para mostrar el contador de notificaciones
class _NotificationBadge extends StatefulWidget {
  final int count;

  const _NotificationBadge({required this.count});

  @override
  State<_NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<_NotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4444), Color(0xFFFF6B6B)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4444).withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: AppColors.backgroundDark,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                widget.count > 99 ? '99+' : widget.count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
