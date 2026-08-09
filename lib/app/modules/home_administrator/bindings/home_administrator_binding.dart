import 'package:get/get.dart';

import '../controllers/home_administrator_controller.dart';

class HomeAdministratorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeAdministratorController>(
      () => HomeAdministratorController(),
    );
  }
}
