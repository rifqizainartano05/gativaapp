import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../notifikasi/controllers/notifikasi_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_pages.dart';

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

class ChatController extends GetxController with GetSingleTickerProviderStateMixin {
  final isLoading = true.obs;
  final dokterList = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  
  late TabController tabController;
  final activeChats = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get filteredDokterList {
    if (searchQuery.value.trim().isEmpty) return dokterList;
    return dokterList.where((doc) {
      final name = doc['name']?.toString().toLowerCase() ?? '';
      return name.contains(searchQuery.value.trim().toLowerCase());
    }).toList();
  }
  
  final messages = <ChatMessage>[].obs;
  final selectedDoctor = Rxn<Map<String, dynamic>>();
  StreamSubscription<QuerySnapshot>? _chatSubscription;
  StreamSubscription<QuerySnapshot>? _dokterSubscription;
  StreamSubscription<QuerySnapshot>? _activeChatsSubscription;
  Timer? _scheduleTimer;
  final chatDoctorUnreads = <String, int>{}.obs;

  void onInit() {
    super.onInit();
    if (!Get.isRegistered<NotifikasiController>()) {
      Get.put(NotifikasiController(), permanent: true);
    }
    tabController = TabController(length: 2, vsync: this);
    fetchDokter();
    fetchActiveChats();
    _scheduleTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      dokterList.refresh();
      activeChats.refresh();
    });
  }

  void fetchActiveChats() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _activeChatsSubscription = Get.find<AuthService>()
        .getUserReference(user.uid)
        .collection('chats')
        .snapshots()
        .listen((snapshot) {
      
      Map<String, int> validIdsAndUnreads = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['deleteAt'] != null) {
          final deleteAt = (data['deleteAt'] as Timestamp).toDate();
          if (DateTime.now().isAfter(deleteAt) || DateTime.now().isAtSameMomentAs(deleteAt)) {
            _deleteExpiredChat(doc.id);
            continue;
          }
        }
        validIdsAndUnreads[doc.id] = data['unreadCount'] ?? 0;
      }
      
      chatDoctorUnreads.clear();
      chatDoctorUnreads.addAll(validIdsAndUnreads);
      _syncActiveChats();
    });
  }

  Future<void> _deleteExpiredChat(String doctorId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final patientId = user.uid;

    try {
      final batch = FirebaseFirestore.instance.batch();
      
      final chatRef = Get.find<AuthService>().getUserReference(patientId).collection('chats').doc(doctorId).collection('messages');
      final doctorMessagesRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(doctorId).collection('chats').doc(patientId).collection('messages');
      
      final doctorCatatanRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(doctorId).collection('chats').doc(patientId).collection('catatan');
      final patientCatatanRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('pasien').doc(patientId).collection('chats').doc(doctorId).collection('catatan');

      final querySnapshot = await chatRef.get();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
        batch.delete(doctorMessagesRef.doc(doc.id));
        batch.delete(doctorCatatanRef.doc(doc.id));
        batch.delete(patientCatatanRef.doc(doc.id));
      }

      batch.delete(Get.find<AuthService>().getUserReference(patientId).collection('chats').doc(doctorId));
      batch.delete(FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(doctorId).collection('chats').doc(patientId));

      await batch.commit();
    } catch (e) {
      print('Error lazy deleting chat: $e');
    }
  }

  void _syncActiveChats() {
    if (chatDoctorUnreads.isEmpty || dokterList.isEmpty) {
      activeChats.clear();
      return;
    }
    
    final List<Map<String, dynamic>> temp = [];
    for (var id in chatDoctorUnreads.keys) {
      final doctor = dokterList.firstWhereOrNull((d) => d['id'] == id);
      if (doctor != null) {
        final clonedDoc = Map<String, dynamic>.from(doctor);
        clonedDoc['unreadCount'] = chatDoctorUnreads[id];
        temp.add(clonedDoc);
      }
    }
    activeChats.value = temp;
  }

  void fetchDokter() {
    isLoading.value = true;
    _dokterSubscription = FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('dokter')
        .snapshots()
        .listen((snapshot) {
      List<Map<String, dynamic>> temp = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['rating'] = '0'; // Placeholder until fetched
        temp.add(data);
      }
      
      // Update UI immediately without waiting for ratings
      dokterList.value = temp;
      _syncActiveChats();
      isLoading.value = false;

      // Fetch ratings in background
      _fetchRatingsBackground(snapshot.docs);
    }, onError: (e) {
      Get.snackbar('Error', 'Gagal memuat daftar dokter: $e');
      isLoading.value = false;
    });
  }

  Future<void> _fetchRatingsBackground(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    for (var doc in docs) {
      try {
        final pasienSnapshot = await doc.reference.collection('pasien').get();
        double totalRating = 0;
        int ratingCount = 0;
        for (var pDoc in pasienSnapshot.docs) {
          final pData = pDoc.data();
          if (pData.containsKey('rating')) {
            totalRating += (pData['rating'] as num).toDouble();
            ratingCount++;
          }
        }
        
        String newRating = ratingCount > 0 ? (totalRating / ratingCount).toStringAsFixed(1) : '0';
        
        int index = dokterList.indexWhere((d) => d['id'] == doc.id);
        if (index != -1) {
          if (dokterList[index]['rating'] != newRating) {
            var updatedDoc = Map<String, dynamic>.from(dokterList[index]);
            updatedDoc['rating'] = newRating;
            dokterList[index] = updatedDoc;
            _syncActiveChats();
          }
        }
      } catch (e) {
        // Ignore rating fetch errors so main UI isn't affected
      }
    }
  }

  Future<void> openChatWithDoctor(Map<String, dynamic> doctor) async {
    Get.toNamed(Routes.ROOM_CHAT, arguments: {...doctor, 'isHistory': false});
  }

  Future<void> enterChatRoom(Map<String, dynamic> doctor) async {
    Get.toNamed(Routes.ROOM_CHAT, arguments: {...doctor, 'isHistory': true});
  }

  Future<void> updateDoctorRating(String doctorId, int rating) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('dokter')
          .doc(doctorId)
          .collection('pasien')
          .doc(user.uid)
          .set({'rating': rating}, SetOptions(merge: true));
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim rating: $e');
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    _scheduleTimer?.cancel();
    _dokterSubscription?.cancel();
    _activeChatsSubscription?.cancel();
    _chatSubscription?.cancel();
    super.onClose();
  }
}
