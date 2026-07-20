import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class ChatController extends GetxController {
  final isLoading = true.obs;
  final nakesList = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  
  List<Map<String, dynamic>> get filteredNakesList {
    if (searchQuery.value.trim().isEmpty) return nakesList;
    return nakesList.where((doc) {
      final name = doc['name']?.toString().toLowerCase() ?? '';
      return name.contains(searchQuery.value.trim().toLowerCase());
    }).toList();
  }
  
  final messages = <ChatMessage>[].obs;
  final selectedDoctor = Rxn<Map<String, dynamic>>();
  StreamSubscription<QuerySnapshot>? _chatSubscription;
  StreamSubscription<QuerySnapshot>? _nakesSubscription;
  Timer? _scheduleTimer;

  @override
  void onInit() {
    super.onInit();
    fetchNakes();
    _scheduleTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      nakesList.refresh();
    });
  }

  void fetchNakes() {
    isLoading.value = true;
    _nakesSubscription = FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('tenaga_kesehatan')
        .snapshots()
        .listen((snapshot) async {
      List<Map<String, dynamic>> temp = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        
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
          if (ratingCount > 0) {
            data['rating'] = (totalRating / ratingCount).toStringAsFixed(1);
          } else {
            data['rating'] = '0';
          }
        } catch (e) {
          data['rating'] = '0';
        }
        temp.add(data);
      }
      nakesList.value = temp;
      isLoading.value = false;
    }, onError: (e) {
      Get.snackbar('Error', 'Gagal memuat daftar tenaga kesehatan: $e');
      isLoading.value = false;
    });
  }

  Future<void> openChatWithDoctor(Map<String, dynamic> doctor) async {
    Get.toNamed(Routes.ROOM_CHAT, arguments: doctor);
  }

  Future<void> updateDoctorRating(String doctorId, int rating) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
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
    _scheduleTimer?.cancel();
    _nakesSubscription?.cancel();
    _chatSubscription?.cancel();
    super.onClose();
  }
}

