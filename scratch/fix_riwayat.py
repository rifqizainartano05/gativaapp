import re
import os

def process_file(path, is_anggota=False):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Remove "Tren Asupan Natrium" and put the Dropdown there
    if 'Tren Asupan Natrium' in content:
        old_tren = """                                Text(
                                  'Tren Asupan Natrium',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                ),
                                // Dropdown removed"""
        
        new_dropdown = """                                const Spacer(),
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
                                )"""
        content = content.replace(old_tren, new_dropdown)

    # 2. Change "Rata-Rata Asupan Anda" to "Total Natrium"
    if 'Rata-Rata Asupan Anda' in content:
        content = content.replace('Rata-Rata Asupan Anda', 'Total Natrium')

    # 3. Replace RadialProgressPainter with LineChart
    # Find the start
    start_str = "// Hitung batas bulanan dan tahunan secara otomatis"
    end_str = "const SizedBox(height: 32),\n\n                      Container(\n                        alignment: Alignment.centerLeft,"
    
    if start_str in content and end_str in content:
        start_idx = content.find(start_str)
        # backtrack to the start of that line
        while start_idx > 0 and content[start_idx-1] not in ['\\n', '\\r']:
            start_idx -= 1
            
        end_idx = content.find(end_str)
        
        old_block = content[start_idx:end_idx]
        
        new_chart = """                              final dataPoints = controller.getChartData();
                              
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
                                          ),
                                          LineChartBarData(
                                            spots: () {
                                              if (dataPoints.isEmpty) return const [FlSpot(0, 0)];
                                              List<FlSpot> spots = [];
                                              for (int i = 0; i < dataPoints.length; i++) {
                                                spots.add(FlSpot(i.toDouble(), dataPoints[i].warningValue ?? 0));
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
                            }),
                          ],
                        ),
                      ),
                      """
        
        content = content.replace(old_block, new_chart)

    # 4. Remove RadialProgressPainter class
    if 'class RadialProgressPainter extends CustomPainter' in content:
        radial_start = content.find('class RadialProgressPainter extends CustomPainter')
        radial_end = content.find('}', content.find('bool shouldRepaint', radial_start)) + 1
        # Include the trailing newline and curly brace
        radial_end = content.find('}', radial_end) + 1
        content = content[:radial_start] + content[radial_end:]

    # 5. Fix padding in list items (terlalu sempit)
    list_item_padding = """                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),"""
    new_list_item_padding = """                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),"""
    content = content.replace(list_item_padding, new_list_item_padding)
    
    # 6. Make sure fl_chart is imported
    if "import 'package:fl_chart/fl_chart.dart';" not in content:
        if "import 'package:flutter/material.dart';" in content:
            content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\\nimport 'package:fl_chart/fl_chart.dart';")

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
        print(f"Processed {path}")

process_file('lib/app/modules/riwayat/views/riwayat_view.dart', False)
process_file('lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart', True)
