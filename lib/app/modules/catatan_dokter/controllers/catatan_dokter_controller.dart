import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CatatanDokterController extends GetxController {
  final isLoading = true.obs;
  final CatatanDokter = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    listenCatatan();
  }

  void listenCatatan() {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection('pasien')
            .doc(user.uid)
            .snapshots()
            .listen((docSnapshot) {
          CatatanDokter.clear();
          if (docSnapshot.exists) {
            final data = docSnapshot.data() ?? {};
            if (data['catatan_dokter'] != null) {
              final catatanData = data['catatan_dokter'];
              if (catatanData is List) {
                for (var item in catatanData) {
                  if (item != null && item.toString().isNotEmpty) {
                    CatatanDokter.add(item.toString());
                  }
                }
              } else if (catatanData is String && catatanData.isNotEmpty) {
                CatatanDokter.add(catatanData);
              }
            }
          }
          isLoading.value = false;
        }, onError: (error) {
          isLoading.value = false;
          Get.snackbar('Error', 'Gagal memuat catatan medis');
        });
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Gagal inisialisasi catatan medis');
    }
  }
}
