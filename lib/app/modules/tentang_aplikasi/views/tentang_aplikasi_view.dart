import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/tentang_aplikasi_controller.dart';

class TentangAplikasiView extends GetView<TentangAplikasiController> {
  const TentangAplikasiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF8F9FA),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF2E7D32),
        body: Column(
          children: [
            // Top Green Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -40,
                    top: -20,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.info_outline_rounded,
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
                              'Tentang Aplikasi',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bottom Content Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- App Info Card ---
                      _buildAppInfoCard(),
                      const SizedBox(height: 32),

                      // --- Fitur Utama ---
                      const Text(
                        'Fitur Utama Pasien',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        icon: Icons.qr_code_scanner_rounded,
                        title: 'Lensa Natrium',
                        description: 'Memindai bungkus makanan (nutrition facts) untuk mengetahui kandungan natrium secara instan.',
                        color: const Color(0xFF2E7D32),
                      ),
                      _buildFeatureCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Chat Dokter',
                        description: 'Berkonsultasi langsung dengan tenaga kesehatan terpercaya kapan saja.',
                        color: const Color(0xFF1976D2),
                      ),
                      _buildFeatureCard(
                        icon: Icons.history_rounded,
                        title: 'Riwayat',
                        description: 'Melihat catatan konsumsi dan rekam medis harian Anda dengan mudah.',
                        color: const Color(0xFFE65100),
                      ),
                      _buildFeatureCard(
                        icon: Icons.menu_book_rounded,
                        title: 'Edukasi',
                        description: 'Membaca artikel informatif terkait gaya hidup dan kesehatan.',
                        color: const Color(0xFF00796B),
                      ),
                      const SizedBox(height: 32),

                      // --- Panduan Natrium ---
                      const Text(
                        'Panduan Batas Natrium Harian',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Referensi asupan maksimal yang dianjurkan.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),

                      _buildLimitTable(
                        title: "10 - 18 Tahun (Remaja)",
                        color: const Color(0xFFF57C00),
                        items: [
                          {"label": "Sehat", "val": "1.500 mg"},
                          {"label": "Hipertensi", "val": "1.200 mg"},
                          {"label": "Penyakit Kardiovaskular", "val": "1.000 mg"},
                          {"label": "Penyakit Jantung Koroner", "val": "1.000 mg"},
                          {"label": "Penyakit Ginjal Kronis", "val": "800 - 1.000 mg"},
                          {"label": "Stroke", "val": "-"},
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLimitTable(
                        title: "18 - 59 Tahun (Dewasa)",
                        color: const Color(0xFF1976D2),
                        items: [
                          {"label": "Sehat", "val": "2.000 mg"},
                          {"label": "Hipertensi", "val": "1.500 mg"},
                          {"label": "Penyakit Kardiovaskular", "val": "1.500 mg"},
                          {"label": "Penyakit Jantung Koroner", "val": "1.500 mg"},
                          {"label": "Penyakit Ginjal Kronis", "val": "1.500 mg"},
                          {"label": "Stroke", "val": "1.500 mg"},
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      _buildNoteCard(),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GATIVA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E7D32),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),
          const Text(
            'Aplikasi inovatif yang dirancang untuk membantu Anda memantau kesehatan dan menjaga asupan natrium harian. Dengan antarmuka yang ramah pengguna, Anda dapat berkonsultasi dengan tenaga kesehatan terpercaya dan mencatat konsumsi harian Anda secara mudah dan praktis.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String description, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitTable({required String title, required Color color, required List<Map<String, String>> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.person_outline_rounded, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: items.map((item) {
                final bool isLast = items.last == item;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item["label"]!,
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          ),
                          Text(
                            item["val"]!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(height: 1, color: Colors.grey.shade100),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Light purple for note
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1BEE7), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF8E24AA), size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahukah Anda?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF8E24AA),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "• 2.000 mg Natrium setara dengan sekitar 1 sendok teh garam (5 gram).\n• Membatasi asupan natrium sangat penting untuk menjaga tekanan darah tetap normal (ideal < 120/80 mmHg).",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
