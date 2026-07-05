import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NakesDetailPasienChatController extends GetxController {
  final pasienData = {}.obs;

  late TextEditingController nameController;
  late TextEditingController tekananDarahController;
  late TextEditingController tinggiBadanController;
  late TextEditingController beratBadanController;
  late TextEditingController kondisiKesehatanController;
  late TextEditingController usiaController;
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
          _populateFields(data);
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
    super.onClose();
  }
}
