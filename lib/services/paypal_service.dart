// Service: PayPal API - RF10

import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

/// Servicio para procesar pagos con PayPal - RF10
class PayPalService {
  // Credenciales de PayPal Sandbox (modo prueba)
  // IMPORTANTE: Cambiar a credenciales de producción cuando estés listo
  static const String _clientId =
      'AW9dfHaKQ_weXbaAbJroVoZoHM2rjb9MNQMxG7WJy27DL1u_D9mx97PbyW0KtrD0Zo9Lr6xxlDiALZbo';
  static const String _secretKey =
      'EE9KJoF96onbYt3h15HMpql8XprVWMNOaWQVsK1KdGO6KuPk7v2NlavS8HNdtzus-cM834AdRRuULHxO';

  // Configuración de PayPal
  static const bool _isSandbox = true; // Cambiar a false en producción
  static const String _returnURL = 'com.quillashop.app://paypalpay';
  static const String _cancelURL = 'com.quillashop.app://paypalcancel';
  static const String _currency = 'USD'; // PayPal requiere USD

  /// Procesar pago con PayPal
  /// Retorna true si el pago fue exitoso, false si falló o fue cancelado
  static Future<bool> processPayment({
    required BuildContext context,
    required double amount,
    required String description,
    required Function(Map) onSuccess,
    required Function(String) onError,
    required Function() onCancel,
  }) async {
    try {
      // Convertir Quetzales a USD (tipo de cambio aproximado: 1 USD = 7.8 GTQ)
      final amountUSD = amount / 7.8;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => PaypalCheckoutView(
            sandboxMode: _isSandbox,
            clientId: _clientId,
            secretKey: _secretKey,
            transactions: [
              {
                "amount": {
                  "total": amountUSD.toStringAsFixed(2),
                  "currency": _currency,
                  "details": {
                    "subtotal": amountUSD.toStringAsFixed(2),
                    "shipping": '0',
                    "shipping_discount": 0
                  }
                },
                "description": description,
                "item_list": {
                  "items": [
                    {
                      "name": description,
                      "quantity": 1,
                      "price": amountUSD.toStringAsFixed(2),
                      "currency": _currency
                    }
                  ],
                }
              }
            ],
            note: "Contacta al vendedor para cualquier duda",
            onSuccess: (Map params) async {
              debugPrint("PayPal onSuccess: $params");
              onSuccess(params);
            },
            onError: (error) {
              debugPrint("PayPal onError: $error");
              onError(error.toString());
            },
            onCancel: () {
              debugPrint('PayPal cancelled by user');
              onCancel();
            },
          ),
        ),
      );

      return true;
    } catch (e) {
      debugPrint('Error al procesar pago PayPal: $e');
      onError(e.toString());
      return false;
    }
  }

  /// Convertir monto de GTQ a USD
  static double convertGTQtoUSD(double amountGTQ) {
    return amountGTQ / 7.8; // Tipo de cambio aproximado
  }

  /// Formatear monto en USD
  static String formatUSD(double amount) {
    return '\$${amount.toStringAsFixed(2)} USD';
  }

  /// Formatear monto convertido de GTQ a USD con ambas monedas
  static String formatWithConversion(double amountGTQ) {
    final amountUSD = convertGTQtoUSD(amountGTQ);
    return 'Q ${amountGTQ.toStringAsFixed(2)} (\$${amountUSD.toStringAsFixed(2)} USD)';
  }
}
