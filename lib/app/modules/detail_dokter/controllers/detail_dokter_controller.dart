import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../widgets/custom_popup.dart';

class DetailDokterController extends GetxController {
  final isLoading = true.obs;
  final doctorData = <String, dynamic>{}.obs;
  final scheduleText = 'Belum ada jadwal'.obs;
  String? currentDoctorId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      doctorData.value = args;
      if (args['id'] != null) {
        currentDoctorId = args['id'].toString();
      }
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
          .collection('dokter')
          .doc(id)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        currentDoctorId = doc.id;
        doctorData.value = data;
        if (data['jadwal_online'] != null && data['jadwal_online'].toString().isNotEmpty) {
          scheduleText.value = data['jadwal_online'].toString();
        }
      }
    } catch (e) {
      // fallback to args
    } finally {
      isLoading.value = false;
    }
  }
}

