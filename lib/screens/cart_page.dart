import 'dart:async';
import 'package:flutter/material.dart';
import 'cart_item.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final VoidCallback onCartUpdated;
  final Function(String productName)? onAskAi; // 1. Added callback

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onCartUpdated,
    this.onAskAi, // 2. Received in constructor
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color primaryBlue = Color(0xFF1E439B);
  static const Color cyanPlus = Color(0xFF29B6F6);
  static const Color redMinus = Color(0xFFE53935);
  static const Color purpleAi = Color(0xFF8E24AA);
  static const Color checkoutGreen = Color(0xFF00C853);
  static const Color totalGrey = Color(0xFFB0BEC5);

  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  int get totalItemCount =>
      widget.cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get grandTotal =>
      widget.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final date = '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    return '$date | $time';
  }

  void _incrementQuantity(int index) {
    setState(() {
      widget.cartItems[index].quantity++;
    });
    widget.onCartUpdated();
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (widget.cartItems[index].quantity > 1) {
        widget.cartItems[index].quantity--;
      } else {
        widget.cartItems.removeAt(index);
      }
    });
    widget.onCartUpdated();
  }

  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
    widget.onCartUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Item Count & Live Date/Time
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Item Count: $totalItemCount',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _formatDateTime(_currentTime),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Cart Items List
            Expanded(
              child: widget.cartItems.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.white54),
                    SizedBox(height: 12),
                    Text(
                      'Your cart is empty.\nScan a QR code or barcode to add items.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.4),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Row(
                      children: [
                        // Product Image Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 45,
                            height: 45,
                            color: Colors.white,
                            child: Image.asset(
                              item.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.grey,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Product Name
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Quantity Tag
                        Expanded(
                          flex: 1,
                          child: Text(
                            'x${item.quantity}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Counter Controls (+) | (-)
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _incrementQuantity(index),
                              icon: const Icon(
                                Icons.add_circle,
                                color: cyanPlus,
                                size: 32,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              height: 24,
                              width: 2,
                              color: Colors.white70,
                            ),
                            IconButton(
                              onPressed: () => _decrementQuantity(index),
                              icon: const Icon(
                                Icons.remove_circle,
                                color: redMinus,
                                size: 32,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(width: 32),

                        // AI Sparkle Button -> Direct to AI Chat (Qwen)
                        IconButton(
                          onPressed: () {
                            if (widget.onAskAi != null) {
                              widget.onAskAi!(item.name);
                            }
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: purpleAi,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Item Total Price
                        SizedBox(
                          width: 90,
                          child: Text(
                            'RM${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        // Delete Icon
                        IconButton(
                          onPressed: () => _removeItem(index),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: redMinus,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Checkout Bottom Bar
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 200,
                  height: 56,
                  color: totalGrey,
                  alignment: Alignment.center,
                  child: Text(
                    'RM${grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  width: 200,
                  height: 56,
                  color: checkoutGreen,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      child: const Center(
                        child: Text(
                          'CHECKOUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
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
}