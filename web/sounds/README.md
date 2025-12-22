# 🔊 Archivos de Sonido para Notificaciones Web

## 📁 Contenido de esta carpeta

Esta carpeta debe contener el archivo de sonido que se reproducirá cuando llegue una notificación push en la versión web de la aplicación.

## 📥 Cómo Obtener el Archivo de Sonido

### Opción 1: Descargar Sonido Gratuito (Recomendado)

Visita uno de estos sitios para descargar un sonido de notificación:

1. **Pixabay** (gratis, sin atribución): https://pixabay.com/sound-effects/search/notification/
2. **Freesound** (gratis, requiere cuenta): https://freesound.org/search/?q=notification
3. **Zapsplat** (gratis, requiere cuenta): https://www.zapsplat.com/sound-effect-category/notifications/
4. **Notification Sounds** (gratis): https://notificationsounds.com/

**Buscar términos**:
- "notification sound"
- "alert sound"
- "ping"
- "ding"
- "bell"

### Opción 2: Usar Sonido del Sistema

Puedes usar sonidos de iOS o Android:

**iOS**:
- Ubicación en Mac: `/System/Library/Audio/UISounds/`
- Sonidos populares: `sms-received1.caf`, `tweet_sent.caf`

**Android**:
- Ubicación: `/system/media/audio/notifications/`
- Sonidos populares: `pixie_dust.ogg`, `when.ogg`

**IMPORTANTE**: Debes convertirlos a `.mp3` para compatibilidad web.

### Opción 3: Generar Tu Propio Sonido

Usa herramientas online para crear sonidos personalizados:
- **BeepBox**: https://www.beepbox.co/
- **ChipTone**: https://sfbgames.itch.io/chiptone
- **AudioMass** (editor): https://audiomass.co/

## ✅ Archivo Requerido

**Nombre**: `notification.mp3`

**Especificaciones recomendadas**:
- Formato: MP3
- Duración: 0.5 - 2 segundos
- Tamaño: < 50 KB
- Bitrate: 128 kbps o menos
- Frecuencia: 44.1 kHz

## 🔧 Cómo Agregar el Archivo

1. Descarga tu sonido de notificación favorito
2. Conviértelo a MP3 si no lo está (usa https://cloudconvert.com/to/mp3)
3. Renómbralo a `notification.mp3`
4. Cópialo a esta carpeta: `web/sounds/notification.mp3`

```bash
# Ejemplo en terminal:
cp ~/Downloads/mi-sonido.mp3 web/sounds/notification.mp3
```

## 🧪 Probar el Sonido

Puedes probar si el sonido funciona creando un archivo HTML simple:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Test Sonido</title>
</head>
<body>
  <h1>Prueba de Sonido de Notificación</h1>
  <button onclick="playSound()">▶️ Reproducir Sonido</button>

  <script>
    function playSound() {
      const audio = new Audio('notification.mp3');
      audio.play();
    }
  </script>
</body>
</html>
```

Guarda esto como `test.html` en la misma carpeta y ábrelo en el navegador.

## 📋 Checklist

- [ ] Descargar sonido de notificación
- [ ] Convertir a MP3 (si es necesario)
- [ ] Renombrar a `notification.mp3`
- [ ] Copiar a `web/sounds/notification.mp3`
- [ ] Probar con `test.html`
- [ ] Verificar que el tamaño sea < 50 KB

## 🎵 Sonidos Recomendados por Tipo

### Para Solicitud de Ayuda (actual):
- **Tono**: Urgente pero no alarmante
- **Duración**: 1-1.5 segundos
- **Estilo**: Doble ping, campana suave

### Para Rutina Asignada:
- **Tono**: Positivo y motivador
- **Duración**: 0.5-1 segundo
- **Estilo**: Ding, chime ascendente

### Para Pedido de Tienda:
- **Tono**: Neutral e informativo
- **Duración**: 0.5-1 segundo
- **Estilo**: Single ping, blip

## 🔇 Troubleshooting

### "El sonido no se reproduce"
✅ Verifica que el archivo se llame exactamente `notification.mp3`
✅ Verifica que esté en la carpeta `web/sounds/`
✅ Asegúrate de que sea un archivo MP3 válido
✅ Prueba con el archivo `test.html`

### "El sonido suena distorsionado"
✅ Reduce el bitrate a 128 kbps o menos
✅ Asegúrate de que la duración sea < 2 segundos
✅ Convierte de nuevo con un conversor diferente

### "El archivo es muy grande"
✅ Usa un conversor para reducir el bitrate
✅ Recorta la duración a 0.5-1.5 segundos
✅ Usa herramientas de compresión de audio

## 📚 Recursos Adicionales

- **Convertir audio online**: https://cloudconvert.com/
- **Editar audio online**: https://audiomass.co/
- **Comprimir audio**: https://www.mp3smaller.com/
- **Recortar audio**: https://mp3cut.net/

---

**Nota**: Una vez agregado el archivo `notification.mp3`, el Service Worker lo reproducirá automáticamente cuando llegue una notificación push, incluso si la app web está cerrada.
