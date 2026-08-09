import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/custom_popup.dart';

class ChatMessage {
  final String? id;
  final String text;
  final bool isUser;
  final DateTime time;
  final String? senderName;
  final String? senderRole;
  final String? note;

  ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.senderName,
    this.senderRole,
    this.note,
  });
}

class RoomDokterChatController extends GetxController {
  final messages = <ChatMessage>[].obs; // Menyimpan catatan dari sub-collection 'catatan'
  
  // Live Chat Data
  final selectedDoctor = Rxn<Map<String, dynamic>>();
  final RxBool partnerIsOnline = false.obs;
  final Rx<DateTime?> partnerLastSeen = Rx<DateTime?>(null);
  StreamSubscription? _chatSubscription;
  StreamSubscription? _notesSubscription;

  final notesMap = <String, String>{}.obs;
  StreamSubscription<DocumentSnapshot>? _presenceSubscription;
  StreamSubscription<DocumentSnapshot>? _typingSubscription;
  StreamSubscription<DocumentSnapshot>? _myProfileSubscription;
  StreamSubscription<DocumentSnapshot>? _patientProfileSubscription;
  final RxBool partnerIsTyping = false.obs;
  final RxBool isWithinSchedule = true.obs;
  Timer? _typingTimer;
  Timer? _scheduleTimer;
  String _jadwalOnline = '';

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      selectedDoctor.value = Get.arguments as Map<String, dynamic>;
      _listenToNotes();
      _listenToFirebaseChat();
      _listenToPartnerPresence();
      _listenToPartnerTyping();
      _listenToMyProfile();
      
      _scheduleTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _checkSchedule();
      });
    }
  }

  @override
  void onClose() {
    _chatSubscription?.cancel();
    _notesSubscription?.cancel();
    _presenceSubscription?.cancel();
    _typingSubscription?.cancel();
    _myProfileSubscription?.cancel();
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
          .collection('pasien')
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

  void _listenToPartnerPresence() {
    final pasienId = selectedDoctor.value?['id'] ?? '';
    if (pasienId.isEmpty) return;

    _presenceSubscription?.cancel();
    _presenceSubscription = FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('pasien')
        .doc(pasienId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        partnerIsOnline.value = snapshot.data()?['isOnline'] ?? false;
        
        final lastSeenData = snapshot.data()?['lastSeen'];
        if (lastSeenData != null) {
          if (lastSeenData is Timestamp) {
            partnerLastSeen.value = lastSeenData.toDate();
          }
        } else {
          partnerLastSeen.value = null;
        }
      }
    });
  }

  void _listenToMyProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _myProfileSubscription?.cancel();
    _myProfileSubscription = FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('dokter')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _jadwalOnline = snapshot.data()?['jadwal_online'] ?? '';
        _checkSchedule();
      }
    });
  }

  void _checkSchedule() {
    if (_jadwalOnline.isEmpty) {
      isWithinSchedule.value = false;
      return;
    }
    try {
      final parts = _jadwalOnline.split('-');
      if (parts.length == 2) {
        final startParts = parts[0].trim().split(':');
        final endParts = parts[1].trim().split(':');
        if (startParts.length == 2 && endParts.length == 2) {
          final now = DateTime.now();
          final startTime = DateTime(now.year, now.month, now.day,
              int.parse(startParts[0]), int.parse(startParts[1]));
          final endTime = DateTime(now.year, now.month, now.day,
              int.parse(endParts[0]), int.parse(endParts[1]));
          isWithinSchedule.value = now.isAfter(startTime) && now.isBefore(endTime);
          return;
        }
      }
    } catch (_) {}
    isWithinSchedule.value = false;
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (selectedDoctor.value != null) {

      if (text.toLowerCase().contains('terima kasih')) {
        _sendToFirebase(text);
        exitChat();
        return;
      }
      _sendToFirebase(text);
    }
  }

  void exitChat() {
    _chatSubscription?.cancel();
    _notesSubscription?.cancel();
    Get.back();
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
      'senderRole': 'dokter',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Referensi dokumen chat parent
      final doctorChatRef = Get.find<AuthService>()
          .getUserReference(userId)
          .collection('chats')
          .doc(doctorId);
          
      final patientChatRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(doctorId)
          .collection('chats')
          .doc(userId);

      // Pastikan parent document ada dan terupdate
      batch.set(doctorChatRef, {
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      batch.set(patientChatRef, {
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Generate a single ID for the message so it's identical on both sides
      final messageId = doctorChatRef.collection('messages').doc().id;

      // Tambahkan pesan ke sub-collection menggunakan ID yang sama
      final doctorMsgRef = doctorChatRef.collection('messages').doc(messageId);
      batch.set(doctorMsgRef, messageData);

      final patientMsgRef = patientChatRef.collection('messages').doc(messageId);
      batch.set(patientMsgRef, messageData);

      await batch.commit();
    } catch (e) {
      CustomPopup.showError('Error', 'Gagal mengirim pesan: $e');
    }
  }

  Future<void> saveNoteToMessage(String messageId, String note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final userId = user.uid;
    final doctorId = selectedDoctor.value?['id'] ?? '';
    if (doctorId.isEmpty) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      final doctorNoteRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('dokter')
          .doc(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('catatan') // New subcollection
          .doc(messageId);
          
      final patientNoteRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('catatan') // New subcollection
          .doc(messageId);

      try {
        batch.set(doctorNoteRef, {'note': note}, SetOptions(merge: true));
        batch.set(patientNoteRef, {'note': note}, SetOptions(merge: true));
        await batch.commit();
      } catch (e) {
        print('Error updating note in new subcollection: $e');
      }
    } catch (e) {
      print('Error saving note to subcollection: $e');
    }
  }

  void _listenToNotes() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';

    if (doctorId.isEmpty) return;

    final notesRef = FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('dokter')
        .doc(userId)
        .collection('chats')
        .doc(doctorId)
        .collection('catatan');

    _notesSubscription = notesRef.snapshots().listen((snapshot) {
      final newNotesMap = <String, String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('note') && data['note'] != null) {
          newNotesMap[doc.id] = data['note'] as String;
        }
      }
      notesMap.assignAll(newNotesMap);
    }, onError: (error) {
      print('Error listening to notes: $error');
    });
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
        final isUser = data['senderId'] == userId;
        final ts = data['timestamp'] as Timestamp?;
        final time = ts?.toDate() ?? DateTime.now();
        final senderRole = data['senderRole'] as String?;
        final note = data['note'] as String?;

        newMessages.add(
          ChatMessage(
            id: doc.id,
            text: text,
            isUser: isUser,
            time: time,
            senderName: data['senderName'],
            senderRole: senderRole,
            note: note,
          ),
        );
      }

      // Tambahkan pesan sistem di bagian paling bawah (index paling akhir karena reverse list)
      final docName = selectedDoctor.value?['name'] ?? 'Pasien';
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
      // Hapus dari sisi Dokter
      await Get.find<AuthService>()
          .getUserReference(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('messages')
          .doc(msgId)
          .delete();
          
      // Hapus dari sisi Pasien
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
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

  Future<void> clearChatHistory() async {
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
          
      final pasienMessagesRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('messages');

      final snapshot = await messagesRef.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
        batch.delete(pasienMessagesRef.doc(doc.id));
      }
      await batch.commit();

      messages.clear();
      final docName = selectedDoctor.value?['name'] ?? 'Pasien';
      messages.insert(
        0,
        ChatMessage(
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
