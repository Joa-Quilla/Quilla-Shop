import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';
import '../utils/app_colors.dart';
import '../routes/app_routes.dart';
import '../services/pdf_service.dart';
import '../widgets/custom_snackbar.dart';

class OrderConfirmationView extends StatelessWidget {
  final String orderId;

  const OrderConfirmationView({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<OrderModel?>(
        future: context.read<OrdersController>().getOrderById(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final order = snapshot.data;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Icono de éxito
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Título
                  const Text(
                    '¡Pedido Confirmado!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Mensaje
                  Text(
                    'Tu pedido ha sido procesado exitosamente',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Información de la orden
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Número de Orden',
                          '#${orderId.substring(0, 8).toUpperCase()}',
                          isBold: true,
                        ),
                        const SizedBox(height: 16),
                        if (order != null) ...[
                          _buildInfoRow(
                            'Total',
                            order.totalFormatted,
                            valueColor: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Método de Pago',
                            order.paymentMethod == 'cash_on_delivery' 
                                ? 'Contra Entrega' 
                                : 'PayPal',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Estado',
                            order.statusText,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Artículos',
                            '${order.totalItems}',
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mensaje adicional según método de pago
                  if (order != null && order.paymentMethod == 'cash_on_delivery')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.payments, color: Colors.orange[700], size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pago Contra Entrega',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[900],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Prepara ${order.totalFormatted} en efectivo para cuando llegue tu pedido',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Te enviaremos actualizaciones sobre tu pedido',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Botones
                  Column(
                    children: [
                      // Botón Descargar Factura
                      if (order != null)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => _downloadInvoice(context, order),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                            label: const Text(
                              'Descargar Factura',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.ordersHistory,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Ver Mis Pedidos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.catalog,
                              (route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Seguir Comprando',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadInvoice(BuildContext context, OrderModel order) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Generar PDF
      final File pdfFile = await PdfService.generateInvoice(order);

      if (context.mounted) {
        Navigator.pop(context); // Cerrar loading

        // Mostrar mensaje de éxito con la ruta del archivo
        CustomSnackBar.success(
          context,
          'Factura guardada exitosamente',
        );

        // Mostrar diálogo con opciones
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Factura Generada'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tu factura ha sido generada exitosamente.'),
                const SizedBox(height: 12),
                Text(
                  'Ubicación:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pdfFile.path,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  try {
                    final result = await OpenFile.open(pdfFile.path);
                    if (context.mounted && result.type != ResultType.done) {
                      CustomSnackBar.warning(
                        context,
                        'No se pudo abrir el PDF: ${result.message}',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      CustomSnackBar.error(
                        context,
                        'Error al abrir el archivo: $e',
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                icon: const Icon(Icons.visibility, color: Colors.white),
                label: const Text(
                  'Ver Factura',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Cerrar loading
        CustomSnackBar.error(
          context,
          'Error al generar la factura: $e',
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
