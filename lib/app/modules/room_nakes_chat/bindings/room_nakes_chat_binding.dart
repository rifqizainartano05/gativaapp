import 'package:get/get.dart';

import '../controllers/room_nakes_chat_controller.dart';

class RoomNakesChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomNakesChatController>(
      () => RoomNakesChatController(),
    );
  }
}
