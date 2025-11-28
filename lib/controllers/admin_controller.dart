// Controller: Administración - RF13, RF14, RF15, RF16

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../services/storage_service.dart';

/// Controlador para funcionalidades de administración - RF13, RF14, RF15, RF16
class AdminController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  // Estados
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Datos
  List<ProductModel> _allProducts = [];
  List<CategoryModel> _categories = [];
  List<OrderModel> _allOrders = [];
  
  // Estadísticas
  Map<String, dynamic> _statistics = {};

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<ProductModel> get allProducts => _allProducts;
  List<CategoryModel> get categories => _categories;
  List<OrderModel> get allOrders => _allOrders;
  Map<String, dynamic> get statistics => _statistics;

  // ============================================
  // PRODUCTOS - RF13, RF16
  // ============================================

  /// Obtener todos los productos
  Future<void> fetchAllProducts() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      _allProducts = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar productos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crear nuevo producto
  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    String? brand,
    List<String>? sizes,
    List<String>? colors,
    double? rating,
    bool? isTrending,
    File? imageFile,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      // Crear documento en Firestore
      final docRef = await _firestore.collection('products').add({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
        'brand': brand,
        'images': [], // Array de imágenes
        'sizes': sizes ?? [], // Tallas disponibles
        'colors': colors ?? [], // Colores disponibles
        'isTrending': isTrending ?? false,
        'rating': rating ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Subir imagen si existe
      if (imageFile != null) {
        debugPrint('🔄 Subiendo imagen a Firebase Storage...');
        final imageUrl = await _storageService.uploadProductImage(imageFile, docRef.id);
        debugPrint('✅ URL obtenida: $imageUrl');
        
        await docRef.update({
          'images': [imageUrl], // Guardar como array
        });
        debugPrint('✅ Documento actualizado con URL de imagen');
      }

      _isLoading = false;
      notifyListeners();
      
      // Recargar productos DESPUÉS de que todo termine
      debugPrint('🔄 Recargando lista de productos...');
      await fetchAllProducts();
      debugPrint('✅ Lista de productos actualizada');
      
      return true;
    } catch (e) {
      debugPrint('❌ Error completo al crear producto: $e');
      _errorMessage = 'Error al crear producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Actualizar producto existente
  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    String? brand,
    List<String>? sizes,
    List<String>? colors,
    double? rating,
    bool? isTrending,
    File? newImageFile,
    String? currentImageUrl,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      List<String> images = currentImageUrl != null && currentImageUrl.isNotEmpty ? [currentImageUrl] : [];

      // Si hay nueva imagen, eliminar la anterior y subir la nueva
      if (newImageFile != null) {
        if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
          await _storageService.deleteProductImage(currentImageUrl);
        }
        final imageUrl = await _storageService.uploadProductImage(newImageFile, productId);
        images = [imageUrl];
      }

      // Actualizar documento
      await _firestore.collection('products').doc(productId).update({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
        'brand': brand,
        'images': images, // Guardar como array
        'sizes': sizes ?? [],
        'colors': colors ?? [],
        'rating': rating ?? 0.0,
        'isTrending': isTrending ?? false,
      });

      _isLoading = false;
      notifyListeners();
      
      // Recargar productos
      await fetchAllProducts();
      
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Eliminar producto
  Future<bool> deleteProduct(String productId, String? imageUrl) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      // Eliminar imagen si existe
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _storageService.deleteProductImage(imageUrl);
      }

      // Eliminar documento
      await _firestore.collection('products').doc(productId).delete();

      _isLoading = false;
      notifyListeners();
      
      // Recargar productos
      await fetchAllProducts();
      
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // CATEGORÍAS - RF14
  // ============================================

  /// Obtener todas las categorías
  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();

      _categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar categorías: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crear nueva categoría
  Future<bool> createCategory({
    required String name,
    required String icon,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _firestore.collection('categories').add({
        'name': name,
        'icon': icon,
        'productCount': 0,
      });

      _isLoading = false;
      notifyListeners();
      
      await fetchCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear categoría: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Actualizar categoría
  Future<bool> updateCategory({
    required String categoryId,
    required String name,
    required String icon,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _firestore.collection('categories').doc(categoryId).update({
        'name': name,
        'icon': icon,
      });

      _isLoading = false;
      notifyListeners();
      
      await fetchCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar categoría: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Eliminar categoría
  Future<bool> deleteCategory(String categoryId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _firestore.collection('categories').doc(categoryId).delete();

      _isLoading = false;
      notifyListeners();
      
      await fetchCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar categoría: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // PEDIDOS - RF15
  // ============================================

  /// Obtener todos los pedidos
  Future<void> fetchAllOrders() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      _allOrders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar pedidos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualizar estado de pedido
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
      
      await fetchAllOrders();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar estado: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Filtrar pedidos por estado
  List<OrderModel> getOrdersByStatus(String status) {
    return _allOrders.where((order) => order.status == status).toList();
  }

  // ============================================
  // ESTADÍSTICAS - RF17
  // ============================================

  /// Calcular estadísticas del dashboard
  Future<void> calculateStatistics() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Obtener inicio y fin del día actual
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Total de productos
      final productsSnapshot = await _firestore.collection('products').get();
      final totalProducts = productsSnapshot.docs.length;

      // Total de pedidos (TODOS)
      final ordersSnapshot = await _firestore.collection('orders').get();
      final totalOrders = ordersSnapshot.docs.length;

      // Pedidos del DÍA
      final todayOrdersSnapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      // Obtener IDs de pedidos ya cerrados hoy
      final closedOrderIds = await _getClosedOrderIdsToday();

      // Filtrar pedidos del día que NO han sido cerrados
      final todayOrders = todayOrdersSnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .where((order) => !closedOrderIds.contains(order.id))
          .toList();
      
      final totalSales = todayOrders.fold<double>(
        0.0,
        (sum, order) => sum + order.total,
      );

      // Pedidos por estado (TODOS los pedidos)
      final allOrders = ordersSnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
      
      final pendingOrders = allOrders.where((o) => o.status == 'pending').length;
      final confirmedOrders = allOrders.where((o) => o.status == 'confirmed').length;
      final shippedOrders = allOrders.where((o) => o.status == 'shipped').length;
      final deliveredOrders = allOrders.where((o) => o.status == 'delivered').length;

      // Total de usuarios
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;

      // Productos con bajo stock (menos de 5)
      final lowStockProducts = productsSnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((product) => product.stock < 5)
          .length;

      _statistics = {
        'totalProducts': totalProducts,
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'confirmedOrders': confirmedOrders,
        'shippedOrders': shippedOrders,
        'deliveredOrders': deliveredOrders,
        'totalSales': totalSales, // Solo pedidos NO cerrados del día
        'totalUsers': totalUsers,
        'lowStockProducts': lowStockProducts,
      };

      _isLoading = false;
      notifyListeners();
      
      debugPrint('📊 Estadísticas calculadas - Ventas del día: Q${totalSales.toStringAsFixed(2)} (${todayOrders.length} pedidos pendientes de cierre)');
    } catch (e) {
      _errorMessage = 'Error al calcular estadísticas: $e';
      _isLoading = false;
      notifyListeners();
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

  /// Limpiar mensajes de error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
