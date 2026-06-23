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
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
            onPressed: () {
              if (controller.currentPage.value == 1) {
                controller.previousPage();
              } else {
                Get.back();
              }
            },
          ),
        ),
        body: SafeArea(
          child: PageView(
            controller: controller.pageController,
            physics: const NeverScrollableScrollPhysics(), // Supaya tidak bisa di-swipe secara manual
            children: [
              _buildStep1(),
              _buildStep2(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Langkah 1: Data Pribadi',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lengkapi informasi dasar Anda untuk memulai.',
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 32),
          
          const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildTextField(controller.nameController, 'Masukkan nama lengkap', Icons.person_outline_rounded, false),
          const SizedBox(height: 16),

          const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildTextField(controller.emailController, 'Masukkan email', Icons.email_outlined, false, TextInputType.emailAddress),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Usia (Tahun)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    _buildTextField(controller.ageController, 'Contoh: 25', Icons.cake_outlined, false, TextInputType.number),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildTextField(controller.passwordController, 'Buat kata sandi', Icons.lock_outline_rounded, true, TextInputType.text, controller.isPasswordObscure, controller.togglePassword),
          const SizedBox(height: 16),

          const Text('Konfirmasi Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildTextField(controller.confirmPasswordController, 'Ulangi kata sandi', Icons.lock_outline_rounded, true, TextInputType.text, controller.isConfirmPasswordObscure, controller.toggleConfirmPassword),
          
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                shadowColor: const Color(0xFF2E7D32).withOpacity(0.5),
              ),
              onPressed: controller.nextPage,
              child: const Text('Selanjutnya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Sudah punya akun?', style: TextStyle(color: Colors.grey)),
              TextButton(
                onPressed: controller.goToLogin,
                child: const Text('Masuk di sini', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Langkah 2: Kondisi Kesehatan',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih kondisi kesehatan Anda saat ini agar kami dapat menyesuaikan rekomendasi batasan natrium yang tepat.',
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 32),
          
          Obx(() => Column(
            children: controller.conditions.map((condition) {
              bool isSelected = controller.selectedCondition.value == condition;
              return GestureDetector(
                onTap: () {
                  controller.selectedCondition.value = condition;
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2E7D32).withOpacity(0.1) : Colors.white,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          condition,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                shadowColor: const Color(0xFF2E7D32).withOpacity(0.5),
              ),
              onPressed: controller.register,
              child: Obx(() => controller.isLoading.value 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('Selesai & Daftar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController txtController, 
    String hint, 
    IconData icon, 
    bool isPassword, 
    [TextInputType type = TextInputType.text, RxBool? obscureState, VoidCallback? onToggleObscure]
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Obx(() {
        bool isObscured = isPassword && obscureState != null ? obscureState.value : false;
        return TextField(
          controller: txtController,
          obscureText: isObscured,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: isPassword && obscureState != null && onToggleObscure != null
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        );
      }),
    );
  }
}
