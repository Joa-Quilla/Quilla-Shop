// View: Gestión de productos MEJORADA con todos los campos - RF13, RF16

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/admin_controller.dart';
import '../../models/product_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_snackbar.dart';

class ManageProductsViewNew extends StatefulWidget {
  const ManageProductsViewNew({Key? key}) : super(key: key);

  @override
  State<ManageProductsViewNew> createState() => _ManageProductsViewNewState();
}

class _ManageProductsViewNewState extends State<ManageProductsViewNew> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminController = context.read<AdminController>();
      adminController.fetchAllProducts();
      adminController.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminController = context.watch<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Productos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: adminController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adminController.allProducts.length,
              itemBuilder: (context, index) {
                final product = adminController.allProducts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image, size: 50),
                          )
                        : const Icon(Icons.image, size: 50),
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.brand != null)
                          Text('Marca: ${product.brand}',
                              style: TextStyle(color: Colors.grey[600])),
                        Text('Stock: ${product.stock}'),
                        Text('Precio: Q ${product.price.toStringAsFixed(2)}'),
                        if (product.sizes.isNotEmpty)
                          Text('Tallas: ${product.sizes.join(", ")}'),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.info),
                          onPressed: () =>
                              _showEditProductDialog(context, product),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.error,
                          ),
                          onPressed: () =>
                              _showDeleteProductDialog(context, product),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProductDialog(context),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateProductDialog(BuildContext context) {
    final adminController = context.read<AdminController>();
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final brandController = TextEditingController();
    final ratingController = TextEditingController(text: '0.0');
    String? selectedCategory;
    File? selectedImage;
    bool isTrending = false;
    
    // Tallas y colores
    final List<String> availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
    Set<String> selectedSizes = {};
    List<Color> selectedColors = [];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setState) => AlertDialog(
          title: const Text('Crear Producto Nuevo'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de imagen
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() => selectedImage = File(image.path));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Toca para seleccionar imagen',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nombre
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Producto *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Marca
                  TextFormField(
                    controller: brandController,
                    decoration: const InputDecoration(
                      labelText: 'Marca (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.branding_watermark),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio *',
                      border: OutlineInputBorder(),
                      prefixText: 'Q ',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (v) =>
                        v == null || v.isEmpty || double.tryParse(v) == null
                            ? 'Precio inválido'
                            : null,
                  ),
                  const SizedBox(height: 16),

                  // Stock
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock (Cantidad) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Categoría
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: adminController.categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.name,
                            child: Text('${c.icon} ${c.name}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedCategory = v),
                    validator: (v) => v == null ? 'Selecciona categoría' : null,
                  ),
                  const SizedBox(height: 16),

                  // Rating (Estrellas)
                  TextFormField(
                    controller: ratingController,
                    decoration: const InputDecoration(
                      labelText: 'Rating (0.0 - 5.0)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.star),
                      helperText: 'Calificación del producto',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d\.?\d?')),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return null; // Opcional
                      final rating = double.tryParse(v);
                      if (rating == null || rating < 0 || rating > 5) {
                        return 'Debe estar entre 0.0 y 5.0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // IsTrending (Producto en tendencia)
                  SwitchListTile(
                    title: const Text('Producto en Tendencia'),
                    subtitle: const Text('Aparecerá destacado en el catálogo'),
                    value: isTrending,
                    onChanged: (value) {
                      setState(() => isTrending = value);
                    },
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 20),

                  // TALLAS
                  const Text(
                    'Tallas Disponibles:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: availableSizes.map((size) {
                      final isSelected = selectedSizes.contains(size);
                      return FilterChip(
                        label: Text(size),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedSizes.add(size);
                            } else {
                              selectedSizes.remove(size);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withOpacity(0.3),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // COLORES
                  const Text(
                    'Colores Disponibles:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ...selectedColors.map((color) {
                        return Chip(
                          avatar: CircleAvatar(backgroundColor: color),
                          label: Text(
                            color.value.toRadixString(16).substring(2).toUpperCase(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          onDeleted: () {
                            setState(() => selectedColors.remove(color));
                          },
                        );
                      }).toList(),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar Color'),
                        onPressed: () {
                          _showColorPicker(stateContext, (color) {
                            setState(() => selectedColors.add(color));
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (selectedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Selecciona una imagen del producto')),
                    );
                    return;
                  }
                  
                  Navigator.pop(dialogContext);
                  
                  // Mostrar loading mientras se crea
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  // Convertir colores a hex strings
                  List<String> colorHexCodes = selectedColors
                      .map((c) =>
                          '#${c.value.toRadixString(16).substring(2).toUpperCase()}')
                      .toList();

                  try {
                    final success = await adminController.createProduct(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      price: double.parse(priceController.text),
                      stock: int.parse(stockController.text),
                      category: selectedCategory!,
                      brand: brandController.text.trim().isEmpty
                          ? null
                          : brandController.text.trim(),
                      sizes: selectedSizes.toList(),
                      colors: colorHexCodes,
                      rating: double.tryParse(ratingController.text) ?? 0.0,
                      isTrending: isTrending,
                      imageFile: selectedImage,
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context); // Cerrar loading
                      
                      if (success) {
                        CustomSnackBar.success(context, 'Producto creado exitosamente');
                      } else {
                        CustomSnackBar.error(context, adminController.errorMessage ?? 'Error al crear producto');
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Cerrar loading
                      CustomSnackBar.error(context, 'Error crítico: $e');
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Crear Producto'),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, Function(Color) onColorSelected) {
    // Lista de colores predefinidos comunes
    final List<Color> commonColors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.brown,
      Colors.grey,
      Colors.teal,
      const Color(0xFFFFD700), // Dorado
      const Color(0xFFC0C0C0), // Plateado
      const Color(0xFF000080), // Azul marino
      const Color(0xFF800000), // Marrón oscuro
      const Color(0xFF008080), // Verde azulado
      const Color(0xFF808000), // Verde oliva
    ];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona un Color'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: commonColors.length,
              itemBuilder: (context, index) {
                final color = commonColors[index];
                return GestureDetector(
                  onTap: () {
                    onColorSelected(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, ProductModel product) {
    final adminController = context.read<AdminController>();
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());
    final stockController = TextEditingController(text: product.stock.toString());
    final brandController = TextEditingController(text: product.brand ?? '');
    final ratingController = TextEditingController(text: product.rating.toString());
    String? selectedCategory = product.category;
    File? selectedImage;
    bool isTrending = product.isTrending;
    
    // Tallas y colores
    final List<String> availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
    Set<String> selectedSizes = Set<String>.from(product.sizes);
    List<Color> selectedColors = product.colors.map((hex) {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    }).toList();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setState) => AlertDialog(
          title: const Text('Editar Producto'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen actual o nueva
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() => selectedImage = File(image.path));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(selectedImage!, fit: BoxFit.cover),
                            )
                          : product.images.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    product.images.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image, size: 60, color: Colors.grey[400]),
                                        const SizedBox(height: 8),
                                        const Text('Toca para cambiar imagen'),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 60, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    const Text('Toca para agregar imagen'),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nombre
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Producto *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Marca
                  TextFormField(
                    controller: brandController,
                    decoration: const InputDecoration(
                      labelText: 'Marca (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.branding_watermark),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio *',
                      border: OutlineInputBorder(),
                      prefixText: 'Q ',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (v) =>
                        v == null || v.isEmpty || double.tryParse(v) == null
                            ? 'Precio inválido'
                            : null,
                  ),
                  const SizedBox(height: 16),

                  // Stock
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock (Cantidad) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Categoría
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: adminController.categories
                        .map((c) => DropdownMenuItem(
                              value: c.name,
                              child: Text('${c.icon} ${c.name}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => selectedCategory = v),
                    validator: (v) => v == null ? 'Selecciona categoría' : null,
                  ),
                  const SizedBox(height: 16),

                  // Rating
                  TextFormField(
                    controller: ratingController,
                    decoration: const InputDecoration(
                      labelText: 'Rating (0.0 - 5.0)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.star),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d\.?\d?')),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final rating = double.tryParse(v);
                      if (rating == null || rating < 0 || rating > 5) {
                        return 'Debe estar entre 0.0 y 5.0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // IsTrending
                  SwitchListTile(
                    title: const Text('Producto en Tendencia'),
                    subtitle: const Text('Aparecerá destacado en el catálogo'),
                    value: isTrending,
                    onChanged: (value) {
                      setState(() => isTrending = value);
                    },
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 20),

                  // Tallas
                  const Text(
                    'Tallas Disponibles:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: availableSizes.map((size) {
                      final isSelected = selectedSizes.contains(size);
                      return FilterChip(
                        label: Text(size),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedSizes.add(size);
                            } else {
                              selectedSizes.remove(size);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withOpacity(0.3),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Colores
                  const Text(
                    'Colores Disponibles:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ...selectedColors.map((color) {
                        return Chip(
                          avatar: CircleAvatar(backgroundColor: color),
                          label: Text(
                            color.value.toRadixString(16).substring(2).toUpperCase(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          onDeleted: () {
                            setState(() => selectedColors.remove(color));
                          },
                        );
                      }).toList(),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar Color'),
                        onPressed: () {
                          _showColorPicker(stateContext, (color) {
                            setState(() => selectedColors.add(color));
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext);
                  
                  // Mostrar loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );
                  
                  // Convertir colores a hex
                  List<String> colorHexCodes = selectedColors
                      .map((c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}')
                      .toList();

                  try {
                    final success = await adminController.updateProduct(
                      productId: product.id,
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      price: double.parse(priceController.text),
                      stock: int.parse(stockController.text),
                      category: selectedCategory!,
                      brand: brandController.text.trim().isEmpty
                          ? null
                          : brandController.text.trim(),
                      sizes: selectedSizes.toList(),
                      colors: colorHexCodes,
                      rating: double.tryParse(ratingController.text) ?? 0.0,
                      isTrending: isTrending,
                      newImageFile: selectedImage,
                      currentImageUrl: product.images.isNotEmpty ? product.images.first : null,
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context); // Cerrar loading
                      
                      if (success) {
                        CustomSnackBar.success(context, 'Producto actualizado exitosamente');
                      } else {
                        CustomSnackBar.error(context, adminController.errorMessage ?? 'Error al actualizar producto');
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      CustomSnackBar.error(context, 'Error crítico: $e');
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
              ),
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteProductDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final adminController = context.read<AdminController>();
              final imageUrl = product.images.isNotEmpty ? product.images.first : null;
              await adminController.deleteProduct(product.id, imageUrl);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Producto eliminado')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
