import os

# 1. Update EdukasiDokterController (Add & Delete)
path_edukasi_dokter_controller = 'lib/app/modules/edukasi_dokter/controllers/edukasi_dokter_controller.dart'
with open(path_edukasi_dokter_controller, 'r', encoding='utf-8') as f:
    content = f.read()

old_add = "FirebaseFirestore.instance.collection('mobile').doc('roles').collection('edukasi')"
new_add = "FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(FirebaseAuth.instance.currentUser!.uid).collection('edukasi')"

content = content.replace(old_add, new_add)
with open(path_edukasi_dokter_controller, 'w', encoding='utf-8') as f:
    f.write(content)

# 2. Update EdukasiDokterView (Stream)
path_edukasi_dokter_view = 'lib/app/modules/edukasi_dokter/views/edukasi_dokter_view.dart'
with open(path_edukasi_dokter_view, 'r', encoding='utf-8') as f:
    content_view = f.read()

# Since we now only fetch the doctor's own collection, we don't need the Obx filter anymore!
# But for now, just replace the path and keep the filter (it will just filter itself, harmless) or remove the filter.
# Let's just replace the path first to be safe and clean up later.
old_view_stream = "FirebaseFirestore.instance.collection('mobile').doc('roles').collection('edukasi').orderBy('created_at', descending: true).snapshots()"
new_view_stream = "FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(FirebaseAuth.instance.currentUser!.uid).collection('edukasi').orderBy('created_at', descending: true).snapshots()"
content_view = content_view.replace(old_view_stream, new_view_stream)
with open(path_edukasi_dokter_view, 'w', encoding='utf-8') as f:
    f.write(content_view)


# 3. Update EdukasiView (Patient) to use collectionGroup
path_edukasi_view = 'lib/app/modules/edukasi/views/edukasi_view.dart'
with open(path_edukasi_view, 'r', encoding='utf-8') as f:
    content_ev = f.read()

old_ev_stream = "FirebaseFirestore.instance.collection('mobile').doc('roles').collection('edukasi')"
new_ev_stream = "FirebaseFirestore.instance.collectionGroup('edukasi')"
content_ev = content_ev.replace(old_ev_stream, new_ev_stream)
with open(path_edukasi_view, 'w', encoding='utf-8') as f:
    f.write(content_ev)


# 4. Update HomeController (Patient Dashboard) to use collectionGroup
path_home_controller = 'lib/app/modules/home/controllers/home_controller.dart'
with open(path_home_controller, 'r', encoding='utf-8') as f:
    content_home = f.read()

old_home_stream = """    FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('edukasi')"""
new_home_stream = """    FirebaseFirestore.instance
        .collectionGroup('edukasi')"""
content_home = content_home.replace(old_home_stream, new_home_stream)
with open(path_home_controller, 'w', encoding='utf-8') as f:
    f.write(content_home)

print("Updated paths to use collectionGroup and doctor's specific subcollection.")
