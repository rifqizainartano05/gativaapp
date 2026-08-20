import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

import '../../../widgets/custom_popup.dart';

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

class ChartDataPoint {
  final String label;
  final double amanValue;
  final double warningValue;
  final double bahayaValue;

  ChartDataPoint(this.label, this.amanValue, this.warningValue, this.bahayaValue);
}

class RiwayatAnggotaController extends GetxController {
  final RxString filterOption = "".obs;
  final Rx<DateTimeRange?> customDateRange = Rx<DateTimeRange?>(null);
  
  final List<String> filterOptionsList = [
    "3 Hari Terakhir",
    "5 Hari Terakhir",
    "7 Hari Terakhir",
    "14 Hari Terakhir",
    "30 Hari Terakhir",
    "3 Minggu Terakhir",
    "4 Minggu Terakhir",
    "8 Minggu Terakhir",
    "12 Minggu Terakhir",
    "3 Bulan Terakhir",
    "6 Bulan Terakhir",
    "9 Bulan Terakhir",
    "12 Bulan Terakhir",
    "3 Tahun Terakhir",
    "5 Tahun Terakhir",
    "Atur Tanggal",
  ];

  void setFilterOption(String option) {
    filterOption.value = option;
  }

  // Helper to parse the current option
  int get currentCount {
    if (filterOption.value.isEmpty) return 7; // Default
    if (filterOption.value == "Saat Ini") return 1;
    if (filterOption.value == "Atur Tanggal") {
      if (customDateRange.value != null) {
        return customDateRange.value!.end.difference(customDateRange.value!.start).inDays + 1;
      }
      return 7;
    }
    final parts = filterOption.value.split(" ");
    if (parts.isNotEmpty) {
      return int.tryParse(parts[0]) ?? 1;
    }
    return 1;
  }

  String get currentUnit {
    if (filterOption.value.isEmpty) return "Hari"; // Default
    if (filterOption.value == "Saat Ini") return "Saat Ini";
    if (filterOption.value == "Atur Tanggal") return "Atur Tanggal";
    if (filterOption.value.contains("Hari")) return "Hari";
    if (filterOption.value.contains("Minggu")) return "Minggu";
    if (filterOption.value.contains("Bulan")) return "Bulan";
    if (filterOption.value.contains("Tahun")) return "Tahun";
    return "Hari";
  }

  final RxList<SodiumLog> logs = <SodiumLog>[].obs;
  final RxDouble dailyLimit = 2000.0.obs;
  final RxDouble averageSodium = 0.0.obs;
  final RxInt currentStreak = 0.obs;
  final RxBool isMissionCompleted = false.obs;

  late String memberId;
  late String memberName;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      try {
        memberId = args.id;
        memberName = args.name;
      } catch (e) {
        if (args is Map) {
          memberId = args['id'] ?? FirebaseAuth.instance.currentUser?.uid ?? '';
          memberName = args['name'] ?? 'Anggota';
        } else {
          memberId = FirebaseAuth.instance.currentUser?.uid ?? '';
          memberName = 'Anggota';
        }
      }
    } else {
      memberId = FirebaseAuth.instance.currentUser?.uid ?? '';
      memberName = 'Anggota';
    }

    fetchHistoryData();
    fetchDailyLimit();
  }

  void fetchDailyLimit() {
    if (memberId.isEmpty) return;
    Get.find<AuthService>().getUserReference(memberId).snapshots().listen((
      doc,
    ) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['dailyLimit'] != null && data['dailyLimit'] != 0) {
          dailyLimit.value = (data['dailyLimit'] as num).toDouble();
        } else {
          int age = data['age'] ?? 28;
          String condition = data['kondisi_kesehatan'] ?? data['kondisi'] ?? 'Sehat';
          dailyLimit.value = calculateDailyLimit(age, condition);
        }
      }
    });
  }

  void fetchHistoryData() {
    if (memberId.isEmpty) return;
    Get.find<AuthService>()
        .getUserReference(memberId)
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

  List<SodiumLog> get filteredLogs {
    final now = DateTime.now();
    DateTime threshold;
    
    // HANYA data label gizi makanan (natrium dari makanan)
    final foodLogs = logs.where((l) => l.type == 'makanan');

    int count = currentCount;

    if (currentUnit == 'Saat Ini') {
      threshold = DateTime(now.year, now.month, now.day);
    } else if (currentUnit == 'Hari') {
      threshold = DateTime(now.year, now.month, now.day).subtract(Duration(days: count - 1));
    } else if (currentUnit == 'Minggu') {
      threshold = DateTime(now.year, now.month, now.day).subtract(Duration(days: (count * 7) - 1));
    } else if (currentUnit == 'Bulan') {
      int targetMonth = now.month - count + 1;
      int targetYear = now.year;
      while (targetMonth <= 0) {
        targetMonth += 12;
        targetYear -= 1;
      }
      threshold = DateTime(targetYear, targetMonth, 1);
    } else if (currentUnit == 'Tahun') {
      threshold = DateTime(now.year - count + 1, 1, 1);
    } else if (currentUnit == 'Atur Tanggal') {
      if (customDateRange.value != null) {
        return foodLogs.where((l) => 
          (l.timestamp.isAfter(customDateRange.value!.start) || l.timestamp.isAtSameMomentAs(customDateRange.value!.start)) &&
          (l.timestamp.isBefore(customDateRange.value!.end.add(const Duration(days: 1))) || l.timestamp.isAtSameMomentAs(customDateRange.value!.end.add(const Duration(days: 1))))
        ).toList();
      }
      threshold = now.subtract(const Duration(days: 7));
    } else {
      threshold = DateTime(now.year - 4, 1, 1);
    }
    if (currentUnit == 'Saat Ini') {
       return foodLogs.where((l) => l.timestamp.year == now.year && l.timestamp.month == now.month && l.timestamp.day == now.day).toList();
    }
    
    // STRICT ACCUMULATED DATA COUNT CHECK
    if (filterOption.value.isNotEmpty) {
       int uniqueCount = 0;
       int requiredCount = 0;
       
       if (currentUnit == 'Bulan') {
          uniqueCount = foodLogs.map((l) => "${l.timestamp.year}-${l.timestamp.month}").toSet().length;
          requiredCount = count;
       } else if (currentUnit == 'Tahun') {
          uniqueCount = foodLogs.map((l) => "${l.timestamp.year}").toSet().length;
          requiredCount = count;
       } else {
          uniqueCount = foodLogs.map((l) => "${l.timestamp.year}-${l.timestamp.month}-${l.timestamp.day}").toSet().length;
          if (currentUnit == 'Hari') {
             requiredCount = count;
          } else if (currentUnit == 'Minggu') {
             requiredCount = count * 7;
          } else if (currentUnit == 'Atur Tanggal') {
             if (customDateRange.value != null) {
                requiredCount = customDateRange.value!.end.difference(customDateRange.value!.start).inDays + 1;
             } else {
                requiredCount = 7;
             }
          }
       }
       
       if (uniqueCount < requiredCount) {
          return []; // Belum memenuhi syarat jumlah data akumulasi
       }
    }
    
    return foodLogs.where((l) => l.timestamp.isAfter(threshold) || l.timestamp.isAtSameMomentAs(threshold)).toList();
  }

  double get chartLimit {
    final distinctDays = <String>{};
    for (var log in filteredLogs) {
      distinctDays.add("${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}");
    }
    int activeDaysCount = distinctDays.length;
    if (activeDaysCount == 0) return dailyLimit.value;
    
    return dailyLimit.value * activeDaysCount;
  }

  double getTotalIntake() {
    final dataPoints = getChartData();
    if (dataPoints.isEmpty) return 0;

    double total = 0;
    for (var point in dataPoints) {
      total += point.amanValue + point.warningValue + point.bahayaValue;
    }
    return total;
  }

  double getAmanIntake() {
    return filteredLogs.where((l) => l.amount <= dailyLimit.value * 0.1).fold(0.0, (sum, item) => sum + item.amount);
  }

  double getWarningIntake() {
    return filteredLogs.where((l) => l.amount > dailyLimit.value * 0.1 && l.amount <= dailyLimit.value * 0.2).fold(0.0, (sum, item) => sum + item.amount);
  }

  double getBahayaIntake() {
    return filteredLogs.where((l) => l.amount > dailyLimit.value * 0.2).fold(0.0, (sum, item) => sum + item.amount);
  }

  double getAbsoluteMaxChartValue() {
    final foodLogs = logs.where((l) => l.type == 'makanan').toList();
    if (foodLogs.isEmpty) return dailyLimit.value > 0 ? dailyLimit.value : 2000;

    double maxVal = 0;
    
    if (currentUnit == 'Hari' || currentUnit == 'Atur Tanggal') {
      Map<String, double> dailyTotals = {};
      for (var log in foodLogs) {
        String key = "${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}";
        dailyTotals[key] = (dailyTotals[key] ?? 0) + log.amount;
      }
      maxVal = dailyTotals.values.isEmpty ? 0 : dailyTotals.values.reduce((a, b) => a > b ? a : b);
    } 
    else if (currentUnit == 'Minggu') {
      Map<String, double> weeklyTotals = {};
      for (var log in foodLogs) {
        int weekNum = (log.timestamp.difference(DateTime(log.timestamp.year, 1, 1)).inDays / 7).floor();
        String key = "${log.timestamp.year}-W$weekNum";
        weeklyTotals[key] = (weeklyTotals[key] ?? 0) + log.amount;
      }
      maxVal = weeklyTotals.values.isEmpty ? 0 : weeklyTotals.values.reduce((a, b) => a > b ? a : b);
    }
    else if (currentUnit == 'Bulan') {
      Map<String, double> monthlyTotals = {};
      for (var log in foodLogs) {
        String key = "${log.timestamp.year}-${log.timestamp.month}";
        monthlyTotals[key] = (monthlyTotals[key] ?? 0) + log.amount;
      }
      maxVal = monthlyTotals.values.isEmpty ? 0 : monthlyTotals.values.reduce((a, b) => a > b ? a : b);
    }
    else if (currentUnit == 'Tahun') {
      Map<String, double> yearlyTotals = {};
      for (var log in foodLogs) {
        String key = "${log.timestamp.year}";
        yearlyTotals[key] = (yearlyTotals[key] ?? 0) + log.amount;
      }
      maxVal = yearlyTotals.values.isEmpty ? 0 : yearlyTotals.values.reduce((a, b) => a > b ? a : b);
    } else {
      maxVal = foodLogs.fold(0.0, (sum, log) => sum + log.amount);
    }

    return maxVal == 0 ? (dailyLimit.value > 0 ? dailyLimit.value : 2000) : maxVal;
  }

  Map<String, double> getRadialData() {
    double total = 0;
    for (var log in logs) {
      if (log.type == 'makanan') {
        total += log.amount;
      }
    }
    // Karena sistem tidak di-reset per hari, maka semua kategori menampilkan akumulasi total
    return {
      'harian': total,
      'bulanan': total,
      'tahunan': total,
    };
  }

  List<ChartDataPoint> getChartData() {
    final now = DateTime.now();
    List<ChartDataPoint> data = [];
    final foodLogs = logs.where((l) => l.type == 'makanan').toList();
    int count = currentCount;
    void addData(String label, Iterable<SodiumLog> matchedLogs) {
      double aman = 0, warning = 0, bahaya = 0;
      for (var log in matchedLogs) {
        if (log.amount >= 1000) {
          bahaya += log.amount;
        } else if (log.amount >= 600) {
          warning += log.amount;
        } else {
          aman += log.amount;
        }
      }
      data.add(ChartDataPoint(label, aman, warning, bahaya));
    }

    if (currentUnit == 'Saat Ini') {
      var matched = foodLogs; // Tidak di-reset per hari, gabungkan semuanya
      addData("Semua Waktu", matched);
    } else if (currentUnit == 'Atur Tanggal' && customDateRange.value != null) {
      DateTime start = customDateRange.value!.start;
      DateTime end = customDateRange.value!.end;
      int days = end.difference(start).inDays + 1;
      
      for (int i = 0; i < days; i++) {
        DateTime targetDate = start.add(Duration(days: i));
        var matched = foodLogs.where((log) => log.timestamp.year == targetDate.year && log.timestamp.month == targetDate.month && log.timestamp.day == targetDate.day);
        String label = "${targetDate.day} ${["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Ags", "Sep", "Okt", "Nov", "Des"][targetDate.month - 1]}";
        addData(label, matched);
      }
    } else if (currentUnit == 'Hari' || currentUnit == 'Atur Tanggal') {
      // Last N days
      for (int i = count - 1; i >= 0; i--) {
        DateTime targetDate = now.subtract(Duration(days: i));
        var matched = foodLogs.where((log) => log.timestamp.year == targetDate.year && log.timestamp.month == targetDate.month && log.timestamp.day == targetDate.day);
        String label = "${targetDate.day} ${["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Ags", "Sep", "Okt", "Nov", "Des"][targetDate.month - 1]}";
        addData(label, matched);
      }
    } else if (currentUnit == 'Minggu') {
      // Last N weeks
      for (int i = count - 1; i >= 0; i--) {
        DateTime targetEnd = DateTime(now.year, now.month, now.day).subtract(Duration(days: i * 7));
        DateTime targetStart = targetEnd.subtract(const Duration(days: 6));
        var matched = foodLogs.where((log) => log.timestamp.isAfter(targetStart.subtract(const Duration(seconds: 1))) && log.timestamp.isBefore(targetEnd.add(const Duration(days: 1))));
        String label = "Mgg ${count - i}";
        addData(label, matched);
      }
    } else if (currentUnit == 'Bulan') {
      for (int i = count - 1; i >= 0; i--) {
        int targetMonth = now.month - i;
        int targetYear = now.year;
        while (targetMonth <= 0) {
          targetMonth += 12;
          targetYear -= 1;
        }
        var matched = foodLogs.where((log) => log.timestamp.month == targetMonth && log.timestamp.year == targetYear);
        String label = "${["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Ags", "Sep", "Okt", "Nov", "Des"][targetMonth - 1]}";
        addData(label, matched);
      }
    } else if (currentUnit == 'Tahun') {
      for (int i = count - 1; i >= 0; i--) {
        int targetYear = now.year - i;
        var matched = foodLogs.where((log) => log.timestamp.year == targetYear);
        addData(targetYear.toString(), matched);
      }
    }

    return data;
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

        CustomPopup.showSuccess("Terhapus", "Catatan telah dihapus.");
      } catch (e) {
        CustomPopup.showError("Gagal", "Gagal menghapus data: $e");
      }
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

  double getAverageDailyIntake() {
    if (logs.isEmpty) return 0.0;
    
    Map<String, double> dailySums = {};
    for (var log in logs) {
      if (log.type == 'makanan') {
        String dateKey = "${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}";
        dailySums[dateKey] = (dailySums[dateKey] ?? 0.0) + log.amount;
      }
    }
    
    if (dailySums.isEmpty) return 0.0;
    
    double total = 0.0;
    dailySums.forEach((key, value) {
      total += value;
    });
    
    return total / dailySums.length;
  }
}
