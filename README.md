# 🛡️ Gativa (Garda Preventiva)

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-%23039BE5.svg?style=for-the-badge&logo=firebase" alt="Firebase" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <br/><br/>
  <strong>Aplikasi Pemantauan dan Pencegahan Kesehatan Kardiovaskular Berbasis Flutter</strong>
</div>

---

## 🌟 Apa itu Gativa?

**Gativa (Garda Preventiva)** hadir sebagai solusi inovatif di era digital untuk menjaga kesehatan jantung Anda dan orang tercinta. Gativa adalah aplikasi pintar yang dirancang khusus untuk memantau, mencegah, dan mengontrol risiko **penyakit kardiovaskular** melalui pemantauan konsumsi natrium (garam) harian yang akurat. 

Dengan memadukan **Kecerdasan Buatan (AI)** untuk pemindaian label makanan dan **Konektivitas Cerdas** untuk keluarga, Gativa bukan sekadar aplikasi pencatat, melainkan asisten kesehatan pribadi yang selalu mendampingi Anda menuju gaya hidup yang lebih sehat.

---

## ✨ Fitur Unggulan

### 🔍 Lensa Pintar (Pemindaian Cerdas)
Ucapkan selamat tinggal pada perhitungan manual yang merepotkan!
- **Teknologi OCR Canggih**: Didukung oleh *Google ML Kit*, cukup arahkan kamera ke label Informasi Nilai Gizi pada kemasan makanan. Gativa akan mendeteksi kandungan natrium secara *real-time* dan otomatis!
- **Rekomendasi Pintar**: Gativa menyediakan katalog makanan alternatif untuk membantu Anda mengganti pilihan tinggi natrium dengan opsi yang jauh lebih sehat.

### 👥 Pemantauan Grup Keluarga
Kesehatan adalah perjalanan bersama. Jaga orang tua, anak, dan kerabat Anda dalam satu genggaman.
- **Koneksi Radar Cerdas**: Hubungkan perangkat anggota keluarga dengan mulus melalui **Nearby Connections** (Bluetooth/Wi-Fi jarak dekat) atau cukup pindai **QR Code**.
- **Real-Time Monitoring**: Pantau persentase asupan natrium harian seluruh anggota keluarga dari layar Anda.
- **Haptic Reminder**: Kirim peringatan kasih sayang melalui tombol pintar "INGATKAN!". Perangkat anggota keluarga akan bergetar, memberi sinyal waspada ketika batas konsumsi natrium harian telah terlampaui.

### 👩‍⚕️ Konsultasi Terintegrasi
Tidak perlu bingung mencari jawaban. Konsultasikan langsung dengan ahlinya!
- **Live Chat Medis**: Diskusi *real-time* dan interaktif dengan konsultan gizi atau tenaga kesehatan profesional.
- **Analisis Mendalam**: Tenaga kesehatan memiliki akses untuk melihat riwayat grafik konsumsi natrium pasien (mingguan, bulanan, tahunan) guna memberikan diagnosis dan saran yang presisi.

### 📊 Dasbor Analitik Visual
Pahami pola konsumsi Anda dengan mudah melalui visualisasi data yang memukau.
- Grafik interaktif *(Fl_Chart)* menyajikan rekapitulasi kesehatan Anda dalam format Harian, Mingguan, Bulanan, hingga Tahunan.

---

## 🚀 Mulai Menggunakan Gativa

### Persyaratan Sistem
Pastikan perangkat keras dan lunak Anda sudah siap:
- **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (Versi ^3.11.5 atau lebih baru)
- **Dart SDK**
- **Android Studio** atau **Visual Studio Code**
- **Perangkat Android Fisik** (Sangat direkomendasikan agar fitur Kamera OCR, Nearby Connections, dan Haptic Feedback berjalan optimal).

### Langkah Instalasi

1. **Clone Repository:**
   ```bash
   git clone https://github.com/rifqizainartano05/gativaapp.git
   ```

2. **Masuk ke Direktori Project:**
   ```bash
   cd gativa
   ```

3. **Unduh Dependensi:**
   ```bash
   flutter pub get
   ```

4. **Jalankan Aplikasi:**
   ```bash
   flutter run
   ```

---

## 🛠️ Stack Teknologi & Library Utama

Gativa dibangun menggunakan teknologi mutakhir untuk memastikan performa yang cepat, aman, dan memanjakan mata:

- **State Management & Routing**: `get` (GetX)
- **Layanan Cloud & Database**: `firebase_core`, `firebase_auth`, `cloud_firestore`
- **Machine Learning (AI)**: `google_mlkit_text_recognition`, `google_mlkit_image_labeling`
- **Integrasi Perangkat Keras**: `camera`, `mobile_scanner`, `qr_flutter`
- **Konektivitas Jaringan**: `nearby_connections`
- **Data & Visualisasi**: `fl_chart`
- **UI & Animasi**: `flutter_spinkit`, `google_fonts`

*(Daftar pustaka selengkapnya dapat dilihat pada file `pubspec.yaml`)*

---

<div align="center">
  <em>Dikembangkan dengan penuh dedikasi untuk masa depan keluarga yang lebih sehat. ❤️</em>
</div>