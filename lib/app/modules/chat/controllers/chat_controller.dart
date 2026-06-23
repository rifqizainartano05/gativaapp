import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final String? senderName;
  final String? senderRole;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.senderName,
    this.senderRole,
  });
}

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;

  // Live Chat Data
  final selectedDoctor = Rxn<Map<String, dynamic>>();
  StreamSubscription<QuerySnapshot>? _chatSubscription;

  // List of doctors
  final doctors = <Map<String, dynamic>>[].obs;
  final isLoadingDoctors = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchDoctors();
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

  Future<void> _fetchDoctors() async {
    if (doctors.isNotEmpty) return;

    isLoadingDoctors.value = true;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('website')
          .get();

      print("DOKTER DEBUG: Found ${snapshot.docs.length} docs in website collection");
      
      final List<Map<String, dynamic>> tempDoctors = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print("DOKTER DEBUG Data: $data");
        final peran = (data['peran'] ?? '').toString().toLowerCase();
        // Cek toleransi case sensitivity
        if (peran == 'dokter') {
          tempDoctors.add({'id': doc.id, ...data});
        } else {
          // DEBUG: Tampilkan semua data sementara agar kita bisa lihat strukturnya di layar
          tempDoctors.add({'id': doc.id, 'is_debug': true, ...data});
        }
      }

      doctors.value = tempDoctors;
    } catch (e) {
      print("Error fetching doctors/admins: $e");
    }
    isLoadingDoctors.value = false;
  }

  Future<void> openChatWithDoctor(Map<String, dynamic> doctor) async {
    selectedDoctor.value = doctor;
    messages.clear();

    final docName = doctor['username'] ?? 'Dokter';
    final docRole = doctor['peran'] ?? 'dokter';

    messages.insert(
      0,
      ChatMessage(
        text: "--- Anda terhubung dengan $docName ---",
        isUser: false,
        time: DateTime.now(),
        senderName: 'Sistem',
        senderRole: 'sistem',
      ),
    );

    _listenToFirebaseChat();
  }

  void exitChat() {
    _chatSubscription?.cancel();
    selectedDoctor.value = null;
    messages.clear();
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

    messages.insert(
      0, 
      ChatMessage(
        text: text, 
        isUser: true, 
        time: DateTime.now(),
        senderName: userName,
        senderRole: 'pasien'
      )
    );

    try {
      // Simpan di sub-collection mobile
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('messages')
          .add(messageData);

      // Simpan di sub-collection website
      await FirebaseFirestore.instance
          .collection('website')
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

    final query = FirebaseFirestore.instance
        .collection('mobile')
        .doc(userId)
        .collection('chats')
        .doc(doctorId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    _chatSubscription = query.snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final senderId = data['senderId'] ?? '';

          if (senderId != userId) {
            final text = data['text'] ?? '';
            final ts = data['timestamp'] as Timestamp?;
            final time = ts?.toDate() ?? DateTime.now();
            final senderName = data['senderName'] ?? selectedDoctor.value?['username'] ?? 'Dokter';
            final senderRole = data['senderRole'] ?? selectedDoctor.value?['peran'] ?? 'dokter';

            messages.insert(
              0, 
              ChatMessage(
                text: text, 
                isUser: false, 
                time: time,
                senderName: senderName,
                senderRole: senderRole
              )
            );
          }
        }
      }
    });
  }

  @override
  void onClose() {
    _chatSubscription?.cancel();
    super.onClose();
  }
}
