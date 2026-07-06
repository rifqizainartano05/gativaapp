import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/detail_tenaga_kesehatan_controller.dart';

class DetailTenagaKesehatanView extends GetView<DetailTenagaKesehatanController> {
  const DetailTenagaKesehatanView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
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
                          'Detail Tenaga Kesehatan',
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

                final isOnline = controller.isOnline.value;
                final photoBase64 = data['photoBase64'] ?? '';

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
                                // Nama Tenaga Kesehatan
                                Text(
                                  data['name'] ?? data['nama'] ?? data['username'] ?? 'Nama Tenaga Kesehatan',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    color: Color(0xFF1E293B),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                // Badge Online / Offline
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isOnline ? const Color(0xFFE8F5E9) : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isOnline ? Colors.green.shade200 : Colors.red.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isOnline ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                        color: isOnline ? const Color(0xFF2E7D32) : Colors.red.shade700,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isOnline ? "Online" : "Offline",
                                        style: TextStyle(
                                          color: isOnline ? const Color(0xFF2E7D32) : Colors.red.shade700,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // List Info
                                _buildInfoRow(Icons.schedule_rounded, "Jadwal Praktek", controller.scheduleText.value),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                                ),
                                _buildInfoRow(Icons.work_history_rounded, "Role", data['role'] ?? 'Tenaga Kesehatan'),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                                ),
                                _buildInfoRow(Icons.school_rounded, "Lulusan", data['universitas'] ?? data['lulusan'] ?? 'Lulusan Terkemuka'),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, color: Color(0xFFEEEEEE)),
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
                                    return _buildInfoRow(Icons.star_rounded, "Pengalaman", "$pengalaman Tahun Praktik");
                                  },
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                                ),
                                if (data['strNumber'] != null && data['strNumber'].toString().isNotEmpty) ...[
                                  _buildInfoRow(Icons.pin_rounded, "STR Number", data['strNumber'].toString()),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                                  ),
                                ],
                                if (data['age'] != null && data['age'].toString().isNotEmpty) ...[
                                  _buildInfoRow(Icons.cake_rounded, "Umur", "${data['age']} Tahun"),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                                  ),
                                ],

                                // Rating Box
                                const SizedBox(height: 12),
                                Obx(() {
                                  final hasRated = controller.hasRated.value;
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          hasRated ? "Rating Anda" : "Beri Rating Tenaga Kesehatan",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          hasRated ? "Terima kasih telah memberikan penilaian." : "Seberapa puas Anda dengan layanan ini?",
                                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(5, (index) {
                                            final currentRating = controller.rating.value;
                                            return IconButton(
                                              icon: Icon(
                                                index < currentRating ? Icons.star_rounded : Icons.star_border_rounded,
                                                color: Colors.amber,
                                                size: 36,
                                              ),
                                              onPressed: hasRated ? null : () {
                                                controller.rating.value = index + 1;
                                              },
                                            );
                                          }),
                                        ),
                                        if (!hasRated) ...[
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (controller.rating.value > 0) {
                                                controller.updateDoctorRating(data['id']?.toString(), controller.rating.value);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF2E7D32),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              minimumSize: const Size(double.infinity, 44),
                                            ),
                                            child: const Text("Kirim Rating", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 16),

                                ...data.entries.where((e) {
                                  final excludedKeys = ['photoBase64', 'strImageBase64', 'id', 'name', 'nama', 'username', 'role', 'universitas', 'lulusan', 'pengalaman', 'mulai_praktik', 'jadwal_online', 'detail_tenaga_kesehatan', 'strNumber', 'age', 'email', 'createdAt', 'created_at', 'kode_akses', 'status'];
                                  return !excludedKeys.contains(e.key) && e.value != null && e.value.toString().isNotEmpty;
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
                                                e.value.toString(),
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

