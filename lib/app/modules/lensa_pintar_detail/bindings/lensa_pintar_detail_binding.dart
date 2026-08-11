import 'package:get/get.dart';
import '../controllers/lensa_pintar_detail_controller.dart';

class LensaPintarDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LensaPintarDetailController>(
      () => LensaPintarDetailController(),
    );
  }
}
