import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/edukasi_controller.dart';
import '../../../widgets/custom_popup.dart';

class EdukasiView extends GetView<EdukasiController> {
  const EdukasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Obx(() {
        bool isFromMission = Get.arguments is Map && Get.arguments['isFromMission'] == true;
        bool missionCompleted = controller.isMissionCompleted.value; // Unconditionally read to avoid GetX error
        bool canGoBack = !isFromMission || missionCompleted;

        return PopScope(
          canPop: canGoBack,
          onPopInvoked: (didPop) {
            if (didPop) return;
            if (!canGoBack) {
              CustomPopup.showWarning(
                'Perhatian',
                'Harap tunggu materi edukasi termuat untuk menyelesaikan misi.',
              );
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F6F8),
        body: Column(
          children: [
            // Custom Header with Watermark
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 30,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 10,
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
                        Icons.menu_book_rounded,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (!canGoBack) {
                            CustomPopup.showWarning(
                              'Perhatian',
                              'Harap tunggu materi edukasi termuat untuk menyelesaikan misi.',
                            );
                          } else {
                            Get.back();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Edukasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.edukasiList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Materi edukasi belum tersedia',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SafeArea(
                  bottom: true,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: PageController(viewportFraction: 0.85),
                    itemCount: controller.edukasiList.length,
                    itemBuilder: (context, index) {
                      final article = controller.edukasiList[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header Banner
                              Expanded(
                                flex: 3,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                    const Positioned.fill(
                                      child: Opacity(
                                        opacity: 0.1,
                                        child: Icon(
                                          Icons.menu_book_rounded,
                                          size: 150,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    // Category Badge
                                    Positioned(
                                      top: 20,
                                      left: 20,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                                        ),
                                        child: Text(
                                          article['kategori'] ?? 'Umum',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Content
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article['judul'] ?? 'Tanpa Judul',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 22,
                                            color: Color(0xFF1E293B),
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          article['deskripsi'] ?? 'Tidak ada deskripsi',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 15,
                                            height: 1.6,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.arrow_downward_rounded, color: Colors.grey.shade400, size: 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Scroll ke bawah",
                                                style: TextStyle(
                                                  color: Colors.grey.shade400,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe_rounded, color: Colors.grey, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Geser (slide) untuk materi lain",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
            ),
          ],
        ),
      ),
    );
  }),
  );
  }
}
