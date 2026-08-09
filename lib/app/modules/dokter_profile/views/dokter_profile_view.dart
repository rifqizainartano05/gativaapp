import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/dokter_profile_controller.dart';

class DokterProfileView extends GetView<DokterProfileController> {
  const DokterProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DokterProfileController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // White icons for status bar
        systemNavigationBarColor: Colors.white, // White background for navigation bar
        systemNavigationBarIconBrightness: Brightness.dark, // Dark icons for nav bar
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8, // Decreased from +16 to move arrow/text higher up
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
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
                Positioned(
                  top: 12, // Re-adjusted to perfectly align vertically with the center of the back arrow (which is 48px tall)
                  child: const Text(
                    "Profil",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                    children: [
                      const SizedBox(height: 64), // Increased from 48 to create more space between text/arrow and the avatar
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
                          controller.dokterName.value,
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
                          controller.dokterEmail.value,
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
                          color: Colors.black87,
                          onTap: () => Get.toNamed(Routes.DOKTER_EDIT_PROFILE),
                        ),
                        Divider(height: 1, indent: 56, color: Colors.grey.withOpacity(0.2)),
                        _buildProfileOption(
                          icon: Icons.security_rounded,
                          title: 'Ganti Kata Sandi',
                          subtitle: 'Perbarui kata sandi Anda',
                          color: Colors.black87,
                          onTap: () => Get.toNamed(Routes.DOKTER_GANTI_KATA_SANDI),
                        ),
                        Divider(height: 1, indent: 56, color: Colors.grey.withOpacity(0.2)),
                        _buildProfileOption(
                          icon: Icons.notifications_active_rounded,
                          title: 'Notifikasi',
                          subtitle: 'Pengaturan notifikasi pesan dan pengingat',
                          color: Colors.black87,
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
                          color: Colors.black87,
                          onTap: () => Get.toNamed(Routes.DOKTER_TENTANG_APLIKASI),
                        ),
                        Divider(height: 1, indent: 56, color: Colors.grey.withOpacity(0.2)),
                        _buildProfileOption(
                          icon: Icons.help_outline_rounded,
                          title: 'Bantuan/FAQ',
                          subtitle: 'Panduan penggunaan aplikasi',
                          color: Colors.black87,
                          onTap: () => Get.toNamed(Routes.DOKTER_BANTUAN_FAQ),
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
                          color: Colors.black87,
                          onTap: () {
                            controller.logout();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40 + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
                ], // close Expanded's Column children
              ), // close Expanded's Column
            ), // close SingleChildScrollView
          ), // close Expanded
        ],
      ),
    ),
  );
}

  Widget _buildProfileOption({
    required IconData icon,
    Widget? customIcon,
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
              if (customIcon != null)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: customIcon,
                )
              else
                Icon(icon, color: color, size: 24),
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
