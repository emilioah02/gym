import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/app_providers.dart';

/// Shell de navegación para el entrenador con BottomNavigationBar flotante
/// Diseño moderno con glassmorphism y efectos 3D (mismo estilo que cliente)
class TrainerShell extends ConsumerStatefulWidget {
  final Widget child;
  final int currentIndex;

  const TrainerShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  ConsumerState<TrainerShell> createState() => _TrainerShellState();
}

class _TrainerShellState extends ConsumerState<TrainerShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    // Obtener el contador de notificaciones no leídas
    final unreadCount =
        ref.watch(unreadNotificationsCountProvider).valueOrNull ?? 0;

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
                  icon: Icons.people_rounded,
                  label: 'Clientes',
                  isSelected: widget.currentIndex == 0,
                  onTap: () => _onNavTap(0),
                ),
                _FloatingNavItem(
                  icon: Icons.fitness_center_rounded,
                  label: 'Rutinas',
                  isSelected: widget.currentIndex == 1,
                  onTap: () => _onNavTap(1),
                ),
                _FloatingNavItem(
                  icon: Icons.storefront_rounded,
                  label: 'Tienda',
                  isSelected: widget.currentIndex == 2,
                  onTap: () => _onNavTap(2),
                ),
                _FloatingNavItem(
                  icon: Icons.notifications_rounded,
                  label: 'Notif.',
                  isSelected: widget.currentIndex == 3,
                  onTap: () => _onNavTap(3),
                  badgeCount: unreadCount,
                ),
                _FloatingNavItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  isSelected: widget.currentIndex == 4,
                  onTap: () => _onNavTap(4),
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
        context.go(AppRoutes.trainerClients);
        break;
      case 1:
        context.go(AppRoutes.trainerRoutines);
        break;
      case 2:
        context.go(AppRoutes.trainerStore);
        break;
      case 3:
        context.go(AppRoutes.trainerNotifications);
        break;
      case 4:
        context.go(AppRoutes.trainerProfile);
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
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
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

/// Badge de notificaciones con diseño moderno
class _NotificationBadge extends StatelessWidget {
  final int count;

  const _NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    // Mostrar "99+" si hay más de 99 notificaciones
    final displayCount = count > 99 ? '99+' : count.toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.elasticOut,
      padding: EdgeInsets.symmetric(horizontal: count > 9 ? 5 : 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.error, AppColors.error.withValues(alpha: 0.85)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        displayCount,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
