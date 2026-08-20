import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  final isTransitioning = false.obs;
  final isRippleStarted = false.obs;
  final isNavWhite = false.obs;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    _playOpeningSound();
    _startSplash();
  }

  void _playOpeningSound() async {
    try {
      await _audioPlayer.play(AssetSource('suara_opening.mp3'));
    } catch (e) {
      debugPrint('Error playing opening sound: $e');
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  void _startSplash() async {
    final stopwatch = Stopwatch()..start();

    String nextRoute = Routes.ONBOARDING;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      
      if (FirebaseAuth.instance.currentUser != null) {
        // Sign out user so they always have to login again when the app starts
        await FirebaseAuth.instance.signOut();
      }

      if (hasSeenOnboarding) {
        nextRoute = Routes.LOGIN;
      } else {
        nextRoute = Routes.ONBOARDING;
      }
    } catch (e) {
      debugPrint('SharedPreferences error: $e');
    }

    // Pastikan loading minimal 4 detik
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 4000) {
      await Future.delayed(Duration(milliseconds: 4000 - elapsed));
    }
    
    // Tahap 2: Mulai efek denyut membesar
    isRippleStarted.value = true;
    
    // Tunggu 900ms (pas saat ombak putih menabrak Navigation Bar di bawah)
    await Future.delayed(const Duration(milliseconds: 900));

    // Beri tahu UI untuk segera mengubah warna Navigation Bar menjadi putih
    isNavWhite.value = true;
    
    // Tunggu sisa waktu (300ms) untuk menyelesaikan efek ombak menutupi pojokan
    await Future.delayed(const Duration(milliseconds: 300));

    // Pindah halaman
    Get.offAllNamed(nextRoute);
  }
}
