import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../controllers/home_administrator_controller.dart';
import '../../../routes/app_pages.dart';

class HomeAdministratorView extends GetView<HomeAdministratorController> {
  const HomeAdministratorView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F6),
        appBar: AppBar(
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: 1.0,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Keluar',
              onPressed: () {
                Get.offAllNamed(Routes.LOGIN);
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_alt_rounded),
                    SizedBox(width: 8),
                    Text('Pasien'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medical_services_rounded),
                    SizedBox(width: 8),
                    Text('Dokter'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPasienView(),
            _buildDokterView(),
          ],
        ),
      ),
    );
  }

  // ================= PASIEN VIEW =================
  Widget _buildPasienView() {
    return Obx(() {
      final pasiens = controller.pasiens;
      if (pasiens.isEmpty) {
        return _buildEmptyState('Tidak ada data pasien yang terdaftar', Icons.group_off_rounded);
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pasiens.length,
        itemBuilder: (context, index) {
          final doc = pasiens[index];
          final String nama = doc['name'] ?? 'Tanpa Nama';
          final String initial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE8F5E9),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              title: Text(
                nama,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doc['email'] ?? '-',
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showEditModal(doc, 'pasien'),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(Icons.edit_outlined, color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _confirmHapus(doc['uid'], 'pasien'),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // ================= DOKTER VIEW =================
  Widget _buildDokterView() {
    return Column(
      children: [
        // Filter Bar yang Indah
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Semua', 'Menunggu', 'Disetujui', 'Ditolak', 'Diblokir'].map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Obx(() {
                    final isSelected = controller.dokterFilter.value == filter;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        showCheckmark: false,
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        onSelected: (selected) {
                          if (selected) controller.dokterFilter.value = filter;
                        },
                      ),
                    );
                  }),
                );
              }).toList(),
            ),
          ),
        ),
        
        // List Dokter
        Expanded(
          child: Obx(() {
            final dokters = controller.filteredDokters;
            if (dokters.isEmpty) {
              return _buildEmptyState('Belum ada data dokter untuk filter ini', Icons.medical_information_outlined);
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dokters.length,
              itemBuilder: (context, index) {
                return _buildDokterCard(dokters[index]);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDokterCard(Map<String, dynamic> doc) {
    final status = doc['status']?.toString().toLowerCase() ?? 'menunggu';
    
    // Konfigurasi Warna Status
    Color statusColor;
    IconData statusIcon;
    if (status == 'disetujui') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'ditolak') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (status == 'diblokir') {
      statusColor = Colors.black87;
      statusIcon = Icons.block;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header Info & Status
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Dokter
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person, color: Color(0xFF2E7D32), size: 36),
                  ),
                  const SizedBox(width: 16),
                  
                  // Detail Dokter
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['name'] ?? 'Tanpa Nama',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(doc['email'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.badge_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('STR: ${doc['strNumber'] ?? '-'}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Badge Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            
            // Action Buttons Area
            Container(
              color: const Color(0xFFFAFAFA),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Tombol Lihat STR
                  Expanded(
                    child: (doc['strImageBase64'] != null && doc['strImageBase64'].toString().isNotEmpty)
                      ? ElevatedButton.icon(
                          onPressed: () => _showSTRModal(doc['strImageBase64']),
                          icon: const Icon(Icons.image_search, size: 18, color: Colors.white),
                          label: const Text('Lihat STR', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12)
                          ),
                          alignment: Alignment.center,
                          child: const Text('STR Kosong', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                  ),
                  
                  // Action Buttons (Khusus Status Menunggu)
                  if (status == 'menunggu') ...[
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => controller.updateDokterStatus(doc['uid'], 'Disetujui'),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Icon(Icons.check, color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => controller.updateDokterStatus(doc['uid'], 'Ditolak'),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Icon(Icons.close, color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(width: 8),
                  
                  // Menu Lainnya (Titik Tiga / Dropmenu)
                  Material(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: Colors.blueGrey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      offset: const Offset(0, 40),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditModal(doc, 'dokter');
                        } else if (value == 'setujui') {
                          controller.updateDokterStatus(doc['uid'], 'disetujui');
                        } else if (value == 'tolak') {
                          controller.updateDokterStatus(doc['uid'], 'ditolak');
                        } else if (value == 'blokir') {
                          controller.updateDokterStatus(doc['uid'], 'diblokir');
                        } else if (value == 'hapus') {
                          _confirmHapus(doc['uid'], 'dokter');
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined, color: Colors.blue),
                            title: Text('Edit Data'),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        if (status != 'disetujui')
                          const PopupMenuItem<String>(
                            value: 'setujui',
                            child: ListTile(
                              leading: Icon(Icons.check_circle_outline, color: Colors.green),
                              title: Text('Setujui Akun'),
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        if (status != 'ditolak')
                          const PopupMenuItem<String>(
                            value: 'tolak',
                            child: ListTile(
                              leading: Icon(Icons.cancel_outlined, color: Colors.orange),
                              title: Text('Tolak Akun'),
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        if (status != 'diblokir')
                          const PopupMenuItem<String>(
                            value: 'blokir',
                            child: ListTile(
                              leading: Icon(Icons.block, color: Colors.black87),
                              title: Text('Blokir Akun'),
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'hapus',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline, color: Colors.red),
                            title: Text('Hapus Permanen', style: TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]
            ),
            child: Icon(icon, size: 60, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showSTRModal(String base64String) {
    if (base64String.contains(',')) {
      base64String = base64String.split(',').last;
    }
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Container(
                width: double.infinity,
                height: Get.height * 0.7,
                alignment: Alignment.center,
                child: Image.memory(
                  base64Decode(base64String),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.white54, size: 60),
                        SizedBox(height: 16),
                        Text('Format gambar tidak didukung', style: TextStyle(color: Colors.white)),
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black, size: 24),
                onPressed: () => Get.back(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            )
          ],
        ),
      ),
      barrierColor: Colors.black87,
    );
  }

  void _confirmHapus(String uid, String role) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
              ),
              const SizedBox(height: 20),
              const Text('Hapus Akun?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                'Tindakan ini tidak dapat dibatalkan. Semua data terkait akun ini akan hilang selamanya.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Batal', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.hapusAkun(uid, role);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  void _showEditModal(Map<String, dynamic> doc, String role) {
    final nameController = TextEditingController(text: doc['name'] ?? '');
    final emailController = TextEditingController(text: doc['email'] ?? '');
    
    final originalName = doc['name'] ?? '';
    final originalEmail = doc['email'] ?? '';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          final bool isEmailChanged = emailController.text.trim() != originalEmail && emailController.text.trim().isNotEmpty;
          final bool isNameChanged = nameController.text.trim() != originalName;
          final bool isChanged = isNameChanged || isEmailChanged;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.zero,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Edit Data Pengguna', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    
                    TextField(
                      controller: nameController,
                      onChanged: (v) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kotak Pembungkus Email & Reset
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Data Email & Autentikasi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: emailController,
                                  onChanged: (v) => setState(() {}),
                                  decoration: InputDecoration(
                                    labelText: 'Alamat Email',
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Material(
                                color: isEmailChanged ? Colors.blue : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: isEmailChanged ? () {
                                    controller.sendPasswordReset(emailController.text.trim());
                                  } : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                                    child: Icon(Icons.send, color: isEmailChanged ? Colors.white : Colors.grey.shade500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '* Tekan ikon kirim di sebelah email untuk mengirim tautan reset kata sandi (Ikon hanya aktif jika email diperbarui / diubah).',
                            style: TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isChanged ? () {
                          Get.back();
                          controller.updateAkun(
                            doc['uid'], 
                            role, 
                            nameController.text.trim(), 
                            emailController.text.trim(),
                          );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isChanged ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              ),
            ),
          );
        }
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
  }

  // Hapus _showDokterActionModal karena sudah digantikan oleh PopupMenuButton

}
