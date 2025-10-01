import '../models/cart.dart';
import 'api_service.dart';

class CartService {
  static final _apiService = ApiService.instance;

  // Helper method to convert price from string to double
  static Map<String, dynamic> _convertProductPrice(
      Map<String, dynamic> productData) {
    final convertedData = Map<String, dynamic>.from(productData);
    final price = convertedData['price'];
    if (price is String) {
      convertedData['price'] = double.tryParse(price) ?? 0.0;
    } else if (price is num) {
      convertedData['price'] = price.toDouble();
    }
    return convertedData;
  }

  // Helper method to convert cart item with product price
  static Map<String, dynamic> _convertCartItemPrice(
      Map<String, dynamic> itemData) {
    final convertedData = Map<String, dynamic>.from(itemData);
    if (convertedData['product'] != null) {
      convertedData['product'] = _convertProductPrice(convertedData['product']);
    }
    return convertedData;
  }

  static Future<Cart> getCart() async {
    try {
      final response = await _apiService.get('/cart');

      // Check if response.data is null or doesn't have the expected structure
      if (response.data == null) {
        throw Exception('No cart data received');
      }

      // Check if the API response has the expected structure
      final data = response.data['data'];
      if (data == null) {
        throw Exception('Cart data is null - user may not be logged in');
      }

      // Convert product prices from string to double before parsing
      final cartData = Map<String, dynamic>.from(data);
      if (cartData['items'] != null) {
        cartData['items'] = (cartData['items'] as List)
            .map((item) => _convertCartItemPrice(item))
            .toList();
      }

      return Cart.fromJson(cartData);
    } catch (e) {
      // Re-throw with more context
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        throw Exception('Please log in to view your cart');
      }
      rethrow;
    }
  }

  static Future<CartItem> addToCart(String productId, int quantity) async {
    try {
      final response = await _apiService.post('/cart', data: {
        'productId': productId,
        'quantity': quantity,
      });

      if (response.data == null || response.data['data'] == null) {
        throw Exception('Failed to add item to cart');
      }

      // Convert product price from string to double before parsing
      final itemData = _convertCartItemPrice(response.data['data']);
      return CartItem.fromJson(itemData);
    } catch (e) {
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        throw Exception('Please log in to add items to cart');
      }
      rethrow;
    }
  }

  static Future<CartItem> updateCartItem(String itemId, int quantity) async {
    try {
      final response = await _apiService.put('/cart/$itemId', data: {
        'quantity': quantity,
      });

      if (response.data == null || response.data['data'] == null) {
        throw Exception('Failed to update cart item');
      }

      // Convert product price from string to double before parsing
      final itemData = _convertCartItemPrice(response.data['data']);
      return CartItem.fromJson(itemData);
    } catch (e) {
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        throw Exception('Please log in to update cart');
      }
      rethrow;
    }
  }

  static Future<void> removeFromCart(String itemId) async {
    try {
      await _apiService.delete('/cart/$itemId');
    } catch (e) {
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        throw Exception('Please log in to modify cart');
      }
      rethrow;
    }
  }

  static Future<void> clearCart() async {
    try {
      await _apiService.delete('/cart');
    } catch (e) {
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        throw Exception('Please log in to clear cart');
      }
      rethrow;
    }
  }
}
