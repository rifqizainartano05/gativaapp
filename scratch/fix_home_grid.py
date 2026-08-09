import re

path = 'lib/app/modules/home/views/home_view.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Replace empty container next to Riwayat with Edukasi Grid Item
old_grid_row = """                      Row(
                        children: [
                          Expanded(
                            child: _buildGridItem(
                              icon: Icons.history_rounded,
                              title: 'Riwayat',
                              subtitle: 'Catatan Medis',
                              isActive: false,
                              onTap: () => Get.toNamed(Routes.RIWAYAT),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      ),"""

new_grid_row = """                      Row(
                        children: [
                          Expanded(
                            child: _buildGridItem(
                              icon: Icons.history_rounded,
                              title: 'Riwayat',
                              subtitle: 'Catatan Medis',
                              isActive: false,
                              onTap: () => Get.toNamed(Routes.RIWAYAT),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGridItem(
                              icon: Icons.menu_book_rounded,
                              title: 'Edukasi',
                              subtitle: 'Artikel & Info',
                              isActive: false,
                              onTap: () => Get.toNamed('/edukasi'),
                            ),
                          ),
                        ],
                      ),"""
content = content.replace(old_grid_row, new_grid_row)

# 2. Remove the EDUKASI KESEHATAN section completely
start_idx = content.find("                      const SizedBox(height: 32),\n                      Row(\n                        mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                        children: [\n                          const Text(\n                            'EDUKASI KESEHATAN',")

if start_idx != -1:
    end_string = """                        }),\n                      ),"""
    end_idx = content.find(end_string, start_idx) + len(end_string)
    content = content[:start_idx] + content[end_idx:]

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
