import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_badge.dart';
import '../widgets/app_drawer.dart';
import '../routes/app_routes.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesController>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesController = context.watch<FavoritesController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          'Mis Favoritos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (favoritesController.totalFavorites > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearAllDialog(context, favoritesController),
              tooltip: 'Limpiar todos',
            ),
          CartBadge(
            onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
            iconColor: Colors.black87,
          ),
          _buildUserMenu(context),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => favoritesController.loadFavorites(),
        child: favoritesController.isLoading
            ? const Center(child: CircularProgressIndicator())
            : favoritesController.favoriteProducts.isEmpty
                ? _buildEmptyState(context)
                : _buildFavoritesList(context, favoritesController),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 120,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                'No tienes favoritos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Agrega productos a tus favoritos\ntocando el corazón',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.catalog),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Explorar Productos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, FavoritesController controller) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${controller.totalFavorites} ${controller.totalFavorites == 1 ? "producto favorito" : "productos favoritos"}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Grid de productos
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: controller.favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = controller.favoriteProducts[index];
              return ProductCard(product: product);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                isSelected: false,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.search,
                isSelected: false,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usa el buscador en la página principal'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.shopping_cart_outlined,
                isSelected: false,
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.cart);
                },
              ),
              _buildNavItem(
                icon: Icons.favorite,
                isSelected: true,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, isSelected ? -20 : 0, 0),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[400],
            size: isSelected ? 30 : 28,
          ),
        ),
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isGuest = authController.isGuest;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<String>(
        onSelected: (value) => _handleUserMenuSelection(context, value, authController),
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        itemBuilder: (context) => [
          if (!isGuest) ...[
            const PopupMenuItem(
              value: 'profile',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person, color: AppColors.primary),
                title: Text('Mi Perfil'),
              ),
            ),
            const PopupMenuItem(
              value: 'orders',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.shopping_bag, color: AppColors.primary),
                title: Text('Mis Pedidos'),
              ),
            ),
            const PopupMenuItem(
              value: 'home',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.home, color: AppColors.primary),
                title: Text('Inicio'),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.settings, color: AppColors.textSecondary),
                title: Text('Configuración'),
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout, color: AppColors.error),
                title: Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
              ),
            ),
          ] else ...[
            const PopupMenuItem(
              value: 'login',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.login, color: AppColors.primary),
                title: Text('Iniciar Sesión'),
              ),
            ),
          ],
        ],
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: Icon(
            isGuest ? Icons.person_outline : Icons.person,
            color: Colors.grey[700],
            size: 24,
          ),
        ),
      ),
    );
  }

  void _handleUserMenuSelection(BuildContext context, String value, AuthController authController) {
    switch (value) {
      case 'profile':
        // TODO: Navegar a perfil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil en desarrollo')),
        );
        break;
      case 'orders':
        Navigator.pushNamed(context, AppRoutes.ordersHistory);
        break;
      case 'home':
        Navigator.pushNamed(context, AppRoutes.home);
        break;
      case 'settings':
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
      case 'logout':
        _showLogoutDialog(context, authController);
        break;
      case 'login':
        Navigator.pushNamed(context, AppRoutes.login);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              authController.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, FavoritesController controller) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpiar Favoritos'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar todos tus productos favoritos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await controller.clearAllFavorites();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                        ? 'Favoritos eliminados'
                        : 'Error al eliminar favoritos'),
                      backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );
  }
}
