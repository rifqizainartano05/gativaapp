import 'package:cloud_firestore/cloud_firestore.dart';
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
      CustomPopup.showError('Error', 'Gagal memuat data informasi: $e');
      isLoading.value = false;
    });
  }
}
