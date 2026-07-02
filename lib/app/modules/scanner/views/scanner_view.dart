import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../controllers/scanner_controller.dart';

class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const textSecondary = Colors.grey;
  static const textPrimary = Colors.black87;
  static const textMuted = Colors.black54;
  static const safe = Colors.green;
  static const warning = Colors.orange;
  static const danger = Colors.red;
  static const glassBorder = Color(0xFFE0E0E0);
  static const scannerBox = Colors.white;
}

class DashedLine extends StatelessWidget {
  const DashedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.black26),
              ),
            );
          }),
        );
      },
    );
  }
}

class ScannerView extends GetView<ScannerController> {
  const ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        // AppBar dihapus agar tidak menahan pewarnaan SystemUiOverlayStyle
        body: Obx(() {
          // Layar Kamera Aktif / Siap Scan
          // JIKA TIDAK ADA HASIL (Layar Kamera Aktif / Siap Scan)
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            child: Stack(
              children: [
                // 1. Full Screen Camera Layer
                Positioned.fill(
                  child: Obx(() {
                    bool cameraActive =
                        controller.isCameraInitialized.value &&
                        controller.isCameraSupported.value;

                    if (cameraActive &&
                        controller.cameraController != null &&
                        controller.cameraController!.value.isInitialized) {
                      if (!controller.isCameraActive.value) {
                        return Container(
                          color: Colors.black,
                          child: const Center(
                            child: Icon(
                              Icons.videocam_off_rounded,
                              color: Colors.white54,
                              size: 64,
                            ),
                          ),
                        );
                      }
                      final size = MediaQuery.of(context).size;
                      var scale =
                          size.aspectRatio *
                          controller.cameraController!.value.aspectRatio;
                      if (scale < 1) scale = 1 / scale;

                      return Transform.scale(
                        scale: scale,
                        child: Center(
                          child: CameraPreview(controller.cameraController!),
                        ),
                      );
                    } else {
                      return Container(color: const Color(0xFFF8F9FA));
                    }
                  }),
                ),

                // 2. Scanner Overlay (Dimmed background with cutout)
                Positioned.fill(
                  child: IgnorePointer(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Make the box nice and proportional (e.g. for nutrition facts, a rectangle)
                        final boxWidth = constraints.maxWidth * 0.75;
                        final boxHeight = boxWidth * 1.3;
                        final scanWindow = Rect.fromCenter(
                          center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2 - 80),
                          width: boxWidth,
                          height: boxHeight,
                        );
                        return CustomPaint(
                          painter: ScannerOverlayPainter(scanWindow: scanWindow),
                        );
                      },
                    ),
                  ),
                ),

                // 3. Tombol Ambil Gambar
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 90),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.zero,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Arahkan kamera ke tabel informasi nilai gizi pada kemasan makanan Anda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                (controller.isScanning.value ||
                                    !controller.isCameraActive.value)
                                ? null
                                : () => controller.performScan(simulate: true),
                            icon: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 28,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'AMBIL GAMBAR & DETEKSI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Full Screen Loading Overlay (Di atas semua elemen)
                Positioned.fill(
                  child: Obx(() {
                    if (controller.isScanning.value) {
                      return Container(
                        color: Colors.black.withOpacity(0.7),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SpinKitPulse(
                                color: AppColors.primary,
                                size: 80.0,
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Menganalisis Gizi Anda...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double borderRadius;

  ScannerOverlayPainter({required this.scanWindow, this.borderRadius = 16.0});

  @override
  void paint(Canvas canvas, Size size) {
    // Dimmed background to make it not too bright
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.65);
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Transparent cutout window in the middle
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanWindow, Radius.circular(borderRadius)));
    
    // Combine paths using difference to create a hole
    final path = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    canvas.drawPath(path, backgroundPaint);

    // Beautiful corner borders for the scanner box
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    
    final double cornerLength = 40.0;
    
    // Top-left
    canvas.drawPath(Path()
      ..moveTo(scanWindow.left, scanWindow.top + cornerLength)
      ..lineTo(scanWindow.left, scanWindow.top + borderRadius)
      ..arcToPoint(Offset(scanWindow.left + borderRadius, scanWindow.top), radius: Radius.circular(borderRadius))
      ..lineTo(scanWindow.left + cornerLength, scanWindow.top), borderPaint);
      
    // Top-right
    canvas.drawPath(Path()
      ..moveTo(scanWindow.right - cornerLength, scanWindow.top)
      ..lineTo(scanWindow.right - borderRadius, scanWindow.top)
      ..arcToPoint(Offset(scanWindow.right, scanWindow.top + borderRadius), radius: Radius.circular(borderRadius))
      ..lineTo(scanWindow.right, scanWindow.top + cornerLength), borderPaint);
      
    // Bottom-left
    canvas.drawPath(Path()
      ..moveTo(scanWindow.left, scanWindow.bottom - cornerLength)
      ..lineTo(scanWindow.left, scanWindow.bottom - borderRadius)
      ..arcToPoint(Offset(scanWindow.left + borderRadius, scanWindow.bottom), radius: Radius.circular(borderRadius), clockwise: false)
      ..lineTo(scanWindow.left + cornerLength, scanWindow.bottom), borderPaint);

    // Bottom-right
    canvas.drawPath(Path()
      ..moveTo(scanWindow.right - cornerLength, scanWindow.bottom)
      ..lineTo(scanWindow.right - borderRadius, scanWindow.bottom)
      ..arcToPoint(Offset(scanWindow.right, scanWindow.bottom - borderRadius), radius: Radius.circular(borderRadius), clockwise: false)
      ..lineTo(scanWindow.right, scanWindow.bottom - cornerLength), borderPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow || oldDelegate.borderRadius != borderRadius;
  }
}
