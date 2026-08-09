import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/custom_popup.dart';
import 'package:intl/intl.dart';

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

class RoomChatController extends GetxController {
  final messages = <ChatMessage>[].obs;

  // Live Chat Data
  final selectedDoctor = Rxn<Map<String, dynamic>>();
  final RxBool doctorIsOnline = false.obs;
  final Rx<DateTime?> doctorLastSeen = Rx<DateTime?>(null);
  final RxBool doctorIsTyping = false.obs;
  
  final notesMap = <String, String>{}.obs;
  StreamSubscription? _chatSubscription;
  StreamSubscription? _notesSubscription;
  StreamSubscription<DocumentSnapshot>? _presenceSubscription;
  StreamSubscription<DocumentSnapshot>? _typingSubscription;
  Timer? _typingTimer;
  Timer? _scheduleTimer;

  // Data filter
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();
  final selectedFilter = Rxn<String>();

  final RxBool hasShownRating = false.obs;
  final RxBool partnerIsTyping = false.obs;
  final RxBool partnerIsOnline = false.obs;
  final Rx<DateTime?> partnerLastSeen = Rx<DateTime?>(null);

  bool _isTemporary = false;
  bool get isHistory => !_isTemporary;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      selectedDoctor.value = args;
      _listenToNotes();
      _listenToFirebaseChat();
      _listenToPartnerTyping();
      _listenToPartnerPresence();
      
      if (args['isHistory'] == false) {
        _isTemporary = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showTemporaryChatPopup();
        });
      }
    }
  }

    void _showTemporaryChatPopup() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 80, color: Colors.blue.withOpacity(0.1)),
                  const Icon(Icons.timer_outlined, size: 40, color: Colors.blue),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Informasi Chat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Jika tidak ada respon selama 5 menit, maka obrolan otomatis dihapus.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        _startPopupReminderTimer();
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _initChatHistory();
                        _startAutoDeleteTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Baik', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _initChatHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';
    if (doctorId.isEmpty) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // User side
      final userChatRef = Get.find<AuthService>().getUserReference(userId).collection('chats').doc(doctorId);
      batch.set(userChatRef, {
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Doctor side
      final doctorChatRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(doctorId).collection('chats').doc(userId);
      batch.set(doctorChatRef, {
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      await batch.commit();
    } catch (e) {
      // ignore
    }
  }

  Timer? _countdownTimer;
  Timer? _reminderTimer;
  final RxInt remainingSeconds = 300.obs;

  void _startAutoDeleteTimer() {
    _reminderTimer?.cancel();
    remainingSeconds.value = 300;
    _countdownTimer?.cancel();
    _reminderTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        await _deleteChatHistory();
        Get.back();
        Get.snackbar('Otomatis Dihapus', 'Chat telah dihapus karena tidak ada respon selama 5 menit.', backgroundColor: Colors.white);
      }
    });
  }
  
  void _startPopupReminderTimer() {
    _countdownTimer?.cancel();
    _reminderTimer?.cancel();
    _reminderTimer?.cancel();
    _reminderTimer = Timer(const Duration(minutes: 5), () {
      if (messages.isEmpty) {
        _showTemporaryChatPopup();
      }
    });
  }

  Future<void> _deleteChatHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final doctorId = selectedDoctor.value?['id'] ?? '';
    if (doctorId.isEmpty) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // User side
      final userChatRef = Get.find<AuthService>().getUserReference(userId).collection('chats').doc(doctorId);
      batch.delete(userChatRef);
      
      // Doctor side
      final doctorChatRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(doctorId).collection('chats').doc(userId);
      batch.delete(doctorChatRef);
      
      await batch.commit();
    } catch (e) {
      // ignore
    }
  }

  void _cancelAllTimers() {
    _countdownTimer?.cancel();
    _reminderTimer?.cancel();
    _reminderTimer?.cancel();
  }


  void _listenToPartnerPresence() {
    final doctorId = selectedDoctor.value?['id'] ?? '';
    if (doctorId.isEmpty) return;

    _presenceSubscription?.cancel();
    _presenceSubscription = FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('dokter')
        .doc(doctorId)
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

  void onClose() {
    _chatSubscription?.cancel();
    _notesSubscription?.cancel();
    _presenceSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    _countdownTimer?.cancel();
    _reminderTimer?.cancel();
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
          .collection('dokter')
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

    _cancelAllTimers();

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
      final batch = FirebaseFirestore.instance.batch();

      // Referensi dokumen chat parent
      final userChatRef = Get.find<AuthService>()
          .getUserReference(userId)
          .collection('chats')
          .doc(doctorId);
          
      final doctorChatRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('dokter')
          .doc(doctorId)
          .collection('chats')
          .doc(userId);

      // Pastikan parent document ada dan terupdate
      batch.set(userChatRef, {
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      batch.set(doctorChatRef, {
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Generate a single ID for the message so it's identical on both sides
      final messageId = userChatRef.collection('messages').doc().id;

      // Tambahkan pesan ke sub-collection menggunakan ID yang sama
      final userMsgRef = userChatRef.collection('messages').doc(messageId);
      batch.set(userMsgRef, messageData);

      final doctorMsgRef = doctorChatRef.collection('messages').doc(messageId);
      batch.set(doctorMsgRef, messageData);

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

      final userMsgRef = Get.find<AuthService>()
          .getUserReference(userId)
          .collection('chats')
          .doc(doctorId)
          .collection('catatan')
          .doc(messageId);
          
      final doctorMsgRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('dokter')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('catatan')
          .doc(messageId);

      try {
        batch.set(userMsgRef, {'note': note}, SetOptions(merge: true));
        batch.set(doctorMsgRef, {'note': note}, SetOptions(merge: true));
        await batch.commit();
      } catch (e) {
        print('Error updating note: $e');
      }
    } catch (e) {
      print('Error saving note: $e');
    }
  }



  int _parseDays(String label) {
    if (label == 'Atur Tanggal') return 7; // Default 7 days for now if unhandled
    if (label.contains('Hari')) {
      return int.tryParse(label.split(' ')[0]) ?? 0;
    } else if (label.contains('Minggu')) {
      return (int.tryParse(label.split(' ')[0]) ?? 0) * 7;
    } else if (label.contains('Bulan')) {
      return (int.tryParse(label.split(' ')[0]) ?? 0) * 30;
    } else if (label.contains('Tahun')) {
      return (int.tryParse(label.split(' ')[0]) ?? 0) * 365;
    }
    return 7;
  }

  void showHistoryModal() {
    final filterOptionsList = [
      "3 Hari Terakhir",
      "5 Hari Terakhir",
      "7 Hari Terakhir",
      "14 Hari Terakhir",
      "30 Hari Terakhir",
      "3 Minggu Terakhir",
      "4 Minggu Terakhir",
      "8 Minggu Terakhir",
      "12 Minggu Terakhir",
      "3 Bulan Terakhir",
      "6 Bulan Terakhir",
      "9 Bulan Terakhir",
      "12 Bulan Terakhir",
      "3 Tahun Terakhir",
      "5 Tahun Terakhir",
      "Atur Tanggal",
    ];

    String selectedOption = "";
    DateTimeRange? customDateRange;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bagikan Riwayat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Pilih periode riwayat konsumsi natrium yang ingin dibagikan ke dokter.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: filterOptionsList.length,
                      itemBuilder: (context, index) {
                        final option = filterOptionsList[index];
                        final isSelected = selectedOption == option;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (index == 0) Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                              title: Text(
                                option,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                                ),
                              ),
                              trailing: Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                              ),
                              onTap: () {
                                setState(() {
                                  selectedOption = option;
                                });
                              },
                            ),
                            if (option == 'Atur Tanggal' && isSelected) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: customDateRange?.start ?? DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime.now(),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              final end = customDateRange?.end ?? picked;
                                              customDateRange = DateTimeRange(
                                                start: picked,
                                                end: end.isBefore(picked) ? picked : end,
                                              );
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Dari', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                              const SizedBox(height: 4),
                                              Text(
                                                customDateRange != null
                                                    ? "${customDateRange!.start.day}/${customDateRange!.start.month}/${customDateRange!.start.year}"
                                                    : "Pilih",
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text("-", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 20)),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: customDateRange?.end ?? DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime.now(),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              final start = customDateRange?.start ?? picked;
                                              customDateRange = DateTimeRange(
                                                start: start.isAfter(picked) ? picked : start,
                                                end: picked,
                                              );
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Sampai', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                              const SizedBox(height: 4),
                                              Text(
                                                customDateRange != null
                                                    ? "${customDateRange!.end.day}/${customDateRange!.end.month}/${customDateRange!.end.year}"
                                                    : "Pilih",
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedOption.isEmpty
                            ? null
                            : () {
                                if (selectedOption == 'Atur Tanggal') {
                                  if (customDateRange == null) {
                                    CustomPopup.showError('Peringatan', 'Silakan atur tanggal dari dan sampai terlebih dahulu.');
                                    return;
                                  }
                                  Get.back();
                                  _sendHistoryData('Kustom', 0, customDateRange);
                                } else {
                                  Get.back();
                                  _sendHistoryData(selectedOption, _parseDays(selectedOption), null);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Kirim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
      isScrollControlled: false,
    );
  }

  Future<void> _sendHistoryData(String label, int days, DateTimeRange? dateRange) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      Query query = Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('label gizi makanan');
          
      if (dateRange != null) {
        final startOfDay = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
        final endOfDay = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day, 23, 59, 59);
        label = "${startOfDay.day}/${startOfDay.month}/${startOfDay.year} - ${endOfDay.day}/${endOfDay.month}/${endOfDay.year}";
        query = query.where('created_at', isGreaterThanOrEqualTo: startOfDay).where('created_at', isLessThanOrEqualTo: endOfDay);
      } else {
        final now = DateTime.now();
        DateTime startDate;
        if (days == 1) {
          startDate = DateTime(now.year, now.month, now.day);
        } else {
          startDate = now.subtract(Duration(days: days));
        }
        query = query.where('created_at', isGreaterThanOrEqualTo: startDate);
      }

      final snapshot = await query.get();

      double totalNatrium = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalNatrium += (data['natrium'] ?? data['sodium'] ?? data['amount'] ?? 0).toDouble();
      }

      final int count = snapshot.docs.length;
      
      if (count <= 1) {
        CustomPopup.showError(
          'Tidak Sesuai',
          'Riwayat belum terpenuhi atau kurang lengkap untuk periode $label. Pastikan rentang data riwayat yang Anda miliki sudah sesuai dengan periode yang dipilih.',
        );
        return;
      }

      // Validasi apakah rentang waktu terpenuhi sesuai yang dipilih
      if (dateRange == null && days > 1) {
        DateTime oldestDate = DateTime.now();
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['created_at'] != null) {
            final createdAt = (data['created_at'] as Timestamp).toDate();
            if (createdAt.isBefore(oldestDate)) {
              oldestDate = createdAt;
            }
          }
        }
        
        final differenceInDays = DateTime.now().difference(oldestDate).inDays;
        // Jika opsi yang dipilih '3 Hari Terakhir' (days = 3), data tertua harus berjarak minimal 2 hari (H-2)
        if (differenceInDays < (days - 1)) {
          CustomPopup.showError(
            'Tidak Sesuai',
            'Riwayat belum terpenuhi untuk periode $label. Anda baru memiliki data kurang dari batas tersebut.',
          );
          return;
        }
      }

      final totalStr = totalNatrium.toStringAsFixed(0);
      
      String msg = 'Laporan Riwayat Natrium ($label)\nTotal Konsumsi: $totalStr mg\nJumlah Data: $count item';
      sendMessage(msg);

    } catch (e) {
      CustomPopup.showError('Error', 'Gagal memuat riwayat: $e');
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
        .collection('pasien')
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
        final ts = data['timestamp'] as Timestamp?;
        final time = ts?.toDate() ?? DateTime.now();
        final isUser = data['senderId'] == userId;
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
          
      // Hapus sisi dokter
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('dokter')
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
          
      final dokterMessagesRef = FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('dokter')
          .doc(doctorId)
          .collection('chats')
          .doc(userId)
          .collection('messages');

      final snapshot = await messagesRef.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
        batch.delete(dokterMessagesRef.doc(doc.id));
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


