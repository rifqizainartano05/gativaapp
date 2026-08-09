import os

path_edukasi_view = 'lib/app/modules/edukasi/views/edukasi_view.dart'
with open(path_edukasi_view, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace StreamBuilder with Obx
old_stream_builder = """            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collectionGroup('edukasi').orderBy('created_at', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Terjadi kesalahan'));
                  }
                  
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {"""

new_obx = """            Expanded(
              child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final docs = controller.edukasiList;
                  if (docs.isEmpty) {"""

content = content.replace(old_stream_builder, new_obx)

old_item_builder = """                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      data['id'] = docs[index].id;"""
new_item_builder = """                    itemBuilder: (context, index) {
                      final data = docs[index];"""

content = content.replace(old_item_builder, new_item_builder)

old_closing = """                    },
                  );
                },
              ),
            ),"""
new_closing = """                    },
                  );
              }),
            ),"""
content = content.replace(old_closing, new_closing)

with open(path_edukasi_view, 'w', encoding='utf-8') as f:
    f.write(content)
print("done")
