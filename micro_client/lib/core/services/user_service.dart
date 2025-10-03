import '../models/user.dart';
import 'api_service.dart';

class UserService {
  static final ApiService _apiService = ApiService.instance;

  /// Update current user's profile
  static Future<User> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (firstName != null && firstName.isNotEmpty) {
        updateData['firstName'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        updateData['lastName'] = lastName;
      }

      // Get current user ID from auth provider or use 'me' endpoint
      final response =
          await _apiService.patch('/auth/profile', data: updateData);

      if (response.data['success'] == true) {
        final userData = response.data['data'];
        return User.fromJson(userData);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        throw Exception('Please log in to update your profile');
      }
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  /// Get current user's profile
  static Future<User> getProfile() async {
    try {
      final response = await _apiService.get('/auth/profile');

      if (response.data['success'] == true) {
        final userData = response.data['data'];
        return User.fromJson(userData);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        throw Exception('Please log in to view your profile');
      }
      throw Exception('Failed to load profile: ${e.toString()}');
    }
  }
}
