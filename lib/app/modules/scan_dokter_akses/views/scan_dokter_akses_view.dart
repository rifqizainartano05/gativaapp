import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/scan_dokter_akses_controller.dart';

class ScanDokterAksesView extends GetView<ScanDokterAksesController> {
  const ScanDokterAksesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Mobile Scanner Camera
          MobileScanner(
            controller: controller.scannerController,
            onDetect: controller.onDetect,
          ),

          // 2. Custom Dark Overlay with a Transparent Hole
          const _ScannerOverlay(),

          // 3. Top App Bar Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  icon: Icons.close_rounded,
                  onTap: controller.goToMain,
                ),
                const Text(
                  "Akses Dokter",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Obx(
                  () => _buildCircleButton(
                    icon: controller.isFlashOn.value
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    onTap: controller.toggleFlash,
                  ),
                ),
              ],
            ),
          ),
          
          // 4. Instructions
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Arahkan kamera ke Barcode Profil Tenaga Kesehatan Anda",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        
        // Define the transparent hole size
        final double holeSize = width * 0.7;
        final double holeX = (width - holeSize) / 2;
        final double holeY = (height - holeSize) / 2.5;

        return Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.8),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: holeX,
                    top: holeY,
                    width: holeSize,
                    height: holeSize,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scanner Frame / Borders
            Positioned(
              left: holeX - 2,
              top: holeY - 2,
              width: holeSize + 4,
              height: holeSize + 4,
              child: _buildScannerBorders(),
            ),
            
            // Watermark Icon
            Positioned(
              left: holeX,
              top: holeY,
              width: holeSize,
              height: holeSize,
              child: Center(
                child: Icon(
                  Icons.medical_information_rounded,
                  size: 100,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScannerBorders() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCorner(top: true, left: true),
            _buildCorner(top: true, left: false),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCorner(top: false, left: true),
            _buildCorner(top: false, left: false),
          ],
        ),
      ],
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Colors.greenAccent, width: 4) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Colors.greenAccent, width: 4) : BorderSide.none,
          left: left ? const BorderSide(color: Colors.greenAccent, width: 4) : BorderSide.none,
          right: !left ? const BorderSide(color: Colors.greenAccent, width: 4) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(24) : Radius.zero,
          topRight: top && !left ? const Radius.circular(24) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(24) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(24) : Radius.zero,
        ),
      ),
    );
  }
}
