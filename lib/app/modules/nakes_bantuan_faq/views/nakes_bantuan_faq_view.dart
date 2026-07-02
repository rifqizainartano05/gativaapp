import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/nakes_bantuan_faq_controller.dart';


class NakesBantuanFaqView extends GetView<NakesBantuanFaqController> {
  const NakesBantuanFaqView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                // Tidak melengkung sesuai permintaan
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -40,
                    top: -20,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 130,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Bantuan & FAQ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 52), // 36 (icon size) + 16 (spacing)
                        child: Text(
                          'Pusat bantuan untuk Tenaga Kesehatan',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Watermark Background inside the content container
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Transform.rotate(
                          angle: -0.2,
                          child: Icon(
                            Icons.health_and_safety_rounded,
                            size: 150,
                            color: Colors.grey.withOpacity(0.04),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      _buildFaqItem(
                        'Bagaimana cara membalas chat pasien?',
                        'Anda dapat masuk ke tab Konsultasi dan memilih nama pasien yang ingin dibalas. Pesan baru akan berada di bagian paling atas daftar.',
                      ),
                      _buildFaqItem(
                        'Bisakah saya menghapus pasien dari daftar pantauan?',
                        'Saat ini, riwayat pasien akan tetap tersimpan selama mereka terdaftar di platform untuk memastikan kelengkapan rekam medis elektronik.',
                      ),
                      _buildFaqItem(
                        'Bagaimana jika aplikasi mengalami error?',
                        'Pastikan koneksi internet stabil. Jika masalah berlanjut, hubungi tim IT Support GATIVA di menu Bantuan Lanjutan atau restart aplikasi Anda.',
                      ),
                      _buildFaqItem(
                        'Apa yang harus dilakukan jika akun dihapus atau diblokir?',
                        'Jika akun Anda dihapus oleh admin (misal karena pelanggaran) atau dihapus sendiri, Anda tidak bisa lagi mengakses fitur. Untuk banding atau bantuan lebih lanjut, silakan hubungi tim kami di gatrapreventiva@gmail.com.',
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Butuh Bantuan Lain?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.email_rounded, color: Color(0xFF2E7D32), size: 20),
                              SizedBox(width: 8),
                              SelectableText(
                                'gatrapreventiva@gmail.com',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ), // Container
          ), // SingleChildScrollView
        ), // Expanded
      ], // Column children
    ), // Column
  ), // Scaffold
); // AnnotatedRegion
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
