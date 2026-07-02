import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import '../../../services/auth_service.dart';

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

class GroupRequest {
  final String id;
  final String name;
  final String status;

  GroupRequest({required this.id, required this.name, required this.status});
}

class AnggotaController extends GetxController {
  final RxList<AnggotaMember> AnggotaMembers = <AnggotaMember>[].obs;
  final RxList<GroupRequest> pendingRequests = <GroupRequest>[].obs;
  final RxMap<String, bool> isSendingReminder = <String, bool>{}.obs;
  final RxList<Map<String, String>> discoveredDevices =
      <Map<String, String>>[].obs;
  final RxBool isScanningDevices = false.obs;
  final RxBool isCreatingInvite = false.obs;

  final Strategy strategy = Strategy.P2P_STAR;
  static const MethodChannel _shareChannel = MethodChannel('gativa/share');
  static const String inviteBaseUrl = 'https://gativa.app/invite';
  static const String appDownloadUrl =
      'https://play.google.com/store/apps/details?id=com.example.gativa';

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
      var userDoc = await Get.find<AuthService>()
          .getUserReference(user.uid)
          .get();
      if (userDoc.exists) {
        currentUserName =
            (userDoc.data() as Map<String, dynamic>?)?['name'] ?? "Anggota";
      }

      Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('anggota')
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

      // Dengarkan group_requests (pending requests)
      Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('group_requests')
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen((snapshot) {
            pendingRequests.value = snapshot.docs.map((doc) {
              final data = doc.data();
              return GroupRequest(
                id: doc.id,
                name: data['name'] ?? 'Unknown',
                status: data['status'] ?? 'pending',
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

      // Mulai discovery, radar akan terus berputar hingga dihentikan atau menampilkan list jika ada yang ditemukan
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

  Future<String?> generateQRInvite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        "Belum Masuk",
        "Silakan masuk terlebih dahulu untuk membuat undangan.",
      );
      return null;
    }

    isCreatingInvite.value = true;

    try {
      final token = _generateInviteToken();

      // Simpan ke sub-collection anggota (sebelumnya mobile) dengan dataType Invite
      await Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('anggota')
          .doc(token)
          .set({
            'dataType': 'Invite',
            'token': token,
            'ownerUid': user.uid,
            'ownerName': currentUserName,
            'status': 'active',
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Hapus otomatis setelah 20 detik
      Future.delayed(const Duration(seconds: 20), () async {
        try {
          await Get.find<AuthService>()
              .getUserReference(user.uid)
              .collection('anggota')
              .doc(token)
              .delete();
        } catch (e) {
          debugPrint("Gagal menghapus token invite otomatis: $e");
        }
      });

      // Embed owner ID and token in the QR code
      final inviteData = "GATIVA_INVITE:${user.uid}:$token";
      return inviteData;
    } catch (e) {
      Get.snackbar("Undangan Gagal", "Gagal membuat barcode undangan.");
      return null;
    } finally {
      isCreatingInvite.value = false;
    }
  }

  void requestConnection(String endpointId, String endpointName) {
    Nearby().requestConnection(
      currentUserName,
      endpointId,
      onConnectionInitiated: (id, info) {
        // Harus disetujui manual (Hak Akses Privat)
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
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
                    child: Icon(
                      Icons.security_rounded,
                      color: Colors.orange.shade700,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Hak Akses Privat",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$endpointName mencoba bergabung ke grup Anda. Dengan menyetujui, $endpointName dapat melihat data pantauan natrium harian Anda. Apakah Anda menyetujui?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Nearby().rejectConnection(id);
                            Get.back();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            "Tolak",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            Nearby().acceptConnection(
                              id,
                              onPayLoadRecieved: (endid, payload) {},
                              onPayloadTransferUpdate:
                                  (endid, payloadTransferUpdate) {},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Setujui",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
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
        } else if (status == Status.REJECTED) {
          Get.snackbar("Ditolak", "Koneksi ditolak.");
        }
      },
      onDisconnected: (id) {},
    );
  }

  Future<void> acceptRequest(GroupRequest request) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. Update status di group_requests
      await Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('group_requests')
          .doc(request.id)
          .update({'status': 'approved'});

      // 2. Tambahkan member ke sub-collection anggota owner
      await Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('anggota')
          .doc(request.id)
          .set({
            'dataType': 'Anggota',
            'name': request.name,
            'role': 'Anggota Keluarga',
            'sodiumConsumed': 0, // Nilai default, nantinya bisa disinkronkan
            'limit': 2000,
            'joinedAt': FieldValue.serverTimestamp(),
          });

      // 3. Tambahkan owner ke sub-collection anggota member agar member juga bisa melihat
      await Get.find<AuthService>()
          .getUserReference(request.id)
          .collection('anggota')
          .doc(user.uid)
          .set({
            'dataType': 'Anggota',
            'name': currentUserName,
            'role': 'Pemilik Grup',
            'sodiumConsumed': 0,
            'limit': 2000,
            'joinedAt': FieldValue.serverTimestamp(),
          });

      Get.snackbar('Berhasil', '${request.name} telah bergabung ke grup Anda.');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyetujui permintaan.');
    }
  }

  Future<void> rejectRequest(GroupRequest request) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('group_requests')
          .doc(request.id)
          .update({'status': 'rejected'});
    } catch (e) {
      Get.snackbar('Error', 'Gagal menolak permintaan.');
    }
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
