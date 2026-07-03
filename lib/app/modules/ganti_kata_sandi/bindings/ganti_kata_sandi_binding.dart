import 'package:get/get.dart';
import '../controllers/ganti_kata_sandi_controller.dart';

class GantiKataSandiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GantiKataSandiController>(
      () => GantiKataSandiController(),
    );
  }
}
