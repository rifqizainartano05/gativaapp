import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class EdukasiDokterController extends GetxController {
  // Manual Tab Controllers
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final imageUrlController = TextEditingController();

  // PDF Tab Controllers
  final pdfTitleController = TextEditingController();
  final Rx<File?> selectedPdfFile = Rx<File?>(null);

  // Link Tab Controllers
  final linkTitleController = TextEditingController();
  final linkUrlController = TextEditingController();

  final isLoading = false.obs;
  final loadingMessage = ''.obs;
  final currentDoctorName = 'Dokter'.obs;
  final RxString searchQuery = ''.obs;

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  @override
  void onInit() {
    super.onInit();
    _loadDoctorName();
  }

  Future<void> _loadDoctorName() async {
    currentDoctorName.value = await _getDoctorName();
  }

  Future<String> _getDoctorName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('mobile')
          .doc('roles')
          .collection('dokter')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return doc.data()?['name'] ?? 'Dokter';
      }
    }
    return 'Dokter';
  }

  Future<String> _summarizeWithGroq(String text) async {
    const apiKey = 'YOUR_API_KEY_HERE';
    const url = 'https://api.groq.com/openai/v1/chat/completions';
    
    // Batasi teks agar tidak melebihi limit token (misal ambil 4000 karakter pertama)
    String safeText = text.length > 4000 ? text.substring(0, 4000) : text;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content': 'Anda adalah asisten medis. Tugas Anda merangkum poin UTAMA dari teks berikut ke dalam 2-3 kalimat singkat yang padat dan jelas untuk pasien dalam bahasa Indonesia. JANGAN sebutkan "Berikut adalah ringkasan" atau kalimat pengantar lainnya, langsung ke intinya saja.'
            },
            {
              'role': 'user',
              'content': 'Buat ringkasan dari konten berikut:\n\n$safeText'
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        print('Groq error: ${response.body}');
        return 'Gagal membuat ringkasan (Error ${response.statusCode})';
      }
    } catch (e) {
      print('Groq exception: $e');
      return 'Gagal membuat ringkasan karena gangguan jaringan.';
    }
  }

  Future<void> pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        selectedPdfFile.value = File(result.files.single.path!);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih file PDF', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void tambahEdukasiManual() async {
    if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Judul dan Konten wajib diisi!', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    loadingMessage.value = 'Menyimpan...';
    try {
      String docName = await _getDoctorName();
      await FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(FirebaseAuth.instance.currentUser!.uid).collection('edukasi').add({
        'type': 'manual',
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'imageUrl': imageUrlController.text.trim().isEmpty ? null : imageUrlController.text.trim(),
        'doctor_name': docName,
        'created_at': FieldValue.serverTimestamp(),
      });
      
      _onSuccess();
    } catch (e) {
      _onError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void tambahEdukasiPdf() async {
    if (pdfTitleController.text.trim().isEmpty || selectedPdfFile.value == null) {
      Get.snackbar('Error', 'Judul dan File PDF wajib diisi!', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      String docName = await _getDoctorName();
      
      // 1. Ekstrak teks dari PDF
      loadingMessage.value = 'Membaca isi PDF...';
      String extractedText = '';
      try {
        final PdfDocument document = PdfDocument(inputBytes: selectedPdfFile.value!.readAsBytesSync());
        extractedText = PdfTextExtractor(document).extractText();
        document.dispose();
      } catch (e) {
        print('Gagal ekstrak PDF: $e');
      }

      // 2. Buat ringkasan dengan Groq
      String summary = '';
      if (extractedText.isNotEmpty) {
        loadingMessage.value = 'Membuat ringkasan AI (Groq)...';
        summary = await _summarizeWithGroq(extractedText);
      } else {
        summary = 'Tidak dapat mengekstrak teks dari PDF ini.';
      }

      // 3. Upload PDF to Storage
      loadingMessage.value = 'Mengunggah file PDF...';
      String fileName = 'edukasi_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      Reference ref = FirebaseStorage.instance.ref().child('edukasi_files').child(fileName);
      UploadTask uploadTask = ref.putFile(selectedPdfFile.value!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 4. Save to Firestore
      loadingMessage.value = 'Menyimpan data...';
      await FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(FirebaseAuth.instance.currentUser!.uid).collection('edukasi').add({
        'type': 'pdf',
        'title': pdfTitleController.text.trim(),
        'fileUrl': downloadUrl,
        'summary': summary,
        'doctor_name': docName,
        'created_at': FieldValue.serverTimestamp(),
      });
      
      _onSuccess();
    } catch (e) {
      _onError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void tambahEdukasiLink() async {
    if (linkTitleController.text.trim().isEmpty || linkUrlController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Judul dan Link wajib diisi!', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      String docName = await _getDoctorName();
      
      // 1. Ambil teks dari URL
      loadingMessage.value = 'Menganalisis tautan...';
      String extractedText = '';
      try {
        final response = await http.get(Uri.parse(linkUrlController.text.trim())).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final document = parse(response.body);
          // Hapus tag script dan style agar AI tidak merangkum kode JS/CSS
          document.querySelectorAll('script, style').forEach((e) => e.remove());
          extractedText = document.body?.text.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
        }
      } catch (e) {
        print('Gagal ekstrak teks dari tautan: $e');
      }

      // 2. Buat ringkasan dengan Groq
      String summary = '';
      if (extractedText.isNotEmpty && extractedText.length > 50) {
        loadingMessage.value = 'Membuat ringkasan AI (Groq)...';
        summary = await _summarizeWithGroq(extractedText);
      } else {
        summary = 'Tidak dapat menemukan konten teks yang cukup pada tautan ini.';
      }

      // 3. Save to Firestore
      loadingMessage.value = 'Menyimpan data...';
      await FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(FirebaseAuth.instance.currentUser!.uid).collection('edukasi').add({
        'type': 'link',
        'title': linkTitleController.text.trim(),
        'linkUrl': linkUrlController.text.trim(),
        'summary': summary,
        'doctor_name': docName,
        'created_at': FieldValue.serverTimestamp(),
      });
      
      _onSuccess();
    } catch (e) {
      _onError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _onSuccess() {
    Get.back(); // close the form
    
    // Tampilkan custom dialog sukses
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -40,
                top: -40,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 150,
                    color: Colors.green.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Sukses!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Edukasi berhasil ditambahkan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
    
    // Clear all inputs
    titleController.clear();
    contentController.clear();
    imageUrlController.clear();
    pdfTitleController.clear();
    selectedPdfFile.value = null;
    linkTitleController.clear();
    linkUrlController.clear();
  }

  void _onError(String errorMsg) {
    Get.snackbar('Error', 'Gagal menambahkan data: $errorMsg', backgroundColor: Colors.red, colorText: Colors.white);
  }

  void hapusEdukasi(String id, Map<String, dynamic> data) async {
    try {
      // Delete file from storage if type is pdf
      if (data['type'] == 'pdf' && data['fileUrl'] != null) {
        try {
          Reference ref = FirebaseStorage.instance.refFromURL(data['fileUrl']);
          await ref.delete();
        } catch (e) {
          // Ignore if file doesn't exist
        }
      }

      await FirebaseFirestore.instance.collection('mobile').doc('roles').collection('dokter').doc(FirebaseAuth.instance.currentUser!.uid).collection('edukasi').doc(id).delete();
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -40,
                  top: -40,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      Icons.delete_sweep,
                      size: 150,
                      color: Colors.red.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Berhasil',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Artikel edukasi berhasil dihapus secara permanen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus data', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    imageUrlController.dispose();
    pdfTitleController.dispose();
    linkTitleController.dispose();
    linkUrlController.dispose();
    super.onClose();
  }
}
