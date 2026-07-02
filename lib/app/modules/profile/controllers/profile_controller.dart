import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class ProfileController extends GetxController {
  final RxString name = "Pengguna".obs;
  final RxInt age = 28.obs;
  final RxString bloodPressure = "120/80".obs;
  final RxInt totalNatrium = 0.obs;

  final RxBool isNotificationEnabled = false.obs;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final RxString healthTargetText = "".obs;

  final RxString photoBase64 = "".obs;
  final RxString beratBadan = "Belum ada".obs;
  final RxString tinggiBadan = "Belum ada".obs;
  final RxString kondisiKesehatan = "Belum ada".obs;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
    fetchUserData();
  }

  void fetchUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.find<AuthService>().getUserReference(user.uid).snapshots().listen((
        doc,
      ) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          name.value = data['name'] ?? data['nama'] ?? user.displayName ?? "Pengguna";
          totalNatrium.value =
              (data['natrium'] as num?)?.toInt() ??
              (data['sodium'] as num?)?.toInt() ??
              (data['totalNatrium'] as num?)?.toInt() ??
              0;
          age.value = data['age'] ?? data['usia'] ?? 28;
          photoBase64.value = data['photoBase64'] ?? data['strImageBase64'] ?? '';
          beratBadan.value = data['berat_badan']?.toString() ?? 'Belum ada';
          tinggiBadan.value = data['tinggi_badan']?.toString() ?? 'Belum ada';
          kondisiKesehatan.value = data['kondisi'] ?? data['kondisi_kesehatan'] ?? 'Belum ada';

          // Format dailyLimit to int string correctly
          if (data['dailyLimit'] != null) {
            double limit = (data['dailyLimit'] as num).toDouble();
            healthTargetText.value = limit.toInt().toString();
          } else {
            healthTargetText.value = "2000";
          }

          bloodPressure.value = data['tekanan_darah'] ?? data['tensi'] ?? "Belum ada";
        }
      });

      // Data natrium sudah diambil dari userReference (koleksi pasien)
      // Blok kode sebelumnya yang menjumlahkan dari 'label gizi makanan' dihapus
      // sesuai permintaan agar membaca langsung dari data 'natrium' di sub collection pasien.
    }
  }

  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
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
      body =
          'Asupan natrium Anda ($current mg) telah melebihi batas harian (${limit.toInt()} mg). Kurangi makanan asin!';
    } else if (current >= limit * 0.8) {
      title = 'Perhatian! Hampir Mencapai Batas';
      body =
          'Asupan natrium ($current mg) mendekati batas harian (${limit.toInt()} mg).';
    } else {
      title = 'Status Natrium Aman ✅';
      body =
          'Asupan Anda ($current mg) masih dalam batas aman hari ini (${limit.toInt()} mg).';
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'gativa_limit_channel',
          'Peringatan Batas Natrium',
          channelDescription: 'Notifikasi jika melewati batas asupan',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

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
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ekspor Laporan Medis",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Pilih rentang tanggal untuk laporan dokter Anda.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.date_range_rounded, color: Colors.white),
                label: const Text(
                  "Pilih Rentang Tanggal",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onPressed: () async {
                  if (Get.context == null) return;

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
              ),
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
              const Text(
                "Dokumen Pendukung",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pilih data yang ingin disertakan di dalam PDF:",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),

              Obx(
                () => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF2E7D32),
                  title: const Text(
                    "Data Asupan Harian",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  value: checkHarian.value,
                  onChanged: (val) => checkHarian.value = val ?? false,
                ),
              ),
              Obx(
                () => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF2E7D32),
                  title: const Text(
                    "Grafik Tren Mingguan",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  value: checkGrafik.value,
                  onChanged: (val) => checkGrafik.value = val ?? false,
                ),
              ),
              Obx(
                () => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF2E7D32),
                  title: const Text(
                    "Kesimpulan Sistem",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  value: checkKesimpulan.value,
                  onChanged: (val) => checkKesimpulan.value = val ?? false,
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          "Mengunduh",
                          "Laporan PDF sedang di-generate...",
                          backgroundColor: Colors.white,
                        );
                      },
                      child: const Text(
                        "Unduh",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monitor_weight_rounded,
                  color: Color(0xFF2E7D32),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Target Kesehatan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                "Berapa target berat badan dan batas natrium harian Anda?",
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: inputController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: "Contoh: 65 kg / 1800 mg",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.normal,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (inputController.text.isNotEmpty) {
                      healthTargetText.value = inputController.text;
                      Get.back();
                    }
                  },
                  child: const Text(
                    "Simpan Target",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
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

  void confirmLogout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Watermark Icon
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  Icons.shield_outlined,
                  size: 150,
                  color: const Color(0xFF2E7D32).withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Keluar Akun?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Apakah Anda yakin ingin keluar dari GATIVA? Anda harus login kembali untuk mengakses data kesehatan Anda.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            onPressed: () => Get.back(),
                            child: const Text(
                              "Batal",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: Colors.red.withOpacity(0.5),
                            ),
                            onPressed: () async {
                              Get.back(); // tutup dialog
                              await FirebaseAuth.instance.signOut();
                              Get.offAllNamed(Routes.LOGIN);
                            },
                            child: const Text(
                              "Keluar",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
