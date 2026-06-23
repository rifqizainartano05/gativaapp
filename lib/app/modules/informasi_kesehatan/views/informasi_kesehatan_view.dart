import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/informasi_kesehatan_controller.dart';

class InformasiKesehatanView extends GetView<InformasiKesehatanController> {
  const InformasiKesehatanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Informasi Kesehatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.checkupEvents.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.checkupEvents.length,
            itemBuilder: (context, index) {
              final event = controller.checkupEvents[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed('/informasi-kesehatan-detail', arguments: event);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: event['type'] == 'Nasional' ? Colors.red.shade50 : (event['type'] == 'Regional' ? Colors.blue.shade50 : Colors.green.shade50),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              event['organizer'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: event['type'] == 'Nasional' ? Colors.red.shade700 : (event['type'] == 'Regional' ? Colors.blue.shade700 : Colors.green.shade700),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                event['type'],
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(child: Text(event['date'], style: const TextStyle(fontSize: 13, color: Colors.black87))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              (event['description'] ?? '').length > 50 
                                  ? 'Keterangan: ${(event['description'] ?? '').substring(0, 50)}...' 
                                  : 'Keterangan: ${event['description'] ?? ''}',
                              style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Lihat Detail",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
