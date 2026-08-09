import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class DokterBantuanFaqController extends GetxController {
  final List<Map<String, String>> faqs = [
    {
      'question': 'Bagaimana cara membalas chat pasien?',
      'answer': 'Anda dapat masuk ke tab Konsultasi dan memilih nama pasien yang ingin dibalas. Pesan baru akan berada di bagian paling atas daftar.',
    },
    {
      'question': 'Bisakah saya menghapus pasien dari daftar pantauan?',
      'answer': 'Saat ini, riwayat pasien akan tetap tersimpan selama mereka terdaftar di platform untuk memastikan kelengkapan rekam medis elektronik.',
    },
    {
      'question': 'Bagaimana jika aplikasi mengalami error?',
      'answer': 'Pastikan koneksi internet stabil. Jika masalah berlanjut, hubungi tim IT Support GATIVA di menu Bantuan Lanjutan atau restart aplikasi Anda.',
    },
    {
      'question': 'Apa yang harus dilakukan jika akun dihapus atau diblokir?',
      'answer': 'Jika akun Anda dihapus oleh admin (misal karena pelanggaran) atau dihapus sendiri, Anda tidak bisa lagi mengakses fitur. Untuk banding atau bantuan lebih lanjut, silakan hubungi tim kami di gatrapreventiva@gmail.com.',
    },
  ];

  void deleteAccount() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(
                    Icons.delete_forever_rounded,
                    size: 140,
                    color: Colors.red.shade900,
                  ),
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
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: Colors.red.shade600,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Hapus Akun Permanen?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Apakah Anda yakin ingin menghapus akun? Semua data konsultasi dan riwayat Anda akan hilang selamanya.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            onPressed: () => Get.back(),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                                try {
                                    User? user = FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      String uid = user.uid;
                                      final userRef = Get.find<AuthService>().getUserReference(uid);
                                      
                                      // Delete user data in firestore
                                      await userRef.delete();
                                      // Delete the auth user
                                      await user.delete();
                                      await FirebaseAuth.instance.signOut();
                                      Get.offAllNamed(Routes.LOGIN);
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
                                                        color: Colors.green.withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    const Text(
                                                      'Berhasil',
                                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    const Text(
                                                      'akun sudah di hapus tidak bisa di akses',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.black54),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () => Get.back(),
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
                                            ],
                                          ),
                                        ),
                                      );
                                  }
                                } catch (e) {
                                  await FirebaseAuth.instance.signOut();
                                  Get.offAllNamed(Routes.LOGIN);
                                }
                            },
                            child: const Text(
                              "Hapus",
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
      ),
    );
  }
}
