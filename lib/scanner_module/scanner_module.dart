import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:latestversionscanner/modal/scanned_item_modal.dart';
import 'package:latestversionscanner/sqlite_manager/database_helper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerModule extends StatefulWidget {
  const ScannerModule({super.key});

  @override
  State<ScannerModule> createState() => _ScannerModuleState();
}

class _ScannerModuleState extends State<ScannerModule> {

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final List<ScannedItemModal> scannedItems = [];
  late MobileScannerController controller;

  bool _isTorchOn = false;
  String _scannedCode = "";
  bool _isShowingSnackBar = false;
  bool _isAutoFocusEnabled = true;

  //Prevent Duplicate
  final Set<String> _scannedCodes = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = MobileScannerController(
      // detectionSpeed: DetectionSpeed.normal,
      detectionSpeed: DetectionSpeed.unrestricted,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: [BarcodeFormat.all],
      detectionTimeoutMs: 500,
    );
  }



  Future<void> _saveData() async {
    if (scannedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data to save'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final dataList = scannedItems.map((item) => item.toMap()).toList();
    final response = await _databaseHelper.insertDataList(
        "SerialNumberStoreTable", dataList);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response), backgroundColor: Colors.green),
    );
    Navigator.pop(context);

  }


  void _deleteItem(int index) {
    setState(() {
      scannedItems.removeAt(index);
    });
  }

  void _toggleTorch() {
    controller.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  void _readBarCodeOrQRCode(BarcodeCapture capture, BoxConstraints constraints, double scanBoxSize,) async
  {
    if (_isShowingSnackBar) return;

    try {
      final barcodes = capture.barcodes;
      final imageSize = capture.size;
      final widgetSize = Size(constraints.maxWidth, constraints.maxHeight);

      print("Found ${barcodes.length} barcodes");

      // ✅ Process ALL barcodes, not just the first one
      for (final barcode in barcodes) {
        final corners = barcode.corners;
        if (corners == null || corners.isEmpty) continue;

        final captureData = barcode.rawValue;
        final format = barcode.format.name.toUpperCase();
        if (captureData == null || captureData.isEmpty) continue;

        // ✅ Skip if already scanned
        if (_scannedCodes.contains(captureData)) {
          print("Duplicate prevented: $captureData");
          continue;
        }

        // Build rect from corners
        final imageRect = _rectFromCorners(corners);

        // Map rect into widget coordinates
        final mappedRect = _mapImageRectToWidgetRect(
          imageRect,
          imageSize,
          widgetSize,
          fit: BoxFit.cover,
        );

        // ✅ MATCH the visual scan area positioning
        final scanRect = Rect.fromLTWH(
          (widgetSize.width - scanBoxSize) / 2,
          (widgetSize.height - scanBoxSize) / 2 - widgetSize.height * 0.2, // Match visual
          scanBoxSize,
          scanBoxSize,
        );

        print("Barcode: $captureData");
        print("Mapped rect: $mappedRect");
        print("Scan rect: $scanRect");
        print("Center in scan area: ${scanRect.contains(mappedRect.center)}");
        print("Overlaps scan area: ${scanRect.overlaps(mappedRect)}");

        // ✅ More lenient detection - check if any part of barcode is in scan area
        if (scanRect.overlaps(mappedRect) ||
            scanRect.contains(mappedRect.center) ||
            mappedRect.overlaps(scanRect)) {

          print("✅ Barcode accepted: $captureData");

          // Add to scanned codes immediately to prevent duplicates
          _scannedCodes.add(captureData);
          final List<Map<String, dynamic>> rawData = await _databaseHelper.readData('SerialNumberStoreTable');
          final exists = rawData.any((row) => row['serialNumber'] == captureData);

          if(!exists)
            {
              final scannedItem = ScannedItemModal(
                serialNumber: captureData,
                format: format,
                scannedAt: DateTime.now().toString(),
              );

              setState(() {
                _scannedCode = captureData;
                scannedItems.insert(0, scannedItem);
              });

              // Show brief success feedback without stopping scanner
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Scanned: $captureData'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 1), // Shorter duration
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height - 200,
                    left: 20,
                    right: 20,
                  ),
                ),
              );

            }
          else
            {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Duplicate Scanned: $captureData'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 1), // Shorter duration
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height - 200,
                    left: 20,
                    right: 20,
                  ),
                ),
              );
            }
          // ✅ DON'T stop the scanner - continue scanning
          // This allows multiple barcodes to be scanned quickly

        } else {
          print("Barcode rejected: $captureData (outside scan area)");
        }
      }
    } catch (e) {
      print("Error reading barcode: $e");
      _isShowingSnackBar = false;
    }
  }



  @override
  Widget build(BuildContext context) {
    final scanBoxSize = MediaQuery.of(context).size.width * 0.9;
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(onPressed: _saveData, child: Text("Want To Save")),
          IconButton(
            onPressed: _toggleTorch,
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            color: _isTorchOn ? Colors.yellow : Colors.grey,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints){
          return Stack(
            children: [
              GestureDetector(
                child: MobileScanner(
                  controller: controller,
                  fit: BoxFit.cover, // use same 'fit' when mapping coordinates
                  onDetect: (capture) => _readBarCodeOrQRCode(capture, constraints, scanBoxSize),
                  errorBuilder: (context, error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          Text(
                            'Error: ${error.errorDetails?.message ?? 'Unknown error'}',
                          ),
                          ElevatedButton(
                            onPressed: () {
                              controller.start();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  },
                  // overlayBuilder: _overlayBuilder,
                ),

              ),

              ScannedPortionFun(scanBoxSize, _isAutoFocusEnabled),
              if(scannedItems.isEmpty)
                Positioned(
                  top: 500,
                  left: 60,
                  child: Text("No QR or Bar Code Capture Yet ",style: TextStyle(color: Colors.white, fontSize: 20),),),
              if (scannedItems.isNotEmpty)
                Positioned(
                  top: 400,
                  child:
                  SizedBox(
                    height: 400, // give it some space
                    width: 400,  // optional: restrict width too
                    child: ListView.builder(
                      shrinkWrap: true, // <-- helps inside fixed height
                      itemCount: scannedItems.length,
                      itemBuilder: (context, index) {
                        final item = scannedItems[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.grey[300]!),
                              right: BorderSide(color: Colors.grey[300]!),
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                            color: Colors.green[50],
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.serialNumber,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: IconButton(
                                  onPressed: () => _deleteItem(index),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}












Widget ScannedPortionFun(double scanBoxSize, bool _isAutoFocusEnabled)
{
  return LayoutBuilder(
    builder: (context, constraints) {
      return Stack(
        children: [
          // Blur outside scan area
          Positioned.fill(
            child: ClipPath(
              clipper: _ScanAreaClipper(scanBoxSize),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          ),

          // Blue corners
          Positioned(
            top: (constraints.maxHeight - scanBoxSize) / 2 - constraints.maxHeight * 0.2, // move up (same as clipper)
            left: (constraints.maxWidth - scanBoxSize) / 2,  // keep horizontally centered
            child: Container(
              width: scanBoxSize,
              height: scanBoxSize,
              color: Colors.transparent,
              child: CustomPaint(
                painter: _CornerPainter(),
              ),
            ),
          ),

          // Instructions
          Positioned(
            top: (constraints.maxHeight - scanBoxSize) / 2 - constraints.maxHeight * 0.25, // move up (same as clipper)
            left: (constraints.maxWidth - scanBoxSize) / 2,  // keep horizontally centered
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isAutoFocusEnabled ? Icons.center_focus_strong : Icons.touch_app,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isAutoFocusEnabled
                              ? 'Autofocus ON • Tap to focus'
                              : 'Tap anywhere to focus',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}








/// Clipper to blur only outside scan box
class _ScanAreaClipper extends CustomClipper<Path> {
  final double size;
  _ScanAreaClipper(this.size);

  @override
  Path getClip(Size screenSize) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height));
    // Center horizontally, but shift upward vertically
    final rect = Rect.fromLTWH(
      (screenSize.width - size) / 2,    // horizontal center
      (screenSize.height - size) / 2 - screenSize.height * 0.2, // move up 20% screen height
      size,
      size,
    );
    /*  final rect = Rect.fromCenter(
      center: screenSize.center(Offset.zero),
      width: size,
      height: size,
    );*/
    path.addRect(rect);
    return Path.combine(PathOperation.difference, path, Path()..addRect(rect));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}


/// Draw blue corners
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const corner = 20.0;

    // Top-left
    canvas.drawLine(Offset(0, 0), Offset(corner, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, corner), paint);

    // Top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - corner, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, corner), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(corner, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - corner), paint);

    // Bottom-right
    canvas.drawLine(
        Offset(size.width, size.height), Offset(size.width - corner, size.height), paint);
    canvas.drawLine(
        Offset(size.width, size.height), Offset(size.width, size.height - corner), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




Rect _rectFromCorners(List<Offset> corners) {
  final xs = corners.map((o) => o.dx);
  final ys = corners.map((o) => o.dy);
  final minX = xs.reduce(math.min);
  final maxX = xs.reduce(math.max);
  final minY = ys.reduce(math.min);
  final maxY = ys.reduce(math.max);
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

/// Map a rect from image coordinates -> widget coordinates.
///
/// - imageSize: size of camera image (capture.size)
/// - widgetSize: size of the widget where the preview is drawn (constraints)
/// - fit: how the preview is fitted (MobileScanner has `fit` property; default is often BoxFit.cover)
Rect _mapImageRectToWidgetRect(
    Rect imageRect,
    Size imageSize,
    Size widgetSize, {
      BoxFit fit = BoxFit.cover,
    }) {
  if (imageSize.width == 0 || imageSize.height == 0) {
    return Rect.zero;
  }

  // scale used by BoxFit.cover / contain
  double scale;
  if (fit == BoxFit.cover) {
    scale = math.max(widgetSize.width / imageSize.width, widgetSize.height / imageSize.height);
  } else {
    // BoxFit.contain or similar
    scale = math.min(widgetSize.width / imageSize.width, widgetSize.height / imageSize.height);
  }

  final displayW = imageSize.width * scale;
  final displayH = imageSize.height * scale;

  // center the displayed image inside widget
  final dx = (widgetSize.width - displayW) / 2;
  final dy = (widgetSize.height - displayH) / 2;

  return Rect.fromLTRB(
    imageRect.left * scale + dx,
    imageRect.top * scale + dy,
    imageRect.right * scale + dx,
    imageRect.bottom * scale + dy,
  );
}












