import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isDialogShowing = false;

  Future<NetworkService> init() async {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    return this;
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final isOffline = results.isEmpty || results.every((r) => r == ConnectivityResult.none);

    if (isOffline) {
      if (!_isDialogShowing) {
        _isDialogShowing = true;
        _showNoNetworkDialog();
      }
    } else {
      if (_isDialogShowing) {
        _isDialogShowing = false;
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      }
    }
  }

  void _showNoNetworkDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Opacity(
                    opacity: 0.05,
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 150,
                      color: Colors.red.shade900,
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
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.signal_wifi_connected_no_internet_4_rounded,
                          color: Colors.red.shade600,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Koneksi Terputus",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Maaf, Anda sedang tidak terhubung ke jaringan internet. Silakan periksa koneksi data atau WiFi Anda.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
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

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
