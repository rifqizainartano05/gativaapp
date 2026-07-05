import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isObscure = true.obs;
  final isLoading = false.obs;

  void togglePassword() {
    isObscure.value = !isObscure.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Input Kosong',
        'Email dan Kata Sandi tidak boleh kosong',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
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

        // Dapatkan info device
        String deviceName = "Perangkat Tidak Dikenal";
        try {
          final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          if (GetPlatform.isAndroid) {
            AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
            deviceName = "${androidInfo.brand} ${androidInfo.model}";
          } else if (GetPlatform.isIOS) {
            IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
            deviceName = "${iosInfo.name} ${iosInfo.model}";
          } else if (GetPlatform.isWeb) {
            WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
            deviceName = webInfo.userAgent ?? "Web Browser";
          }
        } catch (e) {
          debugPrint("Gagal mendapat info device: $e");
        }

        // Initialize AuthService to fetch role safely (even during hot reload)
        AuthService authService;
        if (!Get.isRegistered<AuthService>()) {
          authService = await Get.putAsync(() => AuthService().init());
        } else {
          authService = Get.find<AuthService>();
        }
        await authService.fetchUserRole(user.uid);

        // Catat riwayat login
        await authService
            .getUserReference(user.uid)
            .collection('login_history')
            .add({
              'timestamp': FieldValue.serverTimestamp(),
              'method': 'email_password',
              'device': deviceName,
            });

        isLoading.value = false;
        if (authService.userRole.value == 'Pasien') {
          try {
            final pasienDoc = await authService.getUserReference(user.uid).get();
            final data = pasienDoc.data() as Map<String, dynamic>?;
            if (data != null && data['nakesUid'] == null) {
              Get.offAllNamed(Routes.SCAN_TENAGA_KESEHATAN_AKSES);
            } else {
              Get.offAllNamed(Routes.MAIN_NAVIGATION);
            }
          } catch (e) {
            Get.offAllNamed(Routes.MAIN_NAVIGATION);
          }
        } else if (authService.userRole.value == 'Tenaga Kesehatan') {
          try {
            final nakesDoc = await authService.getUserReference(user.uid).get();
            final data = nakesDoc.data() as Map<String, dynamic>?;
            
            String status = 'menunggu';
            if (data != null && data['status'] != null) {
              // Murni HANYA membaca field 'status' dan menangani kapitalisasi ("Disetujui")
              status = data['status'].toString().toLowerCase().trim();
            }
            
            if (status == 'disetujui') {
              Get.offAllNamed(Routes.NAKES_DASHBOARD);
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
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_empty_rounded, size: 60, color: Colors.orange.shade400),
                        const SizedBox(height: 16),
                        const Text('Menunggu Persetujuan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text(
                          'Akun Anda saat ini berstatus menunggu persetujuan admin. Anda tidak bisa login sampai akun disetujui.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade400,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
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
        message = 'Email dan password tidak sesuai.';
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
}

