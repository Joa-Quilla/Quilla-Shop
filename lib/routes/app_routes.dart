import 'package:flutter/material.dart';
import '../views/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/forgot_password_view.dart';
import '../views/catalog_view.dart';
import '../views/product_detail_view.dart';
import '../views/cart_view.dart';
import '../views/checkout_view.dart';
import '../views/order_confirmation_view.dart';
import '../views/orders_history_view.dart';
import '../views/favorites_view.dart';
import '../views/settings_view.dart';
import '../views/help_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../views/admin/manage_products_view_new.dart'; // Nueva vista mejorada
import '../views/admin/manage_categories_view.dart';
import '../views/admin/manage_orders_view.dart';
import '../views/admin/cash_register_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String catalog = '/home';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String favorites = '/favorites';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String ordersHistory = '/orders-history';
  
  // Rutas de Administrador
  static const String adminDashboard = '/admin-dashboard';
  static const String manageProducts = '/admin-products';
  static const String manageCategories = '/admin-categories';
  static const String manageOrders = '/admin-orders';
  static const String cashRegister = '/admin-cash-register';
  
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashView(),
    login: (context) => const LoginView(),
    register: (context) => const RegisterView(),
    forgotPassword: (context) => const ForgotPasswordView(),
    home: (context) => const CatalogView(),
    cart: (context) => const CartView(),
    favorites: (context) => const FavoritesView(),
    settings: (context) => const SettingsView(),
    help: (context) => const HelpView(),
    checkout: (context) => const CheckoutView(),
    ordersHistory: (context) => const OrdersHistoryView(),
    adminDashboard: (context) => const AdminDashboardView(),
    manageProducts: (context) => const ManageProductsViewNew(),
    manageCategories: (context) => const ManageCategoriesView(),
    manageOrders: (context) => const ManageOrdersView(),
    cashRegister: (context) => const CashRegisterView(),
  };
  
  // Ruta con parámetros para detalle de producto y confirmación de orden
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == productDetail) {
      final productId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => ProductDetailView(productId: productId),
      );
    }
    
    if (settings.name == orderConfirmation) {
      final orderId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OrderConfirmationView(orderId: orderId),
      );
    }
    
    return null;
  }
}
