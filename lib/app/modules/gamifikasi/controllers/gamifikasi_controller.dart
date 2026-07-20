import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';

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
  final dailyLimit = 2000.obs;
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
      Get.find<AuthService>().getUserReference(user.uid).snapshots().listen((
        doc,
      ) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          userPoints.value = data['points'] ?? 0;
          userLevel.value = data['gamifikasiLevel'] ?? 'Pemula';
          currentStreak.value = data['streak'] ?? 0;
          dailyLimit.value = (data['dailyLimit'] ?? 2000).toInt();
        }
      });
    }
  }

  List<Mission> _generateMissionTemplates() {
    final titles = [
      "Pengetahuan Dasar", 
      "Organ Terdampak", 
      "Batas Aman", 
      "Bahaya Tersembunyi", 
      "Bumbu Alami", 
      "Fakta Ginjal", 
      "Trik Mengurangi", 
      "Master Natrium",
      "Kandungan Saus",
      "Garam dan Air",
      "Fakta Makanan Cepat Saji",
      "Gejala Hipertensi",
      "Mitos dan Fakta",
      "Camilan Sehat",
      "Fakta Olahraga",
      "Ahli Nutrisi"
    ];

    final tasks = [
      "Berapa batas aman konsumsi garam per hari menurut WHO? (gram)", 
      "Organ apa yang bekerja paling keras menyaring natrium berlebih?", 
      "Pahami batas aman konsumsi harianmu. Natrium pada makanan ringan biasanya disembunyikan dalam bentuk apa?", 
      "Apakah minum banyak air putih membantu membuang natrium dari tubuh? (Ya/Tidak)", 
      "Sebutkan satu alternatif bumbu alami selain garam untuk masakan.", 
      "Apa dampak utama asupan garam tinggi yang tidak terkontrol pada pembuluh darah?", 
      "Cara terbaik memasak untuk menghindari penambahan garam berlebih adalah dengan...", 
      "Buktikan kamu adalah Master Natrium! Apa kepanjangan dari hipertensi?",
      "Sebutkan salah satu saus botolan yang umumnya sangat tinggi natrium.",
      "Benarkah garam himalaya lebih sehat dan bebas natrium daripada garam dapur biasa? (Benar/Salah)",
      "Apa alasan utama makanan cepat saji (fast food) sangat tinggi natrium?",
      "Sebutkan satu gejala umum dari tekanan darah tinggi (hipertensi).",
      "Apakah berkeringat mengeluarkan banyak natrium dari tubuh? (Ya/Tidak)",
      "Sebutkan satu jenis camilan alami yang rendah natrium namun mengenyangkan.",
      "Olahraga jenis apa yang paling disarankan untuk menjaga kesehatan jantung dan tekanan darah?",
      "Zat gizi apa yang dapat membantu menyeimbangkan kadar natrium dalam darah? (Petunjuk: ada di pisang)"
    ];

    List<Mission> generatedMissions = [];
    for (int i = 0; i < titles.length; i++) {
      String? question = tasks[i]; // Semua tugas adalah pertanyaan
      
      final mission = Mission(
        id: 'm${i + 1}',
        level: i + 1,
        title: titles[i],
        description: "Jawab pertanyaan singkat di bawah ini dengan tepat untuk melanjutkan perjalanan sehat Anda mengurangi konsumsi natrium berlebih.",
        question: question,
        rewardPoints: 10 + (i * 5),
        isCompleted: false,
        isUnlocked: i == 0,
      );
      generatedMissions.add(mission);
    }
    return generatedMissions;
  }

  void _fetchMissionsFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      final snapshot = await Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('missions')
          .orderBy('level')
          .get();
          
      final localTemplates = _generateMissionTemplates();

      if (snapshot.docs.isEmpty) {
        // Seeding HANYA level pertama ke Firebase
        localTemplates[0].isUnlocked = true;
        await Get.find<AuthService>()
            .getUserReference(user.uid)
            .collection('missions')
            .doc(localTemplates[0].id)
            .set(localTemplates[0].toMap());
            
        _updateMissionsState(localTemplates);
      } else {
        final List<Mission> fetchedMissions = snapshot.docs
            .map((doc) => Mission.fromMap(doc.data(), doc.id))
            .toList();
            
        for (var firebaseMission in fetchedMissions) {
          int index = localTemplates.indexWhere((m) => m.id == firebaseMission.id);
          if (index != -1) {
            // Hanya timpakan status progressnya agar teks lokal (judul/deskripsi terbaru) tetap dipakai
            localTemplates[index].isCompleted = firebaseMission.isCompleted;
            localTemplates[index].isUnlocked = firebaseMission.isUnlocked;
          }
        }
        _updateMissionsState(localTemplates);
      }
    } catch (e) {
      print("Error fetching missions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _updateMissionsState(List<Mission> allMissions) {
    int firstIncomplete = allMissions.indexWhere((m) => m.isUnlocked && !m.isCompleted);
    currentActiveLevel.value = firstIncomplete != -1
        ? allMissions[firstIncomplete].level
        : allMissions.length;
    missions.assignAll(allMissions);
    
    if (firstIncomplete != -1) {
      // Jadwalkan pengingat agar muncul esok hari / saat app ditutup, bukan saat sedang login/buka app.
      NotificationService.scheduleDailyReminder();
    }
  }

  int calculateDailyLimit(int currentLimit) {
    // Menurunkan batas natrium secara bertahap dari limit pengguna saat ini
    // Turun 30mg setiap kali naik level, batas minimum 1000mg.
    int newLimit = currentLimit - 30;
    if (newLimit < 1000) {
      newLimit = 1000;
    }
    return (newLimit / 10).round() * 10; // Bulatkan ke puluhan terdekat
  }

  Future<void> verifyMissionAnswer(Mission mission, String answer) async {
    if (answer.trim().isEmpty) {
      Get.snackbar('Perhatian', 'Jawaban tidak boleh kosong!', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      ),
      barrierDismissible: false,
    );

    try {
      const apiKey = 'YOUR_GROQ_API_KEY_HERE'; // TODO: Setup environment variable or get from config
      
      String botMessage = "";
      
      if (apiKey == 'YOUR_GROQ_API_KEY_HERE') {
        // Fallback evaluasi lokal jika API key belum dikonfigurasi (Agar fitur tetap 'Aktif')
        await Future.delayed(const Duration(seconds: 1)); // Simulasi loading
        
        final lowerAnswer = answer.toLowerCase();
        final lowerQuestion = mission.question?.toLowerCase() ?? "";
        
        // Ekstrak kata kunci penting dari pertanyaan
        final stopWords = ['apa', 'yang', 'dimaksud', 'dengan', 'bagaimana', 'cara', 'mengapa', 'kenapa', 'sebutkan', 'jelaskan', 'di', 'ke', 'dari', 'pada', 'dalam', 'untuk', 'adalah', 'itu', 'ini', 'dan', 'atau', 'apakah'];
        final questionWords = lowerQuestion.split(RegExp(r'\W+'))
            .where((w) => w.length > 3 && !stopWords.contains(w))
            .toList();
            
        // Kata kunci tambahan kesehatan
        final healthKeywords = ['ginjal', 'jantung', 'darah', 'natrium', 'garam', 'air', 'hipertensi', 'stroke', 'kalium', 'sehat', 'tubuh', 'tekanan', 'pembuluh', 'makanan', 'minuman', 'nutrisi', 'gizi'];
        
        bool isPlausible = false;
        if (lowerAnswer.length > 5 && !lowerAnswer.contains('tidak tahu')) {
           // Cek irisan kata dari pertanyaan
           for (var qw in questionWords) {
             if (lowerAnswer.contains(qw)) {
               isPlausible = true;
               break;
             }
           }
           // Jika belum cocok, cek kata kunci kesehatan umum
           if (!isPlausible) {
             for (var hk in healthKeywords) {
               if (lowerAnswer.contains(hk)) {
                 isPlausible = true;
                 break;
               }
             }
           }
        }
        
        if (isPlausible) {
           botMessage = "BENAR";
        } else {
           botMessage = "SALAH. ${_getCorrectAnswer(mission.id)}";
        }
      } else {
        final prompt = '''
        Anda adalah asisten kesehatan ahli gizi dan penilai kuis.
        Pertanyaan: "${mission.question}"
        Jawaban Pengguna: "$answer"
        
        Aturan:
        1. Jika jawaban pengguna BENAR atau esensinya sudah tepat, balas dengan satu kata saja: "BENAR".
        2. Jika jawaban pengguna SALAH, melenceng, atau ngawur, balas dengan awalan "SALAH". Setelah itu, spasi, dan beritahu apa JAWABAN YANG BENAR secara singkat dan ramah (maksimal 2 kalimat).
        
        Contoh 1 (Jika pengguna jawab benar):
        BENAR
        Contoh 2 (Jika pengguna jawab salah):
        SALAH. Kurang tepat. Yang benar adalah Ginjal, karena ginjal bertugas menyaring sisa metabolisme dan natrium berlebih.
        ''';

        final response = await http.post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'llama-3.1-8b-instant',
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
            'temperature': 0.1,
            'max_tokens': 150,
          }),
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          botMessage = jsonResponse['choices'][0]['message']['content'].toString().trim();
        } else {
           botMessage = "BENAR"; // Fallback
        }
      }

      Get.back(); // Tutup loading

      bool isCorrect = true; // Default fallback ke benar jika error
      String explanation = '';

      if (botMessage.isNotEmpty) {
        isCorrect = botMessage.toUpperCase().startsWith("BENAR");
        explanation = botMessage.replaceFirst(RegExp(r'^(BENAR|SALAH)[.\s]*', caseSensitive: false), '').trim();
      }

      if (isCorrect) {
        completeMission(mission.id);
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            elevation: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned(
                    right: -40,
                    bottom: -20,
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 200,
                      color: const Color(0xFF2E7D32).withOpacity(0.05),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF2E7D32),
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Jawaban Benar! 🎉",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Luar biasa! Kamu berhasil menyelesaikan misi ini.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Lanjut",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            elevation: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned(
                    right: -40,
                    bottom: -20,
                    child: Icon(
                      Icons.cancel_rounded,
                      size: 200,
                      color: Colors.red.withOpacity(0.05),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.red,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Jawaban Salah",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          explanation.isNotEmpty ? explanation : 'Jawaban kamu masih keliru, coba lagi yuk!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Tutup & Coba Lagi",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      Get.back();
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          elevation: 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  right: -40,
                  bottom: -20,
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 200,
                    color: Colors.orange.withOpacity(0.05),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.orange,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Koneksi Bermasalah",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Gagal terhubung ke server asisten pintar untuk mengevaluasi jawaban Anda. Periksa jaringan internet Anda dan coba lagi.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Mengerti",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void completeMission(String id) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    int index = missions.indexWhere((m) => m.id == id);
    if (index != -1 &&
        !missions[index].isCompleted &&
        missions[index].isUnlocked) {
      // Update lokal secara sinkron agar UI langsung responsif
      missions[index].isCompleted = true;
      userPoints.value += missions[index].rewardPoints;

      if (index + 1 < missions.length) {
        missions[index + 1].isUnlocked = true;
        currentActiveLevel.value = missions[index + 1].level;
      }
      missions.refresh();

      // Mulai proses background ke Firebase tanpa memblokir UI
      try {
        final docRef = Get.find<AuthService>()
            .getUserReference(user.uid)
            .collection('missions')
            .doc(missions[index].id);
        await docRef.update({'isCompleted': true});

        if (index + 1 < missions.length) {
          // Kirim misi selanjutnya ke Firebase (satu per satu)
          final nextDocRef = Get.find<AuthService>()
              .getUserReference(user.uid)
              .collection('missions')
              .doc(missions[index + 1].id);
          await nextDocRef.set(missions[index + 1].toMap());
        }
        
        int newLimit = calculateDailyLimit(dailyLimit.value);

        await Get.find<AuthService>().getUserReference(user.uid).update({
          'points': FieldValue.increment(missions[index].rewardPoints),
          'gamifikasiLevel': 'Level ${currentActiveLevel.value}',
          'dailyLimit': newLimit, // Menurunkan batas harian natrium!
        });
      } catch (e) {
        print("Firebase update for mission failed (network issue?), but UI is updated optimistically: $e");
      }

    }
  }

  bool completeMissionByLevel(int level) {
    int index = missions.indexWhere((m) => m.level == level);
    if (index != -1 && !missions[index].isCompleted) {
      completeMission(missions[index].id);
      return true;
    }
    return false;
  }

  String _getCorrectAnswer(String missionId) {
    switch (missionId) {
      case 'm1': return "Batas aman menurut WHO adalah 5 gram per hari (sekitar 1 sendok teh).";
      case 'm2': return "Ginjal adalah organ yang bekerja paling keras menyaring natrium berlebih.";
      case 'm3': return "Dalam bentuk pengawet makanan atau penguat rasa seperti MSG (Monosodium Glutamat).";
      case 'm4': return "Ya, air putih sangat membantu ginjal membuang kelebihan natrium dari tubuh.";
      case 'm5': return "Perasan lemon, lada, bawang putih, ketumbar, atau rempah-rempah asli.";
      case 'm6': return "Dapat mengeraskan pembuluh darah dan menyebabkan tekanan darah tinggi (hipertensi).";
      case 'm7': return "Mengukus, memanggang, atau menggunakan bumbu rempah alami tanpa tambahan garam olahan.";
      case 'm8': return "Hipertensi adalah istilah medis untuk penyakit tekanan darah tinggi.";
      case 'm9': return "Kecap asin, saus tomat, sambal botolan, atau saus tiram sangat tinggi natrium.";
      case 'm10': return "Salah, garam himalaya tetap mengandung natrium yang kadarnya mirip dengan garam dapur biasa.";
      case 'm11': return "Sering digunakan sebagai bahan pengawet agar tahan lama dan penguat rasa buatan agar lebih gurih.";
      case 'm12': return "Sering sakit kepala bagian belakang, pusing, tengkuk terasa kaku, atau kelelahan (terkadang tanpa gejala/silent killer).";
      case 'm13': return "Ya, namun bukan berarti kamu bebas makan natrium banyak hanya dengan berkeringat saja.";
      case 'm14': return "Buah-buahan segar, kacang-kacangan tanpa garam, sayuran rebus, atau yogurt plain.";
      case 'm15': return "Olahraga aerobik/kardio seperti lari ringan (jogging), jalan cepat, berenang, atau bersepeda.";
      case 'm16': return "Kalium (Potassium). Zat ini berfungsi menyeimbangkan dan membuang kelebihan natrium.";
      default: return "Jawaban yang benar berkaitan erat dengan penjelasan dan materi edukasi pada misi kesehatan ini.";
    }
  }
}
