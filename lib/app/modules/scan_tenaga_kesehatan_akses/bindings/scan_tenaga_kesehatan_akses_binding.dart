import 'package:get/get.dart';
import '../controllers/scan_tenaga_kesehatan_akses_controller.dart';

class ScanTenagaKesehatanAksesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanTenagaKesehatanAksesController>(
      () => ScanTenagaKesehatanAksesController(),
    );
  }
}

