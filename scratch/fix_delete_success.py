import re

path = 'lib/app/modules/edukasi_dokter/controllers/edukasi_dokter_controller.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

old_delete_success = """      await FirebaseFirestore.instance.collection('edukasi').doc(id).delete();
      Get.snackbar('Sukses', 'Edukasi berhasil dihapus', backgroundColor: Colors.green, colorText: Colors.white);"""

new_delete_success = """      await FirebaseFirestore.instance.collection('edukasi').doc(id).delete();
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
                      Icons.delete_sweep,
                      size: 150,
                      color: Colors.red.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Berhasil',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Artikel edukasi berhasil dihapus secara permanen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );"""

content = content.replace(old_delete_success, new_delete_success)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
