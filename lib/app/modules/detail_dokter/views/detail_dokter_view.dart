import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/detail_dokter_controller.dart';
import '../../chat/controllers/chat_controller.dart';

class DetailDokterView extends GetView<DetailDokterController> {
  const DetailDokterView({super.key});

  @override
  Widget build(BuildContext context) {
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
            // Custom Header with Watermark
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
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
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
                    top: -10,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.medical_services_rounded,
                        size: 130,
                        color: Colors.white.withOpacity(0.1),
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
                            color: Colors.white.withOpacity(0.2),
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
                      const Expanded(
                        child: Text(
                          'Detail Dokter',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                bottom: true,
                child: Obx(() {
                  if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  );
                }

                final data = controller.doctorData;
                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      "Detail dokter tidak ditemukan",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final photoBase64 = data['photo64'] ?? '';

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              right: -40,
                              bottom: -40,
                              child: Opacity(
                                opacity: 0.03,
                                child: Icon(
                                  Icons.medical_services_rounded,
                                  size: 150,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                // Avatar
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.white,
                                    backgroundImage: photoBase64.isNotEmpty
                                        ? MemoryImage(const Base64Decoder().convert(photoBase64))
                                        : null,
                                    child: photoBase64.isEmpty
                                        ? const Icon(
                                            Icons.medical_information_rounded,
                                            size: 50,
                                            color: Color(0xFF2E7D32),
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Nama Dokter
                                Text(
                                  data['name'] ?? data['nama'] ?? data['username'] ?? 'Nama Dokter',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    color: Color(0xFF1E293B),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                // List Info
                                _buildInfoRow(Icons.location_on_rounded, "Praktik Dimana", data['praktik_dimana']?.toString() ?? data['tempat_praktik']?.toString() ?? ''),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Container(
                                    height: 3,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.all(Radius.circular(2)),
                                    ),
                                  ),
                                ),

                                _buildInfoRow(Icons.school_rounded, "Lulusan", data['universitas']?.toString() ?? data['lulusan']?.toString() ?? ''),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Container(
                                    height: 3,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.all(Radius.circular(2)),
                                    ),
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    int pengalaman = 0;
                                    if (data['pengalaman'] != null) {
                                      pengalaman = int.tryParse(data['pengalaman'].toString()) ?? 0;
                                    } else if (data['mulai_praktik'] != null) {
                                      final tahun = int.tryParse(data['mulai_praktik'].toString());
                                      if (tahun != null) {
                                        pengalaman = DateTime.now().year - tahun;
                                        if (pengalaman < 0) pengalaman = 0;
                                      }
                                    }
                                      return _buildInfoRow(Icons.star_rounded, "Pengalaman", pengalaman > 0 ? "$pengalaman Tahun Praktik" : "-");
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Container(
                                    height: 3,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.all(Radius.circular(2)),
                                    ),
                                  ),
                                ),
                                if (data['strNumber'] != null && data['strNumber'].toString().isNotEmpty) ...[
                                  _buildInfoRow(Icons.pin_rounded, "STR Number", data['strNumber'].toString()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Container(
                                    height: 3,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.all(Radius.circular(2)),
                                    ),
                                  ),
                                  ),
                                ],




                                ...data.entries.where((e) {
                                  final excludedKeys = ['photo64', 'photoBase64', 'strImageBase64', 'id', 'name', 'nama', 'username', 'role', 'universitas', 'lulusan', 'pengalaman', 'mulai_praktik', 'jadwal_online', 'detail_dokter', 'strNumber', 'age', 'email', 'createdAt', 'created_at', 'kode_akses', 'status', 'isOnline', 'isonline', 'rating', 'praktik_dimana', 'tempat_praktik', 'lastSeen'];
                                  return !excludedKeys.contains(e.key) && e.value != null;
                                }).map((e) {
                                  // Format key to Title Case
                                  String formattedKey = e.key.replaceAll('_', ' ');
                                  formattedKey = formattedKey.split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                formattedKey,
                                                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                e.value.toString().trim().isEmpty ? "-" : e.value.toString(),
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                }),
              ),
            ),
          ],
        ),
        
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    if (value.trim().isEmpty) value = '-';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // Slate 100
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

