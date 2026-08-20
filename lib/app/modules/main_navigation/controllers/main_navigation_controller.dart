import 'package:get/get.dart';
import '../../notifikasi/controllers/notifikasi_controller.dart';

class MainNavigationController extends GetxController {
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<NotifikasiController>()) {
      Get.put(NotifikasiController(), permanent: true);
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
