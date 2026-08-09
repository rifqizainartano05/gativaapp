import os

path = 'lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("import '../controllers/riwayat_controller.dart';", "import '../controllers/riwayat_anggota_controller.dart';")
with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
