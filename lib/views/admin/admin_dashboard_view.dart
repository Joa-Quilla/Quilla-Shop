// View: Dashboard del administrador - RF04, RF17

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../routes/app_routes.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({Key? key}) : super(key: key);

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    // Cargar estadísticas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminController = context.read<AdminController>();
      adminController.calculateStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final adminController = context.watch<AdminController>();
    final user = authController.currentUser;

    // Verificar que sea admin
    if (user == null || !user.isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 100, color: AppColors.error),
              const SizedBox(height: 20),
              const Text(
                'Acceso Denegado',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('No tienes permisos de administrador'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final stats = adminController.statistics;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminController.calculateStatistics(),
            tooltip: 'Actualizar estadísticas',
          ),
        ],
      ),
      body: adminController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => adminController.calculateStatistics(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bienvenida
                    Text(
                      '¡Bienvenido, ${user.name}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Panel de control y estadísticas',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tarjetas de estadísticas
                    _buildStatisticsCards(stats),
                    const SizedBox(height: 24),

                    // Acciones rápidas
                    _buildQuickActions(context),
                    const SizedBox(height: 24),

                    // Alertas
                    if (stats['lowStockProducts'] != null && stats['lowStockProducts'] > 0)
                      _buildAlert(
                        'Productos con bajo stock',
                        '${stats['lowStockProducts']} productos tienen menos de 5 unidades',
                        Icons.warning,
                        AppColors.warning,
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatisticsCards(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Total Ventas del Día',
          'Q ${(stats['totalSales'] ?? 0.0).toStringAsFixed(2)}',
          Icons.attach_money,
          AppColors.success,
        ),
        _buildStatCard(
          'Pedidos',
          '${stats['totalOrders'] ?? 0}',
          Icons.shopping_bag,
          AppColors.primary,
        ),
        _buildStatCard(
          'Productos',
          '${stats['totalProducts'] ?? 0}',
          Icons.inventory,
          AppColors.info,
        ),
        _buildStatCard(
          'Usuarios',
          '${stats['totalUsers'] ?? 0}',
          Icons.people,
          AppColors.secondary,
        ),
        _buildStatCard(
          'Pendientes',
          '${stats['pendingOrders'] ?? 0}',
          Icons.hourglass_empty,
          AppColors.warning,
        ),
        _buildStatCard(
          'Entregados',
          '${stats['deliveredOrders'] ?? 0}',
          Icons.check_circle,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          context,
          'Gestionar Productos',
          'Crear, editar y eliminar productos',
          Icons.inventory_2,
          AppColors.primary,
          () => Navigator.pushNamed(context, AppRoutes.manageProducts),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          'Gestionar Categorías',
          'Administrar categorías de productos',
          Icons.category,
          AppColors.secondary,
          () => Navigator.pushNamed(context, AppRoutes.manageCategories),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          'Gestionar Pedidos',
          'Ver y actualizar estado de pedidos',
          Icons.shopping_cart,
          AppColors.info,
          () => Navigator.pushNamed(context, AppRoutes.manageOrders),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          'Caja',
          'Cerrar caja y ver historial de ventas',
          Icons.monetization_on,
          AppColors.success,
          () async {
            await Navigator.pushNamed(context, AppRoutes.cashRegister);
            // Cuando regrese de Caja, recargar estadísticas
            if (context.mounted) {
              final adminController = context.read<AdminController>();
              adminController.calculateStatistics();
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 20, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildAlert(String title, String message, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
