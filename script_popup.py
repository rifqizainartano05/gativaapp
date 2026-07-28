import os
import re

def replace_snackbar_with_popup(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find and replace Get.snackbar for Success
    success_pattern = r'Get\.snackbar\(\s*"Sukses",\s*"Notifikasi berhasil diaktifkan!",\s*backgroundColor:[^;]+;\s*'
    success_repl = 'CustomPopup.showSuccess("Sukses", "Notifikasi berhasil diaktifkan!");\n        '
    content = re.sub(success_pattern, success_repl, content)

    # Find and replace Get.snackbar for Warning (already on)
    warning_on_pattern = r'Get\.snackbar\(\s*"Pengaturan Perangkat",\s*"Notifikasi saat ini diaktifkan oleh sistem\. Untuk mematikannya, silakan ubah di Pengaturan HP Anda\.",\s*backgroundColor:[^;]+;\s*'
    warning_on_repl = 'CustomPopup.showWarning("Pengaturan Perangkat", "Notifikasi saat ini diaktifkan oleh sistem. Untuk mematikannya, silakan ubah di Pengaturan HP Anda.");\n      '
    content = re.sub(warning_on_pattern, warning_on_repl, content)

    # Find and replace Get.snackbar for Warning (off)
    warning_off_pattern = r'Get\.snackbar\(\s*"Pengaturan Perangkat",\s*"Notifikasi dimatikan oleh sistem\. Untuk menghidupkannya, silakan ubah di Pengaturan HP Anda\.",\s*backgroundColor:[^;]+;\s*'
    warning_off_repl = 'CustomPopup.showWarning("Pengaturan Perangkat", "Notifikasi dimatikan oleh sistem. Untuk menghidupkannya, silakan ubah di Pengaturan HP Anda.");\n        '
    content = re.sub(warning_off_pattern, warning_off_repl, content)

    # Make sure CustomPopup is imported
    if "import '../../../widgets/custom_popup.dart';" not in content:
        content = "import '../../../widgets/custom_popup.dart';\n" + content

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Replaced in {filepath}")

files = [
    r"d:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\profile\controllers\profile_controller.dart",
    r"d:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\nakes_profile\controllers\nakes_profile_controller.dart"
]

for file in files:
    replace_snackbar_with_popup(file)
