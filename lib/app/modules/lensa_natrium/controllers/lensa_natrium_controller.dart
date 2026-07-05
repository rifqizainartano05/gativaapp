import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../gamifikasi/controllers/gamifikasi_controller.dart';
import '../../../routes/app_pages.dart';
import '../../main_navigation/controllers/main_navigation_controller.dart';

class LensaNatriumController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final isAnalyzing = false.obs;
  final isLoading = false.obs;
  final isMissionCompleted = false.obs;

  final searchResults = <Map<String, dynamic>>[].obs;
  final allJajanan = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchJajananFromFirebase();
  }

  List<Map<String, dynamic>> _globalJajanan = [];
  List<Map<String, dynamic>> _userJajanan = [];

  void _fetchJajananFromFirebase() {
    isLoading.value = true;
    final user = FirebaseAuth.instance.currentUser;

    // Ambil data jajanan global dari website
    FirebaseFirestore.instance
        .collection('website')
        .doc('rifqizainartano50904@gmail.com')
        .collection('jajanan')
        .snapshots()
        .listen(
          (snapshot) {
              final globalData = snapshot.docs.map((e) {
              final d = e.data();
              return {
                'id': e.id,
                'isGlobal': true,
                'name': d['nama_jajanan'] ?? d['name'] ?? 'Tanpa Nama',
                'type': d['kategori'] ?? d['type'] ?? 'Umum',
                'natrium':
                    int.tryParse(
                      d['kandungan_natrium']?.toString() ??
                          d['natrium_mg']?.toString() ??
                          d['natrium']?.toString() ??
                          '0',
                    ) ??
                    0,
              };
            }).toList();

            _updateAllJajanan(globalData, true);
          },
          onError: (e) {
            print("Error fetching jajanan global: $e");
            isLoading.value = false;
          },
        );

    // Ambil data jajanan hasil scan user dari subcollection mobile
    if (user != null) {
      Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('label gizi makanan')
          .snapshots()
          .listen(
            (snapshot) {
              final userData = snapshot.docs.map((e) {
                final d = e.data();
                return {
                  'id': e.id,
                  'isGlobal': false,
                  'name': d['name'] ?? 'Pindaian',
                  'type': d['type'] ?? 'Kemasan',
                  'natrium': (d['natrium'] as num?)?.toInt() ?? 0,
                };
              }).toList();

              _updateAllJajanan(userData, false);
            },
            onError: (e) {
              print("Error fetching user jajanan: $e");
            },
          );
    }
  }

  void _updateAllJajanan(List<Map<String, dynamic>> data, bool isGlobal) {
    if (isGlobal) {
      _globalJajanan = data;
    } else {
      _userJajanan = data;
    }
    allJajanan.assignAll([..._userJajanan, ..._globalJajanan]);
    searchFood(searchController.text);
    isLoading.value = false;
  }

  void searchFood(String query) {
    if (query.isEmpty) {
      searchResults.assignAll(allJajanan);
      return;
    }
    final lowercaseQuery = query.toLowerCase();
    searchResults.assignAll(
      allJajanan.where(
        (item) =>
            item['name'].toString().toLowerCase().contains(lowercaseQuery),
      ),
    );
  }

  void captureAndAnalyze() async {
    isAnalyzing.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isAnalyzing.value = false;

    Get.snackbar(
      'Analisis Selesai',
      'Tidak menemukan natrium pada gambar yang dipindai.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  void logFood(Map<String, dynamic> item) async {
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
        'name': item['name'],
        'type': item['type'] ?? 'makanan',
        'natrium': item['natrium'],
        'created_at': Timestamp.now(),
      });
      
      batch.set(docRef, {
        'natrium': FieldValue.increment(item['natrium']),
      }, SetOptions(merge: true));
      
      await batch.commit();

      Get.snackbar(
        'Berhasil Disimpan',
        '${item['name']} telah ditambahkan ke catatan harian.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
    }    
    if (Get.isRegistered<GamifikasiController>()) {
      final gamifikasi = Get.find<GamifikasiController>();
      int currentLevel = gamifikasi.currentActiveLevel.value;
      if ([1, 3, 6, 7, 9, 10, 11].contains(currentLevel)) {
        bool done = gamifikasi.completeMissionByLevel(currentLevel);
        if (done) isMissionCompleted.value = true;
      }
    }

    bool isFromMission = Get.arguments != null && Get.arguments is Map && Get.arguments['isFromMission'] == true;
    if (isFromMission || isMissionCompleted.value) {
      if (Get.isRegistered<MainNavigationController>()) {
        Get.find<MainNavigationController>().changePage(1); // Index 1 is Gamifikasi
      }
      Get.until((route) => route.settings.name == Routes.MAIN_NAVIGATION);
    }
  }

  void deleteJajanan(String id, bool isGlobal) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        if (!isGlobal) {
          await Get.find<AuthService>()
              .getUserReference(user.uid)
              .collection('label gizi makanan')
              .doc(id)
              .delete();
          Get.snackbar(
            "Terhapus",
            "Data pindaian dihapus",
            backgroundColor: Get.theme.scaffoldBackgroundColor,
          );
        } else {
          await FirebaseFirestore.instance
              .collection('website')
              .doc('rifqizainartano50904@gmail.com')
              .collection('jajanan')
              .doc(id)
              .delete();
          Get.snackbar(
            "Terhapus",
            "Data katalog dihapus",
            backgroundColor: Get.theme.scaffoldBackgroundColor,
          );
        }
      } catch (e) {
        Get.snackbar(
          "Gagal",
          "Gagal menghapus data: $e",
          backgroundColor: Colors.red.withOpacity(0.1),
        );
      }
    }
  }
}
