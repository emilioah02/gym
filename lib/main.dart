import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mexican_bulking/app.dart';
import 'package:mexican_bulking/firebase_options.dart';
import 'package:mexican_bulking/core/services/notification_service.dart';

/// Mexican Bulking - Main Entry Point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Inicializar formateo de fechas para español
  await initializeDateFormatting('es');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar servicio de notificaciones push sin bloquear el inicio
  // Se ejecuta en segundo plano para que la UI se muestre inmediatamente
  NotificationService().initialize().catchError((e) {
    debugPrint('⚠️ Error inicializando notificaciones: $e');
  });

  runApp(const ProviderScope(child: MyApp()));
}
