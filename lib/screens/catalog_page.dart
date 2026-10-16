import 'dart:async';
import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double originalPrice;
  final double? discountedPrice;
  final String imagePath; // Local asset file path

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.originalPrice,
    this.discountedPrice,
    required this.imagePath,
  });

  bool get isDiscounted => discountedPrice != null && discountedPrice! < originalPrice;
}

class CatalogScreen extends StatefulWidget {
  final Function(String productName)? onAskAi;

  const CatalogScreen({
    super.key,
    this.onAskAi,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const Color primaryBlue = Color(0xFF1E439B);
  static const Color accentOrange = Color(0xFFD35400);
  static const Color aiPurple = Color(0xFF8E24AA);

  final List<String> categories = [
    'ALL',
    'GROCERY',
    'SNACKS',
    'BEVERAGE',
    'PETS',
    'BEAUTY',
  ];
  String selectedCategory = 'ALL';

  final List<Product> products = [
    Product(
      id: '1',
      name: 'Maggie 2 Minute Instant Noodle',
      category: 'GROCERY',
      originalPrice: 6.20,
      discountedPrice: 4.79,
      imagePath: 'assets/images/grocery/IntelliCart Images.png',
    ),
    Product(
      id: '2',
      name: 'Double Swallow Garam Halus',
      category: 'GROCERY',
      originalPrice: 0.95,
      discountedPrice: null,
      imagePath: 'assets/images/grocery/IntelliCart Images (1).png',
    ),
    Product(
      id: '3',
      name: 'Jasmine Sunwhite Super Import 10kg',
      category: 'GROCERY',
      originalPrice: 73.34,
      discountedPrice: 60.99,
      imagePath: 'assets/images/grocery/IntelliCart Images (2).png',
    ),
    Product(
      id: '4',
      name: 'Knife Cooking Oil',
      category: 'GROCERY',
      originalPrice: 35.61,
      discountedPrice: 32.79,
      imagePath: 'assets/images/grocery/IntelliCart Images (3).png',
    ),
    Product(
      id: '5',
      name: 'CSR Coarse Sugar',
      category: 'GROCERY',
      originalPrice: 2.85,
      discountedPrice: null,
      imagePath: 'assets/images/grocery/IntelliCart Images (4).png',
    ),
    Product(
      id: '6',
      name: 'Twisties Big Cheese',
      category: 'SNACKS',
      originalPrice: 6.08,
      discountedPrice: null,
      imagePath: 'assets/images/snacks/1.png',
    ),
    Product(
      id: '7',
      name: 'Cadbury Dairy Milk Mini Bars',
      category: 'SNACKS',
      originalPrice: 18.49,
      discountedPrice: null,
      imagePath: 'assets/images/snacks/2.png',
    ),
    Product(
      id: '8',
      name: 'Munchy Oat Krunch Dark Chocolate',
      category: 'SNACKS',
      originalPrice: 10.95,
      discountedPrice: 8.30,
      imagePath: 'assets/images/snacks/3.png',
    ),
    Product(
      id: '9',
      name: 'Thumbs Ground Nut',
      category: 'SNACKS',
      originalPrice: 4.38,
      discountedPrice: 3.99,
      imagePath: 'assets/images/snacks/4.png',
    ),
    Product(
      id: '10',
      name: 'TOPVALU Dried Mango',
      category: 'SNACKS',
      originalPrice: 15.00,
      discountedPrice: null,
      imagePath: 'assets/images/snacks/5.png',
    ),
    Product(
      id: '11',
      name: 'Dutch Lady UHT Pure Farm Cream Milk',
      category: 'BEVERAGE',
      originalPrice: 20.40,
      discountedPrice: 17.90,
      imagePath: 'assets/images/beverages/1.png',
    ),
    Product(
      id: '12',
      name: 'Nescafe 3 in 1 White Coffee',
      category: 'BEVERAGE',
      originalPrice: 16.75,
      discountedPrice: 9.90,
      imagePath: 'assets/images/beverages/2.png',
    ),
    Product(
      id: '13',
      name: 'Aik Cheong Teh Cham',
      category: 'BEVERAGE',
      originalPrice: 14.99,
      discountedPrice: 10.99,
      imagePath: 'assets/images/beverages/3.png',
    ),
    Product(
      id: '14',
      name: 'Gatorade No Sugar Quiet Storm',
      category: 'BEVERAGE',
      originalPrice: 2.75,
      discountedPrice: null,
      imagePath: 'assets/images/beverages/4.png',
    ),
    Product(
      id: '15',
      name: 'Farm Fresh Chocolate Malt Powder',
      category: 'BEVERAGE',
      originalPrice: 15.99,
      discountedPrice: null,
      imagePath: 'assets/images/beverages/5.png',
    ),
    Product(
      id: '16',
      name: 'Smart Heart Pouch Tuna With Chicken',
      category: 'PETS',
      originalPrice: 2.00,
      discountedPrice: null,
      imagePath: 'assets/images/pets/1.png',
    ),
    Product(
      id: '17',
      name: 'Smart Heart Pouch 85g',
      category: 'PETS',
      originalPrice: 2.00,
      discountedPrice: null,
      imagePath: 'assets/images/pets/2.png',
    ),
    Product(
      id: '18',
      name: 'Pedigree Adult 3 kg',
      category: 'PETS',
      originalPrice: 29.20,
      discountedPrice: 27.90,
      imagePath: 'assets/images/pets/3.png',
    ),
    Product(
      id: '19',
      name: 'Cesar Dog Food Chicken',
      category: 'PETS',
      originalPrice: 4.40,
      discountedPrice: null,
      imagePath: 'assets/images/pets/4.png',
    ),
    Product(
      id: '20',
      name: 'TOPVALU Cat Litter Bentonite Lavendar',
      category: 'PETS',
      originalPrice: 10.90,
      discountedPrice: null,
      imagePath: 'assets/images/pets/5.png',
    ),
    Product(
      id: '21',
      name: 'Biore Men Double Scrub Facial Foam',
      category: 'BEAUTY',
      originalPrice: 15.40,
      discountedPrice: 10.99,
      imagePath: 'assets/images/beauty/1.png',
    ),
    Product(
      id: '22',
      name: 'TIRTIR Mask Fit Tone Up Cream',
      category: 'BEAUTY',
      originalPrice: 109.00,
      discountedPrice: 70.85,
      imagePath: 'assets/images/beauty/2.png',
    ),
    Product(
      id: '23',
      name: 'Simple Refreshing Facial Wash Gel',
      category: 'BEAUTY',
      originalPrice: 27.30,
      discountedPrice: null,
      imagePath: 'assets/images/beauty/3.png',
    ),
    Product(
      id: '24',
      name: 'Simple Soothing Toner',
      category: 'BEAUTY',
      originalPrice: 23.60,
      discountedPrice: 16.52,
      imagePath: 'assets/images/beauty/4.png',
    ),
    Product(
      id: '25',
      name: 'Bio Essence Bio Water Energizing Water Spray',
      category: 'BEAUTY',
      originalPrice: 39.90,
      discountedPrice: 27.93,
      imagePath: 'assets/images/beauty/5.png',
    ),
  ];

  late PageController _pageController;
  Timer? _carouselTimer;
  int _currentPage = 1000;

  List<Product> get filteredProducts {
    if (selectedCategory == 'ALL') {
      return products;
    }
    return products.where((p) => p.category == selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.28,
    );
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && filteredProducts.isNotEmpty) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 180,
                      width: 180,
                      color: Colors.grey.shade50,
                      child: Image.asset(
                        product.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Category: ${product.category}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'RM${(product.discountedPrice ?? product.originalPrice).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: accentOrange,
                      ),
                    ),
                    if (product.isDiscounted) ...[
                      const SizedBox(width: 10),
                      Text(
                        'RM${product.originalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: aiPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          if (widget.onAskAi != null) {
                            widget.onAskAi!(product.name);
                          }
                        },
                        icon: const Icon(Icons.auto_awesome, size: 20),
                        label: const Text(
                          'Ask AI (Halal / Allergens)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentProducts = filteredProducts;

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for an item',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.black87,
                      size: 28,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Category Filters
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                          _currentPage = 1000;
                        });
                        if (_pageController.hasClients && currentProducts.isNotEmpty) {
                          _pageController.jumpToPage(_currentPage);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? accentOrange : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Header Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  selectedCategory == 'ALL'
                      ? 'Recommended For You'
                      : '$selectedCategory Products',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Carousel Viewport
              Expanded(
                child: currentProducts.isEmpty
                    ? Center(
                  child: Text(
                    'No products found in "$selectedCategory"',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    : NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    _carouselTimer?.cancel();
                    _startAutoPlay();
                    return false;
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      final product = currentProducts[index % currentProducts.length];
                      return GestureDetector(
                        onTap: () => _showProductDetails(product),
                        child: _buildProductCard(product),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Product Image (Local Asset)
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  product.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // Product Info & Price
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Row(
                children: [
                  if (product.isDiscounted) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'RM${product.discountedPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: accentOrange,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'RM${product.originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'RM${product.originalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: accentOrange,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Container(
                    width: 1.5,
                    height: 28,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Quick Ask AI icon button on card
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      if (widget.onAskAi != null) {
                        widget.onAskAi!(product.name);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: aiPurple.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: aiPurple,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}