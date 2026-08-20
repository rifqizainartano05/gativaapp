import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // --- Dekorasi Latar Belakang (Solid & Transparan Animasi) ---
              Obx(() {
                final pageData = controller.onboardingPages[controller.currentPage.value];
                final colorTop = (pageData['color_top'] as Color?) ?? const Color(0xFF6C63FF);
                final colorBottom = (pageData['color_bottom'] as Color?) ?? const Color(0xFFFF6584);

                return Stack(
                  children: [
                    // 1. Kiri atas besar (Warna Top)
                    Positioned(
                      top: 20,
                      left: -40,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: colorTop,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // 2. Kiri atas kecil (Warna Top)
                    Positioned(
                      top: 130,
                      left: 80,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorTop,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // 3. Kanan bawah besar (Warna Bottom)
                    Positioned(
                      bottom: Get.height * 0.35,
                      right: -40,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: colorBottom,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // 4. Kanan bawah kecil (Warna Bottom)
                    Positioned(
                      bottom: Get.height * 0.50, // Naikkan agar menjauh dari lingkaran besar
                      right: 45, // Geser ke kiri
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colorBottom,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // 5. Kiri tengah kecil (Warna Bottom)
                    Positioned(
                      bottom: Get.height * 0.40,
                      left: 50,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colorBottom,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                );
              }),
              
              // --- Konten Utama ---
              Column(
                children: [
                  // 1. Area PageView
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.onPageChanged,
                      itemCount: controller.onboardingPages.length,
                      itemBuilder: (context, index) {
                        final page = controller.onboardingPages[index];
                        return Column(
                          children: [
                            // Ilustrasi
                            Expanded(
                              flex: 6,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 120.0), // Mendorong gambar dan lingkaran lebih ke bawah lagi
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Lingkaran luar (sangat transparan)
                                    Obx(() {
                                      final pageData = controller.onboardingPages[controller.currentPage.value];
                                      final colorTop = (pageData['color_top'] as Color?) ?? const Color(0xFF6C63FF);
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 500),
                                        width: 320,
                                        height: 320,
                                        decoration: BoxDecoration(
                                          color: colorTop.withOpacity(0.04),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }),
                                    // Lingkaran dalam (agak transparan, tidak terlalu transparan dibanding yang luar)
                                    Obx(() {
                                      final pageData = controller.onboardingPages[controller.currentPage.value];
                                      final colorTop = (pageData['color_top'] as Color?) ?? const Color(0xFF6C63FF);
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 500),
                                        width: 240,
                                        height: 240,
                                        decoration: BoxDecoration(
                                          color: colorTop.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }),
                                    // Gambar (Ukurannya disesuaikan agar pas di dalam lingkaran tanpa terlihat terlalu kecil)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        page['icon'] as String,
                                        width: 210, // Diperbesar dari 160, tapi tetap lebih kecil dari lingkaran (240)
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Teks (Judul & Deskripsi)
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  const SizedBox(height: 50), // Jarak dikembalikan agar teks tetap di bawah
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                    child: Text(
                                      page['title'] as String,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 64.0), // Diperbesar agar teks lebih ke bawah
                                    child: Text(
                                      page['description'] as String,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  
                  // 2. Bilah Navigasi Bawah (Dots & Next Button)
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 40.0, top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dots (Di sebelah kiri)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(
                            controller.onboardingPages.length,
                            (index) => Obx(() {
                              bool isCurrent = controller.currentPage.value == index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 8,
                                width: isCurrent ? 24 : 8,
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? const Color(0xFF2E7D32)
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                        
                        // Tombol Next / Mulai (Tombol Teks Lebih Kecil)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          onPressed: controller.nextPage,
                          child: Obx(
                            () => Text(
                              controller.currentPage.value == controller.onboardingPages.length - 1
                                  ? 'Mulai'
                                  : 'Lanjut',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Tombol Skip (Kanan Atas) Diletakkan paling akhir agar berada di atas (clickable)
              Positioned(
                top: 16,
                right: 16,
                child: TextButton(
                  onPressed: controller.skip,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
