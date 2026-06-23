import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final RxString name = "Pengguna".obs;
  final RxInt age = 28.obs;
  final RxString bloodPressure = "120/80".obs;
  final RxInt totalNatrium = 0.obs;

  final RxBool isNotificationEnabled = false.obs;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final RxString healthTargetText = "".obs;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
    fetchUserData();
  }

  void fetchUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('mobile').doc(user.uid).snapshots().listen((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          name.value = data['name'] ?? user.displayName ?? "Pengguna";
          totalNatrium.value = (data['natrium'] as num?)?.toInt() ?? (data['sodium'] as num?)?.toInt() ?? (data['totalNatrium'] as num?)?.toInt() ?? 0;
          age.value = data['age'] ?? 28;
          
          // Format dailyLimit to int string correctly
          if (data['dailyLimit'] != null) {
            double limit = (data['dailyLimit'] as num).toDouble();
            healthTargetText.value = limit.toInt().toString();
          } else {
            healthTargetText.value = "2000";
          }
          
          bloodPressure.value = data['tensi'] ?? "Belum ada";
        }
      });

      // Dengarkan sub collection label gizi makanan untuk total natrium hari ini
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      FirebaseFirestore.instance
          .collection('mobile')
          .doc(user.uid)
          .collection('label gizi makanan')
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .snapshots()
          .listen((snapshot) {
        double total = 0;
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final amount = (data['natrium'] as num?)?.toDouble() ?? (data['sodium'] as num?)?.toDouble() ?? 0.0;
          total += amount;
        }
        totalNatrium.value = total.toInt();
      });
    }
  }

  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
  }

  void toggleNotification(bool value) {
    isNotificationEnabled.value = value;
    if (value) {
      _evaluateSodiumAndNotify();
    }
  }

  Future<void> _evaluateSodiumAndNotify() async {
    final double limit = double.tryParse(healthTargetText.value) ?? 2000.0;
    final int current = totalNatrium.value;
    
    String title = '';
    String body = '';

    if (current >= limit) {
      title = '⚠️ Batas Terlampaui!';
      body = 'Asupan natrium Anda ($current mg) telah melebihi batas harian (${limit.toInt()} mg). Kurangi makanan asin!';
    } else if (current >= limit * 0.8) {
      title = 'Perhatian! Hampir Mencapai Batas';
      body = 'Asupan natrium ($current mg) mendekati batas harian (${limit.toInt()} mg).';
    } else {
      title = 'Status Natrium Aman ✅';
      body = 'Asupan Anda ($current mg) masih dalam batas aman hari ini (${limit.toInt()} mg).';
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'garda_limit_channel', 'Peringatan Batas Natrium',
            channelDescription: 'Notifikasi jika melewati batas asupan',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id: 0, 
      title: title, 
      body: body, 
      notificationDetails: platformChannelSpecifics,
    );
  }

  // Dialog Ekspor
  void showExportDialog() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Ekspor Laporan Medis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Get.back(),
                  )
                ],
              ),
              const SizedBox(height: 8),
              const Text("Pilih rentang tanggal untuk laporan dokter Anda.", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.date_range_rounded, color: Colors.white),
                label: const Text("Pilih Rentang Tanggal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                onPressed: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: Get.context!,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF2E7D32), 
                            onPrimary: Colors.white, 
                            onSurface: Colors.black, 
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    Get.back(); // Tutup bottom sheet
                    _showDocumentChecklistDialog(); // Buka dialog checklist
                  }
                },
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Dialog Checklist Dokumen Mengambang
  void _showDocumentChecklistDialog() {
    // State lokal untuk checkbox
    RxBool checkHarian = true.obs;
    RxBool checkGrafik = true.obs;
    RxBool checkKesimpulan = false.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Dokumen Pendukung", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text("Pilih data yang ingin disertakan di dalam PDF:", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              
              Obx(() => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF2E7D32),
                title: const Text("Data Asupan Harian", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                value: checkHarian.value,
                onChanged: (val) => checkHarian.value = val ?? false,
              )),
              Obx(() => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF2E7D32),
                title: const Text("Grafik Tren Mingguan", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                value: checkGrafik.value,
                onChanged: (val) => checkGrafik.value = val ?? false,
              )),
              Obx(() => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF2E7D32),
                title: const Text("Kesimpulan Sistem", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                value: checkKesimpulan.value,
                onChanged: (val) => checkKesimpulan.value = val ?? false,
              )),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.grey)
                      ),
                      onPressed: () => Get.back(),
                      child: const Text("Batal", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0
                      ),
                      onPressed: () {
                        Get.back();
                        Get.snackbar("Mengunduh", "Laporan PDF sedang di-generate...", backgroundColor: Colors.white);
                      },
                      child: const Text("Unduh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  // Dialog Target Kesehatan
  void showTargetDialog() {
    final TextEditingController inputController = TextEditingController();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  shape: BoxShape.circle
                ),
                child: const Icon(Icons.monitor_weight_rounded, color: Color(0xFF2E7D32), size: 32),
              ),
              const SizedBox(height: 20),
              const Text("Target Kesehatan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text("Berapa target berat badan dan batas natrium harian Anda?", 
                style: TextStyle(color: Colors.grey, fontSize: 13), 
                textAlign: TextAlign.center
              ),
              const SizedBox(height: 24),
              TextField(
                controller: inputController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Contoh: 65 kg / 1800 mg",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2E7D32))),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0
                  ),
                  onPressed: () {
                    if (inputController.text.isNotEmpty) {
                      healthTargetText.value = inputController.text;
                      Get.back();
                    }
                  },
                  child: const Text("Simpan Target", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void exportToPDF() {
    showExportDialog();
  }

  // Dialog Edit Profil
  void showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(text: name.value);
    final TextEditingController ageController = TextEditingController(text: age.value.toString());

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Edit Profil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              
              // Foto Profil Avatar (Interaktif)
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_rounded, color: Color(0xFF2E7D32), size: 50),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Input Nama
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.badge_rounded, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2E7D32))),
                ),
              ),
              const SizedBox(height: 16),

              // Input Usia
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Usia (Tahun)",
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.cake_rounded, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2E7D32))),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) name.value = nameController.text;
                    if (ageController.text.isNotEmpty) age.value = int.tryParse(ageController.text) ?? age.value;
                    Get.back();
                    Get.snackbar("Tersimpan", "Profil berhasil diperbarui", backgroundColor: Colors.white);
                  },
                  child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void deleteAccount() {
    Get.defaultDialog(
      title: "Hapus Akun",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      middleText: "Apakah Anda yakin ingin menghapus akun secara permanen? Semua data medis dan riwayat akan hilang dan tidak dapat dipulihkan.",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.black87,
      onConfirm: () async {
        try {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Delete user data in firestore (optional but good practice)
            await FirebaseFirestore.instance.collection('mobile').doc(user.uid).delete();
            // Delete the auth user
            await user.delete();
            Get.offAllNamed(Routes.LOGIN);
            Get.snackbar("Berhasil", "Akun Anda telah dihapus secara permanen.", backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
          }
        } catch (e) {
          Get.back();
          Get.snackbar("Gagal", "Silakan login ulang terlebih dahulu sebelum menghapus akun.", backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
        }
      },
    );
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
