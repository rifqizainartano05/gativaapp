void main() {
  String text1 = "10 sajian perkemasan";
  String text2 = "sajian perkemasan 10";
  String text3 = "10 sajian per kemasan";
  
  RegExp sppRegex = RegExp(
    r'([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(?:sajian|sejian|serving|takaran|porsi).{0,20}?(?:kemasan|container|bungkus|pack|wadah|amount|botol|kaleng|gelas|cup)',
    caseSensitive: false,
  );
  RegExp sppAfterRegex = RegExp(
    r'(?:sajian|sejian|serving|takaran|porsi).{0,20}?(?:kemasan|container|bungkus|pack|wadah|amount|botol|kaleng|gelas|cup).{0,10}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)',
    caseSensitive: false,
  );
  
  for (var text in [text1, text2, text3]) {
    var sppMatch = sppRegex.firstMatch(text) ?? sppAfterRegex.firstMatch(text);
    if (sppMatch != null) {
      print("Match for '$text': ${sppMatch.group(1)}");
    } else {
      print("No match for '$text'");
    }
  }
}
