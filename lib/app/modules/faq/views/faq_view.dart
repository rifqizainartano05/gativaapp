import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/faq_controller.dart';

class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const textSecondary = Colors.grey;
  static const textPrimary = Colors.black87;
  static const textMuted = Colors.black54;
  static const safe = Colors.green;
  static const warning = Colors.orange;
  static const danger = Colors.red;
}

class FaqView extends GetView<FaqController> {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Bantuan & FAQ', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                ]
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Pusat Bantuan",
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Temukan jawaban cepat atas pertanyaan seputar aplikasi Garda.",
                              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Masih butuh bantuan?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                              const SizedBox(height: 2),
                              Text("Hubungi support@garda.id", style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9))),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.7), size: 14)
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "PERTANYAAN UMUM",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary, letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),

            // FAQ Items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.faqs.length,
              itemBuilder: (context, index) {
                final faq = controller.faqs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      title: Text(faq['question']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                      iconColor: AppColors.primary,
                      collapsedIconColor: Colors.grey,
                      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      children: [
                        Container(height: 1, color: Colors.grey.shade100, margin: const EdgeInsets.only(bottom: 16)),
                        Text(
                          faq['answer']!, 
                          style: const TextStyle(color: AppColors.textMuted, height: 1.6, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}
