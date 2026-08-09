import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/lensa_natrium_detail_controller.dart';

class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const textSecondary = Colors.grey;
  static const textPrimary = Colors.black87;
  static const danger = Colors.red;
  static const warning = Colors.orange;
  static const safe = Colors.green;
  static const surface = Colors.white;
  static const background = Color(0xFFF4F6F8);
}

class LensaNatriumDetailView extends GetView<LensaNatriumDetailController> {
  const LensaNatriumDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final food = controller.foodItem;
    final int sodiumMg =
        (food['natrium'] as num?)?.toInt() ??
        (food['sodium'] as num?)?.toInt() ??
        0;

    return Obx(() {
      final double limit = controller.dailyLimit.value;
      
      Color statusColor;
      String statusText;
      String statusDesc;

      if (limit == 0) {
        statusColor = AppColors.danger;
        statusText = "Sangat Dilarang";
        statusDesc = "Kondisi Anda saat ini sangat disarankan untuk menghindari natrium berlebih sama sekali.";
      } else if (sodiumMg > (limit * 0.5)) {
        statusColor = AppColors.danger;
        statusText = "Sangat Tinggi Natrium";
        statusDesc =
            "Konsumsi jajanan ini akan menghabiskan lebih dari setengah batas harian natrium Anda. Sangat disarankan untuk membatasinya.";
      } else if (sodiumMg > (limit * 0.3)) {
        statusColor = AppColors.warning;
        statusText = "Natrium Sedang";
        statusDesc =
            "Kandungan natrium cukup tinggi. Sebaiknya perhatikan asupan makanan lain hari ini agar tidak melebihi batas.";
      } else {
        statusColor = AppColors.safe;
        statusText = "Natrium Relatif Aman";
        statusDesc =
            "Kandungan natrium masih dalam batas yang wajar untuk satu kali ngemil.";
      }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Custom Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 30,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.fastfood_rounded,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.offNamedUntil(
                            '/lensa-natrium',
                            (route) => route.settings.name == '/main-navigation' || route.isFirst,
                          );
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
                        'Detail Lensa Natrium',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Separate White Box for Snack Name and Icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (food['description'] != null && food['description'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      food['description'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sodium Content Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              
                              const Text(
                                "Kandungan Natrium",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    "$sodiumMg",
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "mg",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      (limit > 0 && sodiumMg > (limit * 0.5))
                                          ? Icons.warning_rounded
                                          : Icons.info_outline_rounded,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                statusDesc,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 24),

              // Educational Info Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tahukah Anda?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              food['health_tip'] ??
                                  "Batas konsumsi natrium harian yang disarankan untuk Anda (${controller.ageGroup.value} dengan kondisi ${controller.conditionName.value}) adalah maksimal ${limit.toInt()} mg (menyesuaikan kepatuhan sistem aplikasi Gativa). Jajanan jalanan sering kali kaya akan MSG dan garam bumbu yang bisa membuat Anda tanpa sadar melebihi batas tersebut.",
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
          ],
        ),
      ),
    );
    });
  }
}
