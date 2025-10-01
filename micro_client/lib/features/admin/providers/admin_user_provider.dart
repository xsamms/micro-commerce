import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user.dart';
import '../services/admin_user_service.dart';

// Provider for all users (admin view)
final adminUsersProvider = FutureProvider<List<User>>((ref) async {
  return await AdminUserService.getAllUsers();
});

// Provider for getting a user by ID
final adminUserDetailProvider =
    FutureProvider.family<User?, String>((ref, userId) async {
  return await AdminUserService.getUserById(userId);
});

// Provider for updating user information
final userUpdateProvider =
    StateNotifierProvider<UserUpdateNotifier, AsyncValue<User?>>((ref) {
  return UserUpdateNotifier(ref);
});

// Provider for updating user role
final userRoleUpdateProvider =
    StateNotifierProvider<UserRoleUpdateNotifier, AsyncValue<User?>>((ref) {
  return UserRoleUpdateNotifier(ref);
});

// Provider for deleting user
final userDeleteProvider =
    StateNotifierProvider<UserDeleteNotifier, AsyncValue<void>>((ref) {
  return UserDeleteNotifier(ref);
});

class UserUpdateNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;

  UserUpdateNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> updateUser(
      String userId, Map<String, dynamic> updateData) async {
    state = const AsyncValue.loading();

    try {
      print('Updating user $userId with data: $updateData');
      final updatedUser = await AdminUserService.updateUser(userId, updateData);
      print('User update successful: ${updatedUser.email}');
      state = AsyncValue.data(updatedUser);

      // Refresh the users list
      _ref.invalidate(adminUsersProvider);

      return true;
    } catch (e, stackTrace) {
      print('User update failed: $e');
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

class UserRoleUpdateNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;

  UserRoleUpdateNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> updateUserRole(String userId, Role newRole) async {
    state = const AsyncValue.loading();

    try {
      print('Updating user $userId role to $newRole');
      final updatedUser =
          await AdminUserService.updateUserRole(userId, newRole);
      print('User role update successful: ${updatedUser.role}');
      state = AsyncValue.data(updatedUser);

      // Refresh the users list
      _ref.invalidate(adminUsersProvider);

      return true;
    } catch (e, stackTrace) {
      print('User role update failed: $e');
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

class UserDeleteNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  UserDeleteNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> deleteUser(String userId) async {
    state = const AsyncValue.loading();

    try {
      print('Deleting user $userId');
      await AdminUserService.deleteUser(userId);
      print('User deletion successful');
      state = const AsyncValue.data(null);

      // Refresh the users list
      _ref.invalidate(adminUsersProvider);

      return true;
    } catch (e, stackTrace) {
      print('User deletion failed: $e');
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
