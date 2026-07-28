import os
import re

def modify_controller(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add WidgetsBindingObserver
    if "with WidgetsBindingObserver" not in content:
        content = re.sub(r"class (\w+ProfileController) extends GetxController \{", r"class \1 extends GetxController with WidgetsBindingObserver {", content)

    # Modify onInit
    if "WidgetsBinding.instance.addObserver(this);" not in content:
        content = re.sub(r"  @override\n  void onInit\(\) \{\n    super.onInit\(\);", r"  @override\n  void onInit() {\n    super.onInit();\n    WidgetsBinding.instance.addObserver(this);", content)

    # Modify onClose
    if "WidgetsBinding.instance.removeObserver(this);" not in content:
        content = re.sub(r"  @override\n  void onClose\(\) \{", r"  @override\n  void onClose() {\n    WidgetsBinding.instance.removeObserver(this);", content)

    # Add didChangeAppLifecycleState
    if "didChangeAppLifecycleState" not in content:
        lifecycle_func = '''
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initNotifications();
    }
  }
'''
        content = re.sub(r"  @override\n  void onInit\(\)", lifecycle_func + r"\n  @override\n  void onInit()", content)

    # Replace toggleNotification
    old_toggle = r"  Future<void> toggleNotification\(bool value\) async \{[\s\S]*?    \}\n  \}"
    new_toggle = '''  Future<void> toggleNotification(bool value) async {
    final status = await Permission.notification.status;
    if (status.isGranted) {
      import_custom_popup(); // just a marker
      // Notification is already granted
    }
  }'''
    
    # We won't use regex for the whole toggle function, we can just replace it entirely with a smart regex
    
    toggle_pattern = r"  Future<void> toggleNotification\(bool value\) async \{[\s\S]*?(?=  void _showNotificationDialog|  void fetchUserData|  void fetchProfileData)"
    
    new_toggle_code = '''  Future<void> toggleNotification(bool value) async {
    final status = await Permission.notification.status;
    if (status.isGranted) {
      Get.snackbar(
        "Pengaturan Perangkat",
        "Notifikasi saat ini diaktifkan oleh sistem. Untuk mematikannya, silakan ubah di Pengaturan HP Anda.",
        backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
        colorText: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 3),
      );
      Future.delayed(const Duration(seconds: 2), () {
        openAppSettings();
      });
      _initNotifications(); // Re-check
    } else {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        isNotificationEnabled.value = true;
        _listenToIncomingChats();
        Get.snackbar(
          "Sukses",
          "Notifikasi berhasil diaktifkan!",
          backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
          colorText: const Color(0xFF2E7D32),
        );
      } else {
        Get.snackbar(
          "Pengaturan Perangkat",
          "Notifikasi dimatikan oleh sistem. Untuk menghidupkannya, silakan ubah di Pengaturan HP Anda.",
          backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
          colorText: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 3),
        );
        Future.delayed(const Duration(seconds: 2), () {
          openAppSettings();
        });
        isNotificationEnabled.value = false;
      }
    }
  }

'''
    
    content = re.sub(toggle_pattern, new_toggle_code, content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Modified {filepath}")

modify_controller(r"d:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\profile\controllers\profile_controller.dart")
modify_controller(r"d:\STARTUP\GARDA\aplikasi\gativa\lib\app\modules\nakes_profile\controllers\nakes_profile_controller.dart")
