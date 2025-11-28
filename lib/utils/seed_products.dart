import 'package:cloud_firestore/cloud_firestore.dart';

/// Script para agregar productos de prueba a Firestore
/// Ejecutar una sola vez desde un botón temporal o init
Future<void> seedProducts() async {
  final firestore = FirebaseFirestore.instance;
  final productsRef = firestore.collection('products');

  // Lista de productos de prueba - ropa y calzado deportivo
  final products = [
    {
      'name': 'Nike Air Max 270',
      'description':
          'Zapatillas deportivas con tecnología Air Max para máxima comodidad. Perfectas para correr y uso diario.',
      'price': 450.00,
      'category': 'Calzado Deportivo',
      'images': [
        'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/99486859-0ff3-46b4-949b-2d16af2ad421/custom-nike-air-max-270-shoes-by-you.png',
        'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/awjogtdnqxniqqk0wpgf/custom-nike-air-max-270-shoes-by-you.png',
      ],
      'sizes': ['7', '7.5', '8', '8.5', '9', '9.5', '10'],
      'colors': ['#000000', '#FFFFFF', '#FF5722'],
      'isTrending': true,
      'rating': 4.5,
      'stock': 25,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Adidas Ultraboost 22',
      'description':
          'Tenis de running de alto rendimiento con suela Boost para máxima energía en cada paso.',
      'price': 525.00,
      'category': 'Calzado Deportivo',
      'images': [
        'https://assets.adidas.com/images/h_840,f_auto,q_auto,fl_lossy,c_fill,g_auto/fbaf991a78bc4896a3e9ad7800abcec6_9366/Ultraboost_22_Shoes_Black_GZ0127_01_standard.jpg',
      ],
      'sizes': ['7', '8', '9', '10', '11'],
      'colors': ['#000000', '#808080', '#0000FF'],
      'isTrending': true,
      'rating': 4.8,
      'stock': 18,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Chamarra Deportiva Nike',
      'description':
          'Chamarra ligera resistente al agua, ideal para entrenamientos en exteriores. Con tecnología Dri-FIT.',
      'price': 350.00,
      'category': 'Ropa Deportiva',
      'images': [
        'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/8d2a1c2e-74fb-4f9e-9f50-b3b0c5e5c5e5/sportswear-club-fleece-mens-full-zip-hoodie-RQ74k9.png',
      ],
      'sizes': ['S', 'M', 'L', 'XL'],
      'colors': ['#000000', '#808080', '#0000FF'],
      'isTrending': false,
      'rating': 4.2,
      'stock': 30,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Puma RS-X Bold',
      'description':
          'Sneakers retro con diseño audaz y colores vibrantes. Comodidad y estilo en cada paso.',
      'price': 380.00,
      'category': 'Calzado Deportivo',
      'images': [
        'https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_2000,h_2000/global/393169/01/sv01/fnd/PNA/fmt/png/RS-X-Bold-Sneakers',
      ],
      'sizes': ['7', '8', '9', '10'],
      'colors': ['#FFFFFF', '#FF5722', '#000000'],
      'isTrending': true,
      'rating': 4.3,
      'stock': 22,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Playera Under Armour',
      'description':
          'Playera deportiva de compresión con tecnología HeatGear para mantenerte fresco y seco.',
      'price': 180.00,
      'category': 'Ropa Deportiva',
      'images': [
        'https://underarmour.scene7.com/is/image/Underarmour/V5-1361518-001_FC?rp=standard-0pad|gridCellLarge&scl=1&fmt=jpg&qlt=85&resMode=sharp2&cache=on,on&bgc=F0F0F0&wid=566&hei=708&size=566,708',
      ],
      'sizes': ['S', 'M', 'L', 'XL'],
      'colors': ['#000000', '#FFFFFF', '#FF0000'],
      'isTrending': false,
      'rating': 4.6,
      'stock': 45,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Shorts Nike Dri-FIT',
      'description':
          'Shorts deportivos con tecnología Dri-FIT para entrenamientos intensos. Material transpirable.',
      'price': 150.00,
      'category': 'Ropa Deportiva',
      'images': [
        'https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/e44d7c5a-9a7d-4f9b-9b3d-6b8e9f1c1f1f/dri-fit-challenger-mens-5-brief-lined-running-shorts-5V9Lmv.png',
      ],
      'sizes': ['S', 'M', 'L', 'XL'],
      'colors': ['#000000', '#808080', '#0000FF'],
      'isTrending': false,
      'rating': 4.4,
      'stock': 35,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'New Balance 574 Sport',
      'description':
          'Clásicos sneakers retro con estilo moderno. Comodidad excepcional para uso diario.',
      'price': 320.00,
      'category': 'Calzado Deportivo',
      'images': [
        r'https://nb.scene7.com/is/image/NB/ml574evn_nb_02_i?$dw_detail_main_lg$&bgc=f5f5f5&layer=1&bgcolor=f5f5f5&blendMode=mult&scale=10&wid=1600&hei=1600',
      ],
      'sizes': ['7', '8', '9', '10', '11'],
      'colors': ['#808080', '#0000FF', '#FF5722'],
      'isTrending': true,
      'rating': 4.7,
      'stock': 28,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Sudadera Adidas Essentials',
      'description':
          'Sudadera con capucha de algodón suave. Perfecta para entrenamientos ligeros o uso casual.',
      'price': 280.00,
      'category': 'Ropa Deportiva',
      'images': [
        'https://assets.adidas.com/images/h_840,f_auto,q_auto,fl_lossy,c_fill,g_auto/7ed0855435194229a525aad6009a0497_9366/Essentials_Fleece_3-Stripes_Hoodie_Black_H12111_21_model.jpg',
      ],
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'colors': ['#000000', '#808080', '#0000FF'],
      'isTrending': false,
      'rating': 4.5,
      'stock': 40,
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  print('🌱 Iniciando seed de productos...');

  int count = 0;
  for (final product in products) {
    try {
      await productsRef.add(product);
      count++;
      print('✅ Producto agregado: ${product['name']}');
    } catch (e) {
      print('❌ Error agregando ${product['name']}: $e');
    }
  }

  print('🎉 Seed completado: $count productos agregados de ${products.length}');
}
