// Controller: Productos - RF05, RF06, RF07

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductsController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<CategoryModel> _categories = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  
  // Getters
  List<ProductModel> get products => _filteredProducts;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  
  /// Cargar productos desde Firestore
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();
      
      _products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar productos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Cargar categorías
  Future<void> loadCategories() async {
    try {
      // Obtener categorías únicas de los productos
      final categoriesSet = _products.map((p) => p.category).toSet();
      
      _categories = [
        CategoryModel(id: 'all', name: 'Todos', icon: '🛍️'),
        ...categoriesSet.map((cat) => CategoryModel(
          id: cat.toLowerCase(),
          name: cat,
          icon: _getCategoryIcon(cat),
          productCount: _products.where((p) => p.category == cat).length,
        )),
      ];
      
      notifyListeners();
    } catch (e) {
      print('Error al cargar categorías: $e');
    }
  }
  
  /// Buscar productos
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }
  
  /// Filtrar por categoría
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }
  
  /// Aplicar filtros de búsqueda y categoría
  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      // Filtro de categoría
      bool matchesCategory = _selectedCategory == 'Todos' || 
                            product.category == _selectedCategory;
      
      // Filtro de búsqueda (nombre, descripción Y marca)
      bool matchesSearch = _searchQuery.isEmpty ||
                          product.name.toLowerCase().contains(_searchQuery) ||
                          product.description.toLowerCase().contains(_searchQuery) ||
                          (product.brand != null && product.brand!.toLowerCase().contains(_searchQuery));
      
      return matchesCategory && matchesSearch;
    }).toList();
    
    notifyListeners();
  }
  
  /// Obtener producto por ID
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Obtener productos trending
  List<ProductModel> get trendingProducts {
    return _products.where((p) => p.isTrending).toList();
  }
  
  /// Obtener icono según categoría (usando IconData de Material)
  IconData _getCategoryIconData(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('calzado') || lowerCategory.contains('sneakers') || lowerCategory.contains('zapato')) {
      return Icons.sports_soccer; // Icono de zapato deportivo
    } else if (lowerCategory.contains('ropa') || lowerCategory.contains('camisa') || lowerCategory.contains('playera')) {
      return Icons.checkroom; // Icono de ropa
    } else if (lowerCategory.contains('reloj') || lowerCategory.contains('watch')) {
      return Icons.watch; // Icono de reloj
    } else if (lowerCategory.contains('chaqueta') || lowerCategory.contains('jacket') || lowerCategory.contains('chamarra')) {
      return Icons.dry_cleaning; // Icono de chaqueta
    } else {
      return Icons.shopping_bag; // Icono por defecto
    }
  }
  
  /// Obtener icono según categoría (legacy - para compatibilidad)
  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'sneakers':
      case 'zapatos':
      case 'calzado':
        return '👟';
      case 'jacket':
      case 'chaqueta':
      case 'chamarra':
        return '🧥';
      case 'watch':
      case 'reloj':
        return '⌚';
      case 'camisa':
      case 'playera':
        return '👕';
      case 'pantalón':
      case 'jeans':
        return '👖';
      default:
        return '📦';
    }
  }
  
  /// Método público para obtener icono de categoría
  IconData getCategoryIconData(String category) {
    return _getCategoryIconData(category);
  }
  
  /// Limpiar filtros
  void clearFilters() {
    _selectedCategory = 'Todos';
    _searchQuery = '';
    _applyFilters();
  }
}
