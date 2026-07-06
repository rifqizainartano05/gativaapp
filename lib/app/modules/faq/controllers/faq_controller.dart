import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class FaqController extends GetxController {
  final List<Map<String, String>> faqs = [
    {
      "question": "Berapa batas konsumsi natrium harian yang aman?",
      "answer":
          "WHO merekomendasikan asupan natrium tidak lebih dari 2.000 mg (setara dengan kurang dari 5 gram atau 1 sendok teh garam) per hari untuk orang dewasa.",
    },
    {
      "question": "Bagaimana cara memindai barcode makanan?",
      "answer":
          "Buka tab Pindai di navigasi bawah, lalu arahkan kamera ke barcode kemasan makanan. Sistem kami akan secara otomatis membaca dan menampilkan kadar natriumnya.",
    },
    {
      "question": "Apa itu Fitur Grup Pantauan?",
      "answer":
          "Fitur ini memungkinkan Anda memantau asupan natrium anggota grup, seperti orang tua, pasangan, anak, atau pendamping kesehatan, dan memberikan peringatan jika mereka mendekati batas harian.",
    },
    {
      "question": "Bagaimana cara mengekspor laporan medis?",
      "answer":
          "Masuk ke halaman Profil, lalu ketuk 'Ekspor Laporan Medis'. Pilih rentang tanggal yang diinginkan, dan aplikasi akan menghasilkan file PDF yang dapat dibagikan.",
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
                                        
                                        // 2. Hapus semua dokumen di subkoleksi milik diri sendiri
                                        final allAnggota = await userRef.collection('anggota').get();
                                        for (var d in allAnggota.docs) { await d.reference.delete(); }
                                        
                                        final allRiwayat = await userRef.collection('riwayat').get();
                                        for (var d in allRiwayat.docs) { await d.reference.delete(); }
                                        
                                        final allReqs = await userRef.collection('group_requests').get();
                                        for (var d in allReqs.docs) { await d.reference.delete(); }
                                      } catch (e) {
                                        debugPrint("Gagal menghapus relasi anggota: $e");
                                      }

                                      // Delete user data in firestore
                                      await userRef.delete();
                                      // Delete the auth user
                                      await user.delete();
                                      await FirebaseAuth.instance.signOut();
                                      Get.offAllNamed(Routes.LOGIN);
                                    Get.snackbar(
                                      "Berhasil",
                                      "Akun Anda telah dihapus secara permanen.",
                                      backgroundColor: Colors.green.withOpacity(
                                        0.1,
                                      ),
                                      colorText: Colors.green,
                                    );
                                  }
                                } catch (e) {
                                  await FirebaseAuth.instance.signOut();
                                  Get.offAllNamed(Routes.LOGIN);
                                  Get.snackbar(
                                    "Info",
                                    "Sesi login telah diakhiri. Silakan login kembali untuk melanjutkan penghapusan akun.",
                                    backgroundColor: Colors.blue.withOpacity(0.1),
                                    colorText: Colors.blue,
                                  );
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
