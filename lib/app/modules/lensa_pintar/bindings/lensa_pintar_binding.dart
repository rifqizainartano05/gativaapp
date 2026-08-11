import 'package:get/get.dart';
import '../controllers/lensa_pintar_controller.dart';

class LensaPintarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LensaPintarController>(() => LensaPintarController());
  }
}
