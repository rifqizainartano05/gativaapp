import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna background modern yang sangat soft
      appBar: AppBar(
        title: Obx(() {
          if (controller.selectedDoctor.value != null) {
            final doc = controller.selectedDoctor.value!;
            final docName = doc['username'] ?? 'Dokter';
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        docName, 
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text('Online', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.support_agent_rounded, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text('Pilih Konsultan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.5)),
            ],
          );
        }),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20), // Hijau elegan
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        leading: Obx(() {
          if (controller.selectedDoctor.value != null) {
            return IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                controller.exitChat();
              },
            );
          }
          return IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Get.back(),
          );
        }),
      ),
      body: Obx(() {
        if (controller.selectedDoctor.value == null) {
          // TAMPILAN DAFTAR DOKTER (List Mode)
          return _buildDoctorList();
        } else {
          // TAMPILAN RUANG OBROLAN (Chat Mode)
          return Stack(
            children: [
              // Watermark Background
              Positioned.fill(
                child: Opacity(
                  opacity: 0.04,
                  child: Icon(
                    Icons.medical_services_rounded, // Watermark Icon yang lebih bagus
                    size: 250,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true, // Auto-scroll ke bawah
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final msg = controller.messages[index];
                        return _ChatBubble(
                          text: msg.text,
                          isUser: msg.isUser,
                          senderName: msg.senderName,
                          senderRole: msg.senderRole,
                          time: msg.time,
                        );
                      },
                    ),
                  ),
                  // Input Area
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                decoration: const InputDecoration(
                                  hintText: "Ketik pesan Anda...",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 14, color: Colors.black45),
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
                                controller.sendMessage(textController.text);
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
                              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      }),
    );
  }

  Widget _buildDoctorList() {
    if (controller.isLoadingDoctors.value) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
    }

    if (controller.doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Belum ada konsultan yang tersedia",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.doctors.length,
      itemBuilder: (context, index) {
        final doc = controller.doctors[index];
        final name = doc['username'] ?? 'Konsultan';
        final int antreanCount = int.tryParse(doc['antrean']?.toString() ?? '0') ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => controller.openChatWithDoctor(doc),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_information_rounded,
                        color: Color(0xFF2E7D32),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Flexible(
                                child: Text(
                                  "Tersedia untuk chat",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (antreanCount > 0) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.people_alt_rounded, size: 14, color: Colors.orange.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Antrean: $antreanCount",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String? senderName;
  final String? senderRole;
  final DateTime time;

  const _ChatBubble({
    required this.text,
    required this.isUser,
    required this.time,
    this.senderName,
    this.senderRole,
  });

  @override
  Widget build(BuildContext context) {
    // Format waktu
    String formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75, // Maksimal lebar chat 75%
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Nama pengirim untuk dokter
            if (!isUser && senderName != null && senderRole != 'sistem')
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  "$senderName (${senderRole!.toUpperCase()})",
                  style: TextStyle(
                    fontSize: 12,
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
    );
  }
}
