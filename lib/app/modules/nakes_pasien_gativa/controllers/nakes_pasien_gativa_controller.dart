import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class NakesPasienGativaController extends GetxController {
  final isLoading = true.obs;
  final pasienList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPasien();
  }

  void fetchPasien() {
    isLoading.value = true;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('tenaga_kesehatan')
        .doc(user.uid)
        .collection('pasien')
        .snapshots()
        .listen((snapshot) {
      pasienList.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      isLoading.value = false;
    }, onError: (e) {
      Get.snackbar('Error', 'Gagal memuat data pasien: $e');
      isLoading.value = false;
    });
  }
}

