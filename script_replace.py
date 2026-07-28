import os

def replace_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    old_func = '''  double calculateDailyLimit(int age, String condition) {
    if (age >= 5 && age <= 9) {
      switch (condition) {
        case 'Sehat': return 1200;
        case 'Hipertensi': return 1200;
        case 'Penyakit kardiovaskular': return 1000;
        case 'Penyakit jantung koroner': return 1000;
        case 'Penyakit ginjal kronis': return 800;
        case 'Stroke': return 0;
        default: return 1200;
      }
    } else if (age >= 10 && age <= 17) {
      switch (condition) {
        case 'Sehat': return 1500;
        case 'Hipertensi': return 1200;
        case 'Penyakit kardiovaskular': return 1000;
        case 'Penyakit jantung koroner': return 1000;
        case 'Penyakit ginjal kronis': return 800;
        case 'Stroke': return 0;
        default: return 1500;
      }
    } else if (age >= 18 && age <= 59) {
      switch (condition) {
        case 'Sehat': return 2000;
        case 'Hipertensi': return 1500;
        case 'Penyakit kardiovaskular': return 1500;
        case 'Penyakit jantung koroner': return 1500;
        case 'Penyakit ginjal kronis': return 1500;
        case 'Stroke': return 1500;
        default: return 2000;
      }
    } else if (age >= 60) {
      switch (condition) {
        case 'Sehat': return 1200;
        case 'Hipertensi': return 1000;
        case 'Penyakit kardiovaskular': return 1000;
        case 'Penyakit jantung koroner': return 1000;
        case 'Penyakit ginjal kronis': return 1000;
        case 'Stroke': return 1000;
        case 'Osteoporosis': return 2300;
        default: return 1200;
      }
    }
    return 2000;
  }'''

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

    if old_func in content:
        content = content.replace(old_func, new_func)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Replaced in {filepath}")
    else:
        print(f"Not found in {filepath}, perhaps slightly different formatting?")

files = [
    r'd:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\anggota\controllers\anggota_controller.dart',
    r'd:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\edit_profile\controllers\edit_profile_controller.dart',
    r'd:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\home\controllers\home_controller.dart',
    r'd:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\lensa_natrium\controllers\lensa_natrium_controller.dart',
    r'd:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\nakes_detail_pasien_chat\controllers\nakes_detail_pasien_chat_controller.dart',
    r'd:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\nakes_detail_pasien_gativa\controllers\nakes_detail_pasien_gativa_controller.dart',
    r'd:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\profile\controllers\profile_controller.dart',
    r'd:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\register\controllers\register_controller.dart',
    r'd:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\riwayat\controllers\riwayat_controller.dart'
]

for file in files:
    if os.path.exists(file):
        replace_in_file(file)
    else:
        print(f"File not found: {file}")
