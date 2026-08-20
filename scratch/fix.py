import re

with open(r'd:\SIDANG\aplikasi\gativa\lib\app\modules\gabung_anggota\controllers\gabung_anggota_controller.dart', 'r', encoding='utf-8') as f:
    code = f.read()

start_idx = code.find('void _processScannedData(String data)')
end_idx = code.find('void _showConfirmationDialog(')

if start_idx != -1 and end_idx != -1:
    new_code = '''  void _processScannedData(String data) async {
    if (data.startsWith('GATIVA_INVITE:')) {
      final parts = data.split(':');
      if (parts.length >= 3) {
        final ownerUid = parts[1];
        final token = parts.sublist(2).join(':'); 

        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        try {
          await _processInviteToken(ownerUid, token);
          return;
        } catch (e) {
          Get.back();
          _showErrorDialog("Terjadi kesalahan: $e");
          return;
        }
      }
    }
    _showErrorDialog("Kode barcode tidak valid atau tidak dikenali.");
  }

  void showManualInputDialog() {
    isScanning.value = false;
    scannerController.stop();
    final TextEditingController textController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Masukkan Kode Akses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLength: 8,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: "Contoh: H2G9J8XQ",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        _resumeScanning();
                      },
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // close dialog
                        _processManualToken(textController.text.trim().toUpperCase());
                      },
                      child: const Text("Kirim"),
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
  }

  void _processManualToken(String token) async {
    if (token.isEmpty || token.length < 8) {
      _showErrorDialog("Kode akses tidak valid.");
      _resumeScanning();
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('anggota')
          .where('token', isEqualTo: token)
          .where('dataType', isEqualTo: 'Invite')
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.back();
        _showErrorDialog("Kode akses tidak ditemukan atau sudah kadaluarsa.");
        return;
      }

      final doc = querySnapshot.docs.first;
      final inviteData = doc.data();
      final ownerUid = inviteData['ownerUid'] ?? '';
      
      if (ownerUid.isEmpty) {
        Get.back();
        _showErrorDialog("Data undangan tidak lengkap.");
        return;
      }

      await _processInviteToken(ownerUid, token);
    } catch (e) {
      Get.back();
      _showErrorDialog("Gagal memproses kode manual: $e");
    }
  }

  Future<void> _processInviteToken(String ownerUid, String token) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final existingOwner = await Get.find<AuthService>()
          .getUserReference(currentUser.uid)
          .collection('anggota')
          .where('role', isEqualTo: 'pemilik anggota')
          .get();

      if (existingOwner.docs.isNotEmpty) {
        Get.back(); // Tutup loading
        _showErrorDialog("Anda sudah bergabung di anggota lain. 1 Pengguna hanya bisa bergabung ke 1 Anggota.");
        return;
      }
    }
    
    final doc = await Get.find<AuthService>()
        .getUserReference(ownerUid)
        .collection('anggota')
        .doc(token)
        .get();

    Get.back(); // Tutup loading

    if (!doc.exists) {
      _showErrorDialog("Undangan tidak ditemukan atau sudah digunakan.");
      return;
    }

    final inviteData = doc.data() as Map<String, dynamic>? ?? {};
    final String ownerName = inviteData['ownerName'] ?? "Pengguna";

    // Fetch owner's actual sodium data from 'pasien'
    double ownerSodium = 0;
    double ownerLimit = 2000;
    
    final ownerFoodDoc = await FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('pasien')
        .doc(ownerUid)
        .collection('label gizi makanan')
        .get();
        
    if (ownerFoodDoc.docs.isNotEmpty) {
      double total = 0;
      final now = DateTime.now();
      for (var fDoc in ownerFoodDoc.docs) {
        final fData = fDoc.data();
        DateTime? docDate = (fData['created_at'] as Timestamp?)?.toDate() ?? (fData['timestamp'] as Timestamp?)?.toDate();
        if (docDate != null && docDate.year == now.year && docDate.month == now.month && docDate.day == now.day) {
          total += ((fData['natrium'] ?? fData['sodium'] ?? fData['amount'] ?? 0) as num).toDouble();
        }
      }
      ownerSodium = total;
    }
    final ownerDoc = await Get.find<AuthService>().getUserReference(ownerUid).get();
    if (ownerDoc.exists) ownerLimit = ((ownerDoc.data() as Map<String, dynamic>?)?['dailyLimit'] ?? 2000).toDouble();

    // Fetch scanner's actual sodium data from 'pasien'
    double scannerSodium = 0;
    double scannerLimit = 2000;
    if (currentUser != null) {
      final scannerFoodDoc = await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(currentUser.uid)
          .collection('label gizi makanan')
          .get();
          
      if (scannerFoodDoc.docs.isNotEmpty) {
        double total = 0;
        final now = DateTime.now();
        for (var fDoc in scannerFoodDoc.docs) {
          final fData = fDoc.data();
          DateTime? docDate = (fData['created_at'] as Timestamp?)?.toDate() ?? (fData['timestamp'] as Timestamp?)?.toDate();
          if (docDate != null && docDate.year == now.year && docDate.month == now.month && docDate.day == now.day) {
            total += ((fData['natrium'] ?? fData['sodium'] ?? fData['amount'] ?? 0) as num).toDouble();
          }
        }
        scannerSodium = total;
      }
      final scannerDoc = await Get.find<AuthService>().getUserReference(currentUser.uid).get();
      if (scannerDoc.exists) scannerLimit = ((scannerDoc.data() as Map<String, dynamic>?)?['dailyLimit'] ?? 2000).toDouble();
    }

    _showConfirmationDialog(ownerName, ownerUid, token, ownerSodium, ownerLimit, scannerSodium, scannerLimit);
  }

  '''
    code = code[:start_idx] + new_code + code[end_idx:]
    with open(r'd:\SIDANG\aplikasi\gativa\lib\app\modules\gabung_anggota\controllers\gabung_anggota_controller.dart', 'w', encoding='utf-8') as f:
        f.write(code)
    print('Fixed!')
else:
    print('Could not find indices.')
