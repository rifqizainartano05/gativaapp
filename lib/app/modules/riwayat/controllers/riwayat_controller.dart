import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class SodiumLog {
  final String id;
  final String title;
  final String type;
  final int amount;
  final DateTime timestamp;

  SodiumLog({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.timestamp,
  });
}

class RiwayatController extends GetxController {
  final RxString filterRange = "Minggu Ini".obs;
  final List<String> filterRanges = ["Minggu Ini", "Bulan Ini", "Tahun Ini"];

  final RxList<SodiumLog> logs = <SodiumLog>[].obs;
  final RxDouble dailyLimit = 2000.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistoryData();
    fetchDailyLimit();
  }

  void fetchDailyLimit() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.find<AuthService>().getUserReference(user.uid).snapshots().listen((
        doc,
      ) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['dailyLimit'] != null) {
            dailyLimit.value = (data['dailyLimit'] as num).toDouble();
          }
        }
      });
    }
  }

  void fetchHistoryData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('label gizi makanan')
          .snapshots()
          .listen((snapshot) {
            var rawLogs = snapshot.docs.map((doc) {
              final data = doc.data();
              String parsedType = data['type'] ?? 'makanan';
              if (parsedType.toLowerCase() == 'kemasan' ||
                  parsedType.toLowerCase() == 'produk pindaian') {
                parsedType = 'makanan';
              }

              return SodiumLog(
                id: doc.id,
                title: data['name'] ?? data['title'] ?? 'Unknown',
                type: parsedType,
                amount:
                    (data['natrium'] as num?)?.toInt() ??
                    (data['sodium'] as num?)?.toInt() ??
                    (data['amount'] as num?)?.toInt() ??
                    0,
                timestamp:
                    (data['created_at'] as Timestamp?)?.toDate() ??
                    (data['timestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              );
            }).toList();

            // Sort descending locally to ensure we don't miss docs without created_at field
            rawLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            logs.value = rawLogs;
          });
    }
  }

  List<SodiumLog> get filteredLogs {
    return logs.toList();
  }

  double getAverageDailyIntake() {
    if (logs.isEmpty) return 0;

    final foodLogs = logs.where((l) => l.type == 'makanan').toList();
    if (foodLogs.isEmpty) return 0;

    final days = foodLogs
        .map(
          (l) => "${l.timestamp.year}-${l.timestamp.month}-${l.timestamp.day}",
        )
        .toSet()
        .length;
    final totalFoodIntake = foodLogs.fold(0, (sum, item) => sum + item.amount);

    return days > 0 ? (totalFoodIntake / days) : 0;
  }

  // Generate radial data for 3 concentric rings (harian, bulanan, tahunan)
  Map<String, double> getRadialData() {
    final now = DateTime.now();
    
    double harian = 0;
    double bulanan = 0;
    double tahunan = 0;
    
    for (var log in logs) {
      if (log.type == 'makanan') {
        if (log.timestamp.year == now.year) {
          tahunan += log.amount;
          if (log.timestamp.month == now.month) {
            bulanan += log.amount;
            if (log.timestamp.day == now.day) {
              harian += log.amount;
            }
          }
        }
      }
    }
    
    return {
      'harian': harian,
      'bulanan': bulanan,
      'tahunan': tahunan,
    };
  }

  void deleteHistoryLog(String id) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
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
          transaction.delete(docRef);
        });

        Get.snackbar(
          "Terhapus",
          "Catatan telah dihapus.",
          backgroundColor: Get.theme.scaffoldBackgroundColor,
        );
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
