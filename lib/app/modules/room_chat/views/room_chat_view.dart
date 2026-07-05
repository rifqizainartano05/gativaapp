import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/room_chat_controller.dart';
import '../../chat/controllers/chat_controller.dart';

class RoomChatView extends GetView<RoomChatController> {
  const RoomChatView({super.key});

  void _showRatingDialog(BuildContext context, String doctorId) {
    int rating = 0;
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Beri Penilaian", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    "Seberapa puas Anda dengan layanan konsultan kami?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (rating > 0) {
                        Get.back();
                        if (Get.isRegistered<ChatController>()) {
                          Get.find<ChatController>().updateDoctorRating(doctorId, rating);
                          Get.snackbar(
                            "Terima Kasih", 
                            "Rating Anda berhasil dikirim",
                            backgroundColor: Colors.white,
                            colorText: Colors.black,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text("Kirim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna background modern yang sangat soft
      body: Column(
        children: [
          _buildCustomHeader(context),
          Expanded(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Watermark Background
                Positioned.fill(
                  child: Center(
                    child: Opacity(
                      opacity: 0.04,
                      child: Icon(
                        Icons.medical_services_rounded,
                        size: 250,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Obx(() => ListView.builder(
                          shrinkWrap: true,
                          reverse: true, // Auto-scroll ke bawah
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final msg = controller.messages[index];
                            return _ChatBubble(
                              id: msg.id,
                              text: msg.text,
                              isUser: msg.isUser,
                              senderName: msg.senderName,
                              senderRole: msg.senderRole,
                              time: msg.time,
                            );
                          },
                        )),
                      ),
                    ),
                    // Input Area
                    Builder(
                      builder: (context) {
                        bool isOnline = false;
                        final doc = controller.selectedDoctor.value;
                        if (doc != null) {
                          final String jadwalOnline = doc['jadwal_online'] ?? '';
                          try {
                            final parts = jadwalOnline.split('-');
                            if (parts.length == 2) {
                              final startParts = parts[0].trim().split(':');
                              final endParts = parts[1].trim().split(':');
                              if (startParts.length == 2 && endParts.length == 2) {
                                final now = DateTime.now();
                                final startTime = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
                                final endTime = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));
                                isOnline = now.isAfter(startTime) && now.isBefore(endTime);
                              }
                            }
                          } catch (_) {}
                        }

                        if (!isOnline) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(top: BorderSide(color: Colors.grey.shade200)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                )
                              ]
                            ),
                            child: SafeArea(
                              top: false,
                              child: Center(
                                child: Text(
                                  "Layanan chat tidak tersedia di luar jadwal",
                                  style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(top: BorderSide(color: Colors.grey.shade200)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              )
                            ]
                          ),
                          child: SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9), // Abu-abu terang untuk input
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: TextField(
                                        controller: textController,
                                        maxLines: 4,
                                        minLines: 1,
                                        textInputAction: TextInputAction.send,
                                        decoration: const InputDecoration(
                                          hintText: "Ketik pesan Anda...",
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                          hintStyle: TextStyle(fontSize: 14, color: Colors.black45),
                                        ),
                                        onSubmitted: (val) {
                                          if (val.trim().toLowerCase().contains("terima kasih") || val.trim().toLowerCase().contains("terimakasih")) {
                                            if (doc != null && doc['id'] != null && !controller.hasShownRating.value) {
                                              controller.hasShownRating.value = true;
                                              _showRatingDialog(context, doc['id']);
                                            }
                                          }
                                          controller.sendMessage(val);
                                          textController.clear();
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: () {
                                      if (textController.text.trim().isNotEmpty) {
                                        final val = textController.text;
                                        if (val.trim().toLowerCase().contains("terima kasih") || val.trim().toLowerCase().contains("terimakasih")) {
                                          if (doc != null && doc['id'] != null && !controller.hasShownRating.value) {
                                            controller.hasShownRating.value = true;
                                            _showRatingDialog(context, doc['id']);
                                          }
                                        }
                                        controller.sendMessage(val);
                                        textController.clear();
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 20,
        left: 16,
        right: 16,
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
                Icons.medical_services_rounded,
                size: 130,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Row(
            children: [
              Builder(
                builder: (context) {
                  return InkWell(
                    onTap: () => Get.back(),
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
                  );
                }
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  if (controller.selectedDoctor.value != null) {
                    final doc = controller.selectedDoctor.value!;
                    final docName = doc['name'] ?? 'Dokter';
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.DETAIL_TENAGA_KESEHATAN, arguments: doc);
                      },
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) {
                              final photoBase64 = doc['photoBase64'] ?? '';
                              return CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white24,
                                backgroundImage: photoBase64.isNotEmpty ? MemoryImage(const Base64Decoder().convert(photoBase64)) : null,
                                child: photoBase64.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                              );
                            }
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final String jadwalOnline = doc['jadwal_online'] ?? '';
                                bool isOnline = false;
                                try {
                                  final parts = jadwalOnline.split('-');
                                  if (parts.length == 2) {
                                    final startParts = parts[0].trim().split(':');
                                    final endParts = parts[1].trim().split(':');
                                    if (startParts.length == 2 && endParts.length == 2) {
                                      final now = DateTime.now();
                                      final startTime = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
                                      final endTime = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));
                                      isOnline = now.isAfter(startTime) && now.isBefore(endTime);
                                    }
                                  }
                                } catch (_) {}
                                
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      docName,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      isOnline ? 'Online' : 'Offline', 
                                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: isOnline ? Colors.white70 : Colors.red.shade200)
                                    ),
                                  ],
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),
              Obx(() {
                if (controller.selectedDoctor.value != null) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteChatDialog();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus Chat', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteChatDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(Icons.delete_sweep_rounded, size: 140, color: Colors.red.shade900),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600, size: 40),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Hapus Semua Chat?", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Apakah Anda yakin ingin menghapus seluruh riwayat chat ini? Tindakan ini tidak dapat dibatalkan.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.grey.shade300)
                            ),
                            onPressed: () => Get.back(),
                            child: const Text("Batal", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Get.back();
                              controller.deleteChat();
                            },
                            child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String? id;
  final String text;
  final bool isUser;
  final String? senderName;
  final String? senderRole;
  final DateTime time;

  const _ChatBubble({
    this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.senderName,
    this.senderRole,
  });

  void _showDeleteDialog(BuildContext context, RoomChatController controller) {
    if (id == null || id == 'system') return;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.04,
                  child: Icon(Icons.delete_sweep_rounded, size: 120, color: Colors.red.shade900),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Hapus Pesan?", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Apakah Anda yakin ingin menghapus pesan ini?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: BorderSide(color: Colors.grey.shade300)
                            ),
                            onPressed: () => Get.back(),
                            child: const Text("Batal", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Get.back();
                              if (id != null) {
                                controller.deleteSingleMessage(id!);
                              }
                            },
                            child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format waktu
    String formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    final controller = Get.find<RoomChatController>();

    return Align(
      alignment: senderRole == 'sistem' 
          ? Alignment.center 
          : (isUser ? Alignment.centerRight : Alignment.centerLeft),
      child: GestureDetector(
        onLongPress: isUser ? () => _showDeleteDialog(context, controller) : null,
        child: senderRole == 'sistem'
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text.replaceAll('---', '').trim(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          )
        : Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75, // Maksimal lebar chat 75%
          ),
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Nama pengirim untuk tenaga kesehatan
              if (!isUser && senderName != null && senderRole != 'sistem')
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                  child: Text(
                    "$senderName (${senderRole?.toUpperCase() ?? ''})",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                
              // Bubble Chat
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? const Color(0xFF2E7D32) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4), // Lebih lancip di bawah
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: isUser ? null : Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: isUser ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 10,
                            color: isUser ? Colors.white70 : Colors.grey.shade500,
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.done_all, size: 12, color: Colors.white70),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


