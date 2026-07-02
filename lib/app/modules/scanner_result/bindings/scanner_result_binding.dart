import 'package:get/get.dart';
import '../controllers/scanner_result_controller.dart';

class ScannerResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScannerResultController>(
      () => ScannerResultController(),
    );
  }
}
