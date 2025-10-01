import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/cart.dart';
import '../../../core/services/cart_service.dart';

// Cart provider
final cartProvider = FutureProvider<Cart>((ref) async {
  return await CartService.getCart();
});

// Cart state notifier for real-time updates
class CartNotifier extends StateNotifier<AsyncValue<Cart>> {
  CartNotifier() : super(const AsyncValue.loading()) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final cart = await CartService.getCart();
      state = AsyncValue.data(cart);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      await CartService.addToCart(productId, quantity);
      await _loadCart(); // Refresh cart
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }

    try {
      await CartService.updateCartItem(itemId, quantity);
      await _loadCart(); // Refresh cart
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      await CartService.removeFromCart(itemId);
      await _loadCart(); // Refresh cart
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearCart() async {
    try {
      await CartService.clearCart();
      await _loadCart(); // Refresh cart
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadCart();
  }
}

// Cart notifier provider
final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<Cart>>((ref) {
  return CartNotifier();
});

// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cartAsync = ref.watch(cartNotifierProvider);
  return cartAsync.when(
    data: (cart) => cart.items.fold(0, (sum, item) => sum + item.quantity),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Cart total provider
final cartTotalProvider = Provider<double>((ref) {
  final cartAsync = ref.watch(cartNotifierProvider);
  return cartAsync.when(
    data: (cart) =>
        cart.total ??
        cart.items.fold(
            0.0, (sum, item) => sum + (item.product.price * item.quantity)),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
