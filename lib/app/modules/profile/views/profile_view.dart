import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';

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

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: Column(
          children: [
            _buildTopGreenHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- GRAFIK KONDISI JANTUNG (EKG) ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'STATUS KESEHATAN SAAT INI',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GetX<ProfileController>(
                            builder: (profileCtrl) {
                              double current = profileCtrl.totalNatrium.value
                                  .toDouble();
                              double limit = 2000; // Default limit
                              if (profileCtrl
                                  .healthTargetText
                                  .value
                                  .isNotEmpty) {
                                limit =
                                    double.tryParse(
                                      profileCtrl.healthTargetText.value,
                                    ) ??
                                    2000;
                              }

                              double ratio = limit > 0 ? (current / limit) : 0;
                              Color statusColor;
                              IconData statusIcon;
                              String statusText;

                              if (ratio >= 0.9) {
                                statusColor = AppColors.danger;
                                statusIcon = Icons.dangerous_rounded;
                                statusText = "BAHAYA (Over Limit)";
                              } else if (ratio >= 0.6) {
                                statusColor = AppColors.warning;
                                statusIcon = Icons.warning_amber_rounded;
                                statusText = "WASPADA (Mendekati Limit)";
                              } else {
                                statusColor = AppColors.safe;
                                statusIcon = Icons.check_circle_rounded;
                                statusText = "AMAN (Normal)";
                              }

                              return AnimatedProfileEkgCard(
                                ratio: ratio,
                                statusColor: statusColor,
                                statusIcon: statusIcon,
                                statusText: statusText,
                                currentSodium: current,
                                limitSodium: limit,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PREFERENSI & DATA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.glassBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Obx(() => _buildSimpleMenuTile(
                                  icon: Icons.medical_services_rounded,
                                  title: "Tenaga Kesehatan",
                                  subtitle: controller.nakesName.value == '-' ? "Belum terhubung" : controller.nakesName.value,
                                  onTap: () => controller.showNakesDialog(),
                                )),
                                const Divider(
                                  height: 1,
                                  indent: 56,
                                  color: AppColors.glassBorder,
                                ),
                                _buildSimpleMenuTile(
                                  icon: Icons.person_outline_rounded,
                                  title: "Edit Profil",
                                  subtitle: "Perbarui data diri",
                                  onTap: () =>
                                      Get.toNamed(Routes.EDIT_PROFILE),
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 56,
                                  color: AppColors.glassBorder,
                                ),
                                _buildSimpleMenuTile(
                                  icon: Icons.history_rounded,
                                  title: "Riwayat Login",
                                  subtitle: "Log masuk perangkat",
                                  onTap: () =>
                                      Get.toNamed(Routes.RIWAYAT_LOGIN),
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 56,
                                  color: AppColors.glassBorder,
                                ),
                                _buildSimpleMenuTile(
                                  icon: Icons.assignment_ind_rounded,
                                  title: "Catatan Nakes",
                                  subtitle: "Lihat pesan dari tenaga kesehatan",
                                  onTap: () => Get.toNamed(Routes.CATATAN_NAKES),
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 56,
                                  color: AppColors.glassBorder,
                                ),
                                _buildSimpleMenuTile(
                                  icon: Icons.lock_outline_rounded,
                                  title: "Ganti Kata Sandi",
                                  subtitle: "Perbarui kata sandi Anda",
                                  onTap: () => Get.toNamed(Routes.GANTI_KATA_SANDI),
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 56,
                                  color: AppColors.glassBorder,
                                ),
                                _buildSimpleMenuTile(
                                  icon: Icons.notifications_active_rounded,
                                  title: "Notifikasi Pengingat",
                                  subtitle: "Pengingat selalu aktif",
                                  trailing: const Text(
                                    "Aktif",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    Get.snackbar(
                                      "Info",
                                      "Notifikasi pengingat diatur untuk selalu aktif secara permanen.",
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Text(
                            'LAINNYA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Column(
                              children: [
                                _buildSimpleMenuTile(
                                  icon: Icons.help_outline_rounded,
                                  title: "Bantuan & Dukungan",
                                  subtitle: "FAQ dan kontak kami",
                                  onTap: () => Get.toNamed(Routes.FAQ),
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 56,
                                  color: AppColors.glassBorder,
                                ),
                                _buildSimpleMenuTile(
                                  icon: Icons.info_outline_rounded,
                                  title: "Tentang Aplikasi",
                                  subtitle: "Informasi versi & detail",
                                  onTap: () => Get.toNamed(Routes.TENTANG_APLIKASI),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Text(
                            'AKUN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Column(
                              children: [
                                _buildSimpleMenuTile(
                                  icon: Icons.logout_rounded,
                                  title: "Keluar Akun",
                                  subtitle: "Akhiri sesi saat ini",
                                  textColor: AppColors.danger,
                                  iconColor: AppColors.danger,
                                  onTap: () => controller.confirmLogout(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopGreenHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: 40,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.health_and_safety_rounded,
                size: 280,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Obx(() {
                          if (controller.photoBase64.value.isNotEmpty) {
                            try {
                              return CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.white,
                                backgroundImage: MemoryImage(
                                  const Base64Decoder().convert(
                                    controller.photoBase64.value,
                                  ),
                                ),
                              );
                            } catch (e) {
                              return const CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primary,
                                  size: 45,
                                ),
                              );
                            }
                          }
                          return const CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: 45,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => Text(
                                controller.name.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 26,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(
                              () => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Usia: ${controller.age.value} Tahun",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildInnerStatItem(
                              "Tekanan Darah",
                              controller.bloodPressure.value,
                              Icons.favorite_rounded,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildInnerStatItem(
                              "Target Natrium",
                              "${controller.healthTargetText.value.isNotEmpty ? NumberFormat.decimalPattern('id').format(double.tryParse(controller.healthTargetText.value) ?? 2000) : '2.000'} mg",
                              Icons.track_changes_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerStatItem(String title, String value, IconData icon, {VoidCallback? onTap}) {
    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
        if (value.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (title.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: content,
          ),
        ),
      );
    }
    
    return content;
  }

  Widget _buildSimpleMenuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool hideArrow = false,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.black87, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor ?? AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (!hideArrow)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }
}

class AnimatedProfileEkgCard extends StatefulWidget {
  final double ratio;
  final Color statusColor;
  final IconData statusIcon;
  final String statusText;
  final double currentSodium;
  final double limitSodium;

  const AnimatedProfileEkgCard({
    super.key,
    required this.ratio,
    required this.statusColor,
    required this.statusIcon,
    required this.statusText,
    required this.currentSodium,
    required this.limitSodium,
  });

  @override
  State<AnimatedProfileEkgCard> createState() => _AnimatedProfileEkgCardState();
}

class _AnimatedProfileEkgCardState extends State<AnimatedProfileEkgCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    int durationMs = widget.ratio >= 0.9
        ? 3000
        : (widget.ratio >= 0.6 ? 2500 : 800);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedProfileEkgCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ratio != widget.ratio) {
      int durationMs = widget.ratio >= 0.9
          ? 3000
          : (widget.ratio >= 0.6 ? 2500 : 800);
      _controller.duration = Duration(milliseconds: durationMs);
      if (_controller.isAnimating) {
        _controller.repeat();
      }
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double glowOpacity = isSafe
            ? 0.0
            : (0.1 + 0.3 * (0.5 - (0.5 - _controller.value).abs()) * 2);

        return Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.statusColor.withOpacity(isSafe ? 0.3 : 0.8),
              width: 1.5,
            ),
            boxShadow: [
              if (!isSafe)
                BoxShadow(
                  color: widget.statusColor.withOpacity(glowOpacity),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                widget.statusIcon,
                                color: widget.statusColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.statusText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: widget.statusColor,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${NumberFormat.decimalPattern('id').format(widget.currentSodium.toInt())} mg',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: widget.statusColor,
                                ),
                              ),
                              Text(
                                '/ ${NumberFormat.decimalPattern('id').format(widget.limitSodium.toInt())} mg',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: widget.ratio,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                if (isDanger)
                  Positioned.fill(
                    child: Container(
                      color: widget.statusColor.withOpacity(0.9),
                      child: Center(
                        child: Icon(
                          widget.statusIcon,
                          size: 100,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: ProfileEkgPainter(
                        animationValue: _controller.value,
                        color: isDanger ? Colors.white : widget.statusColor,
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

class ProfileEkgPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isFlatline;

  ProfileEkgPainter({
    required this.animationValue,
    required this.color,
    this.isFlatline = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(isFlatline ? 1.0 : 0.2)
      ..strokeWidth = isFlatline ? 6.0 : 2.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    double width = size.width;
    double height = size.height;
    double midY = height - 40; // Diletakkan agak ke bawah

    double patternWidth = 120.0;
    double shift = animationValue * patternWidth;

    path.moveTo(-patternWidth, midY);

    for (
      double x = -patternWidth;
      x < width + patternWidth;
      x += patternWidth
    ) {
      double currentX = x - shift;

      if (isFlatline) {
        path.lineTo(currentX + 40, midY);
        path.lineTo(currentX + 45, midY - 4);
        path.lineTo(currentX + 50, midY + 4);
        path.lineTo(currentX + 55, midY);
        path.lineTo(currentX + patternWidth, midY);
      } else {
        path.lineTo(currentX + 20, midY);
        path.quadraticBezierTo(currentX + 25, midY - 5, currentX + 30, midY);
        path.lineTo(currentX + 40, midY);
        path.lineTo(currentX + 45, midY + 10);
        path.lineTo(currentX + 55, midY - 40);
        path.lineTo(currentX + 65, midY + 15);
        path.lineTo(currentX + 70, midY);
        path.lineTo(currentX + 80, midY);
        path.quadraticBezierTo(currentX + 90, midY - 15, currentX + 100, midY);
        path.lineTo(currentX + 120, midY);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ProfileEkgPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.isFlatline != isFlatline;
  }
}
