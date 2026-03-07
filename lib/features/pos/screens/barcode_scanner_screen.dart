import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late final bool _isSupported;
  MobileScannerController? cameraController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isSupported = kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
    if (_isSupported) {
      cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return; // Prevent multiple scans at once

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final String? code = barcode.rawValue;
      if (code != null) {
        setState(() {
          _isProcessing = true;
        });
        
        // Pause camera to prevent immediate rescanning
        cameraController?.stop();

        // Return the barcode value to the previous screen
        Navigator.pop(context, code);
      }
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Scan Barcode',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (!_isSupported)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt, color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Camera strictly unsupported on this platform.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, "1"); // Mocking an Espresso scan
                    },
                    child: const Text('Simulate Scan: "1"'),
                  ),
                ],
              ),
            )
          else ...[
            MobileScanner(
              controller: cameraController!,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Scanner error: ${error.errorCode}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            // Scanner Overlay
            Container(
              decoration: ShapeDecoration(
                shape: _ScannerOverlayShape(
                  borderColor: colorScheme.primary,
                  borderWidth: 4,
                  overlayColor: Colors.black54,
                  cutOutSize: MediaQuery.of(context).size.width * 0.7,
                ),
              ),
            ),
            // Instruction Text
            Positioned(
              bottom: 64,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Align barcode within the frame',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double cutOutSize;

  const _ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.overlayColor = const Color(0x88000000),
    required this.cutOutSize,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          const Radius.circular(16),
        ),
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;
    
    // Draw the overlay
    final backgroundPath = Path()
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          const Radius.circular(16),
        ),
      )
      ..fillType = PathFillType.evenOdd;
      
    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw the borders at corners
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    final double length = cutOutSize * 0.15;
    
    // Top-left
    canvas.drawLine(
        cutOutRect.topLeft, cutOutRect.topLeft + Offset(length, 0), borderPaint);
    canvas.drawLine(
        cutOutRect.topLeft, cutOutRect.topLeft + Offset(0, length), borderPaint);

    // Top-right
    canvas.drawLine(cutOutRect.topRight,
        cutOutRect.topRight + Offset(-length, 0), borderPaint);
    canvas.drawLine(cutOutRect.topRight,
        cutOutRect.topRight + Offset(0, length), borderPaint);

    // Bottom-left
    canvas.drawLine(cutOutRect.bottomLeft,
        cutOutRect.bottomLeft + Offset(length, 0), borderPaint);
    canvas.drawLine(cutOutRect.bottomLeft,
        cutOutRect.bottomLeft + Offset(0, -length), borderPaint);

    // Bottom-right
    canvas.drawLine(cutOutRect.bottomRight,
        cutOutRect.bottomRight + Offset(-length, 0), borderPaint);
    canvas.drawLine(cutOutRect.bottomRight,
        cutOutRect.bottomRight + Offset(0, -length), borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return _ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      cutOutSize: cutOutSize * t,
    );
  }
}
