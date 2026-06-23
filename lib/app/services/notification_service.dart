import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // Minta izin notifikasi (Android 13+)
    await Permission.notification.request();
  }

  static Future<void> showLimitWarning(double current, double limit) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'garda_limit_channel',
      'Peringatan Batas Natrium',
      channelDescription: 'Notifikasi jika melewati batas asupan',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id: 0,
      title: '⚠️ Batas Natrium Hampir Melewati Limit!',
      body: 'Asupan hari ini: ${current.toInt()} mg (Batas: ${limit.toInt()} mg). Hati-hati ya!',
      notificationDetails: platformChannelSpecifics,
    );
  }
}
