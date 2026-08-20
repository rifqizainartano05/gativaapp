void main() {
  String text1 = "sajian per kemasan 2,5";
  String text2 = "2,5 sajian per kemasan";
  String text3 = "sajian per kemasan l g";
  String text4 = "nilai gizi 2,5 sajian per kemasan";
  
  RegExp sppRegex = RegExp(
    r'(?<=[\s:(/]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\b\s*(?:sajian|sejian|serving|takaran|porsi).{0,20}?(?:kemasan|container|bungkus|pack|wadah|amount|botol|kaleng|gelas|cup)',
    caseSensitive: false,
  );
  RegExp sppAfterRegex = RegExp(
    r'(?:sajian|sejian|serving|takaran|porsi).{0,20}?(?:kemasan|container|bungkus|pack|wadah|amount|botol|kaleng|gelas|cup).{0,10}?(?<=[\s:(/]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\b',
    caseSensitive: false,
  );
  RegExp sppFallbackRegex = RegExp(
    r'(?<=[\s:(/]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\b\s*(?:sajian|sejian|serving|perkemasan|kemasan)',
    caseSensitive: false,
  );
  RegExp sppFallbackAfterRegex = RegExp(
    r'(?:jumlah\s*sajian|jumlah\s*sejian|sajian|sejian|serving|perkemasan|kemasan).{0,10}?(?<=[\s:(/]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\b',
    caseSensitive: false,
  );

  for (var text in [text1, text2, text3, text4]) {
    var match = sppRegex.firstMatch(text) ?? sppAfterRegex.firstMatch(text) ?? sppFallbackRegex.firstMatch(text) ?? sppFallbackAfterRegex.firstMatch(text);
    if (match != null) {
      print("Match for '$text': ${match.group(1)}");
    } else {
      print("No match for '$text'");
    }
  }
}
