import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class FaqController extends GetxController {
  final List<Map<String, String>> faqs = [
    {
      "question": "Bagaimana cara mengubah profil dan preferensi saya?",
      "answer":
          "Buka tab Profil di navigasi bawah, lalu ketuk opsi Edit Profil. Anda bisa memperbarui data pribadi, tinggi, berat badan, serta kondisi kesehatan Anda di sana.",
    },
    {
      "question": "Apakah data privasi dan riwayat saya aman?",
      "answer":
          "Ya, kami menjamin kerahasiaan data Anda. Aplikasi Gativa menggunakan sistem keamanan terenkripsi sesuai standar untuk melindungi rekam medis dan riwayat nutrisi Anda.",
    },
    {
      "question": "Bagaimana cara membagikan pemantauan ke anggota keluarga?",
      "answer":
          "Masuk ke menu 'Anggota' di navigasi utama, ketuk ikon QR Code, lalu minta keluarga Anda untuk memindai kode tersebut menggunakan fitur Gabung Anggota di perangkat mereka.",
    },
    {
      "question": "Bagaimana cara mengatur ulang kata sandi?",
      "answer":
          "Pada halaman Login, Anda dapat mengetuk 'Lupa Kata Sandi' (Forgot Password) dan sistem kami akan mengirimkan tautan pemulihan ke alamat email yang Anda daftarkan.",
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
                      "Apakah Anda yakin ingin menghapus akun? Semua data rekam medis dan riwayat konsumsi Anda akan hilang selamanya.",
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
                                      
                                      // 1. Hapus diri sendiri dari daftar anggota milik orang lain
                                      try {
                                        final anggotaSnapshot = await userRef.collection('anggota').where('dataType', isEqualTo: 'Anggota').get();
                                        for (var doc in anggotaSnapshot.docs) {
                                          String memberUid = doc.id;
                                          await FirebaseFirestore.instance
                                              .collection('mobile')
                                              .doc('roles')
                                              .collection('pasien')
                                              .doc(memberUid)
                                              .collection('anggota')
                                              .doc(uid)
                                              .delete();
                                        }
                                        
                                        // 2. Hapus semua dokumen di subkoleksi milik diri sendiri secara menyeluruh
                                        List<String> subcollections = [
                                          'anggota', 'riwayat', 'group_requests', 'notifikasi',
                                          'chats', 'labels', 'jajanan', 'label gizi makanan'
                                        ];
                                        
                                        for (String col in subcollections) {
                                          final snap = await userRef.collection(col).get();
                                          for (var doc in snap.docs) {
                                            if (col == 'chats') {
                                              final msgs = await doc.reference.collection('messages').get();
                                              for (var m in msgs.docs) { await m.reference.delete(); }
                                              final notes = await doc.reference.collection('catatan').get();
                                              for (var n in notes.docs) { await n.reference.delete(); }
                                            }
                                            await doc.reference.delete();
                                          }
                                        }
                                      } catch (e) {
                                        debugPrint("Gagal menghapus relasi dan data: $e");
                                      }

                                      // Delete user data in firestore
                                      await userRef.delete();
                                      // Delete the auth user
                                      await user.delete();
                                      await FirebaseAuth.instance.signOut();
                                      
                                      Get.back(); // close confirmation dialog
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
                                                      'Akun sudah dihapus, tidak bisa diakses.',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.black54),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () => Get.offAllNamed(Routes.LOGIN),
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
                                        barrierDismissible: false,
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

  void deleteAllData() {
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
                    Icons.delete_sweep_rounded,
                    size: 140,
                    color: Colors.orange.shade900,
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
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade600,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Hapus Semua Data?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Apakah Anda yakin ingin menghapus semua data riwayat konsumsi? Data yang dihapus tidak dapat dikembalikan, namun akun Anda tetap aktif.",
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
                              backgroundColor: Colors.orange.shade600,
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
                                  
                                  // Hapus data riwayat konsumsi (labels)
                                  final labelsSnapshot = await userRef.collection('labels').get();
                                  for (var doc in labelsSnapshot.docs) {
                                    await doc.reference.delete();
                                  }
                                  
                                  // Hapus data jajanan
                                  final jajananSnapshot = await userRef.collection('jajanan').get();
                                  for (var doc in jajananSnapshot.docs) {
                                    await doc.reference.delete();
                                  }

                                  // Hapus data riwayat harian
                                  final riwayatSnapshot = await userRef.collection('riwayat').get();
                                  for (var doc in riwayatSnapshot.docs) {
                                    await doc.reference.delete();
                                  }

                                  // Hapus data label gizi makanan (Lensa Pintar)
                                  final labelGiziSnapshot = await userRef.collection('label gizi makanan').get();
                                  for (var doc in labelGiziSnapshot.docs) {
                                    await doc.reference.delete();
                                  }
                                  
                                  // Reset total natrium harian pengguna
                                  await userRef.update({
                                    'natrium': 0.0,
                                  });
                                  
                                  Get.back();
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
                                                  'Semua data riwayat berhasil dihapus.',
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
                                print(e);
                                Get.back();
                                Get.snackbar(
                                  'Error', 
                                  'Gagal menghapus data',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            child: const Text(
                              "Hapus Data",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
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
    );
  }
}
