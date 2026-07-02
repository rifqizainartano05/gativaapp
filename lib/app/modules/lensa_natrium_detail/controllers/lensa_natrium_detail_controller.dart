import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
}
