import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';

class NakesDashboardController extends GetxController {
  final currentIndex = 0.obs;

  final RxString nakesName = 'Tenaga Kesehatan'.obs;
  final RxString photoBase64 = ''.obs;
  final Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);
  final RxInt totalPatients = 0.obs;
  final isLoading = true.obs;

  final RxInt patuhCount = 0.obs;
  final RxInt kurangPatuhCount = 0.obs;
  final RxInt tidakPatuhCount = 0.obs;
  final RxDouble averageRating = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    
    ever(photoBase64, (String b64) {
      if (b64.isEmpty) {
        imageBytes.value = null;
        return;
      }
      try {
        if (b64.contains(',')) b64 = b64.split(',').last;
        b64 = b64.replaceAll(RegExp(r'\s+'), '');
        imageBytes.value = base64Decode(b64);
      } catch (e) {
        imageBytes.value = null;
      }
    });
    
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Ambil nama dari dokumen Nakes
        Get.find<AuthService>()
            .getUserReference(user.uid)
            .snapshots()
            .listen((nakesDoc) {
          if (nakesDoc.exists) {
            final data = nakesDoc.data() as Map<String, dynamic>?;
            nakesName.value = data?['name'] ?? 'Tenaga Kesehatan';
            photoBase64.value = data?['photoBase64'] ?? '';
          }
        });

        // Ambil rating dari subcollection pasien milik nakes ini
        FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection('tenaga_kesehatan')
            .doc(user.uid)
            .collection('pasien')
            .snapshots()
            .listen((nakesPasienSnapshot) {
          double totalRating = 0;
          int ratingCount = 0;
          for (var doc in nakesPasienSnapshot.docs) {
            final data = doc.data();
            if (data.containsKey('rating')) {
              totalRating += (data['rating'] as num).toDouble();
              ratingCount++;
            }
          }
          if (ratingCount > 0) {
            averageRating.value = totalRating / ratingCount;
          } else {
            averageRating.value = 0.0;
          }
        });

        // Hitung total pasien di subcollection mobile/roles/pasien
        FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection('pasien')
            .snapshots()
            .listen((pasienSnapshot) {
          final total = pasienSnapshot.docs.length;
          totalPatients.value = total;

          int patuh = 0;
          int kurangPatuh = 0;
          int tidakPatuh = 0;

          for (var doc in pasienSnapshot.docs) {
            final data = doc.data();
            double limit = (data['dailyLimit'] ?? 2000.0).toDouble();
            if (limit == 0) limit = 2000.0;
            double natrium = (data['natrium'] ?? data['sodium'] ?? data['totalNatrium'] ?? 0.0).toDouble();
            
            double ratio = natrium / limit;
            
            if (ratio < 0.6) {
              patuh++;
            } else if (ratio < 0.9) {
              kurangPatuh++;
            } else {
              tidakPatuh++;
            }
          }

          patuhCount.value = patuh;
          kurangPatuhCount.value = kurangPatuh;
          tidakPatuhCount.value = tidakPatuh;
          
          isLoading.value = false;
        });
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
    }
  }
  void changePage(int index) {
    currentIndex.value = index;
  }
}
