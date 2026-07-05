import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../../services/auth_service.dart';

class ScanBarcodeController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
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

  void switchCamera() {
    scannerController.switchCamera();
  }

  void onDetect(BarcodeCapture capture) async {
    if (!isScanning.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? rawValue = barcodes.first.rawValue;
      if (rawValue != null) {
        // Pause pemindaian sementara memproses
        isScanning.value = false;
        scannerController.stop();
        HapticFeedback.vibrate();

        _processScannedData(rawValue);
      }
    }
  }

  void _processScannedData(String data) async {
    if (data.startsWith('GATIVA_INVITE:')) {
      final parts = data.split(':');
      if (parts.length >= 3) {
        final ownerUid = parts[1];
        final token = parts
            .sublist(2)
            .join(':'); // Sisa dari string adalah token

        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        try {
          final User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            final existingOwner = await Get.find<AuthService>()
                .getUserReference(currentUser.uid)
                .collection('anggota')
                .where('role', isEqualTo: 'Pemilik Grup')
                .get();

            if (existingOwner.docs.isNotEmpty) {
              Get.back(); // Tutup loading
              _showErrorDialog("Anda sudah bergabung di grup lain. 1 Pengguna hanya bisa bergabung ke 1 Grup.");
              return;
            }
          }
          final doc = await Get.find<AuthService>()
              .getUserReference(ownerUid)
              .collection('anggota')
              .doc(token)
              .get();

          Get.back(); // Tutup loading

          if (!doc.exists) {
            _showErrorDialog("Undangan tidak ditemukan atau sudah digunakan.");
            return;
          }

          final inviteData = doc.data() as Map<String, dynamic>? ?? {};
          final String ownerName = inviteData['ownerName'] ?? "Pengguna";

          // Fetch owner's actual sodium data
          double ownerSodium = 0;
          double ownerLimit = 2000;
          final ownerDoc = await Get.find<AuthService>().getUserReference(ownerUid).get();
          if (ownerDoc.exists) {
            final data = ownerDoc.data() as Map<String, dynamic>?;
            if (data != null) {
              ownerSodium = (data['natrium'] ?? data['sodium'] ?? data['totalNatrium'] ?? 0).toDouble();
              ownerLimit = (data['dailyLimit'] ?? 2000).toDouble();
            }
          }

          // Fetch scanner's (current user) actual sodium data
          double scannerSodium = 0;
          double scannerLimit = 2000;
          if (currentUser != null) {
            final scannerDoc = await Get.find<AuthService>().getUserReference(currentUser.uid).get();
            if (scannerDoc.exists) {
              final data = scannerDoc.data() as Map<String, dynamic>?;
              if (data != null) {
                scannerSodium = (data['natrium'] ?? data['sodium'] ?? data['totalNatrium'] ?? 0).toDouble();
                scannerLimit = (data['dailyLimit'] ?? 2000).toDouble();
              }
            }
          }

          _showConfirmationDialog(ownerName, ownerUid, token, ownerSodium, ownerLimit, scannerSodium, scannerLimit);
          return;
        } catch (e) {
          Get.back();
          _showErrorDialog("Terjadi kesalahan saat memeriksa undangan.");
          return;
        }
      }
    }

    _showErrorDialog("Kode barcode tidak valid atau tidak dikenali.");
  }

  void _showConfirmationDialog(
    String ownerName,
    String ownerUid,
    String token,
    double ownerSodium,
    double ownerLimit,
    double scannerSodium,
    double scannerLimit,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        elevation: 10,
        child: Stack(
          children: [
            // Watermark Icon
            Positioned(
              right: -40,
              bottom: -40,
              child: Icon(
                Icons.verified_user_rounded,
                size: 180,
                color: Colors.green.withOpacity(0.04),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade100, Colors.green.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.group_add_rounded,
                      color: Colors.green.shade700,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Undangan Grup Ditemukan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Anda diundang oleh $ownerName untuk bergabung ke grup pantauan natriumnya.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Data Box Premium
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                              child: Icon(Icons.person_outline_rounded, size: 16, color: Colors.blue.shade700),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(ownerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                            Text("${ownerLimit.toInt()} mg", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                              child: Icon(Icons.person_rounded, size: 16, color: Colors.green.shade700),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(child: Text("Batas Anda", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                            Text("${scannerLimit.toInt()} mg", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.privacy_tip_rounded,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Setelah Anda menyetujui, pemilik grup juga harus menerima permintaan Anda.",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade900,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.back();
                            _resumeScanning();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            _joinGroup(ownerUid, token);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Setujui",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
      barrierDismissible: false,
    );
  }

  Future<void> _joinGroup(String ownerUid, String token) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar("Belum Masuk", "Anda harus masuk untuk bergabung.");
      _resumeScanning();
      return;
    }

    if (currentUser.uid == ownerUid) {
      Get.snackbar("Gagal", "Anda tidak bisa bergabung ke grup Anda sendiri.");
      _resumeScanning();
      return;
    }

    try {
      await Get.find<AuthService>()
          .getUserReference(ownerUid)
          .collection('group_requests')
          .doc(currentUser.uid)
          .set({
            'uid': currentUser.uid,
            'name': currentUser.displayName ?? 'Pengguna',
            'email': currentUser.email,
            'status': 'pending',
            'role': 'Anggota Keluarga',
            'timestamp': FieldValue.serverTimestamp(),
          });

      // Hapus token undangan agar hanya bisa dipakai sekali
      await Get.find<AuthService>()
          .getUserReference(ownerUid)
          .collection('anggota')
          .doc(token)
          .delete();

      Get.defaultDialog(
        title: "Permintaan Terkirim",
        middleText:
            "Permintaan bergabung telah dikirim. Menunggu persetujuan pemilik grup.",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF2E7D32),
        onConfirm: () {
          Get.back(); // Tutup dialog
          Get.back(); // Tutup halaman scanner
        },
      );
    } catch (e) {
      Get.snackbar("Terjadi Kesalahan", "Gagal mengirim permintaan bergabung.");
      _resumeScanning();
    }
  }

  void _showErrorDialog(String message) {
    Get.defaultDialog(
      title: "Peringatan",
      middleText: message,
      textConfirm: "Coba Lagi",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        _resumeScanning();
      },
    );
  }

  void _resumeScanning() {
    isScanning.value = true;
    scannerController.start();
  }
}
