import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeAdministratorController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data
  final RxList<Map<String, dynamic>> dokters = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> pasiens = <Map<String, dynamic>>[].obs;
  
  // UI State
  final RxString dokterFilter = 'Semua'.obs; // Semua, Menunggu, Disetujui, Ditolak, Diblokir

  @override
  void onInit() {
    super.onInit();
    _fetchDokters();
    _fetchPasiens();
  }

  void _fetchDokters() {
    _firestore
        .collection('mobile')
        .doc('roles')
        .collection('dokter')
        .snapshots()
        .listen((snapshot) {
      dokters.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }

  void _fetchPasiens() {
    _firestore
        .collection('mobile')
        .doc('roles')
        .collection('pasien')
        .snapshots()
        .listen((snapshot) {
      pasiens.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> updateDokterStatus(String uid, String newStatus) async {
    try {
      await _firestore
          .collection('mobile')
          .doc('roles')
          .collection('dokter')
          .doc(uid)
          .update({'status': newStatus.toLowerCase()});
      _showCustomDialog('Berhasil', 'Status dokter berhasil diubah menjadi $newStatus', true);
    } catch (e) {
      _showCustomDialog('Gagal', 'Gagal mengubah status: $e', false);
    }
  }

  Future<void> hapusAkun(String uid, String role) async {
    try {
      await _firestore
          .collection('mobile')
          .doc('roles')
          .collection(role.toLowerCase())
          .doc(uid)
          .delete();
      _showCustomDialog('Berhasil', 'Akun berhasil dihapus selamanya', true);
    } catch (e) {
      _showCustomDialog('Gagal', 'Gagal menghapus akun: $e', false);
    }
  }

  Future<void> updateAkun(String uid, String role, String newName, String newEmail) async {
    try {
      await _firestore
          .collection('mobile')
          .doc('roles')
          .collection(role.toLowerCase())
          .doc(uid)
          .update({
            'name': newName,
            'email': newEmail,
          });
      _showCustomDialog('Tersimpan', 'Data akun berhasil diperbarui di Database', true);
    } catch (e) {
      _showCustomDialog('Gagal', 'Gagal memperbarui akun: $e', false);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (email.isEmpty) {
      Get.snackbar('Error', 'Email tidak boleh kosong', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showCustomDialog('Terkirim', 'Tautan reset kata sandi telah dikirim ke $email', true);
    } catch (e) {
      _showCustomDialog('Gagal', 'Gagal mengirim email reset: $e', false);
    }
  }

  void _showCustomDialog(String title, String message, bool isSuccess) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 72,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? const Color(0xFF2E7D32) : Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Helper getters
  List<Map<String, dynamic>> get filteredDokters {
    if (dokterFilter.value == 'Semua') return dokters;
    return dokters.where((d) => d['status']?.toString().toLowerCase() == dokterFilter.value.toLowerCase()).toList();
  }
}
