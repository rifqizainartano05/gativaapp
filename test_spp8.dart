void main() {
  String text = "sajian per kemasan 2,5 lemak 1 g";
  
  RegExp sppAfterRegex = RegExp(
    r'(?:sajian|sejian|serving|takaran|porsi).{0,20}?(?:kemasan|container|bungkus|pack|wadah|amount|botol|kaleng|gelas|cup).{0,10}?(?<=[\s:(/]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\b',
    caseSensitive: false,
  );
  var match = sppAfterRegex.firstMatch(text);
  if (match != null) {
    print("Match: ${match.group(1)}");
  } else {
    print("No match");
  }
}
