import 'package:get/get.dart';
import '../controllers/scan_dokter_akses_controller.dart';

class ScanDokterAksesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanDokterAksesController>(
      () => ScanDokterAksesController(),
    );
  }
}
