import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/room_nakes_chat_controller.dart';
import '../../../widgets/custom_popup.dart';

class RoomNakesChatView extends GetView<RoomNakesChatController> {
  const RoomNakesChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Custom Header
          Container(
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
                  top: -10,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 130,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
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
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() {
                        if (controller.selectedDoctor.value != null) {
                          final doc = controller.selectedDoctor.value!;
                          final docName = doc['name'] ?? 'Pasien';
                          return GestureDetector(
                            onTap: () {
                              final args = Map<String, dynamic>.from(doc);
                              args['readOnly'] = true; // Still pass readOnly just in case
                              Get.toNamed(
                                Routes.NAKES_DETAIL_PASIEN_CHAT,
                                arguments: args,
                              );
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: [
                                doc['strImageBase64'] != null && doc['strImageBase64'].toString().isNotEmpty
                                    ? CircleAvatar(
                                        radius: 20,
                                        backgroundImage: MemoryImage(base64Decode(doc['strImageBase64'])),
                                      )
                                    : const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 20,
                                        child: Icon(
                                          Icons.person,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        docName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Text(
                                        'Online',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
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
                        return IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                          onPressed: () {
                            CustomPopup.showConfirm(
                              title: 'Hapus Semua Chat?',
                              message: 'Apakah Anda yakin ingin menghapus seluruh riwayat chat ini? Tindakan ini tidak dapat dibatalkan.',
                              onConfirm: () {
                                controller.clearChatHistory();
                              },
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Watermark Background
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.04,
                    child: Icon(
                      Icons
                          .medical_services_rounded, // Watermark Icon yang lebih bagus
                      size: 250,
                      color: Colors.green.shade900,
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
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 8,
                          ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFF1F5F9,
                                  ), // Abu-abu terang untuk input
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: TextField(
                                  controller: textController,
                                  maxLines: 4,
                                  minLines: 1,
                                  textInputAction: TextInputAction.send,
                                  decoration: const InputDecoration(
                                    hintText: "Ketik pesan...",
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  onSubmitted: (val) {
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
                                  controller.sendMessage(
                                    textController.text,
                                  );
                                  textController.clear();
                                }
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF2E7D32),
                                      Color(0xFF1B5E20),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            ],
                          ),
                        ),
                      ),
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

  void _showDeleteDialog(BuildContext context, RoomNakesChatController controller) {
    if (id == null || id == 'system') return;

    CustomPopup.showConfirm(
      title: 'Hapus Pesan?',
      message: 'Apakah Anda yakin ingin menghapus pesan ini?',
      onConfirm: () {
        controller.deleteSingleMessage(id!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format waktu
    String formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    final controller = Get.find<RoomNakesChatController>();

    return Align(
      alignment: senderRole == 'sistem' 
          ? Alignment.center 
          : (isUser ? Alignment.centerRight : Alignment.centerLeft),
      child: GestureDetector(
        onLongPress: isUser
            ? () => _showDeleteDialog(context, controller)
            : null,
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
            maxWidth:
                MediaQuery.of(context).size.width *
                0.75, // Maksimal lebar chat 75%
          ),
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Nama pengirim untuk tenaga kesehatan
              if (!isUser && senderName != null && senderRole != 'sistem')
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                  child: Text(
                    "$senderName (${senderRole?.toUpperCase() ?? ''})",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

              // Bubble Chat
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isUser ? const Color(0xFF2E7D32) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(
                      isUser ? 20 : 4,
                    ), // Lebih lancip di bawah
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: isUser
                      ? null
                      : Border.all(color: Colors.grey.shade200),
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
                          const Icon(
                            Icons.done_all,
                            size: 12,
                            color: Colors.white70,
                          ),
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

