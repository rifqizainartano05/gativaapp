import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_popup.dart';

class InformasiKesehatanController extends GetxController {
  final isLoading = true.obs;
  final infoList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchInformasi();
  }

  void fetchInformasi() {
    if (FirebaseAuth.instance.currentUser == null) {
      isLoading.value = false;
      return;
    }
    
    isLoading.value = true;
    FirebaseFirestore.instance
        .collectionGroup('informasi_kesehatan')
        .snapshots()
        .listen((snapshot) {
      infoList.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      isLoading.value = false;
    }, onError: (e) {
      if (e.toString().contains('permission-denied')) {
        Get.log('Informasi Kesehatan permission denied (likely not logged in)');
      } else {
        CustomPopup.showError('Error', 'Gagal memuat data informasi: $e');
      }
      isLoading.value = false;
    });
  }
}
