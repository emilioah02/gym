// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

/// Vibrar en web usando Navigator.vibrate
void webVibrate() {
  try {
    js.context.callMethod('eval', [
      'if (navigator.vibrate) navigator.vibrate([200, 100, 200]);'
    ]);
  } catch (e) {
    // Vibration not supported
  }
}

/// Mostrar notificación web usando la Web Notifications API
Future<void> showWebNotification(String title, String body) async {
  try {
    // Verificar permisos
    final permission = html.Notification.permission;

    if (permission == 'denied') {
      return;
    }

    if (permission != 'granted') {
      // Solicitar permiso
      final result = await html.Notification.requestPermission();
      if (result != 'granted') {
        return;
      }
    }

    // Crear y mostrar la notificación
    final notification = html.Notification(
      title,
      body: body,
      icon: '/icons/Icon-192.png',
      tag: 'gym-notification-${DateTime.now().millisecondsSinceEpoch}',
    );

    // Auto-cerrar después de 8 segundos
    Timer(const Duration(seconds: 8), () {
      notification.close();
    });

    // Manejar clic en la notificación
    notification.onClick.listen((event) {
      // Enfocar la ventana del navegador
      js.context.callMethod('eval', ['window.focus();']);
      notification.close();
    });

  } catch (e) {
    // Error showing notification
  }
}

/// Solicitar permisos de notificación web
Future<bool> requestWebNotificationPermission() async {
  try {
    final permission = html.Notification.permission;

    if (permission == 'granted') return true;
    if (permission == 'denied') return false;

    final result = await html.Notification.requestPermission();
    return result == 'granted';
  } catch (e) {
    return false;
  }
}
