import 'package:get/get.dart';
import '../controllers/informasi_kesehatan_detail_controller.dart';

class InformasiKesehatanDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InformasiKesehatanDetailController>(
      () => InformasiKesehatanDetailController(),
    );
  }
}
