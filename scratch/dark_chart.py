import os
import re

def update_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # The container I just changed had color: Colors.transparent
    container_pattern = r"decoration:\s*BoxDecoration\([\s\S]*?color:\s*Colors\.transparent,\s*\n\s*\),"
    new_container = """decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: const Color(0xFF282142),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),"""
    
    if re.search(container_pattern, content):
        content = re.sub(container_pattern, new_container, content)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

success1 = update_file('lib/app/modules/riwayat/views/riwayat_view.dart')
success2 = update_file('lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart')

print(f"Riwayat: {success1}, Riwayat Anggota: {success2}")
