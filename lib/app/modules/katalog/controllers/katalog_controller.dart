import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class KatalogController extends GetxController {
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchKatalogData();
  }

  void _fetchKatalogData() {
    FirebaseFirestore.instance
        .collectionGroup('katalog_makanan')
        .snapshots()
        .listen(
          (snapshot) {
            items.clear();
            for (var doc in snapshot.docs) {
              final data = doc.data();
              items.add({
                'id': doc.id,
                'makanan_asli': data['makanan_asli'] ?? '',
                'makanan_alternatif': data['makanan_alternatif'] ?? '',
                'hemat_natrium_mg':
                    double.tryParse(
                      data['hemat_natrium_mg']?.toString() ?? '0',
                    ) ??
                    0,
              });
            }
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
            print("Error fetching katalog: $e");
          },
        );
  }

  void kurangiNatrium(Map<String, dynamic> item) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Gagal', 'Anda harus login terlebih dahulu');
      return;
    }

    final int hematNatrium = item['hemat_natrium_mg'].toInt();
    
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Watermark Icon di background
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.spa_rounded, // Watermark daun yang sehat
                  size: 140,
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
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.energy_savings_leaf_rounded,
                        color: Color(0xFF2E7D32),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Catat Penghematan",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Anda akan mengonsumsi ${item['makanan_alternatif']} sebagai pengganti ${item['makanan_asli']}.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                        children: [
                          const TextSpan(text: "Total natrium Anda akan berkurang: "),
                          TextSpan(
                            text: "$hematNatrium mg",
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Batal",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back(); // Tutup dialog
                              _processHematNatrium(user.uid, item, hematNatrium);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Ya, Lanjut",
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _processHematNatrium(String uid, Map<String, dynamic> item, int hematNatrium) async {
    try {
      final docRef = Get.find<AuthService>().getUserReference(uid);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userSnap = await transaction.get(docRef);
        
        num currentTotalNum = 0;
        if (userSnap.exists) {
          final data = userSnap.data() as Map<String, dynamic>?;
          if (data != null) {
            currentTotalNum = data['natrium'] ?? data['sodium'] ?? data['totalNatrium'] ?? 0;
          }
        }
        
        int currentTotal = currentTotalNum.toInt();
        int newTotal = currentTotal - hematNatrium;
        if (newTotal < 0) newTotal = 0; // Jangan sampai minus
        
        // 1. Update total konsumsi di user (agar langsung ngefek ke dashboard/pasien)
        if (userSnap.exists) {
          transaction.update(docRef, {'natrium': newTotal});
        } else {
          transaction.set(docRef, {'natrium': newTotal}, SetOptions(merge: true));
        }
        
        // 2. Catat history (agar tampil di riwayat grafik)
        DocumentReference logRef = docRef.collection('label gizi makanan').doc();
        transaction.set(logRef, {
          'name': 'Hemat: ${item['makanan_alternatif']}',
          'type': 'makanan', // type makanan agar terhitung grafik riwayat
          'natrium': -hematNatrium,
          'created_at': FieldValue.serverTimestamp(),
        });
      });

      Get.snackbar(
        'Berhasil', 
        'Data konsumsi natrium Anda berhasil dikurangi $hematNatrium mg!',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e');
    }
  }
}
