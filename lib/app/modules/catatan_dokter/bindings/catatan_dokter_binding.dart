import 'package:get/get.dart';
import '../controllers/catatan_dokter_controller.dart';

class CatatanDokterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatatanDokterController>(
      () => CatatanDokterController(),
    );
  }
}
