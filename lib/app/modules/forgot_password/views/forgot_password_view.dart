import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

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
        body: Stack(
          children: [
            // Watermark Icon
            Positioned(
              top: -50,
              right: -50,
              child: Icon(
                Icons.lock_reset_rounded,
                size: 300,
                color: const Color(0xFF2E7D32).withOpacity(0.05),
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mark_email_read_rounded, size: 40, color: Color(0xFF2E7D32)),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Lupa Kata Sandi?',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Jangan khawatir! Masukkan email yang terdaftar dan kami akan mengirimkan tautan pemulihan untuk mengatur ulang kata sandi Anda.',
                            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                          ),
                          const SizedBox(height: 40),
                          
                          // Form Email
                          const Text('Alamat Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan email Anda',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
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
                                shadowColor: const Color(0xFF2E7D32).withOpacity(0.5),
                              ),
                              onPressed: controller.sendResetLink,
                              child: Obx(() => controller.isLoading.value 
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                : const Text('Kirim Tautan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
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
