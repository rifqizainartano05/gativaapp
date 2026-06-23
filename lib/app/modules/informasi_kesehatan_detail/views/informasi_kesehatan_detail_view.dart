import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/informasi_kesehatan_detail_controller.dart';

class InformasiKesehatanDetailView extends GetView<InformasiKesehatanDetailController> {
  const InformasiKesehatanDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final event = controller.event;
    final String base64Image = event['gambar_base64'] ?? '';
    Widget imageWidget = const SizedBox.shrink();

    if (base64Image.isNotEmpty) {
      try {
        final String base64Str = base64Image.contains(',') ? base64Image.split(',')[1] : base64Image;
        imageWidget = Image.memory(
          base64Decode(base64Str),
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } catch (e) {
        imageWidget = Container(
          color: Colors.grey.shade200,
          width: double.infinity,
          height: 200,
          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Detail Informasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // Watermark Icon
              Positioned.fill(
                child: Center(
                  child: Opacity(
                    opacity: 0.05,
                    child: Icon(
                      Icons.health_and_safety_rounded,
                      size: 250,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ),
              // Main Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (base64Image.isNotEmpty) imageWidget,
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: event['type'] == 'Nasional' ? Colors.red.shade50 : (event['type'] == 'Regional' ? Colors.blue.shade50 : Colors.green.shade50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event['type'] ?? 'Umum',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: event['type'] == 'Nasional' ? Colors.red.shade700 : (event['type'] == 'Regional' ? Colors.blue.shade700 : Colors.green.shade700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          event['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(event['date'] ?? '-', style: const TextStyle(fontSize: 14, color: Colors.black87))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Deskripsi',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                              ),
                              const Divider(height: 24),
                              Text(
                                event['description'] ?? '',
                                style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
