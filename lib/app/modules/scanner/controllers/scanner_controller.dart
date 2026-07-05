import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScannerController extends GetxController {
  // Mode Camera
  final RxBool isCameraInitialized = false.obs;
  final RxBool isCameraSupported = false.obs;
  final RxBool isCameraActive = true.obs;
  CameraController? cameraController;

  // OCR state
  final RxBool isScanning = false.obs;
  final RxBool hasResult = false.obs;
  final RxBool isFromMission = false.obs;

  void toggleCamera() {
    isCameraActive.value = !isCameraActive.value;
    if (isCameraActive.value) {
      cameraController?.resumePreview();
    } else {
      cameraController?.pausePreview();
    }
  }

  // Timer state
  final RxInt countdown = 15.obs;
  Timer? _closeTimer;

  // Variabel ekstraksi
  final RxString scannedFoodName = "".obs;
  final RxString scannedServingSize = "".obs;
  final RxDouble scannedSodiumPerServing = 0.0.obs;
  final RxDouble scannedServingsPerPack = 0.0.obs;
  final RxDouble servingsMultiplier = 1.0.obs;

  final RxString _packageName = "".obs;

  double get totalCalculatedSodium =>
      scannedSodiumPerServing.value * servingsMultiplier.value;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is String) {
        _packageName.value = Get.arguments as String;
      } else if (Get.arguments is Map) {
        final args = Get.arguments as Map;
        _packageName.value = args['name'] ?? '';
        isFromMission.value = args['isFromMission'] == true;
      }
    }
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFFFFFFFF), // Putih
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    _initCamera();
  }

  @override
  void onClose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    cameraController?.dispose();
    _closeTimer?.cancel();
    super.onClose();
  }

  Future<void> _initCamera() async {
    try {
      var status = await Permission.camera.request();
      if (!status.isGranted) {
        isCameraSupported.value = false;
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await cameraController!.initialize();
        isCameraInitialized.value = true;
        isCameraSupported.value = true;
      } else {
        isCameraSupported.value = false;
      }
    } catch (e) {
      isCameraSupported.value = false;
      print("Camera error: $e");
    }
  }

  Future<void> performScan({required bool simulate}) async {
    if (cameraController == null || !cameraController!.value.isInitialized)
      return;

    isScanning.value = true;
    hasResult.value = false;

    try {
      // Ambil gambar dari kamera
      final XFile imageFile = await cameraController!.takePicture();

      // Gunakan ML Kit Text Recognizer
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      String allText = recognizedText.text.toLowerCase();

      // Regex untuk mendeteksi Sodium/Natrium/Garam dan angkanya
      // Skip semua karakter non-angka hingga menemukan angka pertama.
      RegExp regExp = RegExp(
        r'(?:monatrium|natrium|sodium|garam)[^\d]*?([0-9]+(?:\.[0-9]+)?)',
        caseSensitive: false,
      );
      final match = regExp.firstMatch(allText);

      if (match != null && match.groupCount >= 1) {
        String numStr = match.group(1)!;
        double sodiumValue = double.tryParse(numStr) ?? 0.0;
        scannedSodiumPerServing.value = sodiumValue;
        scannedFoodName.value = _packageName.value.isNotEmpty
            ? _packageName.value
            : "Produk Pindaian";
        scannedServingSize.value = "1 Sajian";
        scannedServingsPerPack.value = 1.0; // Default 1 sajian
      } else {
        // Jika gagal deteksi otomatis
        scannedSodiumPerServing.value = 0.0;
        scannedFoodName.value = _packageName.value.isNotEmpty
            ? _packageName.value
            : "Tidak Terdeteksi";
        scannedServingSize.value = "-";
        scannedServingsPerPack.value = 1.0;
      }

      servingsMultiplier.value = 1.0;
      await textRecognizer.close();
    } catch (e) {
      print("Error scanning image: $e");
      scannedSodiumPerServing.value = 0.0;
      scannedFoodName.value = "Error Kamera";
    } finally {
      isScanning.value = false;

      try {
        await cameraController?.pausePreview();
      } catch (e) {
        print("Cannot pause preview: $e");
      }

      Get.toNamed('/scanner-result', arguments: {
        'foodName': scannedFoodName.value,
        'servingSize': scannedServingSize.value,
        'sodiumPerServing': scannedSodiumPerServing.value,
        'servingsPerPack': scannedServingsPerPack.value,
        'isFromMission': isFromMission.value,
      })?.then((_) {
        if (isFromMission.value) {
          Get.back();
          return;
        }
        // Resume preview when returning from result page
        resetScan();
      });
    }
  }

  void startCountdown() {
    countdown.value = 15; // Halaman tertutup otomatis dalam 15 detik
    _closeTimer?.cancel();
    _closeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 1) {
        countdown.value--;
      } else {
        resetScan();
      }
    });
  }

  void resetScan() async {
    _closeTimer?.cancel();
    // Nyalakan ulang preview kamera
    try {
      await cameraController?.resumePreview();
    } catch (e) {
      print("Cannot resume preview: $e");
    }
  }

  Future<void> logScannedFood() async {
    _closeTimer?.cancel();

    // Auto-save to Firebase
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final sodiumValue = totalCalculatedSodium;

        final batch = FirebaseFirestore.instance.batch();
        final userRef = Get.find<AuthService>().getUserReference(user.uid);

        final labelRef = userRef.collection('label gizi makanan').doc();
        batch.set(labelRef, {
          'name': scannedFoodName.value,
          'type': 'Kemasan',
          'natrium': sodiumValue,
          'created_at': Timestamp.now(),
        });

        batch.update(userRef, {'natrium': FieldValue.increment(sodiumValue)});

        await batch.commit();

        Get.snackbar(
          'Berhasil Disimpan',
          '${scannedFoodName.value} otomatis ditambahkan ke catatan harian.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print("Error saving to Firestore: $e");
    }

    // Prepare the data map to match Lensa Natrium Detail format
    final itemData = {
      'name': scannedFoodName.value,
      'natrium': totalCalculatedSodium,
      'type': 'Kemasan',
    };

    Get.offAndToNamed('/lensa-natrium-detail', arguments: itemData);
  }
}
