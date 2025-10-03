import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user != null
                        ? '${user.firstName ?? ''} ${user.lastName ?? ''}'
                            .trim()
                        : 'Guest User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'Not logged in',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  // Debug info for role
                  if (user != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Role: ${user.role.name.toUpperCase()}',
                      style: TextStyle(
                        color:
                            user.role == Role.admin ? Colors.red : Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.push('/profile/edit');
                    },
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu Items
            _buildMenuSection('Account', [
              _buildMenuItem(
                Icons.person_outline,
                'Personal Information',
                () {
                  // TODO: Navigate to personal info
                },
              ),
              _buildMenuItem(
                Icons.location_on_outlined,
                'Addresses',
                () {
                  // TODO: Navigate to addresses
                },
              ),
              _buildMenuItem(
                Icons.payment_outlined,
                'Payment Methods',
                () {
                  // TODO: Navigate to payment methods
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Admin Panel Section (only for admin users)
            if (user?.role == Role.admin) ...[
              _buildMenuSection('Admin Panel', [
                _buildMenuItem(
                  Icons.admin_panel_settings,
                  'Admin Dashboard',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboardScreen(),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 16),
            ],

            _buildMenuSection('Orders & Shopping', [
              _buildMenuItem(
                Icons.receipt_long_outlined,
                'Order History',
                () {
                  // TODO: Navigate to order history
                },
              ),
              _buildMenuItem(
                Icons.favorite_outline,
                'Wishlist',
                () {
                  // TODO: Navigate to wishlist
                },
              ),
              _buildMenuItem(
                Icons.reviews_outlined,
                'Reviews',
                () {
                  // TODO: Navigate to reviews
                },
              ),
            ]),

            const SizedBox(height: 16),

            _buildMenuSection('Support & Information', [
              _buildMenuItem(
                Icons.help_outline,
                'Help Center',
                () {
                  // TODO: Navigate to help
                },
              ),
              _buildMenuItem(
                Icons.info_outline,
                'About',
                () {
                  // TODO: Navigate to about
                },
              ),
              _buildMenuItem(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                () {
                  // TODO: Navigate to privacy policy
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Logout'),
              ),
            ),

            const SizedBox(height: 16),

            // App Version
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(title),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Logout using auth provider
                await ref.read(authProvider.notifier).logout();
                if (mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
