import 'package:get/get.dart';
import '../controllers/gabung_anggota_controller.dart';

class GabungAnggotaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GabungAnggotaController>(() => GabungAnggotaController());
  }
}
