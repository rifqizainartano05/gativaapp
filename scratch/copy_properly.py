import os
import codecs

source = 'scratch/riwayat_view_head.dart'
dest_riwayat = 'lib/app/modules/riwayat/views/riwayat_view.dart'
dest_anggota = 'lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart'

with open(source, 'r', encoding='utf-16le') as f:
    original = f.read()

# Write exactly to riwayat_view
with open(dest_riwayat, 'w', encoding='utf-8') as f:
    f.write(original)

# Modify and write to riwayat_anggota_view
modified = original.replace('RiwayatView', 'RiwayatAnggotaView').replace('RiwayatController', 'RiwayatAnggotaController').replace("import '../controllers/riwayat_controller.dart';", "import '../controllers/riwayat_anggota_controller.dart';")
with open(dest_anggota, 'w', encoding='utf-8') as f:
    f.write(modified)
print('Done copying properly')
