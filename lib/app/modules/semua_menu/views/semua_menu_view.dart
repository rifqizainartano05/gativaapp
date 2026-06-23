import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/semua_menu_controller.dart';
import '../../../routes/app_pages.dart';

class SemuaMenuView extends GetView<SemuaMenuController> {
  const SemuaMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Semua Menu', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "SEMUA LAYANAN",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey, letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: Opacity(
                          opacity: 0.05,
                          child: Icon(
                            Icons.grid_view_rounded,
                            size: 200,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          final items = [
                            _MenuItem(icon: Icons.science_outlined, color: const Color(0xFF2E7D32), label: "Lensa Natrium", route: Routes.LENSA_NATRIUM),
                            _MenuItem(icon: Icons.restaurant_menu_rounded, color: const Color(0xFF2E7D32), label: "Katalog Makanan", route: Routes.CATALOG),
                            _MenuItem(icon: Icons.history_rounded, color: const Color(0xFF2E7D32), label: "Riwayat", route: Routes.RIWAYAT),
                            _MenuItem(icon: Icons.menu_book_rounded, color: const Color(0xFF2E7D32), label: "Edukasi", route: Routes.EDUKASI),
                            _MenuItem(icon: Icons.chat_bubble_outline_rounded, color: const Color(0xFF2E7D32), label: "Konsultasi Chat", route: Routes.CHAT),
                            _MenuItem(icon: Icons.health_and_safety_rounded, color: const Color(0xFF2E7D32), label: "Informasi Kesehatan", route: Routes.INFORMASI_KESEHATAN),
                          ];
                          final item = items[index];
                          return GestureDetector(
                            onTap: () {
                              if (item.route == Routes.PROFILE) {
                                Get.back();
                              }
                              Get.toNamed(item.route);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: item.color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(item.icon, color: item.color, size: 28),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.label,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.2),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color color;
  final String label;
  final String route;

  _MenuItem({required this.icon, required this.color, required this.label, required this.route});
}
