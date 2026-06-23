import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller agar onInit berjalan
    Get.put(SplashController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF2E7D32),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF2E7D32),
        body: Center(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.5, end: 1.0),
            duration: const Duration(seconds: 2),
            curve: Curves.elasticOut,
            builder: (context, double value, child) {
              double opacityValue = (value - 0.5) * 2;
              if (opacityValue < 0) opacityValue = 0;
              if (opacityValue > 1) opacityValue = 1;

              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: opacityValue,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.monitor_heart_rounded, size: 120, color: Colors.white.withOpacity(0.2)),
                          const Icon(Icons.health_and_safety_rounded, size: 80, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'GARDA',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kawal Kesehatan Bersama',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
