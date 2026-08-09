import os

# 1. Update EdukasiDokterController
path_ctrl = 'lib/app/modules/edukasi_dokter/controllers/edukasi_dokter_controller.dart'
with open(path_ctrl, 'r', encoding='utf-8') as f:
    content = f.read()

old_vars = """  final loadingMessage = ''.obs;
  final currentDoctorName = 'Dokter'.obs;"""
new_vars = """  final loadingMessage = ''.obs;
  final currentDoctorName = 'Dokter'.obs;
  final RxString searchQuery = ''.obs;

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }"""
if old_vars in content:
    content = content.replace(old_vars, new_vars)

with open(path_ctrl, 'w', encoding='utf-8') as f:
    f.write(content)


# 2. Update EdukasiDokterView
path_view = 'lib/app/modules/edukasi_dokter/views/edukasi_dokter_view.dart'
with open(path_view, 'r', encoding='utf-8') as f:
    content = f.read()

old_expanded = """          Expanded(
            child: StreamBuilder<QuerySnapshot>("""
new_expanded = """          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => controller.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Cari edukasi Anda...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>("""
if old_expanded in content:
    content = content.replace(old_expanded, new_expanded)

old_filter = """                  final currentDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['doctor_name'] == name;
                  }).toList();"""
new_filter = """                  final currentDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    bool isMine = data['doctor_name'] == name;
                    bool matchesSearch = true;
                    if (controller.searchQuery.value.trim().isNotEmpty) {
                      String title = (data['title'] ?? '').toString().toLowerCase();
                      matchesSearch = title.contains(controller.searchQuery.value.trim().toLowerCase());
                    }
                    return isMine && matchesSearch;
                  }).toList();"""
if old_filter in content:
    content = content.replace(old_filter, new_filter)

with open(path_view, 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")
