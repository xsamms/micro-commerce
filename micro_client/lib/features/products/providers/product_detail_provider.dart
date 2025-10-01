import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/product.dart';
import '../../../core/services/products_service.dart';

// Product detail provider
final productDetailProvider =
    FutureProvider.family<Product, String>((ref, productId) async {
  final product = await ProductsService.getProductById(productId);
  if (product == null) {
    throw Exception('Product not found');
  }
  return product;
});
