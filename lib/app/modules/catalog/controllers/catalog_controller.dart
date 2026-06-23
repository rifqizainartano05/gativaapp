import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AlternativeFood {
  final String category;
  final String originalFood;
  final double originalSodium;
  final String alternativeFood;
  final double alternativeSodium;
  final String benefit;

  AlternativeFood({
    required this.category,
    required this.originalFood,
    required this.originalSodium,
    required this.alternativeFood,
    required this.alternativeSodium,
    required this.benefit,
  });

  double get savings => originalSodium - alternativeSodium;
}

class CatalogController extends GetxController {
  final RxString searchQuery = "".obs;
  final RxString selectedCategory = "Semua".obs;
  
  final RxList<String> categories = <String>["Semua"].obs;

  final RxList<AlternativeFood> allAlternatives = <AlternativeFood>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadRealData();
  }

  void _loadRealData() {
    FirebaseFirestore.instance
        .collection('website')
        .doc('rifqizainartano50904@gmail.com')
        .collection('katalog_makanan')
        .snapshots()
        .listen((snapshot) {
      allAlternatives.clear();
      Set<String> uniqueCategories = {"Semua"};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        String altFood = data['makanan_alternatif'] ?? '';
        String origFood = data['makanan_asli'] ?? '';
        double savings = double.tryParse(data['hemat_natrium_mg'].toString()) ?? 0;
        
        String cat = altFood.isNotEmpty ? altFood : 'Lainnya';
        uniqueCategories.add(cat);

        allAlternatives.add(AlternativeFood(
          category: cat,
          originalFood: origFood,
          originalSodium: savings, 
          alternativeFood: altFood,
          alternativeSodium: 0,
          benefit: "Alternatif sehat ini dapat menghemat natrium sebanyak ${savings.toInt()} mg.",
        ));
      }
      categories.assignAll(uniqueCategories.toList());
      if (!categories.contains(selectedCategory.value)) {
         selectedCategory.value = "Semua";
      }
    });
  }

  List<AlternativeFood> get filteredAlternatives {
    return allAlternatives.where((alt) {
      bool matchCategory = selectedCategory.value == "Semua" || alt.category == selectedCategory.value;
      bool matchSearch = alt.originalFood.toLowerCase().contains(searchQuery.value.toLowerCase()) || 
                         alt.alternativeFood.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  void selectAlternativeForCalculator(AlternativeFood food) {
    Get.snackbar(
      "Dihitung", 
      "Memproyeksikan ${food.alternativeFood} ke dalam asupan harian...",
      backgroundColor: Get.theme.scaffoldBackgroundColor
    );
  }
}
