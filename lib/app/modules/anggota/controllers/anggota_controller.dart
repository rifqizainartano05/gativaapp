import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

class AnggotaMember {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final double consumedSodium;
  final double dailyLimit;

  AnggotaMember({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.consumedSodium,
    required this.dailyLimit,
  });

  double get usagePercentage => consumedSodium / dailyLimit;

  Color get statusColor {
    if (usagePercentage >= 0.9) return Colors.red;
    if (usagePercentage >= 0.6) return Colors.orange;
    return Colors.green;
  }

  String get statusText {
    if (usagePercentage >= 0.9) return "Bahaya";
    if (usagePercentage >= 0.6) return "Waspada";
    return "Aman";
  }
}

class AnggotaController extends GetxController {
  final RxList<AnggotaMember> AnggotaMembers = <AnggotaMember>[].obs;
  final RxMap<String, bool> isSendingReminder = <String, bool>{}.obs;
  final RxList<Map<String, String>> discoveredDevices = <Map<String, String>>[].obs;
  final RxBool isScanningDevices = false.obs;
  final RxBool isCreatingInvite = false.obs;
  
  final Strategy strategy = Strategy.P2P_STAR;
  static const MethodChannel _shareChannel = MethodChannel('garda/share');
  static const String inviteBaseUrl = 'https://garda.app/invite';
  static const String appDownloadUrl = 'https://play.google.com/store/apps/details?id=com.example.garda';

  String currentUserName = "Anggota";

  @override
  void onInit() {
    super.onInit();
    fetchAnggotaData();
  }
  
  @override
  void onClose() {
    Nearby().stopDiscovery();
    super.onClose();
  }

  void fetchAnggotaData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get current user's name for Nearby Display
      var userDoc = await FirebaseFirestore.instance.collection('mobile').doc(user.uid).get();
      if (userDoc.exists) {
        currentUserName = userDoc.data()?['name'] ?? "Anggota";
      }

      FirebaseFirestore.instance
          .collection('mobile')
          .doc(user.uid)
          .collection('mobile')
          .where('dataType', isEqualTo: 'Anggota')
          .snapshots()
          .listen((snapshot) {
        AnggotaMembers.value = snapshot.docs.map((doc) {
          final data = doc.data();
          return AnggotaMember(
            id: doc.id,
            name: data['name'] ?? "Unknown",
            role: data['role'] ?? "Member",
            consumedSodium: (data['sodiumConsumed'] ?? 0).toDouble(),
            dailyLimit: (data['limit'] ?? 2000).toDouble(),
            avatarUrl: (data['name'] ?? "U")[0].toString().toUpperCase(),
          );
        }).toList();
      });
    }
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.nearbyWifiDevices,
    ].request();
    
    return statuses.values.every((status) => status.isGranted);
  }

  void startDiscovery() async {
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      Get.snackbar("Izin Ditolak", "Mohon izinkan lokasi dan bluetooth.");
      return;
    }

    try {
      discoveredDevices.clear();
      isScanningDevices.value = true;

      // Simulate radar scanning delay for UX, even if Nearby starts instantly
      await Future.delayed(const Duration(seconds: 2));
      isScanningDevices.value = false;

      await Nearby().startDiscovery(
        currentUserName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          if (!discoveredDevices.any((d) => d['id'] == id)) {
            discoveredDevices.add({"id": id, "name": name});
          }
        },
        onEndpointLost: (id) {
          discoveredDevices.removeWhere((d) => d['id'] == id);
        },
      );
    } catch (e) {
      isScanningDevices.value = false;
      print("Discovery error: $e");
    }
  }

  void stopDiscovery() {
    isScanningDevices.value = false;
    Nearby().stopDiscovery();
  }

  String _generateInviteToken() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> shareInviteLink() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Belum Masuk", "Silakan masuk terlebih dahulu untuk membuat undangan.");
      return;
    }

    isCreatingInvite.value = true;

    try {
      final token = _generateInviteToken();
      final inviteLink = '$inviteBaseUrl?token=$token';
      final expiresAt = DateTime.now().add(const Duration(days: 7));

      await FirebaseFirestore.instance.collection('group_invites').doc(token).set({
        'token': token,
        'ownerUid': user.uid,
        'ownerName': currentUserName,
        'downloadUrl': appDownloadUrl,
        'inviteLink': inviteLink,
        'accessLevel': 'approval_only',
        'accessLabel': 'Menyetujui saja',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
      });

      final message = '''
$currentUserName mengundang Anda bergabung ke Grup GARDA.

Download aplikasi:
$appDownloadUrl

Link masuk:
$inviteLink

Token masuk: $token
Hak akses: menyetujui saja.
''';

      await Share.share(message, subject: 'Undangan GARDA');
    } catch (e) {
      Get.snackbar("Undangan Gagal", "Coba buat link undangan lagi.");
    } finally {
      isCreatingInvite.value = false;
    }
  }

  void requestConnection(String endpointId, String endpointName) {
    Nearby().requestConnection(
      currentUserName,
      endpointId,
      onConnectionInitiated: (id, info) {
        // Otomatis terima koneksi
        Nearby().acceptConnection(
          id,
          onPayLoadRecieved: (endid, payload) {},
          onPayloadTransferUpdate: (endid, payloadTransferUpdate) {},
        );
      },
      onConnectionResult: (id, status) {
        if (status == Status.CONNECTED) {
          Get.snackbar(
            "Terhubung", 
            "Berhasil mengundang $endpointName ke grup Anda.",
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
          );
        }
      },
      onDisconnected: (id) {},
    );
  }

  void sendReminder(AnggotaMember member) async {
    isSendingReminder[member.id] = true;
    
    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));
    
    isSendingReminder[member.id] = false;

    Get.snackbar(
      "Pengingat Terkirim",
      "Notifikasi telah dikirimkan ke ${member.name} untuk menjaga pola makannya.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2E7D32),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(20),
    );
  }
}
