import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import 'dart:async';
import '../../../services/notification_service.dart';

class NotifikasiDokterModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type;

  NotifikasiDokterModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = 'umum',
  });
}

class NotifikasiDokterController extends GetxController {
  final RxList<NotifikasiDokterModel> notifications = <NotifikasiDokterModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  final _firestore = FirebaseFirestore.instance;
  
  StreamSubscription? _userNotifSubscription;

  List<NotifikasiDokterModel> _userNotifs = [];

  void fetchNotifications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final authService = Get.find<AuthService>();
      if (authService.userRole.value.isEmpty) {
        await authService.fetchUserRole(user.uid);
      }
      
      // 1. Fetch User Notifications
      _userNotifSubscription?.cancel();
      _userNotifSubscription = Get.find<AuthService>()
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
              // Only notify if it was created in the last 120 seconds (handling clock drift)
              final diff = DateTime.now().difference(timestamp).inSeconds;
              if (diff < 120 && diff > -120 && (data['isRead'] != true)) {
                if (data['type'] == 'chat') {
                  NotificationService.showChatNotification(
                    id: change.doc.id.hashCode,
                    title: data['title'] ?? 'Notifikasi',
                    body: data['message'] ?? '',
                  );
                } else {
                  NotificationService.showNotification(
                    id: change.doc.id.hashCode,
                    title: data['title'] ?? 'Notifikasi',
                    body: data['message'] ?? '',
                  );
                }
              }
            }
          }
        }
        
        _userNotifs = snapshot.docs.map((doc) {
          final data = doc.data();
          return NotifikasiDokterModel(
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

    } else {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    fetchNotifications();
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  void onClose() {
    _userNotifSubscription?.cancel();
    super.onClose();
  }

  void _updateCombinedNotifs() {
    final combined = [..._userNotifs];
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
}
