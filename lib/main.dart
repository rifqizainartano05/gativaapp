import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/routes/app_pages.dart';
import 'app/services/auth_service.dart';

import 'app/services/notification_service.dart';
import 'app/services/network_service.dart';
import 'app/services/presence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await NotificationService.init();
  } catch (e) {
    debugPrint('Firebase gagal inisialisasi: $e');
  }

  // Daftarkan AuthService ke memori secara sinkron agar tidak ada error 'not found'
  final authService = Get.put(AuthService());
  // Inisialisasi AuthService secara terpisah (misal fetch role)
  try {
    await authService.init();
    Get.put(NetworkService()).init();
    Get.put(PresenceService()).init();
  } catch (e) {
    debugPrint('Service init error: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    GetMaterialApp(
      title: "GATIVA",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}
