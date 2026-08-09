import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DokterDetailPasienChatController extends GetxController {
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
    String getVal(dynamic val) {
      if (val == null) return '-';
      String s = val.toString().trim();
      return s.isEmpty ? '-' : s;
    }

    nameController = TextEditingController(text: getVal(data['name'] ?? data['nama']));
    tekananDarahController = TextEditingController(text: getVal(data['tekanan_darah']));
    tinggiBadanController = TextEditingController(text: getVal(data['tinggi_badan']));
    beratBadanController = TextEditingController(text: getVal(data['berat_badan']));
    kondisiKesehatanController = TextEditingController(text: getVal(data['kondisi_kesehatan'] ?? data['kondisi']));
    usiaController = TextEditingController(text: getVal(data['age'] ?? data['usia']));
    
    dynamic rawCatatan = data['catatan_dokter'];
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
        } else {
          dynamic rawCatatan = data['catatan_dokter'];
          if (rawCatatan is List) {
            catatanList.value = List<String>.from(rawCatatan);
          } else if (rawCatatan is String && rawCatatan.isNotEmpty) {
            catatanList.value = [rawCatatan];
          } else {
            catatanList.clear();
          }
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
}

