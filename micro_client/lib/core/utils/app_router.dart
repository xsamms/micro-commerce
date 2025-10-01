import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/main/screens/main_tab_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/orders/screens/order_list_screen.dart';
import '../../features/products/screens/product_detail_screen.dart';
import '../../features/products/screens/product_list_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String admin = '/admin';

  static GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const MainTabScreen(),
      ),
      GoRoute(
        path: products,
        name: 'products',
        builder: (context, state) {
          final categoryId = state.uri.queryParameters['categoryId'];
          return ProductListScreen(categoryId: categoryId);
        },
      ),
      GoRoute(
        path: productDetail,
        name: 'product-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: cart,
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: orders,
        name: 'orders',
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: orderDetail,
        name: 'order-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: admin,
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}
