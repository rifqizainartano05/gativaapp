import 'package:get/get.dart';
import '../controllers/detail_tenaga_kesehatan_controller.dart';

class DetailTenagaKesehatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailTenagaKesehatanController>(() => DetailTenagaKesehatanController());
  }
}

