import re

file_path = 'lib/app/modules/room_chat/views/room_chat_view.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add SwipeTo import
content = content.replace("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:swipe_to/swipe_to.dart';")

# 2. Add replyTo fields in _ChatBubble constructor
old_bubble_class = '''class _ChatBubble extends StatelessWidget {
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
  });'''
new_bubble_class = '''class _ChatBubble extends StatelessWidget {
  final String? id;
  final String text;
  final bool isUser;
  final String? senderName;
  final String? senderRole;
  final DateTime time;
  final String? note;
  final String? replyToText;
  final String? replyToSender;

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
  });'''
content = content.replace(old_bubble_class, new_bubble_class)

# 3. Add reply block UI in _ChatBubble body
old_bubble_column = '''                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('''
new_bubble_column = '''                      child: Column(
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
                          Text('''
content = content.replace(old_bubble_column, new_bubble_column)

# 4. Wrap _ChatBubble builder with SwipeTo
old_list_item = '''                            return _ChatBubble(
                              id: msg.id,
                              text: msg.text,
                              isUser: msg.isUser,
                              senderName: msg.senderName,
                              senderRole: msg.senderRole,
                              time: msg.time,
                              note: controller.notesMap[msg.id] ?? msg.note,
                            );'''
new_list_item = '''                            return SwipeTo(
                              onRightSwipe: (details) {
                                controller.setReplyMessage(msg);
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
                              ),
                            );'''
content = content.replace(old_list_item, new_list_item)

# 5. Add reply preview above TextField
old_form = '''                    // Form Input (Selalu Tampil)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),'''
new_form = '''                    // Form Input (Selalu Tampil)
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
                      ),'''
content = content.replace(old_form, new_form)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
