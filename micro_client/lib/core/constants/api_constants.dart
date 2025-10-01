class ApiConstants {
  //ifconfig | grep "inet " | grep -v 127.0.0.1
  static const String baseUrl = 'http://172.20.10.5:4500/api';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';

  // Product endpoints
  static const String products = '/products';

  // Cart endpoints
  static const String cart = '/cart';

  // Order endpoints
  static const String orders = '/orders';

  // Admin endpoints
  static const String adminOrders = '/orders/admin/all';

  // Request timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
