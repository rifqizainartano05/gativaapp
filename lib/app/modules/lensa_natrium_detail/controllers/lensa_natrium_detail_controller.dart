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
    fetchUserDailyLimit();
  }

  final RxDouble dailyLimit = 2000.0.obs;
  final RxString ageGroup = "Dewasa".obs;
  final RxString conditionName = "Sehat".obs;

  void fetchUserDailyLimit() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['dailyLimit'] != null) {
            dailyLimit.value = (data['dailyLimit'] as num).toDouble();
          }
          int age = data['age'] ?? 28;
          String condition = data['kondisi_kesehatan'] ?? data['kondisi'] ?? 'Sehat';
          conditionName.value = condition;
          if (age >= 5 && age <= 9) {
            ageGroup.value = "Anak-anak (5-9 Tahun)";
          } else if (age >= 10 && age <= 18) {
            ageGroup.value = "Remaja (10-18 Tahun)";
          } else if (age >= 19 && age <= 59) {
            ageGroup.value = "Dewasa (19-59 Tahun)";
          } else {
            ageGroup.value = "Lansia (60+ Tahun)";
          }
        }
      });
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
