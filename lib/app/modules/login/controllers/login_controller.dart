import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/presence_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isObscure = true.obs;
  final isLoading = false.obs;

  void togglePassword() {
    isObscure.value = !isObscure.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan password tidak boleh kosong',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    // INTERCEPT ADMIN LOGIN
    if (email == 'gativa@administrator') {
      if (password == 'Gativa!Admin26*') {
        emailController.clear();
        passwordController.clear();
        Get.offAllNamed(Routes.HOME_ADMINISTRATOR);
        return;
      } else {
        Get.snackbar(
          'Akses Ditolak',
          'Kata sandi administrator salah!',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }
    }

    isLoading.value = true;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      User? user = userCredential.user;
      if (user != null) {
        // Cek verifikasi email
        if (!user.emailVerified) {
          isLoading.value = false;
          Get.snackbar(
            'Email Belum Diverifikasi',
            'Silakan periksa kotak masuk email Anda dan klik tautan verifikasi.',
            backgroundColor: Colors.orange.withOpacity(0.1),
            colorText: Colors.orange,
          );
          return;
        }

        // Initialize AuthService to fetch role safely (even during hot reload)
        AuthService authService;
        if (!Get.isRegistered<AuthService>()) {
          authService = await Get.putAsync(() => AuthService().init());
        } else {
          authService = Get.find<AuthService>();
        }
        await authService.fetchUserRole(user.uid);

        // Update presence in Firebase now that we know the role
        if (Get.isRegistered<PresenceService>()) {
          Get.find<PresenceService>().updatePresence(true);
        }

        isLoading.value = false;
        if (authService.userRole.value == 'Pasien') {
          Get.offAllNamed(Routes.MAIN_NAVIGATION);
        } else if (authService.userRole.value == 'Tenaga Kesehatan') {
          try {
            final dokterDoc = await authService.getUserReference(user.uid).get();
            final data = dokterDoc.data() as Map<String, dynamic>?;
            
            String status = 'menunggu';
            if (data != null) {
              if (data['status'] != null) {
                // Murni HANYA membaca field 'status' dan menangani kapitalisasi ("Disetujui")
                status = data['status'].toString().toLowerCase().trim();
              }
            }
            
            if (status == 'disetujui') {
              Get.offAllNamed(Routes.HOME_DOKTER);
            } else if (status == 'ditolak') {
              await FirebaseAuth.instance.signOut();
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cancel_rounded, size: 60, color: Colors.red.shade400),
                        const SizedBox(height: 16),
                        const Text('Akses Ditolak', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text(
                          'Akun pendaftaran Anda ditolak oleh admin. Anda tidak bisa login.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              // status == 'menunggu'
              await FirebaseAuth.instance.signOut();
              await FirebaseAuth.instance.signOut();
              
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Colors.white,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Watermark Icon
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
                              'Akun Anda masih menunggu persetujuan admin dari Telegram. Anda belum bisa masuk sampai admin menyetujui.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Get.back(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          } catch (e) {
            Get.offAllNamed(Routes.MAIN_NAVIGATION);
          }
        } else {
          // Fallback if role is unknown
          Get.offAllNamed(Routes.MAIN_NAVIGATION);
        }
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = 'Terjadi kesalahan saat masuk.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Data tidak tersedia atau hapus.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      }
      
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Watermark Icon
              Positioned(
                right: -20,
                bottom: -20,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 150,
                    color: Colors.red.withOpacity(0.05),
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
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal Masuk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Mengerti',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Gagal Masuk',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
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
}

