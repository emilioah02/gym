import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mexican_bulking/app.dart';
import 'package:mexican_bulking/firebase_options.dart';
import 'package:mexican_bulking/core/services/notification_service.dart';

/// Mexican Bulking - Main Entry Point
void main() async {
  // Capturar errores de zona para Crashlytics
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Usar URLs limpias sin hash (#) para web
    // Esto permite URLs como mexican-bulking.web.app/privacy
    usePathUrlStrategy();

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

    // Inicializar Crashlytics (solo en móvil, no en web)
    if (!kIsWeb) {
      // Capturar errores de Flutter
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Capturar errores async
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    // Inicializar servicio de notificaciones push sin bloquear el inicio
    // Se ejecuta en segundo plano para que la UI se muestre inmediatamente
    NotificationService().initialize().catchError((e) {
      debugPrint('⚠️ Error inicializando notificaciones: $e');
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      }
    });

    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    // Capturar errores de zona
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    debugPrint('🚨 Error capturado en zona: $error');
  });
}
