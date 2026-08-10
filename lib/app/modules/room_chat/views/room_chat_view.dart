import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../../routes/app_pages.dart';
import '../controllers/room_chat_controller.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../../widgets/custom_popup.dart';

class RoomChatView extends GetView<RoomChatController> {
  const RoomChatView({super.key});

  @override
  Widget build(BuildContext context) {
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
                    Obx(() {
                      if (controller.countdownSeconds.value > 0) {
                        final minutes = (controller.countdownSeconds.value / 60).floor();
                        final seconds = controller.countdownSeconds.value % 60;
                        final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: Colors.red.shade50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.timer, color: Colors.red.shade700, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Chat akan dihapus dalam $timeString',
                                style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    Expanded(
                      child: Obx(() {
                        // Memaksa Obx untuk melacak semua perubahan pada notesMap
                        final _ = controller.notesMap.values.toList();
                        final _2 = controller.messages.length;
                        final _3 = controller.selectedMessageIds.toList();
                        
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
                            final isSelected = controller.selectedMessageIds.contains(msg.id);
                            
                            return GestureDetector(
                              onLongPress: () {
                                if (msg.id != null) {
                                  controller.toggleSelection(msg.id!);
                                }
                              },
                              onTap: () {
                                if (controller.isSelectionMode && msg.id != null) {
                                  controller.toggleSelection(msg.id!);
                                }
                              },
                              child: SwipeTo(
                                onRightSwipe: (details) {
                                  if (!controller.isSelectionMode) {
                                    controller.setReplyMessage(msg);
                                  }
                                },
                                child: _ChatBubble(
                                  id: msg.id,
                                  text: msg.text,
                                  isUser: msg.isUser,
                                  senderName: msg.senderName,
                                  senderRole: msg.senderRole,
                                  time: msg.time,
                                  note: controller.notesMap[msg.id] ?? msg.note,
                                  replyToText: msg.replyToText,
                                  replyToSender: msg.replyToSender,
                                  isSelected: isSelected,
                                ),
                              ),
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
                    Obx(() {
                      if (controller.replyingToMessage.value != null) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.replyingToMessage.value!.senderName ?? 'Sistem',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 12),
                                    ),
                                    Text(
                                      controller.replyingToMessage.value!.text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => controller.cancelReply(),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
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
                                    controller: controller.textController,
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
                                      controller.textController.clear();
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Obx(() {
                                final isListening = controller.isListening.value;
                                return InkWell(
                                  onTap: () {
                                    if (isListening) {
                                      controller.stopListening();
                                    } else {
                                      controller.listenToSpeech();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isListening ? Colors.red.shade100 : Colors.blue.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isListening ? Icons.mic : Icons.mic_none,
                                      color: isListening ? Colors.red : Colors.blue,
                                      size: 24,
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  if (controller.textController.text
                                      .trim()
                                      .isNotEmpty) {
                                    final val = controller.textController.text;
                                    controller.sendMessage(val);
                                    controller.textController.clear();
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
          Obx(() {
            if (controller.isSelectionMode) {
              return Row(
                children: [
                  InkWell(
                    onTap: () => controller.clearSelection(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${controller.selectedMessageIds.length} dipilih',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: () {
                      CustomPopup.showConfirm(
                        title: 'Hapus Pesan',
                        message: 'Apakah Anda yakin ingin menghapus ${controller.selectedMessageIds.length} pesan ini?',
                        onConfirm: () {
                          controller.deleteSelectedMessages();
                        },
                      );
                    },
                  ),
                ],
              );
            }
            return Row(
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

                                        if (DateTime.now().day == lastSeen.day &&
                                            DateTime.now().month == lastSeen.month &&
                                            DateTime.now().year == lastSeen.year) {
                                          statusText = 'Terakhir dilihat pada pukul $timeStr';
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
                                          statusText = 'Terakhir dilihat pada hari $hari';
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
            );
          }),
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
  final String? replyToText;
  final String? replyToSender;

  final bool isSelected;

  const _ChatBubble({
    this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.senderName,
    this.senderRole,
    this.note,
    this.replyToText,
    this.replyToSender,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // Format waktu
    String formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    final controller = Get.find<RoomChatController>();

    return Container(
      color: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (controller.isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.green : Colors.grey,
                  size: 24,
                ),
              ),
            Expanded(
              child: Align(
                alignment: senderRole == 'sistem'
                    ? Alignment.center
                    : (isUser ? Alignment.centerRight : Alignment.centerLeft),
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
                                color: isSelected 
                                    ? (isUser ? const Color(0xFF1B5E20) : Colors.green.shade50)
                                    : (isUser ? const Color(0xFF2E7D32) : Colors.white),
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
                                    ? (isSelected ? Border.all(color: Colors.white, width: 2) : null)
                                    : Border.all(color: isSelected ? Colors.green.shade300 : Colors.grey.shade200, width: isSelected ? 2 : 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (replyToText != null)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isUser ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border(
                                          left: BorderSide(
                                            color: isUser ? Colors.white : const Color(0xFF2E7D32),
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            replyToSender ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: isUser ? Colors.white : const Color(0xFF2E7D32),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            replyToText!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isUser ? Colors.white70 : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Text(
                                    text,
                                    style: TextStyle(
                                      color: isUser ? Colors.white : const Color(0xFF1E293B),
                                      fontSize: 14.5,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (text.startsWith('Laporan Riwayat Natrium')) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isUser ? Colors.white.withValues(alpha: 0.2) : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.info_outline, size: 12, color: isUser ? Colors.white : Colors.green.shade800),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Membalas terkait laporan ini akan otomatis masuk ke Catatan Dokter.',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontStyle: FontStyle.italic,
                                                color: isUser ? Colors.white70 : Colors.green.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

