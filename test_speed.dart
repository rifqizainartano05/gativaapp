void main() {
  String badText = "takaran saji sajian per kemasan tidak ada angkanya sama sekali dan ini panjang banget dan tidak ada g atau gram nya " * 50;
  
  RegExp oldServingSizeRegex = RegExp(
    r'(?:takaran\s*saji|serving\s*size|jumlah\s*persajian).{0,40}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(g|gr|ml|oz|cup|sdm|sdt|keping|bks|bungkus|porsi|sajian|sejian|gram)',
    caseSensitive: false,
  );

  RegExp newServingSizeRegex = RegExp(
    r'(?:takaran\s*saji|serving\s*size|jumlah\s*persajian)(?:(?!(?:g|gr|ml|oz|cup|sdm|sdt|keping|bks|bungkus|porsi|sajian|sejian|gram)\b).){0,40}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(g|gr|ml|oz|cup|sdm|sdt|keping|bks|bungkus|porsi|sajian|sejian|gram)',
    caseSensitive: false,
  );

  print("Testing oldServingSizeRegex...");
  Stopwatch sw = Stopwatch()..start();
  for(int i=0; i<100; i++) {
    oldServingSizeRegex.hasMatch(badText);
  }
  print("oldServingSizeRegex took ${sw.elapsedMilliseconds} ms");

  print("Testing newServingSizeRegex...");
  sw.reset();
  for(int i=0; i<100; i++) {
    newServingSizeRegex.hasMatch(badText);
  }
  print("newServingSizeRegex took ${sw.elapsedMilliseconds} ms");
}
