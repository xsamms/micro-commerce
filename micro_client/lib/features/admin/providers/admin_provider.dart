import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category.dart';
import '../../../core/models/product.dart';
import '../services/admin_service.dart';

// Categories provider (gets all categories from backend)
final adminCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  return await AdminService.getCategories();
});

// Simple category model for dropdown (for backward compatibility)
class SimpleCategory {
  final String id;
  final String name;

  SimpleCategory({required this.id, required this.name});
}

// Get categories from existing products for dropdown
final categoriesProvider = FutureProvider<List<SimpleCategory>>((ref) async {
  final categories = await AdminService.getCategories();
  return categories
      .map((category) => SimpleCategory(id: category.id, name: category.name))
      .toList();
});

// Products provider for admin (includes all products) - using AdminService
final adminProductsProvider = FutureProvider<List<Product>>((ref) async {
  return await AdminService.getAllProducts();
});

// Provider for refreshing data
final refreshProvider = StateProvider<int>((ref) => 0);

// Category management methods
class AdminCategoryManager {
  final Ref ref;

  AdminCategoryManager(this.ref);

  Future<Category> createCategory({
    required String name,
    String? description,
  }) async {
    final category = await AdminService.createCategory(
      name: name,
      description: description,
    );

    // Refresh categories list
    ref.invalidate(adminCategoriesProvider);
    ref.invalidate(categoriesProvider);

    return category;
  }

  Future<Category> updateCategory({
    required String id,
    String? name,
    String? description,
  }) async {
    final category = await AdminService.updateCategory(
      id: id,
      name: name,
      description: description,
    );

    // Refresh categories list
    ref.invalidate(adminCategoriesProvider);
    ref.invalidate(categoriesProvider);

    return category;
  }

  Future<void> deleteCategory(String id) async {
    await AdminService.deleteCategory(id);

    // Refresh categories list
    ref.invalidate(adminCategoriesProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(adminProductsProvider); // Categories affect products
  }
}

// Product management methods
class AdminProductManager {
  final Ref ref;

  AdminProductManager(this.ref);

  Future<Product> createProduct({
    required String name,
    String? description,
    required double price,
    required int stock,
    required String categoryId,
    String? imageUrl,
  }) async {
    final product = await AdminService.createProduct(
      name: name,
      description: description,
      price: price,
      stock: stock,
      categoryId: categoryId,
      imageUrl: imageUrl,
    );

    // Refresh products list
    ref.invalidate(adminProductsProvider);

    return product;
  }

  Future<Product> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? categoryId,
    String? imageUrl,
  }) async {
    final product = await AdminService.updateProduct(
      id: id,
      name: name,
      description: description,
      price: price,
      stock: stock,
      categoryId: categoryId,
      imageUrl: imageUrl,
    );

    // Refresh products list
    ref.invalidate(adminProductsProvider);

    return product;
  }

  Future<void> deleteProduct(String id) async {
    await AdminService.deleteProduct(id);

    // Refresh products list
    ref.invalidate(adminProductsProvider);
  }
}

// Providers for the managers
final adminCategoryManagerProvider = Provider<AdminCategoryManager>((ref) {
  return AdminCategoryManager(ref);
});

final adminProductManagerProvider = Provider<AdminProductManager>((ref) {
  return AdminProductManager(ref);
});
