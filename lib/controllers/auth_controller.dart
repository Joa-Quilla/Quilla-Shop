import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

/// Controller de Autenticación - RF01, RF02, RF03, RF04
/// Maneja el estado de autenticación del usuario
class AuthController extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  // Estado
  bool _isAuthenticated = false;
  bool _isGuest = false;
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  
  /// RF02: Iniciar sesión con email y contraseña
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Iniciar sesión con Firebase
      final userCredential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      // Obtener datos del usuario desde Firestore
      final user = await _firestoreService.getUser(userCredential.user!.uid);
      
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        _isGuest = false;
        
        // Guardar sesión
        await _saveSession();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw 'No se encontraron datos del usuario';
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// RF01: Registrar nuevo usuario
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Registrar en Firebase Auth
      final userCredential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      
      // Crear documento de usuario en Firestore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        role: Constants.roleClient, // Por defecto es cliente
        createdAt: DateTime.now(),
      );
      
      await _firestoreService.createUser(newUser);
      
      _currentUser = newUser;
      _isAuthenticated = true;
      _isGuest = false;
      
      // Guardar sesión
      await _saveSession();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// RF03: Recuperar contraseña
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _authService.sendPasswordResetEmail(email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Continuar como invitado
  Future<void> continueAsGuest() async {
    _isGuest = true;
    _isAuthenticated = false;
    _currentUser = null;
    
    // Guardar estado de invitado
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', true);
    await prefs.remove('userData');
    
    notifyListeners();
  }
  
  /// Cerrar sesión
  Future<void> logout() async {
    await _authService.signOut();
    
    _isAuthenticated = false;
    _isGuest = false;
    _currentUser = null;
    
    // Limpiar SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }
  
  /// Verificar si hay sesión guardada (llamar desde Splash)
  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool('isGuest') ?? false;
      
      if (isGuest) {
        _isGuest = true;
        _isAuthenticated = false;
        notifyListeners();
        return;
      }
      
      // Verificar si hay usuario autenticado en Firebase
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        // Obtener datos del usuario desde Firestore
        final user = await _firestoreService.getUser(firebaseUser.uid);
        if (user != null) {
          _currentUser = user;
          _isAuthenticated = true;
          _isGuest = false;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  /// Guardar sesión (privado)
  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', false);
    
    if (_currentUser != null) {
      // Guardar datos del usuario en JSON
      await prefs.setString('userData', json.encode(_currentUser!.toJson()));
    }
  }
}
