import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para los pedidos de la tienda
class StoreOrderModel {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String? clientePhotoUrl;
  final List<OrderItem> items;
  final double total;
  final OrderStatus estado;
  final DateTime fechaPedido;
  final DateTime? fechaListo;
  final DateTime? fechaEntregado;
  final String? notas;

  StoreOrderModel({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    this.clientePhotoUrl,
    required this.items,
    required this.total,
    required this.estado,
    required this.fechaPedido,
    this.fechaListo,
    this.fechaEntregado,
    this.notas,
  });

  // Factory desde Firestore
  factory StoreOrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreOrderModel(
      id: doc.id,
      clienteId: data['clienteId'] ?? '',
      clienteNombre: data['clienteNombre'] ?? 'Cliente',
      clientePhotoUrl: data['clientePhotoUrl'],
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: (data['total'] ?? 0.0).toDouble(),
      estado: OrderStatus.values.firstWhere(
        (e) => e.name == data['estado'],
        orElse: () => OrderStatus.pendiente,
      ),
      fechaPedido: (data['fechaPedido'] as Timestamp).toDate(),
      fechaListo: data['fechaListo'] != null
          ? (data['fechaListo'] as Timestamp).toDate()
          : null,
      fechaEntregado: data['fechaEntregado'] != null
          ? (data['fechaEntregado'] as Timestamp).toDate()
          : null,
      notas: data['notas'],
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'clientePhotoUrl': clientePhotoUrl,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'estado': estado.name,
      'fechaPedido': Timestamp.fromDate(fechaPedido),
      'notas': notas,
    };

    if (fechaListo != null) {
      map['fechaListo'] = Timestamp.fromDate(fechaListo!);
    }

    if (fechaEntregado != null) {
      map['fechaEntregado'] = Timestamp.fromDate(fechaEntregado!);
    }

    return map;
  }

  // CopyWith para actualizaciones inmutables
  StoreOrderModel copyWith({
    String? id,
    String? clienteId,
    String? clienteNombre,
    String? clientePhotoUrl,
    List<OrderItem>? items,
    double? total,
    OrderStatus? estado,
    DateTime? fechaPedido,
    DateTime? fechaListo,
    DateTime? fechaEntregado,
    String? notas,
  }) {
    return StoreOrderModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      clientePhotoUrl: clientePhotoUrl ?? this.clientePhotoUrl,
      items: items ?? this.items,
      total: total ?? this.total,
      estado: estado ?? this.estado,
      fechaPedido: fechaPedido ?? this.fechaPedido,
      fechaListo: fechaListo ?? this.fechaListo,
      fechaEntregado: fechaEntregado ?? this.fechaEntregado,
      notas: notas ?? this.notas,
    );
  }
}

/// Item individual en un pedido
class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String category;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.category,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'category': category,
    };
  }

  double get subtotal => price * quantity;
}

/// Estado del pedido
enum OrderStatus {
  pendiente('Pendiente', '⏳', '🟡'),
  enPreparacion('En Preparación', '👨‍🍳', '🟠'),
  listo('Listo', '✅', '🟢'),
  entregado('Entregado', '🎉', '⚪');

  final String displayName;
  final String emoji;
  final String colorIndicator;
  const OrderStatus(this.displayName, this.emoji, this.colorIndicator);
}
