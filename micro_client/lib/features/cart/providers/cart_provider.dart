import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/cart.dart';
import '../../../core/services/cart_service.dart';

// Cart provider
final cartProvider = FutureProvider<Cart>((ref) async {
  return await CartService.getCart();
});

// Cart state notifier for real-time updates
class CartNotifier extends StateNotifier<AsyncValue<Cart>> {
  Timer? _debounceTimer;
  final Map<String, int> _pendingUpdates = {};

  CartNotifier() : super(const AsyncValue.loading()) {
    _loadCart();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCart() async {
    try {
      final cart = await CartService.getCart();
      state = AsyncValue.data(cart);
    } catch (error, stackTrace) {
      // Add some debugging information
      print('Cart loading error: $error');

      // Don't retry for network/image related errors
      if (error.toString().contains('SocketException') ||
          error.toString().contains('ClientException') ||
          error.toString().contains('via.placeholder.com')) {
        print('Network/image error detected, not retrying cart load');
        state = AsyncValue.error(error, stackTrace);
        return;
      }

      // If it's a parsing error, try again once after a small delay
      if (error.toString().contains('type cast') ||
          error.toString().contains('Invalid cart data')) {
        print('Retrying cart load due to parsing error...');
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          final cart = await CartService.getCart();
          state = AsyncValue.data(cart);
          return;
        } catch (retryError) {
          print('Retry failed: $retryError');
        }
      }

      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      await CartService.addToCart(productId, quantity);
      // Wait a bit longer for backend to process the change
      await Future.delayed(const Duration(milliseconds: 300));
      await _loadCart(); // Refresh cart to get updated data from server
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }

    // Store the pending update
    _pendingUpdates[itemId] = quantity;

    // Optimistic update
    final currentState = state;
    if (currentState.hasValue) {
      final currentCart = currentState.value!;
      final updatedItems = currentCart.items.map((item) {
        if (item.id == itemId) {
          return CartItem(
            id: item.id,
            cartId: item.cartId,
            productId: item.productId,
            product: item.product,
            quantity: quantity,
            createdAt: item.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return item;
      }).toList();

      final updatedCart = Cart(
        id: currentCart.id,
        userId: currentCart.userId,
        items: updatedItems,
        total: updatedItems.fold<double>(
            0.0, (sum, item) => sum + (item.product.price * item.quantity)),
        createdAt: currentCart.createdAt,
        updatedAt: DateTime.now(),
      );

      state = AsyncValue.data(updatedCart);
    }

    // Debounce the API call
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final finalQuantity = _pendingUpdates[itemId];
      if (finalQuantity != null) {
        _pendingUpdates.remove(itemId);

        try {
          await CartService.updateCartItem(itemId, finalQuantity);
          // Reload cart to ensure consistency with server
          await _loadCart();
        } catch (error) {
          // Revert optimistic update on error
          if (currentState.hasValue) {
            state = currentState;
          }
          print('Failed to update cart item: $error');
          // Optionally show a snackbar or toast here
        }
      }
    });
  }

  Future<void> removeItem(String itemId) async {
    // Optimistic update
    final currentState = state;
    if (currentState.hasValue) {
      final currentCart = currentState.value!;
      final updatedItems =
          currentCart.items.where((item) => item.id != itemId).toList();

      final updatedCart = Cart(
        id: currentCart.id,
        userId: currentCart.userId,
        items: updatedItems,
        total: updatedItems.fold<double>(
            0.0, (sum, item) => sum + (item.product.price * item.quantity)),
        createdAt: currentCart.createdAt,
        updatedAt: DateTime.now(),
      );

      state = AsyncValue.data(updatedCart);
    }

    try {
      await CartService.removeFromCart(itemId);
      // Reload cart to ensure consistency with server
      await _loadCart();
    } catch (error) {
      // Revert optimistic update on error
      if (currentState.hasValue) {
        state = currentState;
      }
      print('Failed to remove cart item: $error');
      // Optionally show a snackbar or toast here
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
