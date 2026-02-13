import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _isScanned = false;

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: [
      BarcodeFormat.aztec,
      BarcodeFormat.codabar,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.itf,
      BarcodeFormat.pdf417,
      BarcodeFormat.unknown,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AiBarcodeScanner(
        controller: _controller,
        onDetect: (capture) async {
          if (_isScanned) return;

          final barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;

          final code = barcodes.first.rawValue;
          if (code == null) return;

          _isScanned = true;

          await Future.delayed(const Duration(milliseconds: 300));

          if (mounted) {
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}
