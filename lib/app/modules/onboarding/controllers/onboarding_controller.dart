import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  final onboardingPages = [
    {
      'title': 'Pindai Natrium Anda',
      'description':
          'Ketahui kandungan garam pada makanan dalam hitungan detik. Hindari penyakit berisiko tinggi.',
      'icon': Icons.document_scanner_rounded,
    },
    {
      'title': 'Pantau Kesehatan',
      'description':
          'Lihat status kesehatan dan perbandingan asupan natrium harian melalui grafik interaktif modern.',
      'icon': Icons.monitor_heart_rounded,
    },
    {
      'title': 'Jaga Orang Terdekat',
      'description':
          'Tambahkan anggota grup, pantau rekam medis mereka, dan pastikan tetap dalam batas aman.',
      'icon': Icons.groups_2_rounded,
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  Future<void> _finishOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (e) {
      debugPrint('Error saving onboarding state: $e');
    }
    Get.offAllNamed(Routes.LOGIN);
  }

  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  void skip() {
    _finishOnboarding();
  }
}
