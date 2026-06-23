import 'package:get/get.dart';
import '../controllers/lensa_natrium_controller.dart';

class LensaNatriumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LensaNatriumController>(
      () => LensaNatriumController(),
    );
  }
}
