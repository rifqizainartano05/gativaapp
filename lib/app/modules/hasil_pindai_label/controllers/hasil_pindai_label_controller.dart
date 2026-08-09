import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';

import '../../main_navigation/controllers/main_navigation_controller.dart';
class HasilPindaiLabelController extends GetxController {
  final foodName = "".obs;
  late final TextEditingController foodNameController;
  final servingSize = "".obs;
  final sodiumPerServing = 0.0.obs;
  final servingsPerPack = 1.0.obs;
  final servingsMultiplier = 1.0.obs;
  final TextEditingController portionController = TextEditingController(text: '1');
  final isFromMission = false.obs;
  final isMissionCompleted = false.obs;
  final isEditingName = false.obs;
  final FocusNode foodNameFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      foodName.value = args['foodName'] ?? "Produk Pindaian";
      foodNameController = TextEditingController(text: foodName.value);
      servingSize.value = args['servingSize'] ?? "1 Sajian";
      sodiumPerServing.value = args['sodiumPerServing'] ?? 0.0;
      servingsPerPack.value = args['servingsPerPack'] ?? 1.0;
      isFromMission.value = args['isFromMission'] == true;
    }
    
    // Sinkronkan text controller dengan slider (servingsMultiplier) saat berubah
    portionController.addListener(() {
      final text = portionController.text;
      if (text.isNotEmpty) {
        final val = double.tryParse(text.replaceAll(',', '.'));
        if (val != null && val >= 0) {
          servingsMultiplier.value = val;
        }
      }
    });
  }

  @override
  void onClose() {
    portionController.dispose();
    foodNameController.dispose();
    foodNameFocusNode.dispose();
    super.onClose();
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
        'name': foodNameController.text, // Simpan nama makanan yang mungkin sudah diedit
        'type': 'Kemasan',
        'natrium': totalCalculatedSodium.toInt(),
        'created_at': Timestamp.now(),
      });
      
      batch.set(docRef, {
        'natrium': FieldValue.increment(totalCalculatedSodium.toInt()),
      }, SetOptions(merge: true));
      
      batch.commit();
      
      Get.offNamed(Routes.LENSA_NATRIUM_DETAIL, arguments: {
        'name': foodNameController.text,
        'natrium': totalCalculatedSodium,
        'type': 'Kemasan',
        'showSuccessPopup': true,
      });
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
