import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

      // Sort by createdAt client-side if it exists
      tempPatients.sort((a, b) {
        final dateA = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA); // newest first, adjust if you want oldest first (dateA.compareTo(dateB))
      });

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
