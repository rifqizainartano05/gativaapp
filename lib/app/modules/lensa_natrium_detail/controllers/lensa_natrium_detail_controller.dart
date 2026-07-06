import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_popup.dart';

class LensaNatriumDetailController extends GetxController {
  late final Map<String, dynamic> foodItem;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Mendapatkan data makanan yang dilempar dari halaman sebelumnya
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      foodItem = args;
    } else {
      foodItem = {
        'name': 'Data tidak ditemukan',
        'natrium': 0,
        'type': 'Tidak diketahui',
      };
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (foodItem['showSuccessPopup'] == true) {
      // Tampilkan popup sukses dengan CustomPopup (menengah, ada watermark)
      Future.delayed(const Duration(milliseconds: 300), () {
        CustomPopup.showSuccess(
          "Sukses",
          "Data konsumsi natrium berhasil dicatat.",
        );
      });
    }
  }
}
