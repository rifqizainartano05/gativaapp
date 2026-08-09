import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/gabung_grup_anggota_controller.dart';

class GabungGrupAnggotaView extends GetView<GabungGrupAnggotaController> {
  const GabungGrupAnggotaView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          return AnimatedBuilder(
            animation: tabController,
            builder: (context, child) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness:
                      tabController.index == 0 ? Brightness.light : Brightness.dark,
                  systemNavigationBarColor: Colors.white,
                  systemNavigationBarIconBrightness: Brightness.dark,
                ),
                child: child!,
              );
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildScannerTab(context),
                  _buildManualInputTab(context),
                ],
              ),
              bottomNavigationBar: SafeArea(
                child: Container(
                  color: Colors.white,
                  child: const TabBar(
                    indicatorColor: Colors.green,
                    labelColor: Colors.green,
                    unselectedLabelColor: Colors.grey,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(icon: Icon(Icons.qr_code_scanner), text: "Scan Anggota"),
                      Tab(icon: Icon(Icons.keyboard), text: "Kode Akses"),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScannerTab(BuildContext context) {
    return Stack(
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
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Get.back(),
              ),
              const Text(
                "Scan Anggota",
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

        // 4. Bottom Information Panel
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Arahkan ke Barcode",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Pindai barcode undangan untuk bergabung ke grup.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualInputTab(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Kode Akses",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "Masukkan Kode Akses",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Masukkan 8 digit kode akses untuk bergabung ke grup.",
            style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: controller.accessCodeController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 8,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4.0,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              counterText: "",
              hintText: "XXXXXXXX",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.validateAccessCode(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                "Gabung",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _ScannerOverlay extends StatefulWidget {
  const _ScannerOverlay();

  @override
  State<_ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<_ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7; // Square again, not lonjong

        return Stack(
          children: [
            // Gelap di luar kotak (Dihapus sesuai permintaan)

            // Container untuk Watermark dan Laser
            Center(
              child: SizedBox(
                width: scanAreaSize,
                height: scanAreaSize,
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.qr_code_rounded,
                        size: 150,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Positioned(
                          top: _animationController.value * (scanAreaSize - 4),
                          left: 0,
                          right: 0,
                          child: child!,
                        );
                      },
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5), // Laser tipis
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final double borderRadius;
  final Color overlayColor;

  _ScannerOverlayPainter({
    required this.scanAreaSize,
    required this.borderRadius,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, Radius.circular(borderRadius)));

    final overlayPath = Path.combine(PathOperation.difference, path, holePath);
    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanAreaSize != scanAreaSize ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.overlayColor != overlayColor;
  }
}
