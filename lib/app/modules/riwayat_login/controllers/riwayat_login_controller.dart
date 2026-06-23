import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RiwayatLoginController extends GetxController {
  final loginLogs = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLoginHistory();
  }

  void fetchLoginHistory() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('mobile')
          .doc(user.uid)
          .collection('login_history')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        loginLogs.value = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            'method': data['method'] ?? 'Unknown',
            'device': data['device'] ?? 'Perangkat Tidak Dikenal',
          };
        }).toList();
        isLoading.value = false;
      }, onError: (e) {
        isLoading.value = false;
      });
    } else {
      isLoading.value = false;
    }
  }
}
