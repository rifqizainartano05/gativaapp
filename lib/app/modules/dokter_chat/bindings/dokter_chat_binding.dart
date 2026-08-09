import 'package:get/get.dart';
import '../controllers/dokter_chat_controller.dart';

class DokterChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DokterChatController>(() => DokterChatController());
  }
}
