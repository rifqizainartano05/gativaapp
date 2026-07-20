import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';

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

  final _firestore = FirebaseFirestore.instance;

  List<NotifikasiModel> _userNotifs = [];
  List<NotifikasiModel> _edukasiNotifs = [];
  List<NotifikasiModel> _infoNotifs = [];

  void fetchNotifications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final authService = Get.find<AuthService>();
      if (authService.userRole.value.isEmpty) {
        await authService.fetchUserRole(user.uid);
      }
      
      // 1. Fetch User Notifications
      Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('notifikasi')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
            
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            if (data != null) {
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              // Only notify if it was created in the last 15 seconds to avoid spam on initial load
              if (DateTime.now().difference(timestamp).inSeconds < 15 && (data['isRead'] != true)) {
                NotificationService.showNotification(
                  id: change.doc.id.hashCode,
                  title: data['title'] ?? 'Notifikasi',
                  body: data['message'] ?? '',
                );
              }
            }
          }
        }
        
        _userNotifs = snapshot.docs.map((doc) {
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
        _updateCombinedNotifs();
      }, onError: (e) => print(e));

      // 2. Fetch Edukasi from Nakes
      _firestore.collectionGroup('edukasi').snapshots().listen((snapshot) {
        _edukasiNotifs = snapshot.docs.map((doc) {
          final data = doc.data();
          final timestamp = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return NotifikasiModel(
            id: doc.id,
            title: 'Edukasi: ${data['judul'] ?? 'Materi Baru'}',
            message: 'Diunggah pada tanggal: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
            timestamp: timestamp,
            isRead: true, // Asumsikan global post tidak ada unread state per user
            type: 'edukasi',
          );
        }).toList();
        _updateCombinedNotifs();
      }, onError: (e) => print(e));

      // 3. Fetch Informasi Kesehatan dari Nakes
      _firestore.collectionGroup('informasi_kesehatan').snapshots().listen((snapshot) {
        _infoNotifs = snapshot.docs.map((doc) {
          final data = doc.data();
          final timestamp = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return NotifikasiModel(
            id: doc.id,
            title: 'Info Kesehatan: ${data['keterangan'] ?? 'Info Baru'}',
            message: 'Diunggah pada tanggal: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
            timestamp: timestamp,
            isRead: true,
            type: 'informasi_kesehatan',
          );
        }).toList();
        _updateCombinedNotifs();
      }, onError: (e) => print(e));

    } else {
      isLoading.value = false;
    }
  }

  void _updateCombinedNotifs() {
    final combined = [..._userNotifs, ..._edukasiNotifs, ..._infoNotifs];
    // Sort descending by timestamp
    combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifications.value = combined;
    isLoading.value = false;
  }

  void markAsRead(String id) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.find<AuthService>()
          .getUserReference(user.uid)
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
      return notifications.firstWhere(
        (n) =>
            n.type == 'pengingat_harian' &&
            n.timestamp.year == now.year &&
            n.timestamp.month == now.month &&
            n.timestamp.day == now.day,
      );
    } catch (e) {
      return null;
    }
  }
}
