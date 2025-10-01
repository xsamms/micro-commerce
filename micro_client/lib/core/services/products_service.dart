import '../models/product.dart';
import 'api_service.dart';

class PaginatedProductResponse {
  final List<Product> data;
  final ProductPagination pagination;

  PaginatedProductResponse({
    required this.data,
    required this.pagination,
  });

  factory PaginatedProductResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedProductResponse(
      data: (json['data'] as List)
          .map((productJson) => Product.fromJson(productJson))
          .toList(),
      pagination: ProductPagination.fromJson(json['pagination']),
    );
  }
}

class ProductPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  ProductPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory ProductPagination.fromJson(Map<String, dynamic> json) {
    return ProductPagination(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
    );
  }
}

class ProductsService {
  static final _apiService = ApiService.instance;

  static Future<PaginatedProductResponse> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;

    final response =
        await _apiService.get('/products', queryParameters: queryParams);
    return PaginatedProductResponse.fromJson(response.data['data']);
  }

  static Future<Product?> getProductById(String id) async {
    try {
      final response = await _apiService.get('/products/$id');
      return Product.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }
}
