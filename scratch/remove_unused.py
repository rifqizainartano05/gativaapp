import re
import os

def process_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    regex = r"final radialData = controller\.getRadialData\(\);\s*\n\s*double dailyLimit = controller\.dailyLimit\.value > 0 \? controller\.dailyLimit\.value : 2000\.0;\s*\n\s*// Hitung batas bulanan dan tahunan secara otomatis\s*\n\s*final now = DateTime\.now\(\);\s*\n\s*int daysInMonth = DateTime\(now\.year, now\.month \+ 1, 0\)\.day;\s*\n\s*int daysInYear = \(now\.year % 4 == 0 && now\.year % 100 != 0\) \|\| \(now\.year % 400 == 0\) \? 366 : 365;\s*\n\s*double harianPercent = radialData\['harian'\]! / dailyLimit;\s*\n\s*double bulananPercent = radialData\['bulanan'\]! / \(dailyLimit \* daysInMonth\);\s*\n\s*double tahunanPercent = radialData\['tahunan'\]! / \(dailyLimit \* daysInYear\);\s*\n"
    
    if re.search(regex, content):
        content = re.sub(regex, "", content)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    else:
        print("Regex didn't match in " + path)
        return False

print("Riwayat: ", process_file('lib/app/modules/riwayat/views/riwayat_view.dart'))
print("Riwayat Anggota: ", process_file('lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart'))
