<div align="center">
  <img src="assets/images/logo.png" alt="Gativa Logo" width="120" />
  <h1>Gativa (Garda Preventiva)</h1>
  <p><strong>Aplikasi Pemantauan dan Pencegahan Kesehatan Kardiovaskular Berbasis Flutter</strong></p>

  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](https://firebase.google.com)
  [![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
</div>

<br/>

**Gativa (Garda Preventiva)** adalah aplikasi inovatif yang dirancang khusus untuk memantau, mencegah, dan mengontrol risiko penyakit kardiovaskular melalui pemantauan konsumsi natrium (garam) harian yang ketat dan akurat. Dilengkapi dengan teknologi pemindaian pintar dan konektivitas grup, Gativa menjadi pendamping kesehatan andalan untuk Anda dan keluarga.

---

## ✨ Fitur Utama

### 🔍 Pemindaian Cerdas (Lensa Natrium)
- **Teknologi OCR (Optical Character Recognition)**: Pindai label Informasi Nilai Gizi pada kemasan makanan dengan kamera secara *real-time* untuk mendeteksi kandungan natrium otomatis (didukung oleh *Google ML Kit*).
- **Penghematan Otomatis**: Katalog makanan alternatif yang memungkinkan Anda mengganti makanan tinggi natrium dengan opsi sehat dan langsung memotong grafik konsumsi.

### 👥 Pemantauan Grup Keluarga (Anggota)
- **Koneksi Radar Cerdas**: Tambahkan anggota keluarga melalui teknologi **Nearby Connections** (Bluetooth/Wi-Fi jarak dekat) tanpa ribet, atau dengan pindai **QR Code**.
- **Real-Time Monitoring**: Pantau persentase konsumsi natrium harian anggota keluarga Anda.
- **Haptic Reminder**: Tombol pintar "INGATKAN!" dengan efek getaran perangkat asli untuk saling mengingatkan saat batas konsumsi natrium sudah waspada atau bahaya.

### 👩‍⚕️ Konsultasi Tenaga Kesehatan Terintegrasi
- **Chat Real-time**: Komunikasi dua arah yang responsif antara pasien dan konsultan gizi atau tenaga kesehatan (Nakes).
- **Akses Rekam Jejak**: Konsultan dapat melihat secara mendalam riwayat grafik natrium mingguan, bulanan, dan tahunan dari setiap pasiennya.

### 📊 Riwayat & Grafik Analitik
- Pantau tren konsumsi kesehatan Anda dan keluarga melalui grafik interaktif *(Fl_Chart)* yang memisahkan rekapitulasi secara Harian, Mingguan, Bulanan, dan Tahunan.

---

## 🚀 Cara Menjalankan Project (Getting Started)

### Persyaratan Sistem
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versi ^3.11.5 atau lebih baru)
- Dart SDK
- Android Studio / Visual Studio Code
- Perangkat Android fisik (sangat disarankan untuk menguji fitur kamera OCR, Nearby Connections, dan Haptic Feedback).

### Instalasi

1. **Clone repository ini:**
   ```bash
   git clone https://github.com/RifqiZain59/Gardapreventiva.git
   ```
2. **Masuk ke direktori project:**
   ```bash
   cd Gardapreventiva
   ```
3. **Unduh seluruh dependensi:**
   ```bash
   flutter pub get
   ```
4. **Jalankan aplikasi di perangkat:**
   ```bash
   flutter run
   ```

---

## 🛠️ Stack Teknologi & Library Utama

- **State Management & Routing**: `get` (GetX)
- **Backend & Database**: `firebase_core`, `firebase_auth`, `cloud_firestore`
- **Machine Learning**: `google_mlkit_text_recognition`, `google_mlkit_image_labeling`
- **Kamera & QR**: `camera`, `mobile_scanner`, `qr_flutter`
- **Konektivitas Sekitar**: `nearby_connections`
- **Visualisasi**: `fl_chart`
- **Animasi & UI**: `flutter_spinkit`, `google_fonts`

*(Lihat daftar lengkap di `pubspec.yaml`)*

---
<div align="center">
  <p><i>Dikembangkan dengan penuh dedikasi untuk masa depan keluarga yang lebih sehat. ❤️</i></p>
</div>