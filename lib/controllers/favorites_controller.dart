// Controller: Favoritos

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'auth_controller.dart';

class FavoritesController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController authController;
  
  List<ProductModel> _favoriteProducts = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  
  FavoritesController({required this.authController}) {
    _init();
  }
  
  // Getters
  List<ProductModel> get favoriteProducts => _favoriteProducts;
  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalFavorites => _favoriteIds.length;
  
  void _init() {
    // Escuchar cambios en autenticación
    authController.addListener(_onAuthChanged);
    if (authController.currentUser != null) {
      loadFavorites();
    }
  }
  
  void _onAuthChanged() {
    if (authController.currentUser != null) {
      loadFavorites();
    } else {
      _clearFavorites();
    }
  }
  
  void _clearFavorites() {
    _favoriteProducts = [];
    _favoriteIds = {};
    notifyListeners();
  }
  
  /// Verificar si un producto es favorito
  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }
  
  /// Cargar favoritos del usuario desde Firestore
  Future<void> loadFavorites() async {
    final userId = authController.currentUser?.id;
    if (userId == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Obtener IDs de favoritos
      final favSnapshot = await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('products')
          .get();
      
      _favoriteIds = favSnapshot.docs.map((doc) => doc.id).toSet();
      
      if (_favoriteIds.isEmpty) {
        _favoriteProducts = [];
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Obtener productos completos
      final productsSnapshot = await _firestore
          .collection('products')
          .where(FieldPath.documentId, whereIn: _favoriteIds.toList())
          .get();
      
      _favoriteProducts = productsSnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar favoritos: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error al cargar favoritos: $e');
    }
  }
  
  /// Agregar producto a favoritos
  Future<bool> addFavorite(ProductModel product) async {
    final userId = authController.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Debes iniciar sesión para agregar favoritos';
      notifyListeners();
      return false;
    }
    
    try {
      await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('products')
          .doc(product.id)
          .set({
        'productId': product.id,
        'addedAt': FieldValue.serverTimestamp(),
      });
      
      _favoriteIds.add(product.id);
      _favoriteProducts.add(product);
      notifyListeners();
      
      debugPrint('✅ Producto ${product.name} agregado a favoritos');
      return true;
    } catch (e) {
      _errorMessage = 'Error al agregar favorito: $e';
      notifyListeners();
      debugPrint('❌ Error al agregar favorito: $e');
      return false;
    }
  }
  
  /// Eliminar producto de favoritos
  Future<bool> removeFavorite(String productId) async {
    final userId = authController.currentUser?.id;
    if (userId == null) return false;
    
    try {
      await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('products')
          .doc(productId)
          .delete();
      
      _favoriteIds.remove(productId);
      _favoriteProducts.removeWhere((p) => p.id == productId);
      notifyListeners();
      
      debugPrint('✅ Producto eliminado de favoritos');
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar favorito: $e';
      notifyListeners();
      debugPrint('❌ Error al eliminar favorito: $e');
      return false;
    }
  }
  
  /// Toggle favorito (agregar o eliminar)
  Future<bool> toggleFavorite(ProductModel product) async {
    if (isFavorite(product.id)) {
      return await removeFavorite(product.id);
    } else {
      return await addFavorite(product);
    }
  }
  
  /// Limpiar todos los favoritos
  Future<bool> clearAllFavorites() async {
    final userId = authController.currentUser?.id;
    if (userId == null) return false;
    
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('favorites')
          .doc(userId)
          .collection('products')
          .get();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      _favoriteIds.clear();
      _favoriteProducts.clear();
      notifyListeners();
      
      debugPrint('✅ Todos los favoritos eliminados');
      return true;
    } catch (e) {
      _errorMessage = 'Error al limpiar favoritos: $e';
      notifyListeners();
      debugPrint('❌ Error al limpiar favoritos: $e');
      return false;
    }
  }
  
  @override
  void dispose() {
    authController.removeListener(_onAuthChanged);
    super.dispose();
  }
}
