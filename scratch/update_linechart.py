import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Calculate variables before returning Column
    new_vars = """
                            double limit = controller.dailyLimit.value > 0 ? controller.dailyLimit.value : 2000.0;
                            final dataPoints = controller.getChartData();
                            
                            double maxDataValue = limit;
                            for (var point in dataPoints) {
                              double total = point.amanValue + point.warningValue + point.bahayaValue;
                              if (total > maxDataValue) maxDataValue = total;
                            }
                            // yMax gives some headroom above the highest point
                            double yMax = maxDataValue * 1.1;
                            
                            // Calculate stops based on limit relative to yMax
                            double warningStop = (limit * 0.8) / yMax;
                            double dangerStop = limit / yMax;
                            
                            warningStop = warningStop.clamp(0.0, 1.0);
                            dangerStop = dangerStop.clamp(0.0, 1.0);

                            return Column("""
    content = content.replace('                            return Column(', new_vars)

    # Add clipData and update maxY
    content = content.replace('LineChartData(', 'LineChartData(\n                                      clipData: const FlClipData.all(),')
    content = re.sub(r'maxY:\s*controller\.dailyLimit\.value\s*>\s*0\s*\?\s*controller\.dailyLimit\.value\s*:\s*2000,', 'maxY: yMax,', content)

    # Update lineBarsData spots and colors
    spots_old = """spots: () {
                                            final dataPoints = controller.getChartData();
                                            if (dataPoints.isEmpty) return const [FlSpot(0, 0)];
                                            List<FlSpot> spots = [];
                                            for (int i = 0; i < dataPoints.length; i++) {
                                              double total = dataPoints[i].amanValue + dataPoints[i].warningValue + dataPoints[i].bahayaValue;
                                              spots.add(FlSpot(i.toDouble(), total));
                                            }
                                            return spots;
                                          }(),"""
    spots_new = """spots: () {
                                            if (dataPoints.isEmpty) return const [FlSpot(0, 0)];
                                            List<FlSpot> spots = [];
                                            for (int i = 0; i < dataPoints.length; i++) {
                                              double total = dataPoints[i].amanValue + dataPoints[i].warningValue + dataPoints[i].bahayaValue;
                                              if (total == 0) {
                                                spots.add(FlSpot.nullSpot);
                                              } else {
                                                spots.add(FlSpot(i.toDouble(), total));
                                              }
                                            }
                                            return spots;
                                          }(),"""
    content = content.replace(spots_old, spots_new)

    # Update color to gradient
    content = content.replace('color: AppColors.safe,', """gradient: LinearGradient(
                                            colors: const [
                                              AppColors.safe,
                                              AppColors.safe,
                                              AppColors.warning,
                                              AppColors.warning,
                                              AppColors.danger,
                                              AppColors.danger,
                                            ],
                                            stops: [
                                              0.0,
                                              warningStop,
                                              warningStop,
                                              dangerStop,
                                              dangerStop,
                                              1.0,
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),""")

    # Update getDotPainter limit logic
    dot_old = """                                               double limit = controller.dailyLimit.value;
                                               if (spot.y > limit * 0.2) {
                                                 dotColor = AppColors.danger;
                                               } else if (spot.y > limit * 0.1) {
                                                 dotColor = AppColors.warning;
                                               }"""
    dot_new = """                                               if (spot.y >= limit) {
                                                 dotColor = AppColors.danger;
                                               } else if (spot.y >= limit * 0.8) {
                                                 dotColor = AppColors.warning;
                                               }"""
    content = content.replace(dot_old, dot_new)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

process_file('lib/app/modules/riwayat/views/riwayat_view.dart')
process_file('lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart')
print("Done")
