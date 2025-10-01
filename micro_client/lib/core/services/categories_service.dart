import '../models/category.dart';
import 'api_service.dart';

class CategoriesService {
  static final _apiService = ApiService.instance;

  static Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get('/categories');
      final List<dynamic> categoriesJson = response.data['data'];
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  static Future<Category?> getCategoryById(String id) async {
    try {
      final response = await _apiService.get('/categories/$id');
      return Category.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }
}
