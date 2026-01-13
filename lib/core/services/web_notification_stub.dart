/// Stub implementation for non-web platforms
/// This file is used when the app is compiled for iOS/Android
library;

/// Vibrar en web (no-op en plataformas no-web)
void webVibrate() {
  // No-op on non-web platforms
}

/// Mostrar notificación web (no-op en plataformas no-web)
Future<void> showWebNotification(String title, String body) async {
  // No-op on non-web platforms
}

/// Solicitar permisos de notificación web (no-op en plataformas no-web)
Future<bool> requestWebNotificationPermission() async {
  return true; // Always return true on non-web platforms
}
