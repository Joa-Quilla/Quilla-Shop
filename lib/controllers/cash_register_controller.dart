// Controller: Caja (Cash Register)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class CashRegisterController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Ventas del día actual
  List<OrderModel> _todayOrders = [];
  double _todayTotal = 0.0;
  
  // Historial de cierres
  List<Map<String, dynamic>> _closureHistory = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<OrderModel> get todayOrders => _todayOrders;
  double get todayTotal => _todayTotal;
  int get todayOrdersCount => _todayOrders.length;
  List<Map<String, dynamic>> get closureHistory => _closureHistory;
  
  /// Cargar ventas del día actual
  Future<void> loadTodaySales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Obtener inicio y fin del día actual
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      // Consultar pedidos del día
      final snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();
      
      // Obtener IDs de pedidos ya cerrados
      final closedOrderIds = await _getClosedOrderIdsToday();
      
      // Filtrar solo pedidos que NO han sido cerrados
      _todayOrders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .where((order) => !closedOrderIds.contains(order.id))
          .toList();
      
      // Calcular total
      _todayTotal = _todayOrders.fold(0.0, (sum, order) => sum + order.total);
      
      _isLoading = false;
      notifyListeners();
      
      debugPrint('✅ Ventas del día cargadas: ${_todayOrders.length} pedidos, Total: Q${_todayTotal.toStringAsFixed(2)}');
    } catch (e) {
      _errorMessage = 'Error al cargar ventas del día: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error: $e');
    }
  }
  
  /// Obtener IDs de pedidos que ya fueron cerrados hoy
  Future<Set<String>> _getClosedOrderIdsToday() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      final closuresSnapshot = await _firestore
          .collection('cash_closures')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();
      
      // Combinar todos los orderIds de todos los cierres del día
      final Set<String> closedOrderIds = {};
      for (var doc in closuresSnapshot.docs) {
        final data = doc.data();
        if (data['orderIds'] != null) {
          final List<dynamic> ids = data['orderIds'];
          closedOrderIds.addAll(ids.cast<String>());
        }
      }
      
      return closedOrderIds;
    } catch (e) {
      debugPrint('❌ Error al obtener pedidos cerrados: $e');
      return {};
    }
  }
  
  /// Limpiar ventas del día (cuando ya está cerrada)
  void clearTodaySales() {
    _todayOrders = [];
    _todayTotal = 0.0;
    notifyListeners();
    debugPrint('🧹 Ventas del día limpiadas (caja ya cerrada)');
  }
  
  /// Cerrar caja (guardar reporte del día)
  Future<bool> closeCashRegister() async {
    if (_todayOrders.isEmpty) {
      _errorMessage = 'No hay ventas para cerrar';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final now = DateTime.now();
      
      // Crear documento de cierre
      final closureData = {
        'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
        'closedAt': FieldValue.serverTimestamp(),
        'totalSales': _todayTotal,
        'ordersCount': _todayOrders.length,
        'orderIds': _todayOrders.map((o) => o.id).toList(),
      };
      
      // Guardar en Firestore
      await _firestore.collection('cash_closures').add(closureData);
      
      debugPrint('✅ Caja cerrada exitosamente');
      
      // REINICIAR datos después de cerrar
      _todayOrders = [];
      _todayTotal = 0.0;
      
      _isLoading = false;
      notifyListeners();
      
      // Recargar historial
      await loadClosureHistory();
      
      return true;
    } catch (e) {
      _errorMessage = 'Error al cerrar caja: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error: $e');
      return false;
    }
  }
  
  /// Cargar historial de cierres
  Future<void> loadClosureHistory() async {
    try {
      final snapshot = await _firestore
          .collection('cash_closures')
          .orderBy('date', descending: true)
          .limit(30) // Últimos 30 días
          .get();
      
      _closureHistory = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'date': (data['date'] as Timestamp).toDate(),
          'closedAt': data['closedAt'] != null 
              ? (data['closedAt'] as Timestamp).toDate() 
              : null,
          'totalSales': (data['totalSales'] as num).toDouble(),
          'ordersCount': data['ordersCount'] as int,
        };
      }).toList();
      
      notifyListeners();
      debugPrint('✅ Historial cargado: ${_closureHistory.length} cierres');
    } catch (e) {
      debugPrint('❌ Error al cargar historial: $e');
    }
  }
  
  /// Verificar si ya se cerró la caja hoy
  Future<bool> isTodayClosed() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      final snapshot = await _firestore
          .collection('cash_closures')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error al verificar cierre: $e');
      return false;
    }
  }
}
