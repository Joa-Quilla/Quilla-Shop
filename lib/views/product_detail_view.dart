import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../controllers/products_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/favorites_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/cart_badge.dart';
import '../widgets/custom_snackbar.dart';
import '../routes/app_routes.dart';

class ProductDetailView extends StatefulWidget {
  final String productId;

  const ProductDetailView({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _selectedImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;

  @override
  Widget build(BuildContext context) {
    final productsController = context.watch<ProductsController>();
    final favoritesController = context.watch<FavoritesController>();
    final product = productsController.getProductById(widget.productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Producto no encontrado'),
        ),
      );
    }

    // Inicializar selecciones si no están definidas
    if (_selectedSize == null && product.sizes.isNotEmpty) {
      _selectedSize = product.sizes.first;
    }
    if (_selectedColor == null && product.colors.isNotEmpty) {
      _selectedColor = product.colors.first;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal con scroll
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con flechas y favorito
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botón atrás
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        // Botones derecha (favorito y carrito)
                        Row(
                          children: [
                            // Badge del carrito
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CartBadge(
                                onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
                                iconColor: Colors.black87,
                                iconSize: 22,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botón favorito
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  favoritesController.isFavorite(product.id) 
                                      ? Icons.favorite 
                                      : Icons.favorite_border,
                                  color: favoritesController.isFavorite(product.id) 
                                      ? AppColors.primary 
                                      : Colors.grey,
                                ),
                                onPressed: () async {
                                  final wasFavorite = favoritesController.isFavorite(product.id);
                                  final success = await favoritesController.toggleFavorite(product);
                                  if (context.mounted && success) {
                                    if (wasFavorite) {
                                      CustomSnackBar.info(context, 'Eliminado de favoritos');
                                    } else {
                                      CustomSnackBar.success(context, 'Agregado a favoritos');
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Imagen principal del producto
                  Center(
                    child: Container(
                      height: 250,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: product.images.isNotEmpty
                          ? Image.network(
                              product.images[_selectedImageIndex],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image_not_supported,
                                  size: 100,
                                  color: Colors.grey[400],
                                );
                              },
                            )
                          : Icon(
                              Icons.shopping_bag,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Miniaturas de imágenes
                  if (product.images.length > 1)
                    SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: product.images.length,
                        itemBuilder: (context, index) {
                          final isSelected = index == _selectedImageIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImageIndex = index;
                              });
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  product.images[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Información del producto
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre y precio
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              product.priceFormatted,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Rating con estrellas
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              if (index < product.fullStars) {
                                return const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              } else if (index == product.fullStars &&
                                  product.hasHalfStar) {
                                return const Icon(
                                  Icons.star_half,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              } else {
                                return Icon(
                                  Icons.star_border,
                                  color: Colors.grey[400],
                                  size: 20,
                                );
                              }
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '(${product.rating})',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Stock disponible
                        Row(
                          children: [
                            Icon(
                              product.hasStock 
                                  ? Icons.check_circle 
                                  : Icons.cancel,
                              color: product.hasStock 
                                  ? Colors.green 
                                  : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              product.hasStock 
                                  ? 'En stock (${product.stock} disponibles)' 
                                  : 'Agotado',
                              style: TextStyle(
                                color: product.hasStock 
                                    ? Colors.green[700] 
                                    : Colors.red[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Tallas disponibles
                        const Text(
                          'Tallas disponibles',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: product.sizes.map((size) {
                            final isSelected = size == _selectedSize;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSize = size;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                child: Text(
                                  'US $size',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Colores disponibles
                        const Text(
                          'Color',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: product.colors.map((colorHex) {
                            final isSelected = colorHex == _selectedColor;
                            final color = Color(
                              int.parse(colorHex.replaceFirst('#', '0xFF')),
                            );
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = colorHex;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Descripción
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 100), // Espacio para el botón flotante
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Botón flotante de agregar al carrito
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: () {
                  final cartController = context.read<CartController>();
                  cartController.addItem(
                    product: product,
                    selectedSize: _selectedSize,
                    selectedColor: _selectedColor,
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Agregado al carrito: ${product.name}',
                      ),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: 'Ver carrito',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.cart);
                        },
                      ),
                    ),
                  );
                },
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: const Text(
                  'Agregar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
