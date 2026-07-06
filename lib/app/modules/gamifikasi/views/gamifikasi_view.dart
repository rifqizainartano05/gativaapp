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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.userPoints.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        'Total Poin',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.currentStreak.value} Hari',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        'Beruntun',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
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
      if (controller.missions.isEmpty) return const SizedBox(height: 100);
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
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      backgroundColor: Colors.white,
                      elevation: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            // Watermark
                            Positioned(
                              right: -40,
                              bottom: -20,
                              child: Icon(
                                Icons.lock_rounded,
                                size: 200,
                                color: Colors.grey.withOpacity(0.1),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lock_rounded,
                                      color: Colors.amber,
                                      size: 48,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Level Terkunci 🔒",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Selesaikan misi di level sebelumnya untuk membuka akses ke level ini.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => Get.back(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade800,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        "Mengerti",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
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
        elevation: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Icon Watermark di pojok kanan bawah
              Positioned(
                right: -40,
                bottom: -20,
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 200,
                  color: const Color(0xFF2E7D32).withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFBC02D), Color(0xFFF57F17)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mission.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                          color: Color(0xFF2E7D32),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '+${mission.rewardPoints} Poin',
                                          style: const TextStyle(
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.grey),
                            onPressed: () => Get.back(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Deskripsi Misi
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Obx(
                          () => Text(
                            mission.description.replaceAll(
                              '{limit}',
                              controller.dailyLimit.value.toString(),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Pertanyaan (Bila ada)
                      if (mission.question != null && !mission.isCompleted) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.help_outline_rounded, color: Color(0xFF2E7D32), size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                mission.question!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: answerController,
                          decoration: InputDecoration(
                            hintText: "Tulis jawaban Anda di sini...",
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Tombol Aksi
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
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                onPressed: () => Get.back(),
                                child: const Text(
                                  "Batal",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            flex: mission.isCompleted ? 1 : 2,
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

                                      Get.back(); // Tutup dialog soal

                                      // Validasi menggunakan API Groq
                                      controller.verifyMissionAnswer(mission, answerController.text);
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
                                elevation: mission.isCompleted ? 0 : 4,
                                shadowColor: const Color(0xFF2E7D32).withOpacity(0.4),
                              ),
                              child: Text(
                                mission.isCompleted ? 'Misi Selesai 🎉' : 'Mulai Tugas',
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
            ],
          ),
        ),
      ),
    );
  }
}
