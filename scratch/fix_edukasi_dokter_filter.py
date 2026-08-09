import re

path_controller = 'lib/app/modules/edukasi_dokter/controllers/edukasi_dokter_controller.dart'
with open(path_controller, 'r', encoding='utf-8') as f:
    content = f.read()

# Add onInit and currentDoctorName to controller
if 'final currentDoctorName = ' not in content:
    old_loading = "  final loadingMessage = ''.obs;"
    new_loading = "  final loadingMessage = ''.obs;\n  final currentDoctorName = 'Dokter'.obs;\n\n  @override\n  void onInit() {\n    super.onInit();\n    _loadDoctorName();\n  }\n\n  Future<void> _loadDoctorName() async {\n    currentDoctorName.value = await _getDoctorName();\n  }"
    content = content.replace(old_loading, new_loading)
    
    with open(path_controller, 'w', encoding='utf-8') as f:
        f.write(content)

path_view = 'lib/app/modules/edukasi_dokter/views/edukasi_dokter_view.dart'
with open(path_view, 'r', encoding='utf-8') as f:
    content_view = f.read()

# Replace StreamBuilder handling to filter by doctorName
old_stream = """                  return const Center(child: Text('Terjadi kesalahan'));
                }
                
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {"""

new_stream = """                  return const Center(child: Text('Terjadi kesalahan'));
                }
                
                final docs = snapshot.data?.docs ?? [];
                // Filter docs to only show the current doctor's articles
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['doctor_name'] == controller.currentDoctorName.value;
                }).toList();

                if (filteredDocs.isEmpty) {"""
content_view = content_view.replace(old_stream, new_stream)

# Update the ListView itemCount to use filteredDocs
old_list = """                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;"""

new_list = """                return Obx(() {
                  // Rebuild when currentDoctorName changes
                  final name = controller.currentDoctorName.value;
                  final currentDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['doctor_name'] == name;
                  }).toList();

                  if (currentDocs.isEmpty) {
                    return const Center(child: Text('Belum ada edukasi yang Anda buat.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentDocs.length,
                    itemBuilder: (context, index) {
                      final data = currentDocs[index].data() as Map<String, dynamic>;
                      final id = currentDocs[index].id;"""
content_view = content_view.replace(old_list, new_list)

# We need to close the Obx at the end of ListView.builder
old_end_list = """                  },
                );
              },
            ),
          ),"""

new_end_list = """                    },
                  );
                });
              },
            ),
          ),"""
content_view = content_view.replace(old_end_list, new_end_list)

# Remove 'Ringkasan AI: ' text
old_ringkasan = """                                      'Ringkasan AI: ${data['summary']}',"""
new_ringkasan = """                                      '${data['summary']}',"""
content_view = content_view.replace(old_ringkasan, new_ringkasan)

# Fix the docs.isEmpty which is now not used correctly
# Wait, if we use Obx inside StreamBuilder, we don't need the first `if (filteredDocs.isEmpty)` check.
# Let's clean it up properly.
content_view = content_view.replace("""                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['doctor_name'] == controller.currentDoctorName.value;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text('Belum ada artikel edukasi.'));
                }""", """                // Filter handled in Obx below""")

# Wait, `if (docs.isEmpty)` is already there. Let me just replace the original lines again to be safe.
# Actually I'll write a better regex replacement for this.
