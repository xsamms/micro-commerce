import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category.dart';
import '../../../core/services/categories_service.dart';
import '../../../core/services/products_service.dart';

// Products filter state
class ProductsFilterState {
  final int page;
  final int limit;
  final String? categoryId;
  final String? search;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;

  const ProductsFilterState({
    this.page = 1,
    this.limit = 12,
    this.categoryId,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'createdAt',
  });

  ProductsFilterState copyWith({
    int? page,
    int? limit,
    String? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) {
    return ProductsFilterState(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      categoryId: categoryId ?? this.categoryId,
      search: search ?? this.search,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

// Products filter state provider
final productsFilterProvider =
    StateNotifierProvider<ProductsFilterNotifier, ProductsFilterState>((ref) {
  return ProductsFilterNotifier();
});

class ProductsFilterNotifier extends StateNotifier<ProductsFilterState> {
  ProductsFilterNotifier() : super(const ProductsFilterState());

  void updateFilter({
    int? page,
    String? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) {
    state = state.copyWith(
      page: page ?? 1, // Reset to page 1 when filters change
      categoryId: categoryId,
      search: search,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
    );
  }

  void nextPage() {
    state = state.copyWith(page: state.page + 1);
  }

  void resetFilters() {
    state = const ProductsFilterState();
  }
}

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return await CategoriesService.getCategories();
});

// Products provider with filters
final productsProvider = FutureProvider<PaginatedProductResponse>((ref) async {
  final filter = ref.watch(productsFilterProvider);

  return await ProductsService.getProducts(
    page: filter.page,
    limit: filter.limit,
    category: filter.categoryId,
    search: filter.search,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
  );
});

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');
