import 'package:get/get.dart';
import '../controllers/gabung_grup_anggota_controller.dart';

class GabungGrupAnggotaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GabungGrupAnggotaController>(() => GabungGrupAnggotaController());
  }
}
