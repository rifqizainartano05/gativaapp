import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/riwayat_controller.dart';

// Inlined AppColors to prevent missing import errors
class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const textSecondary = Colors.grey;
  static const textMuted = Colors.black54;
  static const safe = Colors.green;
  static const warning = Colors.orange;
  static const danger = Colors.red;
}

class RiwayatView extends StatelessWidget {
  const RiwayatView({super.key});

  @override
  Widget build(BuildContext context) {
    final RiwayatController controller = Get.put(RiwayatController());

    String formatSimpleDate(DateTime date) {
      final months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "Mei",
        "Jun",
        "Jul",
        "Ags",
        "Sep",
        "Okt",
        "Nov",
        "Des",
      ];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: Column(
          children: [
            // Custom Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 30,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.history_rounded,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Riwayat Konsumsi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BESPOKE GLOWING BAR CHART -> FL CHART LINE CHART
                    Container(
                      margin: const EdgeInsets.only(top: 24), // Added margin top to separate from green box
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tren Asupan Natrium',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                              ),
                              // Dropdown removed
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Batas Harian Anda',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      '${NumberFormat.decimalPattern('id').format(controller.dailyLimit.value.toInt())} mg / Hari',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Rata-Rata Asupan Anda',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  Obx(() {
                                    double avg = controller
                                        .getAverageDailyIntake();
                                    return Text(
                                      '${NumberFormat.decimalPattern('id').format(avg.toInt())} mg',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: avg > controller.dailyLimit.value
                                            ? AppColors.danger
                                            : AppColors.safe,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),


                          Obx(() {
                            final radialData = controller.getRadialData();
                            
                            double dailyLimit = controller.dailyLimit.value > 0 ? controller.dailyLimit.value : 2000.0;
                            
                            // Hitung batas bulanan dan tahunan secara otomatis
                            final now = DateTime.now();
                            int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
                            int daysInYear = (now.year % 4 == 0 && now.year % 100 != 0) || (now.year % 400 == 0) ? 366 : 365;

                            double harianPercent = radialData['harian']! / dailyLimit;
                            double bulananPercent = radialData['bulanan']! / (dailyLimit * daysInMonth);
                            double tahunanPercent = radialData['tahunan']! / (dailyLimit * daysInYear);

                            return Column(
                              children: [
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 220,
                                  width: 220,
                                  child: CustomPaint(
                                    size: const Size(220, 220),
                                    painter: RadialProgressPainter(
                                      harianPercent: harianPercent,
                                      bulananPercent: bulananPercent,
                                      tahunanPercent: tahunanPercent,
                                      harianColor: const Color(0xFFff7285),
                                      bulananColor: const Color(0xFF00c689), // Greenish for month like in image
                                      tahunanColor: const Color(0xFF00a8cc), // Cyan/Blue for year like in image
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Legend
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildLegendItem(const Color(0xFFff7285), 'Harian'),
                                    const SizedBox(width: 16),
                                    _buildLegendItem(const Color(0xFF00c689), 'Bulanan'),
                                    const SizedBox(width: 16),
                                    _buildLegendItem(const Color(0xFF00a8cc), 'Tahunan'),
                                  ],
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Consumption Logs Header
                          const Text(
                            'CATATAN ASUPAN NATRIUM',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Dynamic Log List with Swipe to Delete
                          Obx(() {
                      final list = controller.filteredLogs;
                      if (list.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Text(
                              'Belum ada catatan asupan untuk periode ini.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        itemBuilder: (context, idx) {
                          final log = list[idx];

                          Color densityColor = AppColors.safe;
                          if (log.type == 'makanan') {
                            densityColor = log.amount >= 800
                                ? AppColors.danger
                                : log.amount >= 400
                                ? AppColors.warning
                                : AppColors.safe;
                          } else {
                            densityColor =
                                Colors.blue; // Untuk aktivitas yang mengurangi
                          }

                          return Dismissible(
                            key: Key(log.id),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (direction) {
                              controller.deleteHistoryLog(log.id);
                            },
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: const Icon(
                                Icons.delete_sweep_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.01),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Left Density Bar
                                  Container(
                                    width: 4,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: densityColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          log.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                log.type == 'makanan'
                                                    ? 'Asupan Makanan (Label Gizi)'
                                                    : 'Aktivitas Sehat',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textSecondary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              formatSimpleDate(log.timestamp),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Total sodium count
                                  Text(
                                    '${log.amount > 0 ? '+' : ''}${NumberFormat.decimalPattern('id').format(log.amount)} mg',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: densityColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed manual _buildChartBar

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class RadialProgressPainter extends CustomPainter {
  final double harianPercent;
  final double bulananPercent;
  final double tahunanPercent;
  final Color harianColor;
  final Color bulananColor;
  final Color tahunanColor;

  RadialProgressPainter({
    required this.harianPercent,
    required this.bulananPercent,
    required this.tahunanPercent,
    required this.harianColor,
    required this.bulananColor,
    required this.tahunanColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 18.0;
    double spacing = 8.0;
    
    Paint bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    Paint fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    
    // Outer (Tahunan - Lingkaran Ketiga)
    double radius3 = (size.width / 2) - (strokeWidth / 2);
    _drawArc(canvas, center, radius3, tahunanPercent, bgPaint, fgPaint..color = tahunanColor);
    
    // Middle (Bulanan - Lingkaran Kedua)
    double radius2 = radius3 - strokeWidth - spacing;
    _drawArc(canvas, center, radius2, bulananPercent, bgPaint, fgPaint..color = bulananColor);

    // Inner (Harian - Lingkaran Pertama)
    double radius1 = radius2 - strokeWidth - spacing;
    _drawArc(canvas, center, radius1, harianPercent, bgPaint, fgPaint..color = harianColor);
  }

  void _drawArc(Canvas canvas, Offset center, double radius, double percent, Paint bgPaint, Paint fgPaint) {
    Rect rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -1.5708; // -pi/2 (top)
    double sweepAngle = 6.2832 * percent.clamp(0.0, 1.0);
    
    // Draw background full circle
    canvas.drawArc(rect, startAngle, 6.2832, false, bgPaint);
    
    // Draw progress arc
    if (percent > 0) {
      canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadialProgressPainter oldDelegate) {
    return oldDelegate.harianPercent != harianPercent ||
        oldDelegate.bulananPercent != bulananPercent ||
        oldDelegate.tahunanPercent != tahunanPercent;
  }
}
