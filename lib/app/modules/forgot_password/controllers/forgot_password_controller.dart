import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;

  void _showPopup({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    bool isSuccess = false,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Watermark
              Positioned(
                right: -30,
                top: -20,
                child: Icon(
                  icon,
                  size: 160,
                  color: color.withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Get.back(); // close dialog
                          if (isSuccess) {
                            Get.back(); // back to login
                          }
                        },
                        child: Text(
                          isSuccess ? 'Kembali ke Login' : 'Tutup',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
      ),
      barrierDismissible: !isSuccess,
    );
  }

  Future<void> sendResetLink() async {
    if (emailController.text.isEmpty) {
      _showPopup(
        title: 'Input Kosong',
        message: 'Harap masukkan alamat email Anda terlebih dahulu.',
        icon: Icons.warning_rounded,
        color: Colors.orange,
      );
      return;
    }

    isLoading.value = true;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      isLoading.value = false;
      _showPopup(
        title: 'Berhasil!',
        message: 'Tautan pemulihan telah dikirim ke email Anda. Silakan periksa kotak masuk atau spam.',
        icon: Icons.mark_email_read_rounded,
        color: const Color(0xFF2E7D32),
        isSuccess: true,
      );

    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = 'Terjadi kesalahan pada sistem.';
      if (e.code == 'user-not-found') {
        message = 'Tidak ada pengguna dengan email ini.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      } else if (e.code == 'too-many-requests') {
        message = 'Terlalu banyak percobaan gagal. Silakan coba lagi nanti.';
      } else if (e.code == 'network-request-failed') {
        message = 'Koneksi internet bermasalah. Harap periksa jaringan Anda.';
      }
      _showPopup(
        title: 'Gagal',
        message: message,
        icon: Icons.error_outline_rounded,
        color: Colors.red,
      );
    } catch (e) {
      isLoading.value = false;
      _showPopup(
        title: 'Gagal',
        message: 'Terjadi kesalahan: $e',
        icon: Icons.error_outline_rounded,
        color: Colors.red,
      );
    }
  }
}
