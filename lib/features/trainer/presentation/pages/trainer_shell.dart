import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';

/// Shell de navegación para el entrenador con BottomNavigationBar
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
      body: widget.child,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassDark,
            border: Border(
              top: BorderSide(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.people_outline,
                    activeIcon: Icons.people,
                    label: 'Clientes',
                    isSelected: widget.currentIndex == 0,
                    onTap: () => _onNavTap(0),
                  ),
                  _NavItem(
                    icon: Icons.fitness_center_outlined,
                    activeIcon: Icons.fitness_center,
                    label: 'Rutinas',
                    isSelected: widget.currentIndex == 1,
                    onTap: () => _onNavTap(1),
                  ),
                  _NavItem(
                    icon: Icons.sports_gymnastics_outlined,
                    activeIcon: Icons.sports_gymnastics,
                    label: 'Máquinas',
                    isSelected: widget.currentIndex == 2,
                    onTap: () => _onNavTap(2),
                  ),
                  _NavItem(
                    icon: Icons.notifications_outlined,
                    activeIcon: Icons.notifications,
                    label: 'Notif.',
                    isSelected: widget.currentIndex == 3,
                    onTap: () => _onNavTap(3),
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Perfil',
                    isSelected: widget.currentIndex == 4,
                    onTap: () => _onNavTap(4),
                  ),
                ],
              ),
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
        context.go(AppRoutes.trainerMachines);
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
