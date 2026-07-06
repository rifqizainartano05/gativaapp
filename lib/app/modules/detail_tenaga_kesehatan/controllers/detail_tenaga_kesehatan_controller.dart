import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../widgets/custom_popup.dart';

class DetailTenagaKesehatanController extends GetxController {
  final isLoading = true.obs;
  final doctorData = <String, dynamic>{}.obs;
  final isOnline = false.obs;
  final scheduleText = 'Belum ada jadwal'.obs;
  final rating = 0.obs;
  final hasRated = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      doctorData.value = args;
      _checkOnlineStatus(args['jadwal_online']?.toString());
      fetchDoctorDetails(args['id']);
    } else {
      isLoading.value = false;
    }
  }

  void _checkOnlineStatus(String? jadwal) {
    if (jadwal == null || jadwal.isEmpty) {
      isOnline.value = false;
      scheduleText.value = 'Belum ada jadwal';
      return;
    }

    scheduleText.value = jadwal;
    // Asumsi format jadwal adalah "08:00 - 16:00"
    try {
      final parts = jadwal.split('-');
      if (parts.length == 2) {
        final startPart = parts[0].trim();
        final endPart = parts[1].trim();

        final startParts = startPart.split(':');
        final endParts = endPart.split(':');

        if (startParts.length == 2 && endParts.length == 2) {
          final startHour = int.parse(startParts[0]);
          final startMinute = int.parse(startParts[1]);
          final endHour = int.parse(endParts[0]);
          final endMinute = int.parse(endParts[1]);

          final now = DateTime.now();
          final startTime = DateTime(now.year, now.month, now.day, startHour, startMinute);
          final endTime = DateTime(now.year, now.month, now.day, endHour, endMinute);

          if (now.isAfter(startTime) && now.isBefore(endTime)) {
            isOnline.value = true;
          } else {
            isOnline.value = false;
          }
          return;
        }
      }
    } catch (e) {
      // Abaikan jika format salah
    }
    isOnline.value = false;
  }

  void fetchDoctorDetails(String? id) async {
    if (id == null) {
      isLoading.value = false;
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(id)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        doctorData.value = data;
        _checkOnlineStatus(data['jadwal_online']?.toString());
        
        // Cek rating sebelumnya
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final ratingDoc = await FirebaseFirestore.instance
              .collection('mobile')
              .doc('roles')
              .collection('tenaga_kesehatan')
              .doc(id)
              .collection('pasien')
              .doc(user.uid)
              .get();
              
          if (ratingDoc.exists) {
            final rData = ratingDoc.data();
            if (rData != null && rData['rating'] != null) {
              rating.value = rData['rating'];
              hasRated.value = true;
            }
          }
        }
      }
    } catch (e) {
      // fallback to args
    } finally {
      isLoading.value = false;
    }
  }

  void updateDoctorRating(String? doctorId, int ratingValue) async {
    if (doctorId == null || doctorId.isEmpty) return;
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
          .set({'rating': ratingValue}, SetOptions(merge: true));
          
      hasRated.value = true;
          
      CustomPopup.showSuccess(
        "Terima Kasih", 
        "Rating Anda berhasil dikirim",
      );
    } catch (e) {
      CustomPopup.showError('Error', 'Gagal mengirim rating: $e');
    }
  }
}

