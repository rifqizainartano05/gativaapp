import 'package:get/get.dart';

import '../controllers/dokter_bantuan_faq_controller.dart';

class DokterBantuanFaqBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterBantuanFaqController>(
      () => DokterBantuanFaqController(),
    );
  }
}
