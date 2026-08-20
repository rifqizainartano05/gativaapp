void main() {
  String badText = "takaran saji sajian per kemasan tidak ada angkanya sama sekali dan ini panjang banget dan tidak ada g atau gram nya " * 50;
  
  RegExp servingSizeRegex = RegExp(
    r'(?:takaran\s*saji|serving\s*size|jumlah\s*persajian).{0,40}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(g|gr|ml|oz|cup|sdm|sdt|keping|bks|bungkus|porsi|sajian|sejian|gram)',
    caseSensitive: false,
  );

  print("Testing servingSizeRegex...");
  Stopwatch sw = Stopwatch()..start();
  servingSizeRegex.hasMatch(badText);
  print("servingSizeRegex took ${sw.elapsedMilliseconds} ms");

  RegExp sppAfterRegex = RegExp(
    r'(?:sajian|sejian|serving|takaran|porsi).{0,30}?(?:kemasan|container|bungkus|pack|wadah|amount).{0,15}?(?:\+|-|±|~)?\s*([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)',
    caseSensitive: false,
  );
  
  print("Testing sppAfterRegex...");
  sw.reset();
  sppAfterRegex.hasMatch(badText);
  print("sppAfterRegex took ${sw.elapsedMilliseconds} ms");
}
