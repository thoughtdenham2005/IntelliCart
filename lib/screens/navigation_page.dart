import 'dart:math' as math;
import 'package:flutter/material.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> with SingleTickerProviderStateMixin {
  // Live Cart Coordinate (Starts at Entrance)
  Offset _cartPosition = const Offset(80, 520);

  // Selected Target Destination
  String _selectedItem = "Noodles";
  Offset _destination = const Offset(200, 160); // Aisle 2 - Noodles

  // Preset Product Coordinates
  final Map<String, Offset> _productLocations = {
    "Noodles": const Offset(200, 160),      // Aisle 2 Top
    "Fresh Milk": const Offset(80, 160),     // Aisle 1 Dairy
    "Snacks & Chips": const Offset(320, 300),// Aisle 3 Middle
    "Beverages": const Offset(440, 200),     // Aisle 4 Drinks
  };

  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _updateTarget(String item) {
    setState(() {
      _selectedItem = item;
      _destination = _productLocations[item]!;
    });
  }

  // Move cart manually via D-Pad
  void _moveCart(double dx, double dy) {
    setState(() {
      _cartPosition = Offset(
        (_cartPosition.dx + dx).clamp(40.0, 500.0),
        (_cartPosition.dy + dy).clamp(60.0, 540.0),
      );
    });
  }

  // Auto-route animation for pitch demos
  void _simulateAutoNavigation() async {
    List<Offset> waypoints = [
      const Offset(80, 440),  // Main lower concourse
      const Offset(200, 440), // Move to Aisle 2 entrance
      const Offset(200, 280), // Walk up Aisle 2
      _destination,           // Arrive at Noodles
    ];

    for (var target in waypoints) {
      while ((_cartPosition - target).distance > 5) {
        await Future.delayed(const Duration(milliseconds: 25));
        if (!mounted) return;
        setState(() {
          double dx = target.dx - _cartPosition.dx;
          double dy = target.dy - _cartPosition.dy;
          double angle = math.atan2(dy, dx);
          _cartPosition = Offset(
            _cartPosition.dx + math.cos(angle) * 4,
            _cartPosition.dy + math.sin(angle) * 4,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Row(
          children: [
            // 1. Left: 2D Supermarket Map Canvas
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Static Floor Plan & Navigation Path
                        CustomPaint(
                          size: Size.infinite,
                          painter: SupermarketMapPainter(
                            cartPos: _cartPosition,
                            destPos: _destination,
                          ),
                        ),

                        // Destination Pin (Noodles / Selected Item)
                        Positioned(
                          left: _destination.dx - 16,
                          top: _destination.dy - 32,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141223),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _selectedItem,
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.location_on, color: Colors.redAccent, size: 28),
                            ],
                          ),
                        ),

                        // Live User Cart Marker with Radar Pulse
                        AnimatedBuilder(
                          animation: _radarController,
                          builder: (context, child) {
                            return Positioned(
                              left: _cartPosition.dx - 20,
                              top: _cartPosition.dy - 20,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer Pulsating Ring
                                  Container(
                                    width: 40 * _radarController.value,
                                    height: 40 * _radarController.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFFF9800).withValues(alpha: 1.0 - _radarController.value),
                                    ),
                                  ),
                                  // Core Marker
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFFF9800),
                                      border: Border.all(color: Colors.white, width: 2.5),
                                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Right: Controls & Routing Dashboard
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search / Item Selector
                    const Text(
                      "Find Product in Store",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF141223)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedItem,
                          isExpanded: true,
                          items: _productLocations.keys.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Row(
                                children: [
                                  const Icon(Icons.search, size: 18, color: Color(0xFFFF9800)),
                                  const SizedBox(width: 8),
                                  Text(item, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) _updateTarget(val);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Navigation Info Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141223),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_walk_rounded, color: Color(0xFFFF9800), size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Target: $_selectedItem",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  "Aisle 2 • Approx 12m away",
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Auto-Route Pitch Demo Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _simulateAutoNavigation,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text("Simulate Path Walk"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Live Movement Manual D-Pad
                    const Center(
                      child: Text(
                        "Live Cart Movement Control",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 0,
                              child: _dPadBtn(Icons.arrow_upward, () => _moveCart(0, -15)),
                            ),
                            Positioned(
                              bottom: 0,
                              child: _dPadBtn(Icons.arrow_downward, () => _moveCart(0, 15)),
                            ),
                            Positioned(
                              left: 10,
                              child: _dPadBtn(Icons.arrow_back, () => _moveCart(-15, 0)),
                            ),
                            Positioned(
                              right: 10,
                              child: _dPadBtn(Icons.arrow_forward, () => _moveCart(15, 0)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dPadBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF141223)),
      ),
    );
  }
}

// 3. Custom Painter for Floor Plan Layout & Pathfinding
class SupermarketMapPainter extends CustomPainter {
  final Offset cartPos;
  final Offset destPos;

  SupermarketMapPainter({required this.cartPos, required this.destPos});

  @override
  void paint(Canvas canvas, Size size) {
    final shelfPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final shelfBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Shelves Layout (Aisles 1 to 4)
    final List<Rect> shelves = [
      const Rect.fromLTWH(50, 80, 50, 300),   // Aisle 1 (Dairy)
      const Rect.fromLTWH(170, 80, 50, 300),  // Aisle 2 (Noodles / Grains)
      const Rect.fromLTWH(290, 80, 50, 300),  // Aisle 3 (Snacks)
      const Rect.fromLTWH(410, 80, 50, 300),  // Aisle 4 (Beverages)
    ];

    final List<String> aisleLabels = ["Aisle 1\nDairy", "Aisle 2\nNoodles", "Aisle 3\nSnacks", "Aisle 4\nDrinks"];

    for (int i = 0; i < shelves.length; i++) {
      final rect = shelves[i];
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), shelfPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), shelfBorder);

      _drawText(canvas, aisleLabels[i], Offset(rect.center.dx, rect.top + 20));
    }

    // Entrance & Checkout Kiosk Areas
    final entranceRect = const Rect.fromLTWH(50, 490, 80, 40);
    final exitKioskRect = const Rect.fromLTWH(380, 490, 100, 40);

    canvas.drawRRect(RRect.fromRectAndRadius(entranceRect, const Radius.circular(6)), Paint()..color = Colors.green.shade100);
    _drawText(canvas, "ENTRANCE", entranceRect.center);

    canvas.drawRRect(RRect.fromRectAndRadius(exitKioskRect, const Radius.circular(6)), Paint()..color = Colors.orange.shade100);
    _drawText(canvas, "KIOSK CHECKOUT", exitKioskRect.center);

    // Dynamic Navigation Path Line (Cart -> Destination)
    final pathPaint = Paint()
      ..color = const Color(0xFFFF9800)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(cartPos.dx, cartPos.dy);

    // Corridor Routing Point (routes through bottom hallway to avoid crossing shelves)
    double corridorY = (cartPos.dy < 420 && destPos.dy < 420 && (cartPos.dx - destPos.dx).abs() > 60)
        ? 420.0
        : cartPos.dy;

    if (corridorY == 420.0) {
      path.lineTo(cartPos.dx, corridorY);
      path.lineTo(destPos.dx, corridorY);
      path.lineTo(destPos.dx, destPos.dy);
    } else {
      path.lineTo(destPos.dx, destPos.dy);
    }

    canvas.drawPath(path, pathPaint);
  }

  void _drawText(Canvas canvas, String text, Offset center) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant SupermarketMapPainter oldDelegate) {
    return oldDelegate.cartPos != cartPos || oldDelegate.destPos != destPos;
  }
}