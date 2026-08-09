import re

def update_home_controller():
    path = 'lib/app/modules/home/controllers/home_controller.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Add edukasiList
    if 'final RxList<Map<String, dynamic>> edukasiList = <Map<String, dynamic>>[].obs;' not in content:
        content = content.replace('final RxDouble totalConsumedToday = 0.0.obs;',
                                  'final RxDouble totalConsumedToday = 0.0.obs;\n  final RxList<Map<String, dynamic>> edukasiList = <Map<String, dynamic>>[].obs;')
    
    # Add fetchEdukasi() method
    if 'void fetchEdukasi()' not in content:
        fetch_method = """  void fetchEdukasi() {
    FirebaseFirestore.instance
        .collection('edukasi')
        .orderBy('created_at', descending: true)
        .limit(5)
        .snapshots()
        .listen((snapshot) {
      edukasiList.value = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

"""
        content = content.replace('void fetchUserData() {', fetch_method + '  void fetchUserData() {')
    
    # Call fetchEdukasi in onInit
    if 'fetchEdukasi();' not in content:
        content = content.replace('fetchUserData();', 'fetchUserData();\n    fetchEdukasi();')
        
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def update_home_view():
    path = 'lib/app/modules/home/views/home_view.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    bell_icon = """                      GestureDetector(
                        onTap: () => Get.toNamed('/notifikasi'),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),"""
    if '// Notification icon removed' in content:
        content = content.replace('// Notification icon removed', bell_icon)
    
    # Replace Grid logic
    old_grid_bottom = """                      Row(
                        children: [
                          Expanded(
                            child: _buildGridItem(
                              icon: Icons.history_rounded,
                              title: 'Riwayat',
                              subtitle: 'Catatan Medis',
                              isActive: false,
                              onTap: () => Get.toNamed(Routes.RIWAYAT),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGridItem(
                              icon: Icons.notifications_outlined,
                              title: 'Notifikasi',
                              subtitle: 'Pemberitahuan',
                              isActive: false,
                              onTap: () => Get.toNamed('/notifikasi'),
                            ),
                          ),
                        ],
                      ),"""

    new_grid_bottom = """                      Row(
                        children: [
                          Expanded(
                            child: _buildGridItem(
                              icon: Icons.history_rounded,
                              title: 'Riwayat',
                              subtitle: 'Catatan Medis',
                              isActive: false,
                              onTap: () => Get.toNamed(Routes.RIWAYAT),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'EDUKASI KESEHATAN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed('/edukasi'),
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Horizontal scrollable Edukasi cards
                      SizedBox(
                        height: 200,
                        child: Obx(() {
                          if (controller.edukasiList.isEmpty) {
                            return const Center(
                              child: Text(
                                'Belum ada edukasi tersedia.',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            );
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: controller.edukasiList.length,
                            itemBuilder: (context, index) {
                              final item = controller.edukasiList[index];
                              return GestureDetector(
                                onTap: () => Get.toNamed('/edukasi', arguments: item),
                                child: Container(
                                  width: 260,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Image
                                      Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          image: item['imageUrl'] != null
                                              ? DecorationImage(
                                                  image: NetworkImage(item['imageUrl']),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          color: Colors.grey.shade100,
                                        ),
                                        child: item['imageUrl'] == null
                                            ? const Center(child: Icon(Icons.image, color: Colors.grey, size: 40))
                                            : null,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          item['title'] ?? 'Judul Edukasi',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),"""
    
    if old_grid_bottom in content:
        content = content.replace(old_grid_bottom, new_grid_bottom)
        
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

update_home_controller()
update_home_view()
print("Updated successfully")
