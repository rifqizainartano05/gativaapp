import os

def update_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find where lineBarsData starts
    start_str = "                                      lineBarsData: ["
    end_str = "                                      ],"
    
    if start_str not in content:
        return False
        
    start_idx = content.find(start_str)
    
    # We need to find the matching '],' for lineBarsData
    # Let's just find the exact block using string matching if possible, or substring replacement
    
    old_block = """                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: () {
                                            if (dataPoints.isEmpty) return const [FlSpot(0, 0)];
                                            List<FlSpot> spots = [];
                                            for (int i = 0; i < dataPoints.length; i++) {
                                              double total = dataPoints[i].amanValue + dataPoints[i].warningValue + dataPoints[i].bahayaValue;
                                              spots.add(FlSpot(i.toDouble(), total));
                                            }
                                            return spots;
                                          }(),
                                          isCurved: true,
                                          gradient: LinearGradient(
                                            colors: [
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
                                          ),
                                          barWidth: 4,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(
                                            show: true,
                                            checkToShowDot: (spot, barData) => spot.y > 0,
                                            getDotPainter: (spot, percent, barData, index) {
                                               Color dotColor = AppColors.safe;
                                               if (spot.y >= lineLimit) {
                                                 dotColor = AppColors.danger;
                                               } else if (spot.y >= lineLimit * 0.8) {
                                                 dotColor = AppColors.warning;
                                               }
                                               return FlDotCirclePainter(
                                                 radius: 5, color: dotColor, strokeWidth: 2, strokeColor: Colors.white,
                                               );
                                            },
                                          ),
                                          belowBarData: BarAreaData(show: false),
                                        ),
                                      ],"""
                                      
    new_block = """                                      lineBarsData: [
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
                                          color: AppColors.safe,
                                          barWidth: 4,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(
                                            show: true,
                                            checkToShowDot: (spot, barData) => spot.y > 0,
                                            getDotPainter: (spot, percent, barData, index) {
                                               return FlDotCirclePainter(
                                                 radius: 4, color: AppColors.safe, strokeWidth: 2, strokeColor: Colors.white,
                                               );
                                            },
                                          ),
                                          belowBarData: BarAreaData(show: false),
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
                                          color: AppColors.warning,
                                          barWidth: 4,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(
                                            show: true,
                                            checkToShowDot: (spot, barData) => spot.y > 0,
                                            getDotPainter: (spot, percent, barData, index) {
                                               return FlDotCirclePainter(
                                                 radius: 4, color: AppColors.warning, strokeWidth: 2, strokeColor: Colors.white,
                                               );
                                            },
                                          ),
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
                                          color: AppColors.danger,
                                          barWidth: 4,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(
                                            show: true,
                                            checkToShowDot: (spot, barData) => spot.y > 0,
                                            getDotPainter: (spot, percent, barData, index) {
                                               return FlDotCirclePainter(
                                                 radius: 4, color: AppColors.danger, strokeWidth: 2, strokeColor: Colors.white,
                                               );
                                            },
                                          ),
                                          belowBarData: BarAreaData(show: false),
                                        ),
                                      ],"""
                                      
    if old_block in content:
        content = content.replace(old_block, new_block)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    else:
        print(f"Could not find exact block in {path}")
        return False


success1 = update_file('lib/app/modules/riwayat/views/riwayat_view.dart')
success2 = update_file('lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart')

print(f"Riwayat: {success1}, Riwayat Anggota: {success2}")
