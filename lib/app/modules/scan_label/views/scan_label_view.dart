import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../controllers/scan_label_controller.dart';

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

class ScanLabelView extends GetView<ScanLabelController> {
  const ScanLabelView({super.key});

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
      child: Obx(() {
        bool canGoBack = !controller.isFromMission.value;

        return PopScope(
          canPop: canGoBack,
          onPopInvoked: (didPop) {
            if (didPop) return;
            if (!canGoBack) {
              Get.snackbar(
                'Perhatian',
                'Harap ambil gambar produk untuk menyelesaikan misi.',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            // AppBar dihapus agar tidak menahan pewarnaan SystemUiOverlayStyle
        body: AnnotatedRegion<SystemUiOverlayStyle>(
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



                // 2.5 Flash Toggle Button
                Positioned(
                  top: 50,
                  right: 20,
                  child: Obx(() => Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        controller.isFlashOn.value ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => controller.toggleFlash(),
                    ),
                  )),
                ),

                // 3. Info Text (Tanpa Tombol)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 90),
                    decoration: const BoxDecoration(
                      color: Colors.white,
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
                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Arahkan kamera ke tabel informasi nilai gizi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sistem akan memindai natrium secara otomatis tanpa perlu ditekan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        
                        // HUD: Mencari Natrium
                        Obx(() {
                          if (controller.hasResult.value) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 30),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Berhasil mendeteksi: ${controller.scannedSodiumPerServing.value.toInt()} mg',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (controller.isScanning.value) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary, width: 2),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SpinKitPulse(
                                      color: AppColors.primary,
                                      size: 30.0,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: const Text(
                                        'Sedang mendeteksi',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                ),


              ],
            ),
          ), // closes AnnotatedRegion
        ), // closes Scaffold
      ); // closes PopScope
    }), // closes Obx
    ); // closes outer AnnotatedRegion
  }
}

