import 'package:get/get.dart';
import '../controllers/informasi_kesehatan_controller.dart';

class InformasiKesehatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InformasiKesehatanController>(
      () => InformasiKesehatanController(),
    );
  }
}
