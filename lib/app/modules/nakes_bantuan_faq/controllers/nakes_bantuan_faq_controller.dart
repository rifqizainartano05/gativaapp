import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NakesBantuanFaqController extends GetxController {
  final List<Map<String, String>> faqs = [
    {
      'question': 'Bagaimana cara membalas chat pasien?',
      'answer': 'Anda dapat masuk ke tab Konsultasi dan memilih nama pasien yang ingin dibalas. Pesan baru akan berada di bagian paling atas daftar.',
    },
    {
      'question': 'Bisakah saya menghapus pasien dari daftar pantauan?',
      'answer': 'Saat ini, riwayat pasien akan tetap tersimpan selama mereka terdaftar di platform untuk memastikan kelengkapan rekam medis elektronik.',
    },
    {
      'question': 'Bagaimana jika aplikasi mengalami error?',
      'answer': 'Pastikan koneksi internet stabil. Jika masalah berlanjut, hubungi tim IT Support GATIVA di menu Bantuan Lanjutan atau restart aplikasi Anda.',
    },
    {
      'question': 'Apa yang harus dilakukan jika akun dihapus atau diblokir?',
      'answer': 'Jika akun Anda dihapus oleh admin (misal karena pelanggaran) atau dihapus sendiri, Anda tidak bisa lagi mengakses fitur. Untuk banding atau bantuan lebih lanjut, silakan hubungi tim kami di gatrapreventiva@gmail.com.',
    },
  ];

  void deleteAccount() {
    Get.defaultDialog(
      title: "Peringatan",
      middleText: "Fitur hapus akun nakes belum diimplementasikan untuk keamanan data pasien. Hubungi admin untuk menghapus akun Anda.",
      textConfirm: "Tutup",
      confirmTextColor: const Color(0xFFFFFFFF),
      onConfirm: () => Get.back(),
    );
  }
}
