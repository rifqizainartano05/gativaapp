import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF2E7D32),
            ),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Buat Akun Baru',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E7D32),
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned(
              right: -40,
              top: -20,
              child: Icon(
                Icons.medical_information,
                size: 200,
                color: const Color(0xFF2E7D32).withOpacity(0.05),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih peran dan lengkapi informasi Anda.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                const SizedBox(height: 24),

                // Role Toggle Bar
                _buildRoleToggleBar(),
                const SizedBox(height: 32),

                // Common Fields
                const Text(
                  'Nama Lengkap',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller.nameController,
                  'Masukkan nama lengkap',
                  Icons.person_outline_rounded,
                  false,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller.emailController,
                  'Masukkan email',
                  Icons.email_outlined,
                  false,
                  TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                Obx(() => controller.selectedRole.value == 'Pasien'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Usia (Tahun)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller.ageController,
                            'Contoh: 25',
                            Icons.cake_outlined,
                            false,
                            TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                        ],
                      )
                    : const SizedBox.shrink()),

                const Text(
                  'Kata Sandi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller.passwordController,
                  'Buat kata sandi',
                  Icons.lock_outline_rounded,
                  true,
                  TextInputType.text,
                  controller.isPasswordObscure,
                  controller.togglePassword,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Konfirmasi Kata Sandi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller.confirmPasswordController,
                  'Ulangi kata sandi',
                  Icons.lock_outline_rounded,
                  true,
                  TextInputType.text,
                  controller.isConfirmPasswordObscure,
                  controller.toggleConfirmPassword,
                ),
                const SizedBox(height: 32),

                // Dynamic Fields based on Role
                Obx(
                  () => controller.selectedRole.value == 'Pasien'
                      ? _buildPasienFields()
                      : _buildDokterFields(),
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      shadowColor: const Color(0xFF2E7D32).withOpacity(0.5),
                    ),
                    onPressed: controller.register,
                    child: Obx(
                      () => controller.isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Selesai & Daftar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: controller.goToLogin,
                      child: const Text(
                        'Masuk di sini',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        ),
      ],
    ),
  ),
);
  }

  Widget _buildRoleToggleBar() {
    return Obx(() {
      bool isPasien = controller.selectedRole.value == 'Pasien';
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedRole.value = 'Pasien',
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isPasien
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Pasien',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPasien ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedRole.value = 'Dokter',
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !isPasien
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Dokter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !isPasien ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPasienFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gejala Yang Dialami',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pilih gejala kesehatan Anda saat ini (bisa lebih dari satu) untuk rekomendasi asupan natrium.',
          style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 16),
        Obx(() {
          bool isTidakTerindikasi = controller.selectedConditions.contains('Tidak terindikasi penyakit di atas');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label Utama
              const Text(
                'Terindikasi penyakit berkaitan Natrium:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // List Penyakit Spesifik
              ...controller.conditions.map((condition) {
                bool isSelected = controller.selectedConditions.contains(condition);
                
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      controller.selectedConditions.remove(condition);
                      // Jika semua penyakit dihapus, otomatis pilih 'Tidak terindikasi'
                      if (controller.selectedConditions.isEmpty) {
                        controller.selectedConditions.add('Tidak terindikasi penyakit di atas');
                      }
                    } else {
                      controller.selectedConditions.remove('Tidak terindikasi penyakit di atas');
                      controller.selectedConditions.add(condition);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16, left: 16), // Di-indent sedikit ke dalam
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2E7D32).withOpacity(0.1)
                          : isTidakTerindikasi 
                              ? Colors.grey.shade50 // Disabled look
                              : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2E7D32)
                            : isTidakTerindikasi 
                                ? Colors.grey.shade200 // Disabled border
                                : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          color: isSelected
                              ? const Color(0xFF2E7D32)
                              : isTidakTerindikasi 
                                  ? Colors.grey.shade300 // Disabled icon
                                  : Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            condition,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : isTidakTerindikasi 
                                      ? Colors.grey.shade400 // Disabled text
                                      : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),

              // Opsi Tidak Terindikasi
              GestureDetector(
                onTap: () {
                  if (!isTidakTerindikasi) {
                    controller.selectedConditions.clear();
                    controller.selectedConditions.add('Tidak terindikasi penyakit di atas');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isTidakTerindikasi
                        ? const Color(0xFF2E7D32).withOpacity(0.1)
                        : Colors.white,
                    border: Border.all(
                      color: isTidakTerindikasi
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade300,
                      width: isTidakTerindikasi ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isTidakTerindikasi
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: isTidakTerindikasi
                            ? const Color(0xFF2E7D32)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Tidak terindikasi penyakit di atas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isTidakTerindikasi
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isTidakTerindikasi
                                ? const Color(0xFF2E7D32)
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDokterFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Profesi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Lengkapi nomor STR dan unggah bukti STR untuk verifikasi profesi.',
          style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 16),

        const Text(
          'Nomor STR',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller.strController,
          'Masukkan Nomor STR',
          Icons.badge_outlined,
          false,
        ),
        const SizedBox(height: 24),

        const Text(
          'Foto Bukti STR',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: controller.pickStrImage,
          child: Obx(
            () => Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: controller.strImageBase64.value.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        base64Decode(controller.strImageBase64.value),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ketuk untuk mengunggah foto',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController txtController,
    String hint,
    IconData icon,
    bool isPassword, [
    TextInputType type = TextInputType.text,
    RxBool? obscureState,
    VoidCallback? onToggleObscure,
  ]) {
    Widget buildTextFieldWidget(bool isObscured) {
      return TextField(
        controller: txtController,
        obscureText: isObscured,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon:
              isPassword && obscureState != null && onToggleObscure != null
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: isPassword && obscureState != null
          ? Obx(() => buildTextFieldWidget(obscureState.value))
          : buildTextFieldWidget(false),
    );
  }
}
