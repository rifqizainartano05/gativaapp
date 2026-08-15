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
    List<String> conditions = c.split(',').map((e) => e.trim()).toList();
    
    double minLimit = 2000;

    for (String cond in conditions) {
      double limit = 2000;
      
      if (age >= 10 && age <= 18) {
        if (cond.contains('sehat')) limit = 1500;
        else if (cond.contains('hipertensi')) limit = 1200;
        else if (cond.contains('kardiovaskular')) limit = 1000;
        else if (cond.contains('jantung')) limit = 1000;
        else if (cond.contains('ginjal')) limit = 800;
        else if (cond.contains('stroke')) limit = 0;
        else limit = 1500;
      } else if (age >= 18 && age <= 59) {
        if (cond.contains('sehat')) limit = 2000;
        else if (cond.contains('hipertensi')) limit = 1500;
        else if (cond.contains('kardiovaskular')) limit = 1500;
        else if (cond.contains('jantung')) limit = 1500;
        else if (cond.contains('ginjal')) limit = 1500;
        else if (cond.contains('stroke')) limit = 1500;
        else limit = 2000;
      } else {
        if (age >= 5 && age <= 9) {
          if (cond.contains('sehat')) limit = 1200;
          else if (cond.contains('hipertensi')) limit = 1200;
          else if (cond.contains('kardiovaskular')) limit = 1000;
          else if (cond.contains('jantung')) limit = 1000;
          else if (cond.contains('ginjal')) limit = 1000;
          else if (cond.contains('stroke')) limit = 0;
          else limit = 1200;
        } else if (age >= 60) {
          if (cond.contains('sehat')) limit = 1200;
          else if (cond.contains('hipertensi')) limit = 1000;
          else if (cond.contains('kardiovaskular')) limit = 1200;
          else if (cond.contains('jantung')) limit = 1200;
          else if (cond.contains('ginjal')) limit = 1000;
          else if (cond.contains('stroke')) limit = 1000;
          else if (cond.contains('osteoporosis')) limit = 2300;
          else limit = 1200;
        }
      }
      if (limit < minLimit) {
        minLimit = limit;
      }
    }
    
    return minLimit;
  }

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final tensiController = TextEditingController();
  final beratBadanController = TextEditingController();
  final tinggiBadanController = TextEditingController();
  
  final selectedConditionsList = <String>[].obs;
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
          String fetched = data['kondisi_kesehatan'] ?? 'Sehat';
          selectedConditionsList.assignAll(fetched.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
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
        String joinedConditions = selectedConditionsList.isEmpty ? 'Sehat' : selectedConditionsList.join(', ');
        final dataToUpdate = <String, dynamic>{
          'name': nameController.text.trim(),
          'age': age,
          'berat_badan': double.tryParse(beratBadanController.text.trim()) ?? 0,
          'tinggi_badan': double.tryParse(tinggiBadanController.text.trim()) ?? 0,
          'kondisi_kesehatan': joinedConditions,
          'dailyLimit': calculateDailyLimit(age, joinedConditions),
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
