import 'package:get/get.dart';

import '../controllers/dokter_edit_profile_controller.dart';

class DokterEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterEditProfileController>(() => DokterEditProfileController());
  }
}
