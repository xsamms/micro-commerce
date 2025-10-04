import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order.dart';
import '../../../core/services/order_service.dart';
import '../../auth/providers/auth_provider.dart';

// Orders List Provider
final ordersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  // Depend on auth state so orders reload/clear when user changes or logs out
  final authState = ref.watch(authProvider);

  if (!authState.isAuthenticated) {
    // Throw to show auth prompt UI and clear any cached orders from previous user
    throw Exception('Please log in');
  }

  return await OrderService.getUserOrders();
});

// Order Detail Provider
final orderDetailProvider =
    FutureProvider.autoDispose.family<Order?, String>((ref, orderId) async {
  // Also tie detail fetch to auth state to avoid leaking previous session data
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) {
    throw Exception('Please log in');
  }
  return await OrderService.getOrderById(orderId);
});

// Order Creation Provider
final orderCreationProvider =
    StateNotifierProvider<OrderCreationNotifier, AsyncValue<Order?>>((ref) {
  return OrderCreationNotifier();
});

class OrderCreationNotifier extends StateNotifier<AsyncValue<Order?>> {
  OrderCreationNotifier() : super(const AsyncValue.data(null));

  Future<Order?> createOrder() async {
    state = const AsyncValue.loading();

    try {
      final order = await OrderService.createOrder();
      state = AsyncValue.data(order);
      return order;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
