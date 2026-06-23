import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isFetching.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informasi Dasar'),
              _buildCard(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: controller.nameController,
                      label: 'Nama Lengkap',
                      icon: Icons.person_outline_rounded,
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildTextField(
                      controller: controller.ageController,
                      label: 'Usia (Tahun)',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Riwayat Medis', subtitle: 'Bantu kami memberikan rekomendasi asupan natrium yang tepat.'),
              _buildCard(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: controller.tensiController,
                      label: 'Tekanan Darah (Tensi)',
                      hint: 'Contoh: 120/80',
                      icon: Icons.favorite_border_rounded,
                      readOnly: true,
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildTextField(
                      controller: controller.beratBadanController,
                      label: 'Berat Badan (kg)',
                      hint: 'Contoh: 65',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildTextField(
                      controller: controller.tinggiBadanController,
                      label: 'Tinggi Badan (cm)',
                      hint: 'Contoh: 170',
                      icon: Icons.height_outlined,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.health_and_safety_outlined, color: Colors.grey, size: 22),
                              const SizedBox(width: 12),
                              Text('Kondisi Kesehatan', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F6F8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.selectedCondition.value,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w500),
                                items: controller.conditions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    controller.selectedCondition.value = newValue;
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: const Color(0xFF2E7D32).withOpacity(0.4),
                  ),
                  onPressed: controller.isLoading.value ? null : controller.updateProfile,
                  child: controller.isLoading.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: TextStyle(
        fontSize: 15, 
        fontWeight: FontWeight.w500,
        color: readOnly ? Colors.grey.shade600 : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey, size: 22),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
