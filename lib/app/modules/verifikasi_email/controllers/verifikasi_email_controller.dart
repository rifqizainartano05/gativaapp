import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';

class VerifikasiEmailController extends GetxController {
  final isLoading = false.obs;
  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    // Opsional: Cek berkala setiap 3 detik
    timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
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
        Get.offAllNamed(Routes.LOGIN);
        Get.snackbar('Sukses', 'Email berhasil diverifikasi! Silakan masuk.', backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
      }
    }
  }

  Future<void> resendVerificationEmail() async {
    isLoading.value = true;
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Get.snackbar('Berhasil', 'Tautan verifikasi telah dikirim ulang.', backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan saat mengirim ulang tautan.', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.offAllNamed(Routes.LOGIN);
  }
}
