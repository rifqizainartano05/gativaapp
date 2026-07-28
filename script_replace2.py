import re
import os

def replace_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    pattern = r"  double calculateDailyLimit\(int age, String condition\) \{[\s\S]*?return 2000;\n  \}"
    
    new_func = '''  double calculateDailyLimit(int age, String condition) {
    String c = condition.trim().toLowerCase();
    if (age >= 5 && age <= 9) {
      if (c.contains('sehat')) return 1200;
      if (c.contains('hipertensi')) return 1200;
      if (c.contains('kardiovaskular')) return 1000;
      if (c.contains('jantung')) return 1000;
      if (c.contains('ginjal')) return 1000;
      if (c.contains('stroke')) return 0;
      return 1200;
    } else if (age >= 10 && age <= 17) {
      if (c.contains('sehat')) return 1500;
      if (c.contains('hipertensi')) return 1200;
      if (c.contains('kardiovaskular')) return 1000;
      if (c.contains('jantung')) return 1000;
      if (c.contains('ginjal')) return 1000;
      if (c.contains('stroke')) return 0;
      return 1500;
    } else if (age >= 18 && age <= 59) {
      if (c.contains('sehat')) return 2000;
      if (c.contains('hipertensi')) return 1500;
      if (c.contains('kardiovaskular')) return 1500;
      if (c.contains('jantung')) return 1500;
      if (c.contains('ginjal')) return 1500;
      if (c.contains('stroke')) return 1500;
      return 2000;
    } else if (age >= 60) {
      if (c.contains('sehat')) return 1200;
      if (c.contains('hipertensi')) return 1000;
      if (c.contains('kardiovaskular')) return 1200;
      if (c.contains('jantung')) return 1200;
      if (c.contains('ginjal')) return 1000;
      if (c.contains('stroke')) return 1000;
      if (c.contains('osteoporosis')) return 2300;
      return 1200;
    }
    return 2000;
  }'''

    if re.search(pattern, content):
        content = re.sub(pattern, new_func, content)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Replaced in {filepath}")
    else:
        print(f"Not found in {filepath}")

files = [
    r'd:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\edit_profile\controllers\edit_profile_controller.dart',
    r'd:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\home\controllers\home_controller.dart',
    r'd:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\register\controllers\register_controller.dart',
]

for file in files:
    if os.path.exists(file):
        replace_in_file(file)
    else:
        print(f"File not found: {file}")
