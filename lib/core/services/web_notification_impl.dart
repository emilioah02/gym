// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

/// Audio element para reproducir sonido de notificación
html.AudioElement? _audioElement;

/// Flag para saber si el usuario ha interactuado con la página
bool _userHasInteracted = false;

/// Inicializar el sistema de audio para web
/// Debe llamarse después de la primera interacción del usuario
void initWebAudio() {
  if (_audioElement != null) return;

  try {
    _audioElement = html.AudioElement('/sounds/notification.mp3');
    _audioElement!.volume = 1.0;
    _audioElement!.preload = 'auto';
    _audioElement!.load();

    // Detectar interacción del usuario para habilitar audio
    _setupUserInteractionDetection();

    // Escuchar mensajes del Service Worker para reproducir sonido
    _setupServiceWorkerMessageListener();
  } catch (e) {
    // Error initializing audio
  }
}

/// Configurar listener para mensajes del Service Worker
void _setupServiceWorkerMessageListener() {
  try {
    // Escuchar mensajes del Service Worker
    html.window.navigator.serviceWorker?.addEventListener('message', (event) {
      final messageEvent = event as html.MessageEvent;
      final data = messageEvent.data;

      if (data is Map && data['type'] == 'PLAY_NOTIFICATION_SOUND') {
        // El Service Worker solicita reproducir sonido
        playWebNotificationSound();
        webVibrate();
      }
    });
  } catch (e) {
    // Service Worker messaging not supported
  }
}

/// Configurar detección de interacción del usuario
void _setupUserInteractionDetection() {
  if (_userHasInteracted) return;

  void markInteracted(html.Event e) {
    _userHasInteracted = true;
    // Pre-cargar el audio con un volumen muy bajo para "desbloquear" el audio
    try {
      if (_audioElement != null) {
        _audioElement!.volume = 0.01;
        _audioElement!.play().then((_) {
          _audioElement!.pause();
          _audioElement!.currentTime = 0;
          _audioElement!.volume = 1.0;
        }).catchError((_) {});
      }
    } catch (e) {
      // Ignore errors
    }
  }

  // Escuchar varios eventos de interacción
  html.document.addEventListener('click', markInteracted);
  html.document.addEventListener('touchstart', markInteracted);
  html.document.addEventListener('keydown', markInteracted);
}

/// Reproducir sonido de notificación en web
/// Funciona en Chrome, Safari y otros navegadores modernos
Future<void> playWebNotificationSound() async {
  try {
    // Método 1: Usar el elemento de audio existente
    if (_audioElement != null && _userHasInteracted) {
      _audioElement!.currentTime = 0;
      _audioElement!.volume = 1.0;
      await _audioElement!.play();
      return;
    }

    // Método 2: Crear nuevo elemento de audio (fallback)
    final audio = html.AudioElement('/sounds/notification.mp3');
    audio.volume = 1.0;

    // Intentar reproducir
    await audio.play();

    // Limpiar después de reproducir
    audio.onEnded.listen((_) {
      audio.remove();
    });
  } catch (e) {
    // Método 3: Usar JavaScript directo como último recurso
    try {
      js.context.callMethod('eval', ['''
        (function() {
          try {
            var audio = new Audio('/sounds/notification.mp3');
            audio.volume = 1.0;
            audio.play().catch(function(e) {
              console.log('Audio play failed:', e);
            });
          } catch(e) {
            console.log('Audio creation failed:', e);
          }
        })();
      ''']);
    } catch (e2) {
      // All methods failed
    }
  }
}

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

/// Mostrar notificación web con sonido y vibración
/// Esta es la función principal que debe usarse para mostrar notificaciones
Future<void> showWebNotificationWithSound(String title, String body) async {
  // Reproducir sonido primero (más importante)
  await playWebNotificationSound();

  // Vibrar
  webVibrate();

  // Mostrar notificación visual
  await showWebNotification(title, body);
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

    // Crear y mostrar la notificación con sonido
    // Nota: La propiedad 'silent: false' ayuda en algunos navegadores
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

/// Verificar si el audio está habilitado (usuario ha interactuado)
bool isWebAudioEnabled() {
  return _userHasInteracted;
}
