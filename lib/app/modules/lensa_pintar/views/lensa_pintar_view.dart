import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/lensa_pintar_controller.dart';
import '../../../routes/app_pages.dart';

class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const textSecondary = Colors.grey;
  static const textPrimary = Colors.black87;
  static const danger = Colors.red;
  static const warning = Colors.orange;
  static const safe = Colors.green;
  static final glassBorder = Colors.white.withOpacity(0.5);
}

class LensaPintarView extends GetView<LensaPintarController> {
  const LensaPintarView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LensaPintarController>()) {
      Get.put(LensaPintarController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Obx(() {
        bool isFromMission = Get.arguments is Map && Get.arguments['isFromMission'] == true;
        bool canGoBack = !isFromMission || controller.isMissionCompleted.value;

        return PopScope(
          canPop: canGoBack,
          onPopInvoked: (didPop) {
            if (didPop) return;
            if (!canGoBack) {
              Get.snackbar(
                'Perhatian',
                'Harap cari atau deteksi 1 makanan untuk menyelesaikan misi.',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F6F8),
        body: SafeArea(
          top: false,
          bottom: true,
          child: Column(
            children: [
              // Custom Header (Matches Riwayat)
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 20,
                  left: 24,
                  right: 24,
                ),
                decoration: const BoxDecoration(
                  color: const Color(0xFF2E7D32),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 150,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (!canGoBack) {
                              Get.snackbar(
                                'Perhatian',
                                'Harap cari atau deteksi 1 makanan untuk menyelesaikan misi.',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } else {
                              Get.back();
                            }
                          },
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
                        const Text(
                          'Lensa Pintar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Kalkulator Card Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.calculate_rounded, color: Color(0xFF2E7D32), size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Kalkulator Label Gizi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Cari taksiran natrium jajanan atau makanan kemasan, atau gunakan AI untuk mendeteksi langsung dari foto label.",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F6F8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: controller.searchController,
                              onChanged: controller.searchFood,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Cari makanan...",
                                hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => Get.toNamed(Routes.SCAN_LABEL, arguments: ''),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Results List
              Expanded(
                child: Obx(() {
                  if (controller.searchResults.isEmpty) {
                    return const Center(child: Text("Tidak ada hasil."));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final item = controller.searchResults[index];
                      return Dismissible(
                        key: Key(item['id'] ?? item['name'] ?? index.toString()),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          controller.deleteJajanan(item['id'] ?? '', item['isGlobal'] ?? false);
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.delete_sweep_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        child: InkWell(
                        onTap: () => Get.toNamed(
                          Routes.LENSA_PINTAR_DETAIL,
                          arguments: item,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item['type'] == 'Kemasan' ? Icons.fastfood_rounded : Icons.restaurant_menu_rounded,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['type'],
                                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Builder(
                                builder: (context) {
                                  final int sodiumMg = (item['natrium'] as num?)?.toInt() ?? (item['sodium'] as num?)?.toInt() ?? 0;
                                  final double limit = controller.dailyLimit.value;
                                  Color statusColor;
                                  if (limit == 0) {
                                    statusColor = Colors.red;
                                  } else if (sodiumMg > (limit * 0.5)) {
                                    statusColor = Colors.red;
                                  } else if (sodiumMg > (limit * 0.3)) {
                                    statusColor = Colors.orange;
                                  } else {
                                    statusColor = Colors.green;
                                  }
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$sodiumMg mg',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: statusColor,
                                      ),
                                    ),
                                  );
                                }
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }),
  );
  }
}
