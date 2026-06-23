import 'package:get/get.dart';

class FaqController extends GetxController {
  final List<Map<String, String>> faqs = [
    {
      "question": "Berapa batas konsumsi natrium harian yang aman?",
      "answer": "WHO merekomendasikan asupan natrium tidak lebih dari 2.000 mg (setara dengan kurang dari 5 gram atau 1 sendok teh garam) per hari untuk orang dewasa."
    },
    {
      "question": "Bagaimana cara memindai barcode makanan?",
      "answer": "Buka tab Pindai di navigasi bawah, lalu arahkan kamera ke barcode kemasan makanan. Sistem kami akan secara otomatis membaca dan menampilkan kadar natriumnya."
    },
    {
      "question": "Apa itu Fitur Grup Pantauan?",
      "answer": "Fitur ini memungkinkan Anda memantau asupan natrium anggota grup, seperti orang tua, pasangan, anak, atau pendamping kesehatan, dan memberikan peringatan jika mereka mendekati batas harian."
    },
    {
      "question": "Bagaimana cara mengekspor laporan medis?",
      "answer": "Masuk ke halaman Profil, lalu ketuk 'Ekspor Laporan Medis'. Pilih rentang tanggal yang diinginkan, dan aplikasi akan menghasilkan file PDF yang dapat dibagikan."
    }
  ];
}
