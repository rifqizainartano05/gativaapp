import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/home_dokter_controller.dart';
import '../../../routes/app_pages.dart';

class HomeDokterView extends GetView<HomeDokterController> {
  const HomeDokterView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: _buildDashboardTab(context),
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [_buildTopSection(context)]),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    // The wide green box takes up 55% of the screen
    double totalHeight = screenHeight * 0.92;
    double topHeight = screenHeight * 0.60;
    const double pillHeight = 70; // Decreased height to match pill button size
    double stemHeight = totalHeight - topHeight - pillHeight;

    // Ensure stemHeight doesn't become negative on small screens
    if (stemHeight < 40) stemHeight = 40;
    totalHeight = topHeight + stemHeight + pillHeight;

    return SizedBox(
      height: totalHeight + 20, // some padding at the bottom
      child: Stack(
        children: [
          // 1. The custom blue shape background
          ClipPath(
            clipper: SmartHomeShapeClipper(
              topHeight: topHeight,
              stemHeight: stemHeight,
              pillHeight: pillHeight,
            ),
            child: Container(
              height: totalHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF388E3C), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Aesthetic circles and lines
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Icon(
                      Icons.health_and_safety,
                      size: 140,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  // Large Watermark inside Green Box
                  Positioned(
                    bottom: 0,
                    right: -30,
                    child: Icon(
                      Icons.health_and_safety_rounded,
                      size: 200,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 50,
                    child: Container(
                      width: 1,
                      height: 180,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  Positioned(
                    top: 180,
                    left: 38,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 90,
                    child: Container(
                      width: 1,
                      height: 250,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  Positioned(
                    top: 250,
                    left: 70,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),

                  // Greeting Text & Rating
                  Positioned(
                    top: 90,
                    left: 24,
                    right: 24,
                    child: Obx(() {
                      String fullName = controller.dokterName.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selamat Datang,\ndi Gativa",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              children: [
                                DigitalDoctorCard(
                                  fullName: fullName,
                                  strNumber: controller.strNumber.value,
                                  rating: controller.averageRating.value,
                                  isLoading: controller.isLoading.value,
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => Get.toNamed(Routes.DOKTER_PROFILE),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Lihat Profile",
                                        style: TextStyle(
                                          color: Color(0xFF1B5E20),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),

                ],
              ),
            ),
          ),

          // 2. The white button perfectly placed inside the hollow pill area
          Positioned(
            top: topHeight + stemHeight + 4, // border gap
            left: 24 + 4,
            right: 24 + 4,
            height: pillHeight - 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100), // Match the clipper's pill shape perfectly
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(Routes.DOKTER_CHAT),
                      behavior: HitTestBehavior.opaque,
                      child: const Center(
                        child: Text(
                          'Konsultasi',
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 30, color: Colors.grey.shade300),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(Routes.EDUKASI_DOKTER),
                      behavior: HitTestBehavior.opaque,
                      child: const Center(
                        child: Text(
                          'Edukasi',
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SmartHomeShapeClipper extends CustomClipper<Path> {
  final double topHeight;
  final double stemHeight;
  final double pillHeight;

  SmartHomeShapeClipper({
    required this.topHeight,
    required this.stemHeight,
    required this.pillHeight,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();

    double w = size.width;

    double stemWidth = 60;
    double cornerRadius = 40;
    double innerRadius = 20;

    double stemLeft = (w - stemWidth) / 2;
    double stemRight = (w + stemWidth) / 2;

    double pillTop = topHeight + stemHeight; // 350
    double pillBottom = pillTop + pillHeight; // 434
    double pillLeft = 24;
    double pillRight = w - 24;
    double pillRadius = pillHeight / 2; // 42

    path.lineTo(0, topHeight - cornerRadius);
    path.quadraticBezierTo(0, topHeight, cornerRadius, topHeight);

    path.lineTo(stemLeft - innerRadius, topHeight);
    path.quadraticBezierTo(
      stemLeft,
      topHeight,
      stemLeft,
      topHeight + innerRadius,
    );

    path.lineTo(stemLeft, pillTop - innerRadius);
    path.quadraticBezierTo(stemLeft, pillTop, stemLeft - innerRadius, pillTop);

    path.lineTo(pillLeft + pillRadius, pillTop);
    path.arcToPoint(
      Offset(pillLeft + pillRadius, pillBottom),
      radius: Radius.circular(pillRadius),
      clockwise: false,
    );

    path.lineTo(pillRight - pillRadius, pillBottom);
    path.arcToPoint(
      Offset(pillRight - pillRadius, pillTop),
      radius: Radius.circular(pillRadius),
      clockwise: false,
    );

    path.lineTo(stemRight + innerRadius, pillTop);
    path.quadraticBezierTo(
      stemRight,
      pillTop,
      stemRight,
      pillTop - innerRadius,
    );

    path.lineTo(stemRight, topHeight + innerRadius);
    path.quadraticBezierTo(
      stemRight,
      topHeight,
      stemRight + innerRadius,
      topHeight,
    );

    path.lineTo(w - cornerRadius, topHeight);
    path.quadraticBezierTo(w, topHeight, w, topHeight - cornerRadius);

    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DigitalDoctorCard extends StatefulWidget {
  final String fullName;
  final String strNumber;
  final double rating;
  final bool isLoading;

  const DigitalDoctorCard({
    super.key,
    required this.fullName,
    required this.strNumber,
    required this.rating,
    required this.isLoading,
  });

  @override
  State<DigitalDoctorCard> createState() => _DigitalDoctorCardState();
}

class _DigitalDoctorCardState extends State<DigitalDoctorCard> {
  bool _isFront = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFront = !_isFront;
        });
      },
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: _isFront ? 0 : 1),
        duration: const Duration(milliseconds: 600),
        builder: (BuildContext context, double value, Widget? child) {
          bool isBack = value >= 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * pi),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBack(),
                  )
                : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      height: 220, // Increased height
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark Icon
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.health_and_safety_rounded,
              size: 140,
              color: const Color(0xFF388E3C).withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Dr. ${widget.fullName}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  "STR: ${widget.strNumber}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.touch_app, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text("Tap untuk membalik kartu", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      height: 220, // Increased height
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white, // Solid white background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.medical_services_rounded,
              size: 140, // Match watermark size
              color: const Color(0xFF388E3C).withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "GATIVA CARD",
                  style: TextStyle(
                    fontSize: 18, // Slightly larger
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20), // Dark green text
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                if (!widget.isLoading)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.black87, // Dark text
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '/ 5.0',
                        style: TextStyle(
                          color: Colors.black54, // Dark text
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
