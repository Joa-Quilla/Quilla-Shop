import 'package:flutter/material.dart';

/// Colores de la aplicación - Tema E-commerce moderno
class AppColors {
  // Color principal (Naranja/Rojo)
  static const Color primary = Color(0xFFFF5722); // Deep Orange
  static const Color primaryLight = Color(0xFFFF7043);
  static const Color primaryDark = Color(0xFFE64A19);
  
  // Color secundario (Azul)
  static const Color secondary = Color(0xFF2196F3);
  static const Color secondaryLight = Color(0xFF64B5F6);
  static const Color secondaryDark = Color(0xFF1976D2);
  
  // Fondos
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Textos
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // Acentos
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Otros
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF5722), Color(0xFFFF7043)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
