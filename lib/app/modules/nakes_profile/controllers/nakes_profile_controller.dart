import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_pages.dart';
import 'package:qr_flutter/qr_flutter.dart';

class NakesProfileController extends GetxController {
  final RxString nakesName = 'Tenaga Kesehatan'.obs;
  final RxString nakesEmail = ''.obs;
  final RxString photoBase64 = ''.obs;
  final RxString nakesUid = ''.obs;

  final Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);

  @override
  void onInit() {
    super.onInit();

    ever(photoBase64, (String b64) {
      if (b64.isEmpty) {
        imageBytes.value = null;
        return;
      }
      try {
        if (b64.contains(',')) b64 = b64.split(',').last;
        b64 = b64.replaceAll(RegExp(r'\s+'), '');
        imageBytes.value = base64Decode(b64);
      } catch (e) {
        imageBytes.value = null;
      }
    });

    fetchProfileData();
  }

  void fetchProfileData() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        nakesUid.value = user.uid;
        nakesEmail.value = user.email ?? 'email@domain.com';

        Get.find<AuthService>()
            .getUserReference(user.uid)
            .snapshots()
            .listen((doc) {
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>?;
            nakesName.value = data?['name'] ?? 'Tenaga Kesehatan';
            photoBase64.value = data?['photoBase64'] ?? '';
          }
        });
      }
    } catch (e) {
      // Handle error gracefully
    }
  }

  void showBarcodeDialog() {
    if (nakesUid.value.isEmpty) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  Icons.qr_code_rounded,
                  size: 150,
                  color: const Color(0xFF2E7D32).withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Barcode Akses",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Minta pasien untuk memindai kode ini",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: 'nakes:${nakesUid.value}',
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void logout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  Icons.shield_outlined,
                  size: 150,
                  color: const Color(0xFF2E7D32).withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Keluar Akun?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Apakah Anda yakin ingin keluar dari GATIVA? Anda harus login kembali untuk mengakses data.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            onPressed: () => Get.back(),
                            child: const Text(
                              "Batal",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: Colors.red.withOpacity(0.5),
                            ),
                            onPressed: () async {
                              Get.back();
                              await FirebaseAuth.instance.signOut();
                              Get.offAllNamed(Routes.LOGIN);
                            },
                            child: const Text(
                              "Keluar",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
      ),
      barrierDismissible: true,
    );
  }

}
