import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../widgets/custom_popup.dart';

class DetailTenagaKesehatanController extends GetxController {
  final isLoading = true.obs;
  final doctorData = <String, dynamic>{}.obs;
  final scheduleText = 'Belum ada jadwal'.obs;
  final rating = 0.obs;
  final hasRated = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      doctorData.value = args;
      if (args['jadwal_online'] != null && args['jadwal_online'].toString().isNotEmpty) {
        scheduleText.value = args['jadwal_online'].toString();
      }
      fetchDoctorDetails(args['id']);
    } else {
      isLoading.value = false;
    }
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
        if (data['jadwal_online'] != null && data['jadwal_online'].toString().isNotEmpty) {
          scheduleText.value = data['jadwal_online'].toString();
        }
        
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

