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
      try {
        cameraController?.setFocusMode(FocusMode.auto);
        if (isFlashOn.value) {
          cameraController?.setFlashMode(FlashMode.torch);
        } else {
          cameraController?.setFlashMode(FlashMode.off);
        }
      } catch (e) {
        print("Error re-applying focus in toggleCamera: $e");
      }
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
  final RxList<Rect> recognizedBlocks = <Rect>[].obs;

  final RxString _packageName = "".obs;

  double get totalCalculatedSodium =>
      scannedSodiumPerServing.value * scannedServingsPerPack.value;

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
          ResolutionPreset
              .max, // Resolusi maksimal untuk OCR yang lebih akurat pada bungkus melengkung
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

      String bestServingSize = "";
      Map<String, int> servingSizeCounts = {};
      double bestServingsPerPack = 0.0;

      while (isScanning.value && !hasResult.value) {
        if (!isScanning.value) break; // Berhenti jika dibatalkan

        // Pastikan kamera terus mencari fokus secara otomatis tanpa titik manual
        try {
          await cameraController?.setFocusMode(FocusMode.auto);
        } catch (e) {
          // ignore
        }

        // Ambil gambar dari kamera secara berulang
        final XFile imageFile = await cameraController!.takePicture();
        final inputImage = InputImage.fromFilePath(imageFile.path);

        final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage,
        );

        List<Rect> blocks = [];
        final keywordRegex = RegExp(
          r'(informasi|gizi|nutrition|takaran|sajian|serving|natrium|sodium|garam|salt|mg|gram|kemasan|wadah|bungkus|container|pack|jumlah|perkemasan|persajian|porsi|\b(g|gr|ml|mcg)\b|[+\-<>=_±]*\s*[0-9]+(?:[.,\s]*[0-9]+)*\s*%?)',
          caseSensitive: false,
        );
        for (var block in recognizedText.blocks) {
          if (keywordRegex.hasMatch(block.text)) {
            blocks.add(block.boundingBox);
          }
        }
        recognizedBlocks.value = blocks;

        String fullText = recognizedText.text.toLowerCase().replaceAll(
          '\n',
          ' ',
        );

        // Validasi harus ada salah satu dari kata kunci ini agar dikenali sebagai area Informasi Gizi
        // Diperbarui: Dikembalikan seperti semula, kata "Informasi Gizi" / "Nutrition Facts" WAJIB ada di layar
        RegExp infoGiziRegex = RegExp(
          r'informasi\s*nilai\s*gizi|nutrition\s*facts|nilai\s*gizi|takaran\s*saji|sajian\s*per\s*kemasan|sajian\s*perkemasan',
          caseSensitive: false,
        );
        if (!infoGiziRegex.hasMatch(fullText)) {
          await Future.delayed(const Duration(milliseconds: 300));
          continue; // Lewati jika bukan area gizi
        }

        double foundSodium = -1.0;
        double backupSodium = -1.0;

        // Extract Takaran Saji / Serving Size
        // Diperbarui: Mampu melewati teks dalam kurung seperti (serving size) dan menangkap unit sekunder seperti 1 bungkus (25 gram)
        RegExp servingSizeRegex = RegExp(
          r'(?:takaran\s*saji|takaran\s*sajian|takaran|ukuran\s*saji|serving\s*size|jumlah\s*persajian|jumlah\s*per\s*sajian|sajian|per\s*sajian)\s*(?:\s*[({\[][^)}\]]*[)}\]]\s*)?[:()/{}\[\]\-\\\|±+<>=_~]*\s*([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)*)(?:\s*(bungkus|keping|sajian|sejian|porsi|gram|cup|sdm|sdt|bks|gr|ml|oz|g|q|9)(?:\s*[({\[]?\s*[0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)*\s*(?:gram|g|gr|ml|mcg)\s*[)}\]]?)?|\s+([a-z]{1,7}))\b',
          caseSensitive: false,
        );
        RegExp servingSizeBeforeRegex = RegExp(
          r'(?<=[\s:(/±+<>=_~]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)*)(?:\s*(bungkus|keping|sajian|sejian|porsi|gram|cup|sdm|sdt|bks|gr|ml|oz|g|q|9)(?:\s*[({\[]?\s*[0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)*\s*(?:gram|g|gr|ml|mcg)\s*[)}\]]?)?|\s+([a-z]{1,7}))\b\s*(?:\s*[({\[][^)}\]]*[)}\]]\s*)?[:()/{}\[\]\-\\\|±+<>=_~]*\s*(?:takaran\s*saji|takaran\s*sajian|takaran|ukuran\s*saji|serving\s*size|jumlah\s*persajian|jumlah\s*per\s*sajian|sajian|per\s*sajian)',
          caseSensitive: false,
        );
        var ssMatch = servingSizeRegex.firstMatch(fullText) ?? servingSizeBeforeRegex.firstMatch(fullText);
        if (ssMatch != null) {
          String numStr = ssMatch
              .group(1)!
              .replaceAll(',', '.')
              .replaceAll('o', '0')
              .replaceAll('O', '0')
              .replaceAll('l', '1')
              .replaceAll('I', '1')
              .replaceAll('i', '1')
              .replaceAll(' ', '');
          String unit = (ssMatch.groupCount >= 3 ? (ssMatch.group(2) ?? ssMatch.group(3)) : ssMatch.group(2)) ?? '';
          if (unit == 'q' || unit == '9' || unit == 'ng') unit = 'g'; // Fix common OCR typos for gram
          String newServingSize = "$numStr $unit";
          servingSizeCounts[newServingSize] = (servingSizeCounts[newServingSize] ?? 0) + 1;
        }

        String sppKeywords = r'(?:sajian\s*per\s*kemasan|sajian\s*perkemasan|sajian\s*per\s*wadah|sajian\s*per\s*bungkus|servings?\s*per\s*container|servings?\s*per\s*pack|jumlah\s*sajian\s*per\s*kemasan|jumlah\s*sajian|sajian|sejian|serving|takaran|porsi|perkemasan|kemasan)';
        // Diperbarui: Gunakan \s*[:()/{}\[\]\-\\\|±+<>=_~]*\s* agar mengabaikan simbol dan fokus mengambil angkanya
        RegExp sppRegex = RegExp(
          r'(?<=[\s:(/±+<>=_~]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)*)\b\s*[:()/{}\[\]\-\\\|±+<>=_~]*\s*' + sppKeywords,
          caseSensitive: false,
        );
        RegExp sppAfterRegex = RegExp(
          sppKeywords + r'\s*[:()/{}\[\]\-\\\|±+<>=_~]*\s*([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)*)\b',
          caseSensitive: false,
        );

        var sppMatch = sppRegex.firstMatch(fullText) ?? sppAfterRegex.firstMatch(fullText);

        if (sppMatch != null) {
          String numStr = sppMatch
              .group(1)!
              .replaceAll(',', '.')
              .replaceAll('o', '0')
              .replaceAll('O', '0')
              .replaceAll('l', '1')
              .replaceAll('I', '1')
              .replaceAll('i', '1')
              .replaceAll(' ', '');
          double val = double.tryParse(numStr) ?? -1.0;
          // Bebas tanpa batas maksimal angka dan tanpa mengunci desimal
          if (val > 0) {
            bestServingsPerPack = val;
          }
        }

        // Regex super dinamis agar "anti tangguh" terhadap tulisan buram
        // Diperbarui: Satuan mg kembali DIWAJIBKAN agar tidak salah tangkap angka lain, 
        // namun DIPERPINTAR: (1) Angka kebal terhadap spasi nyasar (misal '1 5 0' -> 150), 
        // (2) Satuan kebal terhadap spasi (misal 'm g', 'rn g').
        // Jarak diperlebar menjadi 60 agar angka yang letaknya jauh di kanan tabel tidak terlewat (jika terlewat, sistem malah membaca 'sodium' lain di komposisi).
        // Diperketat: Hanya mendeteksi garam, sodium, natrium, mononatrium glutamat, salt (dan typo-nya).
        // Diperbarui: Mendukung format "Garam (Natrium/Sodium)" atau apa pun di dalam kurung.
        RegExp sodiumRegex = RegExp(
          r'(?:garam\s*\(?[^)]*\)?|salt\s*\(?[^)]*\)?|natrium\s*/\s*sodium|sodium\s*/\s*natrium|mononatrium\s*glutamat|mononatrium\s*glumat|natrium|natriun|natriurn|natrum|nartium|nattium|natruim|n4trium|sodium|sodiun|sodiurn|s0dium|s0diun|garam|garan|salt).{0,60}?([0-9oOlI]+(?:[\s.,]*[0-9oOlI]+)*)\s*(m\s*g|m\s*c\s*g|m\s*q|rn\s*q|rri\s*q|rn\s*g|nn\s*g|ma\s*q|rn\s*s|n\s*g|r\s*n|m\s*e|m\s*9|m\s*8|n\s*9|rn\s*9|m\s*s|m\s*o)',
          caseSensitive: false,
        );

        var matches = sodiumRegex.allMatches(fullText);

        for (var m in matches) {
          // Koreksi salah ketik OCR pada angka
          String numStr = m
              .group(1)!
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
          // Bebas tanpa batas maksimal angka
          if (val >= 0) {
            if (unit.startsWith('m') ||
                unit.startsWith('r') ||
                unit.startsWith('n')) {
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

          // We require the same number to be read across 2 consecutive frames for fast and accurate scanning
          if (matchCount >= 2) {
            if (servingSizeCounts.isNotEmpty) {
              bestServingSize = servingSizeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
            }
            
            scannedSodiumPerServing.value = foundSodium;
            scannedFoodName.value = _packageName.value.isNotEmpty
                ? _packageName.value
                : "Produk Pindaian";
            scannedServingSize.value = bestServingSize;
            scannedServingsPerPack.value = bestServingsPerPack;
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
                                color: const Color(
                                  0xFF2E7D32,
                                ).withOpacity(0.05),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF2E7D32),
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Berhasil Mendeteksi!",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${foundSodium == foundSodium.toInt() ? foundSodium.toInt() : foundSodium} mg Natrium",
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Sajian per Kemasan: ${bestServingsPerPack == bestServingsPerPack.toInt() ? bestServingsPerPack.toInt() : bestServingsPerPack}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "Takaran Saji: $bestServingSize",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Memproses hasil pindai...",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
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

            await Future.delayed(const Duration(milliseconds: 1000));
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
        Get.toNamed(
          '/hasil-pindai-label',
          arguments: {
            'foodName': scannedFoodName.value,
            'servingSize': scannedServingSize.value,
            'sodiumPerServing': scannedSodiumPerServing.value,
            'servingsPerPack': scannedServingsPerPack.value,
            'isFromMission': isFromMission.value,
          },
        )?.then((_) {
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

      // Kembalikan fokus dan flash agar akurasi tetap tinggi setelah kembali dari hasil scan
      try {
        await cameraController?.setFocusMode(FocusMode.auto);
        if (isFlashOn.value) {
          await cameraController?.setFlashMode(FlashMode.torch);
        } else {
          await cameraController?.setFlashMode(FlashMode.off);
        }
      } catch (e) {
        print("Cannot re-apply focus/flash: $e");
      }

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

        final notifRef = userRef.collection('notifikasi').doc();
        batch.set(notifRef, {
          'title': 'Konsumsi Natrium Tercatat',
          'message': 'Anda baru saja merekam konsumsi sejumlah ${sodiumValue.toInt()} mg natrium.',
          'timestamp': Timestamp.now(),
          'isRead': false,
          'type': 'sistem',
        });

        await batch.commit();

        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -30,
                  child: Opacity(
                    opacity: 0.05,
                    child: Image.asset(
                      'assets/logo.png',
                      width: 150,
                      height: 150,
                    ),
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
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Berhasil Disimpan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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

                            // Prepare the data map to match Lensa Pintar Detail format
                            final itemData = {
                              'name': scannedFoodName.value,
                              'natrium': sodiumValue,
                              'type': 'Kemasan',
                            };

                            Get.offAndToNamed(
                              '/lensa-pintar-detail',
                              arguments: itemData,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Lanjut',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
          barrierDismissible: false,
        );
      } else {
        // user == null
        // Prepare the data map to match Lensa Pintar Detail format
        final itemData = {
          'name': scannedFoodName.value,
          'natrium': totalCalculatedSodium,
          'type': 'Kemasan',
        };
        Get.offAndToNamed('/lensa-pintar-detail', arguments: itemData);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                ),
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
