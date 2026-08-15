import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';
import '../../notifikasi/controllers/notifikasi_controller.dart';

import 'package:flutter/services.dart';

// Inlined AppColors
class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const primaryGlow = Color(0x332E7D32);
  static const textSecondary = Colors.grey;
  static const textPrimary = Colors.black87;
  static const textMuted = Colors.black54;
  static const safe = Colors.green;
  static const warning = Colors.orange;
  static const danger = Colors.red;
  static const glassBorder = Color(0xFFE0E0E0);
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: Column(
          children: [
            // Top Header Box (Green Box that wraps Welcome and Ring)
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 30,
              ),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                children: [
                  // Welcome Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              'Halo, ${controller.userName.value}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mari pantau batas garam Anda hari ini.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Get.toNamed('/notifikasi');
                              },
                            ),
                            GetX<NotifikasiController>(
                              init: NotifikasiController(),
                              builder: (notifCtrl) {
                                if (notifCtrl.unreadCount > 0) {
                                  return Positioned(
                                    right: 12,
                                    top: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${notifCtrl.unreadCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Daily Limit Ring (Radial Indicator)
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'KONSUMSI ASUPAN',
                            style: TextStyle(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Obx(() {
                            double ratio = controller.usageRatio;
                            double consumed =
                                controller.totalConsumedToday.value;
                            Color statusColor =
                                controller.intakeStatus == 'Aman'
                                ? AppColors.safe
                                : controller.intakeStatus == 'Waspada'
                                ? AppColors.warning
                                : AppColors.danger;

                            return Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Background Ring Arc
                                SizedBox(
                                  width: 220,
                                  height: 220,
                                  child: CustomPaint(
                                    painter: RingPainter(
                                      ratio: ratio,
                                      activeColor: statusColor,
                                      backgroundColor: Colors.grey.shade100,
                                      strokeWidth: 20,
                                    ),
                                  ),
                                ),
                                // Content in center
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Asupan',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      NumberFormat.decimalPattern('id')
                                          .format(consumed.toInt()),
                                      style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '/ ${NumberFormat.decimalPattern('id').format(controller.limit.toInt())} mg',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                                // Indicator overlay at bottom gap
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      controller.intakeStatus,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 24),
                          // Summary Rows
                          Obx(() {
                            Color statusColor =
                                controller.intakeStatus == 'Aman'
                                ? AppColors.safe
                                : controller.intakeStatus == 'Waspada'
                                ? AppColors.warning
                                : AppColors.danger;
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Sisa Asupan',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${NumberFormat.decimalPattern('id').format(controller.remainingQuota.toInt())} mg',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32, top: 20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Menu Box / Grid Fitur
                      const Text(
                        'MENU UTAMA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildGridItem(
                                  icon: Icons.qr_code_scanner_rounded,
                                  title: 'Lensa Pintar',
                                  subtitle: 'Pindai Makanan',
                                  isGreen: true,
                                  onTap: () => Get.toNamed(Routes.LENSA_PINTAR),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildGridItem(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  title: 'Chat Dokter',
                                  subtitle: 'Chat',
                                  isGreen: false,
                                  onTap: () => Get.toNamed(Routes.CHAT),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGridItem(
                                  icon: Icons.history_rounded,
                                  title: 'Riwayat',
                                  subtitle: 'Catatan Medis',
                                  isGreen: false,
                                  onTap: () => Get.toNamed(Routes.RIWAYAT),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildGridItem(
                                  icon: Icons.menu_book_rounded,
                                  title: 'Edukasi',
                                  subtitle: 'Artikel & Info',
                                  isGreen: true,
                                  onTap: () => Get.toNamed('/edukasi'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGreen,
    required VoidCallback onTap,
  }) {
    Color bgColor = isGreen ? AppColors.primary : Colors.white;
    Color iconBgColor = isGreen ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.1);
    Color iconColor = isGreen ? Colors.white : AppColors.primary;
    Color titleColor = isGreen ? Colors.white : AppColors.textPrimary;
    Color subtitleColor = isGreen ? Colors.white.withOpacity(0.8) : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double ratio;
  final Color activeColor;
  final Color backgroundColor;
  final double strokeWidth;

  RingPainter({
    required this.ratio,
    required this.activeColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Paint activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Start at 135 degrees, sweep 270 degrees for the gap at bottom
    double startAngle = 135 * (math.pi / 180);
    double sweepAngle = 270 * (math.pi / 180);
    
    Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - strokeWidth / 2,
    );

    // Draw background arc
    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);
    
    // Draw active arc
    double safeRatio = ratio > 1.0 ? 1.0 : ratio;
    double activeSweep = sweepAngle * safeRatio;
    canvas.drawArc(rect, startAngle, activeSweep, false, activePaint);

    // Draw dashed tick marks
    Paint tickPaint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
      
    int totalTicks = 24;
    double tickLength = 6;
    double innerRadius = (size.width / 2) - strokeWidth - 10;
    
    for (int i = 0; i <= totalTicks; i++) {
      double angle = startAngle + (sweepAngle * (i / totalTicks));
      Offset startPoint = Offset(
        size.width / 2 + innerRadius * math.cos(angle),
        size.height / 2 + innerRadius * math.sin(angle),
      );
      Offset endPoint = Offset(
        size.width / 2 + (innerRadius - tickLength) * math.cos(angle),
        size.height / 2 + (innerRadius - tickLength) * math.sin(angle),
      );
      canvas.drawLine(startPoint, endPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) {
    return oldDelegate.ratio != ratio || 
           oldDelegate.activeColor != activeColor;
  }
}
