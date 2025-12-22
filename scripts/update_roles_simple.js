/**
 * Script simple para actualizar roles usando Firebase CLI
 * El usuario debe estar autenticado con: firebase login
 */

const { execSync } = require('child_process');

// Configuración de usuarios
const USERS_CONFIG = {
  trainers: [
    'emilioah02@gmail.com',
    'diegopeniche.galindo25@gmail.com',
    'penichealberto56@gmail.com'
  ],
  clients: [
    'chapingoopen@gmail.com',
    'jack5591389@gmail.com'
  ]
};

console.log('🔄 Generando comandos de actualización para Firestore...\n');
console.log('📋 INSTRUCCIONES:');
console.log('   Los siguientes comandos deben ejecutarse en Firebase Console\n');
console.log('=' .repeat(70));
console.log('\n🔗 Ve a: https://console.firebase.google.com/project/mexican-bulking/firestore/data\n');
console.log('Para cada usuario, busca su documento en la colección "users" por email');
console.log('y actualiza el campo "rol" con el valor indicado:\n');

console.log('👔 ENTRENADORES (rol: "entrenador"):');
console.log('─'.repeat(70));
USERS_CONFIG.trainers.forEach((email, index) => {
  console.log(`${index + 1}. Buscar usuario: ${email}`);
  console.log(`   Actualizar campo: rol = "entrenador"\n`);
});

console.log('\n👤 CLIENTES (rol: "cliente"):');
console.log('─'.repeat(70));
USERS_CONFIG.clients.forEach((email, index) => {
  console.log(`${index + 1}. Buscar usuario: ${email}`);
  console.log(`   Actualizar campo: rol = "cliente"\n`);
});

console.log('\n' + '='.repeat(70));
console.log('\n💡 MÉTODO ALTERNATIVO - Usando Firebase Console:');
console.log('   1. Ve a Firestore Database en Firebase Console');
console.log('   2. Colección "users"');
console.log('   3. Busca cada documento por el campo "email"');
console.log('   4. Edita el campo "rol" con el valor apropiado');
console.log('   5. También actualiza el campo "updatedAt" a la fecha actual\n');

// Generar script para copiar/pegar en la consola de Firebase
console.log('\n📝 SCRIPT PARA EJECUTAR EN FIREBASE CONSOLE (JavaScript):');
console.log('─'.repeat(70));
console.log(`
// Copiar y pegar esto en la consola del navegador en Firebase Console
// cuando estés en: Firestore Database > Query

const updateUserRoles = async () => {
  const trainers = ${JSON.stringify(USERS_CONFIG.trainers, null, 2)};
  const clients = ${JSON.stringify(USERS_CONFIG.clients, null, 2)};

  console.log('🔄 Actualizando roles...');

  // Nota: Este script es solo informativo
  // Debes actualizar manualmente en Firebase Console

  console.log('👔 Entrenadores a actualizar:');
  trainers.forEach(email => console.log('  -', email));

  console.log('\\n👤 Clientes a actualizar:');
  clients.forEach(email => console.log('  -', email));
};

updateUserRoles();
`);

console.log('='.repeat(70));
console.log('\n✨ Para actualización automática, necesitas ejecutar:');
console.log('   firebase firestore:indexes --project mexican-bulking');
console.log('   (Requiere permisos de administrador del proyecto)\n');
