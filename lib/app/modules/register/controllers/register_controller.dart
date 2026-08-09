import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../../routes/app_pages.dart';
class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ageController = TextEditingController();

  // Dokter specific
  final strController = TextEditingController();
  final strImageBase64 = ''.obs;

  final selectedRole = 'Pasien'.obs;
  final roles = ['Pasien', 'Dokter'];

  final selectedConditions = <String>['Tidak terindikasi penyakit di atas'].obs;

  final List<String> conditions = [
    'Hipertensi',
    'Penyakit kardiovaskular',
    'Penyakit ginjal kronis',
    'Stroke',
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

  Future<void> pickStrImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // compress to avoid firestore document size limit (1MB)
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Firestore document limit is 1MB. Ensure base64 string is not too large.
      if (base64Image.length > 800000) {
        Get.snackbar(
          'Gambar Terlalu Besar',
          'Silakan pilih gambar dengan ukuran lebih kecil',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }

      strImageBase64.value = base64Image;
    }
  }

  double calculateDailyLimit(int age, String condition) {
    String c = condition.trim().toLowerCase();
    List<String> conditions = c.split(',').map((e) => e.trim()).toList();
    
    double minLimit = 2000;

    for (String cond in conditions) {
      double limit = 2000;
      
      if (age >= 10 && age <= 18) {
        if (cond.contains('sehat') || cond.contains('tidak terindikasi')) limit = 1500;
        else if (cond.contains('hipertensi')) limit = 1200;
        else if (cond.contains('kardiovaskular')) limit = 1000;
        else if (cond.contains('jantung')) limit = 1000;
        else if (cond.contains('ginjal')) limit = 800;
        else if (cond.contains('stroke')) limit = 0;
        else limit = 1500;
      } else if (age >= 18 && age <= 59) {
        if (cond.contains('sehat') || cond.contains('tidak terindikasi')) limit = 2000;
        else if (cond.contains('hipertensi')) limit = 1500;
        else if (cond.contains('kardiovaskular')) limit = 1500;
        else if (cond.contains('jantung')) limit = 1500;
        else if (cond.contains('ginjal')) limit = 1500;
        else if (cond.contains('stroke')) limit = 1500;
        else limit = 2000;
      } else {
        if (age >= 5 && age <= 9) {
          if (cond.contains('sehat') || cond.contains('tidak terindikasi')) limit = 1200;
          else if (cond.contains('hipertensi')) limit = 1200;
          else if (cond.contains('kardiovaskular')) limit = 1000;
          else if (cond.contains('jantung')) limit = 1000;
          else if (cond.contains('ginjal')) limit = 1000;
          else if (cond.contains('stroke')) limit = 0;
          else limit = 1200;
        } else if (age >= 60) {
          if (cond.contains('sehat') || cond.contains('tidak terindikasi')) limit = 1200;
          else if (cond.contains('hipertensi')) limit = 1000;
          else if (cond.contains('kardiovaskular')) limit = 1200;
          else if (cond.contains('jantung')) limit = 1200;
          else if (cond.contains('ginjal')) limit = 1000;
          else if (cond.contains('stroke')) limit = 1000;
          else if (cond.contains('osteoporosis')) limit = 2300;
          else limit = 1200;
        }
      }
      if (limit < minLimit) {
        minLimit = limit;
      }
    }
    
    return minLimit;
  }

  Future<void> register() async {
    if (selectedRole.value == 'Dokter') {
      if (strController.text.isEmpty) {
        Get.snackbar(
          'Input Kosong',
          'Harap isi Nomor STR',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }
      if (strImageBase64.value.isEmpty) {
        Get.snackbar(
          'Gagal',
          'Harap unggah foto bukti STR',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }
    }

    isLoading.value = true;
    String? verificationStatus;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(nameController.text.trim());

        int age = int.tryParse(ageController.text) ?? 20;
        double? calculatedLimit;

        if (selectedRole.value == 'Pasien') {
          calculatedLimit = calculateDailyLimit(age, selectedConditions.join(', '));
        }

        // Save to main role collection (no separate profile subcollection)
        Map<String, dynamic> userData = {
          'name': nameController.text.trim(),
          'email': user.email,
          'age': age,
          'role': selectedRole.value,
          'createdAt': FieldValue.serverTimestamp(),
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        };

        if (selectedRole.value == 'Pasien') {
          userData['kondisi_kesehatan'] = selectedConditions.join(', ');
          userData['dailyLimit'] = calculatedLimit;
        } else {
          userData['strNumber'] = strController.text.trim();
          userData['strImageBase64'] = strImageBase64.value;
          userData['status'] = 'menunggu'; // Set awal ke menunggu
        }

        String subCollectionName = selectedRole.value == 'Pasien'
            ? 'pasien'
            : 'dokter';

        final userDocRef = FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection(subCollectionName)
            .doc(user.uid);

        // Save all data to the role document directly (status 'menunggu' untuk dokter)
        await userDocRef.set(userData);


        isLoading.value = true;
        // Send email verification
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }
      }

      isLoading.value = false;
      // Semua role diarahkan ke VERIFIKASI_EMAIL terlebih dahulu
      if (selectedRole.value == 'Dokter') {
         Get.offAllNamed(Routes.VERIFIKASI_EMAIL, arguments: {'role': 'Dokter', 'strNumber': strController.text.trim(), 'name': nameController.text.trim()});
      } else {
         Get.offAllNamed(Routes.VERIFIKASI_EMAIL);
      }
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
      Get.snackbar(
        'Pendaftaran Gagal',
        message,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Pendaftaran Gagal',
        'Terjadi error: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void goToLogin() {
    Get.back();
  }
}
