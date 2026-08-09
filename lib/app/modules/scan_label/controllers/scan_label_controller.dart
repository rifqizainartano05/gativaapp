import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:light/light.dart';
import 'dart:async';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanLabelController extends GetxController {
  // Mode Camera
  final RxBool isCameraInitialized = false.obs;
  final RxBool isCameraSupported = false.obs;
  final RxBool isCameraActive = true.obs;
  CameraController? cameraController;

  // OCR state
  final RxBool isScanning = false.obs;
  final RxBool hasResult = false.obs;
  final RxBool isFromMission = false.obs;
  final RxBool isFlashOn = true.obs;

  Light? _light;
  StreamSubscription<int>? _lightSubscription;
  bool _userToggledFlash = false;

  void toggleCamera() {
    isCameraActive.value = !isCameraActive.value;
    if (isCameraActive.value) {
      cameraController?.resumePreview();
    } else {
      cameraController?.pausePreview();
    }
  }

  void toggleFlash() async {
    if (cameraController == null) return;
    isFlashOn.value = !isFlashOn.value;
    _userToggledFlash = true; // User manual override
    try {
      if (isFlashOn.value) {
        await cameraController!.setFlashMode(FlashMode.torch);
      } else {
        await cameraController!.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      print("Error toggling flash: $e");
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
    _initLightSensor();
  }

  void _initLightSensor() {
    _light = Light();
    try {
      _lightSubscription = _light?.lightSensorStream.listen((int luxValue) {
        if (!isCameraInitialized.value || cameraController == null) return;
        
        // Auto-turn on flash if very dark (lux < 10) and user hasn't manually turned it off
        if (luxValue < 15 && !isFlashOn.value && !_userToggledFlash) {
          isFlashOn.value = true;
          cameraController!.setFlashMode(FlashMode.torch);
        } 
        // We do NOT auto-turn off the flash if it gets bright because the flash ITSELF makes it bright!
      });
    } catch (e) {
      print("Light sensor error: $e");
    }
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
          ResolutionPreset.max, // Resolusi maksimal untuk OCR yang lebih akurat pada bungkus melengkung
          enableAudio: false,
        );
        await cameraController!.initialize();
        
        // Mengaktifkan fokus otomatis dan pencahayaan (flash) agar hasil scan terang dan fokus
        try {
          await cameraController!.setFocusMode(FocusMode.auto);
          if (isFlashOn.value) {
            await cameraController!.setFlashMode(FlashMode.torch);
          } else {
            await cameraController!.setFlashMode(FlashMode.off);
          }
        } catch (e) {
          print("Tidak dapat mengatur fokus atau flash: $e");
        }

        isCameraInitialized.value = true;
        isCameraSupported.value = true;
        
        // Auto-start OCR hunting!
        startContinuousScan();
      } else {
        isCameraSupported.value = false;
      }
    } catch (e) {
      isCameraSupported.value = false;
      print("Camera error: $e");
    }
  }

  Future<void> startContinuousScan() async {
    if (cameraController == null || !cameraController!.value.isInitialized)
      return;

    if (isScanning.value) return; // Prevent multiple loops
    isScanning.value = true;
    hasResult.value = false;

    try {
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      double lastFoundSodium = -1.0;
      int matchCount = 0;

      while (isScanning.value && !hasResult.value) {
        if (!isScanning.value) break; // Berhenti jika dibatalkan

        // Ambil gambar dari kamera secara berulang
        final XFile imageFile = await cameraController!.takePicture();
        final inputImage = InputImage.fromFilePath(imageFile.path);

        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        String fullText = recognizedText.text.toLowerCase().replaceAll('\n', ' ');

        // Validasi harus ada tulisan informasi nilai gizi atau nutrition facts
        RegExp infoGiziRegex = RegExp(r'informasi\s*nilai\s*gizi|nutrition\s*facts|nilai\s*gizi', caseSensitive: false);
        if (!infoGiziRegex.hasMatch(fullText)) {
          await Future.delayed(const Duration(milliseconds: 300));
          continue; // Lewati jika bukan tabel gizi
        }

        double foundSodium = -1.0;
        double backupSodium = -1.0;

        // Regex super dinamis agar "anti tangguh" terhadap tulisan buram
        // Dihapus satuan "g" agar tidak salah membaca nilai Protein/Lemak/Karbohidrat
        RegExp sodiumRegex = RegExp(
          r'(?:garam\s*\(?\s*natrium\s*\)?|salt\s*\(?\s*sodium\s*\)?|mononatrium\s*glutamat|mononatrium\s*glumat|natrium|natriun|natriurn|natrum|nartium|nattium|natruim|n4trium|sodium|sodiun|sodiurn|s0dium|s0diun|garam|garan|salt|glutamat|glumat).*?([0-9oOlI]+(?:[\s.,]*[0-9oOlI]+)*)\s*(mg|mcg|mq|rnq|rriq|rng|nng|maq|rns|ng|rn|me)',
          caseSensitive: false,
        );

        var matches = sodiumRegex.allMatches(fullText);

        for (var m in matches) {
          // Koreksi salah ketik OCR pada angka
          String numStr = m.group(1)!
              .replaceAll(',', '.')
              .replaceAll('o', '0')
              .replaceAll('O', '0')
              .replaceAll('l', '1')
              .replaceAll('I', '1')
              .replaceAll(' ', '');
              
          String unit = m.group(2) ?? '';

          String textAfter = fullText.substring(m.end).trimLeft();
          if (unit == '%' || textAfter.startsWith('%')) {
            continue;
          }

          double val = double.tryParse(numStr) ?? -1.0;
          if (val >= 0 && val < 5000) { // Natrium per sajian jarang > 5000mg
            if (unit.startsWith('m') || unit.startsWith('r') || unit.startsWith('n')) {
              foundSodium = val;
              break;
            } else {
              if (backupSodium < 0) backupSodium = val;
            }
          }
        }
        
        if (foundSodium < 0 && backupSodium >= 0) {
          foundSodium = backupSodium;
        }

        if (foundSodium >= 0) {
          if (foundSodium == lastFoundSodium) {
            matchCount++;
          } else {
            lastFoundSodium = foundSodium;
            matchCount = 1;
          }

          // We require the same number to be read across 3 consecutive frames for fast and accurate scanning
          if (matchCount >= 3) {
            scannedSodiumPerServing.value = foundSodium;
            scannedFoodName.value = _packageName.value.isNotEmpty
                ? _packageName.value
                : "Produk Pindaian";
            scannedServingSize.value = "1 Sajian";
            scannedServingsPerPack.value = 1.0;
            hasResult.value = true;
            
            // Tampilkan popup menengah
            Get.dialog(
              Align(
                alignment: const Alignment(0, -0.35),
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    width: Get.width * 0.8,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        alignment: Alignment.center,
                        children: [
                        // Watermark Icon
                        Positioned(
                          right: -40,
                          top: -40,
                          child: Transform.rotate(
                            angle: -0.2,
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 150,
                              color: const Color(0xFF2E7D32).withOpacity(0.05),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 60),
                            const SizedBox(height: 16),
                            const Text(
                              "Berhasil Mendeteksi!",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${foundSodium.toInt()} mg",
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Memproses hasil pindai...",
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            barrierDismissible: false,
          );

            await Future.delayed(const Duration(milliseconds: 1500));
            if (Get.isDialogOpen ?? false) {
              Get.back();
            }

            break; // Keluar dari loop jika sukses
          }
        }

        // Jeda sepersekian detik sebelum mengambil foto lagi agar UI tidak freeze
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (!isScanning.value) {
        await textRecognizer.close();
        return;
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

      if (hasResult.value) {
        Get.toNamed('/hasil-pindai-label', arguments: {
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
      startContinuousScan();
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

        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -30,
                  child: Opacity(
                    opacity: 0.05,
                    child: Image.asset('assets/logo.png', width: 150, height: 150),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Berhasil Disimpan',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${scannedFoodName.value} otomatis ditambahkan ke catatan harian.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back(); // tutup dialog
                            
                            // Prepare the data map to match Lensa Natrium Detail format
                            final itemData = {
                              'name': scannedFoodName.value,
                              'natrium': sodiumValue,
                              'type': 'Kemasan',
                            };
                        
                            Get.offAndToNamed('/lensa-natrium-detail', arguments: itemData);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Lanjut', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
      } else {
        // user == null
        // Prepare the data map to match Lensa Natrium Detail format
        final itemData = {
          'name': scannedFoodName.value,
          'natrium': totalCalculatedSodium,
          'type': 'Kemasan',
        };
        Get.offAndToNamed('/lensa-natrium-detail', arguments: itemData);
      }
    } catch (e) {
      print("Error saving to Firestore: $e");
      
      final itemData = {
        'name': scannedFoodName.value,
        'natrium': totalCalculatedSodium,
        'type': 'Kemasan',
      };
      Get.offAndToNamed('/lensa-natrium-detail', arguments: itemData);
    }
  }

  void _showFailedDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Watermark Icon di background
                Positioned(
                  right: -40,
                  bottom: -40,
                  child: Opacity(
                    opacity: 0.05,
                    child: Icon(
                      Icons.warning_rounded,
                      size: 200,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.document_scanner_rounded,
                          color: Colors.orange.shade600,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Gagal Mendeteksi!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Pastikan angka disandingkan dengan jelas di sebelah tulisan Garam, Sodium, Natrium, atau Mononatrium Glumat. Coba atur pencahayaan atau fokus kamera.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            resetScan();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Coba Lagi",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
