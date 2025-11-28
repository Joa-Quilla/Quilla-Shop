// Service: Generación de facturas en PDF

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/order_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<File> generateInvoice(OrderModel order) async {
    final pdf = pw.Document();

    // Crear el documento PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header - Logo y título
              _buildHeader(),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // Información de la factura
              _buildInvoiceInfo(order),
              pw.SizedBox(height: 20),

              // Información del cliente
              _buildCustomerInfo(order),
              pw.SizedBox(height: 30),

              // Tabla de productos
              _buildProductsTable(order),
              pw.SizedBox(height: 20),

              // Totales
              _buildTotals(order),
              pw.Spacer(),

              // Footer
              _buildFooter(),
            ],
          );
        },
      ),
    );

    // Guardar el PDF
    return _savePdf(pdf, order.id);
  }

  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'QUILLA SHOP',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Tienda de Ropa y Accesorios',
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'FACTURA',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Guatemala',
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(OrderModel order) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Número de Pedido',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '#${order.id.substring(0, 12).toUpperCase()}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Fecha',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                dateFormat.format(order.createdAt),
                style: const pw.TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerInfo(OrderModel order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL CLIENTE',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          if (order.customerName != null) ...[
            _buildInfoRow('Nombre:', order.customerName!),
            pw.SizedBox(height: 6),
          ],
          if (order.shippingPhone != null) ...[
            _buildInfoRow('Teléfono:', order.shippingPhone!),
            pw.SizedBox(height: 6),
          ],
          if (order.shippingDepartment != null) ...[
            _buildInfoRow('Departamento:', order.shippingDepartment!),
            pw.SizedBox(height: 6),
          ],
          if (order.shippingMunicipality != null) ...[
            _buildInfoRow('Municipio:', order.shippingMunicipality!),
            pw.SizedBox(height: 6),
          ],
          _buildInfoRow('Dirección:', order.shippingAddress),
          pw.SizedBox(height: 6),
          _buildInfoRow('Método de Pago:', _getPaymentMethodText(order.paymentMethod)),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildProductsTable(OrderModel order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PRODUCTOS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              children: [
                _buildTableCell('Producto', isHeader: true),
                _buildTableCell('Cantidad', isHeader: true, align: pw.TextAlign.center),
                _buildTableCell('Precio Unit.', isHeader: true, align: pw.TextAlign.right),
                _buildTableCell('Subtotal', isHeader: true, align: pw.TextAlign.right),
              ],
            ),
            // Items
            ...order.items.map((item) {
              return pw.TableRow(
                children: [
                  _buildTableCell(item.product.name),
                  _buildTableCell('${item.quantity}', align: pw.TextAlign.center),
                  _buildTableCell('Q${item.product.price.toStringAsFixed(2)}', align: pw.TextAlign.right),
                  _buildTableCell('Q${item.subtotal.toStringAsFixed(2)}', align: pw.TextAlign.right),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildTotals(OrderModel order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          _buildTotalRow('Subtotal:', 'Q${order.subtotal.toStringAsFixed(2)}'),
          pw.SizedBox(height: 8),
          _buildTotalRow('Envío:', 'Q${order.shippingCost.toStringAsFixed(2)}'),
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 8),
          _buildTotalRow(
            'TOTAL:',
            'Q${order.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: isTotal ? 16 : 12,
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isTotal ? 18 : 12,
            fontWeight: pw.FontWeight.bold,
            color: isTotal ? PdfColors.blue900 : PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 8),
        pw.Text(
          '¡Gracias por tu compra!',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Para cualquier consulta, contáctanos',
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          'www.quillashop.com | info@quillashop.com',
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  static String _getPaymentMethodText(String method) {
    switch (method) {
      case 'paypal':
        return 'PayPal';
      case 'card':
        return 'Tarjeta de Crédito/Débito';
      case 'cash':
        return 'Efectivo contra entrega';
      case 'simulated':
        return 'Pago Simulado';
      default:
        return method;
    }
  }

  static Future<File> _savePdf(pw.Document pdf, String orderId) async {
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/factura_${orderId.substring(0, 8)}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
