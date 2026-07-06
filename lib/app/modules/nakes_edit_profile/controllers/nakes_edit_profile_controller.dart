import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/custom_popup.dart';
import '../../../services/auth_service.dart';

class NakesEditProfileController extends GetxController {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final tensiController = TextEditingController();
  final beratBadanController = TextEditingController();
  final tinggiBadanController = TextEditingController();
  final universitasController = TextEditingController();
  final mulaiPraktikController = TextEditingController();
  final jadwalOnlineController = TextEditingController();

  final RxString photoBase64 = ''.obs;
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final isFetching = true.obs;

  final Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);

  @override
  void onInit() {
    super.onInit();

    ever(photoBase64, (String b64) {
      if (b64.isEmpty) {
        imageBytes.value = null;
        return;
      }
      try {
        if (b64.contains(',')) b64 = b64.split(',').last;
        b64 = b64.replaceAll(RegExp(r'\s+'), '');
        imageBytes.value = base64Decode(b64);
      } catch (e) {
        imageBytes.value = null;
      }
    });

    loadUserData();
  }

  void loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await Get.find<AuthService>()
          .getUserReference(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        nameController.text = data['name'] ?? '';
        ageController.text = (data['age'] ?? '').toString();
        tensiController.text = data['tensi'] ?? '';
        beratBadanController.text = (data['beratBadan'] ?? '').toString();
        tinggiBadanController.text = (data['tinggiBadan'] ?? '').toString();
        photoBase64.value = data['photo64'] ?? '';
        universitasController.text = data['universitas'] ?? '';
        mulaiPraktikController.text = data['mulai_praktik'] ?? '';
        jadwalOnlineController.text = data['jadwal_online'] ?? '';
      }
    }
    isFetching.value = false;
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      if (image != null) {
        final File file = File(image.path);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        photoBase64.value = base64String;
      }
    } catch (e) {
      CustomPopup.showError(
        'Kesalahan',
        'Gagal mengambil gambar',
      );
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty) {
      CustomPopup.showWarning(
        'Input Kosong',
        'Harap isi semua kolom.',
      );
      return;
    }

    int? age = int.tryParse(ageController.text);
    if (age == null || age < 5) {
      CustomPopup.showWarning(
        'Kesalahan',
        'Usia tidak valid (Minimal 5 tahun).',
      );
      return;
    }

    isLoading.value = true;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await Get.find<AuthService>().getUserReference(user.uid).update({
          'name': nameController.text.trim(),
          'age': age,
          'photo64': photoBase64.value,
          'universitas': universitasController.text.trim(),
          'mulai_praktik': mulaiPraktikController.text.trim(),
          'jadwal_online': jadwalOnlineController.text.trim(),
        });

        CustomPopup.showSuccess(
          'Berhasil',
          'Profil Anda telah diperbarui.',
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.back();
        });
      }
    } catch (e) {
      CustomPopup.showError(
        'Gagal',
        'Terjadi kesalahan saat memperbarui profil.',
      );
    } finally {
      isLoading.value = false;
    }
  }

}
