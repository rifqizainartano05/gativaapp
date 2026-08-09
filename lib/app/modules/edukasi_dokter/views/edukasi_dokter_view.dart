import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/edukasi_dokter_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EdukasiDokterView extends StatelessWidget {
  const EdukasiDokterView({super.key});

  @override
  Widget build(BuildContext context) {
    final EdukasiDokterController controller = Get.put(EdukasiDokterController());
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 30,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -30,
                  top: -20,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 150,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Kelola Edukasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Container(
            margin: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => controller.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Cari edukasi Anda...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(FirebaseAuth.instance.currentUser!.uid).collection('edukasi').orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi kesalahan'));
                }
                
                final docs = snapshot.data?.docs ?? [];
                
                return Obx(() {
                  final name = controller.currentDoctorName.value;
                  final currentDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    bool isMine = data['doctor_name'] == name;
                    bool matchesSearch = true;
                    if (controller.searchQuery.value.trim().isNotEmpty) {
                      String title = (data['title'] ?? '').toString().toLowerCase();
                      matchesSearch = title.contains(controller.searchQuery.value.trim().toLowerCase());
                    }
                    return isMine && matchesSearch;
                  }).toList();

                  if (currentDocs.isEmpty) {
                    return const Center(child: Text('Belum ada artikel edukasi yang Anda buat.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentDocs.length,
                    itemBuilder: (context, index) {
                      final data = currentDocs[index].data() as Map<String, dynamic>;
                      final id = currentDocs[index].id;
                    
                    DateTime? date;
                    if (data['created_at'] != null) {
                      date = (data['created_at'] as Timestamp).toDate();
                    }
                    String dateString = date != null ? DateFormat('dd MMM yyyy').format(date) : '';
                    String doctorName = data['doctor_name'] ?? 'Dokter';
                    String type = data['type'] == 'pdf' ? 'Dokumen PDF' : data['type'] == 'link' ? 'Tautan' : 'Artikel';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                data['imageUrl'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(data['imageUrl'], width: 60, height: 60, fit: BoxFit.cover),
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Icon(
                                          data['type'] == 'pdf' ? Icons.picture_as_pdf : 
                                          data['type'] == 'link' ? Icons.link : Icons.article,
                                          color: const Color(0xFF2E7D32),
                                          size: 32,
                                        ),
                                      ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['title'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.person, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(doctorName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            data['type'] == 'pdf' ? Icons.picture_as_pdf : 
                                            data['type'] == 'link' ? Icons.link : Icons.article,
                                            size: 14, 
                                            color: Colors.grey
                                          ),
                                          const SizedBox(width: 4),
                                          Text(type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(dateString, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
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
                                  },
                                ),
                              ],
                            ),
                            if (data['summary'] != null && data['summary'].toString().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${data['summary']}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        fontStyle: FontStyle.italic,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () {
          Get.to(() => const TambahEdukasiView());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    ),
    );
  }
}

class TambahEdukasiView extends StatelessWidget {
  const TambahEdukasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final EdukasiDokterController controller = Get.put(EdukasiDokterController());
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: Column(
          children: [
            // Custom Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 0, // No bottom padding so TabBar sits flush
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.add_circle_outline_rounded,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => Get.back(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Tambah Edukasi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const TabBar(
                        indicatorColor: Colors.white,
                        indicatorWeight: 3,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        tabs: [
                          Tab(text: 'Input Manual'),
                          Tab(text: 'Upload Dokumen'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: TabBarView(
                children: [
                  _buildManualTab(controller, context),
                  _buildDocumentTab(controller, context),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildManualTab(EdukasiDokterController controller, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            const SizedBox(width: 12),
                            Text(controller.loadingMessage.value, style: const TextStyle(color: Colors.white)),
                          ],
                        )
                      : const Text('Simpan Edukasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTab(EdukasiDokterController controller, BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color(0xFF2E7D32),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade700,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Dokumen PDF'),
                  Tab(text: 'Tautan / Link'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPdfTab(controller, context),
                _buildLinkTab(controller, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfTab(EdukasiDokterController controller, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(controller.loadingMessage.value, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis)),
                          ],
                        )
                      : const Text('Unggah PDF & Ringkas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTab(EdukasiDokterController controller, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                hintText: 'Misal: Artikel Tips Menurunkan Gula Darah',
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
                hintText: 'https://...',
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
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(controller.loadingMessage.value, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis)),
                          ],
                        )
                      : const Text('Simpan Tautan & Ringkas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
