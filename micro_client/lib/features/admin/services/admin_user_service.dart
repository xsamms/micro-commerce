import '../../../core/models/user.dart';
import '../../../core/services/api_service.dart';

class AdminUserService {
  static final ApiService _apiService = ApiService.instance;

  /// Get all users for admin
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await _apiService.get('/users');

      final usersData = response.data['data'] as List;
      return usersData.map((userData) => User.fromJson(userData)).toList();
    } catch (e) {
      throw Exception('Failed to load users: ${e.toString()}');
    }
  }

  /// Get user by ID
  static Future<User?> getUserById(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId');

      if (response.statusCode == 404) {
        return null;
      }

      final userData = response.data['data'];
      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to load user: ${e.toString()}');
    }
  }

  /// Update user information
  static Future<User> updateUser(
      String userId, Map<String, dynamic> updateData) async {
    try {
      final response =
          await _apiService.put('/users/$userId', data: updateData);

      final userData = response.data['data'];
      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  /// Delete user
  static Future<void> deleteUser(String userId) async {
    try {
      await _apiService.delete('/users/$userId');
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  /// Update user role (admin only)
  static Future<User> updateUserRole(String userId, Role role) async {
    try {
      final response = await _apiService.patch(
        '/users/$userId/role',
        data: {
          'role': role.name.toUpperCase(),
        },
      );

      final userData = response.data['data'];
      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to update user role: ${e.toString()}');
    }
  }
}
