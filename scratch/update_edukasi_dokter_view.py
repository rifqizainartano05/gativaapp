import re

path = 'lib/app/modules/edukasi_dokter/views/edukasi_dokter_view.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update the hapusEdukasi call
content = content.replace('controller.hapusEdukasi(id);', 'controller.hapusEdukasi(id, data);')

# 2. Replace TambahEdukasiView completely
new_tambah = """class TambahEdukasiView extends GetView<EdukasiDokterController> {
  const TambahEdukasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          title: const Text('Tambah Edukasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF2E7D32),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Input Manual'),
              Tab(text: 'Upload Dokumen'),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Watermark Aesthetic
            Positioned(
              top: -50,
              right: -50,
              child: Icon(
                Icons.health_and_safety_rounded,
                size: 250,
                color: const Color(0xFF2E7D32).withOpacity(0.05),
              ),
            ),
            
            TabBarView(
              children: [
                _buildManualTab(context),
                _buildDocumentTab(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Judul Edukasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(
                hintText: 'Masukkan judul artikel',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),
            
            const Text('URL Gambar (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.imageUrlController,
              decoration: InputDecoration(
                hintText: 'https://...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),

            const Text('Konten Edukasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.contentController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Tulis isi edukasi di sini...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() {
                return ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.tambahEdukasiManual(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Simpan Edukasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTab(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              indicatorColor: Color(0xFF2E7D32),
              labelColor: Color(0xFF2E7D32),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Dokumen PDF'),
                Tab(text: 'Tautan / Link'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPdfTab(context),
                _buildLinkTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Judul Dokumen PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.pdfTitleController,
              decoration: InputDecoration(
                hintText: 'Misal: Panduan Diet Sehat',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('File PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Obx(() {
              final file = controller.selectedPdfFile.value;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 48, color: file != null ? Colors.red : Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      file != null ? file.path.split('/').last.split('\\\\').last : 'Belum ada file terpilih',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: file != null ? Colors.black87 : Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => controller.pickPDF(),
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      label: const Text('Pilih File PDF', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() {
                return ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.tambahEdukasiPdf(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Unggah PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Judul Tautan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.linkTitleController,
              decoration: InputDecoration(
                hintText: 'Misal: Video Cara Mengontrol Garam',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),
            
            const Text('URL Tautan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.linkUrlController,
              decoration: InputDecoration(
                hintText: 'https://youtube.com/...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() {
                return ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.tambahEdukasiLink(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Simpan Tautan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
"""

# Replace the whole TambahEdukasiView class
start_idx = content.find('class TambahEdukasiView extends GetView<EdukasiDokterController> {')
content = content[:start_idx] + new_tambah

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
