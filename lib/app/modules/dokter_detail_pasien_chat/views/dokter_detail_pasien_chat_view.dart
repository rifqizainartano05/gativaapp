import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/dokter_detail_pasien_chat_controller.dart';

class DokterDetailPasienChatView
    extends GetView<DokterDetailPasienChatController> {
  const DokterDetailPasienChatView({super.key});

  @override
  Widget build(BuildContext context) {
    const bool readOnly = true;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
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
                    top: -20,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.monitor_heart_rounded,
                        size: 150,
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
                      const Text(
                        'Detail Pasien',
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
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 40.0,
                  bottom: MediaQuery.of(context).padding.bottom + 24.0,
                ),
                child: Column(
                  children: [
                    // Natrium Box removed
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                    Container(
                      margin: const EdgeInsets.only(top: 50),
                      padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Data Diri'),
                          const SizedBox(height: 16),
                          _buildInputField(
                            label: 'Nama Lengkap',
                            controller: controller.nameController,
                            icon: Icons.person_outline,
                            readOnly: readOnly,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            label: 'Usia (Tahun)',
                            controller: controller.usiaController,
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            readOnly: readOnly,
                          ),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Data Kesehatan'),
                          const SizedBox(height: 16),
                          Obx(() {
                            final rawKondisi = controller.pasienData['kondisi_kesehatan'] ?? controller.pasienData['kondisi'] ?? 'Sehat';
                            final List<String> conditionsList = rawKondisi.toString().split(',').map((e) => e.trim()).toList();
                            
                            List<String> options = [
                              'Hipertensi',
                              'Penyakit kardiovaskular',
                              'Penyakit ginjal kronis',
                              'Stroke',
                              'Tidak terindikasi penyakit di atas',
                            ];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kondisi Kesehatan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F8F8),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    children: options.map((option) {
                                      bool isSelected = conditionsList.contains(option) || 
                                                        (option == 'Tidak terindikasi penyakit di atas' && (conditionsList.isEmpty || conditionsList.contains('Sehat') || conditionsList.contains('Tidak terindikasi penyakit di atas')));
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                                              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                option,
                                                style: TextStyle(
                                                  color: isSelected ? const Color(0xFF2E7D32) : Colors.black54,
                                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          }),

                        ],
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final strImage = controller.pasienData['strImageBase64'];
                        if (strImage != null && strImage.toString().isNotEmpty) {
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: MemoryImage(base64Decode(strImage)),
                          );
                        }
                        return const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF2E7D32),
                          child: Icon(Icons.person, size: 60, color: Colors.white),
                        );
                      }
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ],
    ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          style: TextStyle(
            fontSize: 15,
            color: readOnly ? Colors.black54 : Colors.black87,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade400),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF8F8F8) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: readOnly ? Colors.grey.shade200 : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: readOnly ? Colors.grey.shade300 : const Color(0xFF2E7D32),
                width: readOnly ? 1.0 : 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

