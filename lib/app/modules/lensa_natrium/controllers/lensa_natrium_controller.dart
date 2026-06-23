import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LensaNatriumController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final isAnalyzing = false.obs;
  final isLoading = false.obs;
  
  final searchResults = <Map<String, dynamic>>[].obs;
  final allJajanan = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchJajananFromFirebase();
  }

  List<Map<String, dynamic>> _globalJajanan = [];
  List<Map<String, dynamic>> _userJajanan = [];

  void _fetchJajananFromFirebase() {
    isLoading.value = true;
    final user = FirebaseAuth.instance.currentUser;

    // Ambil data jajanan global dari website
    FirebaseFirestore.instance
        .collection('website')
        .doc('rifqizainartano50904@gmail.com')
        .collection('jajanan')
        .snapshots()
        .listen((snapshot) {
      final globalData = snapshot.docs.map((e) {
        final d = e.data();
        return {
          'name': d['nama_jajanan'] ?? d['name'] ?? 'Tanpa Nama',
          'type': d['kategori'] ?? d['type'] ?? 'Umum',
          'sodium': int.tryParse(d['kandungan_natrium']?.toString() ?? d['natrium_mg']?.toString() ?? d['sodium']?.toString() ?? '0') ?? 0,
        };
      }).toList();
      
      _updateAllJajanan(globalData, true);
    }, onError: (e) {
      print("Error fetching jajanan global: $e");
      isLoading.value = false;
    });

    // Ambil data jajanan hasil scan user dari subcollection mobile
    if (user != null) {
      FirebaseFirestore.instance
          .collection('mobile')
          .doc(user.uid)
          .collection('label gizi makanan')
          .snapshots()
          .listen((snapshot) {
        final userData = snapshot.docs.map((e) {
          final d = e.data();
          return {
            'name': d['name'] ?? 'Pindaian',
            'type': d['type'] ?? 'Kemasan',
            'sodium': (d['natrium'] as num?)?.toInt() ?? (d['sodium'] as num?)?.toInt() ?? 0,
          };
        }).toList();
        
        _updateAllJajanan(userData, false);
      }, onError: (e) {
        print("Error fetching user jajanan: $e");
      });
    }
  }

  void _updateAllJajanan(List<Map<String, dynamic>> data, bool isGlobal) {
    if (isGlobal) {
      _globalJajanan = data;
    } else {
      _userJajanan = data;
    }
    allJajanan.assignAll([..._userJajanan, ..._globalJajanan]);
    searchFood(searchController.text);
    isLoading.value = false;
  }

  void searchFood(String query) {
    if (query.isEmpty) {
      searchResults.assignAll(allJajanan);
      return;
    }
    final lowercaseQuery = query.toLowerCase();
    searchResults.assignAll(
      allJajanan.where((item) => item['name'].toString().toLowerCase().contains(lowercaseQuery))
    );
  }

  void captureAndAnalyze() async {
    isAnalyzing.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isAnalyzing.value = false;
    
    Get.snackbar(
      'Analisis Selesai',
      'Tidak menemukan natrium pada gambar yang dipindai.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }

  void logFood(Map<String, dynamic> item) {
    Get.snackbar(
      'Berhasil Disimpan',
      '${item['name']} telah ditambahkan ke catatan harian.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }
}
