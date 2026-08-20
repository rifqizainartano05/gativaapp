void main() {
  List<String> texts = [
    "takaran saji / serving size 20 g",
    "18 sajian per kemasan / 18 serving amount",
    "sejian per kemasan +2.5",
    "jumlah persajian 10g",
    "sajian per kemasan ±2.5",
    "18 serving amount",
    "sejian per bungkus 3"
  ];

  RegExp servingSizeRegex = RegExp(
    r'(?:takaran\s*saji|serving\s*size|jumlah\s*persajian).{0,40}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(g|gr|ml|oz|cup|sdm|sdt|keping|bks|bungkus|porsi|sajian|sejian|gram)',
    caseSensitive: false,
  );

  RegExp sppRegex = RegExp(
    r'([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(?:sajian|sejian|serving|takaran|porsi).{0,30}?(?:kemasan|container|bungkus|pack|wadah|amount)',
    caseSensitive: false,
  );
  RegExp sppAfterRegex = RegExp(
    r'(?:sajian|sejian|serving|takaran|porsi).{0,30}?(?:kemasan|container|bungkus|pack|wadah|amount).{0,15}?(?:\+|-|±|~)?\s*([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)',
    caseSensitive: false,
  );
  RegExp sppFallbackRegex = RegExp(
    r'([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(?:sajian|sejian|serving)',
    caseSensitive: false,
  );
  RegExp sppFallbackAfterRegex = RegExp(
    r'(?:jumlah\s*sajian|jumlah\s*sejian|sajian|sejian|serving).{0,15}?(?:\+|-|±|~)?\s*([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)',
    caseSensitive: false,
  );

  for (var text in texts) {
    print("Testing: $text");
    var ssMatch = servingSizeRegex.firstMatch(text);
    if (ssMatch != null) {
      print("  Serving Size Match: ${ssMatch.group(1)} ${ssMatch.group(2)}");
    } else {
      print("  Serving Size Match: NULL");
    }

    var sppMatch = sppRegex.firstMatch(text) ?? 
                   sppAfterRegex.firstMatch(text) ?? 
                   sppFallbackRegex.firstMatch(text) ?? 
                   sppFallbackAfterRegex.firstMatch(text);
    if (sppMatch != null) {
      print("  SPP Match: ${sppMatch.group(1)}");
    } else {
      print("  SPP Match: NULL");
    }
  }
}
