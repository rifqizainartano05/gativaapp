import re

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Fix the limit redeclaration
    content = content.replace('double limit = controller.dailyLimit.value > 0 ? controller.dailyLimit.value : 2000.0;', 
                              'double lineLimit = controller.dailyLimit.value > 0 ? controller.dailyLimit.value : 2000.0;')
    
    content = content.replace('double maxDataValue = limit;', 'double maxDataValue = lineLimit;')
    content = content.replace('double warningStop = (limit * 0.8) / yMax;', 'double warningStop = (lineLimit * 0.8) / yMax;')
    content = content.replace('double dangerStop = limit / yMax;', 'double dangerStop = lineLimit / yMax;')
    content = content.replace('if (spot.y >= limit) {', 'if (spot.y >= lineLimit) {')
    content = content.replace('if (spot.y >= limit * 0.8) {', 'if (spot.y >= lineLimit * 0.8) {')
    
    # 2. Revert incorrect gradient replacements
    gradient_str = """gradient: LinearGradient(
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
                                          ),"""
    
    # Temporarily hide the valid one
    content = content.replace(f"isCurved: true,\n                                          {gradient_str}", "isCurved: true,\n                                          %%VALID_GRADIENT%%,")
    
    # Replace all other gradient_str back to color: AppColors.safe,
    content = content.replace(gradient_str, 'color: AppColors.safe,')
    
    # Restore the valid one
    content = content.replace("%%VALID_GRADIENT%%,", gradient_str)
    
    # 3. Fix the "Not a constant expression" error in the stops array.
    content = content.replace('colors: const [', 'colors: [')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

fix_file('lib/app/modules/riwayat/views/riwayat_view.dart')
fix_file('lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart')
print("Done")
