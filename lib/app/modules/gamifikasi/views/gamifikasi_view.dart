import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/gamifikasi_controller.dart';

class GamifikasiView extends GetView<GamifikasiController> {
  const GamifikasiView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GamifikasiController>()) {
      Get.put(GamifikasiController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: Column(
          children: [
            _buildHeaderCard(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'PETA PERJALANAN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildMapPath(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                Icons.emoji_events_rounded,
                size: 130,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Column(
            children: [
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Level Saat Ini',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      controller.userLevel.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.userPoints.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        'Total Poin',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.orangeAccent,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.currentStreak.value} Hari',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        'Beruntun',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ],
      ),
    );
  }

  Widget _buildMapPath(BuildContext context) {
    return Obx(() {
      final missions = controller.missions;
      return Container(
        width: double.infinity,
        child: Wrap(
          spacing: 20,
          runSpacing: 30,
          alignment: WrapAlignment.spaceEvenly,
          children: missions.map((mission) {
            bool isActive =
                mission.level == controller.currentActiveLevel.value;

            return GestureDetector(
              onTap: () {
                if (mission.isUnlocked) {
                  _showMissionDetails(context, mission);
                } else {
                  Get.snackbar(
                    'Terkunci',
                    'Selesaikan level sebelumnya untuk membuka level ini.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: mission.isCompleted
                          ? const Color(0xFF2E7D32)
                          : (isActive ? Colors.amber : Colors.grey.shade300),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? Colors.orange : Colors.transparent,
                        width: isActive ? 4 : 0,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: mission.isCompleted
                          ? const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 35,
                            )
                          : (mission.isUnlocked
                                ? Text(
                                    '${mission.level}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: Colors.black87,
                                    ),
                                  )
                                : const Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white54,
                                    size: 28,
                                  )),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 70,
                    child: Text(
                      mission.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive ? Colors.black87 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  void _showMissionDetails(BuildContext context, dynamic mission) {
    final TextEditingController answerController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                mission.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '+${mission.rewardPoints} Poin',
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  mission.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (mission.question != null && !mission.isCompleted) ...[
                  Text(
                    mission.question!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: answerController,
                    decoration: InputDecoration(
                      hintText: "Tulis jawaban Anda...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Row(
                  children: [
                    if (!mission.isCompleted) ...[
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: mission.isCompleted
                            ? null
                            : () {
                                if (mission.question != null && answerController.text.trim().isEmpty) {
                                  Get.snackbar(
                                    'Perhatian',
                                    'Harap isi jawaban dari pertanyaan misi ini terlebih dahulu!',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                Get.back();

                                // Tindakan navigasi berdasarkan level/tugas
                                if (mission.level == 2 ||
                                    mission.level == 13 ||
                                    mission.level == 5) {
                                  final TextEditingController nameController =
                                      TextEditingController();
                                  Get.dialog(
                                    Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor: Colors.transparent,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            // Watermark Icon
                                            Positioned(
                                              right: -20,
                                              bottom: -20,
                                              child: Icon(
                                                Icons.qr_code_scanner_rounded,
                                                size: 150,
                                                color: const Color(
                                                  0xFF2E7D32,
                                                ).withOpacity(0.05),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(24.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(
                                                          12,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFF2E7D32,
                                                          ).withOpacity(0.1),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.fastfood_rounded,
                                                          color: Color(0xFF2E7D32),
                                                          size: 28,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      const Expanded(
                                                        child: Text(
                                                          'Identifikasi Produk',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 24),
                                                  const Text(
                                                    'Masukkan nama kemasan yang akan dipindai agar mudah dicatat nantinya:',
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 14,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  TextField(
                                                    controller: nameController,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Contoh: Chitato Sapi Panggang',
                                                      hintStyle: TextStyle(
                                                        color: Colors.grey.shade400,
                                                      ),
                                                      filled: true,
                                                      fillColor: Colors.grey.shade50,
                                                      prefixIcon: const Icon(
                                                        Icons.edit_note_rounded,
                                                        color: Colors.grey,
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(16),
                                                        borderSide: BorderSide(
                                                          color: Colors.grey.shade300,
                                                        ),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                            borderSide: BorderSide(
                                                              color: Colors
                                                                  .grey
                                                                  .shade300,
                                                            ),
                                                          ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                            borderSide:
                                                                const BorderSide(
                                                                  color: Color(
                                                                    0xFF2E7D32,
                                                                  ),
                                                                  width: 2,
                                                                ),
                                                          ),
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 16,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 32),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextButton(
                                                          onPressed: () => Get.back(),
                                                          style: TextButton.styleFrom(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 16,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            'Batal',
                                                            style: TextStyle(
                                                              color: Colors.grey,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            if (nameController.text
                                                                .trim()
                                                                .isEmpty) {
                                                              Get.snackbar(
                                                                'Perhatian',
                                                                'Nama kemasan tidak boleh kosong',
                                                                snackPosition:
                                                                    SnackPosition
                                                                        .BOTTOM,
                                                                backgroundColor:
                                                                    Colors.orange,
                                                                colorText:
                                                                    Colors.white,
                                                              );
                                                              return;
                                                            }
                                                            Get.back();
                                                            Get.toNamed(
                                                              '/scanner',
                                                              arguments:
                                                                  nameController.text
                                                                      .trim(),
                                                            )?.then((_) {
                                                              // Selesaikan misi setelah kembali dari scanner (pengerjaan asli)
                                                              controller.completeMission(mission.id);
                                                            });
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFF2E7D32,
                                                                ),
                                                            foregroundColor:
                                                                Colors.white,
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 16,
                                                                ),
                                                            elevation: 0,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            'Pindai',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 16,
                                                            ),
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
                                    ),
                                  );
                                } else if (mission.level == 4 ||
                                    mission.level == 18) {
                                  Get.toNamed('/nakes-edukasi')?.then((_) => controller.completeMission(mission.id));
                                } else if (mission.level == 12) {
                                  Get.toNamed('/riwayat')?.then((_) => controller.completeMission(mission.id));
                                } else if (mission.level == 1) {
                                  Get.toNamed('/lensa-natrium')?.then((_) => controller.completeMission(mission.id));
                                } else {
                                  // Jika hanya menjawab pertanyaan atau tugas lain, langsung selesaikan
                                  controller.completeMission(mission.id);
                                  Get.toNamed('/main-navigation');
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          mission.isCompleted ? 'Selesai' : 'Mulai Tugas',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
