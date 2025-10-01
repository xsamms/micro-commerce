import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/user.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/admin_user_provider.dart';

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState
    extends ConsumerState<AdminUserManagementScreen> {
  Role? _selectedRoleFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(adminUsersProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: usersAsync.when(
              data: (users) => _buildUsersList(users),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildError(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 12),
          // Role Filter
          Row(
            children: [
              const Text(
                'Filter by role:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    _buildRoleFilterChip(null, 'All'),
                    const SizedBox(width: 8),
                    _buildRoleFilterChip(Role.user, 'Users'),
                    const SizedBox(width: 8),
                    _buildRoleFilterChip(Role.admin, 'Admins'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip(Role? role, String label) {
    final isSelected = _selectedRoleFilter == role;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRoleFilter = selected ? role : null;
        });
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildUsersList(List<User> users) {
    // Apply filters
    var filteredUsers = users.where((user) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = user.email.toLowerCase().contains(_searchQuery) ||
            (user.firstName?.toLowerCase().contains(_searchQuery) ?? false) ||
            (user.lastName?.toLowerCase().contains(_searchQuery) ?? false);
        if (!matchesSearch) return false;
      }

      // Role filter
      if (_selectedRoleFilter != null && user.role != _selectedRoleFilter) {
        return false;
      }

      return true;
    }).toList();

    // Sort by creation date (newest first)
    filteredUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (filteredUsers.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminUsersProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          return _buildUserCard(filteredUsers[index]);
        },
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: user.role == Role.admin
                      ? AppTheme.primaryColor.withValues(alpha: 0.2)
                      : AppTheme.secondaryColor.withValues(alpha: 0.2),
                  child: Icon(
                    user.role == Role.admin
                        ? Icons.admin_panel_settings
                        : Icons.person,
                    color: user.role == Role.admin
                        ? AppTheme.primaryColor
                        : AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${user.firstName ?? ''} ${user.lastName ?? ''}'
                                      .trim()
                                      .isEmpty
                                  ? 'No Name'
                                  : '${user.firstName ?? ''} ${user.lastName ?? ''}'
                                      .trim(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                          _buildRoleChip(user.role),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Joined ${DateFormat('MMM dd, yyyy').format(user.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showUserEditDialog(user),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showRoleUpdateDialog(user),
                  icon: const Icon(Icons.security, size: 16),
                  label: const Text('Role'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.secondaryColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                if (user.role != Role.admin) // Don't allow deleting admin users
                  TextButton.icon(
                    onPressed: () => _showDeleteConfirmDialog(user),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(Role role) {
    final isAdmin = role == Role.admin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.purple.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'User',
        style: TextStyle(
          color: isAdmin ? Colors.purple.shade700 : Colors.blue.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showUserEditDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => _UserEditDialog(user: user),
    );
  }

  void _showRoleUpdateDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => _UserRoleDialog(user: user),
    );
  }

  void _showDeleteConfirmDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => _UserDeleteDialog(user: user),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 64,
              color: AppTheme.textTertiaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'No Users Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No users match your current filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(adminUsersProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// User Edit Dialog
class _UserEditDialog extends ConsumerStatefulWidget {
  final User user;

  const _UserEditDialog({required this.user});

  @override
  ConsumerState<_UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends ConsumerState<_UserEditDialog> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.user.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.user.lastName ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(userUpdateProvider);

    return AlertDialog(
      title: const Text('Edit User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(),
            ),
            enabled: !updateState.isLoading,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              border: OutlineInputBorder(),
            ),
            enabled: !updateState.isLoading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              updateState.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: updateState.isLoading ? null : _updateUser,
          child: updateState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateUser() async {
    final updateData = {
      'firstName': _firstNameController.text.trim().isEmpty
          ? null
          : _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
    };

    final success = await ref
        .read(userUpdateProvider.notifier)
        .updateUser(widget.user.id, updateData);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      final errorState = ref.read(userUpdateProvider);
      final errorMessage = errorState.hasError
          ? errorState.error.toString()
          : 'Failed to update user';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

// User Role Dialog
class _UserRoleDialog extends ConsumerStatefulWidget {
  final User user;

  const _UserRoleDialog({required this.user});

  @override
  ConsumerState<_UserRoleDialog> createState() => _UserRoleDialogState();
}

class _UserRoleDialogState extends ConsumerState<_UserRoleDialog> {
  Role? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(userRoleUpdateProvider);

    return AlertDialog(
      title: const Text('Update User Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User: ${widget.user.email}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Select role:'),
          const SizedBox(height: 8),
          RadioListTile<Role>(
            title: const Text('User'),
            subtitle: const Text('Regular user with standard permissions'),
            value: Role.user,
            groupValue: _selectedRole,
            onChanged: updateState.isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<Role>(
            title: const Text('Admin'),
            subtitle: const Text('Administrator with full system access'),
            value: Role.admin,
            groupValue: _selectedRole,
            onChanged: updateState.isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              updateState.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: updateState.isLoading || _selectedRole == widget.user.role
              ? null
              : _updateRole,
          child: updateState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateRole() async {
    if (_selectedRole == null) return;

    final success = await ref
        .read(userRoleUpdateProvider.notifier)
        .updateUserRole(widget.user.id, _selectedRole!);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'User role updated to ${_selectedRole == Role.admin ? 'Admin' : 'User'}'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      final errorState = ref.read(userRoleUpdateProvider);
      final errorMessage = errorState.hasError
          ? errorState.error.toString()
          : 'Failed to update user role';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

// User Delete Dialog
class _UserDeleteDialog extends ConsumerWidget {
  final User user;

  const _UserDeleteDialog({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deleteState = ref.watch(userDeleteProvider);

    return AlertDialog(
      title: const Text('Delete User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning,
            color: AppTheme.errorColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Are you sure you want to delete this user?',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'This action cannot be undone.',
            style: TextStyle(
              color: AppTheme.errorColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              deleteState.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              deleteState.isLoading ? null : () => _deleteUser(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
          ),
          child: deleteState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _deleteUser(BuildContext context, WidgetRef ref) async {
    final success =
        await ref.read(userDeleteProvider.notifier).deleteUser(user.id);

    if (success && context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (context.mounted) {
      final errorState = ref.read(userDeleteProvider);
      final errorMessage = errorState.hasError
          ? errorState.error.toString()
          : 'Failed to delete user';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
