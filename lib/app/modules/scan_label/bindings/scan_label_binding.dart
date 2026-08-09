import 'package:get/get.dart';
import '../controllers/scan_label_controller.dart';

class ScanLabelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanLabelController>(() => ScanLabelController());
  }
}
