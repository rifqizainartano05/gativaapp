import os

path_home_controller = 'lib/app/modules/home/controllers/home_controller.dart'
with open(path_home_controller, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace fetchEdukasi
old_fetch = """    void fetchEdukasi() {
    FirebaseFirestore.instance
        .collectionGroup('edukasi')
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
  }"""

new_fetch = """    void fetchEdukasi() {
    // Gunakan EdukasiController untuk menghindari masalah Index CollectionGroup
    final edukasiCtrl = Get.put(EdukasiController());
    ever(edukasiCtrl.edukasiList, (list) {
      edukasiList.value = list.take(5).toList();
    });
    // Inisialisasi awal jika sudah ada
    edukasiList.value = edukasiCtrl.edukasiList.take(5).toList();
  }"""

content = content.replace(old_fetch, new_fetch)

if "import '../edukasi/controllers/edukasi_controller.dart';" not in content:
    content = content.replace("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport '../../edukasi/controllers/edukasi_controller.dart';")

with open(path_home_controller, 'w', encoding='utf-8') as f:
    f.write(content)
print("done")
