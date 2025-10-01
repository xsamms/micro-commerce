import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/order.dart';
import '../services/admin_order_service.dart';

// Provider for all orders (admin view)
final adminOrdersProvider = FutureProvider<List<Order>>((ref) async {
  return await AdminOrderService.getAllOrders();
});

// Provider for updating order status
final orderStatusUpdateProvider =
    StateNotifierProvider<OrderStatusUpdateNotifier, AsyncValue<Order?>>((ref) {
  return OrderStatusUpdateNotifier(ref);
});

class OrderStatusUpdateNotifier extends StateNotifier<AsyncValue<Order?>> {
  final Ref _ref;

  OrderStatusUpdateNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    state = const AsyncValue.loading();

    try {
      print('Updating order $orderId status to $newStatus');
      final updatedOrder =
          await AdminOrderService.updateOrderStatus(orderId, newStatus);
      print('Order status update successful: ${updatedOrder.status}');
      state = AsyncValue.data(updatedOrder);

      // Refresh the orders list
      _ref.invalidate(adminOrdersProvider);

      return true;
    } catch (e, stackTrace) {
      print('Order status update failed: $e');
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
