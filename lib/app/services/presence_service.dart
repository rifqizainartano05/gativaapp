import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'auth_service.dart';

class PresenceService extends GetxService with WidgetsBindingObserver {
  Future<PresenceService> init() async {
    WidgetsBinding.instance.addObserver(this);
    updatePresence(true);
    return this;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      updatePresence(true);
    } else if (state == AppLifecycleState.paused ||
               state == AppLifecycleState.detached ||
               state == AppLifecycleState.inactive) {
      updatePresence(false);
    }
  }

  Future<void> updatePresence(bool isOnline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final authService = Get.find<AuthService>();
        if (authService.userRole.value.isEmpty) {
          await authService.fetchUserRole(user.uid);
        }
        
        // Mencatat status online di Firebase untuk semua role (Pasien dan Dokter).


        final data = <String, dynamic>{
          'isOnline': isOnline,
        };
        if (!isOnline) {
          data['lastSeen'] = FieldValue.serverTimestamp();
        }
        await authService.getUserReference(user.uid).set(data, SetOptions(merge: true));
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
