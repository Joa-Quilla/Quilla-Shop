import 'package:flutter/material.dart';

enum SnackBarType { success, error, info, warning }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = _getColors(type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors['background'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
        elevation: 6,
      ),
    );
  }

  static Map<String, Color> _getColors(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return {'background': const Color(0xFF4CAF50)};
      case SnackBarType.error:
        return {'background': const Color(0xFFF44336)};
      case SnackBarType.warning:
        return {'background': const Color(0xFFFF9800)};
      case SnackBarType.info:
        return {'background': const Color(0xFF2196F3)};
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
        return Icons.info;
    }
  }

  // Métodos de conveniencia
  static void success(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.info);
  }
}
