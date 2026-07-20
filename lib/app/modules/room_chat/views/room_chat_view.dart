import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/room_chat_controller.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../../widgets/custom_popup.dart';

class RoomChatView extends GetView<RoomChatController> {
  const RoomChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFC,
      ), // Warna background modern yang sangat soft
      body: Column(
        children: [
          _buildCustomHeader(context),
          Expanded(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.04,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final elements = [
                          Icons.medical_services_rounded,
                          Icons.health_and_safety_rounded,
                          Icons.healing_rounded,
                          "Pasien",
                          Icons.local_hospital_rounded,
                          Icons.favorite_rounded,
                          "Nakes",
                          Icons.medication_rounded,
                          Icons.coronavirus_rounded,
                          Icons.monitor_heart_rounded,
                        ];
                        final element = elements[index % elements.length];
                        
                        if (element is String) {
                          return Center(
                            child: Text(
                              element,
                              style: const TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        
                        return Center(
                          child: Icon(
                            element as IconData,
                            size: 16,
                            color: const Color(0xFF1B5E20),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: Obx(
                        () => ListView.builder(
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
                        ),
                      ),
                    ),
                    Obx(() {
                      if (controller.partnerIsTyping.value) {
                        return _buildTypingBubble();
                      }
                      return const SizedBox.shrink();
                    }),
                    Obx(() {
                      bool isOnline = controller.isWithinSchedule.value;
                      if (!isOnline) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border(top: BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: SafeArea(
                              top: false,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.access_time_rounded, color: Colors.grey.shade500, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Di luar jadwal praktik. Chat tidak tersedia.",
                                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Container(
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
                                        onChanged: controller.onTextChanged,
                                        maxLines: 4,
                                        minLines: 1,
                                        textInputAction: TextInputAction.send,
                                        decoration: const InputDecoration(
                                          hintText: "Ketik pesan Anda...",
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
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
                                      if (textController.text
                                          .trim()
                                          .isNotEmpty) {
                                        final val = textController.text;
                                        controller.sendMessage(val);
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
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  if (controller.selectedDoctor.value != null) {
                    final doc = controller.selectedDoctor.value!;
                    final docName = doc['name'] ?? 'Dokter';
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          Routes.DETAIL_TENAGA_KESEHATAN,
                          arguments: doc,
                        );
                      },
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) {
                              final photoBase64 = doc['photoBase64'] ?? '';
                              return CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white24,
                                backgroundImage: photoBase64.isNotEmpty
                                    ? MemoryImage(
                                        const Base64Decoder().convert(
                                          photoBase64,
                                        ),
                                      )
                                    : null,
                                child: photoBase64.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 24,
                                      )
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  docName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                  Obx(() {
                                    bool isOnline = controller.isWithinSchedule.value;
                                    
                                    String statusText = isOnline ? 'Online' : 'Offline';
                                    
                                    return Text(
                                      statusText,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: isOnline
                                            ? Colors.white70
                                            : Colors.red.shade200,
                                      ),
                                    );
                                  }),
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
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      CustomPopup.showConfirm(
                        title: 'Hapus Semua Chat?',
                        message:
                            'Apakah Anda yakin ingin menghapus seluruh riwayat chat ini? Tindakan ini tidak dapat dibatalkan.',
                        onConfirm: () {
                          controller.deleteChat();
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
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Sedang mengetik...",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
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
                  child: Icon(
                    Icons.delete_sweep_rounded,
                    size: 120,
                    color: Colors.red.shade900,
                  ),
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
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade600,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Hapus Pesan?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            onPressed: () => Get.back(),
                            child: const Text(
                              "Batal",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Get.back();
                              if (id != null) {
                                controller.deleteSingleMessage(id!);
                              }
                            },
                            child: const Text(
                              "Hapus",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format waktu
    String formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    final controller = Get.find<RoomChatController>();

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
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
                          senderName ?? '',
                          style: TextStyle(
                            fontSize: 14,
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
                              color: isUser
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
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
                                  color: isUser
                                      ? Colors.white70
                                      : Colors.grey.shade500,
                                ),
                              ),
                              if (isUser) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.done_all,
                                  size: 12,
                                  color: Colors.white70,
                                ),
                              ],
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
