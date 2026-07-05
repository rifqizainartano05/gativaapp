import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';
import '../../gamifikasi/controllers/gamifikasi_controller.dart';
import '../../main_navigation/controllers/main_navigation_controller.dart';
class ScannerResultController extends GetxController {
  final foodName = "".obs;
  final servingSize = "".obs;
  final sodiumPerServing = 0.0.obs;
  final servingsPerPack = 1.0.obs;
  final servingsMultiplier = 1.0.obs;
  final isFromMission = false.obs;
  final isMissionCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      foodName.value = args['foodName'] ?? "Produk Pindaian";
      servingSize.value = args['servingSize'] ?? "1 Sajian";
      sodiumPerServing.value = args['sodiumPerServing'] ?? 0.0;
      servingsPerPack.value = args['servingsPerPack'] ?? 1.0;
      isFromMission.value = args['isFromMission'] == true;
    }
  }

  double get totalCalculatedSodium {
    return sodiumPerServing.value * servingsMultiplier.value;
  }

  void saveAndLog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(user.uid);
          
      final batch = FirebaseFirestore.instance.batch();
      
      final labelRef = docRef.collection('label gizi makanan').doc();
      batch.set(labelRef, {
        'name': foodName.value,
        'type': 'Kemasan',
        'natrium': totalCalculatedSodium.toInt(),
        'created_at': Timestamp.now(),
      });
      
      batch.set(docRef, {
        'natrium': FieldValue.increment(totalCalculatedSodium.toInt()),
      }, SetOptions(merge: true));
      
      await batch.commit();
      
      Get.snackbar(
        "Sukses",
        "Data konsumsi natrium berhasil dicatat.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32).withOpacity(0.9),
        colorText: Colors.white,
      );
      
      if (Get.isRegistered<GamifikasiController>()) {
        final gamifikasi = Get.find<GamifikasiController>();
        int currentLevel = gamifikasi.currentActiveLevel.value;
        // Daftar level yang diselesaikan dengan mencatat makanan / pemindaian
        if ([1, 2, 3, 5, 6, 7, 9, 10, 11, 13].contains(currentLevel)) {
          bool done = gamifikasi.completeMissionByLevel(currentLevel);
          if (done) isMissionCompleted.value = true;
        }
      }
      
      if (isFromMission.value || isMissionCompleted.value) {
        if (Get.isRegistered<MainNavigationController>()) {
          Get.find<MainNavigationController>().changePage(1); // Index 1 is Gamifikasi
        }
        Get.until((route) => route.settings.name == Routes.MAIN_NAVIGATION);
      } else {
        Get.offNamed(Routes.LENSA_NATRIUM_DETAIL, arguments: {
          'name': foodName.value,
          'natrium': totalCalculatedSodium,
          'type': 'Kemasan',
        });
      }
    } else {
      Get.snackbar(
        "Error",
        "Anda belum login.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
