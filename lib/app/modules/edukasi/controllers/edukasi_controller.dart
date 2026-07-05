import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../gamifikasi/controllers/gamifikasi_controller.dart';

class EdukasiController extends GetxController {
  final RxList<Map<String, dynamic>> edukasiList = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isMissionCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEdukasi();
  }

  void fetchEdukasi() {
    isLoading.value = true;
    FirebaseFirestore.instance
        .collectionGroup('edukasi')
        .snapshots()
        .listen((snapshot) {
      edukasiList.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      isLoading.value = false;
      
      if (Get.isRegistered<GamifikasiController>()) {
        bool m1 = Get.find<GamifikasiController>().completeMissionByLevel(4);
        bool m2 = Get.find<GamifikasiController>().completeMissionByLevel(18);
        if (m1 || m2) isMissionCompleted.value = true;
      }
    }, onError: (e) {
      Get.snackbar('Error', 'Gagal memuat data edukasi: $e');
      isLoading.value = false;
    });
  }
}
