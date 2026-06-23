import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;

  Future<void> sendResetLink() async {
    if (emailController.text.isEmpty) {
      Get.snackbar('Input Kosong', 'Harap masukkan alamat email Anda', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    isLoading.value = true;
    
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      
      isLoading.value = false;
      Get.snackbar('Berhasil', 'Tautan pemulihan telah dikirim ke email Anda. Silakan periksa kotak masuk atau spam.', backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
      
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = 'Terjadi kesalahan.';
      if (e.code == 'user-not-found') {
        message = 'Tidak ada pengguna dengan email ini.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      }
      Get.snackbar('Gagal', message, backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    }
  }
}
