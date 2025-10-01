import '../../../core/models/order.dart';
import '../../../core/services/api_service.dart';

class AdminOrderService {
  static final ApiService _apiService = ApiService.instance;

  /// Get all orders for admin
  static Future<List<Order>> getAllOrders() async {
    try {
      final response = await _apiService.get('/orders/admin/all');

      final ordersData = response.data['data'] as List;
      return ordersData
          .map((orderData) => Order.fromJson(_convertOrderData(orderData)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load all orders: ${e.toString()}');
    }
  }

  /// Update order status (admin only)
  static Future<Order> updateOrderStatus(
      String orderId, OrderStatus status) async {
    try {
      // Update the order status
      await _apiService.put(
        '/orders/$orderId/status',
        data: {
          'status': status.name.toUpperCase(),
        },
      );

      // Fetch the complete order with all relationships
      final response = await _apiService.get('/orders/$orderId');
      final orderData = response.data['data'];
      return Order.fromJson(_convertOrderData(orderData));
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  /// Convert order data from API response to ensure proper typing
  static Map<String, dynamic> _convertOrderData(
      Map<String, dynamic> orderData) {
    // Convert string prices to double
    final convertedData = Map<String, dynamic>.from(orderData);

    // Convert total from string to double
    if (convertedData['total'] is String) {
      convertedData['total'] = double.parse(convertedData['total']);
    }

    // Convert order items
    if (convertedData['items'] != null) {
      final items = convertedData['items'] as List;
      convertedData['items'] = items.map((item) {
        final convertedItem = Map<String, dynamic>.from(item);

        // Convert price from string to double
        if (convertedItem['price'] is String) {
          convertedItem['price'] = double.parse(convertedItem['price']);
        }

        // Convert product price if present
        if (convertedItem['product'] != null) {
          final product = Map<String, dynamic>.from(convertedItem['product']);
          if (product['price'] is String) {
            product['price'] = double.parse(product['price']);
          }
          convertedItem['product'] = product;
        }

        return convertedItem;
      }).toList();
    }

    return convertedData;
  }
}
