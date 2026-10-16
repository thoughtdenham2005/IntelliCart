import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ContinuousFrontScanner extends StatefulWidget {
  final Function(String barcode) onBarcodeDetected;
  final Widget child; // Your main UI sits on top of this

  const ContinuousFrontScanner({
    super.key,
    required this.onBarcodeDetected,
    required this.child,
  });

  @override
  State<ContinuousFrontScanner> createState() => _ContinuousFrontScannerState();
}

class _ContinuousFrontScannerState extends State<ContinuousFrontScanner> {
  late MobileScannerController _controller;
  DateTime? _lastScannedTime;

  @override
  void initState() {
    super.initState();
    // Initialize controller strictly targeting the FRONT (selfie) camera
    _controller = MobileScannerController(
      cameraResolution: const Size(1280, 720), // Optimized for 60fps fast detection
      facing: CameraFacing.front,
      detectionSpeed: DetectionSpeed.noDuplicates,  // Very Importantn
      returnImage: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    // Cooldown gate (1.5 seconds) to prevent duplicate rapid scans of the same item
    final now = DateTime.now();
    if (_lastScannedTime == null ||
        now.difference(_lastScannedTime!) > const Duration(milliseconds: 1500)) {
      _lastScannedTime = now;
      widget.onBarcodeDetected(rawValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Off-screen / Background Front Camera Feed
        // Using a 1x1 sized offstage or an actual camera view behind the UI
        Positioned(
          top: 0,
          left: 0,
          width: 1,
          height: 1,
          child: Opacity(
            opacity: 0.01, // Kept active in rendering pipeline
            child: MobileScanner(
              controller: _controller,
              onDetect: _handleBarcode,
            ),
          ),
        ),

        // 2. Foreground App Shell (All your screens, bottom nav, buttons)
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}