import 'package:flutter/material.dart';
import 'trainer_help_notifications_page.dart';
import 'trainer_shell.dart';

/// Página de notificaciones de ayuda para el entrenador
/// Wraps TrainerHelpNotificationsPage with shell navigation
class TrainerNotificationsPage extends StatelessWidget {
  const TrainerNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TrainerShell(
      currentIndex: 3,
      child: TrainerHelpNotificationsPage(),
    );
  }
}
