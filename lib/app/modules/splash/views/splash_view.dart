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

    return Obx(() => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: controller.isNavWhite.value ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: controller.isNavWhite.value ? Colors.white : const Color(0xFF2E7D32),
        systemNavigationBarIconBrightness: controller.isNavWhite.value ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF2E7D32),
        body: Stack(
          alignment: Alignment.center,
          children: [
            // Konten Logo & Loading (di atas lingkaran putih)
            Center(
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(seconds: 1),
                curve: Curves.elasticOut,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Obx(() => Stack(
                      alignment: Alignment.center,
                      children: [
                        // Lingkaran Loading (0-4 detik) atau Ripple Effect (4-6 detik)
                        if (!controller.isRippleStarted.value)
                          const SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          )
                        else
                          const _RippleBackground(),

                        // Logo Statis yang mulai berdenyut
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          transform: Matrix4.identity()
                            ..scale(controller.isRippleStarted.value ? 1.05 : 1.0),
                          transformAlignment: Alignment.center,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: controller.isRippleStarted.value
                                ? [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    )
                                  ]
                                : [],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    )),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class _RippleBackground extends StatefulWidget {
  const _RippleBackground();
  @override
  __RippleBackgroundState createState() => __RippleBackgroundState();
}

class __RippleBackgroundState extends State<_RippleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildRipple(double radius, double opacity) {
    return OverflowBox(
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity.clamp(0.0, 1.0)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Gunakan Curve easeInOut agar merambat pelan, mulus, dan konstan tanpa lonjakan mendadak
        final curve = Curves.easeInOut.transform(_controller.value);
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outermost (paling transparan, diameter maksimal ~3000 sangat cukup untuk menutupi layar)
            _buildRipple(120 + (3000 * curve), 0.2),
            // Middle
            _buildRipple(120 + (2500 * curve), 0.5),
            // Innermost (putih solid, diameter maksimal ~2000 untuk menutup semua sisa warna hijau)
            _buildRipple(120 + (2000 * curve), 1.0),
          ],
        );
      },
    );
  }
}
