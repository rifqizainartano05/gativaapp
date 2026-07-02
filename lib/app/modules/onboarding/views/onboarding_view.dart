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
        body: Stack(
          children: [
            // Latar Belakang Watermark Animasi
            Positioned(
              top: -50,
              right: -50,
              child: Obx(() {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  transform: Matrix4.translationValues(
                    0,
                    controller.currentPage.value * 30.0,
                    0,
                  ),
                  child: Icon(
                    Icons.health_and_safety_rounded,
                    size: 300,
                    color: const Color(0xFF2E7D32).withOpacity(0.05),
                  ),
                );
              }),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Tombol Skip
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0, top: 16.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: controller.skip,
                        child: const Text(
                          'Lewati',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.onPageChanged,
                      itemCount: controller.onboardingPages.length,
                      itemBuilder: (context, index) {
                        final page = controller.onboardingPages[index];
                        return Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2E7D32,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  page['icon'] as IconData,
                                  size: 100,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(height: 60),
                              Text(
                                page['title'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                page['description'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Indikator Titik
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.onboardingPages.length,
                        (index) => Obx(() {
                          bool isCurrent =
                              controller.currentPage.value == index;
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
                  ),

                  // Tombol Next/Mulai
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFF2E7D32).withOpacity(0.5),
                        ),
                        onPressed: controller.nextPage,
                        child: Obx(
                          () => Text(
                            controller.currentPage.value ==
                                    controller.onboardingPages.length - 1
                                ? 'Mulai Sekarang'
                                : 'Selanjutnya',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
