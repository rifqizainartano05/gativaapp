import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/anggota_controller.dart';

class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const textSecondary = Colors.grey;
  static const textPrimary = Colors.black87;
  static const textMuted = Colors.black54;
  static const safe = Colors.green;
  static const warning = Colors.orange;
  static const danger = Colors.red;
  static const glassBorder = Color(0xFFE0E0E0);
}

class AppTheme {
  static BoxDecoration glassBox({required double radius, Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.glassBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class AnggotaView extends StatelessWidget {
  const AnggotaView({super.key});

  void _showInviteOptions(BuildContext context) {
    final controller = Get.find<AnggotaController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pilih Cara Undang",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _InviteOptionTile(
                  icon: Icons.qr_code_2_rounded,
                  title: controller.isCreatingInvite.value
                      ? "Membuat Barcode..."
                      : "Tampilkan Barcode Undangan",
                  subtitle: "Minta anggota memindai layar Anda",
                  onTap: controller.isCreatingInvite.value
                      ? null
                      : () async {
                          Get.back();
                          String? qrData = await controller
                              .generateQRInvite();
                          if (qrData != null && context.mounted) {
                            _showQRDialog(context, qrData);
                          }
                        },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AppColors.glassBorder, height: 1),
                ),
                _InviteOptionTile(
                  icon: Icons.qr_code_scanner_rounded,
                  title: "Pindai Undangan",
                  subtitle: "Gabung ke grup dengan memindai barcode",
                  onTap: () {
                    Get.back();
                    Get.toNamed('/scan-barcode');
                  },
                ),
              ],
            ),
          ),
        ),
        );
      },
    );
  }



  void _showQRDialog(BuildContext context, String qrData) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Barcode Undangan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Minta pengguna lain untuk memindai barcode ini melalui aplikasi.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "TUTUP",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AnggotaController controller = Get.put(AnggotaController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            // Fixed Header Description Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                left: 24,
                right: 24,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.group_rounded,
                        size: 130,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.groups_2_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Grup Pantauan',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Pantau kesehatan dan asupan harian Anggota secara real-time dari satu tempat.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => Text(
                          'ANGGOTA GRUP (${controller.AnggotaMembers.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showInviteOptions(context),
                        icon: const Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 16,
                        ),
                        label: const Text(
                          'Undang',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ],
            ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pending Requests
                    Obx(() {
                      if (controller.pendingRequests.isEmpty)
                        return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Permintaan Bergabung",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...controller.pendingRequests.map((req) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blueGrey.shade50, Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey.withOpacity(0.06),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                                border: Border.all(
                                  color: Colors.blueGrey.shade100,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    // Watermark Icon Premium
                                    Positioned(
                                      right: -15,
                                      top: -15,
                                      child: Transform.rotate(
                                        angle: 0.1,
                                        child: Icon(
                                          Icons.group_add_rounded,
                                          size: 110,
                                          color: Colors.blueGrey.withOpacity(0.04),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.blueGrey.shade300, Colors.blueGrey.shade400],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(color: Colors.blueGrey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                                              ],
                                            ),
                                            child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  req.name,
                                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black87),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Ingin bergabung ke grup",
                                                  style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () => controller.rejectRequest(req),
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                                                  child: Icon(Icons.close_rounded, color: Colors.red.shade600, size: 22),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              InkWell(
                                                onTap: () => controller.acceptRequest(req),
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                                                  child: Icon(Icons.check_rounded, color: Colors.green.shade700, size: 22),
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
                            );
                          }).toList(),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),

                    // Members Cards
                    Obx(() {
                      if (controller.AnggotaMembers.isEmpty) {
                        return const Center(
                          child: Text("Belum ada anggota", style: TextStyle(color: Colors.grey)),
                        );
                      }
                      final members = controller.AnggotaMembers;
                      final pemilik = members.where((m) => m.role.toLowerCase().contains('pemilik')).toList();
                      final anggota = members.where((m) => !m.role.toLowerCase().contains('pemilik')).toList();

                      Widget buildCard(member) {
                        double ratio = member.usagePercentage;
                        Color statusColor = member.statusColor;
                        bool sending =
                            controller.isSendingReminder[member.id] ?? false;

                        IconData statusIcon;
                        if (ratio >= 0.9) {
                          statusIcon =
                              Icons.dangerous_rounded; // Danger (Merah)
                        } else if (ratio >= 0.6) {
                          statusIcon = Icons
                              .warning_amber_rounded; // Waspada (Kuning/Orange)
                        } else {
                          statusIcon =
                              Icons.check_circle_rounded; // Aman (Hijau)
                        }

                        return AnimatedAnggotaCard(
                          member: member,
                          statusColor: statusColor,
                          ratio: ratio,
                          statusIcon: statusIcon,
                          sending: sending,
                          onRemind: () => controller.sendReminder(member),
                          onDelete: member.name.endsWith('(Saya)') ? null : () => controller.deleteMember(member),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: members.map((m) => buildCard(m)).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InviteOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class AnimatedAnggotaCard extends StatefulWidget {
  final dynamic member;
  final Color statusColor;
  final double ratio;
  final IconData statusIcon;
  final bool sending;
  final VoidCallback onRemind;
  final VoidCallback? onDelete;

  const AnimatedAnggotaCard({
    super.key,
    required this.member,
    required this.statusColor,
    required this.ratio,
    required this.statusIcon,
    required this.sending,
    required this.onRemind,
    this.onDelete,
  });

  @override
  State<AnimatedAnggotaCard> createState() => _AnimatedAnggotaCardState();
}

class _AnimatedAnggotaCardState extends State<AnimatedAnggotaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Kecepatan animasi:
    // Hijau (Aman) = Cepat (800ms)
    // Kuning (Waspada) = Pelan (2500ms)
    // Merah (Bahaya) = Flatline (Kecepatan tidak terlalu berpengaruh, buat lambat 3000ms)
    int durationMs = widget.ratio >= 0.9
        ? 3000
        : (widget.ratio >= 0.6 ? 2500 : 800);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..repeat();

    // Otomatis bergetar jika ini adalah card milik sendiri dan statusnya waspada/bahaya
    bool isMe = widget.member.name.contains('(Saya)');
    if (isMe && widget.ratio >= 0.6) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        HapticFeedback.heavyImpact();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDanger = widget.ratio >= 0.9;
    bool isWarning = widget.ratio >= 0.6 && widget.ratio < 0.9;
    bool isSafe = widget.ratio < 0.6;
    bool isMe = widget.member.name.contains('(Saya)');

    Widget remindButton = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.sending ? null : () {
          HapticFeedback.vibrate(); // Getaran asli pada HP
          widget.onRemind();
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDanger 
                ? [Colors.white, Colors.grey.shade100] 
                : [widget.statusColor, widget.statusColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (isDanger ? Colors.white : widget.statusColor).withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Efek watermark icon di dalam tombol
              Positioned(
                right: -5,
                bottom: -5,
                child: Icon(
                  Icons.campaign_rounded,
                  size: 36,
                  color: (isDanger ? widget.statusColor : Colors.white).withOpacity(0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.sending
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDanger ? widget.statusColor : Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.notifications_active_rounded, 
                            size: 16, 
                            color: isDanger ? widget.statusColor : Colors.white,
                          ),
                    const SizedBox(width: 6),
                    Text(
                      'INGATKAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDanger ? widget.statusColor : Colors.white,
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Efek kelap-kelip HANYA untuk waspada dan bahaya
        double glowOpacity = isSafe
            ? 0.0
            : (0.1 + 0.3 * (0.5 - (0.5 - _controller.value).abs()) * 2);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(
              0xFF1E1E1E,
            ), // Warna gelap ala monitor rumah sakit
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.statusColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              // Cahaya neon memancar dari belakang kalau waspada/bahaya
              BoxShadow(
                color: widget.statusColor.withOpacity(glowOpacity),
                blurRadius: isDanger ? 30 : 20,
                spreadRadius: isDanger ? 5 : 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // 1. Konten Utama Card
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.statusColor,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: widget.member.avatarUrl.length == 1
                                  ? Text(
                                      widget.member.avatarUrl,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    )
                                  : ClipOval(
                                      child: Image.network(
                                        widget.member.avatarUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.member.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${widget.member.consumedSodium.toInt()} mg',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: widget.statusColor,
                                ),
                              ),
                              Text(
                                '/ ${widget.member.dailyLimit.toInt()} mg',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: widget.ratio,
                                backgroundColor: Colors.grey[800],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.statusColor,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(widget.ratio * 100).toInt()}%',
                            style: TextStyle(
                              color: widget.statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                widget.statusIcon,
                                color: widget.statusColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Status: ${widget.member.statusText}',
                                style: TextStyle(
                                  color: widget.statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          if (isWarning && !isMe) remindButton,
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Center Warning Icon (Waspada) -> Di Atas Teks tapi Transparan
                if (isWarning)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Icon(
                          widget.statusIcon,
                          size: 100,
                          color: widget.statusColor.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ),

                // 3. Efek Kabut Merah & Icon Solid (Hanya Bahaya/Merah) -> Menutupi Seluruh Teks
                if (isDanger)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.statusColor.withOpacity(0.9), // Efek Kabut Pekat
                        borderRadius: BorderRadius.circular(18), // Agar sudut membulat pas kotak
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.statusIcon,
                              size: 60,
                              color: Colors.white.withOpacity(0.9), // Icon Solid Putih di tengah kabut merah
                            ),
                            const SizedBox(height: 12),
                            if (!isMe) remindButton,
                          ],
                        ),
                      ),
                    ),
                  ),

                // 4. Background EKG Graph
                Positioned.fill(
                  // IgnorePointer agar tombol di bawahnya masih bisa diklik
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: EkgPainter(
                        animationValue: _controller.value,
                        color: isDanger
                            ? Colors.white
                            : widget
                                  .statusColor, // Ubah garis EKG jadi putih jika danger agar kontras
                        isFlatline: isDanger,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EkgPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isFlatline;

  EkgPainter({
    required this.animationValue,
    required this.color,
    this.isFlatline = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Jika bahaya/merah (flatline), opacity 1.0 dan tebal agar BENAR-BENAR MENUTUPI tulisan di bawahnya
    final paint = Paint()
      ..color = color.withOpacity(isFlatline ? 1.0 : 0.2)
      ..strokeWidth = isFlatline ? 6.0 : 2.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    double width = size.width;
    double height = size.height;
    double midY = height / 2 + 10;

    // Pola grafik EKG sepanjang 120 piksel
    double patternWidth = 120.0;

    // Pergeseran posisi X berdasarkan animasi
    double shift = animationValue * patternWidth;

    // Menggambar gelombang yang berulang menutupi lebar container
    // Mulai dari luar layar (-patternWidth) agar transisi pergeseran mulus
    path.moveTo(-patternWidth, midY);

    for (
      double x = -patternWidth;
      x < width + patternWidth;
      x += patternWidth
    ) {
      double currentX = x - shift;

      if (isFlatline) {
        // Meninggal: Garis nyaris datar dengan sedikit fibrilasi/kedutan lemah
        // agar tetap terlihat "berjalan" melintasi layar menutupi tulisan
        path.lineTo(currentX + 40, midY);
        path.lineTo(currentX + 45, midY - 4); // Kedutan sangat lemah ke atas
        path.lineTo(currentX + 50, midY + 4); // Kedutan lemah ke bawah
        path.lineTo(currentX + 55, midY);
        path.lineTo(currentX + patternWidth, midY);
      } else {
        // Hidup: Menggambar 1 siklus PQRST complex normal
        path.lineTo(currentX + 20, midY); // Garis datar

        // Gelombang P
        path.quadraticBezierTo(currentX + 25, midY - 5, currentX + 30, midY);

        path.lineTo(currentX + 40, midY); // Garis datar PR segment

        // Kompleks QRS (lonjakan tinggi)
        path.lineTo(currentX + 45, midY + 10); // Q turun
        path.lineTo(currentX + 55, midY - 40); // R naik tajam
        path.lineTo(currentX + 65, midY + 15); // S turun tajam
        path.lineTo(currentX + 70, midY); // Kembali

        path.lineTo(currentX + 80, midY); // Garis datar ST segment

        // Gelombang T
        path.quadraticBezierTo(currentX + 90, midY - 15, currentX + 100, midY);

        path.lineTo(currentX + 120, midY); // Garis datar ke siklus berikutnya
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant EkgPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.isFlatline != isFlatline;
  }
}
