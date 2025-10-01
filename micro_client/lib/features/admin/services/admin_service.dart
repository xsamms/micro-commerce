import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/models/category.dart';
import '../../../core/models/product.dart';
import '../../../core/services/api_service.dart';

class AdminService {
  static final _apiService = ApiService.instance;

  // Category Management
  static Future<List<Category>> getCategories() async {
    final response = await _apiService.get('/categories');
    final List<dynamic> categoriesJson = response.data['data'];
    return categoriesJson.map((json) => Category.fromJson(json)).toList();
  }

  static Future<Category> createCategory({
    required String name,
    String? description,
  }) async {
    final response = await _apiService.post('/categories', data: {
      'name': name,
      'description': description,
    });

    return Category.fromJson(response.data['data']);
  }

  static Future<Category> updateCategory({
    required String id,
    String? name,
    String? description,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;

    final response = await _apiService.put('/categories/$id', data: data);
    return Category.fromJson(response.data['data']);
  }

  static Future<void> deleteCategory(String id) async {
    await _apiService.delete('/categories/$id');
  }

  // Product Management
  static Future<List<Product>> getAllProducts() async {
    try {
      print('AdminService: Fetching all products...');
      final response = await _apiService.get('/products?page=1&limit=100');
      print('AdminService: Response received: ${response.statusCode}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> productsJson = data['data'];
        print('AdminService: Found ${productsJson.length} products');

        // Convert string prices/stocks to numbers before parsing
        final List<Map<String, dynamic>> processedProducts =
            productsJson.map((json) {
          final Map<String, dynamic> product = Map<String, dynamic>.from(json);

          // Convert price from string to double if it's a string
          if (product['price'] is String) {
            product['price'] = double.parse(product['price']);
          }

          // Convert stock from string to int if it's a string
          if (product['stock'] is String) {
            product['stock'] = int.parse(product['stock']);
          }

          return product;
        }).toList();

        return processedProducts.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      print('AdminService: Error getting all products: $e');
      rethrow;
    }
  }

  static Future<Product> createProduct({
    required String name,
    String? description,
    required double price,
    required int stock,
    required String categoryId,
    String? imageUrl,
  }) async {
    try {
      print('AdminService: Creating product...');
      final data = <String, dynamic>{
        'name': name,
        'price': price,
        'stock': stock,
        'categoryId': categoryId,
      };

      // Only add optional fields if they have values
      if (description != null && description.isNotEmpty) {
        data['description'] = description;
      }
      if (imageUrl != null && imageUrl.isNotEmpty) {
        data['imageUrl'] = imageUrl;
      }

      print('AdminService: Sending data: $data');
      final response = await _apiService.post('/products', data: data);
      print('AdminService: Create product response: ${response.statusCode}');
      print('AdminService: Response data: ${response.data}');

      if (response.data['success'] == true) {
        final productData = response.data['data'];
        print('AdminService: Product data: $productData');

        // Handle potential type conversion issues
        final processedProduct = Map<String, dynamic>.from(productData);

        // Convert price from string to double if it's a string
        if (processedProduct['price'] is String) {
          processedProduct['price'] = double.parse(processedProduct['price']);
        }

        // Convert stock from string to int if it's a string
        if (processedProduct['stock'] is String) {
          processedProduct['stock'] = int.parse(processedProduct['stock']);
        }

        print('AdminService: Processed product data: $processedProduct');
        return Product.fromJson(processedProduct);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      print('AdminService: Error creating product: $e');
      rethrow;
    }
  }

  static Future<Product> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? categoryId,
    String? imageUrl,
  }) async {
    try {
      print('AdminService: Updating product $id...');
      final data = <String, dynamic>{};

      // Only add fields that have values
      if (name != null && name.isNotEmpty) data['name'] = name;
      if (description != null && description.isNotEmpty)
        data['description'] = description;
      if (price != null) data['price'] = price;
      if (stock != null) data['stock'] = stock;
      if (categoryId != null && categoryId.isNotEmpty)
        data['categoryId'] = categoryId;
      if (imageUrl != null && imageUrl.isNotEmpty) data['imageUrl'] = imageUrl;

      print('AdminService: Sending update data: $data');
      final response = await _apiService.put('/products/$id', data: data);
      print('AdminService: Update product response: ${response.statusCode}');
      print('AdminService: Response data: ${response.data}');

      if (response.data['success'] == true) {
        final productData = response.data['data'];
        print('AdminService: Product data: $productData');

        // Handle potential type conversion issues
        final processedProduct = Map<String, dynamic>.from(productData);

        // Convert price from string to double if it's a string
        if (processedProduct['price'] is String) {
          processedProduct['price'] = double.parse(processedProduct['price']);
        }

        // Convert stock from string to int if it's a string
        if (processedProduct['stock'] is String) {
          processedProduct['stock'] = int.parse(processedProduct['stock']);
        }

        print('AdminService: Processed product data: $processedProduct');
        return Product.fromJson(processedProduct);
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      print('AdminService: Error updating product: $e');
      rethrow;
    }
  }

  static Future<void> deleteProduct(String id) async {
    await _apiService.delete('/products/$id');
  }

  // Image Upload
  static Future<String> uploadProductImage(File imageFile) async {
    try {
      print('AdminService: Uploading image...');

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _apiService.post(
        '/upload/product-image',
        data: formData,
      );

      if (response.data['success'] == true) {
        final imageUrl = response.data['data']['imageUrl'] as String;
        print('AdminService: Image uploaded successfully');
        return imageUrl;
      } else {
        throw Exception('Image upload failed: ${response.data}');
      }
    } catch (e) {
      print('AdminService: Error uploading image: $e');
      rethrow;
    }
  }
}
