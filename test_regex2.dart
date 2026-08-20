void main() {
  String text = "takaran saji / serving size 20 g";
  RegExp sppRegex = RegExp(
    r'(?:\+|-|±|~)?\s*([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(?:sajian|serving|takaran|porsi).{0,30}?(?:kemasan|container|bungkus|pack|wadah|amount)',
    caseSensitive: false,
  );
  RegExp sppAfterRegex = RegExp(
    r'(?:sajian|serving|takaran|porsi).{0,30}?(?:kemasan|container|bungkus|pack|wadah|amount).{0,15}?(?:\+|-|±|~)?\s*([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)',
    caseSensitive: false,
  );
  RegExp sppFallbackRegex = RegExp(
    r'(?:\+|-|±|~)?\s*([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(?:sajian|serving)',
    caseSensitive: false,
  );
  RegExp sppFallbackAfterRegex = RegExp(
    r'(?:jumlah\s*sajian|sajian|serving).{0,15}?(?:\+|-|±|~)?\s*([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)',
    caseSensitive: false,
  );

  var sppMatch = sppRegex.firstMatch(text);
  if (sppMatch != null) print("1: ${sppMatch.group(0)} -> ${sppMatch.group(1)}");

  sppMatch = sppAfterRegex.firstMatch(text);
  if (sppMatch != null) print("2: ${sppMatch.group(0)} -> ${sppMatch.group(1)}");

  sppMatch = sppFallbackRegex.firstMatch(text);
  if (sppMatch != null) print("3: ${sppMatch.group(0)} -> ${sppMatch.group(1)}");

  sppMatch = sppFallbackAfterRegex.firstMatch(text);
  if (sppMatch != null) print("4: ${sppMatch.group(0)} -> ${sppMatch.group(1)}");
}
