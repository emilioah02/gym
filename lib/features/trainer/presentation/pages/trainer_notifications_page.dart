import 'package:flutter/material.dart';
import 'trainer_notifications_center_page.dart';
import 'trainer_shell.dart';

/// Página de notificaciones para el entrenador
/// Wraps TrainerNotificationsCenterPage with shell navigation
class TrainerNotificationsPage extends StatelessWidget {
  final int initialTab;

  const TrainerNotificationsPage({
    super.key,
    this.initialTab = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TrainerShell(
      currentIndex: 3,
      child: TrainerNotificationsCenterPage(initialTab: initialTab),
    );
  }
}
