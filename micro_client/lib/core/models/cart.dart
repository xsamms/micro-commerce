import 'package:freezed_annotation/freezed_annotation.dart';

import 'product.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

@freezed
class Cart with _$Cart {
  const factory Cart({
    required String id,
    required String userId,
    required List<CartItem> items,
    required DateTime createdAt,
    required DateTime updatedAt,
    double? total,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
}

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    required String cartId,
    required String productId,
    required int quantity,
    required Product product,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}
