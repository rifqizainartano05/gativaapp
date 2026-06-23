import 'package:get/get.dart';
import '../controllers/lensa_natrium_detail_controller.dart';

class LensaNatriumDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LensaNatriumDetailController>(
      () => LensaNatriumDetailController(),
    );
  }
}
