import re

with open('lib/app/modules/anggota/views/anggota_view.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Rename scan_anggota
content = content.replace('SCAN_ANGGOTA', 'GABUNG_GRUP_ANGGOTA')
content = content.replace('scan_anggota', 'gabung_grup_anggota')

# 2. QR Dialog fixes
content = content.replace(\"embeddedImage: const AssetImage('assets/logo.png'),\", \"\")
content = content.replace(\"embeddedImageStyle: const QrEmbeddedImageStyle(\n                                size: Size(30, 30),\n                              ),\", \"\")

old_qr_column = '''child: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['''
new_qr_column = '''child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: ['''
content = content.replace(old_qr_column, new_qr_column)
content = content.replace('                      ),\n                    ],\n                  ),\n                ),\n              ],\n            ),\n          ),\n        ),', '                      ),\n                    ],\n                  ),\n                ),\n              ],\n            ),\n            ],\n            ),\n          ),\n        ),')

# 3. Header fixes (Center Grup Pantauan, remove icon and subtitle)
old_header = '''Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.groups_2_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Grup Pantauan',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Pantau kesehatan dan asupan harian Anggota secara real-time dari satu tempat.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),'''
new_header = '''const Center(
                    child: Text(
                      'Grup Pantauan',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),'''
content = content.replace(old_header, new_header)

# 4. Use SimpleAnggotaCard
old_card_usage = '''return AnimatedAnggotaCard(
                          member: member,
                          statusColor: statusColor,
                          ratio: ratio,
                          statusIcon: statusIcon,
                          sending: sending,
                          onRemind: () => controller.sendReminder(member),
                          onDelete: member.name.endsWith('(Saya)') ? null : () => controller.deleteMember(member),
                        );'''
new_card_usage = '''return SimpleAnggotaCard(
                          member: member,
                          statusColor: statusColor,
                          statusIcon: statusIcon,
                          onTap: () {
                            Get.toNamed('/riwayat-anggota', arguments: member);
                          },
                        );'''
content = content.replace(old_card_usage, new_card_usage)

# Remove AnimatedAnggotaCard completely
match = re.search(r'class AnimatedAnggotaCard extends StatefulWidget \{.*', content, flags=re.DOTALL)
if match:
    content = content[:match.start()]

with open('lib/app/modules/anggota/views/anggota_view.dart', 'w', encoding='utf-8') as f:
    f.write(content)
