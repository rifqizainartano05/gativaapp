import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final tensiController = TextEditingController();
  final beratBadanController = TextEditingController();
  final tinggiBadanController = TextEditingController();

  final selectedCondition = 'Sehat'.obs;
  
  final List<String> conditions = [
    'Sehat',
    'Hipertensi',
    'Penyakit kardiovaskular',
    'Penyakit jantung koroner',
    'Penyakit ginjal kronis',
    'Stroke'
  ];

  final isLoading = false.obs;
  final isFetching = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('mobile').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        nameController.text = data['name'] ?? '';
        ageController.text = (data['age'] ?? '').toString();
        tensiController.text = data['tensi'] ?? '';
        beratBadanController.text = (data['beratBadan'] ?? '').toString();
        tinggiBadanController.text = (data['tinggiBadan'] ?? '').toString();
        selectedCondition.value = data['kondisi'] ?? 'Sehat';
      }
    }
    isFetching.value = false;
  }

  double calculateDailyLimit(int age, String condition) {
    if (age >= 5 && age <= 9) {
      switch (condition) {
        case 'Sehat': return 1200;
        case 'Hipertensi': return 1200;
        case 'Penyakit kardiovaskular': return 1000;
        case 'Penyakit jantung koroner': return 1000;
        case 'Penyakit ginjal kronis': return 800;
        case 'Stroke': return 0;
        default: return 1200;
      }
    } else if (age >= 10 && age <= 17) {
      switch (condition) {
        case 'Sehat': return 1500;
        case 'Hipertensi': return 1200;
        case 'Penyakit kardiovaskular': return 1000;
        case 'Penyakit jantung koroner': return 1000;
        case 'Penyakit ginjal kronis': return 800;
        case 'Stroke': return 0;
        default: return 1500;
      }
    } else if (age >= 18 && age <= 59) {
      switch (condition) {
        case 'Sehat': return 2000;
        case 'Hipertensi': return 1500;
        case 'Penyakit kardiovaskular': return 1500;
        case 'Penyakit jantung koroner': return 1500;
        case 'Penyakit ginjal kronis': return 1500;
        case 'Stroke': return 1500;
        default: return 2000;
      }
    } else {
      switch (condition) {
        case 'Sehat': return 1200;
        case 'Hipertensi': return 1000;
        case 'Penyakit kardiovaskular': return 1000;
        case 'Penyakit jantung koroner': return 1000;
        case 'Penyakit ginjal kronis': return 1000;
        case 'Stroke': return 1000;
        default: return 1200;
      }
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty || ageController.text.trim().isEmpty) {
      Get.snackbar('Input Kosong', 'Harap isi semua kolom.', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    int? age = int.tryParse(ageController.text);
    if (age == null || age < 5) {
      Get.snackbar('Kesalahan', 'Usia tidak valid (Minimal 5 tahun).', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    isLoading.value = true;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        double newLimit = calculateDailyLimit(age, selectedCondition.value);

        await FirebaseFirestore.instance.collection('mobile').doc(user.uid).update({
          'name': nameController.text.trim(),
          'age': age,
          'kondisi': selectedCondition.value,
          'dailyLimit': newLimit,
        });

        Get.back();
        Get.snackbar('Berhasil', 'Profil Anda telah diperbarui.', backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan saat memperbarui profil.', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}
