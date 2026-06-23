import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ageController = TextEditingController();
  
  final selectedCondition = 'Sehat'.obs;
  
  final List<String> conditions = [
    'Sehat',
    'Hipertensi',
    'Penyakit kardiovaskular',
    'Penyakit jantung koroner',
    'Penyakit ginjal kronis',
    'Stroke'
  ];

  final isPasswordObscure = true.obs;
  final isConfirmPasswordObscure = true.obs;
  final isLoading = false.obs;

  void togglePassword() {
    isPasswordObscure.value = !isPasswordObscure.value;
  }
  
  void toggleConfirmPassword() {
    isConfirmPasswordObscure.value = !isConfirmPasswordObscure.value;
  }

  void nextPage() {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty || ageController.text.isEmpty) {
      Get.snackbar('Input Kosong', 'Harap isi semua kolom pendaftaran', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Kesalahan', 'Kata sandi tidak cocok', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }
    int? age = int.tryParse(ageController.text);
    if (age == null || age < 5) {
      Get.snackbar('Kesalahan', 'Usia tidak valid (Minimal 5 tahun)', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    currentPage.value = 1;
  }

  void previousPage() {
    pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    currentPage.value = 0;
  }

  double calculateDailyLimit(int age, String condition) {
    if (age >= 5 && age <= 9) {
      switch (condition) {
        case 'Sehat': return 1200;
        case 'Hipertensi': return 1200;
        case 'Penyakit kardiovaskular': return 1000;
        case 'Penyakit jantung koroner': return 1000;
        case 'Penyakit ginjal kronis': return 800; // 800 - 1000
        case 'Stroke': return 0; // -
        default: return 1200;
      }
    } else if (age >= 10 && age <= 17) {
      switch (condition) {
        case 'Sehat': return 1500;
        case 'Hipertensi': return 1200;
        case 'Penyakit kardiovaskular': return 1000;
        case 'Penyakit jantung koroner': return 1000;
        case 'Penyakit ginjal kronis': return 800; // 800 - 1000
        case 'Stroke': return 0; // -
        default: return 1500;
      }
    } else if (age >= 18 && age <= 59) {
      switch (condition) {
        case 'Sehat': return 2000;
        case 'Hipertensi': return 1500;
        case 'Penyakit kardiovaskular': return 1500;
        case 'Penyakit jantung koroner': return 1500;
        case 'Penyakit ginjal kronis': return 1500;
        case 'Stroke': return 1500;
        default: return 2000;
      }
    } else {
      // Lansia 60+
      switch (condition) {
        case 'Sehat': return 1200;
        case 'Hipertensi': return 1000;
        case 'Penyakit kardiovaskular': return 1000; // 1000 - 1200
        case 'Penyakit jantung koroner': return 1000; // 1000 - 1200
        case 'Penyakit ginjal kronis': return 1000;
        case 'Stroke': return 1000;
        default: return 1200;
      }
    }
  }

  Future<void> register() async {
    isLoading.value = true;
    
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(nameController.text.trim());
        
        int age = int.tryParse(ageController.text) ?? 20;
        double calculatedLimit = calculateDailyLimit(age, selectedCondition.value);

        // Sesuai instruksi: hapus sub collection data, kembali ke users/{uid} untuk user profile, dan hapus totalNatrium
        await FirebaseFirestore.instance.collection('mobile').doc(user.uid).set({
          'name': nameController.text.trim(),
          'email': user.email,
          'age': age,
          'kondisi': selectedCondition.value,
          'dailyLimit': calculatedLimit,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Send email verification
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }
      }
      
      isLoading.value = false;
      // Pindah ke verifikasi email
      Get.offAllNamed(Routes.VERIFIKASI_EMAIL);
      
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = 'Terjadi kesalahan saat mendaftar.';
      if (e.code == 'weak-password') {
        message = 'Kata sandi terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email ini sudah terdaftar sebelumnya.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      }
      Get.snackbar('Pendaftaran Gagal', message, backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Pendaftaran Gagal', 'Terjadi error: $e', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    }
  }

  void goToLogin() {
    Get.back();
  }
}
