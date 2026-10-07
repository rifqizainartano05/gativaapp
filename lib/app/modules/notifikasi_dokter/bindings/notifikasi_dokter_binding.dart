import 'package:get/get.dart';
import '../controllers/notifikasi_dokter_controller.dart';

class NotifikasiDokterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotifikasiDokterController>(() => NotifikasiDokterController());
  }
}
