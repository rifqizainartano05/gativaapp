import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class EdukasiController extends GetxController {
  final RxList<Map<String, dynamic>> edukasiList = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  List<Map<String, dynamic>> get filteredEdukasiList {
    if (searchQuery.value.trim().isEmpty) return edukasiList;
    return edukasiList.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final query = searchQuery.value.trim().toLowerCase();
      return title.contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  StreamSubscription? _doctorsSubscription;
  final Map<String, StreamSubscription> _doctorEdukasiSubscriptions = {};
  
  // This map keeps the latest snapshot list of articles for each doctor
  final Map<String, List<Map<String, dynamic>>> _articlesPerDoctor = {};

  @override
  void onInit() {
    super.onInit();
    _listenToAllDoctorsEdukasi();
  }

  void _listenToAllDoctorsEdukasi() {
    isLoading.value = true;
    _doctorsSubscription = FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('dokter')
        .snapshots()
        .listen((doctorsSnapshot) {
          
      // Check for removed doctors and cancel their subscriptions
      final currentDoctorIds = doctorsSnapshot.docs.map((doc) => doc.id).toSet();
      final previousDoctorIds = _doctorEdukasiSubscriptions.keys.toSet();
      
      final removedDoctorIds = previousDoctorIds.difference(currentDoctorIds);
      for (final id in removedDoctorIds) {
        _doctorEdukasiSubscriptions[id]?.cancel();
        _doctorEdukasiSubscriptions.remove(id);
        _articlesPerDoctor.remove(id);
      }

      // Add subscriptions for new doctors
      for (final doc in doctorsSnapshot.docs) {
        if (!_doctorEdukasiSubscriptions.containsKey(doc.id)) {
          _doctorEdukasiSubscriptions[doc.id] = FirebaseFirestore.instance
              .collection('mobile')
              .doc('roles')
              .collection('dokter')
              .doc(doc.id)
              .collection('edukasi')
              .snapshots()
              .listen((edukasiSnapshot) {
                
            final articles = edukasiSnapshot.docs.map((e) {
              final data = e.data();
              data['id'] = e.id;
              // we can keep doctorId if needed
              data['doctorId'] = doc.id;
              return data;
            }).toList();
            
            _articlesPerDoctor[doc.id] = articles;
            _updateMergedList();
          });
        }
      }
      
      // If there are no doctors at all
      if (doctorsSnapshot.docs.isEmpty) {
        _articlesPerDoctor.clear();
        _updateMergedList();
      }
    });
  }

  void _updateMergedList() {
    List<Map<String, dynamic>> merged = [];
    for (final articles in _articlesPerDoctor.values) {
      merged.addAll(articles);
    }
    
    // Sort by created_at descending
    merged.sort((a, b) {
      final Timestamp? timeA = a['created_at'] as Timestamp?;
      final Timestamp? timeB = b['created_at'] as Timestamp?;
      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1;
      if (timeB == null) return -1;
      return timeB.compareTo(timeA); // descending
    });
    
    edukasiList.value = merged;
    isLoading.value = false;
  }

  @override
  void onClose() {
    _doctorsSubscription?.cancel();
    for (final sub in _doctorEdukasiSubscriptions.values) {
      sub.cancel();
    }
    super.onClose();
  }
}
