// View: Gestión de pedidos (Admin) - RF15

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';
import '../../models/order_model.dart';
import '../../utils/app_colors.dart';

class ManageOrdersView extends StatefulWidget {
  const ManageOrdersView({Key? key}) : super(key: key);

  @override
  State<ManageOrdersView> createState() => _ManageOrdersViewState();
}

class _ManageOrdersViewState extends State<ManageOrdersView> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchAllOrders();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'shipped':
        return AppColors.secondary;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'shipped':
        return 'Enviado';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminController = context.watch<AdminController>();

    List<OrderModel> filteredOrders = _selectedStatus == 'all'
        ? adminController.allOrders
        : adminController.allOrders.where((o) => o.status == _selectedStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Pedidos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pendiente', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Confirmado', 'confirmed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Enviado', 'shipped'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Entregado', 'delivered'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelado', 'cancelled'),
                ],
              ),
            ),
          ),

          // Lista de pedidos
          Expanded(
            child: adminController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? const Center(child: Text('No hay pedidos'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(order.status),
                                child: const Icon(Icons.shopping_bag, color: Colors.white),
                              ),
                              title: Text(
                                'Pedido #${order.id.substring(0, 8)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cliente: ${order.userId}'),
                                  Text(
                                    'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
                                  ),
                                  Text(
                                    'Total: Q${order.total.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(
                                  _getStatusText(order.status),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                backgroundColor: _getStatusColor(order.status),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Productos:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      ...order.items.map((item) => Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Text('• ${item.product.name} x${item.quantity} - Q${item.subtotal.toStringAsFixed(2)}'),
                                          )),
                                      const Divider(height: 24),
                                      const Text(
                                        'Información de envío:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Nombre: ${order.shippingInfo['name']}'),
                                      Text('Dirección: ${order.shippingInfo['address']}'),
                                      Text('Ciudad: ${order.shippingInfo['city']}'),
                                      Text('Código Postal: ${order.shippingInfo['postalCode']}'),
                                      Text('Teléfono: ${order.shippingInfo['phone']}'),
                                      const Divider(height: 24),
                                      const Text(
                                        'Cambiar estado:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          _buildStatusButton(order, 'pending', 'Pendiente'),
                                          _buildStatusButton(order, 'confirmed', 'Confirmado'),
                                          _buildStatusButton(order, 'shipped', 'Enviado'),
                                          _buildStatusButton(order, 'delivered', 'Entregado'),
                                          _buildStatusButton(order, 'cancelled', 'Cancelado'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    return FilterChip(
      label: Text(label),
      selected: _selectedStatus == status,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
        });
      },
      selectedColor: AppColors.secondary,
      labelStyle: TextStyle(
        color: _selectedStatus == status ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildStatusButton(OrderModel order, String status, String label) {
    final isCurrentStatus = order.status == status;
    return ElevatedButton(
      onPressed: isCurrentStatus
          ? null
          : () async {
              await context.read<AdminController>().updateOrderStatus(order.id, status);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Estado actualizado a: $label')),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrentStatus ? Colors.grey : _getStatusColor(status),
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }
}
