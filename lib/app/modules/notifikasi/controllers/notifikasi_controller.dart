import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotifikasiModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type;

  NotifikasiModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = 'umum',
  });
}

class NotifikasiController extends GetxController {
  final RxList<NotifikasiModel> notifications = <NotifikasiModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  void fetchNotifications() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('mobile')
          .doc(user.uid)
          .collection('notifikasi')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        
        List<NotifikasiModel> loadedNotifs = snapshot.docs.map((doc) {
          final data = doc.data();
          return NotifikasiModel(
            id: doc.id,
            title: data['title'] ?? 'Notifikasi',
            message: data['message'] ?? '',
            timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isRead: data['isRead'] ?? false,
            type: data['type'] ?? 'umum',
          );
        }).toList();

        notifications.value = loadedNotifs;
        isLoading.value = false;
      }, onError: (e) {
        isLoading.value = false;
      });
    } else {
      isLoading.value = false;
    }
  }

  void markAsRead(String id) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('mobile')
          .doc(user.uid)
          .collection('notifikasi')
          .doc(id)
          .update({'isRead': true});
    }
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotifikasiModel? getDailyReminder() {
    // Cari notifikasi terbaru dengan tipe 'pengingat_harian' yang dikirim hari ini
    final now = DateTime.now();
    try {
      return notifications.firstWhere((n) => 
        n.type == 'pengingat_harian' && 
        n.timestamp.year == now.year && 
        n.timestamp.month == now.month && 
        n.timestamp.day == now.day
      );
    } catch (e) {
      return null;
    }
  }
}
