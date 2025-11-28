// Model: Pedido - RF09, RF10, RF11, RF12, RF17

import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double shippingCost;
  final double total;
  final String status; // 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled'
  final String shippingAddress;
  final String? shippingDepartment; // Departamento de Guatemala
  final String? shippingMunicipality; // Municipio de Guatemala
  final String? shippingPhone;
  final String? customerName;
  final String paymentMethod; // 'paypal', 'card', 'cash', 'simulated'
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.shippingCost = 0.0,
    required this.total,
    this.status = 'pending',
    required this.shippingAddress,
    this.shippingDepartment,
    this.shippingMunicipality,
    this.shippingPhone,
    this.customerName,
    this.paymentMethod = 'simulated',
    required this.createdAt,
    this.updatedAt,
  });

  // Getters útiles
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  String get totalFormatted => 'Q ${total.toStringAsFixed(2)}';

  String get subtotalFormatted => 'Q ${subtotal.toStringAsFixed(2)}';

  String get shippingCostFormatted => 'Q ${shippingCost.toStringAsFixed(2)}';

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'shipped':
        return 'En camino';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  String get formattedDate {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${createdAt.day} de ${months[createdAt.month - 1]}, ${createdAt.year}';
  }

  // Firestore serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'total': total,
      'status': status,
      'shippingAddress': shippingAddress,
      'shippingDepartment': shippingDepartment,
      'shippingMunicipality': shippingMunicipality,
      'shippingPhone': shippingPhone,
      'customerName': customerName,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingCost: (json['shippingCost'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      shippingAddress: json['shippingAddress'] ?? '',
      shippingDepartment: json['shippingDepartment'],
      shippingMunicipality: json['shippingMunicipality'],
      shippingPhone: json['shippingPhone'],
      customerName: json['customerName'],
      paymentMethod: json['paymentMethod'] ?? 'simulated',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Constructor desde Firestore
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromJson({...data, 'id': doc.id});
  }

  // Getter para información de envío en formato Map (para ManageOrdersView)
  Map<String, String> get shippingInfo {
    return {
      'name': customerName ?? 'N/A',
      'address': shippingAddress,
      'city': shippingMunicipality ?? 'N/A',
      'department': shippingDepartment ?? 'N/A',
      'postalCode': '00000',
      'phone': shippingPhone ?? 'N/A',
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    double? subtotal,
    double? shippingCost,
    double? total,
    String? status,
    String? shippingAddress,
    String? shippingDepartment,
    String? shippingMunicipality,
    String? shippingPhone,
    String? customerName,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      shippingDepartment: shippingDepartment ?? this.shippingDepartment,
      shippingMunicipality: shippingMunicipality ?? this.shippingMunicipality,
      shippingPhone: shippingPhone ?? this.shippingPhone,
      customerName: customerName ?? this.customerName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
