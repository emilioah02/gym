import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Modelo para notificaciones in-app
class InAppNotification {
  final String title;
  final String body;
  final String? tipo;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  InAppNotification({
    required this.title,
    required this.body,
    this.tipo,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Servicio para gestionar notificaciones push con Firebase Cloud Messaging
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream controller para notificaciones in-app
  static final StreamController<InAppNotification> _inAppNotificationController =
      StreamController<InAppNotification>.broadcast();

  /// Stream de notificaciones in-app para mostrar banners
  static Stream<InAppNotification> get inAppNotifications =>
      _inAppNotificationController.stream;

  /// Mostrar una notificación in-app
  static void showInAppNotification({
    required String title,
    required String body,
    String? tipo,
    Map<String, dynamic>? data,
  }) {
    _inAppNotificationController.add(InAppNotification(
      title: title,
      body: body,
      tipo: tipo,
      data: data,
    ));
  }

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    // Solicitar permisos en iOS
    if (!kIsWeb && Platform.isIOS) {
      await _requestIOSPermissions();
    }

    // Solicitar permisos en Android 13+
    if (!kIsWeb && Platform.isAndroid) {
      await _requestAndroidPermissions();
    }

    // Obtener el token FCM
    final token = await getToken();
    if (token != null) {
      print('📱 FCM Token: $token');
    }

    // Configurar listeners para notificaciones
    _setupNotificationListeners();
  }

  /// Solicitar permisos en iOS
  Future<void> _requestIOSPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('📱 iOS Notification permission: ${settings.authorizationStatus}');
  }

  /// Solicitar permisos en Android
  Future<void> _requestAndroidPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('📱 Android Notification permission: ${settings.authorizationStatus}');
  }

  /// Obtener el token FCM del dispositivo
  Future<String?> getToken() async {
    try {
      if (kIsWeb) {
        // Para web, necesitas configurar vapidKey
        // Genera tu VAPID key en: Firebase Console > Project Settings > Cloud Messaging > Web Push certificates
        // Instrucciones completas en: NOTIFICACIONES_WEB_SETUP.md
        return await _firebaseMessaging.getToken(
          vapidKey: 'BH7hosCs64NRmpORuyYAB0LLNkrgmSz5plfUlvpNx0A28BnYZHmD4u9YgSy6sQfeUmsNP3q9RAbFvFR9s68weiY',
        );
      } else {
        return await _firebaseMessaging.getToken();
      }
    } catch (e) {
      print('❌ Error obteniendo FCM token: $e');
      if (kIsWeb) {
        print('💡 Para web: Asegúrate de haber configurado el VAPID key en Firebase Console');
        print('📖 Lee NOTIFICACIONES_WEB_SETUP.md para más detalles');
      }
      return null;
    }
  }

  /// Guardar el token FCM en Firestore para el usuario
  Future<void> saveTokenForUser(String userId) async {
    final token = await getToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Token guardado para usuario $userId');
    }
  }

  /// Configurar listeners para notificaciones
  void _setupNotificationListeners() {
    // Cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Mensaje recibido en foreground: ${message.notification?.title}');
      _handleMessage(message);
    });

    // Cuando el usuario toca una notificación (app en background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Notificación tocada (background): ${message.notification?.title}');
      _handleMessage(message);
    });

    // Verificar si la app fue abierta por una notificación
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📬 App abierta por notificación: ${message.notification?.title}');
        _handleMessage(message);
      }
    });
  }

  /// Manejar el mensaje recibido
  void _handleMessage(RemoteMessage message) {
    print('📬 Datos del mensaje: ${message.data}');

    // Mostrar banner in-app
    final title = message.notification?.title ?? 'Nueva notificación';
    final body = message.notification?.body ?? '';
    final tipo = message.data['tipo'] as String?;

    showInAppNotification(
      title: title,
      body: body,
      tipo: tipo,
      data: message.data,
    );

    // Log según el tipo de notificación
    switch (tipo) {
      case 'ayuda_ejercicio':
        print('🏋️ Cliente solicita ayuda con ejercicio');
        break;
      case 'rutina_asignada':
        print('📋 Nueva rutina asignada');
        break;
      case 'nuevo_pedido':
        print('🛒 Nuevo pedido recibido');
        break;
      default:
        print('📬 Tipo de notificación: $tipo');
    }
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
        print('⚠️ Usuario $recipientUserId no tiene token FCM registrado');
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
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });

      print('✅ Notificación push encolada para $recipientUserId');
    } catch (e) {
      print('❌ Error enviando notificación push: $e');
    }
  }

  /// Suscribirse a un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Suscrito al topic: $topic');
    } catch (e) {
      print('❌ Error suscribiéndose al topic $topic: $e');
    }
  }

  /// Desuscribirse de un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Desuscrito del topic: $topic');
    } catch (e) {
      print('❌ Error desuscribiéndose del topic $topic: $e');
    }
  }

  /// Eliminar el token FCM del usuario (al cerrar sesión)
  Future<void> removeTokenForUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
      await _firebaseMessaging.deleteToken();
      print('✅ Token FCM eliminado para usuario $userId');
    } catch (e) {
      print('❌ Error eliminando token: $e');
    }
  }
}
