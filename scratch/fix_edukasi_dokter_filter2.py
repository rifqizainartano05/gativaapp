import re

path_controller = 'lib/app/modules/edukasi_dokter/controllers/edukasi_dokter_controller.dart'
with open(path_controller, 'r', encoding='utf-8') as f:
    content = f.read()

if 'final currentDoctorName = ' not in content:
    old_loading = "  final loadingMessage = ''.obs;"
    new_loading = "  final loadingMessage = ''.obs;\n  final currentDoctorName = 'Dokter'.obs;\n\n  @override\n  void onInit() {\n    super.onInit();\n    _loadDoctorName();\n  }\n\n  Future<void> _loadDoctorName() async {\n    currentDoctorName.value = await _getDoctorName();\n  }"
    content = content.replace(old_loading, new_loading)
    with open(path_controller, 'w', encoding='utf-8') as f:
        f.write(content)


path_view = 'lib/app/modules/edukasi_dokter/views/edukasi_dokter_view.dart'
with open(path_view, 'r', encoding='utf-8') as f:
    content_view = f.read()

old_stream = """                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('Belum ada artikel edukasi.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;"""

new_stream = """                final docs = snapshot.data?.docs ?? [];
                
                return Obx(() {
                  final name = controller.currentDoctorName.value;
                  final currentDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['doctor_name'] == name;
                  }).toList();

                  if (currentDocs.isEmpty) {
                    return const Center(child: Text('Belum ada artikel edukasi yang Anda buat.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentDocs.length,
                    itemBuilder: (context, index) {
                      final data = currentDocs[index].data() as Map<String, dynamic>;
                      final id = currentDocs[index].id;"""
content_view = content_view.replace(old_stream, new_stream)


old_end = """                  },
                );
              },
            ),
          ),"""

new_end = """                    },
                  );
                });
              },
            ),
          ),"""
content_view = content_view.replace(old_end, new_end)


old_ringkasan = """'Ringkasan AI: ${data['summary']}',"""
new_ringkasan = """'${data['summary']}',"""
content_view = content_view.replace(old_ringkasan, new_ringkasan)


with open(path_view, 'w', encoding='utf-8') as f:
    f.write(content_view)

print("Done")
