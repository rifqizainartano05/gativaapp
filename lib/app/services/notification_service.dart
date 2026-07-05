import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(settings: initializationSettings);

    // Minta izin notifikasi (Android 13+)
    await Permission.notification.request();
  }

  static Future<void> showLimitWarning(double current, double limit) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'gativa_limit_channel',
          'Peringatan Batas Natrium',
          channelDescription: 'Notifikasi jika melewati batas asupan',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id: 0,
      title: '⚠️ Batas Natrium Hampir Melewati Limit!',
      body:
          'Asupan hari ini: ${current.toInt()} mg (Batas: ${limit.toInt()} mg). Hati-hati ya!',
      notificationDetails: platformChannelSpecifics,
    );
  }

  static Future<void> showNotification({required int id, required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'gativa_general_channel',
          'Notifikasi Umum',
          channelDescription: 'Notifikasi sistem dan pengingat',
          importance: Importance.high,
          priority: Priority.high,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  static Future<void> scheduleDailyReminder() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'gativa_daily_channel',
          'Pengingat Harian',
          channelDescription: 'Pengingat misi dan target harian',
          importance: Importance.high,
          priority: Priority.high,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Mengingatkan setiap hari (dari waktu saat ini / login)
    await _notificationsPlugin.periodicallyShow(
      id: 999, // Menggunakan ID yang sama dengan gamifikasi
      title: 'Pengingat Sehat Gativa! 🎮',
      body: 'Jangan lupa selesaikan misi Detox Natrium dan cek target harianmu hari ini ya!',
      repeatInterval: RepeatInterval.daily,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }
}
