import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/catalog_controller.dart';

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

class CatalogView extends StatelessWidget {
  const CatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final CatalogController controller = Get.put(CatalogController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Alternatif Makanan', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Cari makanan sehat...',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isEmpty) return const SizedBox.shrink();
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
            child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.categories.length,
              itemBuilder: (context, idx) {
                String cat = controller.categories[idx];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Obx(() {
                    bool isSelected = controller.selectedCategory.value == cat;
                    return ChoiceChip(
                      showCheckmark: true,
                      checkmarkColor: Colors.white,
                      label: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.glassCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.glassBorder),
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
            )),
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
                      Icon(Icons.sentiment_dissatisfied_rounded, color: AppColors.textMuted, size: 48),
                      SizedBox(height: 12),
                      Text('Alternatif tidak ditemukan.', style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
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
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            alt.category,
                            style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Food Comparison Layout
                        Row(
                          children: [
                            // Original Unhealthy Food (Red indicator)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Asal (Tinggi Garam)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  const SizedBox(height: 4),
                                  Text(
                                    alt.originalFood,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${alt.originalSodium.toInt()} mg',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.danger),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 20),
                            ),
                            // Safe Alternative Food (Green indicator)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Alternatif Sehat', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  const SizedBox(height: 4),
                                  Text(
                                    alt.alternativeFood,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${alt.alternativeSodium.toInt()} mg',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.safe),
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
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 16),

                        // Actions Panel
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Savings Highlight
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.safe.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Hemat ${alt.savings.toInt()} mg Garam!',
                                style: const TextStyle(fontSize: 11, color: AppColors.safe, fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Select Alternative Button
                            TextButton.icon(
                              onPressed: () => controller.selectAlternativeForCalculator(alt),
                              icon: const Icon(Icons.calculate_outlined, size: 16),
                              label: const Text('Hitung Porsi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            )
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
    );
  }
}
