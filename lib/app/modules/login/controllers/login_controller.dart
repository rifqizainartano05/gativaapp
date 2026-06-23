import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../routes/app_pages.dart';

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
      Get.snackbar('Input Kosong', 'Email dan Kata Sandi tidak boleh kosong', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    isLoading.value = true;
    
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      User? user = userCredential.user;
      if (user != null) {
        // Cek verifikasi email
        if (!user.emailVerified) {
          isLoading.value = false;
          Get.snackbar('Email Belum Diverifikasi', 'Silakan periksa kotak masuk email Anda dan klik tautan verifikasi.', backgroundColor: Colors.orange.withOpacity(0.1), colorText: Colors.orange);
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

        // Catat riwayat login
        await FirebaseFirestore.instance.collection('mobile').doc(user.uid).collection('login_history').add({
          'timestamp': FieldValue.serverTimestamp(),
          'method': 'email_password',
          'device': deviceName,
        });
      }
      
      isLoading.value = false;
      Get.offAllNamed(Routes.MAIN_NAVIGATION);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = 'Terjadi kesalahan saat masuk.';
      if (e.code == 'user-not-found') {
        message = 'Tidak ada pengguna dengan email ini.';
      } else if (e.code == 'wrong-password') {
        message = 'Kata sandi salah.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      }
      Get.snackbar('Gagal Masuk', message, backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Gagal Masuk', 'Terjadi kesalahan: $e', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    }
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }
}
