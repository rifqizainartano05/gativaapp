import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/verifikasi_email_controller.dart';

class VerifikasiEmailView extends GetView<VerifikasiEmailController> {
  const VerifikasiEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verifikasi Email', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Watermark
            Positioned(
              right: -50,
              top: -20,
              child: Icon(
                Icons.mark_email_unread_rounded,
                size: 300,
                color: Colors.green.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mark_email_unread_rounded, size: 100, color: Color(0xFF2E7D32)),
                  const SizedBox(height: 32),
                  const Text(
                    'Cek Kotak Masuk Anda!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kami telah mengirimkan tautan verifikasi ke alamat email Anda. Silakan klik tautan tersebut untuk mengaktifkan akun Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: controller.checkEmailVerified,
                      child: const Text('Saya Sudah Verifikasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => TextButton(
                    onPressed: controller.isLoading.value ? null : controller.resendVerificationEmail,
                    child: controller.isLoading.value 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF2E7D32), strokeWidth: 2))
                      : const Text('Kirim Ulang Email', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                  )),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: controller.goToLogin,
                    child: const Text('Kembali ke Login', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
