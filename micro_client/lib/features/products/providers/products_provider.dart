import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/products_service.dart';

final productsServiceProvider = Provider<ProductsService>((ref) {
  return ProductsService();
});
