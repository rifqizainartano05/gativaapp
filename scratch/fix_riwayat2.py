import re
import os

def process_file(path, is_anggota=False):
    # Try reading as utf-8, fallback to utf-16le
    try:
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        with open(path, 'r', encoding='utf-16le') as f:
            content = f.read()

    # 1. Dropdown and remove Tren Asupan Natrium
    old_tren = """                          Row(
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
                          ),"""
    new_dropdown = """                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F6F8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Obx(() => DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.filterOption.value.isEmpty ? (controller.filterOptionsList.isNotEmpty ? controller.filterOptionsList.first : null) : controller.filterOption.value,
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 20),
                                    items: controller.filterOptionsList.map((val) {
                                      return DropdownMenuItem<String>(
                                        value: val,
                                        child: Text(val),
                                      );
                                    }).toList(),
                                    onChanged: (newVal) {
                                      if (newVal != null) controller.setFilterOption(newVal);
                                    },
                                  ),
                                )),
                              ),
                            ],
                          ),"""
    
    if old_tren in content:
        content = content.replace(old_tren, new_dropdown)
    else:
        print(f"Warning: Could not find old_tren in {path}")

    # 2. Replace RadialProgressPainter block with LineChart
    start_str = "                          Obx(() {"
    end_str = "                          }),\n                        ],\n                      ),\n                    ),\n                    const SizedBox(height: 32),\n\n                    Container("
    
    if start_str in content and end_str in content:
        target_marker = "RadialProgressPainter("
        obx_starts = [m.start() for m in re.finditer(re.escape(start_str), content)]
        
        for start_idx in obx_starts:
            end_idx = content.find(end_str, start_idx)
            if end_idx != -1:
                block = content[start_idx:end_idx + len("                          }),")]
                if target_marker in block:
                    new_chart = """                          Obx(() {
                            final dataPoints = controller.getChartData();
                            
                            return Column(
                              children: [
                                Container(
                                  height: 250,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E2C),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
                                  child: LineChart(
                                    LineChartData(
                                      clipData: const FlClipData.all(),
                                      gridData: const FlGridData(show: false),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 22,
                                            getTitlesWidget: (value, meta) {
                                              int index = value.toInt();
                                              if (index >= 0 && index < dataPoints.length) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Text(
                                                    dataPoints[index].label,
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const Text('');
                                            },
                                          ),
                                        ),
                                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: () {
                                            if (dataPoints.isEmpty) return const [FlSpot(0, 0)];
                                            List<FlSpot> spots = [];
                                            for (int i = 0; i < dataPoints.length; i++) {
                                              spots.add(FlSpot(i.toDouble(), dataPoints[i].amanValue));
                                            }
                                            return spots;
                                          }(),
                                          isCurved: true,
                                          curveSmoothness: 0.35,
                                          preventCurveOverShooting: true,
                                          color: AppColors.safe,
                                          barWidth: 6,
                                          isStrokeCapRound: true,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(show: false),
                                          shadow: Shadow(color: AppColors.safe.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                                        ),
                                        LineChartBarData(
                                          spots: () {
                                            if (dataPoints.isEmpty) return const [FlSpot(0, 0)];
                                            List<FlSpot> spots = [];
                                            for (int i = 0; i < dataPoints.length; i++) {
                                              spots.add(FlSpot(i.toDouble(), dataPoints[i].warningValue));
                                            }
                                            return spots;
                                          }(),
                                          isCurved: true,
                                          curveSmoothness: 0.35,
                                          preventCurveOverShooting: true,
                                          color: AppColors.warning,
                                          barWidth: 6,
                                          isStrokeCapRound: true,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(show: false),
                                          shadow: Shadow(color: AppColors.warning.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                                        ),
                                        LineChartBarData(
                                          spots: () {
                                            if (dataPoints.isEmpty) return const [FlSpot(0, 0)];
                                            List<FlSpot> spots = [];
                                            for (int i = 0; i < dataPoints.length; i++) {
                                              spots.add(FlSpot(i.toDouble(), dataPoints[i].bahayaValue));
                                            }
                                            return spots;
                                          }(),
                                          isCurved: true,
                                          curveSmoothness: 0.35,
                                          preventCurveOverShooting: true,
                                          color: AppColors.danger,
                                          barWidth: 6,
                                          isStrokeCapRound: true,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(show: false),
                                          shadow: Shadow(color: AppColors.danger.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Legend
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildLegendItem(AppColors.safe, 'Aman'),
                                    const SizedBox(width: 16),
                                    _buildLegendItem(AppColors.warning, 'Waspada'),
                                    const SizedBox(width: 16),
                                    _buildLegendItem(AppColors.danger, 'Bahaya'),
                                  ],
                                ),
                              ],
                            );
                          })"""
                    content = content.replace(block, new_chart)
                    break
    else:
        print(f"Warning: Could not find start/end for LineChart in {path}")

    # 3. Change "Rata-Rata Asupan Anda" to "Total Natrium"
    if 'Rata-Rata Asupan Anda' in content:
        content = content.replace('Rata-Rata Asupan Anda', 'Total Natrium')

    # 4. Remove RadialProgressPainter class
    if 'class RadialProgressPainter extends CustomPainter {' in content:
        radial_start = content.find('class RadialProgressPainter extends CustomPainter {')
        # We find the end of the class manually by tracking braces just to be safe
        brace_count = 0
        in_class = False
        radial_end = radial_start
        for i in range(radial_start, len(content)):
            if content[i] == '{':
                brace_count += 1
                in_class = True
            elif content[i] == '}':
                brace_count -= 1
                
            if in_class and brace_count == 0:
                radial_end = i + 1
                break
                
        content = content[:radial_start] + content[radial_end:]

    # 5. Fix padding
    old_pad = """                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),"""
    new_pad = """                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),"""
    if old_pad in content:
        content = content.replace(old_pad, new_pad)

    # 6. Make sure fl_chart is imported
    if "import 'package:fl_chart/fl_chart.dart';" not in content:
        if "import 'package:flutter/material.dart';" in content:
            content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\\nimport 'package:fl_chart/fl_chart.dart';")
            
    # For riwayat_anggota_view.dart, we might need to replace 'RiwayatController' with 'RiwayatAnggotaController' if we hardcoded anything, but we didn't.

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
        print(f"Processed {path}")

process_file('lib/app/modules/riwayat/views/riwayat_view.dart', False)
process_file('lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart', True)
