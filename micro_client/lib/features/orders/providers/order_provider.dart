import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order.dart';
import '../../../core/services/order_service.dart';

// Orders List Provider
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  return await OrderService.getUserOrders();
});

// Order Detail Provider
final orderDetailProvider =
    FutureProvider.family<Order?, String>((ref, orderId) async {
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
