import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/cart.dart';
import '../../orders/providers/order_provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartNotifierProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final itemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart ($itemCount items)'),
        actions: [
          if (itemCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearCartDialog(context, ref),
            ),
        ],
      ),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context, ref, error),
        data: (cart) => cart.items.isEmpty
            ? _buildEmptyCart(context)
            : _buildCartContent(context, ref, cart),
      ),
      bottomNavigationBar: itemCount > 0
          ? _buildCheckoutBar(context, cartTotal, itemCount)
          : null,
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/products');
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, WidgetRef ref, Cart cart) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(cartNotifierProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];
          return _buildCartItem(context, ref, item);
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, WidgetRef ref, CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.product.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 32,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.product.category != null)
                    Text(
                      item.product.category!.name,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${item.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total: \$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Quantity Controls
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        ref
                            .read(cartNotifierProvider.notifier)
                            .updateQuantity(item.id, item.quantity - 1);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: item.quantity < item.product.stock
                          ? () {
                              ref
                                  .read(cartNotifierProvider.notifier)
                                  .updateQuantity(item.id, item.quantity + 1);
                            }
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    ref.read(cartNotifierProvider.notifier).removeItem(item.id);
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, double total, int itemCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total ($itemCount items)',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 56,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return ElevatedButton.icon(
                        onPressed: () {
                          final cartItems =
                              ref.read(cartNotifierProvider).value?.items ?? [];
                          final total = ref.read(cartTotalProvider);

                          // Check if any items are out of stock
                          final outOfStockItems = cartItems
                              .where((item) =>
                                  item.product.stock <= 0 ||
                                  item.quantity > item.product.stock)
                              .toList();

                          if (outOfStockItems.isNotEmpty) {
                            _showOutOfStockDialog(context, outOfStockItems);
                            return;
                          }

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => CheckoutBottomSheet(
                              cartItems: cartItems,
                              total: total,
                              onCheckoutComplete: () {
                                // Clear cart after successful checkout
                                ref
                                    .read(cartNotifierProvider.notifier)
                                    .clearCart();
                                // Refresh orders list
                                ref.invalidate(ordersProvider);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, Object error) {
    final isAuthError = error.toString().contains('log in') ||
        error.toString().contains('Unauthorized') ||
        error.toString().contains('401');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAuthError ? Icons.login : Icons.error_outline,
            size: 64,
            color: isAuthError ? Colors.orange : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            isAuthError ? 'Please log in' : 'Failed to load cart',
            style: TextStyle(
              fontSize: 18,
              color: isAuthError ? Colors.orange : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          if (isAuthError)
            ElevatedButton.icon(
              onPressed: () {
                context.go('/login');
              },
              icon: const Icon(Icons.login),
              label: const Text('Log In'),
            )
          else
            ElevatedButton(
              onPressed: () {
                ref.read(cartNotifierProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(cartNotifierProvider.notifier).clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showOutOfStockDialog(
      BuildContext context, List<CartItem> outOfStockItems) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Items Out of Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'The following items are out of stock or exceed available quantity:'),
            const SizedBox(height: 12),
            ...outOfStockItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.product.name} (${item.quantity} requested, ${item.product.stock} available)',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            const Text(
              'Please update your cart before proceeding to checkout.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Update Cart'),
          ),
        ],
      ),
    );
  }
}

// Checkout Bottom Sheet Widget
class CheckoutBottomSheet extends StatefulWidget {
  final List<CartItem> cartItems;
  final double total;
  final VoidCallback onCheckoutComplete;

  const CheckoutBottomSheet({
    super.key,
    required this.cartItems,
    required this.total,
    required this.onCheckoutComplete,
  });

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  int _currentStep = 0;
  bool _isProcessing = false;

  // Mock data
  String _selectedPayment = 'credit_card';
  String _selectedShipping = 'standard';

  final _nameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _addressController = TextEditingController(text: '123 Main Street');
  final _cityController = TextEditingController(text: 'New York');
  final _zipController = TextEditingController(text: '10001');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Shipping', _currentStep >= 0),
                Expanded(
                    child: Container(
                        height: 2,
                        color: _currentStep >= 1
                            ? Colors.green
                            : Colors.grey.shade300)),
                _buildStepIndicator(1, 'Payment', _currentStep >= 1),
                Expanded(
                    child: Container(
                        height: 2,
                        color: _currentStep >= 2
                            ? Colors.green
                            : Colors.grey.shade300)),
                _buildStepIndicator(2, 'Review', _currentStep >= 2),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isProcessing ? _buildProcessingView() : _buildStepContent(),
          ),

          // Bottom bar
          if (!_isProcessing) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildShippingStep();
      case 1:
        return _buildPaymentStep();
      case 2:
        return _buildReviewStep();
      default:
        return Container();
    }
  }

  Widget _buildShippingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Full Name', _nameController, Icons.person),
          const SizedBox(height: 12),
          _buildTextField('Email', _emailController, Icons.email),
          const SizedBox(height: 12),
          _buildTextField('Address', _addressController, Icons.location_on),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                    'City', _cityController, Icons.location_city),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                    'ZIP Code', _zipController, Icons.local_post_office),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Shipping Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildShippingOption(
              'standard', 'Standard Shipping', '5-7 business days', 0.0),
          _buildShippingOption(
              'express', 'Express Shipping', '2-3 business days', 9.99),
          _buildShippingOption(
              'overnight', 'Overnight Shipping', '1 business day', 19.99),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentOption(
            'credit_card',
            'Credit Card',
            Icons.credit_card,
            'Visa, Mastercard, American Express',
          ),
          _buildPaymentOption(
            'paypal',
            'PayPal',
            Icons.payment,
            'Pay with your PayPal account',
          ),
          _buildPaymentOption(
            'apple_pay',
            'Apple Pay',
            Icons.phone_iphone,
            'Pay with Touch ID or Face ID',
          ),
          _buildPaymentOption(
            'google_pay',
            'Google Pay',
            Icons.android,
            'Pay with Google Pay',
          ),
          if (_selectedPayment == 'credit_card') ...[
            const SizedBox(height: 24),
            const Text(
              'Card Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
                'Card Number',
                TextEditingController(text: '**** **** **** 1234'),
                Icons.credit_card),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('MM/YY',
                      TextEditingController(text: '12/25'), Icons.date_range),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField('CVV',
                      TextEditingController(text: '123'), Icons.security),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final shippingCost = _getShippingCost();
    final tax = widget.total * 0.08; // 8% tax
    final finalTotal = widget.total + shippingCost + tax;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Items
          ...widget.cartItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.name} × ${item.quantity}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),

          const Divider(height: 32),

          // Totals
          _buildTotalRow('Subtotal', widget.total),
          _buildTotalRow('Shipping', shippingCost),
          _buildTotalRow('Tax', tax),
          const Divider(height: 16),
          _buildTotalRow('Total', finalTotal, isTotal: true),

          const SizedBox(height: 24),

          // Shipping & Payment Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipping to:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_nameController.text}\n${_addressController.text}\n${_cityController.text}, ${_zipController.text}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  'Payment:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPaymentMethodName(),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Processing your order...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we process your payment',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildShippingOption(
      String value, String title, String subtitle, double cost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedShipping,
        onChanged: (value) {
          setState(() {
            _selectedShipping = value!;
          });
        },
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Text(
          cost == 0 ? 'Free' : '\$${cost.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      String value, String title, IconData icon, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedPayment,
        onChanged: (value) {
          setState(() {
            _selectedPayment = value!;
          });
        },
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _handleNext,
                child: Text(
                  _currentStep == 2 ? 'Place Order' : 'Continue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _processCheckout();
    }
  }

  Future<void> _processCheckout() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Create actual order using the order service
      final orderNotifier = ProviderScope.containerOf(context)
          .read(orderCreationProvider.notifier);
      final order = await orderNotifier.createOrder();

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        if (order != null) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Order Placed Successfully!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Thank you for your purchase! You can track your order in the Orders tab.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    widget.onCheckoutComplete();
                  },
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
          );
        } else {
          // Show error dialog
          _showErrorDialog('Failed to create order. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Debug: Print the actual error for development
        print('Order creation error: $e');

        String errorMessage = e.toString();
        if (errorMessage.contains('log in')) {
          errorMessage = 'Please log in to place an order';
        } else if (errorMessage.contains('stock')) {
          errorMessage = 'Some items in your cart are out of stock';
        } else if (errorMessage.contains('empty')) {
          errorMessage = 'Your cart is empty';
        } else {
          errorMessage = 'Failed to create order: ${e.toString()}';
        }

        _showErrorDialog(errorMessage);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  double _getShippingCost() {
    switch (_selectedShipping) {
      case 'express':
        return 9.99;
      case 'overnight':
        return 19.99;
      default:
        return 0.0;
    }
  }

  String _getPaymentMethodName() {
    switch (_selectedPayment) {
      case 'paypal':
        return 'PayPal';
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
      default:
        return 'Credit Card ending in 1234';
    }
  }
}
