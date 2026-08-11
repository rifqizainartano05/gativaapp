import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';

import '../../main_navigation/controllers/main_navigation_controller.dart';
class HasilPindaiLabelController extends GetxController {
  final foodName = "".obs;
  late final TextEditingController foodNameController;
  late final TextEditingController servingSizeController;
  late final TextEditingController servingsPerPackController;
  late final TextEditingController sodiumPerServingController;
  late final TextEditingController portionController;
  
  final isFromMission = false.obs;
  final isMissionCompleted = false.obs;
  final servingsMultiplier = 1.0.obs;
  
  // Total sodium calculation reactivity
  final totalCalculatedSodiumObs = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      
      foodName.value = args['foodName'] ?? "Produk Pindaian";
      foodNameController = TextEditingController(text: foodName.value);
      
      String servingSizeArg = args['servingSize']?.toString() ?? "";
      servingSizeController = TextEditingController(text: servingSizeArg.trim());
      
      double sodium = args['sodiumPerServing'] ?? 0.0;
      sodiumPerServingController = TextEditingController(text: sodium.toInt().toString());
      
      // Default to 1 if it's 0 to prevent 0 division/multiplication issues if desired, 
      // but let's use the actual parsed value or 1 as fallback.
      double packArg = args['servingsPerPack'] ?? 0.0;
      String packArgStr = packArg > 0 ? (packArg == packArg.toInt() ? packArg.toInt().toString() : packArg.toString()) : "1";
      servingsPerPackController = TextEditingController(text: packArgStr);
      
      isFromMission.value = args['isFromMission'] == true;
      
      // Kosongkan agar pengguna mengisi manual
      servingsMultiplier.value = 0.0;
      portionController = TextEditingController(text: "");
      
      _updateTotalSodium();

      portionController.addListener(_updateTotalSodium);
      servingsPerPackController.addListener(_updateTotalSodium);
      sodiumPerServingController.addListener(_updateTotalSodium);
    }
  }

  void _updateTotalSodium() {
    final portionText = portionController.text.replaceAll(',', '.');
    final portionValue = double.tryParse(portionText) ?? 0.0;
    servingsMultiplier.value = portionValue;

    // Remove any non-numeric characters (like ' sajian') before parsing
    final sppText = servingsPerPackController.text.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
    double spp = double.tryParse(sppText) ?? 1.0;
    if (spp <= 0) spp = 1.0;

    final sodiumText = sodiumPerServingController.text.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
    double sodium = double.tryParse(sodiumText) ?? 0.0;

    totalCalculatedSodiumObs.value = sodium * spp * portionValue;
  }
    
  @override
  void onClose() {
    foodNameController.dispose();
    servingSizeController.dispose();
    servingsPerPackController.dispose();
    sodiumPerServingController.dispose();
    portionController.dispose();
    super.onClose();
  }

  double get totalCalculatedSodium => totalCalculatedSodiumObs.value;

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
        'name': foodNameController.text, // Simpan nama makanan yang mungkin sudah diedit
        'type': 'Kemasan',
        'natrium': totalCalculatedSodium.toInt(),
        'servingSize': servingSizeController.text,
        'servingsPerPack': double.tryParse(servingsPerPackController.text.replaceAll(',', '.')) ?? 1.0,
        'sodiumPerServing': double.tryParse(sodiumPerServingController.text.replaceAll(',', '.')) ?? 0.0,
        'created_at': Timestamp.now(),
      });
      
      batch.set(docRef, {
        'natrium': FieldValue.increment(totalCalculatedSodium.toInt()),
      }, SetOptions(merge: true));
      
      batch.commit();
      
      Get.offNamedUntil(
        Routes.LENSA_PINTAR_DETAIL, 
        (route) => route.settings.name == Routes.LENSA_PINTAR || route.settings.name == Routes.MAIN_NAVIGATION || route.isFirst,
        arguments: {
          'name': foodNameController.text,
          'natrium': totalCalculatedSodium,
          'type': 'Kemasan',
          'showSuccessPopup': true,
          'servingSize': servingSizeController.text,
          'servingsPerPack': double.tryParse(servingsPerPackController.text.replaceAll(',', '.')) ?? 1.0,
          'sodiumPerServing': double.tryParse(sodiumPerServingController.text.replaceAll(',', '.')) ?? 0.0,
        }
      );
    } else {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset('assets/logo.png', width: 150, height: 150),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline_rounded, color: Colors.red, size: 64),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Error',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Anda belum login.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
