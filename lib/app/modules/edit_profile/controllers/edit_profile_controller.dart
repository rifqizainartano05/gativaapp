import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  final isFetching = false.obs;
  final isLoading = false.obs;
  final photoBase64 = ''.obs;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final tensiController = TextEditingController();
  final beratBadanController = TextEditingController();
  final tinggiBadanController = TextEditingController();
  
  final selectedCondition = 'Sehat'.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchProfileData();
  }

  void _fetchProfileData() async {
    isFetching.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection('pasien')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          nameController.text = data['name'] ?? data['nama'] ?? '';
          ageController.text = (data['age'] ?? data['usia'])?.toString() ?? '';
          tensiController.text = data['tekanan_darah'] ?? data['bloodPressure'] ?? data['tensi'] ?? '';
          beratBadanController.text = (data['berat_badan'] ?? data['weight'])?.toString() ?? '';
          tinggiBadanController.text = (data['tinggi_badan'] ?? data['height'])?.toString() ?? '';
          photoBase64.value = data['strImageBase64'] ?? data['photoBase64'] ?? '';
          selectedCondition.value = data['kondisi_kesehatan'] ?? 'Sehat';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat profil', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isFetching.value = false;
    }
  }

  void pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        photoBase64.value = base64Encode(bytes);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void updateProfile() async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final dataToUpdate = <String, dynamic>{
          'name': nameController.text.trim(),
          'age': int.tryParse(ageController.text.trim()) ?? 0,
        };
        
        if (photoBase64.value.isNotEmpty) {
          dataToUpdate['strImageBase64'] = photoBase64.value;
        }

        await FirebaseFirestore.instance
            .collection('mobile')
            .doc('roles')
            .collection('pasien')
            .doc(user.uid)
            .set(dataToUpdate, SetOptions(merge: true));

        Get.snackbar(
          'Sukses',
          'Profil berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui profil', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    ageController.dispose();
    tensiController.dispose();
    beratBadanController.dispose();
    tinggiBadanController.dispose();
    super.onClose();
  }
}
