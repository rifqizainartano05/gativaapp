import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mission {
  final String id;
  final int level;
  final String title;
  final String description;
  final String? question;
  final int rewardPoints;
  bool isCompleted;
  bool isUnlocked;

  Mission({
    required this.id,
    required this.level,
    required this.title,
    required this.description,
    this.question,
    required this.rewardPoints,
    this.isCompleted = false,
    this.isUnlocked = false,
  });

  factory Mission.fromMap(Map<String, dynamic> map, String id) {
    return Mission(
      id: id,
      level: map['level'] ?? 1,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      question: map['question'],
      rewardPoints: map['rewardPoints'] ?? 10,
      isCompleted: map['isCompleted'] ?? false,
      isUnlocked: map['isUnlocked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'title': title,
      'description': description,
      'question': question,
      'rewardPoints': rewardPoints,
      'isCompleted': isCompleted,
      'isUnlocked': isUnlocked,
    };
  }
}

class GamifikasiController extends GetxController {
  final userPoints = 0.obs;
  final userLevel = 'Pemula'.obs;
  final currentStreak = 0.obs;
  final currentActiveLevel = 1.obs;
  final isLoading = false.obs;
  
  final missions = <Mission>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchUserData();
    _fetchMissionsFromFirebase();
  }

  void _fetchUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('mobile').doc(user.uid).snapshots().listen((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          userPoints.value = data['points'] ?? 0;
          userLevel.value = data['gamifikasiLevel'] ?? 'Pemula';
          currentStreak.value = data['streak'] ?? 0;
        }
      });
    }
  }

  void _fetchMissionsFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('mobile').doc(user.uid).collection('missions').orderBy('level').get();
      if (snapshot.docs.isEmpty) {
        await _seedMissionsToFirebase();
      } else {
        final List<Mission> fetchedMissions = snapshot.docs.map((doc) => Mission.fromMap(doc.data(), doc.id)).toList();
        _updateMissionsState(fetchedMissions);
      }
    } catch (e) {
      print("Error fetching missions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _seedMissionsToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final tasks = [
      "Catat sarapan pertamamu!",
      "Pindai barcode kemasan keripik.",
      "Makan siang di bawah 600mg natrium.",
      "Baca artikel edukasi hipertensi.",
      "Gunakan Lensa Natrium untuk seblak.",
      "Catat asupan air 2 liter.",
      "Pilih jajanan sehat tanpa MSG.",
      "Konsultasi dengan Chat Bot.",
      "Makan malam rendah garam.",
      "Catat berat badan dan tensi.",
      "Simulasikan asupan masa depan.",
      "Cek riwayat konsumsi mingguan.",
      "Pindai 3 barcode berbeda hari ini.",
      "Cari alternatif camilan sehat.",
      "Bagikan progres ke grup.",
      "Masak sendiri tanpa kecap asin.",
      "Pertahankan batas aman 3 hari.",
      "Cek edukasi ginjal kronis.",
      "Makan buah sebagai pengganti camilan.",
      "Tantangan 7 hari rendah natrium selesai!"
    ];

    List<Mission> generatedMissions = [];
    for (int i = 0; i < 20; i++) {
      String? question;
      if (i == 4) question = "Berapa gram natrium rata-rata pada seblak?";
      if (i == 7) question = "Apa kepanjangan dari MSG?";
      if (i == 13) question = "Sebutkan satu jenis buah yang baik untuk camilan rendah natrium.";

      final mission = Mission(
        id: 'm${i+1}',
        level: i + 1,
        title: 'Level ${i+1}',
        description: tasks[i],
        question: question,
        rewardPoints: 10 + (i * 5),
        isCompleted: false, 
        isUnlocked: i == 0, 
      );
      generatedMissions.add(mission);
      
      final docRef = FirebaseFirestore.instance.collection('mobile').doc(user.uid).collection('missions').doc('m${i+1}');
      batch.set(docRef, mission.toMap());
    }
    
    await batch.commit();
    _updateMissionsState(generatedMissions);
  }

  void _updateMissionsState(List<Mission> fetchedMissions) {
    int firstIncomplete = fetchedMissions.indexWhere((m) => !m.isCompleted);
    currentActiveLevel.value = firstIncomplete != -1 ? fetchedMissions[firstIncomplete].level : 20;
    missions.assignAll(fetchedMissions);
  }

  void completeMission(String id) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    int index = missions.indexWhere((m) => m.id == id);
    if (index != -1 && !missions[index].isCompleted && missions[index].isUnlocked) {
      
      // Update lokal
      missions[index].isCompleted = true;
      userPoints.value += missions[index].rewardPoints;
      
      final docRef = FirebaseFirestore.instance.collection('mobile').doc(user.uid).collection('missions').doc(missions[index].id);
      await docRef.update({'isCompleted': true});

      if (index + 1 < missions.length) {
        missions[index + 1].isUnlocked = true;
        currentActiveLevel.value = missions[index + 1].level;
        
        final nextDocRef = FirebaseFirestore.instance.collection('mobile').doc(user.uid).collection('missions').doc(missions[index + 1].id);
        await nextDocRef.update({'isUnlocked': true});
      }
      missions.refresh(); 

      await FirebaseFirestore.instance.collection('mobile').doc(user.uid).update({
        'points': FieldValue.increment(missions[index].rewardPoints),
        'gamifikasiLevel': 'Level ${currentActiveLevel.value}'
      });

      Get.snackbar(
        'Level ${missions[index].level} Selesai! 🎉',
        'Anda mendapatkan ${missions[index].rewardPoints} poin.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF2E7D32).withOpacity(0.9),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
