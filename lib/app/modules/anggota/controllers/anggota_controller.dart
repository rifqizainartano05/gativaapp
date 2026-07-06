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

        return AnggotaMember(
          id: doc.id,
          name: data['name'] ?? "Unknown",
          role: data['role'] ?? "Member",
          consumedSodium: (data['sodiumConsumed'] ?? 0).toDouble(), // Nilai sementara sebelum listener makanan terpanggil
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

      CustomPopup.showSuccess('Berhasil', '${request.name} telah bergabung ke grup Anda.');
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

      CustomPopup.showSuccess('Berhasil', '${member.name} telah dihapus dari grup.');
    } catch (e) {
      CustomPopup.showError('Error', 'Gagal menghapus ${member.name}.');
    }
  }
}
