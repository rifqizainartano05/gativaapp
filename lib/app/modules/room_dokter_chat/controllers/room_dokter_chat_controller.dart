import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  final String? replyToText;
  final String? replyToSender;

  ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.senderName,
    this.senderRole,
    this.note,
    this.replyToText,
    this.replyToSender,
  });
}

class RoomDokterChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final Rx<ChatMessage?> replyingToMessage = Rx<ChatMessage?>(null);

  void setReplyMessage(ChatMessage msg) {
    replyingToMessage.value = msg;
  }

  void cancelReply() {
    replyingToMessage.value = null;
  }

  // Multi-select Delete
  final selectedMessageIds = <String>{}.obs;
  bool get isSelectionMode => selectedMessageIds.isNotEmpty;

  void toggleSelection(String id) {
    if (id == 'system') return; // Jangan izinkan pilih pesan sistem
    if (selectedMessageIds.contains(id)) {
      selectedMessageIds.remove(id);
    } else {
      selectedMessageIds.add(id);
    }
  }

  void clearSelection() {
    selectedMessageIds.clear();
  }

  Future<void> deleteSelectedMessages() async {
    if (selectedMessageIds.isEmpty) return;
    final doctorId = selectedDoctor.value?['id']; // This is actually the patient's ID
    if (doctorId == null) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final chatRef = Get.find<AuthService>().getUserReference(userId).collection('chats').doc(doctorId).collection('messages');
      
      final patientMessagesRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('messages');

      final doctorCatatanRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('dokter')
          .doc(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('catatan');

      final patientCatatanRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('catatan');
      
      for (final id in selectedMessageIds) {
        final msg = messages.firstWhereOrNull((m) => m.id == id);
        batch.delete(chatRef.doc(id));
        batch.delete(patientMessagesRef.doc(id));
        batch.delete(doctorCatatanRef.doc(id));
        batch.delete(patientCatatanRef.doc(id));
        
        if (msg != null) {
          // Cari juga di koleksi pasien berdasarkan teks (untuk pesan lama yang ID-nya mungkin berbeda)
          try {
            final querySnapshot = await patientMessagesRef
                .where('text', isEqualTo: msg.text)
                .where('senderId', isEqualTo: userId)
                .get();
            for (var doc in querySnapshot.docs) {
              batch.delete(doc.reference);
              // Hapus juga catatan yang terkait dengan document ID lama tersebut
              batch.delete(patientCatatanRef.doc(doc.id));
              batch.delete(doctorCatatanRef.doc(doc.id));
            }
          } catch (e) {
            print('Error querying old messages: $e');
          }
        }
      }
      
      await batch.commit();
      clearSelection();
    } catch (e) {
      print('Error deleting messages: $e');
    }
  }
  
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
  Timer? _countdownTimer;
  final RxInt countdownSeconds = 0.obs;
  String _jadwalOnline = '';

  // Controller Text dan Speech-to-Text
  final TextEditingController textController = TextEditingController();
  final stt.SpeechToText speechToText = stt.SpeechToText();
  final RxBool isListening = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
    if (Get.arguments != null) {
      selectedDoctor.value = Get.arguments as Map<String, dynamic>;
      _listenToFirebaseChat();
      _listenToPartnerPresence();
      _listenToPartnerTyping();
      _listenToMyProfile();
      
      _scheduleTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _checkSchedule();
      });
    }
  }

  Future<void> _initSpeech() async {
    try {
      bool available = await speechToText.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (errorNotification) {
          isListening.value = false;
          print('Speech recognition error: $errorNotification');
        },
      );
      if (!available) {
        print("Perekam suara tidak tersedia di perangkat ini.");
      }
    } catch (e) {
      print("Error inisialisasi speech to text: $e");
    }
  }

  void listenToSpeech() async {
    if (!isListening.value) {
      bool available = await speechToText.initialize();
      if (available) {
        isListening.value = true;
        // Simpan isi text saat ini agar tidak tertimpa
        final currentText = textController.text;
        final prefix = currentText.isNotEmpty && !currentText.endsWith(' ') ? '$currentText ' : currentText;
        
        speechToText.listen(
          onResult: (result) {
            textController.text = prefix + result.recognizedWords;
            textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length));
          },
          localeId: 'id_ID', // Memaksa bahasa Indonesia
        );
      } else {
        isListening.value = false;
        CustomPopup.showError('Error', 'Izin mikrofon ditolak atau tidak tersedia.');
      }
    }
  }

  void stopListening() {
    if (isListening.value) {
      speechToText.stop();
      isListening.value = false;
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
    _countdownTimer?.cancel();
    _updateTypingStatus(false);
    textController.dispose();
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
    _typingSubscription = FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('pasien')
        .doc(doctorId)
        .collection('chats')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        partnerIsTyping.value = data['isTyping'] ?? false;
        
        // Cek deleteAt di document chat yang ada di collection dokter (karena patient nulis deleteAt disana juga, tapi kita dengerin chat pasien? 
        // Wait, patient menulis deleteAt di dua document. Kita cek saja di document pasien.
        if (data['deleteAt'] != null) {
          final deleteAt = (data['deleteAt'] as Timestamp).toDate();
          _startLocalCountdown(deleteAt);
        } else {
          _stopLocalCountdown();
        }
      }
    });
  }

  void _startLocalCountdown(DateTime deleteAt) {
    _countdownTimer?.cancel();
    _updateCountdown(deleteAt);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown(deleteAt);
    });
  }

  void _updateCountdown(DateTime deleteAt) {
    final now = DateTime.now();
    if (now.isAfter(deleteAt) || now.isAtSameMomentAs(deleteAt)) {
      _stopLocalCountdown();
      _deleteAllMessages();
    } else {
      countdownSeconds.value = deleteAt.difference(now).inSeconds;
    }
  }

  void _stopLocalCountdown() {
    _countdownTimer?.cancel();
    countdownSeconds.value = 0;
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

    if (countdownSeconds.value > 0) {
      await _cancelGlobalAutoDeleteTimer();
    }

    if (selectedDoctor.value != null) {
      await _sendToFirebase(text);
      cancelReply();
      _checkTerimaKasih(text);
    }
  }

  void _checkTerimaKasih(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('terima kasih') || lowerText.contains('makasih') || lowerText.contains('terimakasih')) {
      _showAutoDeletePopup();
      Future.delayed(const Duration(seconds: 1), () {
        _sendSystemReply('Sama-sama. Percakapan ini akan dihapus secara otomatis dalam 2 menit.');
      });
      _startGlobalAutoDeleteTimer();
    }
  }

  Future<void> _startGlobalAutoDeleteTimer() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';
    if (doctorId.isEmpty) return;
    
    final deleteAtTime = DateTime.now().add(const Duration(minutes: 2));
    
    try {
      final batch = FirebaseFirestore.instance.batch();
      final doctorChatRef = Get.find<AuthService>().getUserReference(userId).collection('chats').doc(doctorId);
      final patientChatRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('pasien').doc(doctorId).collection('chats').doc(userId);
      
      batch.set(doctorChatRef, {'deleteAt': Timestamp.fromDate(deleteAtTime)}, SetOptions(merge: true));
      batch.set(patientChatRef, {'deleteAt': Timestamp.fromDate(deleteAtTime)}, SetOptions(merge: true));
      await batch.commit();
    } catch (e) {
      print('Error setting delete timer: $e');
    }
  }

  Future<void> _cancelGlobalAutoDeleteTimer() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';
    if (doctorId.isEmpty) return;
    
    try {
      final batch = FirebaseFirestore.instance.batch();
      final doctorChatRef = Get.find<AuthService>().getUserReference(userId).collection('chats').doc(doctorId);
      final patientChatRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('pasien').doc(doctorId).collection('chats').doc(userId);
      
      batch.set(doctorChatRef, {'deleteAt': FieldValue.delete()}, SetOptions(merge: true));
      batch.set(patientChatRef, {'deleteAt': FieldValue.delete()}, SetOptions(merge: true));
      await batch.commit();
      
      _stopLocalCountdown();
    } catch (e) {
      print('Error canceling delete timer: $e');
    }
  }

  void _showAutoDeletePopup() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 10))],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.timer_outlined, size: 100, color: Colors.orange.withOpacity(0.1)),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.auto_delete, color: Colors.orange.shade700, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text('Peringatan Sistem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Sistem mendeteksi ucapan terima kasih.\nChat hapus otomatis selama 2 menit.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text('Mengerti'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendSystemReply(String text) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';
    if (doctorId.isEmpty) return;

    final messageData = {
      'text': text,
      'senderId': 'system',
      'senderName': 'Sistem',
      'senderRole': 'system',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      final batch = FirebaseFirestore.instance.batch();
      final doctorChatRef = Get.find<AuthService>().getUserReference(userId).collection('chats').doc(doctorId);
      final patientChatRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('pasien').doc(doctorId).collection('chats').doc(userId);

      batch.set(doctorChatRef, {'lastMessage': text, 'lastMessageTime': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      batch.set(patientChatRef, {'lastMessage': text, 'lastMessageTime': FieldValue.serverTimestamp()}, SetOptions(merge: true));

      final messageId = doctorChatRef.collection('messages').doc().id;
      batch.set(doctorChatRef.collection('messages').doc(messageId), messageData);
      batch.set(patientChatRef.collection('messages').doc(messageId), messageData);
      
      await batch.commit();
    } catch (e) {
      print('Error sending system reply: $e');
    }
  }

  Future<void> _deleteAllMessages() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';
    if (doctorId.isEmpty) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      
      final chatRef = Get.find<AuthService>().getUserReference(userId).collection('chats').doc(doctorId).collection('messages');
      final patientMessagesRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('pasien').doc(doctorId).collection('chats').doc(userId).collection('messages');
      
      final doctorCatatanRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(userId).collection('chats').doc(doctorId).collection('catatan');
      final patientCatatanRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('pasien').doc(doctorId).collection('chats').doc(userId).collection('catatan');

      final querySnapshot = await chatRef.get();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
        batch.delete(patientMessagesRef.doc(doc.id));
        batch.delete(doctorCatatanRef.doc(doc.id));
        batch.delete(patientCatatanRef.doc(doc.id));
      }
      
      // Hapus dokumen chat utama agar hilang dari daftar chat
      batch.delete(chatRef.parent!);
      batch.delete(patientMessagesRef.parent!);
      
      await batch.commit();
    } catch (e) {
      print('Error auto-deleting messages: $e');
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
    
    if (replyingToMessage.value != null) {
      messageData['replyToText'] = replyingToMessage.value!.text;
      messageData['replyToSender'] = replyingToMessage.value!.senderName ?? 'Sistem';
      
      // Auto-save doctor notes if replying to a report
      if (replyingToMessage.value!.text.startsWith('Laporan Riwayat Natrium')) {
        try {
          final patientDocRef = FirebaseFirestore.instance
              .collection('mobile')
              .doc('roles')
              .collection('pasien')
              .doc(doctorId);
              
          String reportContext = replyingToMessage.value!.text;
          String savedNote = "$reportContext\n\nCatatan dari $userName:\n$text";
          
          patientDocRef.update({
            'catatan_dokter': FieldValue.arrayUnion([savedNote])
          });
        } catch (e) {
          print('Error appending to catatan_dokter: $e');
        }
      }
    }

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
            replyToText: data['replyToText'],
            replyToSender: data['replyToSender'],
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

      // Hapus dari catatan Dokter
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('dokter')
          .doc(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('catatan')
          .doc(msgId)
          .delete();

      // Hapus dari catatan Pasien
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('catatan')
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

  Future<void> editMessage(String msgId, String newText) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';

    if (doctorId.isEmpty) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      
      final msg = messages.firstWhereOrNull((m) => m.id == msgId);
      if (msg == null || !msg.isUser) return;

      final doctorMsgRef = Get.find<AuthService>()
          .getUserReference(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('messages')
          .doc(msgId);
          
      final patientMsgRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .doc(msgId);

      batch.update(doctorMsgRef, {'text': newText});
      batch.update(patientMsgRef, {'text': newText});

      if (msg.replyToText != null && msg.replyToText!.startsWith('Laporan Riwayat Natrium')) {
        final doctorNoteRef = FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection('dokter')
            .doc(userId)
            .collection('chats')
            .doc(doctorId)
            .collection('catatan')
            .doc(msgId);
            
        final patientNoteRef = FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection('pasien')
            .doc(doctorId)
            .collection('chats')
            .doc(userId)
            .collection('catatan')
            .doc(msgId);

        final userName = user?.displayName ?? 'Dokter';
        String reportContext = msg.replyToText!;
        String savedNote = "$reportContext\n\nCatatan dari $userName:\n$newText";
        String oldNote1 = "$reportContext\n\nCatatan:\n${msg.text}";
        String oldNote2 = "$reportContext\n\nCatatan dari $userName:\n${msg.text}";

        // Only update if it actually exists, to avoid errors if it was missing, we use SetOptions(merge:true)
        batch.set(doctorNoteRef, {'note': savedNote}, SetOptions(merge: true));
        batch.set(patientNoteRef, {'note': savedNote}, SetOptions(merge: true));
        
        final patientDocRef = FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection('pasien')
            .doc(doctorId);
            
        // Karena FieldValue tidak bisa digunakan dua kali pada array yang sama dalam satu batch (update),
        // lakukan update sequential langsung di luar batch.
        try {
          await patientDocRef.update({
            'catatan_dokter': FieldValue.arrayRemove([oldNote1, oldNote2])
          });
          await patientDocRef.update({
            'catatan_dokter': FieldValue.arrayUnion([savedNote])
          });
        } catch (e) {
          print('Error updating catatan_dokter array: $e');
        }
      }

      await batch.commit();

      CustomPopup.showSuccess(
        'Sukses',
        'Pesan berhasil diubah',
      );
      
      clearSelection();
    } catch (e) {
      CustomPopup.showError(
        'Error',
        'Gagal mengubah pesan: $e',
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
