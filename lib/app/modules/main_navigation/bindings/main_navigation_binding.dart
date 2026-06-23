import 'package:garda/app/modules/anggota/controllers/anggota_controller.dart';
import 'package:get/get.dart';
import '../controllers/main_navigation_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../gamifikasi/controllers/gamifikasi_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(
      () => MainNavigationController(),
    );
    // Menginisialisasi controller untuk 4 tab
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<GamifikasiController>(() => GamifikasiController());
    Get.lazyPut<AnggotaController>(() => AnggotaController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
