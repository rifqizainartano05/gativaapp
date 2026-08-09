import re

path = 'lib/app/modules/edukasi_dokter/controllers/edukasi_dokter_controller.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

old_link = """          final document = parse(response.body);
          extractedText = document.body?.text.replaceAll(RegExp(r'\\s+'), ' ') ?? '';"""

new_link = """          final document = parse(response.body);
          // Hapus tag script dan style agar AI tidak merangkum kode JS/CSS
          document.querySelectorAll('script, style').forEach((e) => e.remove());
          extractedText = document.body?.text.replaceAll(RegExp(r'\\s+'), ' ').trim() ?? '';"""

content = content.replace(old_link, new_link)

old_prompt = """'content': 'Anda adalah asisten medis yang bertugas merangkum dokumen edukasi kesehatan ke dalam 2-3 kalimat singkat yang padat, jelas, dan mudah dipahami oleh pasien dalam bahasa Indonesia.'"""
new_prompt = """'content': 'Anda adalah asisten medis. Tugas Anda merangkum poin UTAMA dari teks berikut ke dalam 2-3 kalimat singkat yang padat dan jelas untuk pasien dalam bahasa Indonesia. JANGAN sebutkan "Berikut adalah ringkasan" atau kalimat pengantar lainnya, langsung ke intinya saja.'"""
content = content.replace(old_prompt, new_prompt)


old_success = """  void _onSuccess() {
    Get.back(); // close the form
    Get.snackbar('Sukses', 'Edukasi berhasil ditambahkan', backgroundColor: Colors.green, colorText: Colors.white);
    
    // Clear all inputs"""

new_success = """  void _onSuccess() {
    Get.back(); // close the form
    
    // Tampilkan custom dialog sukses
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
                    Icons.check_circle_outline,
                    size: 150,
                    color: Colors.green.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Sukses!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Edukasi berhasil ditambahkan.',
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
      barrierDismissible: false,
    );
    
    // Clear all inputs"""
content = content.replace(old_success, new_success)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
