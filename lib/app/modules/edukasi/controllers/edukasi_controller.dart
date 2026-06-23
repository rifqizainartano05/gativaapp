import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class EdukasiArticle {
  final String title;
  final String category;
  final String content;
  final String iconUrl;

  EdukasiArticle(this.title, this.category, this.content, this.iconUrl);
}

class EdukasiController extends GetxController {
  final articles = <EdukasiArticle>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadRealData();
  }

  void _loadRealData() {
    FirebaseFirestore.instance
        .collection('website')
        .doc('rifqizainartano50904@gmail.com')
        .collection('edukasi')
        .snapshots()
        .listen((snapshot) {
      articles.assignAll(snapshot.docs.map((doc) {
        final data = doc.data();
        return EdukasiArticle(
          data['judul'] ?? 'Tanpa Judul',
          data['kategori'] ?? 'Umum',
          data['deskripsi'] ?? '',
          data['gambar'] ?? '',
        );
      }).toList());
    });
  }
}
