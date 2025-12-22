// Firebase Cloud Messaging Service Worker
// Este archivo maneja las notificaciones push en segundo plano para la web

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

// Manejar notificaciones en segundo plano (cuando la app está cerrada o minimizada)
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Notificación recibida en background:', payload);

  const notificationTitle = payload.notification?.title || '🆘 Solicitud de Ayuda';
  const notificationBody = payload.notification?.body || 'Un cliente necesita asistencia';

  const notificationOptions = {
    body: notificationBody,
    icon: '/icons/Icon-192.png',  // Ícono de la notificación
    badge: '/icons/Icon-192.png', // Badge pequeño

    // 🔊 SONIDO - Reproducir sonido de notificación
    sound: '/sounds/notification.mp3',

    // Vibración (patrón: vibrar 200ms, pausa 100ms, vibrar 200ms)
    vibrate: [200, 100, 200],

    // Mantener la notificación visible hasta que el usuario la cierre
    requireInteraction: true,

    // Tag para agrupar notificaciones del mismo tipo
    tag: payload.data?.tipo || 'notification',

    // Datos adicionales que se pueden usar al hacer clic
    data: {
      url: payload.data?.url || '/trainer/notifications',
      tipo: payload.data?.tipo,
      clienteId: payload.data?.clienteId,
      clienteNombre: payload.data?.clienteNombre,
      ejercicioNombre: payload.data?.ejercicioNombre,
      rutinaNombre: payload.data?.rutinaNombre,
    },

    // Acciones personalizadas en la notificación
    actions: [
      {
        action: 'open',
        title: '👁️ Ver Cliente',
        icon: '/icons/Icon-192.png'
      },
      {
        action: 'close',
        title: '❌ Cerrar',
        icon: '/icons/Icon-192.png'
      }
    ],

    // Imagen grande (opcional)
    // image: '/images/notification-banner.png',

    // Silencioso o no
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
  const data = event.notification.data;

  // Si el usuario presiona "Cerrar", solo cerramos
  if (action === 'close') {
    return;
  }

  // Construir la URL a la que navegar
  let urlToOpen = '/';

  if (action === 'open' && data.clienteId) {
    // Navegar al perfil del cliente
    urlToOpen = `/trainer/client-profile/${data.clienteId}`;
  } else if (data.url) {
    // Usar la URL proporcionada en los datos
    urlToOpen = data.url;
  } else if (data.tipo === 'ayuda_ejercicio') {
    // Navegar a notificaciones de ayuda
    urlToOpen = '/trainer/notifications';
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
