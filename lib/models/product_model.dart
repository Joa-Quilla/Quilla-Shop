// Model: Producto - RF05, RF06, RF07

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? brand; // Marca del producto (opcional)
  final List<String> images; // URLs de imágenes
  final List<String> sizes; // Ej: ["S", "M", "L", "XL"] o ["US 6", "US 7"]
  final List<String> colors; // Códigos de colores en hex: ["#FFD700", "#4169E1"]
  final bool isTrending;
  final double rating;
  final int stock;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.brand,
    required this.images,
    this.sizes = const [],
    this.colors = const [],
    this.isTrending = false,
    this.rating = 0.0,
    this.stock = 0,
    required this.createdAt,
  });

  // Constructor desde Firestore
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      brand: data['brand'],
      images: List<String>.from(data['images'] ?? []),
      sizes: List<String>.from(data['sizes'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      isTrending: data['isTrending'] ?? false,
      rating: (data['rating'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'brand': brand,
      'images': images,
      'sizes': sizes,
      'colors': colors,
      'isTrending': isTrending,
      'rating': rating,
      'stock': stock,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Constructor desde JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      brand: json['brand'],
      images: List<String>.from(json['images'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      isTrending: json['isTrending'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'brand': brand,
      'images': images,
      'sizes': sizes,
      'colors': colors,
      'isTrending': isTrending,
      'rating': rating,
      'stock': stock,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // CopyWith para inmutabilidad
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? brand,
    List<String>? images,
    List<String>? sizes,
    List<String>? colors,
    bool? isTrending,
    double? rating,
    int? stock,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      images: images ?? this.images,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      isTrending: isTrending ?? this.isTrending,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Precio formateado en Quetzales
  String get priceFormatted => 'Q ${price.toStringAsFixed(2)}';
  
  // Verificar si tiene stock
  bool get hasStock => stock > 0;
  
  // Rating en estrellas (0-5)
  int get fullStars => rating.floor();
  bool get hasHalfStar => (rating - fullStars) >= 0.5;
}
