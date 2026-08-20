import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import '../../../widgets/custom_popup.dart';

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

  double get usagePercentage {
    if (dailyLimit <= 0) return consumedSodium > 0 ? 1.0 : 0.0;
    return consumedSodium / dailyLimit;
  }

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
  final RxBool isCreatingInvite = false.obs;
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
    _makananSub?.cancel();
    _anggotaSub?.cancel();
    _userSub?.cancel();
    for (var sub in _memberFoodSubs.values) {
      sub.cancel();
    }
    _memberFoodSubs.clear();
    super.onClose();
  }

  StreamSubscription? _makananSub;
  StreamSubscription? _anggotaSub;
  StreamSubscription? _userSub;
  final Map<String, StreamSubscription> _memberFoodSubs = {};

  double _myTodaySodium = 0.0;
  double _myDailyLimit = 1500.0;
  String _myName = "Pemilik";
  List<AnggotaMember> _otherMembers = [];

  void _updateMembersUI(String uid) {
    List<AnggotaMember> members = [];
    members.add(
      AnggotaMember(
        id: uid,
        name: "$_myName (Saya)",
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

    // 2. Listen to today's food logs for real-time sodium sum from 'pasien'
    _makananSub = FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('pasien')
        .doc(user.uid)
        .collection('label gizi makanan')
        .snapshots()
        .listen((snapshot) {
      double total = 0;
      final now = DateTime.now();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        DateTime? docDate = (data['created_at'] as Timestamp?)?.toDate() ?? (data['timestamp'] as Timestamp?)?.toDate();
        if (docDate != null && docDate.year == now.year && docDate.month == now.month && docDate.day == now.day) {
          total += ((data['natrium'] ?? data['sodium'] ?? data['amount'] ?? 0) as num).toDouble();
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
        
        // Mulai listen ke data gizi aktual member di subcollection pasien
        if (!_memberFoodSubs.containsKey(doc.id)) {
          _memberFoodSubs[doc.id] = FirebaseFirestore.instance
              .collection('mobile')
              .doc('roles')
              .collection('pasien')
              .doc(doc.id)
              .collection('label gizi makanan')
              .snapshots()
              .listen((foodSnap) {
            double memberTotal = 0;
            final n = DateTime.now();
            for (var fDoc in foodSnap.docs) {
              final fData = fDoc.data();
              DateTime? dDate = (fData['created_at'] as Timestamp?)?.toDate() ?? (fData['timestamp'] as Timestamp?)?.toDate();
              if (dDate != null && dDate.year == n.year && dDate.month == n.month && dDate.day == n.day) {
                memberTotal += ((fData['natrium'] ?? fData['sodium'] ?? fData['amount'] ?? 0) as num).toDouble();
              }
            }
            // Update nilai consumedSodium di list _otherMembers
            int index = _otherMembers.indexWhere((m) => m.id == doc.id);
            if (index != -1) {
              _otherMembers[index] = AnggotaMember(
                id: _otherMembers[index].id,
                name: _otherMembers[index].name,
                role: _otherMembers[index].role,
                consumedSodium: memberTotal,
                dailyLimit: _otherMembers[index].dailyLimit,
                avatarUrl: _otherMembers[index].avatarUrl,
              );
              _updateMembersUI(user.uid);
            }
          });
        }

        int age = data['age'] ?? 28;
        String condition = data['kondisi_kesehatan'] ?? data['kondisi'] ?? 'Sehat';
        double calculatedLimit = calculateDailyLimit(age, condition);

        return AnggotaMember(
          id: doc.id,
          name: data['name'] ?? "Unknown",
          role: "Anggota Keluarga",
          consumedSodium: (data['sodiumConsumed'] ?? 0).toDouble(), // Nilai sementara sebelum listener makanan terpanggil
          dailyLimit: (data['limit'] ?? calculatedLimit).toDouble(),
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

  String _generateInviteToken() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<String?> generateQRInvite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomPopup.showWarning(
        "Belum Masuk",
        "Silakan masuk terlebih dahulu untuk membuat undangan.",
      );
      return null;
    }

    isCreatingInvite.value = true;

    try {
      final token = _generateInviteToken();

      // Simpan ke sub-collection anggota (sebelumnya mobile) dengan dataType Invite
      final inviteDocData = {
        'dataType': 'Invite',
        'token': token,
        'ownerUid': user.uid,
        'ownerName': currentUserName,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await Get.find<AuthService>()
          .getUserReference(user.uid)
          .collection('anggota')
          .doc(token)
          .set(inviteDocData);

      // Simpan juga ke root collection 'invites' untuk lookup tanpa CollectionGroup Index
      await FirebaseFirestore.instance
          .collection('invites')
          .doc(token)
          .set(inviteDocData);

      // Hapus otomatis setelah 20 detik
      Future.delayed(const Duration(seconds: 20), () async {
        try {
          await Get.find<AuthService>()
              .getUserReference(user.uid)
              .collection('anggota')
              .doc(token)
              .delete();
          await FirebaseFirestore.instance.collection('invites').doc(token).delete();
        } catch (e) {
          debugPrint("Gagal menghapus token invite otomatis: $e");
        }
      });

      // Embed owner ID and token in the QR code
      final qrData = "GATIVA_INVITE:${user.uid}:$token";
      return qrData;
    } catch (e) {
      CustomPopup.showError("Undangan Gagal", "Gagal membuat barcode undangan.");
      return null;
    } finally {
      isCreatingInvite.value = false;
    }
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
          int age = data['age'] ?? 28;
          String condition = data['kondisi_kesehatan'] ?? data['kondisi'] ?? 'Sehat';
          memberLimit = calculateDailyLimit(age, condition);
          memberConsumed = (data['natrium'] ?? data['sodium'] ?? data['totalNatrium'] ?? 0).toDouble();
          memberLimit = (data['dailyLimit'] ?? memberLimit).toDouble();
        }
      }

      // Get owner's (current user) real data
      final ownerDoc = await Get.find<AuthService>().getUserReference(user.uid).get();
      double ownerConsumed = 0;
      double ownerLimit = 2000;
      if (ownerDoc.exists) {
        final data = ownerDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          int age = data['age'] ?? 28;
          String condition = data['kondisi_kesehatan'] ?? data['kondisi'] ?? 'Sehat';
          ownerLimit = calculateDailyLimit(age, condition);
          ownerConsumed = (data['natrium'] ?? data['sodium'] ?? data['totalNatrium'] ?? 0).toDouble();
          ownerLimit = (data['dailyLimit'] ?? ownerLimit).toDouble();
        }
      }

      String memberRole = request.role; // e.g. "Anggota Keluarga"
      String ownerRole = 'Anggota Keluarga';

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

      CustomPopup.showSuccess('Berhasil', '${request.name} telah bergabung ke anggota Anda.');
    } catch (e) {
      CustomPopup.showError('Error', 'Gagal menyetujui permintaan.');
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
      CustomPopup.showError('Error', 'Gagal menolak permintaan.');
    }
  }

  void sendReminder(AnggotaMember member) async {
    isSendingReminder[member.id] = true;

    try {
      // Save notification to the member's notifikasi subcollection
      await Get.find<AuthService>()
          .getUserReference(member.id)
          .collection('notifikasi')
          .add({
        'title': 'Pengingat dari ${_myName}',
        'message': 'Halo ${member.name}, jangan lupa perhatikan batas konsumsi garam kamu hari ini!',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'pengingat',
      });

      isSendingReminder[member.id] = false;

      // Bergetar dan notifikasi lokal "seperti gamifikasi" sebagai feedback sukses mengirim
      NotificationService.showNotification(
        id: member.id.hashCode,
        title: "Pengingat Terkirim! 🔔",
        body: "Notifikasi berhasil dikirim ke ${member.name}.",
      );

      CustomPopup.showSuccess(
        "Pengingat Terkirim",
        "Notifikasi telah dikirimkan ke ${member.name} untuk menjaga pola makannya.",
      );
    } catch (e) {
      isSendingReminder[member.id] = false;
      CustomPopup.showError(
        "Gagal",
        "Gagal mengirim pengingat ke ${member.name}.",
      );
    }
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

      CustomPopup.showSuccess('Berhasil', '${member.name} telah dihapus dari anggota.');
    } catch (e) {
      CustomPopup.showError('Error', 'Gagal menghapus ${member.name}.');
    }
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
  
  final TextEditingController accessCodeController = TextEditingController();
  
  void showManualInputDialog() {
    accessCodeController.clear();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Transform.rotate(
                angle: 0.2,
                child: Icon(
                  Icons.password_rounded,
                  size: 140,
                  color: Colors.green.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kode Akses",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ketikkan 8 digit kode akses yang diberikan oleh pemilik anggota untuk bergabung.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: accessCodeController,
                    maxLength: 8,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Contoh: H2G9J8XQ',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 0,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      counterText: "",
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("Batal", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            validateAccessCode();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text("Gabung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      barrierDismissible: true,
    );
  }

  void validateAccessCode() async {
    final accessCode = accessCodeController.text.trim();
    if (accessCode.isEmpty) {
      CustomPopup.showError("Gagal", "Kode akses tidak boleh kosong.");
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final existingGroup = await Get.find<AuthService>()
            .getUserReference(currentUser.uid)
            .collection('anggota')
            .where('dataType', isEqualTo: 'Anggota')
            .get();

        if (existingGroup.docs.isNotEmpty) {
          Get.back();
          CustomPopup.showError("Gagal", "Anda sudah bergabung dengan anggota lain. Tidak bisa bergabung lagi.");
          return;
        }
      }

      final doc = await FirebaseFirestore.instance
          .collection('invites')
          .doc(accessCode)
          .get();

      if (!doc.exists) {
        Get.back();
        CustomPopup.showError("Gagal", "Kode Akses tidak ditemukan atau sudah tidak berlaku.");
        return;
      }

      final inviteData = doc.data()!;
      final String ownerUid = inviteData['ownerUid'];
      final String token = inviteData['token'];

      Get.back(); // close loading dialog
      
      _processInviteData(ownerUid, token);
    } catch (e) {
      Get.back();
      CustomPopup.showError("Gagal", "Terjadi kesalahan. Silakan hubungi admin.");
    }
  }

  void _processInviteData(String ownerUid, String token) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final doc = await Get.find<AuthService>()
          .getUserReference(ownerUid)
          .collection('anggota')
          .doc(token)
          .get();

      Get.back(); // Tutup loading

      if (!doc.exists) {
        CustomPopup.showError("Gagal", "Undangan tidak ditemukan atau sudah digunakan.");
        return;
      }

      final inviteData = doc.data() as Map<String, dynamic>? ?? {};
      final String ownerName = inviteData['ownerName'] ?? "Pengguna";

      // Fetch owner's limit
      double ownerSodium = 0;
      double ownerLimit = 2000;
      final ownerDoc = await Get.find<AuthService>().getUserReference(ownerUid).get();
      if (ownerDoc.exists) ownerLimit = ((ownerDoc.data() as Map<String, dynamic>?)?['dailyLimit'] ?? 2000).toDouble();

      // Fetch scanner's limit
      double scannerSodium = 0;
      double scannerLimit = 2000;
      if (currentUser != null) {
        final scannerDoc = await Get.find<AuthService>().getUserReference(currentUser.uid).get();
        if (scannerDoc.exists) scannerLimit = ((scannerDoc.data() as Map<String, dynamic>?)?['dailyLimit'] ?? 2000).toDouble();
      }

      _showConfirmationDialog(ownerName, ownerUid, token, ownerSodium, ownerLimit, scannerSodium, scannerLimit);
    } catch (e) {
      Get.back();
      CustomPopup.showError("Gagal", "Terjadi kesalahan saat memeriksa undangan.");
    }
  }

  void _showConfirmationDialog(
    String ownerName,
    String ownerUid,
    String token,
    double ownerSodium,
    double ownerLimit,
    double scannerSodium,
    double scannerLimit,
  ) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.15),
                blurRadius: 40,
                offset: const Offset(0, 12),
              )
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.green.withOpacity(0.15), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -40,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.group_add_rounded,
                    size: 200,
                    color: Colors.green.withOpacity(0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade300, Colors.teal.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.group_add_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Undangan Ditemukan",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Anda diundang oleh $ownerName untuk bergabung ke anggota pantauan natriumnya.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                                child: Icon(Icons.person_outline_rounded, size: 18, color: Colors.blue.shade700),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(ownerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                              Text("${ownerLimit.toInt()} mg", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.blue)),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                                child: Icon(Icons.person_rounded, size: 18, color: Colors.green.shade700),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: Text("Batas Anda", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                              Text("${scannerLimit.toInt()} mg", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "pemilik anggota juga harus menerima permintaan Anda.",
                              style: TextStyle(fontSize: 12, color: Colors.orange.shade900, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text("Batal", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              _joinGroup(ownerUid, token);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00796B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                              shadowColor: Colors.teal.withOpacity(0.3),
                            ),
                            child: const Text("Setujui", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      barrierDismissible: false,
    );
  }

  Future<void> _joinGroup(String ownerUid, String token) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      CustomPopup.showError("Gagal", "Anda harus masuk untuk bergabung.");
      return;
    }

    if (currentUser.uid == ownerUid) {
      CustomPopup.showError("Gagal", "Anda tidak bisa bergabung ke anggota Anda sendiri.");
      return;
    }

    try {
      await Get.find<AuthService>()
          .getUserReference(ownerUid)
          .collection('group_requests')
          .doc(currentUser.uid)
          .set({
            'uid': currentUser.uid,
            'name': currentUser.displayName ?? 'Pengguna',
            'email': currentUser.email,
            'status': 'pending',
            'role': 'Anggota Keluarga',
            'timestamp': FieldValue.serverTimestamp(),
          });

      // Hapus token undangan
      await Get.find<AuthService>()
          .getUserReference(ownerUid)
          .collection('anggota')
          .doc(token)
          .delete();
      await FirebaseFirestore.instance.collection('invites').doc(token).delete();

      CustomPopup.showSuccess("Permintaan Terkirim", "Permintaan bergabung telah dikirim ke pemilik anggota. Silakan tunggu persetujuannya.");
      accessCodeController.clear();
    } catch (e) {
      CustomPopup.showError("Gagal", "Gagal mengirim permintaan bergabung.");
    }
  }
}
