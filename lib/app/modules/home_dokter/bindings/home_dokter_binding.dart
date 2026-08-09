import 'package:get/get.dart';
import '../controllers/home_dokter_controller.dart';
import '../../dokter_profile/controllers/dokter_profile_controller.dart';

class HomeDokterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeDokterController>(() => HomeDokterController());
    Get.lazyPut<DokterProfileController>(() => DokterProfileController());
  }
}
