import 'dart:async';
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
  final String role;

  GroupRequest({required this.id, required this.name, required this.status, this.role = 'Anggota Keluarga'});
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

  StreamSubscription? _makananSub;
  StreamSubscription? _anggotaSub;
  StreamSubscription? _userSub;

  double _myTodaySodium = 0.0;
  double _myDailyLimit = 1500.0;
  String _myName = "Pemilik";
  List<AnggotaMember> _otherMembers = [];

  void _updateMembersUI(String uid) {
    List<AnggotaMember> members = [];
    members.add(
      AnggotaMember(
        id: uid,
        name: _myName + " (Saya)",
        role: "Pemilik Grup",
        consumedSodium: _myTodaySodium,
        dailyLimit: _myDailyLimit,
        avatarUrl: _myName.isNotEmpty ? _myName[0].toUpperCase() : "P",
      )
    );
    members.addAll(_otherMembers);
    AnggotaMembers.value = members;
  }

  void fetchAnggotaData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    // 1. Listen to user profile for dailyLimit and name
    _userSub = Get.find<AuthService>()
        .getUserReference(user.uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _myName = data['name'] ?? user.displayName ?? "Pemilik";
        _myDailyLimit = (data['dailyLimit'] ?? 1500).toDouble();
        currentUserName = _myName;
        _updateMembersUI(user.uid);
      }
    });

    // 2. Listen to today's food logs for real-time sodium sum
    _makananSub = Get.find<AuthService>()
        .getUserReference(user.uid)
        .collection('label gizi makanan')
        .snapshots()
        .listen((snapshot) {
      double total = 0;
      final now = DateTime.now();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        DateTime? docDate = (data['created_at'] as Timestamp?)?.toDate() ?? (data['timestamp'] as Timestamp?)?.toDate();
        if (docDate != null && docDate.year == now.year && docDate.month == now.month && docDate.day == now.day) {
          total += (data['natrium'] ?? data['sodium'] ?? 0).toDouble();
        }
      }
      _myTodaySodium = total;
      _updateMembersUI(user.uid);
    });

    // 3. Listen to other members in the group
    _anggotaSub = Get.find<AuthService>()
        .getUserReference(user.uid)
        .collection('anggota')
        .where('dataType', isEqualTo: 'Anggota')
        .snapshots()
        .listen((snapshot) {
      _otherMembers = snapshot.docs.map((doc) {
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
      _updateMembersUI(user.uid);
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
                role: data['role'] ?? 'Anggota Keluarga',
              );
            }).toList();
          });
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
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            elevation: 10,
            child: Stack(
              children: [
                // Watermark Icon
                Positioned(
                  right: -40,
                  bottom: -40,
                  child: Icon(
                    Icons.security_rounded,
                    size: 180,
                    color: Colors.orange.withOpacity(0.05),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade100, Colors.orange.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.security_rounded,
                          color: Colors.orange.shade700,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Hak Akses Privat",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "$endpointName mencoba bergabung ke grup Anda. Dengan menyetujui, $endpointName dapat melihat data pantauan natrium harian Anda. Apakah Anda menyetujui?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Nearby().rejectConnection(id);
                                Get.back();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                                backgroundColor: const Color(0xFFE65100), // Orange Dark
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
              ],
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

      // Get member's real data
      final memberDoc = await Get.find<AuthService>().getUserReference(request.id).get();
      double memberConsumed = 0;
      double memberLimit = 2000;
      if (memberDoc.exists) {
        final data = memberDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          memberConsumed = (data['natrium'] ?? data['sodium'] ?? data['totalNatrium'] ?? 0).toDouble();
          memberLimit = (data['dailyLimit'] ?? 2000).toDouble();
        }
      }

      // Get owner's (current user) real data
      final ownerDoc = await Get.find<AuthService>().getUserReference(user.uid).get();
      double ownerConsumed = 0;
      double ownerLimit = 2000;
      if (ownerDoc.exists) {
        final data = ownerDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          ownerConsumed = (data['natrium'] ?? data['sodium'] ?? data['totalNatrium'] ?? 0).toDouble();
          ownerLimit = (data['dailyLimit'] ?? 2000).toDouble();
        }
      }

      // Role determination
      String memberRole = request.role; // e.g. "Pemilik" or "Anggota Keluarga"
      String ownerRole = memberRole == 'Pemilik' ? 'Anggota Keluarga' : 'Pemilik Grup';

      // 2. Tambahkan member ke sub-collection anggota owner
      await Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('anggota')
          .doc(request.id)
          .set({
            'dataType': 'Anggota',
            'name': request.name,
            'role': memberRole,
            'sodiumConsumed': memberConsumed, 
            'limit': memberLimit,
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
            'role': ownerRole,
            'sodiumConsumed': ownerConsumed,
            'limit': ownerLimit,
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

  Future<void> deleteMember(AnggotaMember member) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Hapus dari sub-collection 'anggota' milik currentUser
      await Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('anggota')
          .doc(member.id)
          .delete();

      // Hapus currentUser dari sub-collection 'anggota' milik member
      await Get.find<AuthService>()
          .getUserReference(member.id)
          .collection('anggota')
          .doc(user.uid)
          .delete();

      Get.snackbar('Berhasil', '${member.name} telah dihapus dari grup.',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus ${member.name}.');
    }
  }
}
