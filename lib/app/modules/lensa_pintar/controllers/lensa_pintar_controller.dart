import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';

import '../../../routes/app_pages.dart';
import '../../main_navigation/controllers/main_navigation_controller.dart';
import '../../../widgets/custom_popup.dart';

class LensaPintarController extends GetxController {
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
    _fetchUserDailyLimit();
  }

  final RxDouble dailyLimit = 2000.0.obs;

  void _fetchUserDailyLimit() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.find<AuthService>().getUserReference(user.uid).snapshots().listen((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['dailyLimit'] != null) {
            dailyLimit.value = (data['dailyLimit'] as num).toDouble();
          } else {
            int age = data['age'] ?? 28;
            String condition = data['kondisi_kesehatan'] ?? data['kondisi'] ?? 'Sehat';
            dailyLimit.value = calculateDailyLimit(age, condition);
          }
        }
      });
    }
  }

  double calculateDailyLimit(int age, String condition) {
    String c = condition.trim().toLowerCase();
    List<String> conditions = c.split(',').map((e) => e.trim()).toList();
    
    double minLimit = 2000;

    for (String cond in conditions) {
      double limit = 2000;
      
      if (age >= 10 && age <= 18) {
        if (cond.contains('sehat')) limit = 1500;
        else if (cond.contains('hipertensi')) limit = 1200;
        else if (cond.contains('kardiovaskular')) limit = 1000;
        else if (cond.contains('jantung')) limit = 1000;
        else if (cond.contains('ginjal')) limit = 800;
        else if (cond.contains('stroke')) limit = 0;
        else limit = 1500;
      } else if (age >= 18 && age <= 59) {
        if (cond.contains('sehat')) limit = 2000;
        else if (cond.contains('hipertensi')) limit = 1500;
        else if (cond.contains('kardiovaskular')) limit = 1500;
        else if (cond.contains('jantung')) limit = 1500;
        else if (cond.contains('ginjal')) limit = 1500;
        else if (cond.contains('stroke')) limit = 1500;
        else limit = 2000;
      } else {
        if (age >= 5 && age <= 9) {
          if (cond.contains('sehat')) limit = 1200;
          else if (cond.contains('hipertensi')) limit = 1200;
          else if (cond.contains('kardiovaskular')) limit = 1000;
          else if (cond.contains('jantung')) limit = 1000;
          else if (cond.contains('ginjal')) limit = 1000;
          else if (cond.contains('stroke')) limit = 0;
          else limit = 1200;
        } else if (age >= 60) {
          if (cond.contains('sehat')) limit = 1200;
          else if (cond.contains('hipertensi')) limit = 1000;
          else if (cond.contains('kardiovaskular')) limit = 1200;
          else if (cond.contains('jantung')) limit = 1200;
          else if (cond.contains('ginjal')) limit = 1000;
          else if (cond.contains('stroke')) limit = 1000;
          else if (cond.contains('osteoporosis')) limit = 2300;
          else limit = 1200;
        }
      }
      if (limit < minLimit) {
        minLimit = limit;
      }
    }
    
    return minLimit;
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
                  'servingSize': d['servingSize'],
                  'servingsPerPack': d['servingsPerPack'],
                  'sodiumPerServing': d['sodiumPerServing'],
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

    CustomPopup.showWarning(
      'Analisis Selesai',
      'Tidak menemukan natrium pada gambar yang dipindai.',
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

      CustomPopup.showSuccess(
        'Berhasil Disimpan',
        '${item['name']} telah ditambahkan ke catatan harian.',
      );
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
          final docRef = Get.find<AuthService>()
              .getUserReference(user.uid)
              .collection('label gizi makanan')
              .doc(id);

          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentSnapshot logSnap = await transaction.get(docRef);
            if (!logSnap.exists) return;
            
            final logData = logSnap.data() as Map<String, dynamic>;
            final amount =
                (logData['natrium'] as num?)?.toInt() ??
                (logData['sodium'] as num?)?.toInt() ??
                (logData['amount'] as num?)?.toInt() ??
                0;

            DocumentReference userRef = Get.find<AuthService>().getUserReference(
              user.uid,
            );
            DocumentSnapshot userSnap = await transaction.get(userRef);
            
            if (userSnap.exists) {
              DateTime? logDate = (logData['created_at'] as Timestamp?)?.toDate() ?? (logData['timestamp'] as Timestamp?)?.toDate();
              final now = DateTime.now();
              bool isToday = logDate != null && logDate.year == now.year && logDate.month == now.month && logDate.day == now.day;
              
              if (isToday) {
                num currentTotalNum =
                    (userSnap.data() as Map<String, dynamic>)['natrium'] ??
                    (userSnap.data() as Map<String, dynamic>)['sodium'] ??
                    (userSnap.data() as Map<String, dynamic>)['totalNatrium'] ??
                    0;
                int currentTotal = currentTotalNum.toInt();
                int newTotal = currentTotal - amount;
                if (newTotal < 0) newTotal = 0;
                transaction.update(userRef, {'natrium': newTotal});
              }
            }
            transaction.delete(docRef);
          });
          CustomPopup.showSuccess("Terhapus", "Data pindaian dihapus");
        } else {
          await FirebaseFirestore.instance
              .collection('website')
              .doc('rifqizainartano50904@gmail.com')
              .collection('jajanan')
              .doc(id)
              .delete();
          CustomPopup.showSuccess("Terhapus", "Data katalog dihapus");
        }
      } catch (e) {
        CustomPopup.showError("Gagal", "Gagal menghapus data: $e");
      }
    }
  }
}
