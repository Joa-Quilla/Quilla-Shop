import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedColor,
  });

  double get subtotal => product.price * quantity;

  String get subtotalFormatted => 'Q ${subtotal.toStringAsFixed(2)}';

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(), // Guardamos el producto completo
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      selectedSize: json['selectedSize'],
      selectedColor: json['selectedColor'],
    );
  }
}
