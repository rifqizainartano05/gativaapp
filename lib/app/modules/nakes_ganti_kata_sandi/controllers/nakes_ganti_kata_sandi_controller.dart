import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';
class NakesGantiKataSandiController extends GetxController {
  final oldPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  final isLoading = false.obs;
  final obscureOld = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  void toggleOld() => obscureOld.value = !obscureOld.value;
  void toggleNew() => obscureNew.value = !obscureNew.value;
  void toggleConfirm() => obscureConfirm.value = !obscureConfirm.value;

  Future<void> gantiPassword() async {
    final oldPass = oldPasswordCtrl.text;
    final newPass = newPasswordCtrl.text;
    final confirmPass = confirmPasswordCtrl.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Semua kolom harus diisi',
        backgroundColor: Colors.white,
      );
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar(
        'Perhatian',
        'Konfirmasi sandi baru tidak cocok',
        backgroundColor: Colors.white,
      );
      return;
    }

    if (newPass.length < 6) {
      Get.snackbar(
        'Perhatian',
        'Sandi baru minimal 6 karakter',
        backgroundColor: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPass,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPass);
        Get.snackbar(
          'Berhasil',
          'Kata sandi berhasil diubah, silakan masuk kembali',
          backgroundColor: Colors.white,
        );
        await FirebaseAuth.instance.signOut();
        Get.offAllNamed(Routes.LOGIN);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        Get.snackbar(
          'Gagal',
          'Sandi lama salah',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Gagal',
          e.message ?? 'Terjadi kesalahan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah sandi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    oldPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}
