import re
import os

def process_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Make sure we have fl_chart imported!
    if "import 'package:fl_chart/fl_chart.dart';" not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:fl_chart/fl_chart.dart';")

    regex = r"final radialData = controller\.getRadialData\(\);[\s\S]*?_buildLegendItem\(const Color\(0xFF00a8cc\), 'Tahunan'\),\s*\n\s*\],\s*\n\s*\),\s*\n\s*\],\s*\n\s*\);"

    new_chart_block = """final dataPoints = controller.getChartData();

                            return Column(
                              children: [
                                const SizedBox(height: 10),
                                Container(
                                  height: 250,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: const Color(0xFF282142),
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
                                          shadow: Shadow(color: AppColors.safe.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
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
                                          shadow: Shadow(color: AppColors.warning.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
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
                                          shadow: Shadow(color: AppColors.danger.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
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
                            );"""

    if re.search(regex, content):
        content = re.sub(regex, new_chart_block, content)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    else:
        print("Regex didn't match in " + path)
        return False

print("Riwayat: ", process_file('lib/app/modules/riwayat/views/riwayat_view.dart'))
print("Riwayat Anggota: ", process_file('lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart'))
