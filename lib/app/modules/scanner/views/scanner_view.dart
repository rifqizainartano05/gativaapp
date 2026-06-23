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
        // JIKA ADA HASIL (Layar Struk Full Putih)
        if (controller.hasResult.value) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            child: Container(
              color: Colors.white, 
              height: double.infinity,
              width: double.infinity,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan teks di awal
                    children: [
                      const Text(
                        "Label Gizi Pindaian",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      
                      // Kotak timer hitung mundur
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(color: Colors.orange.shade200),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Halaman ini akan ditutup otomatis dalam ${controller.countdown.value} detik",
                          style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // KOTAK STRUK DIGITAL (Digabung dengan Total Natrium)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.scannedFoodName.value,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    controller.scannedServingSize.value,
                                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            const DashedLine(),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Natrium per Sajian', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                Text(
                                  '${controller.scannedSodiumPerServing.value.toInt()} mg',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Sajian per Bungkus', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                Text(
                                  '${controller.scannedServingsPerPack.value.toInt()} sajian',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const DashedLine(), // Garis pemisah untuk Total Natrium
                            const SizedBox(height: 20),
                            
                            // TOTAL NATRIUM DIGABUNG DI DALAM KOTAK
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TOTAL NATRIUM:',
                                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 14),
                                ),
                                Text(
                                  '${controller.totalCalculatedSodium.toInt()} mg',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: controller.totalCalculatedSodium >= 1000
                                        ? AppColors.danger
                                        : controller.totalCalculatedSodium >= 600
                                            ? AppColors.warning
                                            : AppColors.safe,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Calculator Converter (Di luar Struk atau tetap di bawahnya)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Porsi Konsumsi Anda:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  '${controller.servingsMultiplier.value.toStringAsFixed(1)} Bungkus',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text('0.5x', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                Expanded(
                                  child: Slider(
                                    value: controller.servingsMultiplier.value,
                                    min: 0.5,
                                    max: 3.0,
                                    divisions: 5,
                                    label: '${controller.servingsMultiplier.value}x',
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      controller.servingsMultiplier.value = val;
                                    },
                                  ),
                                ),
                                const Text('3x', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Actions
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.logScannedFood();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: controller.totalCalculatedSodium >= 1000
                                ? AppColors.danger
                                : AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('LIHAT DETAIL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => controller.resetScan(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Tutup Manual', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

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
                  bool cameraActive = controller.isCameraInitialized.value && controller.isCameraSupported.value;
                  
                  if (cameraActive && controller.cameraController != null && controller.cameraController!.value.isInitialized) {
                    if (!controller.isCameraActive.value) {
                      return Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 64),
                        ),
                      );
                    }
                    final size = MediaQuery.of(context).size;
                    var scale = size.aspectRatio * controller.cameraController!.value.aspectRatio;
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

              // 2. Full Screen Loading Overlay Dihapus dari sini dan dipindah ke paling bawah Stack

              // Tombol Toggle Kamera Dihapus

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
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Arahkan kamera ke tabel informasi nilai gizi pada kemasan makanan Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (controller.isScanning.value || !controller.isCameraActive.value)
                              ? null
                              : () => controller.performScan(simulate: true),
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 28, color: Colors.white),
                          label: const Text(
                            'AMBIL GAMBAR & DETEKSI', 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
                            SpinKitPulse(color: AppColors.primary, size: 80.0),
                            SizedBox(height: 24),
                            Text(
                              'Menganalisis Gizi Anda...',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                            )
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
