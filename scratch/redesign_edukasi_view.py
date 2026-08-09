import os

dart_code = """import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/edukasi_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EdukasiView extends GetView<EdukasiController> {
  const EdukasiView({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.arguments != null) {
      return _buildDetailView(context, Get.arguments as Map<String, dynamic>);
    }
    return _buildListView(context);
  }

  Widget _buildListView(BuildContext context) {
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
                        'Edukasi Kesehatan',
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
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collectionGroup('edukasi').orderBy('created_at', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Terjadi kesalahan'));
                  }
                  
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          const Text('Belum ada artikel edukasi.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      data['id'] = docs[index].id;
                      
                      DateTime? date;
                      if (data['created_at'] != null) {
                        date = (data['created_at'] as Timestamp).toDate();
                      }
                      String dateString = date != null ? DateFormat('dd MMM yyyy').format(date) : '';
                      String doctorName = data['doctor_name'] ?? 'Dokter';
                      String type = data['type'] == 'pdf' ? 'Dokumen PDF' : data['type'] == 'link' ? 'Tautan' : 'Artikel';

                      IconData typeIcon = data['type'] == 'pdf' ? Icons.picture_as_pdf_rounded : 
                                          data['type'] == 'link' ? Icons.link_rounded : Icons.article_rounded;
                      Color typeColor = data['type'] == 'pdf' ? Colors.red.shade400 : 
                                        data['type'] == 'link' ? Colors.blue.shade400 : Colors.orange.shade400;

                      return GestureDetector(
                        onTap: () async {
                          if (data['type'] == 'pdf' && data['fileUrl'] != null) {
                            final Uri url = Uri.parse(data['fileUrl']);
                            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                              Get.snackbar('Error', 'Tidak dapat membuka PDF');
                            }
                          } else if (data['type'] == 'link' && data['linkUrl'] != null) {
                            final Uri url = Uri.parse(data['linkUrl']);
                            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                              Get.snackbar('Error', 'Tidak dapat membuka Tautan');
                            }
                          } else {
                            Get.toNamed('/edukasi', arguments: data);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            children: [
                              // WATERMARK ICON inside the card
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: Transform.rotate(
                                  angle: -0.15,
                                  child: Icon(
                                    typeIcon,
                                    size: 140,
                                    color: const Color(0xFF2E7D32).withValues(alpha: 0.03),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (data['imageUrl'] != null)
                                    Stack(
                                      children: [
                                        Image.network(
                                          data['imageUrl'],
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 12,
                                          left: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.9),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(typeIcon, size: 14, color: typeColor),
                                                const SizedBox(width: 4),
                                                Text(
                                                  type,
                                                  style: TextStyle(
                                                    color: typeColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Container(
                                      width: double.infinity,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF2E7D32).withValues(alpha: 0.8),
                                            const Color(0xFF4CAF50).withValues(alpha: 0.6),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Icon(
                                              typeIcon,
                                              size: 60,
                                              color: Colors.white.withValues(alpha: 0.5),
                                            ),
                                          ),
                                          Positioned(
                                            top: 12,
                                            left: 12,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(typeIcon, size: 14, color: typeColor),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    type,
                                                    style: TextStyle(
                                                      color: typeColor,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['title'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF2C3E50),
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.person_rounded, size: 16, color: Color(0xFF2E7D32)),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Dibuat oleh',
                                                    style: TextStyle(color: Colors.grey, fontSize: 11),
                                                  ),
                                                  Text(
                                                    doctorName,
                                                    style: const TextStyle(
                                                      color: Color(0xFF2C3E50),
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 1,
                                              height: 30,
                                              color: Colors.grey.withValues(alpha: 0.2),
                                              margin: const EdgeInsets.symmetric(horizontal: 12),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  'Tanggal',
                                                  style: TextStyle(color: Colors.grey, fontSize: 11),
                                                ),
                                                Text(
                                                  dateString,
                                                  style: const TextStyle(
                                                    color: Color(0xFF2C3E50),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (data['summary'] != null && data['summary'].toString().isNotEmpty) ...[
                                          const SizedBox(height: 20),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8F9FA),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 20),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    data['summary'],
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF546E7A),
                                                      height: 1.5,
                                                    ),
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, Map<String, dynamic> data) {
    String dateString = '';
    if (data['created_at'] != null) {
      DateTime date = (data['created_at'] as Timestamp).toDate();
      dateString = DateFormat('dd MMMM yyyy').format(date);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Edukasi', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['imageUrl'] != null)
              Image.network(
                data['imageUrl'],
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xFF2E7D32), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        data['doctor_name'] ?? 'Dokter',
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        dateString,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    data['content'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""

with open('lib/app/modules/edukasi/views/edukasi_view.dart', 'w', encoding='utf-8') as f:
    f.write(dart_code)
print("done")
