import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static final ApiService _apiService = ApiService.instance;

  static Future<Order> createOrder() async {
    try {
      final response = await _apiService.post('/orders');

      final orderData = response.data['data'];
      final orderId = orderData['id'] as String;

      // After creating the order, fetch the complete order with items
      final completeOrder = await getOrderById(orderId);

      if (completeOrder == null) {
        throw Exception('Failed to retrieve created order');
      }

      return completeOrder;
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  static Future<List<Order>> getUserOrders() async {
    try {
      final response = await _apiService.get('/orders');

      final ordersData = response.data['data'] as List;
      return ordersData
          .map((orderData) => Order.fromJson(_convertOrderData(orderData)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders: ${e.toString()}');
    }
  }

  static Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId');

      if (response.statusCode == 404) {
        return null;
      }

      final orderData = response.data['data'];
      return Order.fromJson(_convertOrderData(orderData));
    } catch (e) {
      throw Exception('Failed to load order: ${e.toString()}');
    }
  }

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
