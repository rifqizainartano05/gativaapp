import os

def update_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the chart container to remove grid lines and borders
    
    # We will replace the whole LineChart block from `LineChart(` to the end of `),` for the `child: LineChart(...)`
    # Let's use regex or just substring replacement.
    
    # First, let's locate the entire LineChart widget.
    import re
    # The LineChart starts at `LineChart(` and ends at `belowBarData: BarAreaData(show: false),\n                                        ),\n                                      ],\n                                    ),`
    
    # Let's just find the `gridData` block and replace it
    grid_data_regex = r"gridData:\s*FlGridData\([\s\S]*?\),"
    new_grid_data = "gridData: const FlGridData(show: false),"
    content = re.sub(grid_data_regex, new_grid_data, content)
    
    # borderData
    border_data_regex = r"borderData:\s*FlBorderData\([\s\S]*?\),"
    new_border_data = "borderData: FlBorderData(show: false),"
    content = re.sub(border_data_regex, new_border_data, content)
    
    # lineBarsData
    line_bars_data_regex = r"lineBarsData:\s*\[[\s\S]*?belowBarData:\s*BarAreaData\(show:\s*false\),\s*\n\s*\w*\s*\),\s*\n\s*\w*\s*\],"
    
    # Wait, my revert script earlier put back ONE line.
    # Let's check what the current lineBarsData block is.
    
    # I will just write a python script that reads the file, finds `lineBarsData: [`, and replaces it with the 3 lines.
    
    new_line_bars_data = """lineBarsData: [
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
                                          curveSmoothness: 0.4,
                                          preventCurveOverShooting: true,
                                          color: AppColors.safe,
                                          barWidth: 6,
                                          isStrokeCapRound: true,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(show: false),
                                          shadow: Shadow(color: AppColors.safe.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
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
                                          curveSmoothness: 0.4,
                                          preventCurveOverShooting: true,
                                          color: AppColors.warning,
                                          barWidth: 6,
                                          isStrokeCapRound: true,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(show: false),
                                          shadow: Shadow(color: AppColors.warning.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
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
                                          curveSmoothness: 0.4,
                                          preventCurveOverShooting: true,
                                          color: AppColors.danger,
                                          barWidth: 6,
                                          isStrokeCapRound: true,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(show: false),
                                          shadow: Shadow(color: AppColors.danger.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                                        ),
                                      ],"""
                                      
    content = re.sub(r"lineBarsData:\s*\[[\s\S]*?belowBarData:\s*BarAreaData\(show:\s*false\),\s*\n\s*\w*\s*\),\s*\n\s*\w*\s*\],", new_line_bars_data, content)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    return True

update_file('lib/app/modules/riwayat/views/riwayat_view.dart')
update_file('lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart')
print("Done")
