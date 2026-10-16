import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  // 1. Declare the callback parameter
  final VoidCallback? onStartPressed;

  // 2. Add it to the constructor
  const HomeScreen({
    super.key,
    this.onStartPressed,
  });

  static const Color primaryBlue = Color(0xFF1E439B);
  static const Color accentOrange = Color(0xFFD35400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Row(
        children: [
          // Left Panel
          Expanded(
            flex: 5,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Logo
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: accentOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: primaryBlue,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'INTELLICART',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Tagline
                    const Text(
                      'Shop Smarter,\nCheckout Faster!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        height: 1.25,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),

                    // 3. Connect the callback to the START ElevatedButton
                    SizedBox(
                      width: 230,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: onStartPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          foregroundColor: primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'START',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Right Panel
          Expanded(
            flex: 5,
            child: SizedBox(
              height: double.infinity,
              child: Image.asset(
                'assets/images/Gemini_Generated_Image_cdzeb0cdzeb0cdze.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}