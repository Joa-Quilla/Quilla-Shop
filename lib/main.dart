import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'utils/app_colors.dart';
import 'controllers/auth_controller.dart';
import 'controllers/products_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/orders_controller.dart';
import 'controllers/admin_controller.dart';
import 'controllers/favorites_controller.dart';
import 'controllers/cash_register_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ProductsController()),
        ChangeNotifierProvider(
          create: (_) {
            final cartController = CartController();
            cartController.loadCart(); // Cargar carrito guardado
            return cartController;
          },
        ),
        ChangeNotifierProvider(create: (_) => OrdersController()),
        ChangeNotifierProvider(create: (_) => AdminController()),
        ChangeNotifierProvider(create: (_) => CashRegisterController()),
        ChangeNotifierProxyProvider<AuthController, FavoritesController>(
          create: (context) => FavoritesController(
            authController: context.read<AuthController>(),
          ),
          update: (context, auth, previous) => previous ?? FavoritesController(
            authController: auth,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Quilla Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto',
        ),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
