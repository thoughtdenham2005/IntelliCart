import 'dart:async';
import 'package:IntelliCart/screens/ai_chat_page.dart';
import 'package:IntelliCart/screens/cart_page.dart';
import 'package:IntelliCart/screens/cart_item.dart';
import 'package:IntelliCart/screens/catalog_page.dart';
import 'package:IntelliCart/screens/home_page.dart';
import 'package:IntelliCart/screens/navigation_page.dart';
import 'package:IntelliCart/screens/setting_page.dart';
import 'package:IntelliCart/widgets/youtube_recipe_dialog.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/sidebar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_API_KEY', // Replace with your Supabase URL
    publishableKey: 'YOUR_ANON_KEY', // Use anonKey (or publishableKey in v2)
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const IntelliCartApp());
}

class IntelliCartApp extends StatelessWidget {
  const IntelliCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntelliCart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final AudioPlayer _audioPlayer;
  bool _hasStarted = false;
  int _selectedTabIndex = 0;

  // Selected product passed across to AiChatScreen
  String? _selectedAiProduct;

  late final MobileScannerController _scannerController;
  DateTime? _lastScannedTime;

  // Active items currently inside the shopping cart
  final List<CartItem> _cartItems = [];

  // ==========================================
  // REALTIME PHONE BRIDGE (SUPABASE)
  // ==========================================
  StreamSubscription<List<Map<String, dynamic>>>? _cartSessionSubscription;
  String _lastProcessedUrl = '';

  // ==========================================
  // BARCODE DATABASE (5 Physical Items)
  // ==========================================
  final Map<String, Map<String, dynamic>> _barcodeDatabase = {
    '9556085536718': {
      'name': 'Pap Pingpong Chocoloate Teddy',
      'price': 4.20,
      'image': 'assets/images/snacks/09de98a0cde63fdedea98e86c57f35f6.webp',
    },
    '9551025380789': {
      'name': "My Rasa Triangle Cake",
      'price': 3.40,
      'image': 'assets/images/snacks/IMG-2858.webp',
    },
    '9555050301115': {
      'name': 'Ibumie Mi Goreng Original Flavour',
      'price': 3.20,
      'image': 'assets/images/barcode/Ibumie Mi Goreng.png',
    },
    '8851818341418': {
      'name': 'Bioré Micellar Water 400ml',
      'price': 12.12,
      'image': 'assets/images/barcode/Biore Micellar Cleansing Water.png',
    },
    '9556024707896': {
      'name': "Lady's Choice Grape Peanut Butter",
      'price': 15.00,
      'image': "assets/images/barcode/Lady's Choice.png",
    },
  };

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _scannerController = MobileScannerController(
      cameraResolution: const Size(1280, 720),
      facing: CameraFacing.front,
      detectionSpeed: DetectionSpeed.normal,
      returnImage: false,
    );

    // Initialize the real-time beam listener
    _startListeningToPhoneBeams();
  }

  void _startListeningToPhoneBeams() {
    final supabase = Supabase.instance.client;

    _cartSessionSubscription = supabase
        .from('cart_sessions')
        .stream(primaryKey: ['cart_id'])
        .eq('cart_id', 'cart_01')
        .listen(
          (List<Map<String, dynamic>> data) {
        if (data.isNotEmpty) {
          final incomingUrl = data.first['youtube_url'] as String? ?? '';

          // Only trigger if a genuine non-empty URL arrived and hasn't been processed yet
          if (incomingUrl.isNotEmpty && incomingUrl != _lastProcessedUrl) {
            _lastProcessedUrl = incomingUrl;
            _onRecipeBeamed(incomingUrl);
          }
        }
      },
      onError: (error) {
        debugPrint('Supabase stream error: $error');
      },
    );
  }

  void _onRecipeBeamed(String youtubeUrl) {
    if (!mounted) return;

    HapticFeedback.heavyImpact();
    _showFeedbackBanner('Recipe beamed from mobile!', isSuccess: true);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => YoutubeRecipeDialog(
        initialUrl: youtubeUrl,
      ),
    );
  }

  @override
  void dispose() {
    _cartSessionSubscription?.cancel();
    _audioPlayer.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _navigateToAiChat(String productName) {
    setState(() {
      _selectedAiProduct = productName;
      _selectedTabIndex = 3;
    });
  }

  Future<void> _playBeep() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        AssetSource('audio/beep.mp3'),
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      debugPrint('Error playing scan sound: $e');
    }
  }

  void _onBarcodeScanned(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue?.trim();
    if (rawValue == null || rawValue.isEmpty) return;

    final now = DateTime.now();
    if (_lastScannedTime == null ||
        now.difference(_lastScannedTime!) > const Duration(milliseconds: 1500)) {
      _lastScannedTime = now;
      _handleItemDetected(rawValue);
    }
  }

  void _handleItemDetected(String barcode) {
    HapticFeedback.mediumImpact();

    if (_barcodeDatabase.containsKey(barcode)) {
      _playBeep();

      final product = _barcodeDatabase[barcode]!;
      final String name = product['name'];
      final double price = product['price'];
      final String imagePath = product['image'];

      setState(() {
        final existingIndex = _cartItems.indexWhere((item) => item.barcode == barcode);
        if (existingIndex != -1) {
          _cartItems[existingIndex].quantity++;
        } else {
          _cartItems.add(
            CartItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              barcode: barcode,
              name: name,
              unitPrice: price,
              imagePath: imagePath,
              quantity: 1,
            ),
          );
        }
      });

      _showFeedbackBanner('Added to Cart: $name (RM${price.toStringAsFixed(2)})', isSuccess: true);
    } else {
      _showFeedbackBanner('Item not found for barcode: $barcode', isSuccess: false);
    }
  }

  void _showFeedbackBanner(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? const Color(0xFF00C853) : Colors.redAccent,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasStarted) {
      return HomeScreen(
        onStartPressed: () {
          setState(() {
            _hasStarted = true;
            _selectedTabIndex = 0;
          });
        },
      );
    }

    final List<Widget> screens = [
      CatalogScreen(
        onAskAi: _navigateToAiChat,
      ),
      CartScreen(
        cartItems: _cartItems,
        onCartUpdated: () => setState(() {}),
        onAskAi: _navigateToAiChat,
      ),
      const NavigationScreen(),
      AiChatScreen(
        key: ValueKey(_selectedAiProduct),
        initialQueryProduct: _selectedAiProduct,
      ),
      SettingsScreen(
        onEndSession: () {
          setState(() {
            _cartItems.clear();
            _selectedAiProduct = null;
            _hasStarted = false;
          });
        },
      ),
    ];

    final bool isScannerSupported = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    if (!isScannerSupported) {
      return Scaffold(
        body: IndexedStack(
          index: _selectedTabIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedTabIndex,
          onTabSelected: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),
      );
    }

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          width: 1,
          height: 1,
          child: Opacity(
            opacity: 0.01,
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _onBarcodeScanned,
            ),
          ),
        ),
        Positioned.fill(
          child: Scaffold(
            body: IndexedStack(
              index: _selectedTabIndex,
              children: screens,
            ),
            bottomNavigationBar: BottomNavBar(
              currentIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

