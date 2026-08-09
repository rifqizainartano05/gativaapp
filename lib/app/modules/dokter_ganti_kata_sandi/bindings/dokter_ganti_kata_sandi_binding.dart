import 'package:get/get.dart';
import '../controllers/dokter_ganti_kata_sandi_controller.dart';

class DokterGantiKataSandiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterGantiKataSandiController>(
      () => DokterGantiKataSandiController(),
    );
  }
}
