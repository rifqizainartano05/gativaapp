void main() {
  String text = "sajian per kemasan 2,5";
  
  RegExp sppRegex = RegExp(
    r'([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(?:sajian|sejian|serving|takaran|porsi).{0,20}?(?:kemasan|container|bungkus|pack|wadah|amount|botol|kaleng|gelas|cup)',
    caseSensitive: false,
  );
  var match = sppRegex.firstMatch(text);
  if (match != null) {
    print("Match sppRegex: ${match.group(1)}");
  } else {
    print("No match sppRegex");
  }
}
