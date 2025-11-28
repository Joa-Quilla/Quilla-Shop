import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../widgets/cart_badge.dart';
import '../routes/app_routes.dart';

class HelpView extends StatefulWidget {
  const HelpView({Key? key}) : super(key: key);

  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ayuda y Soporte',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          CartBadge(
            onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
            iconColor: Colors.black87,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contacto Directo
            _buildContactCard(
              icon: Icons.phone,
              title: 'Llámanos',
              subtitle: '+502 1234-5678',
              color: Colors.green,
              onTap: () => _launchPhone('+50212345678'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.email,
              title: 'Envíanos un correo',
              subtitle: 'soporte@quillashop.com',
              color: AppColors.info,
              onTap: () => _launchEmail('soporte@quillashop.com'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.chat,
              title: 'WhatsApp',
              subtitle: 'Chat directo',
              color: Colors.green[700]!,
              onTap: () => _launchWhatsApp('+50212345678'),
            ),

            const SizedBox(height: 32),

            // FAQ
            const Text(
              'Preguntas Frecuentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _buildFAQItem(
              question: '¿Cómo realizo un pedido?',
              answer: 'Selecciona los productos que deseas, agrégalos al carrito y completa el proceso de checkout con tu información de envío.',
            ),
            _buildFAQItem(
              question: '¿Cuánto tarda la entrega?',
              answer: 'Las entregas toman entre 3-5 días hábiles dentro del área metropolitana y 5-7 días para el interior del país.',
            ),
            _buildFAQItem(
              question: '¿Puedo devolver un producto?',
              answer: 'Sí, aceptamos devoluciones dentro de los primeros 30 días si el producto está en perfecto estado y con su empaque original.',
            ),
            _buildFAQItem(
              question: '¿Qué métodos de pago aceptan?',
              answer: 'Aceptamos pagos en efectivo contra entrega, tarjetas de crédito/débito y transferencias bancarias.',
            ),
            _buildFAQItem(
              question: '¿Tienen tienda física?',
              answer: 'Sí, nuestra tienda está ubicada en la Zona 10 de la Ciudad de Guatemala. Horario: Lunes a Sábado de 9:00 AM a 6:00 PM.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    await Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Teléfono copiado: $phoneNumber')),
    );
  }

  Future<void> _launchEmail(String email) async {
    await Clipboard.setData(ClipboardData(text: email));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email copiado: $email')),
    );
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    await Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('WhatsApp copiado: $phoneNumber\nAbre WhatsApp y pega el número')),
    );
  }
}
