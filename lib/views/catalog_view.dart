import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/products_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_badge.dart';
import '../routes/app_routes.dart';

class CatalogView extends StatefulWidget {
  const CatalogView({Key? key}) : super(key: key);

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedNavIndex = 0; // 0=Home, 1=Search, 2=Cart, 3=Favorites

  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsController = context.read<ProductsController>();
      productsController.loadProducts().then((_) {
        productsController.loadCategories();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final productsController = context.watch<ProductsController>();
    final isGuest = authController.isGuest;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // Badge del carrito
          CartBadge(
            onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
            iconColor: Colors.black87,
          ),
          const SizedBox(width: 8),
          // Ícono de usuario con menú popup
          Padding(
            padding: const EdgeInsets.only(right: 16),
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
                    value: 'favorites',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.favorite, color: AppColors.primary),
                      title: Text('Favoritos'),
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
          ),
        ],
      ),
      drawer: _buildDrawer(context, authController),
      body: RefreshIndicator(
        onRefresh: () => productsController.loadProducts(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text(
                'Nuestros',
                style: TextStyle(
                  fontSize: 28,
                  color: AppColors.textSecondary,
                ),
              ),
              const Text(
                'Productos',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Barra de búsqueda y filtro
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          productsController.searchProducts(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar Productos',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
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
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: AppColors.textPrimary),
                      onPressed: () {
                        // TODO: Mostrar filtros avanzados
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Categorías con diseño rectangular como en la imagen
              if (productsController.categories.isNotEmpty)
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productsController.categories.length,
                    itemBuilder: (context, index) {
                      final category = productsController.categories[index];
                      final isSelected = 
                          productsController.selectedCategory == category.name;
                      
                      // Obtener imagen de ejemplo de un producto de esta categoría
                      final categoryProducts = productsController.products
                          .where((p) => p.category == category.name)
                          .toList();
                      final imageUrl = categoryProducts.isNotEmpty && 
                          categoryProducts.first.images.isNotEmpty
                          ? categoryProducts.first.images.first
                          : '';
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              productsController.clearFilters();
                            } else {
                              productsController.filterByCategory(category.name);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.primary 
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Imagen del producto de la categoría
                                if (imageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 35,
                                      height: 35,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          productsController.getCategoryIconData(category.name),
                                          size: 24,
                                          color: isSelected 
                                              ? AppColors.primary 
                                              : Colors.grey[700],
                                        );
                                      },
                                    ),
                                  )
                                else
                                  Icon(
                                    productsController.getCategoryIconData(category.name),
                                    size: 24,
                                    color: isSelected 
                                        ? AppColors.primary 
                                        : Colors.grey[700],
                                  ),
                                const SizedBox(width: 12),
                                // Nombre de la categoría
                                Text(
                                  category.name.replaceAll(' Deportivo', '').replaceAll(' Deportiva', ''),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected 
                                        ? FontWeight.bold 
                                        : FontWeight.w500,
                                    color: isSelected 
                                        ? AppColors.primary 
                                        : Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Productos
              if (productsController.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (productsController.errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          productsController.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => productsController.loadProducts(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (productsController.products.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay productos disponibles',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72, // Aumentado para evitar overflow
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: productsController.products.length,
                  itemBuilder: (context, index) {
                    final product = productsController.products[index];
                    return ProductCard(product: product);
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  void _handleUserMenuSelection(BuildContext context, String value, AuthController authController) async {
    switch (value) {
      case 'profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vista de perfil en desarrollo')),
        );
        break;
      case 'orders':
        Navigator.pushNamed(context, AppRoutes.ordersHistory);
        break;
      case 'favorites':
        Navigator.pushNamed(context, AppRoutes.favorites);
        break;
      case 'settings':
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
      case 'logout':
        await authController.logout();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
        break;
      case 'login':
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        break;
    }
  }

  Widget _buildDrawer(BuildContext context, AuthController authController) {
    final user = authController.currentUser;
    final isGuest = authController.isGuest;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(
              isGuest ? 'Invitado' : (user?.name ?? 'Usuario'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(isGuest ? 'Navegando sin cuenta' : (user?.email ?? '')),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                isGuest ? Icons.person_outline : Icons.person,
                size: 50,
                color: AppColors.primary,
              ),
            ),
          ),
          if (!isGuest) ...[
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
              title: const Text('Mis Pedidos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.ordersHistory);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline, color: AppColors.primary),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.favorites);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.primary),
              title: const Text('Mi Perfil'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar a perfil
              },
            ),
            // Panel Admin - Solo visible para administradores
            if (user != null && user.isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: AppColors.info),
                title: const Text(
                  'Panel Admin',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.adminDashboard);
                },
              ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.textSecondary),
            title: const Text('Ayuda y Soporte'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.help);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              isGuest ? Icons.login : Icons.logout,
              color: AppColors.error,
            ),
            title: Text(
              isGuest ? 'Iniciar Sesión' : 'Cerrar Sesión',
              style: const TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              if (isGuest) {
                Navigator.pushReplacementNamed(context, '/login');
              } else {
                await authController.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
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
              // Home
              _buildNavItem(
                icon: Icons.home,
                index: 0,
                isSelected: _selectedNavIndex == 0,
                onTap: () {
                  setState(() => _selectedNavIndex = 0);
                },
              ),
              // Search
              _buildNavItem(
                icon: Icons.search,
                index: 1,
                isSelected: _selectedNavIndex == 1,
                onTap: () {
                  setState(() => _selectedNavIndex = 1);
                  // Enfocar el campo de búsqueda
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usa la barra de búsqueda arriba'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              // Cart
              _buildNavItem(
                icon: Icons.shopping_cart_outlined,
                index: 2,
                isSelected: _selectedNavIndex == 2,
                onTap: () {
                  setState(() => _selectedNavIndex = 2);
                  Navigator.pushNamed(context, AppRoutes.cart).then((_) {
                    // Cuando regrese del carrito, resetear el índice
                    if (mounted) setState(() => _selectedNavIndex = 0);
                  });
                },
              ),
              // Favorites
              _buildNavItem(
                icon: Icons.favorite_outline,
                index: 3,
                isSelected: _selectedNavIndex == 3,
                onTap: () {
                  setState(() => _selectedNavIndex = 3);
                  Navigator.pushNamed(context, AppRoutes.favorites).then((_) {
                    // Cuando regrese de favoritos, resetear el índice
                    if (mounted) setState(() => _selectedNavIndex = 0);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
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
}
