import re

path = 'lib/app/modules/edukasi_dokter/views/edukasi_dokter_view.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

old_delete = """                                  onPressed: () {
                                    Get.defaultDialog(
                                      title: 'Hapus Edukasi',
                                      middleText: 'Apakah Anda yakin ingin menghapus artikel ini?',
                                      textConfirm: 'Ya',
                                      textCancel: 'Batal',
                                      confirmTextColor: Colors.white,
                                      buttonColor: Colors.red,
                                      onConfirm: () {
                                        controller.hapusEdukasi(id, data);
                                        Get.back();
                                      },
                                    );
                                  },"""

new_delete = """                                  onPressed: () {
                                    Get.dialog(
                                      Dialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                right: -40,
                                                top: -40,
                                                child: Transform.rotate(
                                                  angle: -0.2,
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    size: 150,
                                                    color: Colors.red.withValues(alpha: 0.1),
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 60),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    'Hapus Edukasi',
                                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'Apakah Anda yakin ingin menghapus artikel ini? Data yang dihapus tidak dapat dikembalikan.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(fontSize: 14, color: Colors.black54),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: OutlinedButton(
                                                          onPressed: () => Get.back(),
                                                          style: OutlinedButton.styleFrom(
                                                            foregroundColor: Colors.grey.shade700,
                                                            side: BorderSide(color: Colors.grey.shade300),
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                                          ),
                                                          child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            controller.hapusEdukasi(id, data);
                                                            Get.back();
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                                          ),
                                                          child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },"""

content = content.replace(old_delete, new_delete)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
