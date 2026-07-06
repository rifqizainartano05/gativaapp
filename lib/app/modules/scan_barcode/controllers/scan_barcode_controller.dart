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

          // Fetch owner's actual sodium data from 'pasien'
          double ownerSodium = 0;
          double ownerLimit = 2000;
          
          final ownerFoodDoc = await FirebaseFirestore.instance
              .collection('mobile')
              .doc('roles')
              .collection('pasien')
              .doc(ownerUid)
              .collection('label gizi makanan')
              .get();
              
          if (ownerFoodDoc.docs.isNotEmpty) {
            double total = 0;
            final now = DateTime.now();
            for (var fDoc in ownerFoodDoc.docs) {
              final fData = fDoc.data();
              DateTime? docDate = (fData['created_at'] as Timestamp?)?.toDate() ?? (fData['timestamp'] as Timestamp?)?.toDate();
              if (docDate != null && docDate.year == now.year && docDate.month == now.month && docDate.day == now.day) {
                total += ((fData['natrium'] ?? fData['sodium'] ?? fData['amount'] ?? 0) as num).toDouble();
              }
            }
            ownerSodium = total;
          }
          final ownerDoc = await Get.find<AuthService>().getUserReference(ownerUid).get();
          if (ownerDoc.exists) ownerLimit = ((ownerDoc.data() as Map<String, dynamic>?)?['dailyLimit'] ?? 2000).toDouble();

          // Fetch scanner's actual sodium data from 'pasien'
          double scannerSodium = 0;
          double scannerLimit = 2000;
          if (currentUser != null) {
            final scannerFoodDoc = await FirebaseFirestore.instance
                .collection('mobile')
                .doc('roles')
                .collection('pasien')
                .doc(currentUser.uid)
                .collection('label gizi makanan')
                .get();
                
            if (scannerFoodDoc.docs.isNotEmpty) {
              double total = 0;
              final now = DateTime.now();
              for (var fDoc in scannerFoodDoc.docs) {
                final fData = fDoc.data();
                DateTime? docDate = (fData['created_at'] as Timestamp?)?.toDate() ?? (fData['timestamp'] as Timestamp?)?.toDate();
                if (docDate != null && docDate.year == now.year && docDate.month == now.month && docDate.day == now.day) {
                  total += ((fData['natrium'] ?? fData['sodium'] ?? fData['amount'] ?? 0) as num).toDouble();
                }
              }
              scannerSodium = total;
            }
            final scannerDoc = await Get.find<AuthService>().getUserReference(currentUser.uid).get();
            if (scannerDoc.exists) scannerLimit = ((scannerDoc.data() as Map<String, dynamic>?)?['dailyLimit'] ?? 2000).toDouble();
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.15),
                blurRadius: 40,
                offset: const Offset(0, 12),
              )
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Premium Background Blobs
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.green.withOpacity(0.15), Colors.transparent],
                    ),
                  ),
                ),
              ),
              // Rotated Watermark Icon
              Positioned(
                left: -30,
                bottom: -40,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.group_add_rounded,
                    size: 200,
                    color: Colors.green.withOpacity(0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade300, Colors.teal.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.group_add_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Undangan Ditemukan",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Anda diundang oleh $ownerName untuk bergabung ke grup pantauan natriumnya.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    // Data Box Premium
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                                child: Icon(Icons.person_outline_rounded, size: 18, color: Colors.blue.shade700),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(ownerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                              Text("${ownerLimit.toInt()} mg", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.blue)),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                                child: Icon(Icons.person_rounded, size: 18, color: Colors.green.shade700),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: Text("Batas Anda", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                              Text("${scannerLimit.toInt()} mg", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Pemilik grup juga harus menerima permintaan Anda.",
                              style: TextStyle(fontSize: 12, color: Colors.orange.shade900, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Get.back();
                              _resumeScanning();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text("Batal", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 16)),
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
                              backgroundColor: const Color(0xFF00796B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                              shadowColor: Colors.teal.withOpacity(0.3),
                            ),
                            child: const Text("Setujui", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                )
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Premium Background Blobs
                Positioned(
                  top: -60,
                  right: -40,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.blue.withOpacity(0.12), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                // Rotated Watermark Icon
                Positioned(
                  left: -30,
                  bottom: -40,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      Icons.send_rounded,
                      size: 200,
                      color: Colors.blue.withOpacity(0.04),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blueGrey.shade300, Colors.blueGrey.shade500],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Permintaan Terkirim",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Permintaan bergabung telah dikirim. Menunggu persetujuan pemilik grup.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back(); // Tutup dialog
                            Get.back(); // Tutup halaman scanner
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF455A64),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            shadowColor: Colors.blueGrey.withOpacity(0.3),
                          ),
                          child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      Get.snackbar("Terjadi Kesalahan", "Gagal mengirim permintaan bergabung.");
      _resumeScanning();
    }
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.15),
                blurRadius: 40,
                offset: const Offset(0, 12),
              )
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Premium Background Blobs
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.red.withOpacity(0.12), Colors.transparent],
                    ),
                  ),
                ),
              ),
              // Rotated Watermark Icon
              Positioned(
                left: -30,
                bottom: -40,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 200,
                    color: Colors.red.withOpacity(0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade300, Colors.red.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Peringatan",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _resumeScanning();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          shadowColor: Colors.red.withOpacity(0.2),
                        ),
                        child: const Text("Mengerti", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _resumeScanning() {
    isScanning.value = true;
    scannerController.start();
  }
}
