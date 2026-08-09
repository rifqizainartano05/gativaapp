import os
import re

def update_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # The current regex for LineChartData
    # Note that my revert script created this exact structure:
    # LineChartData(
    #   clipData: const FlClipData.all(),
    #   gridData: FlGridData(
    #   ...
    #   lineBarsData: [ ... ],
    # )
    
    start_pattern = r"LineChartData\([\s\S]*?lineBarsData:\s*\[[\s\S]*?belowBarData:\s*BarAreaData\(show:\s*false\),\s*\n\s*\w*\s*\),\s*\n\s*\w*\s*\],"
    
    match = re.search(start_pattern, content)
    if not match:
        print(f"Could not find pattern in {path}")
        return False

    new_chart_data = """LineChartData(
                                      clipData: const FlClipData.all(),
                                      gridData: const FlGridData(show: false),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        bottomTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      minX: 0,
                                      maxX: (controller.getChartData().length - 1).toDouble() < 0 ? 0 : (controller.getChartData().length - 1).toDouble(),
                                      minY: 0,
                                      maxY: yMax,
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
                                      ],"""
                                      
    content = content.replace(match.group(0), new_chart_data)
    
    # Let's also remove the padding/border from the Container that holds the LineChart to make it clean like the picture
    # Right above LineChart, there is:
    # Container(
    #   height: 250,
    #   width: double.infinity,
    #   decoration: BoxDecoration(
    #     borderRadius: BorderRadius.circular(18),
    #     color: Colors.white,
    #     border: Border.all(color: Colors.grey.shade200),
    #   ),
    #   padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
    #   child: LineChart(
    
    container_pattern = r"decoration:\s*BoxDecoration\([\s\S]*?border:\s*Border\.all\(color:\s*Colors\.grey\.shade200\),\s*\n\s*\),"
    new_container = """decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: Colors.transparent,
                                    ),"""
    content = re.sub(container_pattern, new_container, content)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    return True

success1 = update_file('lib/app/modules/riwayat/views/riwayat_view.dart')
success2 = update_file('lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart')

print(f"Riwayat: {success1}, Riwayat Anggota: {success2}")
