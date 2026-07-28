import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/custom_popup.dart';

class EditProfileController extends GetxController {
  final isFetching = false.obs;
  final isLoading = false.obs;
  final photoBase64 = ''.obs;

  double calculateDailyLimit(int age, String condition) {
    String c = condition.trim().toLowerCase();
    if (age >= 5 && age <= 9) {
      if (c.contains('sehat')) return 1200;
      if (c.contains('hipertensi')) return 1200;
      if (c.contains('kardiovaskular')) return 1000;
      if (c.contains('jantung')) return 1000;
      if (c.contains('ginjal')) return 1000;
      if (c.contains('stroke')) return 0;
      return 1200;
    } else if (age >= 10 && age <= 17) {
      if (c.contains('sehat')) return 1500;
      if (c.contains('hipertensi')) return 1200;
      if (c.contains('kardiovaskular')) return 1000;
      if (c.contains('jantung')) return 1000;
      if (c.contains('ginjal')) return 1000;
      if (c.contains('stroke')) return 0;
      return 1500;
    } else if (age >= 18 && age <= 59) {
      if (c.contains('sehat')) return 2000;
      if (c.contains('hipertensi')) return 1500;
      if (c.contains('kardiovaskular')) return 1500;
      if (c.contains('jantung')) return 1500;
      if (c.contains('ginjal')) return 1500;
      if (c.contains('stroke')) return 1500;
      return 2000;
    } else if (age >= 60) {
      if (c.contains('sehat')) return 1200;
      if (c.contains('hipertensi')) return 1000;
      if (c.contains('kardiovaskular')) return 1200;
      if (c.contains('jantung')) return 1200;
      if (c.contains('ginjal')) return 1000;
      if (c.contains('stroke')) return 1000;
      if (c.contains('osteoporosis')) return 2300;
      return 1200;
    }
    return 2000;
  }

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
      CustomPopup.showError('Error', 'Gagal memuat profil');
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
      CustomPopup.showError('Error', 'Gagal mengambil gambar');
    }
  }

  void updateProfile() async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        int age = int.tryParse(ageController.text.trim()) ?? 0;
        final dataToUpdate = <String, dynamic>{
          'name': nameController.text.trim(),
          'age': age,
          'dailyLimit': calculateDailyLimit(age, selectedCondition.value),
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

        CustomPopup.showSuccess(
          'Sukses',
          'Profil berhasil diperbarui',
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.back();
        });
      }
    } catch (e) {
      CustomPopup.showError('Error', 'Gagal memperbarui profil');
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
