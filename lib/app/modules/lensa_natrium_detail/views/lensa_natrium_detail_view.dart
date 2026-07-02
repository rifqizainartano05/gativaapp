import 'package:flutter/material.dart';
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

    Color statusColor;
    String statusText;
    String statusDesc;

    if (sodiumMg > 1000) {
      statusColor = AppColors.danger;
      statusText = "Sangat Tinggi Natrium";
      statusDesc =
          "Konsumsi jajanan ini akan menghabiskan lebih dari setengah batas harian natrium Anda. Sangat disarankan untuk membatasinya.";
    } else if (sodiumMg > 600) {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Karena dari scanner, kita ingin kembali ke Lensa Natrium
            // dan bukan ke tampilan scanner
            Get.offNamedUntil('/lensa-natrium', (route) => route.settings.name == '/main-navigation' || route.isFirst);
          },
        ),
        title: const Text(
          'Detail Jajanan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: AppColors.primary),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: -30,
                      top: -20,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Icon(
                          Icons.camera_rounded,
                          size: 130,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.fastfood_rounded,
                          size: 50,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      food['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      food['description'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sodium Content Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Estimasi Kandungan Natrium",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
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
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "mg",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: statusColor.withOpacity(0.8),
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
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              sodiumMg > 1000
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
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                                  "Batas konsumsi natrium harian yang disarankan oleh WHO adalah sekitar 2000 mg (setara dengan 1 sendok teh garam). Jajanan jalanan sering kali kaya akan MSG dan garam bumbu yang bisa membuat Anda tanpa sadar melebihi batas tersebut.",
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
