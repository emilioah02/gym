#!/bin/bash

# Script para actualizar roles de usuarios usando Firebase REST API
# Requiere: firebase login ejecutado previamente

PROJECT_ID="mexican-bulking"

# Obtener access token
echo "🔐 Obteniendo token de acceso..."
ACCESS_TOKEN=$(firebase login:ci 2>&1 | grep -oP '1//.+' | head -1)

if [ -z "$ACCESS_TOKEN" ]; then
    echo "⚠️  No se pudo obtener el token. Asegúrate de estar logueado: firebase login"
    echo "📝 Alternativa: Actualiza manualmente en Firebase Console"
    echo "    https://console.firebase.google.com/project/mexican-bulking/firestore/data"
    exit 1
fi

echo "✅ Token obtenido"
echo ""
echo "🔄 Iniciando actualización de usuarios..."
echo "════════════════════════════════════════"

# Función para actualizar usuario
update_user_role() {
    local EMAIL=$1
    local ROLE=$2
    local EMOJI=$3

    echo ""
    echo "$EMOJI Actualizando: $EMAIL → rol: $ROLE"

    # En producción, aquí usarías la REST API de Firestore
    # Por ahora, solo mostramos las instrucciones
    echo "   ⏭️  Actualizar manualmente en Firebase Console"
}

# Entrenadores
echo ""
echo "👔 ENTRENADORES:"
echo "─────────────────────────────────────────"
update_user_role "emilioah02@gmail.com" "entrenador" "1️⃣"
update_user_role "diegopeniche.galindo25@gmail.com" "entrenador" "2️⃣"
update_user_role "penichealberto56@gmail.com" "entrenador" "3️⃣"

# Clientes
echo ""
echo "👤 CLIENTES:"
echo "─────────────────────────────────────────"
update_user_role "chapingoopen@gmail.com" "cliente" "4️⃣"
update_user_role "jack5591389@gmail.com" "cliente" "5️⃣"

echo ""
echo "════════════════════════════════════════"
echo ""
echo "📋 RESUMEN:"
echo "   Para actualizar estos usuarios, ve a:"
echo "   https://console.firebase.google.com/project/mexican-bulking/firestore/data"
echo ""
echo "   Y busca cada usuario en la colección 'users' por su email,"
echo "   luego actualiza el campo 'rol' con el valor correspondiente."
echo ""
