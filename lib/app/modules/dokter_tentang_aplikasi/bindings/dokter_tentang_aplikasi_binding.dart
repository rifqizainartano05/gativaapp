import 'package:get/get.dart';

import '../controllers/dokter_tentang_aplikasi_controller.dart';

class DokterTentangAplikasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterTentangAplikasiController>(
      () => DokterTentangAplikasiController(),
    );
  }
}
