// Service: Firebase Storage - RF16

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Servicio para gestionar archivos en Firebase Storage - RF16
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Subir imagen de producto
  /// Retorna la URL de descarga de la imagen
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      debugPrint('📤 Iniciando subida de imagen...');
      debugPrint('📂 Archivo: ${imageFile.path}');
      debugPrint('📦 Product ID: $productId');
      
      // Verificar que el archivo existe
      if (!await imageFile.exists()) {
        throw Exception('El archivo de imagen no existe');
      }
      
      // Verificar tamaño del archivo
      final fileSize = await imageFile.length();
      debugPrint('📏 Tamaño del archivo: ${fileSize / 1024} KB');
      
      // Referencia al archivo en Storage: products/{productId}/{timestamp}.jpg
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('products/$productId/$fileName');
      
      debugPrint('🔗 Ruta en Storage: products/$productId/$fileName');

      // Subir archivo
      debugPrint('⬆️ Iniciando upload...');
      final UploadTask uploadTask = ref.putFile(imageFile);
      
      // Monitorear progreso
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('📊 Progreso: ${progress.toStringAsFixed(1)}%');
      });
      
      // Esperar a que termine la subida
      final TaskSnapshot snapshot = await uploadTask;
      debugPrint('✅ Upload completado');
      
      // Obtener URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('🎉 Imagen subida exitosamente');
      debugPrint('🔗 URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ ERROR COMPLETO al subir imagen:');
      debugPrint('❌ Tipo de error: ${e.runtimeType}');
      debugPrint('❌ Mensaje: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Eliminar imagen de producto
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      // Obtener referencia desde la URL
      final Reference ref = _storage.refFromURL(imageUrl);
      
      // Eliminar archivo
      await ref.delete();
      
      debugPrint('✅ Imagen eliminada exitosamente');
    } catch (e) {
      debugPrint('❌ Error al eliminar imagen: $e');
      rethrow;
    }
  }

  /// Eliminar todas las imágenes de un producto
  Future<void> deleteAllProductImages(String productId) async {
    try {
      // Referencia a la carpeta del producto
      final Reference ref = _storage.ref().child('products/$productId');
      
      // Listar todos los archivos
      final ListResult result = await ref.listAll();
      
      // Eliminar todos los archivos
      for (var item in result.items) {
        await item.delete();
      }
      
      debugPrint('✅ Todas las imágenes del producto eliminadas');
    } catch (e) {
      debugPrint('❌ Error al eliminar imágenes del producto: $e');
      rethrow;
    }
  }

  /// Subir imagen de categoría
  Future<String> uploadCategoryImage(File imageFile, String categoryId) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('categories/$categoryId/$fileName');

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('✅ Imagen de categoría subida: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error al subir imagen de categoría: $e');
      rethrow;
    }
  }

  /// Eliminar imagen de categoría
  Future<void> deleteCategoryImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('✅ Imagen de categoría eliminada');
    } catch (e) {
      debugPrint('❌ Error al eliminar imagen de categoría: $e');
      rethrow;
    }
  }

  /// Obtener tamaño de archivo en MB
  Future<double> getFileSize(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      final FullMetadata metadata = await ref.getMetadata();
      final double sizeInMB = metadata.size! / (1024 * 1024);
      return sizeInMB;
    } catch (e) {
      debugPrint('❌ Error al obtener tamaño de archivo: $e');
      return 0.0;
    }
  }

  /// Validar tamaño de imagen (max 5MB)
  Future<bool> validateImageSize(File imageFile) async {
    try {
      final int bytes = await imageFile.length();
      final double mb = bytes / (1024 * 1024);
      return mb <= 5.0; // Máximo 5MB
    } catch (e) {
      debugPrint('❌ Error al validar tamaño de imagen: $e');
      return false;
    }
  }
}
