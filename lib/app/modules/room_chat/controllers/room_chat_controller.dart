import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class ChatMessage {
  final String? id;
  final String text;
  final bool isUser;
  final DateTime time;
  final String? senderName;
  final String? senderRole;

  ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.senderName,
    this.senderRole,
  });
}

class RoomChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final selectedDoctor = Rxn<Map<String, dynamic>>();
  final RxBool hasShownRating = false.obs;
  StreamSubscription<QuerySnapshot>? _chatSubscription;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      selectedDoctor.value = args;
      _listenToFirebaseChat();
    }
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (selectedDoctor.value != null) {
      _sendToFirebase(text);
    }
  }

  Future<void> _sendToFirebase(String text) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final userName = user?.displayName ?? 'Pasien';
    final doctorId = selectedDoctor.value?['id'] ?? '';

    if (doctorId.isEmpty) return;

    final messageData = {
      'text': text,
      'senderId': userId,
      'senderName': userName,
      'senderRole': 'pasien',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      // Simpan di sub-collection pasien
      await Get.find<AuthService>()
          .getUserReference(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('messages')
          .add(messageData);

      // Simpan di sub-collection nakes
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .add(messageData);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim pesan: $e');
    }
  }

  void _listenToFirebaseChat() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';

    if (doctorId.isEmpty) return;

    _chatSubscription?.cancel();

    final query = Get.find<AuthService>()
        .getUserReference(userId)
        .collection('chats')
        .doc(doctorId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    _chatSubscription = query.snapshots().listen((snapshot) {
      final List<ChatMessage> newMessages = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final text = data['text'] ?? '';
        final senderId = data['senderId'] ?? '';
        final isUser = senderId == userId;
        final ts = data['timestamp'] as Timestamp?;
        final time = ts?.toDate() ?? DateTime.now();
        final senderName =
            data['senderName'] ??
            (isUser
                ? 'Pasien'
                : (selectedDoctor.value?['name'] ?? 'Nakes'));
        final senderRole =
            data['senderRole'] ??
            (isUser ? 'pasien' : 'nakes');

        newMessages.add(
          ChatMessage(
            id: doc.id,
            text: text,
            isUser: isUser,
            time: time,
            senderName: senderName,
            senderRole: senderRole,
          ),
        );
      }

      final docName = selectedDoctor.value?['name'] ?? 'Dokter';
      newMessages.add(
        ChatMessage(
          id: 'system',
          text: "--- Anda terhubung dengan $docName ---",
          isUser: false,
          time: DateTime.now(),
          senderName: 'Sistem',
          senderRole: 'sistem',
        ),
      );

      messages.value = newMessages;
    });
  }

  Future<void> deleteSingleMessage(String msgId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';

    if (doctorId.isEmpty) return;

    try {
      await Get.find<AuthService>()
          .getUserReference(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('messages')
          .doc(msgId)
          .delete();
      
      Get.snackbar(
        'Sukses',
        'Pesan berhasil dihapus',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus pesan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteChat() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';

    if (doctorId.isEmpty) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final messagesRef = Get.find<AuthService>()
          .getUserReference(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('messages');

      final snapshot = await messagesRef.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      messages.clear();
      final docName = selectedDoctor.value?['name'] ?? 'Dokter';
      messages.add(
        ChatMessage(
          id: 'system',
          text: "--- Chat dengan $docName telah dihapus ---",
          isUser: false,
          time: DateTime.now(),
          senderName: 'Sistem',
          senderRole: 'sistem',
        ),
      );

      Get.snackbar(
        'Berhasil',
        'Chat berhasil dihapus',
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus chat: $e');
    }
  }

  @override
  void onClose() {
    _chatSubscription?.cancel();
    super.onClose();
  }
}


