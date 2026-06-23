import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InformasiKesehatanController extends GetxController {
  final checkupEvents = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadRealData();
  }

  void _loadRealData() {
    FirebaseFirestore.instance
        .collection('website')
        .doc('rifqizainartano50904@gmail.com')
        .collection('informasi')
        .snapshots()
        .listen((snapshot) {
      checkupEvents.assignAll(snapshot.docs.map((doc) {
        final data = doc.data();
        
        String formattedDate = '-';
        if (data['created_at'] != null) {
          try {
            DateTime dt = (data['created_at'] as Timestamp).toDate();
            formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(dt);
          } catch (e) {
            formattedDate = data['created_at'].toString();
          }
        }

        return {
          'title': data['judul'] ?? 'Informasi Kesehatan',
          'organizer': data['kategori'] ?? 'Kesehatan',
          'date': formattedDate,
          'location': '-', 
          'description': data['deskripsi'] ?? '',
          'type': data['kategori'] ?? 'Umum',
          'gambar_base64': data['gambar_base64'] ?? ''
        };
      }).toList());
    });
  }
}
