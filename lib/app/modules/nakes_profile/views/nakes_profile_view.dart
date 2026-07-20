import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/nakes_profile_controller.dart';

class NakesProfileView extends GetView<NakesProfileController> {
  const NakesProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NakesProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 32,
              left: 32,
              right: 32,
              bottom: 32,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  right: -40,
                  top: -20,
                  child: Icon(
                    Icons.medical_information,
                    size: 160,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),

                Column(
                    children: [
                      Obx(
                        () {
                          final bool hasImage = controller.imageBytes.value != null && controller.imageBytes.value!.isNotEmpty;
                          return CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white24,
                            backgroundImage: hasImage
                                ? MemoryImage(controller.imageBytes.value!)
                                : null,
                            onBackgroundImageError: hasImage ? (exception, stackTrace) {} : null,
                            child: !hasImage
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 64,
                                  )
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => Text(
                          controller.nakesName.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Text(
                          controller.nakesEmail.value,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: controller.showBarcodeDialog,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2E7D32).withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Color(0xFF2E7D32),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Barcode Akses",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Tampilkan untuk dipindai oleh Pasien",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Akun',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                        _buildProfileOption(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profil',
                          subtitle: 'Ubah data diri dan informasi dasar',
                          color: const Color(0xFF2196F3),
                          onTap: () => Get.toNamed(Routes.NAKES_EDIT_PROFILE),
                        ),
                        Divider(height: 1, indent: 56, color: Colors.grey.withOpacity(0.2)),
                        _buildProfileOption(
                          icon: Icons.security_rounded,
                          title: 'Ganti Kata Sandi',
                          subtitle: 'Perbarui kata sandi Anda',
                          color: const Color(0xFFFF9800),
                          onTap: () => Get.toNamed(Routes.NAKES_GANTI_KATA_SANDI),
                        ),
                        Divider(height: 1, indent: 56, color: Colors.grey.withOpacity(0.2)),
                        _buildProfileOption(
                          icon: Icons.notifications_active_rounded,
                          title: 'Notifikasi',
                          subtitle: 'Pengaturan notifikasi pesan dan pengingat',
                          color: const Color(0xFF2E7D32),
                          trailing: Obx(
                            () => Switch(
                              value: controller.isNotificationEnabled.value,
                              onChanged: (value) => controller.toggleNotification(value),
                              activeColor: const Color(0xFF2E7D32),
                              activeTrackColor: const Color(0xFF2E7D32).withOpacity(0.3),
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          onTap: () {
                            controller.toggleNotification(!controller.isNotificationEnabled.value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Umum',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                        _buildProfileOption(
                          icon: Icons.info_outline_rounded,
                          title: 'Tentang Aplikasi',
                          subtitle: 'Informasi versi & detail aplikasi',
                          color: const Color(0xFF9C27B0),
                          onTap: () => Get.toNamed(Routes.NAKES_TENTANG_APLIKASI),
                        ),
                        Divider(height: 1, indent: 56, color: Colors.grey.withOpacity(0.2)),
                        _buildProfileOption(
                          icon: Icons.help_outline_rounded,
                          title: 'Bantuan/FAQ',
                          subtitle: 'Panduan penggunaan aplikasi',
                          color: const Color(0xFF00BCD4),
                          onTap: () => Get.toNamed(Routes.NAKES_BANTUAN_FAQ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Lainnya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                        _buildProfileOption(
                          icon: Icons.logout_rounded,
                          title: 'Keluar',
                          subtitle: 'Akhiri sesi Anda',
                          color: const Color(0xFFF44336),
                          onTap: () {
                            controller.logout();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
                ], // close Expanded's Column children
              ), // close Expanded's Column
            ), // close SingleChildScrollView
          ), // close Expanded
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ?? Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
