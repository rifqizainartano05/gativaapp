import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/nakes_detail_pasien_gativa_controller.dart';

class NakesDetailPasienGativaView
    extends GetView<NakesDetailPasienGativaController> {
  const NakesDetailPasienGativaView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final bool readOnly = (args is Map && args['readOnly'] == true);
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
                    // Natrium Box (Moved to top & Beautified)
                    Obx(() {
                      final natrium = controller.pasienData['natrium'] ?? controller.pasienData['totalNatrium'] ?? controller.pasienData['sodium'] ?? 0;
                      final dailyLimit = controller.pasienData['dailyLimit'] ?? controller.pasienData['limitNatrium'] ?? 2000;
                      // Calculate percentage for progress
                      final double percentage = (dailyLimit > 0) ? (natrium / dailyLimit).clamp(0.0, 1.0) : 0.0;
                      final bool isWarning = natrium >= dailyLimit;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24, top: 8),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isWarning 
                                ? [Colors.red.shade400, Colors.red.shade600]
                                : [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (isWarning ? Colors.red : const Color(0xFF2E7D32)).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Watermark Icon
                            Positioned(
                              right: -20,
                              bottom: -20,
                              child: Icon(
                                Icons.water_drop_rounded,
                                size: 120,
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.science_outlined,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Asupan Natrium Harian',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '$natrium',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 6, left: 4),
                                        child: Text(
                                          'mg',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'Batas Maksimal',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Text(
                                            '$dailyLimit mg',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: percentage,
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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
                              _buildInputField(
                                label: 'Kondisi Kesehatan',
                                controller: controller.kondisiKesehatanController,
                                icon: Icons.favorite_border_rounded,
                                readOnly: readOnly,
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                label: 'Tinggi (cm)',
                                controller: controller.tinggiBadanController,
                                icon: Icons.height_rounded,
                                keyboardType: TextInputType.number,
                                readOnly: readOnly,
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                label: 'Berat Badan (kg)',
                                controller: controller.beratBadanController,
                                icon: Icons.scale_rounded,
                                keyboardType: TextInputType.number,
                                readOnly: readOnly,
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                label: 'Tekanan Darah',
                                controller: controller.tekananDarahController,
                                icon: Icons.bloodtype_outlined,
                                readOnly: readOnly,
                              ),
                              const SizedBox(height: 32),
                              _buildSectionTitle('Catatan Nakes'),
                              const SizedBox(height: 16),
                              Obx(() => Column(
                                children: [
                                  for (int i = 0; i < controller.catatanList.length; i++)
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF86EFAC)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(top: 2),
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2E7D32).withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.format_quote_rounded, color: Color(0xFF2E7D32), size: 14),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              controller.catatanList[i],
                                              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                                            ),
                                          ),
                                          if (!readOnly) ...[  
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () => controller.catatanList.removeAt(i),
                                              child: Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.red.shade200),
                                                ),
                                                child: Icon(Icons.close_rounded, size: 14, color: Colors.red.shade600),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                ],
                              )),
                              if (!readOnly) ...[  
                                const SizedBox(height: 12),
                                _buildInputField(
                                  label: 'Tambah Catatan Baru',
                                  controller: controller.newCatatanController,
                                  icon: Icons.add_comment_outlined,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      if (controller.newCatatanController.text.trim().isNotEmpty) {
                                        controller.catatanList.add(controller.newCatatanController.text.trim());
                                        controller.newCatatanController.clear();
                                      }
                                    },
                                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                                    label: const Text('Tambah ke Daftar', style: TextStyle(fontWeight: FontWeight.w600)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF2E7D32),
                                      side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                    ),
                                  ),
                                ),
                              ],
                              if (!readOnly) ...[  
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: Obx(() => ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () {
                                            controller.saveChanges();
                                          },
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Simpan Perubahan',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  )),
                                ),
                              ],
                            ],
                          ),
                    ),
                    Obx(() {
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
                    }),
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

