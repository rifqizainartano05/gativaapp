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

class NakesChatController extends GetxController {
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

  @override
  void onInit() {
    super.onInit();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    if (doctors.isNotEmpty) return;

    isLoadingDoctors.value = true;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .get();

      print(
        "PASIEN DEBUG: Found ${snapshot.docs.length} docs in pasien collection",
      );

      final List<Map<String, dynamic>> tempPatients = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        tempPatients.add({'id': doc.id, ...data});
      }

      doctors.value = tempPatients; // Reusing doctors variable for patients to avoid massive refactoring
    } catch (e) {
      print("Error fetching patients: $e");
    }
    isLoadingDoctors.value = false;
  }

  Future<void> openChatWithDoctor(Map<String, dynamic> doctor) async {
    Get.toNamed(Routes.ROOM_NAKES_CHAT, arguments: doctor);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
