import 'package:get/get.dart';
import '../controllers/riwayat_anggota_controller.dart';

class RiwayatAnggotaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatAnggotaController>(() => RiwayatAnggotaController());
  }
}
