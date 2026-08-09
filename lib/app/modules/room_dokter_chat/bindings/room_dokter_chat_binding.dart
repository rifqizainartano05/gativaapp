import 'package:get/get.dart';

import '../controllers/room_dokter_chat_controller.dart';

class RoomDokterChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomDokterChatController>(
      () => RoomDokterChatController(),
    );
  }
}
