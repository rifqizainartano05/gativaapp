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
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Builder(
        builder: (context) {
          bool canGoBack = true;

          return PopScope(
            canPop: canGoBack,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFF4F6F8),
              body: Column(
                children: [
                  // Green Header (like Riwayat)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                      bottom: 30,
                      left: 24,
                      right: 24,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: -30,
                          top: -40,
                          child: Icon(
                            Icons.receipt_long_rounded,
                            size: 150,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
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
                              'Hasil Scan Label',
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

                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Detail Informasi Gizi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Masukkan jumlah porsi yang Anda konsumsi untuk menghitung total asupan natrium.",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Form Box (Merged with Total Asupan)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputField(
                                  label: "Nama Produk",
                                  controller: controller.foodNameController,
                                  hintText: "Contoh: Susu Cokelat",
                                  readOnly: false,
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  label: "Takaran Saji",
                                  controller: controller.servingSizeController,
                                  hintText: "Contoh: 30 g",
                                  readOnly: true,
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  label: "Sajian per Kemasan",
                                  controller: controller.servingsPerPackController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  hintText: "Contoh: 2.5",
                                  readOnly: true,
                                  suffixText: "sajian",
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  label: "Natrium per Sajian (mg)",
                                  controller: controller.sodiumPerServingController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  hintText: "Contoh: 120",
                                  readOnly: true,
                                  suffixText: "mg",
                                ),
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  label: "Berapa kemasan yang dimakan?",
                                  controller: controller.portionController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  hintText: "Contoh: 1 (sebungkus) atau 0.5 (setengah)",
                                  readOnly: false,
                                  suffixText: "kemasan",
                                ),
                                const SizedBox(height: 24),
                                
                                // Total Sodium Calculation Display
                                Obx(() {
                                  final totalSodium = controller.totalCalculatedSodium;
                                  final isSafe = totalSodium <= 2000;
                                  
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isSafe ? Colors.green.shade50 : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSafe ? Colors.green.shade200 : Colors.red.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "TOTAL ASUPAN:",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isSafe ? Colors.green.shade100 : Colors.red.shade100,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isSafe ? "Aman" : "Lebih",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSafe ? Colors.green.shade700 : Colors.red.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "${totalSodium.toInt()} mg",
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: isSafe ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: Obx(() {
                              double sodium = controller.totalCalculatedSodium;
                              Color densityColor = sodium >= 1000
                                  ? AppColors.danger
                                  : (sodium >= 600 ? AppColors.warning : AppColors.primary);
                                  
                              return ElevatedButton(
                                onPressed: () {
                                  if (controller.portionController.text.isEmpty) {
                                    Get.snackbar(
                                      "Perhatian",
                                      "Harap masukkan jumlah porsi yang dikonsumsi.",
                                      backgroundColor: Colors.orange,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    return;
                                  }
                                  
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
                                  backgroundColor: densityColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  shadowColor: densityColor.withValues(alpha: 0.4),
                                ),
                                child: const Text(
                                  'SIMPAN & CATAT',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    bool readOnly = false,
    String? suffixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: readOnly ? Colors.black54 : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            suffixText: suffixText,
            suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black45),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.normal,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              borderSide: BorderSide(color: readOnly ? Colors.transparent : AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
          ),
        ),
      ],
    );
  }
}
