import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/lensa_pintar_detail_controller.dart';

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

class LensaPintarDetailView extends GetView<LensaPintarDetailController> {
  const LensaPintarDetailView({super.key});

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
                            '/lensa-pintar',
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
                        'Detail Lensa Pintar',
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
                    border: Border.all(color: AppColors.safe.withOpacity(0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.safe.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.safe,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Informasi Nutrisi Klinis",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (context) {
                                String ssText = (food['servingSize']?.toString().isEmpty ?? true) ? "1 Porsi" : food['servingSize'].toString();
                                var spp = food['servingsPerPack'] ?? 1;
                                String sppText = (spp is num && spp <= 0) 
                                    ? "1 Porsi" 
                                    : (spp is num && spp == spp.toInt() ? "${spp.toInt()} Porsi" : "$spp Porsi");
                                
                                double sppVal = (spp is num && spp > 0) ? spp.toDouble() : 1.0;
                                double spsVal = (food['sodiumPerServing'] is num) ? food['sodiumPerServing'].toDouble() : sodiumMg.toDouble();
                                
                                // Parse number and unit from serving size (e.g. "30 g" -> 30, "g")
                                final numMatch = RegExp(r'([\d.]+)').firstMatch(ssText);
                                double ssVal = numMatch != null ? double.tryParse(numMatch.group(1) ?? '1') ?? 1 : 1;
                                String unitText = ssText.replaceAll(RegExp(r'[\d.\s]'), '').trim();
                                if (unitText.isEmpty) unitText = "Porsi";

                                double totalBerat = ssVal * sppVal;
                                double natriumSatuBungkus = spsVal * sppVal;
                                // Retrieve explicitly passed portionEaten, or fallback to math
                                double portionEaten = 1.0;
                                if (food['portionEaten'] != null) {
                                  portionEaten = (food['portionEaten'] is num) ? food['portionEaten'].toDouble() : 1.0;
                                } else {
                                  double natriumSatuBungkus = spsVal * sppVal;
                                  portionEaten = natriumSatuBungkus > 0 ? (sodiumMg / natriumSatuBungkus) : 1.0;
                                }
                                
                                String portionEatenStr = portionEaten == portionEaten.toInt() 
                                    ? portionEaten.toInt().toString() 
                                    : portionEaten.toStringAsFixed(1);
                                
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Berdasarkan standar regulasi pelabelan gizi, penting untuk memahami terminologi \"Takaran Saji\" (Serving Size) dan \"Sajian Per Kemasan\" (Servings Per Container).",
                                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                                    ),
                                    const SizedBox(height: 12),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                                        children: [
                                          const TextSpan(text: "• "),
                                          const TextSpan(text: "Takaran Saji", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                          const TextSpan(text: " merepresentasikan jumlah asupan standar dalam satu kali konsumsi. Pada produk ini, 1 porsi setara dengan "),
                                          TextSpan(text: ssText, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                          const TextSpan(text: "."),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                                        children: [
                                          const TextSpan(text: "• "),
                                          const TextSpan(text: "Sajian Per Kemasan", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                          const TextSpan(text: " mengindikasikan total porsi yang tersedia dalam satu unit kemasan utuh. Produk ini memiliki "),
                                          TextSpan(text: sppText, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                          const TextSpan(text: "."),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "Estimasi akumulasi massa atau volume bersih dalam satu kemasan utuh dapat dihitung sebagai berikut:",
                                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${ssVal.toInt() == ssVal ? ssVal.toInt() : ssVal} $unitText × $sppText = ${totalBerat.toInt() == totalBerat ? totalBerat.toInt() : totalBerat.toStringAsFixed(1)} $unitText",
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 16),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                                        children: [
                                          const TextSpan(text: "Perlu diperhatikan bahwa kandungan Natrium sebesar "),
                                          TextSpan(text: "${spsVal.toInt() == spsVal ? spsVal.toInt() : spsVal} mg", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                          const TextSpan(text: " yang tercantum adalah takaran untuk 1 porsi konsumsi, bukan merepresentasikan total kandungan dalam satu kemasan."),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Berdasarkan data asupan yang direkam, Anda telah mengonsumsi sebanyak $portionEatenStr kemasan. Total kandungan Natrium untuk 1 kemasan utuh adalah:",
                                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${spsVal.toInt() == spsVal ? spsVal.toInt() : spsVal} mg × $sppText = ${natriumSatuBungkus.toInt() == natriumSatuBungkus ? natriumSatuBungkus.toInt() : natriumSatuBungkus.toStringAsFixed(1)} mg Natrium",
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),

                                  ],
                                );
                              },
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
