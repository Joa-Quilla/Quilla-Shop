import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../controllers/orders_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_colors.dart';
import '../utils/guatemala_locations.dart';
import '../routes/app_routes.dart';
import '../services/paypal_service.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedMunicipality;
  List<String> _municipalities = [];

  bool _isProcessing = false;
  final double _shippingCost = 25.0; // Costo fijo de envío
  
  // Método de pago seleccionado: 'paypal' o 'cash_on_delivery'
  String _selectedPaymentMethod = 'paypal';

  @override
  void initState() {
    super.initState();
    // Pre-llenar el nombre del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      final user = authController.currentUser;
      if (user != null && user.name.isNotEmpty) {
        _nameController.text = user.name;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que se hayan seleccionado departamento y municipio
    if (_selectedDepartment == null || _selectedMunicipality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona departamento y municipio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cartController = context.read<CartController>();
    final ordersController = context.read<OrdersController>();
    final authController = context.read<AuthController>();

    final userId = authController.currentUser?.id ?? '';
    final total = cartController.subtotal + _shippingCost;

    // 1. Verificar stock disponible ANTES de procesar pago
    final hasStock = await ordersController.checkStockAvailability(cartController.items);
    
    if (!hasStock) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ordersController.error ?? 'Stock insuficiente'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Procesar según el método de pago seleccionado
    if (_selectedPaymentMethod == 'cash_on_delivery') {
      // PAGO CONTRA ENTREGA: Crear orden directamente
      await _processCashOnDeliveryOrder(
        ordersController: ordersController,
        cartController: cartController,
        userId: userId,
        total: total,
      );
    } else {
      // PAGO CON PAYPAL
      await _processPayPalOrder(
        ordersController: ordersController,
        cartController: cartController,
        userId: userId,
        total: total,
      );
    }
  }

  /// Procesar pedido con pago contra entrega
  Future<void> _processCashOnDeliveryOrder({
    required OrdersController ordersController,
    required CartController cartController,
    required String userId,
    required double total,
  }) async {
    try {
      // 1. Descontar stock primero
      final stockUpdated = await ordersController.decreaseStock(cartController.items);
      
      if (!stockUpdated) {
        setState(() {
          _isProcessing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ordersController.error ?? 'Error al actualizar el inventario.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      
      // 2. Crear la orden con método "contra entrega"
      final orderId = await ordersController.createOrder(
        userId: userId,
        items: cartController.items,
        subtotal: cartController.subtotal,
        shippingCost: _shippingCost,
        total: total,
        shippingAddress: _addressController.text.trim(),
        shippingDepartment: _selectedDepartment,
        shippingMunicipality: _selectedMunicipality,
        shippingPhone: _phoneController.text.trim(),
        customerName: _nameController.text.trim(),
        paymentMethod: 'cash_on_delivery',
      );

      setState(() {
        _isProcessing = false;
      });

      if (orderId != null) {
        // Limpiar el carrito
        cartController.clearCart();

        // Navegar a confirmación
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.orderConfirmation,
            arguments: orderId,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al crear la orden. Intenta de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Procesar pedido con PayPal
  Future<void> _processPayPalOrder({
    required OrdersController ordersController,
    required CartController cartController,
    required String userId,
    required double total,
  }) async {
    await PayPalService.processPayment(
      context: context,
      amount: total,
      description: 'Pedido de ${cartController.totalItems} productos - Quilla Shop',
      onSuccess: (Map params) async {
        // 3. Pago exitoso: Descontar stock y crear orden
        debugPrint('✅ Pago exitoso: $params');
        
        // IMPORTANTE: Descontar stock PRIMERO
        final stockUpdated = await ordersController.decreaseStock(cartController.items);
        
        if (!stockUpdated) {
          setState(() {
            _isProcessing = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ordersController.error ?? 'Error al actualizar el inventario. Contacta al vendedor.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }
        
        // Crear la orden DESPUÉS de descontar stock
        final orderId = await ordersController.createOrder(
          userId: userId,
          items: cartController.items,
          subtotal: cartController.subtotal,
          shippingCost: _shippingCost,
          total: total,
          shippingAddress: _addressController.text.trim(),
          shippingDepartment: _selectedDepartment,
          shippingMunicipality: _selectedMunicipality,
          shippingPhone: _phoneController.text.trim(),
          customerName: _nameController.text.trim(),
          paymentMethod: 'paypal',
        );

        setState(() {
          _isProcessing = false;
        });

        if (orderId != null) {
          // Limpiar el carrito
          cartController.clearCart();

          // Navegar a confirmación
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.orderConfirmation,
              arguments: orderId,
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al crear la orden. Contacta al vendedor.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      onError: (String error) {
        // Pago falló
        setState(() {
          _isProcessing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error en el pago: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      onCancel: () {
        // Usuario canceló el pago
        setState(() {
          _isProcessing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pago cancelado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartController = context.watch<CartController>();
    final total = cartController.subtotal + _shippingCost;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirmar Pedido',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen de productos
                _buildSectionTitle('Resumen del Pedido'),
                const SizedBox(height: 12),
                _buildOrderSummary(cartController),
                const SizedBox(height: 24),

                // Información de envío
                _buildSectionTitle('Información de Envío'),
                const SizedBox(height: 12),
                _buildShippingForm(),
                const SizedBox(height: 24),

                // Método de pago
                _buildSectionTitle('Método de Pago'),
                const SizedBox(height: 12),
                _buildPaymentMethod(),
                const SizedBox(height: 24),

                // Resumen de costos
                _buildCostSummary(cartController, total),
                const SizedBox(height: 24),

                // Botón de confirmar
                _buildConfirmButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildOrderSummary(CartController cartController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...cartController.items.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == cartController.items.length - 1;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product.images.isNotEmpty
                              ? item.product.images[0]
                              : '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cantidad: ${item.quantity}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (item.selectedSize != null)
                              Text(
                                'Talla: ${item.selectedSize}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        item.subtotalFormatted,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, color: Colors.grey[200]),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildShippingForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa tu nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa tu teléfono';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Dirección detallada (Aldea, zona, calle, etc.)',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
              hintText: 'Ej: Aldea Sacuchum, Zona 3, Calle Principal',
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa tu dirección';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Dropdown Departamento
          DropdownButtonFormField<String>(
            value: _selectedDepartment,
            decoration: const InputDecoration(
              labelText: 'Departamento',
              prefixIcon: Icon(Icons.map_outlined),
              border: OutlineInputBorder(),
            ),
            items: GuatemalaLocations.departments.map((dept) {
              return DropdownMenuItem(
                value: dept,
                child: Text(dept),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDepartment = value;
                _selectedMunicipality = null; // Reset municipio
                _municipalities = value != null 
                    ? GuatemalaLocations.getMunicipalities(value)
                    : [];
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona un departamento';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Dropdown Municipio
          DropdownButtonFormField<String>(
            value: _selectedMunicipality,
            decoration: const InputDecoration(
              labelText: 'Municipio',
              prefixIcon: Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(),
            ),
            items: _municipalities.map((muni) {
              return DropdownMenuItem(
                value: muni,
                child: Text(muni),
              );
            }).toList(),
            onChanged: _selectedDepartment == null 
                ? null 
                : (value) {
                    setState(() {
                      _selectedMunicipality = value;
                    });
                  },
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona un municipio';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    final cartController = context.watch<CartController>();
    final total = cartController.subtotal + _shippingCost;
    final totalUSD = PayPalService.convertGTQtoUSD(total);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Opción 1: PayPal
          _buildPaymentOption(
            value: 'paypal',
            icon: Icons.payment,
            iconColor: Colors.blue.shade700,
            iconBgColor: Colors.blue.shade50,
            title: 'PayPal',
            subtitle: 'Total: Q ${total.toStringAsFixed(2)} (\$${totalUSD.toStringAsFixed(2)} USD)',
            description: 'Pago seguro con PayPal',
          ),
          
          const Divider(height: 24),
          
          // Opción 2: Pago contra entrega
          _buildPaymentOption(
            value: 'cash_on_delivery',
            icon: Icons.local_shipping,
            iconColor: Colors.green.shade700,
            iconBgColor: Colors.green.shade50,
            title: 'Pago Contra Entrega',
            subtitle: 'Total: Q ${total.toStringAsFixed(2)}',
            description: 'Paga en efectivo al recibir tu pedido',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String description,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? iconColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSummary(CartController cartController, double total) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCostRow('Subtotal', 'Q ${cartController.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildCostRow('Envío', 'Q ${_shippingCost.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildCostRow(
            'Total',
            'Q ${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    final buttonText = _selectedPaymentMethod == 'paypal' 
        ? 'Pagar con PayPal' 
        : 'Confirmar Pedido';
    final buttonColor = _selectedPaymentMethod == 'paypal' 
        ? Colors.blue.shade700 
        : AppColors.primary;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedPaymentMethod == 'paypal' 
                        ? Icons.payment 
                        : Icons.local_shipping,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
