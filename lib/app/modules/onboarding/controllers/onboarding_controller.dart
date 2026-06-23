import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  final onboardingPages = [
    {
      'title': 'Pindai Natrium Anda',
      'description': 'Ketahui kandungan garam pada makanan dalam hitungan detik. Hindari penyakit berisiko tinggi.',
      'icon': Icons.document_scanner_rounded,
    },
    {
      'title': 'Pantau Kesehatan',
      'description': 'Lihat status kesehatan dan perbandingan asupan natrium harian melalui grafik interaktif modern.',
      'icon': Icons.monitor_heart_rounded,
    },
    {
      'title': 'Jaga Orang Terdekat',
      'description': 'Tambahkan anggota grup, pantau rekam medis mereka, dan pastikan tetap dalam batas aman.',
      'icon': Icons.groups_2_rounded,
    }
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void skip() {
    Get.offAllNamed(Routes.LOGIN);
  }
}
