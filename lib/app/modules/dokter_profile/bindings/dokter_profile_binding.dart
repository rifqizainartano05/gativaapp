import 'package:get/get.dart';
import '../controllers/dokter_profile_controller.dart';

class DokterProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterProfileController>(() => DokterProfileController());
  }
}
