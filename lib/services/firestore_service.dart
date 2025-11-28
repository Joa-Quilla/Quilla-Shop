// Service: Firebase Firestore (Base de datos)

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Colecciones
  String get usersCollection => 'users';
  String get productsCollection => 'products';
  String get ordersCollection => 'orders';
  String get categoriesCollection => 'categories';

  // ==================== USUARIOS ====================

  // Crear usuario en Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e) {
      throw 'Error al crear usuario: $e';
    }
  }

  // Obtener usuario por ID
  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Error al obtener usuario: $e';
    }
  }

  // Actualizar usuario
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .update(data);
    } catch (e) {
      throw 'Error al actualizar usuario: $e';
    }
  }

  // Eliminar usuario
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw 'Error al eliminar usuario: $e';
    }
  }

  // Verificar si un usuario existe
  Future<bool> userExists(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      throw 'Error al verificar usuario: $e';
    }
  }

  // Stream de usuario (para actualizaciones en tiempo real)
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // ==================== MÉTODOS GENERALES ====================

  // Obtener documento por ID de cualquier colección
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      throw 'Error al obtener documento: $e';
    }
  }

  // Crear o actualizar documento
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data);
    } catch (e) {
      throw 'Error al guardar documento: $e';
    }
  }

  // Eliminar documento
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw 'Error al eliminar documento: $e';
    }
  }

  // Obtener colección completa
  Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await _firestore.collection(collection).get();
    } catch (e) {
      throw 'Error al obtener colección: $e';
    }
  }

  // Stream de colección
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }
}
