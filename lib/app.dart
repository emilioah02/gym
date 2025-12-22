
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mexican_bulking/core/providers/app_providers.dart';
import 'package:mexican_bulking/core/theme/theme.dart';
import 'package:mexican_bulking/shared/widgets/in_app_notification_banner.dart';


/// Root application widget
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider to get the configured GoRouter instance
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Mexican Bulking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) {
        // Wrap the app with the in-app notification banner
        return InAppNotificationBanner(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
