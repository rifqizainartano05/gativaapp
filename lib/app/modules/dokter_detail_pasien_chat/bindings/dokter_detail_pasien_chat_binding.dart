import 'package:get/get.dart';

import '../controllers/dokter_detail_pasien_chat_controller.dart';

class DokterDetailPasienChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterDetailPasienChatController>(
      () => DokterDetailPasienChatController(),
    );
  }
}
