// Model: Categoría - RF14

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon; // Emoji o nombre del ícono
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.productCount = 0,
  });

  // Constructor desde Firestore
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '📦',
      productCount: data['productCount'] ?? 0,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'productCount': productCount,
    };
  }

  // Constructor desde JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '📦',
      productCount: json['productCount'] ?? 0,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'productCount': productCount,
    };
  }
}
