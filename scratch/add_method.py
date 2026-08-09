import os

method = """
  double getAverageDailyIntake() {
    if (logs.isEmpty) return 0.0;
    
    Map<String, double> dailySums = {};
    for (var log in logs) {
      if (log.type == 'makanan') {
        String dateKey = "${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}";
        dailySums[dateKey] = (dailySums[dateKey] ?? 0.0) + log.amount;
      }
    }
    
    if (dailySums.isEmpty) return 0.0;
    
    double total = 0.0;
    dailySums.forEach((key, value) {
      total += value;
    });
    
    return total / dailySums.length;
  }
}"""

def add_method(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    if 'getAverageDailyIntake' not in content:
        # Find last brace
        last_brace = content.rfind('}')
        if last_brace != -1:
            content = content[:last_brace] + method + content[last_brace+1:]
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
    return False

print("Riwayat: ", add_method('lib/app/modules/riwayat/controllers/riwayat_controller.dart'))
print("Riwayat Anggota: ", add_method('lib/app/modules/riwayat_anggota/controllers/riwayat_anggota_controller.dart'))
