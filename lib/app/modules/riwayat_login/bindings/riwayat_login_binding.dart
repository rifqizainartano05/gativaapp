import 'package:get/get.dart';

import '../controllers/riwayat_login_controller.dart';

class RiwayatLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatLoginController>(
      () => RiwayatLoginController(),
    );
  }
}
