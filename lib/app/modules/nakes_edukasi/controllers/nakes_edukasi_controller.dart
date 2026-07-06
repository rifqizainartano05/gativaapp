import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_popup.dart';

class EdukasiArticle {
  final String id;
  final String title;
  final String category;
  final String content;
  final String iconUrl;

  EdukasiArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.iconUrl,
  });
}

class NakesEdukasiController extends GetxController {
  final articles = <EdukasiArticle>[].obs;
  final isLoading = true.obs;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _loadRealData();
  }

  void _loadRealData() {
    final user = _auth.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    _firestore
        .collection('mobile')
        .doc('roles')
        .collection('tenaga_kesehatan')
        .doc(user.uid)
        .collection('edukasi')
        .snapshots()
        .listen((snapshot) {
          articles.assignAll(
            snapshot.docs.map((doc) {
              final data = doc.data();
              return EdukasiArticle(
                id: doc.id,
                title: data['judul'] ?? 'Tanpa Judul',
                category: data['kategori'] ?? 'Umum',
                content: data['deskripsi'] ?? '',
                iconUrl: data['gambar'] ?? '',
              );
            }).toList(),
          );
          isLoading.value = false;
        });
  }

  Future<void> addArticle(String title, String category, String content) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(user.uid)
          .collection('edukasi')
          .add({
            'judul': title,
            'kategori': category,
            'deskripsi': content,
            'gambar': '',
            'createdAt': FieldValue.serverTimestamp(),
          });
      CustomPopup.showSuccess(
        'Sukses',
        'Edukasi berhasil ditambahkan',
      );
    } catch (e) {
      CustomPopup.showError(
        'Error',
        'Gagal menambahkan edukasi',
      );
    }
  }

  Future<void> updateArticle(
    String id,
    String title,
    String category,
    String content,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(user.uid)
          .collection('edukasi')
          .doc(id)
          .update({'judul': title, 'kategori': category, 'deskripsi': content});
      CustomPopup.showSuccess(
        'Sukses',
        'Edukasi berhasil diperbarui',
      );
    } catch (e) {
      CustomPopup.showError(
        'Error',
        'Gagal memperbarui edukasi',
      );
    }
  }

  Future<void> deleteArticle(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('mobile')
          .doc('roles')
          .collection('tenaga_kesehatan')
          .doc(user.uid)
          .collection('edukasi')
          .doc(id)
          .delete();
      CustomPopup.showSuccess(
        'Sukses',
        'Edukasi berhasil dihapus',
      );
    } catch (e) {
      CustomPopup.showError(
        'Error',
        'Gagal menghapus edukasi',
      );
    }
  }
}
