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

  @override
  void onInit() {
    super.onInit();
    fetchNakes();
  }

  void fetchNakes() {
    isLoading.value = true;
    FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('tenaga_kesehatan')
        .snapshots()
        .listen((snapshot) {
      nakesList.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      isLoading.value = false;
    }, onError: (e) {
      Get.snackbar('Error', 'Gagal memuat daftar dokter: $e');
      isLoading.value = false;
    });
  }

  Future<void> openChatWithDoctor(Map<String, dynamic> doctor) async {
    Get.toNamed(Routes.ROOM_CHAT, arguments: doctor);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
