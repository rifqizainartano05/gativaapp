import 'package:get/get.dart';

import '../controllers/edukasi_dokter_controller.dart';

class EdukasiDokterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EdukasiDokterController>(
      () => EdukasiDokterController(),
    );
  }
}
