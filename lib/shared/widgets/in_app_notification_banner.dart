import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/typography.dart';
import '../../core/services/notification_service.dart';

/// Widget que muestra banners de notificaciones in-app
/// Debe envolver el contenido principal de la app
class InAppNotificationBanner extends StatefulWidget {
  final Widget child;

  const InAppNotificationBanner({
    super.key,
    required this.child,
  });

  @override
  State<InAppNotificationBanner> createState() => _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  StreamSubscription<InAppNotification>? _subscription;
  InAppNotification? _currentNotification;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  Timer? _autoHideTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _subscribeToNotifications();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  void _subscribeToNotifications() {
    _subscription = NotificationService.inAppNotifications.listen((notification) {
      _showNotification(notification);
    });
  }

  Future<void> _showNotification(InAppNotification notification) async {
    // Cancel any existing timer
    _autoHideTimer?.cancel();

    // Play notification sound
    await _playNotificationSound();

    setState(() {
      _currentNotification = notification;
    });

    // Animate in
    await _animationController.forward();

    // Auto-hide after 4 seconds
    _autoHideTimer = Timer(const Duration(seconds: 4), () {
      _hideNotification();
    });
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      // Si no existe el sonido, intentar con sonido del sistema
      debugPrint('⚠️ No se pudo reproducir sonido de notificación: $e');
    }
  }

  Future<void> _hideNotification() async {
    await _animationController.reverse();
    if (mounted) {
      setState(() {
        _currentNotification = null;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _autoHideTimer?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_currentNotification != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: SlideTransition(
              position: _slideAnimation,
              child: _NotificationCard(
                notification: _currentNotification!,
                onDismiss: _hideNotification,
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final InAppNotification notification;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final tipo = notification.tipo;
    final isOrder = tipo == 'nuevo_pedido';
    final isRoutine = tipo == 'rutina_asignada' || tipo == 'rutina';
    final isHelp = tipo == 'ayuda_ejercicio';

    Color accentColor;
    IconData icon;

    if (isOrder) {
      accentColor = AppColors.success;
      icon = Icons.shopping_cart;
    } else if (isRoutine) {
      accentColor = AppColors.primary;
      icon = Icons.assignment;
    } else if (isHelp) {
      accentColor = AppColors.warning;
      icon = Icons.help_outline;
    } else {
      accentColor = AppColors.info;
      icon = Icons.notifications;
    }

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onDismiss,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 100) {
            onDismiss();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      notification.title,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        notification.body,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Close button
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.textSecondaryDark,
                ),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
