import 'dart:convert';
import 'dart:io';
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

  // Nakes specific
  final strController = TextEditingController();
  final strImageBase64 = ''.obs;

  final selectedRole = 'Pasien'.obs;
  final roles = ['Pasien', 'Tenaga Kesehatan'];

  final selectedCondition = 'Sehat'.obs;

  final List<String> conditions = [
    'Sehat',
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
    if (age >= 5 && age <= 9) {
      switch (condition) {
        case 'Sehat':
          return 1200;
        case 'Hipertensi':
          return 1200;
        case 'Penyakit kardiovaskular':
          return 1000;
        case 'Penyakit ginjal kronis':
          return 800; // 800 - 1000
        case 'Stroke':
          return 0; // -
        default:
          return 1200;
      }
    } else if (age >= 10 && age <= 17) {
      switch (condition) {
        case 'Sehat':
          return 1500;
        case 'Hipertensi':
          return 1200;
        case 'Penyakit kardiovaskular':
          return 1000;
        case 'Penyakit ginjal kronis':
          return 800; // 800 - 1000
        case 'Stroke':
          return 0; // -
        default:
          return 1500;
      }
    } else if (age >= 18 && age <= 59) {
      switch (condition) {
        case 'Sehat':
          return 2000;
        case 'Hipertensi':
          return 1500;
        case 'Penyakit kardiovaskular':
          return 1500;
        case 'Penyakit ginjal kronis':
          return 1500;
        case 'Stroke':
          return 1500;
        default:
          return 2000;
      }
    } else {
      // Lansia 60+
      switch (condition) {
        case 'Sehat':
          return 1200;
        case 'Hipertensi':
          return 1000;
        case 'Penyakit kardiovaskular':
          return 1000; // 1000 - 1200
        case 'Penyakit ginjal kronis':
          return 1000;
        case 'Stroke':
          return 1000;
        default:
          return 1200;
      }
    }
  }

  Future<void> register() async {
    if (selectedRole.value == 'Tenaga Kesehatan') {
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
          calculatedLimit = calculateDailyLimit(age, selectedCondition.value);
        }

        // Save to main role collection (no separate profile subcollection)
        Map<String, dynamic> userData = {
          'name': nameController.text.trim(),
          'email': user.email,
          'age': age,
          'role': selectedRole.value,
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (selectedRole.value == 'Pasien') {
          userData['kondisi_kesehatan'] = selectedCondition.value;
          userData['dailyLimit'] = calculatedLimit;
        } else {
          userData['strNumber'] = strController.text.trim();
          userData['strImageBase64'] = strImageBase64.value;
          userData['status'] = 'menunggu'; // Set awal ke menunggu
        }

        String subCollectionName = selectedRole.value == 'Pasien'
            ? 'pasien'
            : 'tenaga_kesehatan';

        final userDocRef = FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection(subCollectionName)
            .doc(user.uid);

        // Save all data to the role document directly (status 'menunggu' untuk nakes)
        await userDocRef.set(userData);

        if (selectedRole.value == 'Tenaga Kesehatan') {
          isLoading.value = false; // Matikan loading agar popup terlihat jelas

          // Meminta kode akses admin setelah data tersimpan (status masih menunggu)
          final TextEditingController codeController = TextEditingController();
          String? verificationStatus = await Get.dialog<String>(
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
                            Icons.verified_user_rounded,
                            color: Color(0xFF2E7D32),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Verifikasi Admin',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Masukkan kode akses dari admin untuk mendaftar sebagai Tenaga Kesehatan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: codeController,
                          decoration: InputDecoration(
                            hintText: 'Kode Akses Admin (Wajib)',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Get.back(result: null),
                                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final inputCode = codeController.text.trim();
                                  
                                  if (inputCode.isEmpty) {
                                    Get.snackbar(
                                      'Gagal',
                                      'Kode akses wajib diisi.',
                                      backgroundColor: Colors.red.withOpacity(0.1),
                                      colorText: Colors.red,
                                    );
                                    return;
                                  }
                                  
                                  try {
                                    // Coba query sebagai String di dalam sub collection tenaga_kesehatan
                                    var snapshot = await FirebaseFirestore.instance
                                        .collection('mobile')
                                        .doc('roles')
                                        .collection('tenaga_kesehatan')
                                        .where('kode_akses', isEqualTo: inputCode)
                                        .limit(1)
                                        .get();
                                        
                                    // Jika tidak ketemu, coba query sebagai integer
                                    if (snapshot.docs.isEmpty) {
                                      int? codeInt = int.tryParse(inputCode);
                                      if (codeInt != null) {
                                        snapshot = await FirebaseFirestore.instance
                                            .collection('mobile')
                                            .doc('roles')
                                            .collection('tenaga_kesehatan')
                                            .where('kode_akses', isEqualTo: codeInt)
                                            .limit(1)
                                            .get();
                                      }
                                    }
                                    
                                    if (snapshot.docs.isNotEmpty) {
                                      // Jika kode ditemukan, biarkan lanjut
                                      // Status tetap menunggu, tidak diubah ke disetujui
                                      // agar setelah verifikasi email dan saat login, statusnya tetap menunggu persetujuan admin.
                                      Get.back(result: 'menunggu'); 
                                    } else {
                                      Get.snackbar(
                                        'Gagal',
                                        'Kode akses admin tidak valid (tidak ditemukan).',
                                        backgroundColor: Colors.red.withOpacity(0.1),
                                        colorText: Colors.red,
                                      );
                                    }
                                  } catch (e) {
                                    Get.snackbar(
                                      'Error',
                                      'Gagal memeriksa kode: $e',
                                      backgroundColor: Colors.red.withOpacity(0.1),
                                      colorText: Colors.red,
                                      duration: const Duration(seconds: 5),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Lanjutkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            barrierDismissible: false,
          );

          // Jika Batal (null), hentikan dan jangan ke halaman verifikasi email (user sudah dibuat dgn status menunggu)
          if (verificationStatus == null) return;
        }

        isLoading.value = true;
        // Send email verification
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }
      }

      isLoading.value = false;
      // Semua role diarahkan ke VERIFIKASI_EMAIL terlebih dahulu
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
