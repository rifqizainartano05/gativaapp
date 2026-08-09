import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifikasiEmailController extends GetxController {
  final isLoading = false.obs;
  Timer? timer;
  String? role;
  String? kodeAkses;

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments != null) {
      role = Get.arguments['role'];
    }

    // Opsional: Cek berkala setiap 3 detik
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => checkEmailVerified(),
    );
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  Future<void> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // Wajib agar data terbaru dari server ditarik
      if (user.emailVerified) {
        timer?.cancel();
        
        // Cek jika role Dokter, langsung berikan pop up menunggu persetujuan admin.
        if (role == 'Dokter') {
          await FirebaseAuth.instance.signOut(); // Pastikan sesi logout
          
          // 3. Tampilkan Dialog Menunggu Persetujuan
          await Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 150,
                        color: const Color(0xFF2E7D32).withOpacity(0.05),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.hourglass_empty_rounded,
                            color: Color(0xFF2E7D32),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Menunggu Persetujuan',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Pendaftaran Anda telah dikirim ke admin untuk diverifikasi. Harap tunggu persetujuan sebelum Anda dapat masuk.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              Get.offAllNamed(Routes.LOGIN);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Ke Halaman Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            barrierDismissible: false,
          );
        } else {
          await FirebaseAuth.instance.signOut(); // Pastikan sesi logout
          await showSuccessDialog('Verifikasi Berhasil', 'Email Anda telah berhasil diverifikasi! Anda sekarang dapat masuk ke aplikasi.');
          Get.offAllNamed(Routes.LOGIN);
        }
      }
    }
  }

  Future<void> showSuccessDialog(String title, String message) async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Transform.rotate(
                angle: -0.2,
                child: Icon(
                  Icons.mark_email_read_rounded,
                  size: 150,
                  color: const Color(0xFF2E7D32).withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF2E7D32),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Mengerti',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> resendVerificationEmail() async {
    isLoading.value = true;
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Get.snackbar(
          'Berhasil',
          'Tautan verifikasi telah dikirim ulang.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat mengirim ulang tautan.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
