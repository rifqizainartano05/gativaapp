import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'auth_service.dart';

class PresenceService extends GetxService with WidgetsBindingObserver {
  Future<PresenceService> init() async {
    WidgetsBinding.instance.addObserver(this);
    _updatePresence(true);
    return this;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _updatePresence(true);
    } else if (state == AppLifecycleState.paused ||
               state == AppLifecycleState.detached ||
               state == AppLifecycleState.inactive) {
      _updatePresence(false);
    }
  }

  Future<void> _updatePresence(bool isOnline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final authService = Get.find<AuthService>();
        if (authService.userRole.value.isEmpty) {
          await authService.fetchUserRole(user.uid);
        }
        
        // Hanya pasien yang perlu mencatat status online di Firebase.
        // Nakes menggunakan jadwal praktek.
        if (authService.userRole.value != 'Pasien') {
          return;
        }

        final data = <String, dynamic>{
          'isOnline': isOnline,
        };
        if (!isOnline) {
          data['lastSeen'] = FieldValue.serverTimestamp();
        }
        await authService.getUserReference(user.uid).update(data);
      } catch (e) {
        debugPrint('Failed to update presence: $e');
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
