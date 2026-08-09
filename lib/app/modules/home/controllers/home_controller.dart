import 'package:get/get.dart';
import '../../edukasi/controllers/edukasi_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController extends GetxController {
  final RxString userName = "Pengguna".obs;
  final RxDouble limit = 2000.0.obs;
  final RxDouble totalConsumedToday = 0.0.obs;
  final RxList<Map<String, dynamic>> edukasiList = <Map<String, dynamic>>[].obs;

  double get usageRatio => limit.value == 0
      ? 0
      : (totalConsumedToday.value / limit.value).clamp(0.0, 1.0);
  double get remainingQuota =>
      (limit.value - totalConsumedToday.value).clamp(0.0, limit.value);

  String get intakeStatus {
    double ratio = usageRatio;
    if (ratio < 0.6) return 'Aman';
    if (ratio < 0.9) return 'Waspada';
    return 'Bahaya';
  }

  String get statusMessage {
    double ratio = usageRatio;
    if (ratio < 0.6) return 'Aman, lanjutkan!';
    if (ratio < 0.9) return 'Mulai mendekati batas!';
    return 'Batas terlampaui!';
  }

  // ==== PROYEKSI (SIMULASI MAKAN BERIKUTNYA) ====
  final RxDouble projectionSodiumInput = 300.0.obs;

  Map<String, dynamic> getProjectionDetails() {
    double futureIntake =
        totalConsumedToday.value + projectionSodiumInput.value;
    double futureRemaining = limit.value - futureIntake;
    double futureRatio = limit.value == 0 ? 0 : futureIntake / limit.value;

    String suggestion = "";
    if (futureRatio <= 0.6) {
      suggestion = "Pilihan aman. Anda masih punya banyak sisa kuota.";
    } else if (futureRatio <= 0.9) {
      suggestion = "Porsi ini akan membuat Anda harus waspada sisa hari ini.";
    } else if (futureRatio <= 1.0) {
      suggestion = "Porsi ini akan hampir menghabiskan seluruh kuota Anda!";
    } else {
      suggestion = "Bahaya! Porsi ini akan melampaui batas harian WHO.";
    }

    return {
      'futureIntake': futureIntake,
      'futureRemaining': futureRemaining.clamp(0.0, limit.value),
      'futureRatio': futureRatio.clamp(0.0, 1.5),
      'suggestion': suggestion,
    };
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    fetchEdukasi();
    Future.delayed(const Duration(seconds: 2), checkNotificationPermission);
  }

  Future<void> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      Get.dialog(
        AlertDialog(
          title: const Text("Izin Notifikasi", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Untuk menerima pengingat harian gamifikasi dan peringatan penting, mohon izinkan notifikasi untuk aplikasi Gativa."),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Nanti", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                final result = await Permission.notification.request();
                if (result.isPermanentlyDenied) {
                  openAppSettings();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Izinkan", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
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

    void fetchEdukasi() {
    // Gunakan EdukasiController untuk menghindari masalah Index CollectionGroup
    final edukasiCtrl = Get.put(EdukasiController());
    ever(edukasiCtrl.edukasiList, (list) {
      edukasiList.value = list.take(5).toList();
    });
    // Inisialisasi awal jika sudah ada
    edukasiList.value = edukasiCtrl.edukasiList.take(5).toList();
  }

  void fetchUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.find<AuthService>().getUserReference(user.uid).snapshots().listen((
        doc,
      ) async {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          userName.value = data['name'] ?? user.displayName ?? "Pengguna";

          int age = data['age'] ?? 28;
          String condition =
              data['kondisi_kesehatan'] ?? data['kondisi'] ?? 'Sehat';
          double calculatedLimit = calculateDailyLimit(age, condition);
          double storedLimit = (data['dailyLimit'] ?? 0).toDouble();

          if (storedLimit != calculatedLimit || data.containsKey('kondisi')) {
            limit.value = calculatedLimit;
            
            Map<String, dynamic> updates = {
              'dailyLimit': calculatedLimit,
              'kondisi_kesehatan': condition,
            };
            
            // Hapus field kondisi yang lama
            if (data.containsKey('kondisi')) {
              updates['kondisi'] = FieldValue.delete();
            }

            await Get.find<AuthService>().getUserReference(user.uid).update(updates);

          } else {
            limit.value = storedLimit;
          }
        }
      });

      Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('label gizi makanan')
          .snapshots()
          .listen((snapshot) {
        double dailyTotal = 0.0;
        final now = DateTime.now();
        for (var doc in snapshot.docs) {
          final data = doc.data();
          DateTime? docDate = (data['created_at'] as Timestamp?)?.toDate() ?? (data['timestamp'] as Timestamp?)?.toDate();
          if (docDate != null && docDate.year == now.year && docDate.month == now.month && docDate.day == now.day) {
            dailyTotal += ((data['natrium'] ?? data['sodium'] ?? data['amount'] ?? 0) as num).toDouble();
          }
        }
        totalConsumedToday.value = dailyTotal;
      });
    }
  }
}
