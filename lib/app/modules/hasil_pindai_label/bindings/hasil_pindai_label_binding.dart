import 'package:get/get.dart';
import '../controllers/hasil_pindai_label_controller.dart';

class HasilPindaiLabelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HasilPindaiLabelController>(
      () => HasilPindaiLabelController(),
    );
  }
}
