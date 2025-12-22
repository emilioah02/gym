// Script para cargar productos de ejemplo en Firestore
const admin = require('firebase-admin');

// Inicializar Firebase Admin con credenciales de la cuenta de servicio
const serviceAccount = require('./mexican-bulking-firebase-adminsdk-fbsvc-14058731a4.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'mexican-bulking'
});

const db = admin.firestore();

const products = [
  // BEBIDAS
  {
    name: 'Proteína Whey 2kg',
    description: 'Proteína de suero de leche de alta calidad, sabor chocolate',
    price: 899.00,
    imageUrl: 'https://images.unsplash.com/photo-1579722820308-d74e571900a9?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1579722820308-d74e571900a9?w=800&q=80',
    category: 'bebidas',
    isActive: true,
    stock: 25,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Creatina Monohidrato 300g',
    description: 'Creatina pura micronizada, sin sabor',
    price: 349.00,
    imageUrl: 'https://images.unsplash.com/photo-1608772623190-c8e4f8c5677d?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1608772623190-c8e4f8c5677d?w=800&q=80',
    category: 'bebidas',
    isActive: true,
    stock: 30,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Pre-Entreno Energía',
    description: 'Pre-entreno con cafeína y beta-alanina, sabor frutas',
    price: 549.00,
    imageUrl: 'https://images.unsplash.com/photo-1594897030264-ab7d87efc473?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1594897030264-ab7d87efc473?w=800&q=80',
    category: 'bebidas',
    isActive: true,
    stock: 20,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Amino BCAA 500g',
    description: 'Aminoácidos ramificados 2:1:1, recuperación muscular',
    price: 449.00,
    imageUrl: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=800&q=80',
    category: 'bebidas',
    isActive: true,
    stock: 15,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  // SUPLEMENTOS
  {
    name: 'Multivitamínico Completo',
    description: 'Vitaminas y minerales esenciales, 60 cápsulas',
    price: 299.00,
    imageUrl: 'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=800&q=80',
    category: 'suplementos',
    isActive: true,
    stock: 40,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Omega 3 Fish Oil',
    description: 'Aceite de pescado premium, 90 cápsulas',
    price: 249.00,
    imageUrl: 'https://images.unsplash.com/photo-1526627818775-799c0737c708?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1526627818775-799c0737c708?w=800&q=80',
    category: 'suplementos',
    isActive: true,
    stock: 35,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Quemador de Grasa',
    description: 'Termogénico con extractos naturales, 60 cápsulas',
    price: 499.00,
    imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&q=80',
    category: 'suplementos',
    isActive: true,
    stock: 18,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  // ROPA
  {
    name: 'Playera Deportiva Dry-Fit',
    description: 'Playera técnica de secado rápido, varios colores',
    price: 349.00,
    imageUrl: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=800&q=80',
    category: 'ropa',
    isActive: true,
    stock: 50,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Short Deportivo',
    description: 'Short ligero con bolsillos, ideal para entrenar',
    price: 399.00,
    imageUrl: 'https://images.unsplash.com/photo-1591195845402-2fdb39c9d3e7?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1591195845402-2fdb39c9d3e7?w=800&q=80',
    category: 'ropa',
    isActive: true,
    stock: 45,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Sudadera con Capucha',
    description: 'Sudadera premium de algodón, logo del gym',
    price: 699.00,
    imageUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&q=80',
    category: 'ropa',
    isActive: true,
    stock: 30,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  // ACCESORIOS
  {
    name: 'Guantes de Gimnasio',
    description: 'Guantes acolchados con muñequeras, talla M/L',
    price: 249.00,
    imageUrl: 'https://images.unsplash.com/photo-1584735175315-9d5df23860bc?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1584735175315-9d5df23860bc?w=800&q=80',
    category: 'accesorios',
    isActive: true,
    stock: 60,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Cinturón de Levantamiento',
    description: 'Cinturón de powerlifting de cuero genuino',
    price: 899.00,
    imageUrl: 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800&q=80',
    category: 'accesorios',
    isActive: true,
    stock: 15,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Shaker Mezclador 700ml',
    description: 'Vaso mezclador con compartimento para suplementos',
    price: 149.00,
    imageUrl: 'https://images.unsplash.com/photo-1591761058308-2e21e2d2c57f?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1591761058308-2e21e2d2c57f?w=800&q=80',
    category: 'accesorios',
    isActive: true,
    stock: 100,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Straps para Jalones',
    description: 'Correas acolchadas para mejorar agarre en dominadas',
    price: 199.00,
    imageUrl: 'https://images.unsplash.com/photo-1606902965551-dce093cda6e7?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1606902965551-dce093cda6e7?w=800&q=80',
    category: 'accesorios',
    isActive: true,
    stock: 40,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Banda de Resistencia Set',
    description: 'Set de 5 bandas elásticas con diferentes resistencias',
    price: 449.00,
    imageUrl: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800&q=80',
    imagen: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800&q=80',
    category: 'accesorios',
    isActive: true,
    stock: 25,
    displayed: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

async function seedProducts() {
  console.log('🌱 Iniciando carga de productos...\n');

  const batch = db.batch();
  let count = 0;

  products.forEach((product) => {
    const docRef = db.collection('products').doc();
    batch.set(docRef, product);
    count++;
    console.log(`✅ ${count}. ${product.name} - $${product.price}`);
  });

  try {
    await batch.commit();
    console.log(`\n✨ ${count} productos cargados exitosamente en Firestore!`);
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error al cargar productos:', error);
    process.exit(1);
  }
}

seedProducts();
