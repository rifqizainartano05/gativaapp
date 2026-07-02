import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';

class ScanDokterAksesController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );

  final RxBool isFlashOn = false.obs;
  final RxBool isScanning = true.obs;

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  void toggleFlash() {
    scannerController.toggleTorch();
    isFlashOn.value = !isFlashOn.value;
  }

  void onDetect(BarcodeCapture capture) async {
    if (!isScanning.value) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        if (code.startsWith('nakes:')) {
          // Pause scanning
          isScanning.value = false;
          scannerController.stop();
          
          final nakesUid = code.replaceAll('nakes:', '').trim();
          await _processDoctorAccess(nakesUid);
        } else {
          // Not a valid doctor QR
          Get.snackbar(
            'QR Tidak Valid',
            'QR Code ini bukan untuk akses dokter.',
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 16,
          );
        }
      }
    }
  }

  Future<void> _processDoctorAccess(String nakesUid) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Belum login.");

      // Cek ketersediaan dokter
      final nakesDoc = await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(nakesUid)
          .get();

      if (!nakesDoc.exists) {
        throw Exception("Tenaga Kesehatan tidak ditemukan.");
      }

      // Ambil data pasien saat ini
      final pasienDoc = await Get.find<AuthService>().getUserReference(user.uid).get();
      if (!pasienDoc.exists) {
        throw Exception("Data pasien tidak ditemukan.");
      }

      final pasienData = pasienDoc.data() as Map<String, dynamic>;

      // Copy data pasien ke dalam subcollection pasien milik dokter
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(nakesUid)
          .collection('pasien')
          .doc(user.uid)
          .set({
        ...pasienData,
        'terhubungPada': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save doctor info to patient's document
      await Get.find<AuthService>().getUserReference(user.uid).set({
        'nakesUid': nakesUid,
        'nakesName': nakesDoc.data()?['name'] ?? 'Dokter',
      }, SetOptions(merge: true));

      Get.back(); // Tutup loading

      // Tampilkan sukses
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Berhasil Terhubung!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Anda sekarang telah terhubung dengan ${nakesDoc.data()?['name'] ?? 'Dokter'}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // tutup dialog
                      goToMain(); // menuju halaman utama
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

    } catch (e) {
      Get.back(); // Tutup loading
      Get.snackbar(
        'Gagal',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
      
      // Lanjutkan scanning jika gagal
      isScanning.value = true;
      scannerController.start();
    }
  }

  void goToMain() {
    Get.offAllNamed('/main-navigation');
  }
}
