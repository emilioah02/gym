import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, kDebugMode;
import 'package:flutter/services.dart';
import 'web_notification_stub.dart'
    if (dart.library.html) 'web_notification_impl.dart' as web_notif;

/// Modelo para notificaciones in-app
class InAppNotification {
  final String title;
  final String body;
  final String? tipo;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool playSound;
  final bool vibrate;

  InAppNotification({
    required this.title,
    required this.body,
    this.tipo,
    this.data,
    DateTime? timestamp,
    this.playSound = true,
    this.vibrate = true,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Servicio para gestionar notificaciones push con Firebase Cloud Messaging
/// Incluye soporte para notificaciones nativas del sistema, sonido y vibración
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream controller para notificaciones in-app
  static final StreamController<InAppNotification> _inAppNotificationController =
      StreamController<InAppNotification>.broadcast();

  /// Stream de notificaciones in-app para mostrar banners
  static Stream<InAppNotification> get inAppNotifications =>
      _inAppNotificationController.stream;

  /// Mostrar una notificación in-app con sonido y vibración
  static Future<void> showInAppNotification({
    required String title,
    required String body,
    String? tipo,
    Map<String, dynamic>? data,
    bool playSound = true,
    bool vibrate = true,
    bool showSystemNotification = true,
  }) async {
    // Agregar a la cola de notificaciones in-app
    _inAppNotificationController.add(InAppNotification(
      title: title,
      body: body,
      tipo: tipo,
      data: data,
      playSound: playSound,
      vibrate: vibrate,
    ));

    // Vibrar el dispositivo
    if (vibrate) {
      await _vibrateDevice();
    }

    // Mostrar notificación del sistema (nativa)
    if (showSystemNotification && kIsWeb) {
      await web_notif.showWebNotification(title, body);
    }
  }

  /// Vibrar el dispositivo
  static Future<void> _vibrateDevice() async {
    try {
      if (kIsWeb) {
        // Vibración en web
        web_notif.webVibrate();
      } else {
        // Vibración en móvil usando HapticFeedback
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error al vibrar: $e');
    }
  }

  /// Solicitar permisos de notificación web
  static Future<bool> requestWebNotificationPermission() async {
    if (!kIsWeb) return true;
    return web_notif.requestWebNotificationPermission();
  }

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    try {
      // Solicitar permisos en web
      if (kIsWeb) {
        await requestWebNotificationPermission();
      } else {
        // Solicitar permisos en móvil
        await _requestMobilePermissions();
      }

      // Obtener el token FCM
      await getToken();

      // Configurar listeners para notificaciones
      _setupNotificationListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('Error inicializando notificaciones: $e');
    }
  }

  /// Solicitar permisos en móvil (iOS/Android)
  Future<void> _requestMobilePermissions() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) debugPrint('Notification permission: ${settings.authorizationStatus}');
    } catch (e) {
      if (kDebugMode) debugPrint('Error solicitando permisos: $e');
    }
  }

  /// Obtener el token FCM del dispositivo
  Future<String?> getToken() async {
    try {
      if (kIsWeb) {
        // Para web, necesitas configurar vapidKey
        return await _firebaseMessaging.getToken(
          vapidKey: 'BH7hosCs64NRmpORuyYAB0LLNkrgmSz5plfUlvpNx0A28BnYZHmD4u9YgSy6sQfeUmsNP3q9RAbFvFR9s68weiY',
        );
      } else {
        return await _firebaseMessaging.getToken();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error obteniendo FCM token: $e');
      return null;
    }
  }

  /// Guardar el token FCM en Firestore para el usuario
  Future<void> saveTokenForUser(String userId) async {
    final token = await getToken();
    if (token != null) {
      String platform = 'unknown';
      if (kIsWeb) {
        platform = 'web';
      } else {
        // Usar try-catch porque Platform no está disponible en web
        try {
          platform = _getPlatformName();
        } catch (_) {
          platform = 'mobile';
        }
      }

      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'platform': platform,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) debugPrint('Token guardado para usuario $userId');
    }
  }

  String _getPlatformName() {
    // Este método solo se llama en móvil, no en web
    return 'mobile';
  }

  /// Configurar listeners para notificaciones
  void _setupNotificationListeners() {
    // Cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message, inForeground: true);
    });

    // Cuando el usuario toca una notificación (app en background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message, inForeground: false);
    });

    // Verificar si la app fue abierta por una notificación
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleMessage(message, inForeground: false);
      }
    });
  }

  /// Manejar el mensaje recibido
  void _handleMessage(RemoteMessage message, {bool inForeground = true}) {
    final title = message.notification?.title ?? 'Nueva notificación';
    final body = message.notification?.body ?? '';
    final tipo = message.data['tipo'] as String?;

    // Mostrar banner in-app con sonido y vibración
    showInAppNotification(
      title: title,
      body: body,
      tipo: tipo,
      data: message.data,
      playSound: true,
      vibrate: true,
      // Solo mostrar notificación del sistema si está en background
      showSystemNotification: !inForeground,
    );
  }

  /// Enviar notificación push a un usuario específico
  Future<void> sendPushNotification({
    required String recipientUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Obtener el token FCM del usuario receptor
      final userDoc = await _firestore.collection('users').doc(recipientUserId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null) {
        return;
      }

      // Crear el documento de notificación para que Cloud Functions lo procese
      await _firestore.collection('push_notifications').add({
        'to': fcmToken,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data ?? {},
        'priority': 'high',
        'android': {
          'priority': 'high',
          'notification': {
            'sound': 'default',
            'defaultSound': true,
            'defaultVibrateTimings': true,
            'channelId': 'high_importance_channel',
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'sound': 'default',
              'badge': 1,
            },
          },
        },
        'webpush': {
          'notification': {
            'icon': '/icons/Icon-192.png',
            'badge': '/icons/Icon-192.png',
            'vibrate': [200, 100, 200],
            'requireInteraction': true,
          },
        },
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });

    } catch (e) {
      if (kDebugMode) debugPrint('Error enviando notificación push: $e');
    }
  }

  /// Suscribirse a un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      if (kDebugMode) debugPrint('Error suscribiéndose al topic $topic: $e');
    }
  }

  /// Desuscribirse de un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      if (kDebugMode) debugPrint('Error desuscribiéndose del topic $topic: $e');
    }
  }

  /// Eliminar el token FCM del usuario (al cerrar sesión)
  Future<void> removeTokenForUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
      await _firebaseMessaging.deleteToken();
    } catch (e) {
      if (kDebugMode) debugPrint('Error eliminando token: $e');
    }
  }
}
