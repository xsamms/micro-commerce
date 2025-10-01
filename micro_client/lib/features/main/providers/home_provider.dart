import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category.dart';
import '../../../core/models/product.dart';
import '../../../core/services/categories_service.dart';
import '../../../core/services/products_service.dart';

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return await CategoriesService.getCategories();
});

// Featured products provider (first 4 products)
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  try {
    final response = await ProductsService.getProducts(limit: 4);
    return response.data;
  } catch (e) {
    throw Exception('Failed to load featured products: $e');
  }
});

// Recent products provider
final recentProductsProvider = FutureProvider<List<Product>>((ref) async {
  try {
    final response = await ProductsService.getProducts(limit: 8);
    return response.data;
  } catch (e) {
    throw Exception('Failed to load recent products: $e');
  }
});

// Product by category provider
final productsByCategoryProvider =
    FutureProvider.family<List<Product>, String>((ref, categoryId) async {
  try {
    final response =
        await ProductsService.getProducts(category: categoryId, limit: 10);
    return response.data;
  } catch (e) {
    throw Exception('Failed to load products for category: $e');
  }
});
