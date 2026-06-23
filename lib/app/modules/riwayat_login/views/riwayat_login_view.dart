import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_login_controller.dart';
import 'package:intl/intl.dart';

class RiwayatLoginView extends GetView<RiwayatLoginController> {
  const RiwayatLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Riwayat Login', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Watermark Icon
          Positioned(
            top: -50,
            right: -50,
            child: Icon(
              Icons.history_rounded,
              size: 300,
              color: const Color(0xFF2E7D32).withOpacity(0.05),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
            }

            if (controller.loginLogs.isEmpty) {
              return const Center(
                child: Text('Belum ada riwayat login.', style: TextStyle(color: Colors.grey)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: controller.loginLogs.length,
              itemBuilder: (context, index) {
                final log = controller.loginLogs[index];
                DateTime ts = log['timestamp'];
                String device = log['device'] ?? 'Perangkat Tidak Dikenal';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phonelink_setup_rounded, color: Color(0xFF2E7D32)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(device, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(ts),
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 20),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
