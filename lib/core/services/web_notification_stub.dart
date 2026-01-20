/// Stub implementation for non-web platforms
/// This file is used when the app is compiled for iOS/Android
library;

/// Inicializar el sistema de audio para web (no-op en plataformas no-web)
void initWebAudio() {
  // No-op on non-web platforms
}

/// Reproducir sonido de notificación en web (no-op en plataformas no-web)
Future<void> playWebNotificationSound() async {
  // No-op on non-web platforms
}

/// Vibrar en web (no-op en plataformas no-web)
void webVibrate() {
  // No-op on non-web platforms
}

/// Mostrar notificación web con sonido y vibración (no-op en plataformas no-web)
Future<void> showWebNotificationWithSound(String title, String body) async {
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

/// Verificar si el audio está habilitado (siempre true en no-web)
bool isWebAudioEnabled() {
  return true; // Always return true on non-web platforms
}
