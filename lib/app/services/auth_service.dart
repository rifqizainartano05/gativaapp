import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final RxString userRole = ''.obs;

  Future<AuthService> init() async {
    // Apabila sudah login, periksa role saat service diinisialisasi
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await fetchUserRole(currentUser.uid);
    }
    return this;
  }

  Future<void> fetchUserRole(String uid) async {
    // Cek di subcollection pasien
    var pasienDoc = await FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('pasien')
        .doc(uid)
        .get();
    if (pasienDoc.exists) {
      userRole.value = 'Pasien';
      return;
    }

    // Cek di subcollection dokter
    var dokterDoc = await FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('dokter')
        .doc(uid)
        .get();
    if (dokterDoc.exists) {
      userRole.value = 'Tenaga Kesehatan';
      return;
    }

    // Default fallback
    userRole.value = 'Unknown';
  }

  DocumentReference getUserReference(String uid) {
    if (userRole.value == 'Pasien') {
      return FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(uid);
    } else if (userRole.value == 'Tenaga Kesehatan') {
      return FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('dokter')
          .doc(uid);
    } else {
      // Fallback: Jika tidak terdeteksi (meskipun tidak mungkin jika register berhasil), gunakan pasien sebagai fallback sementara
      return FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien')
          .doc(uid);
    }
  }

  CollectionReference getUserCollectionReference() {
    if (userRole.value == 'Pasien') {
      return FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien');
    } else if (userRole.value == 'Tenaga Kesehatan') {
      return FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('dokter');
    } else {
      return FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('pasien');
    }
  }

  void logout() {
    userRole.value = '';
    FirebaseAuth.instance.signOut();
  }
}
