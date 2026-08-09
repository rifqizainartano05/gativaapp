import 'package:gativa/app/modules/anggota/controllers/anggota_controller.dart';
import 'package:get/get.dart';
import '../controllers/main_navigation_controller.dart';
import '../../home/controllers/home_controller.dart';

import '../../profile/controllers/profile_controller.dart';
import '../../catatan_dokter/controllers/catatan_dokter_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
    // Menginisialisasi controller untuk 4 tab
    Get.lazyPut<HomeController>(() => HomeController());

    Get.lazyPut<AnggotaController>(() => AnggotaController());
    Get.lazyPut<CatatanDokterController>(() => CatatanDokterController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
