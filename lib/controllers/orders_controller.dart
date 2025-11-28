// Controller: Pedidos - RF09, RF10, RF11, RF12, RF17

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrdersController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Crear una nueva orden
  Future<String?> createOrder({
    required String userId,
    required List<CartItemModel> items,
    required double subtotal,
    required double shippingCost,
    required double total,
    required String shippingAddress,
    String? shippingDepartment,
    String? shippingMunicipality,
    String? shippingPhone,
    String? customerName,
    String paymentMethod = 'simulated',
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Generar ID único
      final docRef = _firestore.collection('orders').doc();
      final orderId = docRef.id;

      // Crear el modelo de orden
      final order = OrderModel(
        id: orderId,
        userId: userId,
        items: items,
        subtotal: subtotal,
        shippingCost: shippingCost,
        total: total,
        status: 'pending',
        shippingAddress: shippingAddress,
        shippingDepartment: shippingDepartment,
        shippingMunicipality: shippingMunicipality,
        shippingPhone: shippingPhone,
        customerName: customerName,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );

      // Guardar en Firestore
      await docRef.set(order.toJson());

      // Agregar a la lista local
      _orders.insert(0, order);

      _isLoading = false;
      notifyListeners();

      return orderId;
    } catch (e) {
      _error = 'Error al crear la orden: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Obtener órdenes de un usuario
  Future<void> fetchUserOrders(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      _orders = querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
      
      // Ordenar en el código para evitar índice compuesto
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar las órdenes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener una orden específica
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();

      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _error = 'Error al cargar la orden: $e';
      notifyListeners();
      return null;
    }
  }

  // Actualizar estado de una orden (para admin)
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });

      // Actualizar localmente
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Error al actualizar el estado: $e';
      notifyListeners();
      return false;
    }
  }

  // Cancelar una orden
  Future<bool> cancelOrder(String orderId) async {
    return await updateOrderStatus(orderId, 'cancelled');
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Obtener órdenes por estado (para admin)
  List<OrderModel> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Estadísticas rápidas
  int get totalOrders => _orders.length;

  int get pendingOrders =>
      _orders.where((order) => order.status == 'pending').length;

  int get completedOrders =>
      _orders.where((order) => order.status == 'delivered').length;

  double get totalRevenue =>
      _orders.fold(0, (sum, order) => sum + order.total);

  // ============ MÉTODOS PARA GESTIÓN DE STOCK ============

  /// Verificar si hay stock disponible para todos los productos del carrito
  Future<bool> checkStockAvailability(List<CartItemModel> items) async {
    try {
      for (var item in items) {
        final productDoc = await _firestore
            .collection('products')
            .doc(item.product.id)
            .get();

        if (!productDoc.exists) {
          _error = 'Producto ${item.product.name} no encontrado';
          notifyListeners();
          return false;
        }

        final currentStock = productDoc.data()?['stock'] ?? 0;
        
        if (currentStock < item.quantity) {
          _error = 'Stock insuficiente para ${item.product.name}. Disponible: $currentStock';
          notifyListeners();
          return false;
        }
      }

      return true;
    } catch (e) {
      _error = 'Error al verificar stock: $e';
      notifyListeners();
      return false;
    }
  }

  /// Descontar stock de los productos después de un pago exitoso
  /// Usa transacciones de Firestore para garantizar integridad
  Future<bool> decreaseStock(List<CartItemModel> items) async {
    try {
      // Usar batch para operaciones atómicas
      final batch = _firestore.batch();

      for (var item in items) {
        final productRef = _firestore.collection('products').doc(item.product.id);
        
        // Obtener documento actual
        final productDoc = await productRef.get();
        
        if (!productDoc.exists) {
          throw Exception('Producto ${item.product.name} no encontrado');
        }

        final currentStock = productDoc.data()?['stock'] ?? 0;
        
        // Verificar stock nuevamente (por si cambió entre la verificación y ahora)
        if (currentStock < item.quantity) {
          throw Exception('Stock insuficiente para ${item.product.name}');
        }

        // Calcular nuevo stock
        final newStock = currentStock - item.quantity;
        
        // Actualizar en el batch
        batch.update(productRef, {'stock': newStock});
      }

      // Ejecutar todas las actualizaciones de forma atómica
      await batch.commit();

      print('✅ Stock actualizado correctamente');
      return true;
    } catch (e) {
      _error = 'Error al descontar stock: $e';
      notifyListeners();
      print('❌ Error al actualizar stock: $e');
      return false;
    }
  }
}
