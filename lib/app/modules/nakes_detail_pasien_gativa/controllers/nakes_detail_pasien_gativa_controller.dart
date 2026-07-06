import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_popup.dart';

class NakesDetailPasienGativaController extends GetxController {
  final pasienData = {}.obs;
  final isLoading = false.obs;

  late TextEditingController nameController;
  late TextEditingController tekananDarahController;
  late TextEditingController tinggiBadanController;
  late TextEditingController beratBadanController;
  late TextEditingController kondisiKesehatanController;
  late TextEditingController usiaController;
  late TextEditingController newCatatanController;
  final catatanList = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final data = Get.arguments as Map<String, dynamic>?;
    if (data != null) {
      pasienData.value = data;
      _populateFields(data);
      _listenToPasienData(data['id']);
    } else {
      _populateFields({});
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    nameController = TextEditingController(text: data['name'] ?? data['nama'] ?? '');
    tekananDarahController = TextEditingController(text: data['tekanan_darah'] ?? '');
    tinggiBadanController = TextEditingController(text: (data['tinggi_badan'] ?? '').toString());
    beratBadanController = TextEditingController(text: (data['berat_badan'] ?? '').toString());
    kondisiKesehatanController = TextEditingController(text: data['kondisi_kesehatan'] ?? data['kondisi'] ?? '');
    usiaController = TextEditingController(text: (data['age'] ?? data['usia'] ?? '').toString());
    newCatatanController = TextEditingController();
    
    dynamic rawCatatan = data['catatan_nakes'];
    if (rawCatatan is List) {
      catatanList.value = List<String>.from(rawCatatan);
    } else if (rawCatatan is String && rawCatatan.isNotEmpty) {
      catatanList.value = [rawCatatan];
    } else {
      catatanList.clear();
    }
  }

  bool _isFirstLoad = true;

  void _listenToPasienData(String? id) {
    if (id == null) return;
    FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('pasien')
        .doc(id)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        pasienData.assignAll({
          ...pasienData,
          ...data,
        });
        
        if (_isFirstLoad) {
          nameController.text = data['name'] ?? data['nama'] ?? '';
          tekananDarahController.text = data['tekanan_darah'] ?? '';
          tinggiBadanController.text = (data['tinggi_badan'] ?? '').toString();
          beratBadanController.text = (data['berat_badan'] ?? '').toString();
          kondisiKesehatanController.text = data['kondisi_kesehatan'] ?? data['kondisi'] ?? '';
          usiaController.text = (data['age'] ?? data['usia'] ?? '').toString();
          
          dynamic rawCatatan = data['catatan_nakes'];
          if (rawCatatan is List) {
            catatanList.value = List<String>.from(rawCatatan);
          } else if (rawCatatan is String && rawCatatan.isNotEmpty) {
            catatanList.value = [rawCatatan];
          } else {
            catatanList.clear();
          }
          _isFirstLoad = false;
        }
      }
    }, onError: (e) {
      // Ignore error
    });

    // Calculate daily total from subcollection 'label gizi makanan'
    FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('pasien')
        .doc(id)
        .collection('label gizi makanan')
        .snapshots()
        .listen((snapshot) {
      double dailyTotal = 0.0;
      final now = DateTime.now();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        DateTime? docDate = (data['created_at'] as Timestamp?)?.toDate() ?? (data['timestamp'] as Timestamp?)?.toDate();
        if (docDate != null && docDate.year == now.year && docDate.month == now.month && docDate.day == now.day) {
          dailyTotal += ((data['natrium'] ?? data['sodium'] ?? data['amount'] ?? 0) as num).toDouble();
        }
      }
      pasienData['natrium'] = dailyTotal.toInt();
      pasienData.refresh();
    }, onError: (e) {
      // Ignore error
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    tekananDarahController.dispose();
    tinggiBadanController.dispose();
    beratBadanController.dispose();
    kondisiKesehatanController.dispose();
    usiaController.dispose();
    newCatatanController.dispose();
    super.onClose();
  }

  Future<void> saveChanges() async {
    final id = pasienData['id'];
    if (id == null) {
      CustomPopup.showError('Error', 'ID Pasien tidak ditemukan');
      return;
    }

    isLoading.value = true;
    try {
      final nameKey = pasienData.containsKey('nama') && !pasienData.containsKey('name') ? 'nama' : 'name';
      final kondisiKey = pasienData.containsKey('kondisi') && !pasienData.containsKey('kondisi_kesehatan') ? 'kondisi' : 'kondisi_kesehatan';
      final ageKey = pasienData.containsKey('usia') && !pasienData.containsKey('age') ? 'usia' : 'age';

      final currentData = {
        nameKey: nameController.text.trim(),
        'tekanan_darah': tekananDarahController.text.trim(),
        'tinggi_badan': tinggiBadanController.text.trim(),
        'berat_badan': beratBadanController.text.trim(),
        kondisiKey: kondisiKesehatanController.text.trim(),
        ageKey: int.tryParse(usiaController.text.trim()) ?? usiaController.text.trim(),
        'catatan_nakes': catatanList.toList(),
      };

      final updatedData = <String, dynamic>{};
      currentData.forEach((key, value) {
        if (key == 'catatan_nakes') {
          // Compare lists
          final oldList = pasienData[key] is List ? List.from(pasienData[key]) : [];
          final newList = value as List;
          if (oldList.length != newList.length || !oldList.every((e) => newList.contains(e))) {
            updatedData[key] = value;
          }
        } else {
          final originalValue = pasienData[key]?.toString() ?? '';
          final newValue = value.toString();
          
          if (originalValue != newValue) {
            updatedData[key] = value;
          }
        }
      });

      if (updatedData.isEmpty) {
        CustomPopup.showWarning('Info', 'Tidak ada perubahan data yang perlu disimpan');
        isLoading.value = false;
        return;
      }

      await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(id)
          .update(updatedData);

      pasienData.value = {
        ...pasienData,
        ...updatedData,
      };
      
      CustomPopup.showSuccess('Sukses', 'Data pasien berhasil diperbarui');
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.back(result: true);
      });
    } catch (e) {
      CustomPopup.showError('Error', 'Gagal memperbarui data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}


