import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
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
                          "Dokter",
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
                      child: Obx(() {
                        // Memaksa Obx untuk melacak semua perubahan pada notesMap
                        final _ = controller.notesMap.values.toList();
                        final _2 = controller.messages.length;
                        
                        return ListView.builder(
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
                              note: controller.notesMap[msg.id] ?? msg.note,
                            );
                          },
                        );
                      }),
                    ),
                    Obx(() {
                      if (controller.partnerIsTyping.value) {
                        return _buildTypingBubble();
                      }
                      return const SizedBox.shrink();
                    }),
                    // Form Input (Selalu Tampil)
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
                              IconButton(
                                icon: const Icon(Icons.history_rounded, color: Color(0xFF2E7D32)),
                                tooltip: 'Bagikan Riwayat',
                                onPressed: () {
                                  controller.showHistoryModal();
                                },
                              ),
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
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
                          Routes.DETAIL_DOKTER,
                          arguments: doc,
                        );
                      },
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) {
                              final photoBase64 = doc['photo64'] ?? doc['photoBase64'] ?? '';
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
                                    bool isOnline = controller.partnerIsOnline.value;
                                    if (isOnline) {
                                      return const Text(
                                        'Online',
                                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white70),
                                      );
                                    }
                                    
                                    final lastSeen = controller.partnerLastSeen.value;
                                    String statusText = 'Terakhir online: belum diketahui';
                                    if (lastSeen != null) {                                      final timeStr = "${lastSeen.hour.toString().padLeft(2, '0')}:${lastSeen.minute.toString().padLeft(2, '0')}";

                                      if (DateTime.now().day == lastSeen.day && DateTime.now().month == lastSeen.month && DateTime.now().year == lastSeen.year) {
                                        statusText = 'Terakhir dilihat hari ini pukul $timeStr';
                                      } else {
                                        String hari = '';
                                        switch (lastSeen.weekday) {
                                          case 1: hari = 'Senin'; break;
                                          case 2: hari = 'Selasa'; break;
                                          case 3: hari = 'Rabu'; break;
                                          case 4: hari = 'Kamis'; break;
                                          case 5: hari = 'Jumat'; break;
                                          case 6: hari = 'Sabtu'; break;
                                          case 7: hari = 'Minggu'; break;
                                        }
                                        statusText = 'Terakhir dilihat hari $hari, ${lastSeen.day}/${lastSeen.month}/${lastSeen.year} pukul $timeStr';
                                      }
                                    }
                                    
                                    return Text(
                                      statusText,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Colors.white70,
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
                if (controller.remainingSeconds.value > 0 && controller.remainingSeconds.value < 300) {
                  final minutes = (controller.remainingSeconds.value / 60).floor();
                  final seconds = controller.remainingSeconds.value % 60;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$minutes:${seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
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
  final String? note;

  const _ChatBubble({
    this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.senderName,
    this.senderRole,
    this.note,
  });



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
                          bottomLeft: Radius.circular(isUser ? 20 : 4),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
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
                          ),
                          if (text.startsWith('Laporan Riwayat Natrium')) ...[
                            const SizedBox(height: 8),
                            _ReportNoteBox(
                              messageId: id,
                              initialNote: note,
                              isUser: isUser,
                            ),
                          ],
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

class _ReportNoteBox extends StatelessWidget {
  final String? messageId;
  final String? initialNote;
  final bool isUser;

  const _ReportNoteBox({
    this.messageId,
    this.initialNote,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    if (messageId == null) return const SizedBox.shrink();

    final bool isEmpty = initialNote == null || initialNote!.trim().isEmpty;
    
    if (isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: const Text('Belum ada catatan dari dokter', style: TextStyle(color: Colors.grey, fontSize: 12)),
      );
    }

    return GestureDetector(
      onTap: () => _showNoteViewDialog(context, initialNote!),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: const Text('Lihat Catatan Dokter', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}

void _showNoteViewDialog(BuildContext context, String note) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Watermark Icon
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.note_alt,
                  size: 150,
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
              Positioned(
                right: -10,
                top: -10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Catatan Dokter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade100.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow.shade400),
                    ),
                    child: Text(
                      note,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

