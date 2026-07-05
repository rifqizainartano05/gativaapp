import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/scanner_result_controller.dart';

class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const textSecondary = Colors.grey;
  static const textPrimary = Colors.black87;
  static const textMuted = Colors.black54;
  static const safe = Colors.green;
  static const warning = Colors.orange;
  static const danger = Colors.red;
  static const glassBorder = Color(0xFFE0E0E0);
  static const scannerBox = Colors.white;
}

class DashedLine extends StatelessWidget {
  const DashedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.black26),
              ),
            );
          }),
        );
      },
    );
  }
}

class ScannerResultView extends GetView<ScannerResultController> {
  const ScannerResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark),
      child: Obx(() {
        bool canGoBack = true;

        return PopScope(
          canPop: canGoBack,
          onPopInvoked: (didPop) {
            if (didPop) return;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
          body: Stack(
        children: [
          // Background Watermark (Receipt)
          Positioned(
            right: -40,
            top: -20,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.receipt_long_rounded,
                size: 250,
                color: AppColors.primary.withOpacity(0.04),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 80,
                bottom: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Informasi Natrium",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Hasil pindaian komposisi produk",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Receipt Box (Modern)
                  Obx(() => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                controller.foodName.value,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                controller.servingSize.value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDivider(),
                        const SizedBox(height: 20),

                        _buildInfoRow(
                          "Natrium per Sajian",
                          "${controller.sodiumPerServing.value.toInt()} mg"
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          "Sajian per Bungkus",
                          "${controller.servingsPerPack.value.toInt()} sajian"
                        ),

                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 20),

                        // Total Sodium Highlight
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL ASUPAN:',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${controller.totalCalculatedSodium.toInt()} mg',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: controller.totalCalculatedSodium >= 1000
                                    ? AppColors.danger
                                    : controller.totalCalculatedSodium >= 600
                                        ? AppColors.warning
                                        : AppColors.safe,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: controller.totalCalculatedSodium >= 1000
                                    ? AppColors.danger.withOpacity(0.1)
                                    : controller.totalCalculatedSodium >= 600
                                        ? AppColors.warning.withOpacity(0.1)
                                        : AppColors.safe.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                controller.totalCalculatedSodium >= 1000
                                    ? "Tinggi Natrium!"
                                    : controller.totalCalculatedSodium >= 600
                                        ? "Peringatan"
                                        : "Aman Dikonsumsi",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: controller.totalCalculatedSodium >= 1000
                                      ? AppColors.danger
                                      : controller.totalCalculatedSodium >= 600
                                          ? AppColors.warning
                                          : AppColors.safe,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )),

                  const SizedBox(height: 32),

                  // Portions Adjuster
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Porsi Konsumsi Anda:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Obx(() => Text(
                              '${controller.servingsMultiplier.value.toStringAsFixed(1)} Porsi',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(() => Row(
                          children: [
                            const Text('0.5x', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            Expanded(
                              child: Slider(
                                value: controller.servingsMultiplier.value,
                                min: 0.5,
                                max: 3.0,
                                divisions: 5,
                                label: '${controller.servingsMultiplier.value}x',
                                activeColor: AppColors.primary,
                                onChanged: (val) {
                                  controller.servingsMultiplier.value = val;
                                },
                              ),
                            ),
                            const Text('3x', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                      onPressed: () {
                        controller.saveAndLog();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: controller.totalCalculatedSodium >= 1000
                            ? AppColors.danger
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: controller.totalCalculatedSodium >= 1000
                            ? AppColors.danger.withOpacity(0.4)
                            : AppColors.primary.withOpacity(0.4),
                      ),
                      child: const Text(
                        'CATAT KONSUMSI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),

          // Custom Back Button
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: InkWell(
                onTap: () {
                  if (!canGoBack) {
                    Get.snackbar(
                      'Perhatian',
                      'Harap catat konsumsi produk untuk menyelesaikan misi.',
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } else {
                    Get.back();
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }),
  );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    // If you don't have DashedLine widget available globally, we can use a Container border
    return Container(
      width: double.infinity,
      height: 1,
      color: AppColors.glassBorder,
    );
  }
}
