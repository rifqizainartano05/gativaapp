import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
      final months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Ags", "Sep", "Okt", "Nov", "Des"];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Riwayat Konsumsi', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tren Asupan Natrium',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, fontSize: 16
                  ),
                ),
                Obx(() {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.filterRange.value,
                        dropdownColor: Colors.white,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 20),
                        items: controller.filterRanges.map((val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) controller.filterRange.value = newVal;
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),

            // BESPOKE GLOWING BAR CHART
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Batas Harian Anda', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          Obx(() => Text(
                            '${NumberFormat.decimalPattern('id').format(controller.dailyLimit.value.toInt())} mg / Hari', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.danger)
                          )),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Rata-Rata Asupan Anda', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          Obx(() {
                            double avg = controller.getAverageDailyIntake();
                            return Text(
                              '${NumberFormat.decimalPattern('id').format(avg.toInt())} mg',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: avg > controller.dailyLimit.value ? AppColors.danger : AppColors.safe,
                              ),
                            );
                          }),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  Obx(() {
                    final chartData = controller.getWeeklyChartData();
                    return SizedBox(
                      height: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildChartBar('Sen', chartData[0], context),
                          _buildChartBar('Sel', chartData[1], context),
                          _buildChartBar('Rab', chartData[2], context),
                          _buildChartBar('Kam', chartData[3], context),
                          _buildChartBar('Jum', chartData[4], context),
                          _buildChartBar('Sab', chartData[5], context),
                          _buildChartBar('Min', chartData[6], context),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Consumption Logs Header
            const Text(
              'CATATAN ASUPAN NATRIUM',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary, letterSpacing: 1.0),
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
                      style: TextStyle(color: AppColors.textMuted, fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }

              return ListView.builder(
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
                    densityColor = Colors.blue; // Untuk aktivitas yang mengurangi
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))
                        ]
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 15
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      log.type == 'makanan' ? 'Asupan Makanan (Label Gizi)' : 'Aktivitas Sehat',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.textMuted)),
                                    const SizedBox(width: 8),
                                    Text(
                                      formatSimpleDate(log.timestamp),
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Total sodium count
                          Text(
                            '${log.amount > 0 ? '+' : ''}${NumberFormat.decimalPattern('id').format(log.amount)} mg',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: densityColor),
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
    );
  }

  // Bespoke Glowing Bar Helper
  Widget _buildChartBar(String day, double ratio, BuildContext context) {
    Color barColor = ratio < 0.6
        ? AppColors.safe
        : ratio < 0.9
            ? AppColors.warning
            : AppColors.danger;

    double barHeight = (ratio * 100).clamp(10.0, 100.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (ratio >= 0.9)
          Container(
            width: 14,
            height: 2,
            decoration: BoxDecoration(
              color: barColor,
              boxShadow: [
                BoxShadow(color: barColor, blurRadius: 6, spreadRadius: 2)
              ]
            ),
          ),
        const SizedBox(height: 4),
        Container(
          width: 14,
          height: barHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [barColor.withOpacity(0.2), barColor],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: barColor.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, -2),
              )
            ]
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
