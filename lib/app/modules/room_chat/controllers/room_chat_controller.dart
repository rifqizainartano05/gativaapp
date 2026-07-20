import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/custom_popup.dart';

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
  StreamSubscription<DocumentSnapshot>? _typingSubscription;
  final RxBool partnerIsTyping = false.obs;
  final RxBool isWithinSchedule = false.obs;
  Timer? _typingTimer;
  Timer? _scheduleTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      selectedDoctor.value = args;
      _checkSchedule();
      _listenToFirebaseChat();
      _listenToPartnerTyping();
      
      _scheduleTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _checkSchedule();
      });
    }
  }

  void _checkSchedule() {
    final doc = selectedDoctor.value;
    if (doc == null) return;
    
    final jadwalOnline = doc['jadwal_online']?.toString() ?? '';
    if (jadwalOnline.isEmpty) {
      isWithinSchedule.value = false;
      return;
    }
    
    try {
      final parts = jadwalOnline.split('-');
      if (parts.length == 2) {
        final startParts = parts[0].trim().split(':');
        final endParts = parts[1].trim().split(':');
        if (startParts.length == 2 && endParts.length == 2) {
          final now = DateTime.now();
          final startTime = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
          final endTime = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));
          isWithinSchedule.value = now.isAfter(startTime) && now.isBefore(endTime);
          return;
        }
      }
    } catch (_) {}
    isWithinSchedule.value = false;
  }

  @override
  void onClose() {
    _chatSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    _scheduleTimer?.cancel();
    _updateTypingStatus(false);
    super.onClose();
  }

  void onTextChanged(String text) {
    if (text.isNotEmpty) {
      _updateTypingStatus(true);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _updateTypingStatus(false);
      });
    } else {
      _updateTypingStatus(false);
      _typingTimer?.cancel();
    }
  }

  Future<void> _updateTypingStatus(bool isTyping) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';
    if (doctorId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .set({'isTyping': isTyping}, SetOptions(merge: true));
    } catch (e) {
      // ignore
    }
  }

  void _listenToPartnerTyping() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';
    if (doctorId.isEmpty) return;

    _typingSubscription?.cancel();
    _typingSubscription = Get.find<AuthService>()
        .getUserReference(userId)
        .collection('chats')
        .doc(doctorId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        partnerIsTyping.value = data['isTyping'] ?? false;
      }
    });
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (selectedDoctor.value != null) {
      // Optimistic update
      final user = FirebaseAuth.instance.currentUser;
      final userName = user?.displayName ?? 'Pasien';
      final msg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // temporary ID
        text: text,
        isUser: true,
        time: DateTime.now(),
        senderName: userName,
        senderRole: 'pasien',
      );
      messages.insert(0, msg);

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
      CustomPopup.showError('Error', 'Gagal mengirim pesan: $e');
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
      // Hapus sisi pasien
      await Get.find<AuthService>()
          .getUserReference(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('messages')
          .doc(msgId)
          .delete();
          
      // Hapus sisi nakes
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .doc(msgId)
          .delete();
      
      CustomPopup.showSuccess(
        'Sukses',
        'Pesan berhasil dihapus',
      );
    } catch (e) {
      CustomPopup.showError(
        'Error',
        'Gagal menghapus pesan: $e',
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
          
      final nakesMessagesRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('messages');

      final snapshot = await messagesRef.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
        batch.delete(nakesMessagesRef.doc(doc.id));
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

      CustomPopup.showSuccess(
        'Berhasil',
        'Chat berhasil dihapus',
      );
    } catch (e) {
      CustomPopup.showError('Error', 'Gagal menghapus chat: $e');
    }
  }

}


