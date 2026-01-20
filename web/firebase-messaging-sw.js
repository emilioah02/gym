// Firebase Cloud Messaging Service Worker
// Este archivo maneja las notificaciones push en segundo plano para la web
// Soporta sonido y vibración en Chrome, Safari y otros navegadores modernos

importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Configuración de Firebase (debe coincidir con firebase_options.dart)
firebase.initializeApp({
  apiKey: "AIzaSyD0yU1pR14CELHcCY032UszE-qCJwQQmOI",
  authDomain: "mexican-bulking.firebaseapp.com",
  projectId: "mexican-bulking",
  storageBucket: "mexican-bulking.firebasestorage.app",
  messagingSenderId: "589672531910",
  appId: "1:589672531910:web:8aa4d474b4abf7751a94c7",
  measurementId: "G-MX3MK6Y9YJ"
});

const messaging = firebase.messaging();

// Función para reproducir sonido de notificación
// Usa fetch + AudioContext para máxima compatibilidad
async function playNotificationSound() {
  try {
    // Método 1: Intentar reproducir usando el cliente activo
    const clients = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });

    for (const client of clients) {
      // Enviar mensaje al cliente para que reproduzca el sonido
      client.postMessage({
        type: 'PLAY_NOTIFICATION_SOUND',
        timestamp: Date.now()
      });
    }

    // Si hay clientes activos, el sonido se reproducirá desde la página
    if (clients.length > 0) {
      console.log('[SW] Mensaje enviado a cliente para reproducir sonido');
      return;
    }

    // Método 2: Si no hay clientes, intentar vibrar (funciona en algunos navegadores)
    if (self.registration && self.registration.showNotification) {
      // La vibración se maneja en las opciones de la notificación
      console.log('[SW] Sin clientes activos, usando vibración de notificación');
    }
  } catch (e) {
    console.log('[SW] Error reproduciendo sonido:', e);
  }
}

// Obtener configuración de notificación según el tipo
function getNotificationConfig(tipo) {
  const configs = {
    'solicitud_rutina': {
      icon: '💪',
      defaultTitle: '💪 Nueva Solicitud de Rutina',
      defaultBody: 'Un cliente solicita una rutina de entrenamiento',
      url: '/trainer/requests',
      actionTitle: '📋 Ver Solicitud'
    },
    'ayuda_ejercicio': {
      icon: '🆘',
      defaultTitle: '🆘 Solicitud de Ayuda',
      defaultBody: 'Un cliente necesita asistencia',
      url: '/trainer/notifications',
      actionTitle: '👁️ Ver Cliente'
    },
    'anuncio': {
      icon: '📢',
      defaultTitle: '📢 Nuevo Anuncio',
      defaultBody: 'Tienes un nuevo anuncio del gimnasio',
      url: '/client/notifications',
      actionTitle: '📖 Ver Anuncio'
    },
    'nuevo_pedido': {
      icon: '🛒',
      defaultTitle: '🛒 Nuevo Pedido',
      defaultBody: 'Has recibido un nuevo pedido',
      url: '/trainer/orders',
      actionTitle: '📦 Ver Pedido'
    },
    'rutina_asignada': {
      icon: '🏋️',
      defaultTitle: '🏋️ Rutina Asignada',
      defaultBody: 'Te han asignado una nueva rutina',
      url: '/client/training',
      actionTitle: '💪 Ver Rutina'
    }
  };

  return configs[tipo] || {
    icon: '🔔',
    defaultTitle: '🔔 Nueva Notificación',
    defaultBody: 'Tienes una nueva notificación',
    url: '/',
    actionTitle: '👁️ Ver'
  };
}

// Manejar notificaciones en segundo plano (cuando la app está cerrada o minimizada)
messaging.onBackgroundMessage(async (payload) => {
  console.log('[firebase-messaging-sw.js] Notificación recibida en background:', payload);

  const tipo = payload.data?.tipo || 'notification';
  const config = getNotificationConfig(tipo);

  const notificationTitle = payload.notification?.title || config.defaultTitle;
  const notificationBody = payload.notification?.body || config.defaultBody;

  // Intentar reproducir sonido
  await playNotificationSound();

  const notificationOptions = {
    body: notificationBody,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',

    // Vibración (patrón: vibrar 200ms, pausa 100ms, vibrar 200ms)
    vibrate: [200, 100, 200, 100, 200],

    // Mantener la notificación visible hasta que el usuario la cierre
    requireInteraction: true,

    // Tag para agrupar notificaciones del mismo tipo
    tag: tipo,

    // Datos adicionales que se pueden usar al hacer clic
    data: {
      url: payload.data?.url || config.url,
      tipo: tipo,
      clienteId: payload.data?.clienteId,
      clienteNombre: payload.data?.clienteNombre,
      ejercicioNombre: payload.data?.ejercicioNombre,
      rutinaNombre: payload.data?.rutinaNombre,
      requestId: payload.data?.requestId,
      anuncioId: payload.data?.anuncioId,
      orderId: payload.data?.orderId,
    },

    // Acciones personalizadas en la notificación
    actions: [
      {
        action: 'open',
        title: config.actionTitle,
        icon: '/icons/Icon-192.png'
      },
      {
        action: 'close',
        title: '❌ Cerrar',
        icon: '/icons/Icon-192.png'
      }
    ],

    // NO silencioso - queremos sonido del sistema si está disponible
    silent: false,

    // Tiempo de creación
    timestamp: Date.now(),
  };

  // Mostrar la notificación
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Manejar el clic en la notificación
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notificación clickeada:', event);

  event.notification.close();

  const action = event.action;
  const data = event.notification.data || {};

  // Si el usuario presiona "Cerrar", solo cerramos
  if (action === 'close') {
    return;
  }

  // Construir la URL a la que navegar según el tipo de notificación
  let urlToOpen = '/';

  if (action === 'open') {
    // Determinar URL basada en el tipo de notificación
    switch (data.tipo) {
      case 'solicitud_rutina':
        // Navegar a solicitudes de rutina o al perfil del cliente
        if (data.clienteId) {
          urlToOpen = `/trainer/client-profile/${data.clienteId}`;
        } else {
          urlToOpen = '/trainer/requests';
        }
        break;
      case 'ayuda_ejercicio':
        if (data.clienteId) {
          urlToOpen = `/trainer/client-profile/${data.clienteId}`;
        } else {
          urlToOpen = '/trainer/notifications';
        }
        break;
      case 'anuncio':
        urlToOpen = '/client/notifications';
        break;
      case 'nuevo_pedido':
        urlToOpen = '/trainer/orders';
        break;
      case 'rutina_asignada':
        urlToOpen = '/client/training';
        break;
      default:
        urlToOpen = data.url || '/';
    }
  } else if (data.url) {
    // Usar la URL proporcionada en los datos
    urlToOpen = data.url;
  } else {
    // Fallback basado en tipo
    const config = getNotificationConfig(data.tipo);
    urlToOpen = config.url;
  }

  // Abrir la app o navegar a la URL
  event.waitUntil(
    clients.matchAll({
      type: 'window',
      includeUncontrolled: true
    }).then((clientList) => {
      // Si ya hay una ventana abierta, enfocarla y navegar
      for (let i = 0; i < clientList.length; i++) {
        const client = clientList[i];
        if (client.url.includes(self.registration.scope) && 'focus' in client) {
          client.focus();
          return client.navigate(urlToOpen);
        }
      }

      // Si no hay ventana abierta, abrir una nueva
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen);
      }
    })
  );
});

// Manejar el cierre de la notificación
self.addEventListener('notificationclose', (event) => {
  console.log('[firebase-messaging-sw.js] Notificación cerrada:', event.notification.data);

  // Aquí podrías enviar analytics o marcar la notificación como vista
  // Por ejemplo, hacer un fetch a tu backend

  event.waitUntil(
    Promise.resolve()
  );
});

// Log de instalación del Service Worker
self.addEventListener('install', (event) => {
  console.log('[firebase-messaging-sw.js] Service Worker instalado');
  self.skipWaiting();
});

// Log de activación del Service Worker
self.addEventListener('activate', (event) => {
  console.log('[firebase-messaging-sw.js] Service Worker activado');
  event.waitUntil(self.clients.claim());
});

console.log('[firebase-messaging-sw.js] Service Worker cargado correctamente 🚀');
