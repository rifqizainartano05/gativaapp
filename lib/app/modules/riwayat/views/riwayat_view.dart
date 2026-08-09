import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/riwayat_controller.dart';
import '../../../widgets/custom_popup.dart';

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Obx(() {
        bool isFromMission = Get.arguments is Map && Get.arguments['isFromMission'] == true;
        bool missionCompleted = controller.isMissionCompleted.value; 
        bool canGoBack = !isFromMission || missionCompleted;

        return PopScope(
          canPop: canGoBack,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (!canGoBack) {
              CustomPopup.showWarning(
                'Perhatian',
                'Harap tunggu data termuat untuk menyelesaikan misi.',
              );
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F6F8),
            body: Column(
              children: [
                // 1. HEADER (Green App Bar)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    bottom: 20,
                    left: 24,
                    right: 24,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: -30,
                        top: -40,
                        child: Icon(
                          Icons.access_time_rounded,
                          size: 150,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (!canGoBack) {
                                CustomPopup.showWarning(
                                  'Perhatian',
                                  'Harap tunggu data termuat untuk menyelesaikan misi.',
                                );
                              } else {
                                Get.back();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
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
                            'Riwayat',
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

                // BODY SCROLLABLE
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. COMBINED SUMMARY & CHART CARD
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // SUMMARY ROW
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Sisa Batas',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Obx(() {
                                        double total = controller.getTotalIntake();
                                        double limit = controller.chartLimit;
                                        double sisa = limit - total;
                                        if (sisa < 0) {
                                          sisa = 0;
                                        }
                                        return Text(
                                          '${NumberFormat.decimalPattern('id').format(sisa)} mg',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.primary,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey.shade200,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Total Asupan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Obx(() {
                                        double total = controller.getTotalIntake();
                                        return Text(
                                          '${NumberFormat.decimalPattern('id').format(total)} mg',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.primary,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(height: 1, color: Colors.grey.shade200),
                              const SizedBox(height: 20),
                              
                              // CHART
                              SizedBox(
                                height: 220,
                                width: double.infinity,
                                child: Obx(() {
                                  final chartData = controller.getChartData();
                                  if (chartData.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "Belum ada data",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    );
                                  }

                                  double maxY = chartData.fold(0.0, (max, point) {
                                    double total = point.amanValue + point.warningValue + point.bahayaValue;
                                    return total > max ? total : max;
                                  });
                                  if (maxY == 0) {
                                    maxY = controller.dailyLimit.value > 0 ? controller.dailyLimit.value : 2000;
                                  } else {
                                    maxY = maxY * 1.2;
                                  }

                                  return LineChart(
                                    LineChartData(
                                      minY: 0,
                                      maxY: maxY,
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: maxY / 4 == 0 ? 1 : maxY / 4,
                                        getDrawingHorizontalLine: (value) => FlLine(
                                          color: Colors.grey.withValues(alpha: 0.2),
                                          strokeWidth: 1,
                                        ),
                                      ),
                                      titlesData: const FlTitlesData(
                                        show: false,
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        if (chartData.any((p) => p.amanValue > 0))
                                          _buildLineChartBar(chartData, (p) => p.amanValue, AppColors.safe),
                                        if (chartData.any((p) => p.warningValue > 0))
                                          _buildLineChartBar(chartData, (p) => p.warningValue, AppColors.warning),
                                        if (chartData.any((p) => p.bahayaValue > 0))
                                          _buildLineChartBar(chartData, (p) => p.bahayaValue, AppColors.danger),
                                      ],
                                      lineTouchData: const LineTouchData(enabled: false),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 24),
                              // Legend
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Obx(() {
                                    final chartData = controller.getChartData();
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (chartData.any((p) => p.amanValue > 0)) ...[
                                          _buildLegendItem(AppColors.safe, 'Aman'),
                                          const SizedBox(width: 16),
                                        ],
                                        if (chartData.any((p) => p.warningValue > 0)) ...[
                                          _buildLegendItem(AppColors.warning, 'Waspada'),
                                          const SizedBox(width: 16),
                                        ],
                                        if (chartData.any((p) => p.bahayaValue > 0)) ...[
                                          _buildLegendItem(AppColors.danger, 'Bahaya'),
                                        ],
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 4. LIST CARD
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'CATATAN ASUPAN NATRIUM',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _showFilterBottomSheet(context, controller),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Filter',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.filter_list, color: AppColors.primary, size: 18),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Dynamic Log List
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

                                return ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: list.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, idx) {
                                    final log = list[idx];

                                    Color densityColor = AppColors.safe;
                                    if (log.type == 'makanan') {
                                      densityColor = log.amount >= 1000
                                          ? AppColors.danger
                                          : log.amount >= 600
                                          ? AppColors.warning
                                          : AppColors.safe;
                                    } else {
                                      densityColor = Colors.blue;
                                    }

                                    return Dismissible(
                                      key: Key(log.id),
                                      direction: DismissDirection.startToEnd,
                                      onDismissed: (direction) {
                                        controller.deleteHistoryLog(log.id);
                                      },
                                      background: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.grey.shade100),
                                        ),
                                        child: Row(
                                          children: [
                                            // Circular Icon
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: densityColor.withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.restaurant_rounded, // fork and spoon
                                                color: densityColor,
                                                size: 20,
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
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    log.type == 'makanan' ? 'Asupan Makanan' : 'Aktivitas Sehat',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    formatSimpleDate(log.timestamp),
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors.textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Total sodium badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: densityColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '${log.amount > 0 ? '+' : ''}${NumberFormat.decimalPattern('id').format(log.amount)} mg',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: densityColor,
                                                ),
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
      }),
    );
  }

  LineChartBarData _buildLineChartBar(List<ChartDataPoint> data, double Function(ChartDataPoint) valueSelector, Color color) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), valueSelector(e.value));
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context, RiwayatController controller) {
    RxString tempOption = controller.filterOption.value.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.only(top: 24, bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.zero,
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.filterOptionsList.length,
                  itemBuilder: (context, index) {
                    final option = controller.filterOptionsList[index];
                    return Obx(() {
                      final isSelected = tempOption.value == option;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top divider for the very first item
                          if (index == 0) Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                            title: Text(
                              option,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: isSelected ? AppColors.primary : Colors.black87,
                              ),
                            ),
                            trailing: Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? AppColors.primary : Colors.grey.shade400,
                            ),
                            onTap: () {
                              if (option == "Atur Tanggal") {
                                if (isSelected) {
                                  tempOption.value = ""; // Deselect
                                } else {
                                  tempOption.value = option;
                                }
                              } else {
                                if (isSelected) {
                                  controller.setFilterOption(""); // Deselect
                                } else {
                                  controller.setFilterOption(option);
                                }
                                Get.back();
                              }
                            },
                          ),
                          if (option == "Atur Tanggal" && isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16.0),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          final DateTime? picked = await showDatePicker(
                                            context: context,
                                            initialDate: controller.customDateRange.value?.start ?? DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime.now(),
                                          );
                                          if (picked != null) {
                                            final end = controller.customDateRange.value?.end ?? picked;
                                            controller.customDateRange.value = DateTimeRange(
                                                start: picked, end: end.isBefore(picked) ? picked : end);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                          color: Colors.transparent,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Dari', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                              const SizedBox(height: 4),
                                              Text(
                                                controller.customDateRange.value != null
                                                    ? "${controller.customDateRange.value!.start.day}/${controller.customDateRange.value!.start.month}/${controller.customDateRange.value!.start.year}"
                                                    : "Pilih",
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.grey.shade300,
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          final DateTime? picked = await showDatePicker(
                                            context: context,
                                            initialDate: controller.customDateRange.value?.end ?? DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime.now(),
                                          );
                                          if (picked != null) {
                                            final start = controller.customDateRange.value?.start ?? picked;
                                            controller.customDateRange.value = DateTimeRange(
                                                start: start.isAfter(picked) ? picked : start, end: picked);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                          color: Colors.transparent,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Sampai', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                              const SizedBox(height: 4),
                                              Text(
                                                controller.customDateRange.value != null
                                                    ? "${controller.customDateRange.value!.end.day}/${controller.customDateRange.value!.end.month}/${controller.customDateRange.value!.end.year}"
                                                    : "Pilih",
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                        ],
                      );
                    });
                  },
                ),
              ),
              Obx(() {
                if (tempOption.value == "Atur Tanggal") {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 24, right: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.setFilterOption(tempOption.value);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Terapkan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ));
      },
    );
  }

}
