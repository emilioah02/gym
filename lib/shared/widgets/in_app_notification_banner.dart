import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/services/notification_service.dart';

/// Widget que muestra banners de notificaciones in-app con efectos premium
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
    with TickerProviderStateMixin {
  StreamSubscription<InAppNotification>? _subscription;
  InAppNotification? _currentNotification;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  Timer? _autoHideTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _subscribeToNotifications();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
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
    if (notification.playSound) {
      await _playNotificationSound();
    }

    // Vibrate device
    if (notification.vibrate) {
      await HapticFeedback.heavyImpact();
    }

    setState(() {
      _currentNotification = notification;
    });

    // Animate in
    await _animationController.forward();

    // Auto-hide after 5 seconds
    _autoHideTimer = Timer(const Duration(seconds: 5), () {
      _hideNotification();
    });
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      // Si no existe el sonido personalizado, usar el sonido del sistema
      debugPrint('Usando sonido del sistema: $e');
      try {
        // Intentar vibración háptica como fallback
        await HapticFeedback.mediumImpact();
      } catch (_) {}
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
    _pulseController.dispose();
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
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            right: 12,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: _NotificationCard(
                      notification: _currentNotification!,
                      onDismiss: _hideNotification,
                    ),
                  ),
                ),
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
    final isOrder = tipo == 'nuevo_pedido' || tipo == 'pedido_listo';
    final isRoutine = tipo == 'rutina_asignada' || tipo == 'rutina';
    final isRoutineRequest = tipo == 'solicitud_rutina';
    final isHelp = tipo == 'ayuda_ejercicio';
    final isAnnouncement = tipo == 'anuncio' || tipo == 'oferta' || tipo == 'promocion' || tipo == 'aviso' || tipo == 'informacion';

    Color accentColor;
    IconData icon;
    List<Color> gradientColors;

    if (isOrder) {
      accentColor = AppColors.success;
      icon = Icons.shopping_cart_rounded;
      gradientColors = [const Color(0xFF4CAF50), const Color(0xFF81C784)];
    } else if (isRoutineRequest) {
      // Solicitud de rutina de un cliente - color llamativo para el entrenador
      accentColor = const Color(0xFFE91E63); // Pink
      icon = Icons.fitness_center_rounded;
      gradientColors = [const Color(0xFFE91E63), const Color(0xFFF48FB1)];
    } else if (isRoutine) {
      accentColor = AppColors.primary;
      icon = Icons.fitness_center_rounded;
      gradientColors = [AppColors.primary, AppColors.primaryLight];
    } else if (isHelp) {
      accentColor = AppColors.warning;
      icon = Icons.help_rounded;
      gradientColors = [const Color(0xFFFF9800), const Color(0xFFFFB74D)];
    } else if (isAnnouncement) {
      accentColor = AppColors.info;
      icon = Icons.campaign_rounded;
      gradientColors = [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
    } else {
      accentColor = AppColors.info;
      icon = Icons.notifications_rounded;
      gradientColors = [const Color(0xFF9C27B0), const Color(0xFFBA68C8)];
    }

    return GestureDetector(
      onTap: onDismiss,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 100) {
          onDismiss();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 4),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon con gradiente
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
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
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notification.body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Ahora',
                              style: AppTypography.labelSmall.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Toca para cerrar',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondaryDark.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Close button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textSecondaryDark,
                    ),
                    onPressed: onDismiss,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
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
