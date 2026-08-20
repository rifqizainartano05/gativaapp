import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../notifikasi/controllers/notifikasi_controller.dart';

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

class DokterChatController extends GetxController {
  final isLoading = false.obs;

  // List of doctors (actually patients)
  final doctors = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  
  List<Map<String, dynamic>> get filteredDoctors {
    if (searchQuery.value.trim().isEmpty) return doctors;
    return doctors.where((doc) {
      final name = doc['name']?.toString().toLowerCase() ?? '';
      return name.contains(searchQuery.value.trim().toLowerCase());
    }).toList();
  }
  
  final isLoadingDoctors = false.obs;
  
  StreamSubscription? _chatsSubscription;
  final Map<String, StreamSubscription<DocumentSnapshot>> _presenceSubscriptions = {};

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<NotifikasiController>()) {
      Get.put(NotifikasiController(), permanent: true);
    }
    _fetchDoctors();
  }

  void _fetchDoctors() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    isLoadingDoctors.value = true;
    
    _chatsSubscription = FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('dokter')
        .doc(user.uid)
        .collection('chats')
        .snapshots()
        .listen((chatsSnapshot) async {
      
      final List<Map<String, dynamic>> tempPatients = [];
      
      for (var chatDoc in chatsSnapshot.docs) {
        final patientId = chatDoc.id;
        final chatData = chatDoc.data();
        
        // Lazy delete check
        if (chatData['deleteAt'] != null) {
          final deleteAt = (chatData['deleteAt'] as Timestamp).toDate();
          if (DateTime.now().isAfter(deleteAt) || DateTime.now().isAtSameMomentAs(deleteAt)) {
            _deleteExpiredChat(patientId);
            continue; // Skip adding to UI
          }
        }
        
        // Ambil data detail pasien dari roles/pasien
        final patientDoc = await FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection('pasien')
            .doc(patientId)
            .get();
            
        if (patientDoc.exists) {
          final data = patientDoc.data() ?? {};
          final patientData = {
            'id': patientId, 
            'createdAt': chatData['createdAt'],
            'lastMessage': chatData['lastMessage'],
            'lastMessageTime': chatData['lastMessageTime'],
            'isWaitingReply': chatData['isWaitingReply'] ?? true, // Default to true if not set (legacy)
            'unreadCount': chatData['unreadCount'] ?? 0,
            ...data
          };
          tempPatients.add(patientData);
          
          // Listen to real-time presence
          if (!_presenceSubscriptions.containsKey(patientId)) {
            _presenceSubscriptions[patientId] = FirebaseFirestore.instance
                .collection('mobile')
                .doc('roles')
                .collection('pasien')
                .doc(patientId)
                .snapshots()
                .listen((patientSnapshot) {
              if (patientSnapshot.exists) {
                final isOnline = patientSnapshot.data()?['isOnline'] ?? false;
                final index = doctors.indexWhere((p) => p['id'] == patientId);
                if (index != -1) {
                  final updatedPatient = Map<String, dynamic>.from(doctors[index]);
                  updatedPatient['isOnline'] = isOnline;
                  doctors[index] = updatedPatient;
                  doctors.refresh();
                }
              }
            });
          }
        }
      }

      // Sort by lastMessageTime client-side if it exists (descending, newest first)
      tempPatients.sort((a, b) {
        final dateA = (a['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = (b['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA); 
      });

      // Calculate queue number for those waiting reply.
      // Since list is newest first, we iterate from end (oldest) to start (newest).
      int currentQueue = 1;
      for (int i = tempPatients.length - 1; i >= 0; i--) {
        if (tempPatients[i]['isWaitingReply'] == true) {
          tempPatients[i]['queueNumber'] = currentQueue;
          currentQueue++;
        }
      }

      doctors.value = tempPatients;
      isLoadingDoctors.value = false;
    }, onError: (e) {
      print("Error fetching patients: $e");
      isLoadingDoctors.value = false;
    });
  }

  Future<void> openChatWithDoctor(Map<String, dynamic> doctor) async {
    Get.toNamed(Routes.ROOM_DOKTER_CHAT, arguments: doctor);
  }

  Future<void> _deleteExpiredChat(String patientId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doctorId = user.uid;

    try {
      final batch = FirebaseFirestore.instance.batch();
      
      final chatRef = Get.find<AuthService>().getUserReference(doctorId).collection('chats').doc(patientId).collection('messages');
      final patientMessagesRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('pasien').doc(patientId).collection('chats').doc(doctorId).collection('messages');
      
      final doctorCatatanRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(doctorId).collection('chats').doc(patientId).collection('catatan');
      final patientCatatanRef = FirebaseFirestore.instance.collection('mobile').doc('roles').collection('pasien').doc(patientId).collection('chats').doc(doctorId).collection('catatan');

      final querySnapshot = await chatRef.get();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
        batch.delete(patientMessagesRef.doc(doc.id));
        batch.delete(doctorCatatanRef.doc(doc.id));
        batch.delete(patientCatatanRef.doc(doc.id));
      }

      // Also delete parent docs to clear from list
      batch.delete(Get.find<AuthService>().getUserReference(doctorId).collection('chats').doc(patientId));
      batch.delete(FirebaseFirestore.instance.collection('mobile').doc('roles').collection('pasien').doc(patientId).collection('chats').doc(doctorId));

      await batch.commit();
    } catch (e) {
      print('Error lazy deleting chat: $e');
    }
  }

  @override
  void onClose() {
    _chatsSubscription?.cancel();
    for (var sub in _presenceSubscriptions.values) {
      sub.cancel();
    }
    _presenceSubscriptions.clear();
    super.onClose();
  }
}
