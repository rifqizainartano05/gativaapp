import 'package:get/get.dart';
import '../controllers/gamifikasi_controller.dart';

class GamifikasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GamifikasiController>(
      () => GamifikasiController(),
    );
  }
}
