import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/models/api_response.dart';
import '../../../core/models/user.dart';
import '../../../core/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Register new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final authResponse = AuthResponse.fromJson(apiResponse.data!);

        // Store token securely
        await _storage.write(key: 'auth_token', value: authResponse.token);
        await _storage.write(key: 'user_id', value: authResponse.user.id);

        return authResponse;
      } else {
        throw Exception(apiResponse.message ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          e.response!.data,
          (data) => data as Map<String, dynamic>,
        );
        throw Exception(errorResponse.message ?? 'Registration failed');
      } else {
        throw Exception('Network error: Please check your connection');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final authResponse = AuthResponse.fromJson(apiResponse.data!);

        // Store token securely
        await _storage.write(key: 'auth_token', value: authResponse.token);
        await _storage.write(key: 'user_id', value: authResponse.user.id);

        return authResponse;
      } else {
        throw Exception(apiResponse.message ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          e.response!.data,
          (data) => data as Map<String, dynamic>,
        );
        throw Exception(errorResponse.message ?? 'Login failed');
      } else {
        throw Exception('Network error: Please check your connection');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Get user profile
  Future<User> getProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.profile);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return User.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to load profile');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          e.response!.data,
          (data) => data as Map<String, dynamic>,
        );
        throw Exception(errorResponse.message ?? 'Failed to load profile');
      } else {
        throw Exception('Network error: Please check your connection');
      }
    } catch (e) {
      throw Exception('Failed to load profile: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_id');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  // Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Get stored user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }
}
