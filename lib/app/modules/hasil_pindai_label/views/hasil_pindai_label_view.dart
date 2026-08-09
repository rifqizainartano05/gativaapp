import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/hasil_pindai_label_controller.dart';

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

class HasilPindaiLabelView extends GetView<HasilPindaiLabelController> {
  const HasilPindaiLabelView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark),
      child: Builder(
        builder: (context) {
          bool canGoBack = true;

          return PopScope(
            canPop: canGoBack,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
            },
            child: Scaffold(
              backgroundColor: Colors.white,
            body: Stack(
        children: [
          // Background Watermark (Receipt)
          Positioned(
            left: 0,
            right: 0,
            top: -50,
            child: Align(
              alignment: Alignment.topCenter,
              child: Transform.rotate(
                angle: -0.1,
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 300,
                  color: AppColors.primary.withValues(alpha: 0.04),
                ),
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
                          color: AppColors.primary.withValues(alpha: 0.08),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Obx(() {
                                if (controller.isEditingName.value) {
                                  return TextField(
                                    controller: controller.foodNameController,
                                    focusNode: controller.foodNameFocusNode,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      controller.isEditingName.value = true;
                                      controller.foodNameFocusNode.requestFocus();
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            controller.foodNameController.text.isEmpty ? "Produk Pindaian" : controller.foodNameController.text,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.textPrimary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.edit_rounded,
                                          size: 18,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                              ),
                              decoration: const BoxDecoration(),
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

                        // Text Field for portion adjustment
                        const Text(
                          "Jumlah Porsi yang Dikonsumsi",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller.portionController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: "Contoh: 1 atau 0.5",
                            suffixText: "porsi",
                            suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
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
                                    ? AppColors.danger.withValues(alpha: 0.1)
                                    : controller.totalCalculatedSodium >= 600
                                        ? AppColors.warning.withValues(alpha: 0.1)
                                        : AppColors.safe.withValues(alpha: 0.1),
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


                  const SizedBox(height: 40),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                      onPressed: () {
                        double sodium = controller.totalCalculatedSodium;
                        Color densityColor = sodium >= 1000
                            ? AppColors.danger
                            : (sodium >= 600 ? AppColors.warning : AppColors.safe);
                        IconData densityIcon = sodium >= 1000
                            ? Icons.warning_rounded
                            : (sodium >= 600 ? Icons.info_rounded : Icons.check_circle_rounded);

                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  color: Colors.white,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Watermark
                                      Positioned(
                                        right: -30,
                                        bottom: -30,
                                        child: Icon(
                                          Icons.fastfood_rounded,
                                          size: 140,
                                          color: densityColor.withValues(alpha: 0.08),
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: densityColor.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(densityIcon, size: 48, color: densityColor),
                                          ),
                                          const SizedBox(height: 20),
                                          const Text(
                                            "Catat Konsumsi?",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            "Apakah Anda yakin ingin memakannya dan mencatat asupan ini ke dalam riwayat Anda?",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 28),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () => Get.back(),
                                                  style: OutlinedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  ),
                                                  child: const Text(
                                                    "Batal",
                                                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Get.back(); // close dialog
                                                    controller.saveAndLog();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    backgroundColor: densityColor,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    elevation: 0,
                                                  ),
                                                  child: const Text(
                                                    "Ya, Catat",
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: controller.totalCalculatedSodium >= 1000
                            ? AppColors.danger
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: controller.totalCalculatedSodium >= 1000
                            ? AppColors.danger.withValues(alpha: 0.4)
                            : AppColors.primary.withValues(alpha: 0.4),
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
                  Get.back();
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
                        color: Colors.black.withValues(alpha: 0.04),
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

          // Title
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: SafeArea(
              child: IgnorePointer(
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  child: const Text(
                    "Hasil Scan Label",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
        },
      ),
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
