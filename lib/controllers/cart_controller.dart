import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartController extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  static const String _cartKey = 'shopping_cart';

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double get total => subtotal; // Aquí se pueden agregar impuestos, descuentos, etc.

  String get totalFormatted => 'Q ${total.toStringAsFixed(2)}';

  /// Cargar carrito desde SharedPreferences
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null) {
        final List<dynamic> decoded = json.decode(cartJson);
        _items.clear();
        _items.addAll(decoded.map((item) => CartItemModel.fromJson(item)).toList());
        notifyListeners();
      }
    } catch (e) {
      print('Error al cargar carrito: $e');
    }
  }

  /// Guardar carrito en SharedPreferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error al guardar carrito: $e');
    }
  }

  /// Agregar producto al carrito
  void addItem({
    required ProductModel product,
    String? selectedSize,
    String? selectedColor,
    int quantity = 1,
  }) {
    // Buscar si ya existe el producto con las mismas características
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );

    if (existingIndex >= 0) {
      // Si existe, aumentar cantidad
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      // Si no existe, agregar nuevo item
      _items.add(
        CartItemModel(
          product: product,
          quantity: quantity,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
        ),
      );
    }

    notifyListeners();
    _saveCart();
  }

  /// Actualizar cantidad de un item
  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _items.length) {
      if (newQuantity <= 0) {
        removeItem(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
        notifyListeners();
        _saveCart();
      }
    }
  }

  /// Aumentar cantidad de un item
  void incrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
      notifyListeners();
      _saveCart();
    }
  }

  /// Disminuir cantidad de un item
  void decrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      if (_items[index].quantity > 1) {
        _items[index] = _items[index].copyWith(
          quantity: _items[index].quantity - 1,
        );
        notifyListeners();
        _saveCart();
      } else {
        removeItem(index);
      }
    }
  }

  /// Remover item del carrito
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
      _saveCart();
    }
  }

  /// Limpiar todo el carrito
  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCart();
  }

  /// Verificar si un producto está en el carrito
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  /// Obtener cantidad total de un producto en el carrito
  int getProductQuantity(String productId) {
    return _items
        .where((item) => item.product.id == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }
}
