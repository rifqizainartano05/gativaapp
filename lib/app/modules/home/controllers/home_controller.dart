import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeController extends GetxController {
  final RxString userName = "Pengguna".obs;
  final RxDouble limit = 2000.0.obs;
  final RxDouble totalConsumedToday = 0.0.obs;

  double get usageRatio => limit.value == 0 ? 0 : (totalConsumedToday.value / limit.value).clamp(0.0, 1.0);
  double get remainingQuota => (limit.value - totalConsumedToday.value).clamp(0.0, limit.value);

  String get intakeStatus {
    double ratio = usageRatio;
    if (ratio < 0.6) return 'Aman';
    if (ratio < 0.9) return 'Waspada';
    return 'Bahaya';
  }

  String get statusMessage {
    double ratio = usageRatio;
    if (ratio < 0.6) return 'Asupan sangat terkendali. Lanjutkan!';
    if (ratio < 0.9) return 'Mulai dekati batas. Perhatikan makan malam Anda.';
    return 'Batas terlampaui! Hindari makanan kemasan hari ini.';
  }

  // ==== PROYEKSI (SIMULASI MAKAN BERIKUTNYA) ====
  final RxDouble projectionSodiumInput = 300.0.obs;

  Map<String, dynamic> getProjectionDetails() {
    double futureIntake = totalConsumedToday.value + projectionSodiumInput.value;
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
  }

  double calculateDailyLimit(int age, String condition) {
    if (age >= 5 && age <= 9) {
      switch (condition) {
        case 'Sehat': return 1200;
        case 'Hipertensi': return 1200;
        case 'Penyakit kardiovaskular': return 1000;
        case 'Penyakit jantung koroner': return 1000;
        case 'Penyakit ginjal kronis': return 800;
        case 'Stroke': return 0;
        default: return 1200;
      }
    } else if (age >= 10 && age <= 17) {
      switch (condition) {
        case 'Sehat': return 1500;
        case 'Hipertensi': return 1200;
        case 'Penyakit kardiovaskular': return 1000;
        case 'Penyakit jantung koroner': return 1000;
        case 'Penyakit ginjal kronis': return 800;
        case 'Stroke': return 0;
        default: return 1500;
      }
    } else if (age >= 18 && age <= 59) {
      switch (condition) {
        case 'Sehat': return 2000;
        case 'Hipertensi': return 1500;
        case 'Penyakit kardiovaskular': return 1500;
        case 'Penyakit jantung koroner': return 1500;
        case 'Penyakit ginjal kronis': return 1500;
        case 'Stroke': return 1500;
        default: return 2000;
      }
    } else {
      switch (condition) {
        case 'Sehat': return 1200;
        case 'Hipertensi': return 1000;
        case 'Penyakit kardiovaskular': return 1000;
        case 'Penyakit jantung koroner': return 1000;
        case 'Penyakit ginjal kronis': return 1000;
        case 'Stroke': return 1000;
        default: return 1200;
      }
    }
  }

  void fetchUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('mobile').doc(user.uid).snapshots().listen((doc) async {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          userName.value = data['name'] ?? user.displayName ?? "Pengguna";
          totalConsumedToday.value = (data['natrium'] ?? data['sodium'] ?? data['totalNatrium'] ?? 0).toDouble();
          
          int age = data['age'] ?? 28;
          String condition = data['kondisi'] ?? data['healthCondition'] ?? 'Sehat';
          double calculatedLimit = calculateDailyLimit(age, condition);
          double storedLimit = (data['dailyLimit'] ?? 0).toDouble();
          
          if (storedLimit != calculatedLimit) {
            limit.value = calculatedLimit;
            await FirebaseFirestore.instance.collection('mobile').doc(user.uid).update({
              'dailyLimit': calculatedLimit,
              'kondisi': condition // memastikan migrate field lama ke kondisi
            });
          } else {
            limit.value = storedLimit;
          }
        }
      });

      // Dengarkan sub collection label gizi makanan untuk total hari ini
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      FirebaseFirestore.instance
          .collection('mobile')
          .doc(user.uid)
          .collection('label gizi makanan')
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .snapshots()
          .listen((snapshot) {
        double total = 0;
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final amount = (data['natrium'] as num?)?.toDouble() ?? (data['sodium'] as num?)?.toDouble() ?? 0.0;
          total += amount;
        }
        totalConsumedToday.value = total;
        
        // Update the main document if needed
        FirebaseFirestore.instance.collection('mobile').doc(user.uid).update({
          'natrium': total
        });
      });
    }
  }
}
