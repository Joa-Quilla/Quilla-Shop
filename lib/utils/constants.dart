// Constantes de la aplicación

class Constants {
  // Información de la app
  static const String appName = 'Quilla Shop';
  static const String appVersion = '1.0.0';
  
  // URLs y endpoints (para cuando configures Firebase)
  // static const String apiUrl = 'https://...';
  
  // Configuración de PayPal (sandbox)
  // static const String paypalClientId = 'YOUR_CLIENT_ID';
  // static const String paypalSecret = 'YOUR_SECRET';
  
  // Roles de usuario
  static const String roleClient = 'cliente';
  static const String roleAdmin = 'admin';
  
  // Estados de pedidos
  static const String orderPending = 'Pendiente';
  static const String orderShipped = 'Enviado';
  static const String orderCompleted = 'Completado';
  static const String orderCancelled = 'Cancelado';
  
  // Mensajes
  static const String noInternetMessage = 'No hay conexión a internet';
  static const String errorMessage = 'Ocurrió un error. Intenta de nuevo.';
  static const String successMessage = '¡Operación exitosa!';
}
