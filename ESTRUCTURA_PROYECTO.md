# 📂 Estructura del Proyecto - CarritoApp (MVC)

## 🏗️ Patrón de Arquitectura: MVC (Model-View-Controller)

```
lib/
├── main.dart                              # Punto de entrada de la aplicación
│
├── models/                                # MODEL - Entidades y modelos de datos
│   ├── user_model.dart                   # Usuario (RF01-RF04)
│   ├── product_model.dart                # Producto (RF05-RF07)
│   ├── category_model.dart               # Categoría (RF14)
│   ├── cart_item_model.dart              # Item del carrito (RF08)
│   └── order_model.dart                  # Pedido (RF09-RF12, RF17)
│
├── views/                                 # VIEW - Interfaces de usuario
│   ├── auth/                             # Pantallas de autenticación
│   │   ├── login_view.dart              # Login (RF02)
│   │   ├── register_view.dart           # Registro (RF01)
│   │   └── forgot_password_view.dart    # Recuperar contraseña (RF03)
│   │
│   ├── products/                         # Pantallas de productos
│   │   ├── catalog_view.dart            # Catálogo (RF05)
│   │   ├── product_detail_view.dart     # Detalle producto (RF07)
│   │   └── search_view.dart             # Búsqueda (RF06)
│   │
│   ├── cart/                             # Pantallas del carrito
│   │   └── cart_view.dart               # Carrito de compras (RF08)
│   │
│   ├── orders/                           # Pantallas de pedidos
│   │   ├── checkout_view.dart           # Checkout (RF09)
│   │   ├── payment_view.dart            # Pago PayPal (RF10)
│   │   ├── order_confirmation_view.dart # Confirmación (RF11)
│   │   └── order_history_view.dart      # Historial (RF12)
│   │
│   └── admin/                            # Pantallas de administración
│       ├── admin_dashboard_view.dart    # Dashboard admin (RF04)
│       ├── manage_products_view.dart    # Gestión productos (RF13, RF16)
│       ├── manage_categories_view.dart  # Gestión categorías (RF14)
│       └── manage_orders_view.dart      # Gestión pedidos (RF15)
│
├── controllers/                          # CONTROLLER - Lógica de negocio
│   ├── auth_controller.dart             # Control autenticación (RF01-RF04)
│   ├── products_controller.dart         # Control productos (RF05-RF07)
│   ├── cart_controller.dart             # Control carrito (RF08)
│   ├── orders_controller.dart           # Control pedidos (RF09-RF12, RF17)
│   └── admin_controller.dart            # Control administración (RF13-RF16)
│
├── services/                             # Servicios externos y APIs
│   ├── firebase_auth_service.dart       # Firebase Authentication
│   ├── firestore_service.dart           # Firebase Firestore (BD)
│   ├── storage_service.dart             # Firebase Storage (RF16)
│   └── paypal_service.dart              # PayPal API (RF10)
│
├── widgets/                              # Widgets reutilizables
│   ├── custom_button.dart               # Botón personalizado
│   ├── custom_text_field.dart           # Campo de texto
│   ├── product_card.dart                # Tarjeta de producto
│   ├── cart_item_widget.dart            # Item del carrito
│   ├── loading_indicator.dart           # Indicador de carga
│   ├── error_message.dart               # Mensaje de error
│   └── order_status_badge.dart          # Badge estado pedido (RF17)
│
├── utils/                                # Utilidades y helpers
│   ├── constants.dart                   # Constantes globales
│   ├── validators.dart                  # Validadores de formularios
│   ├── helpers.dart                     # Funciones auxiliares
│   └── app_colors.dart                  # Paleta de colores
│
└── routes/                               # Configuración de rutas
    └── app_routes.dart                  # Rutas de navegación
```

---

## 📋 Mapeo de Requerimientos Funcionales

| RF | Descripción | Archivos Relacionados |
|----|-------------|----------------------|
| RF01 | Registro de usuarios | `user_model.dart`, `auth_controller.dart`, `register_view.dart`, `firebase_auth_service.dart` |
| RF02 | Inicio de sesión | `auth_controller.dart`, `login_view.dart`, `firebase_auth_service.dart` |
| RF03 | Recuperación de contraseña | `auth_controller.dart`, `forgot_password_view.dart`, `firebase_auth_service.dart` |
| RF04 | Gestión de roles | `user_model.dart`, `auth_controller.dart`, `admin_dashboard_view.dart` |
| RF05 | Visualización del catálogo | `product_model.dart`, `products_controller.dart`, `catalog_view.dart`, `firestore_service.dart` |
| RF06 | Buscador de productos | `products_controller.dart`, `search_view.dart` |
| RF07 | Detalle de producto | `product_model.dart`, `products_controller.dart`, `product_detail_view.dart` |
| RF08 | Carrito de compras | `cart_item_model.dart`, `cart_controller.dart`, `cart_view.dart` |
| RF09 | Procesar pedido | `order_model.dart`, `orders_controller.dart`, `checkout_view.dart` |
| RF10 | Integración con PayPal | `orders_controller.dart`, `payment_view.dart`, `paypal_service.dart` |
| RF11 | Confirmación de pedido | `orders_controller.dart`, `order_confirmation_view.dart`, `firestore_service.dart` |
| RF12 | Historial de pedidos | `order_model.dart`, `orders_controller.dart`, `order_history_view.dart` |
| RF13 | Gestión de productos (Admin) | `admin_controller.dart`, `manage_products_view.dart`, `firestore_service.dart` |
| RF14 | Gestión de categorías (Admin) | `category_model.dart`, `admin_controller.dart`, `manage_categories_view.dart` |
| RF15 | Gestión de pedidos (Admin) | `admin_controller.dart`, `manage_orders_view.dart`, `firestore_service.dart` |
| RF16 | Carga de imágenes | `admin_controller.dart`, `manage_products_view.dart`, `storage_service.dart` |
| RF17 | Notificación visual de estados | `order_status_badge.dart`, `orders_controller.dart`, `order_history_view.dart` |

---

## 🔄 Flujo de Datos en MVC

```
┌─────────────┐
│    VIEW     │  ←── El usuario interactúa con la UI
│  (Pantalla) │
└──────┬──────┘
       │ (Evento/Acción)
       ↓
┌─────────────┐
│ CONTROLLER  │  ←── Procesa la lógica de negocio
│  (Gestión)  │      Llama a servicios si es necesario
└──────┬──────┘
       │ (Actualiza datos)
       ↓
┌─────────────┐
│    MODEL    │  ←── Representa los datos
│   (Datos)   │      Notifica cambios al Controller
└──────┬──────┘
       │ (notifyListeners)
       ↓
┌─────────────┐
│    VIEW     │  ←── Se reconstruye con los nuevos datos
│ (Actualiza) │
└─────────────┘
```

---

## 📦 Dependencias Necesarias (agregar a pubspec.yaml)

```yaml
dependencies:
  # State Management
  provider: ^6.1.2
  
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  firebase_storage: ^12.3.8
  
  # PayPal
  flutter_paypal_payment: ^1.0.1
  
  # UI
  cached_network_image: ^3.4.1
  image_picker: ^1.1.2
  
  # Utils
  intl: ^0.20.1
```

---

## 🚀 Próximos Pasos

1. Instalar dependencias: `flutter pub get`
2. Configurar Firebase en el proyecto
3. Implementar los modelos de datos
4. Crear los servicios de Firebase
5. Implementar controllers con Provider
6. Diseñar las vistas/pantallas
7. Conectar todo con rutas de navegación

---

## 📝 Notas Importantes

- **Provider**: Usado para state management (patrón Observer)
- **Controllers**: Extienden `ChangeNotifier` para notificar cambios a las vistas
- **Services**: Encapsulan la lógica de comunicación con APIs externas
- **Models**: Clases puras con métodos `toJson()` y `fromJson()`
- **Widgets**: Componentes reutilizables que simplifican las vistas

---

Última actualización: 25 de octubre de 2025
