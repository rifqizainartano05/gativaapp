import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/nakes_catalog_controller.dart';
import '../../../widgets/custom_popup.dart';

// Inlined AppColors
class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const textSecondary = Colors.grey;
  static const textPrimary = Colors.black87;
  static const textMuted = Colors.black54;
  static const safe = Colors.green;
  static const warning = Colors.orange;
  static const danger = Colors.red;
  static const glassBorder = Color(0xFFE0E0E0);
  static const glassCard = Colors.white;
}

class NakesCatalogView extends StatelessWidget {
  const NakesCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final NakesCatalogController controller = Get.put(NakesCatalogController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: Column(
          children: [
            // Custom Header with Watermark
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
                        Icons.restaurant_menu_rounded,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Katalog Makanan',
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
            Expanded(
              child: Column(
                children: [
                  // Filter & Search Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16,
                    ),
                child: TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: 'Cari makanan sehat...',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: Obx(() {
                      if (controller.searchQuery.value.isEmpty)
                        return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          controller.searchQuery.value = '';
                          FocusScope.of(context).unfocus();
                        },
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Categories Selection
              SizedBox(
                height: 40,
                child: Obx(
                  () => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.categories.length,
                    itemBuilder: (context, idx) {
                      String cat = controller.categories[idx];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Obx(() {
                          bool isSelected =
                              controller.selectedCategory.value == cat;
                          return ChoiceChip(
                            showCheckmark: true,
                            checkmarkColor: Colors.white,
                            label: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.glassCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: AppColors.glassBorder,
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedCategory.value = cat;
                              }
                            },
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Catalog Listing
              Expanded(
                child: Obx(() {
                  final list = controller.filteredAlternatives;
                  if (list.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sentiment_dissatisfied_rounded,
                            color: AppColors.textMuted,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Alternatif tidak ditemukan.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 100,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, idx) {
                      final alt = list[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                alt.category,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Food Comparison Layout
                            Row(
                              children: [
                                // Original Unhealthy Food (Red indicator)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Asal (Tinggi Garam)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        alt.originalFood,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${alt.originalSodium.toInt()} mg',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.danger,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                                // Safe Alternative Food (Green indicator)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Alternatif Sehat',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        alt.alternativeFood,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${alt.alternativeSodium.toInt()} mg',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.safe,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(height: 1, color: AppColors.glassBorder),
                            const SizedBox(height: 12),

                            // Health description
                            Text(
                              alt.benefit,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Actions Panel
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Savings Highlight
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.safe.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Hemat ${alt.savings.toInt()} mg Garam!',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.safe,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      onPressed: () => _showAddEditBottomSheet(
                                        context,
                                        controller,
                                        food: alt,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        CustomPopup.showConfirm(
                                          title: 'Hapus Data',
                                          message: 'Yakin ingin menghapus ${alt.alternativeFood}?',
                                          onConfirm: () {
                                            controller.deleteFood(alt.id);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text(
                  'Tambah Makanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _showAddEditBottomSheet(context, controller),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEditBottomSheet(
    BuildContext context,
    NakesCatalogController controller, {
    AlternativeFood? food,
  }) {
    final isEdit = food != null;
    final asliCtrl = TextEditingController(
      text: isEdit ? food.originalFood : '',
    );
    final altCtrl = TextEditingController(
      text: isEdit ? food.alternativeFood : '',
    );
    final hematCtrl = TextEditingController(
      text: isEdit ? food.savings.toString() : '',
    );

    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -40,
                  top: -40,
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    size: 150,
                    color: AppColors.primary.withOpacity(0.05),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Edit Makanan' : 'Tambah Makanan',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Get.back(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: asliCtrl,
                      decoration: InputDecoration(
                        labelText: 'Makanan Asli (Tinggi Garam)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: altCtrl,
                      decoration: InputDecoration(
                        labelText: 'Makanan Alternatif Sehat',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: hematCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Hemat Natrium (mg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Colors.grey),
                            ),
                            onPressed: () => Get.back(),
                            child: const Text(
                              "Batal",
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              final asli = asliCtrl.text;
                              final alt = altCtrl.text;
                              final hemat = double.tryParse(hematCtrl.text) ?? 0.0;
    
                              if (asli.isNotEmpty && alt.isNotEmpty) {
                                if (isEdit) {
                                  controller.updateFood(food.id, asli, alt, hemat);
                                } else {
                                  controller.addFood(asli, alt, hemat);
                                }
                                Get.back();
                              } else {
                                CustomPopup.showWarning(
                                  'Peringatan',
                                  'Harap isi semua bidang teks',
                                );
                              }
                            },
                            child: Text(
                              isEdit ? 'Simpan' : 'Tambah',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
          ),
        ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
